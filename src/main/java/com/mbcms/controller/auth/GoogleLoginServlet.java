package com.mbcms.controller.auth;

import com.mbcms.service.GoogleOAuthService;
import com.mbcms.service.impl.GoogleOAuthServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.UUID;

/**
 * GoogleLoginServlet - Buoc 1 trong OAuth 2.0 Authorization Code Flow.
 *
 * GET /auth/google/login
 *   -> Sinh state ngau nhien, luu vao session chong CSRF.
 *   -> Redirect nguoi dung den trang chon tai khoan Google.
 *
 * KHONG co doPost (chuyen huong luon qua GET).
 */
@WebServlet("/auth/google/login")
public class GoogleLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Neu da dang nhap roi -> ve trang chu
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Sinh state de chong CSRF (luu session, kiem tra o callback)
        String state = UUID.randomUUID().toString();
        HttpSession newSession = req.getSession(true);
        newSession.setAttribute("oauth_state", state);

        GoogleOAuthService oauthService = new GoogleOAuthServiceImpl();
        String authUrl = oauthService.buildAuthorizationUrl(state);

        resp.sendRedirect(authUrl);
    }
}
