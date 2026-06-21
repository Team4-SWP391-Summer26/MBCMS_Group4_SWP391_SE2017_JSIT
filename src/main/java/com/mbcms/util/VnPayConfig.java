package com.mbcms.util;

import java.io.InputStream;
import java.util.Properties;

/**
 * Cau hinh VNPay Sandbox / Production doc tu database.properties.
 *
 * Dang ky sandbox: https://sandbox.vnpayment.vn/devreg/
 * Sau khi co Terminal (vnp_TmnCode) + Secret Key, dien vao database.properties.
 */
public final class VnPayConfig {

    private static final String PREFIX = "payment.vnpay.";

    private static final String TMN_CODE;
    private static final String HASH_SECRET;
    private static final String PAY_URL;
    private static final String RETURN_URL;
    private static final String IPN_URL;
    private static final String VERSION;
    private static final String COMMAND;
    private static final String CURR_CODE;
    private static final String LOCALE;
    private static final String ORDER_TYPE;

    static {
        Properties p = loadProps();
        TMN_CODE   = trim(p.getProperty(PREFIX + "tmnCode"));
        HASH_SECRET = trim(p.getProperty(PREFIX + "hashSecret"));
        PAY_URL    = defaultIfBlank(p.getProperty(PREFIX + "payUrl"),
                "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html");
        RETURN_URL = trim(p.getProperty(PREFIX + "returnUrl"));
        IPN_URL    = trim(p.getProperty(PREFIX + "ipnUrl"));
        VERSION    = defaultIfBlank(p.getProperty(PREFIX + "version"), "2.1.0");
        COMMAND    = defaultIfBlank(p.getProperty(PREFIX + "command"), "pay");
        CURR_CODE  = defaultIfBlank(p.getProperty(PREFIX + "currCode"), "VND");
        LOCALE     = defaultIfBlank(p.getProperty(PREFIX + "locale"), "vn");
        ORDER_TYPE = defaultIfBlank(p.getProperty(PREFIX + "orderType"), "other");
    }

    private VnPayConfig() {}

    /** Da cau hinh du TmnCode + HashSecret de goi VNPay that. */
    public static boolean isConfigured() {
        return TMN_CODE != null && HASH_SECRET != null;
    }

    public static String getTmnCode() { return TMN_CODE; }
    public static String getHashSecret() { return HASH_SECRET; }
    public static String getPayUrl() { return PAY_URL; }
    public static String getReturnUrl() { return RETURN_URL; }
    public static String getIpnUrl() { return IPN_URL; }
    public static String getVersion() { return VERSION; }
    public static String getCommand() { return COMMAND; }
    public static String getCurrCode() { return CURR_CODE; }
    public static String getLocale() { return LOCALE; }
    public static String getOrderType() { return ORDER_TYPE; }

    private static Properties loadProps() {
        Properties p = new Properties();
        try (InputStream is = VnPayConfig.class.getClassLoader()
                .getResourceAsStream("database.properties")) {
            if (is != null) {
                p.load(is);
            }
        } catch (Exception ignored) {
            // giu trong
        }
        return p;
    }

    private static String trim(String s) {
        if (s == null) {
            return null;
        }
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }

    private static String defaultIfBlank(String value, String def) {
        String t = trim(value);
        return t == null ? def : t;
    }
}
