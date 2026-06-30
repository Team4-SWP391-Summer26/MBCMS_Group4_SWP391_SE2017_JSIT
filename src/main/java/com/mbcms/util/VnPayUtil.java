package com.mbcms.util;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * VNPay Sandbox/Production - tao URL thanh toan va verify chu ky tra ve.
 * Thuat toan chu ky: sap xep tham so vnp_* theo alphabet, HMAC-SHA512 (hex).
 * Tham khao tai lieu chinh thuc VNPay Payment Gateway.
 */
public final class VnPayUtil {

    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private static final DateTimeFormatter CREATE_DATE_FMT =
            DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    private VnPayUtil() {}

    /** Tao vnp_TxnRef duy nhat: {bookingId}_{epochMillis}. */
    public static String buildTxnRef(long bookingId) {
        return bookingId + "_" + System.currentTimeMillis();
    }

    /** Parse bookingId tu vnp_TxnRef (phan truoc dau _). Vd "12_1699999999" -> 12. */
    public static Long parseBookingId(String txnRef) {
        if (txnRef == null || txnRef.isBlank()) {
            return null;
        }
        int idx = txnRef.indexOf('_');
        String idPart = idx > 0 ? txnRef.substring(0, idx) : txnRef;
        try {
            return Long.parseLong(idPart.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /**
     * [PHAN DI] Dung URL thanh toan VNPay co KY CHU KY.
     *
     * 3 buoc: (1) gom tham so vnp_*  ->  (2) sap xep alphabet + ky HMAC-SHA512
     * bang hashSecret  ->  (3) gan &vnp_SecureHash vao query. Cong VNPay se ky
     * lai cung cong thuc va so sanh; sai 1 ky tu la "Sai chu ky" -> chong gia mao.
     *
     * @param amountVnd so tien VND (chua nhan 100; ben trong se nhan 100)
     */
    public static String buildPaymentUrl(long bookingId, String bookingCode,
            long amountVnd, String clientIp, String returnUrl) {
        if (!VnPayConfig.isConfigured()) {
            throw new IllegalStateException("Chua cau hinh VNPay (tmnCode/hashSecret).");
        }

        // (1) Gom cac tham so vnp_* theo dung chuan VNPay (ten merchant, so tien, ma GD...).
        Map<String, String> params = new HashMap<>();
        params.put("vnp_Version", VnPayConfig.getVersion());
        params.put("vnp_Command", VnPayConfig.getCommand());
        params.put("vnp_TmnCode", VnPayConfig.getTmnCode());
        params.put("vnp_Amount", String.valueOf(amountVnd * 100L)); // VNPay yeu cau nhan 100
        params.put("vnp_CurrCode", VnPayConfig.getCurrCode());
        params.put("vnp_TxnRef", buildTxnRef(bookingId)); // ma GD duy nhat: {bookingId}_{millis}
        params.put("vnp_OrderInfo", "Thanh toan dat ve " + bookingCode);
        params.put("vnp_OrderType", VnPayConfig.getOrderType());
        params.put("vnp_Locale", VnPayConfig.getLocale());
        params.put("vnp_ReturnUrl", returnUrl);
        // KHONG gui vnp_IpnUrl trong query: VNPay khong nhan param nay khi tao URL
        // thanh toan -> neu ky kem se "Sai chu ky". IPN URL khai bao o Merchant Portal.
        params.put("vnp_CreateDate", LocalDateTime.now(VN_ZONE).format(CREATE_DATE_FMT));
        params.put("vnp_IpAddr", normalizeIp(clientIp));

        // KY CHU KY: sap xep tham so theo alphabet -> HMAC-SHA512 voi hashSecret.
        // Chi ai co secret moi tao dung chu ky -> chong gia mao.
        String hash = hmacSha512(buildHashData(params), VnPayConfig.getHashSecret());
        String query = buildQueryString(params) + "&vnp_SecureHash=" + hash;
        return VnPayConfig.getPayUrl() + "?" + query;
    }

    /**
     * [PHAN VE - KIEM 1] Verify chu ky VNPay gui ve (Return URL / IPN).
     *
     * Y tuong: lay lai cac tham so vnp_* (bo vnp_SecureHash ra), TU KY LAI bang
     * hashSecret cua minh, roi so voi chu ky VNPay gui. Khop -> dung la cua VNPay;
     * lech -> co the bi gia mao / sua tay -> tra false. So sanh bang
     * constantTimeEquals de chong timing attack.
     */
    public static boolean verifyReturn(Map<String, String> params) {
        if (!VnPayConfig.isConfigured()) {
            return false;
        }
        String received = params.get("vnp_SecureHash");
        if (received == null) {
            return false;
        }
        // Gom lai cac tham so vnp_* NHUNG bo chinh vnp_SecureHash(_Type) ra de tu ky lai.
        Map<String, String> signParams = new HashMap<>();
        for (Map.Entry<String, String> e : params.entrySet()) {
            String key = e.getKey();
            if ("vnp_SecureHash".equals(key) || "vnp_SecureHashType".equals(key)) {
                continue;
            }
            if (key.startsWith("vnp_") && e.getValue() != null && !e.getValue().isEmpty()) {
                signParams.put(key, e.getValue());
            }
        }
        String expected = hmacSha512(buildHashData(signParams), VnPayConfig.getHashSecret());
        return constantTimeEquals(expected, received);
    }

    // [PHAN VE - KIEM 2] Giao dich coi la thanh cong khi vnp_ResponseCode == "00"
    // (va vnp_TransactionStatus = "00" hoac khong gui). Moi ma khac deu la that bai.
    public static boolean isSuccessResponse(String responseCode, String transactionStatus) {
        return "00".equals(responseCode) && (transactionStatus == null || "00".equals(transactionStatus));
    }

    /** Ghep base URL tu request (khi chua set returnUrl/ipnUrl trong properties). */
    public static String buildAppUrl(jakarta.servlet.http.HttpServletRequest req, String path) {
        // Uu tien dung URL da cau hinh san trong properties (returnUrl/ipnUrl).
        String configured = path.contains("ipn")
                ? VnPayConfig.getIpnUrl() : VnPayConfig.getReturnUrl();
        if (configured != null && !configured.isBlank()) {
            return configured.trim();
        }
        // Neu chua cau hinh -> tu dung tu request: scheme://host[:port]/contextPath/path
        StringBuilder sb = new StringBuilder();
        sb.append(req.getScheme()).append("://").append(req.getServerName());
        int port = req.getServerPort();
        // Chi them :port khi khac cong mac dinh (80 cho http, 443 cho https).
        if (("http".equals(req.getScheme()) && port != 80)
                || ("https".equals(req.getScheme()) && port != 443)) {
            sb.append(':').append(port);
        }
        sb.append(req.getContextPath()).append(path);
        return sb.toString();
    }

    // ── Hash helpers (VNPay spec) ───────────────────────────────────────────
    // Tao CHUOI DE KY: cac tham so SAP XEP THEO ALPHABET, noi "name=encode(value)" bang &.
    // Thu tu phai giong het ben VNPay, neu khac -> chu ky khac -> "Sai chu ky".
    private static String buildHashData(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < names.size(); i++) {
            String name = names.get(i);
            String value = params.get(name);
            if (value == null || value.isEmpty()) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append('&');
            }
            sb.append(name).append('=').append(urlEncode(value));
        }
        return sb.toString();
    }

    // Tao CHUOI QUERY de gan vao URL (encode ca name lan value). Cung sap xep alphabet.
    private static String buildQueryString(Map<String, String> params) {
        List<String> names = new ArrayList<>(params.keySet());
        Collections.sort(names);
        StringBuilder sb = new StringBuilder();
        for (String name : names) {
            String value = params.get(name);
            if (value == null || value.isEmpty()) {
                continue;
            }
            if (sb.length() > 0) {
                sb.append('&');
            }
            sb.append(urlEncode(name)).append('=').append(urlEncode(value));
        }
        return sb.toString();
    }

    // Encode an toan cho URL (theo chuan VNPay dung US-ASCII).
    private static String urlEncode(String value) {
        return URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }

    // Bam HMAC-SHA512 chuoi data bang khoa bi mat -> tra chu ky dang hex.
    private static String hmacSha512(String data, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
            // Nap khoa bi mat (hashSecret) -> chi ai co khoa moi tao dung chu ky.
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA512"));
            byte[] raw = mac.doFinal(data.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder(raw.length * 2);
            for (byte b : raw) {
                sb.append(String.format("%02x", b & 0xff));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("VNPay HMAC loi: " + e.getMessage(), e);
        }
    }

    // So sanh 2 chuoi trong THOI GIAN KHONG DOI: duyet het moi ky tu roi moi ket luan
    // (khong thoat som nhu equals) -> ke tan cong khong the do thoi gian de doan chu ky.
    private static boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) {
            return false;
        }
        int diff = 0;
        for (int i = 0; i < a.length(); i++) {
            diff |= a.charAt(i) ^ b.charAt(i);
        }
        return diff == 0;
    }

    // Chuan hoa IP khach cho vnp_IpAddr: rong hoac IPv6 localhost (::1) -> 127.0.0.1
    // (VNPay muon IPv4; chay local thuong ra ::1 nen phai doi).
    private static String normalizeIp(String ip) {
        if (ip == null || ip.isBlank()) {
            return "127.0.0.1";
        }
        if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
            return "127.0.0.1";
        }
        return ip;
    }
}
