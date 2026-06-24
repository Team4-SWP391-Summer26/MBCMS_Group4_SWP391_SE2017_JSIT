package com.mbcms.service.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Customer;
import com.mbcms.service.GoogleOAuthService;
import com.mbcms.util.GoogleOAuthConfig;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;

/**
 * GoogleOAuthServiceImpl - thuc thi luong OAuth 2.0 Authorization Code Flow.
 *
 * Thu vien dung: KHONG co them thu vien ngoai. - HTTP call:
 * java.net.HttpURLConnection (san co trong JDK) - JSON parse: thu cong
 * (String.split / regex nhe) -> du cho cac field don gian cua Google userinfo /
 * token response ma KHONG can them Gson/Jackson. - Username tu dong sinh: "g_"
 * + 8 ky tu dau cua sub (duy nhat theo Google).
 */
public class GoogleOAuthServiceImpl implements GoogleOAuthService {

    private final CustomerDAO customerDAO;

    public GoogleOAuthServiceImpl() {
        this.customerDAO = new CustomerDAOImpl();
    }

    // De inject trong unit test
    public GoogleOAuthServiceImpl(CustomerDAO customerDAO) {
        this.customerDAO = customerDAO;
    }

    // ------------------------------------------------------------------
    // 1. Build authorization URL
    // ------------------------------------------------------------------
    @Override
    public String buildAuthorizationUrl(String state) {
        return GoogleOAuthConfig.authUrl()
                + "?client_id=" + encode(GoogleOAuthConfig.clientId())
                + "&redirect_uri=" + encode(GoogleOAuthConfig.redirectUri())
                + "&response_type=code"
                + "&scope=" + GoogleOAuthConfig.scope() // da encode trong .properties
                + "&state=" + encode(state)
                + "&access_type=online"
                + "&prompt=select_account";   // luon hien picker tai khoan
    }

    // ------------------------------------------------------------------
    // 2. Exchange code -> access_token
    // ------------------------------------------------------------------
    @Override
    public String exchangeCodeForToken(String code) {
        String body = "code=" + encode(code)
                + "&client_id=" + encode(GoogleOAuthConfig.clientId())
                + "&client_secret=" + encode(GoogleOAuthConfig.clientSecret())
                + "&redirect_uri=" + encode(GoogleOAuthConfig.redirectUri())
                + "&grant_type=authorization_code";

        String json = postForm(GoogleOAuthConfig.tokenUrl(), body);

        // Parse "access_token":"..."
        String token = extractJsonString(json, "access_token");
        if (token == null || token.isEmpty()) {
            throw new RuntimeException("Google token endpoint khong tra ve access_token. Response: " + json);
        }
        return token;
    }

    // ------------------------------------------------------------------
    // 3. Get user info
    // ------------------------------------------------------------------
    @Override
    public Customer loginWithGoogle(String accessToken) {
        String json = getWithBearer(GoogleOAuthConfig.userInfoUrl(), accessToken);

        String sub = extractJsonString(json, "sub");
        String email = extractJsonString(json, "email");
        String name = extractJsonString(json, "name");

        if (sub == null || sub.isEmpty()) {
            throw new RuntimeException("Google userinfo khong chua 'sub'.");
        }

        // 1. Tim theo google_id
        Customer existing = customerDAO.findByGoogleId(sub);
        if (existing != null) {
            if (!existing.isActive()) {
                throw new RuntimeException("TAI_KHOAN_BI_KHOA");
            }
            return existing;
        }

        // 2. Email da ton tai -> link google_id
        Customer byEmail = customerDAO.findByEmail(email);
        if (byEmail != null) {
            if (!byEmail.isActive()) {
                throw new RuntimeException("TAI_KHOAN_BI_KHOA");
            }
            customerDAO.linkGoogleId(byEmail.getUsername(), sub);
            byEmail.setGoogleId(sub);
            byEmail.setEmailVerified(true);
            return byEmail;
        }

        // 3. Tao moi
        Customer newCustomer = new Customer();
        newCustomer.setUsername(generateUsername(sub));
        newCustomer.setEmail(email);
        newCustomer.setFullName(name != null ? name : "Google User");
        newCustomer.setGoogleId(sub);
        newCustomer.setActive(true);
        newCustomer.setEmailVerified(true);
        newCustomer.setCreatedAt(LocalDateTime.now());

        if (!customerDAO.insertGoogleCustomer(newCustomer)) {
            throw new RuntimeException("Khong the tao tai khoan Google moi.");
        }
        return newCustomer;
    }

    // ------------------------------------------------------------------
    // Private helpers
    // ------------------------------------------------------------------
    /**
     * Tao username duy nhat: "g_" + 8 ky tu dau sub (sub la so -> safe).
     */
    private static String generateUsername(String sub) {
        String part = sub.length() > 8 ? sub.substring(0, 8) : sub;
        return "g_" + part;
    }

    private static String encode(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.name());
        } catch (UnsupportedEncodingException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * HTTP POST application/x-www-form-urlencoded, tra ve response body.
     */
    private static String postForm(String urlStr, String formBody) {
        try {
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setDoOutput(true);
            conn.setConnectTimeout(10_000);
            conn.setReadTimeout(10_000);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setRequestProperty("Accept", "application/json");

            try (OutputStream os = conn.getOutputStream()) {
                os.write(formBody.getBytes(StandardCharsets.UTF_8));
            }

            int status = conn.getResponseCode();
            InputStream is = (status < 400) ? conn.getInputStream() : conn.getErrorStream();
            String body = readStream(is);

            if (status >= 400) {
                throw new RuntimeException("Google token endpoint loi HTTP " + status + ": " + body);
            }
            return body;
        } catch (IOException e) {
            throw new RuntimeException("Loi ket noi toi Google token endpoint: " + e.getMessage(), e);
        }
    }

    /**
     * HTTP GET voi Authorization: Bearer header.
     */
    private static String getWithBearer(String urlStr, String accessToken) {
        try {
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(10_000);
            conn.setReadTimeout(10_000);
            conn.setRequestProperty("Authorization", "Bearer " + accessToken);
            conn.setRequestProperty("Accept", "application/json");

            int status = conn.getResponseCode();
            InputStream is = (status < 400) ? conn.getInputStream() : conn.getErrorStream();
            String body = readStream(is);

            if (status >= 400) {
                throw new RuntimeException("Google userinfo endpoint loi HTTP " + status + ": " + body);
            }
            return body;
        } catch (IOException e) {
            throw new RuntimeException("Loi ket noi toi Google userinfo endpoint: " + e.getMessage(), e);
        }
    }

    private static String readStream(InputStream is) throws IOException {
        if (is == null) {
            return "";
        }
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        }
    }

    /**
     * Parse JSON string value cho key trong JSON phang (khong long). Du dung
     * cho Google token + userinfo response. Vi du:
     * {"access_token":"ya29.xxx","token_type":"Bearer"}
     */
    static String extractJsonString(String json, String key) {
        if (json == null || key == null) {
            return null;
        }
        // Tim: "key":"value" hoac "key": "value" hoac "key":true/false/number
        String pattern = "\"" + key + "\"";
        int idx = json.indexOf(pattern);
        if (idx < 0) {
            return null;
        }

        int colonIdx = json.indexOf(':', idx + pattern.length());
        if (colonIdx < 0) {
            return null;
        }

        // Bo qua khoang trang sau dau :
        int start = colonIdx + 1;
        while (start < json.length() && json.charAt(start) == ' ') {
            start++;
        }

        if (start >= json.length()) {
            return null;
        }

        char first = json.charAt(start);
        if (first == '"') {
            // String value: lay den " dong sau (xu ly \" escape don gian)
            int end = start + 1;
            while (end < json.length()) {
                if (json.charAt(end) == '"' && json.charAt(end - 1) != '\\') {
                    break;
                }
                end++;
            }
            return json.substring(start + 1, end);
        } else {
            // Boolean hoac number: lay den , hoac }
            int end = start;
            while (end < json.length() && json.charAt(end) != ',' && json.charAt(end) != '}') {
                end++;
            }
            return json.substring(start, end).trim();
        }
    }
}
