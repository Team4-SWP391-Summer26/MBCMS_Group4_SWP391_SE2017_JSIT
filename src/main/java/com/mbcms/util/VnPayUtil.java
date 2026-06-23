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

    /** Parse bookingId tu vnp_TxnRef (phan truoc dau _). */
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
     * Tao URL redirect sang cong VNPay (sandbox hoac production).
     *
     * @param amountVnd so tien VND (khong nhan 100)
     */
    public static String buildPaymentUrl(long bookingId, String bookingCode,
            long amountVnd, String clientIp, String returnUrl) {
        if (!VnPayConfig.isConfigured()) {
            throw new IllegalStateException("Chua cau hinh VNPay (tmnCode/hashSecret).");
        }

        Map<String, String> params = new HashMap<>();
        params.put("vnp_Version", VnPayConfig.getVersion());
        params.put("vnp_Command", VnPayConfig.getCommand());
        params.put("vnp_TmnCode", VnPayConfig.getTmnCode());
        params.put("vnp_Amount", String.valueOf(amountVnd * 100L));
        params.put("vnp_CurrCode", VnPayConfig.getCurrCode());
        params.put("vnp_TxnRef", buildTxnRef(bookingId));
        params.put("vnp_OrderInfo", "Thanh toan dat ve " + bookingCode);
        params.put("vnp_OrderType", VnPayConfig.getOrderType());
        params.put("vnp_Locale", VnPayConfig.getLocale());
        params.put("vnp_ReturnUrl", returnUrl);
        // KHONG gui vnp_IpnUrl trong query: VNPay khong nhan param nay khi tao URL
        // thanh toan -> neu ky kem se "Sai chu ky". IPN URL khai bao o Merchant Portal.
        params.put("vnp_CreateDate", LocalDateTime.now(VN_ZONE).format(CREATE_DATE_FMT));
        params.put("vnp_IpAddr", normalizeIp(clientIp));

        String hash = hmacSha512(buildHashData(params), VnPayConfig.getHashSecret());
        String query = buildQueryString(params) + "&vnp_SecureHash=" + hash;
        return VnPayConfig.getPayUrl() + "?" + query;
    }

    /**
     * Verify chu ky VNPay tra ve (Return URL / IPN).
     * params: tat ca tham so request (co the gom vnp_SecureHash).
     */
    public static boolean verifyReturn(Map<String, String> params) {
        if (!VnPayConfig.isConfigured()) {
            return false;
        }
        String received = params.get("vnp_SecureHash");
        if (received == null) {
            return false;
        }
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

    public static boolean isSuccessResponse(String responseCode, String transactionStatus) {
        return "00".equals(responseCode) && (transactionStatus == null || "00".equals(transactionStatus));
    }

    /** Ghep base URL tu request (khi chua set returnUrl/ipnUrl trong properties). */
    public static String buildAppUrl(jakarta.servlet.http.HttpServletRequest req, String path) {
        String configured = path.contains("ipn")
                ? VnPayConfig.getIpnUrl() : VnPayConfig.getReturnUrl();
        if (configured != null && !configured.isBlank()) {
            return configured.trim();
        }
        StringBuilder sb = new StringBuilder();
        sb.append(req.getScheme()).append("://").append(req.getServerName());
        int port = req.getServerPort();
        if (("http".equals(req.getScheme()) && port != 80)
                || ("https".equals(req.getScheme()) && port != 443)) {
            sb.append(':').append(port);
        }
        sb.append(req.getContextPath()).append(path);
        return sb.toString();
    }

    // ── Hash helpers (VNPay spec) ───────────────────────────────────────────
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

    private static String urlEncode(String value) {
        return URLEncoder.encode(value, StandardCharsets.US_ASCII);
    }

    private static String hmacSha512(String data, String secret) {
        try {
            Mac mac = Mac.getInstance("HmacSHA512");
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
