package com.mbcms.util;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

/**
 * GoogleOAuthConfig - doc cau hinh OAuth tu database.properties.
 * Singleton lazy-load; chi load file 1 lan khi server khoi dong.
 * Pattern giong voi DBConfig / cac util hien co trong du an.
 */
public final class GoogleOAuthConfig {

    private static volatile Properties props;

    private GoogleOAuthConfig() {}

    private static Properties get() {
        if (props == null) {
            synchronized (GoogleOAuthConfig.class) {
                if (props == null) {
                    try (InputStream in = GoogleOAuthConfig.class
                            .getClassLoader()
                            .getResourceAsStream("database.properties")) {
                        if (in == null) {
                            throw new RuntimeException("Khong tim thay database.properties trong classpath");
                        }
                        Properties p = new Properties();
                        p.load(in);
                        props = p;
                    } catch (IOException e) {
                        throw new RuntimeException("Loi doc database.properties: " + e.getMessage(), e);
                    }
                }
            }
        }
        return props;
    }

    public static String clientId()      { return get().getProperty("google.oauth.clientId",      "").trim(); }
    public static String clientSecret()  { return get().getProperty("google.oauth.clientSecret",  "").trim(); }
    public static String redirectUri()   { return get().getProperty("google.oauth.redirectUri",   "").trim(); }
    public static String scope()         { return get().getProperty("google.oauth.scope",         "openid%20email%20profile").trim(); }
    public static String authUrl()       { return get().getProperty("google.oauth.authUrl",       "https://accounts.google.com/o/oauth2/v2/auth").trim(); }
    public static String tokenUrl()      { return get().getProperty("google.oauth.tokenUrl",      "https://oauth2.googleapis.com/token").trim(); }
    public static String userInfoUrl()   { return get().getProperty("google.oauth.userInfoUrl",   "https://www.googleapis.com/oauth2/v3/userinfo").trim(); }
}
