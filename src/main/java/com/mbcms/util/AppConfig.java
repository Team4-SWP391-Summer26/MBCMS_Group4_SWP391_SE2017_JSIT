package com.mbcms.util;

import java.io.InputStream;
import java.util.Properties;

/**
 * Application-wide config from database.properties (shared file with DB/VNPay).
 */
public final class AppConfig {

    private static final String BASE_URL;
    /** VIP seat surcharge percent over showtime base price (default 30 → ×1.30). */
    private static final int VIP_SURCHARGE_PERCENT;

    static {
        Properties p = loadProps();
        String configured = trim(p.getProperty("app.baseUrl"));
        BASE_URL = configured != null ? configured : "http://localhost:9999/MBCMS";
        VIP_SURCHARGE_PERCENT = parsePercent(p.getProperty("pricing.vipSurchargePercent"), 30);
    }

    private AppConfig() {
    }

    public static String getBaseUrl() {
        return BASE_URL;
    }

    /**
     * Fallback VIP % from database.properties when dbo.system_settings is
     * unavailable.
     * Prefer {@link SystemSettings#vipSurchargePercent()} at runtime.
     */
    public static int getVipSurchargePercentFallback() {
        return VIP_SURCHARGE_PERCENT;
    }

    /** @deprecated use {@link SystemSettings#vipSurchargePercent()} */
    @Deprecated
    public static int getVipSurchargePercent() {
        return SystemSettings.vipSurchargePercent();
    }

    /** Multiplier for VIP seats from Admin settings (fallback: properties). */
    public static java.math.BigDecimal getVipMultiplier() {
        int pct = SystemSettings.vipSurchargePercent();
        return java.math.BigDecimal.ONE.add(
                java.math.BigDecimal.valueOf(pct)
                        .divide(java.math.BigDecimal.valueOf(100), 4, java.math.RoundingMode.HALF_UP));
    }

    private static Properties loadProps() {
        Properties p = new Properties();
        try (InputStream is = AppConfig.class.getClassLoader()
                .getResourceAsStream("database.properties")) {
            if (is != null) {
                p.load(is);
            }
        } catch (Exception ignored) {
            // keep defaults
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

    private static int parsePercent(String raw, int defaultValue) {
        if (raw == null || raw.trim().isEmpty()) {
            return defaultValue;
        }
        try {
            int v = Integer.parseInt(raw.trim());
            if (v < 0 || v > 200) {
                return defaultValue;
            }
            return v;
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
