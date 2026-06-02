package com.mbcms.controller.auth;

import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ChangePasswordServlet - xu ly doi mat khau cho user da dang nhap.
 * URL: /auth/change-password
 */
@WebServlet("/auth/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private final AuthService authService = new AuthServiceImpl();

    /**
     * Hien thi form doi mat khau.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(req, resp);
    }

    /**
     * Nhan form, validate input, goi Service de doi mat khau.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

       HttpSession session = req.getSession(false);

    // If user is not logged in, redirect to login page
    if (session == null || session.getAttribute("currentUser") == null) {
        resp.sendRedirect(req.getContextPath() + "/auth/login");
        return;
    }

    // Get current logged-in user information from session
    String username = (String) session.getAttribute("username");
    String userRole = (String) session.getAttribute("userRole");

    // Get form data
    String oldPassword = req.getParameter("oldPassword");
    String newPassword = req.getParameter("newPassword");
    String confirmPassword = req.getParameter("confirmPassword");

    // Check whether new password and confirm password match
    if (newPassword == null || confirmPassword == null || !newPassword.equals(confirmPassword)) {
        req.setAttribute("errorMsg", "New password and confirm password do not match.");
        req.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(req, resp);
        return;
    }

    try {
        // Call service to handle change password logic
        String result = authService.changePassword(username, userRole, oldPassword, newPassword);

        switch (result) {
            case "SUCCESS":
                req.setAttribute("successMsg", "Password changed successfully.");
                break;

            case "WRONG_OLD_PASSWORD":
                req.setAttribute("errorMsg", "Current password is incorrect.");
                break;

            case "WEAK_PASSWORD":
                req.setAttribute("errorMsg", "New password must be at least 6 characters.");
                break;

            case "SAME_PASSWORD":
                req.setAttribute("errorMsg", "New password must be different from the current password.");
                break;

            case "USER_NOT_FOUND":
                req.setAttribute("errorMsg", "Account not found or has been disabled.");
                break;

            default:
                req.setAttribute("errorMsg", "Failed to change password. Please try again.");
                break;
        }

    } catch (RuntimeException ex) {
        // Log real error on server, do not show database error details to users
        getServletContext().log("System error while changing password", ex);
        req.setAttribute("errorMsg", "The system is currently unavailable. Please try again later.");
    }

    // Forward back to change password page to show message
    req.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(req, resp);
    }
}