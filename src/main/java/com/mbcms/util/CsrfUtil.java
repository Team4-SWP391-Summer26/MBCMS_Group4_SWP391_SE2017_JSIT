package com.mbcms.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.util.UUID;

/**
 * CSRF token helper – session attribute {@value #SESSION_ATTR}, param {@value #PARAM},
 * header {@value #HEADER}.
 */
public final class CsrfUtil {

    public static final String SESSION_ATTR = "csrfToken";
    public static final String PARAM = "_csrf";
    public static final String HEADER = "X-CSRF-TOKEN";

    private CsrfUtil() {
    }

    public static String generateToken() {
        return UUID.randomUUID().toString();
    }

    public static String getOrCreateToken(HttpSession session) {
        if (session == null) {
            return generateToken();
        }
        Object existing = session.getAttribute(SESSION_ATTR);
        if (existing instanceof String s && !s.isEmpty()) {
            return s;
        }
        String token = generateToken();
        session.setAttribute(SESSION_ATTR, token);
        return token;
    }

    public static boolean validate(HttpServletRequest request, HttpSession session) {
        if (session == null) {
            return false;
        }
        Object expectedObj = session.getAttribute(SESSION_ATTR);
        if (!(expectedObj instanceof String expected) || expected.isEmpty()) {
            return false;
        }
        String actual = request.getParameter(PARAM);
        if (actual == null || actual.isEmpty()) {
            actual = request.getHeader(HEADER);
        }
        return expected.equals(actual);
    }
}
