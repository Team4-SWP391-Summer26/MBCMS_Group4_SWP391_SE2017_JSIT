package com.mbcms.controller.auth;

import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * VerifyServlet - Handles email activation links for new registrations (UC10).
 * URL mapping: /auth/verify
 */
@WebServlet("/auth/verify")
public class VerifyServlet extends HttpServlet {

    private final AuthService authService = new AuthServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("username");
        String token = req.getParameter("token");

        if (username != null) {
            username = username.trim();
        }
        if (token != null) {
            token = token.trim();
        }

        // Validate that parameters are not empty
        if (username == null || username.isEmpty() || token == null || token.isEmpty()) {
            req.setAttribute("errorMsg", "Yêu cầu xác thực không hợp lệ (thiếu tham số).");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        try {
            boolean success = authService.verifyCustomer(username, token);
            if (success) {
                // If verified successfully, redirect back to login page with verified=true
                resp.sendRedirect(req.getContextPath() + "/auth/login?verified=true");
            } else {
                // Verification failed (token expired, mismatch, or already verified)
                req.setAttribute("errorMsg", "Mã xác thực không hợp lệ hoặc tài khoản đã được kích hoạt trước đó.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            }
        } catch (Exception e) {
            getServletContext().log("System error during account verification for: " + username, e);
            req.setAttribute("errorMsg", "Hệ thống gặp sự cố trong quá trình xác thực. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }
}
