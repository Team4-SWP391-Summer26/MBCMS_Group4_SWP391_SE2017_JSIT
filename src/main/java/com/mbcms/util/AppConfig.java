package com.mbcms.util;

import java.io.InputStream;
import java.util.Properties;

/**
 * Application-wide config from database.properties (shared file with DB/VNPay).
 */
public final class AppConfig {

    private static final String BASE_URL;

    static {
        Properties p = loadProps();
        String configured = trim(p.getProperty("app.baseUrl"));
        BASE_URL = configured != null ? configured : "http://localhost:9999/MBCMS";
    }

    private AppConfig() {}

    public static String getBaseUrl() {
        return BASE_URL;
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
}
