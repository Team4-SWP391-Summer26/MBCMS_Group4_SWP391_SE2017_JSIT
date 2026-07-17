package com.mbcms.controller.auth;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet - owner: TrangNT (Report 4).
 */
@WebServlet("/auth/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Set success message if redirected from registration or password reset
        if ("true".equals(req.getParameter("resetSuccess"))) {
            req.setAttribute("successMsg", "Your password has been reset successfully. Please sign in with your new password.");
        } else if ("true".equals(req.getParameter("registered"))) {
            req.setAttribute("successMsg", "Registration successful! Please check your email and "
                    + "click the verification link before signing in.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username = req.getParameter("email");
        String password = req.getParameter("password");
        boolean rememberMe = "true".equals(req.getParameter("rememberMe"));

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Please enter username and password.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        username = username.trim();

        AuthService authService = new AuthServiceImpl();
        Customer customer;
        Employee employee;

        try {
            customer = authService.loginCustomer(username, password);
            employee = (customer == null)
                    ? authService.loginEmployee(username, password)
                    : null;
        } catch (RuntimeException ex) {
            // Loi he thong (DB/pool...) - log day du o server, KHONG lo chi tiet ra UI.
            // Thong bao RIENG voi "sai mat khau" de loi DB khong bi nguy trang.
            getServletContext().log("System error", ex);
            req.setAttribute("errorMsg", "Please try again.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        if (customer != null) {
            HttpSession old = req.getSession(false);
            String redirectAfterLogin = null;
            if (old != null) {
                Object saved = old.getAttribute("redirectAfterLogin");
                if (saved instanceof String) {
                    redirectAfterLogin = (String) saved;
                }
                old.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", customer);
            session.setAttribute("userRole", "CUSTOMER");
            session.setAttribute("username", customer.getUsername());
            applyRememberMe(req, resp, session, rememberMe);
            String target = resolveSafeRedirect(req, redirectAfterLogin);
            resp.sendRedirect(target);
            return;
        }

        if (employee != null) {
            HttpSession old = req.getSession(false);
            if (old != null) {
                old.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", employee);
            session.setAttribute("userRole", employee.getRole()); //add later
            session.setAttribute("username", employee.getUsername());
            if (employee.getBranchId() != null) {
                session.setAttribute("branchId", employee.getBranchId());
                session.setAttribute("currentBranchId", employee.getBranchId());
            }
            applyRememberMe(req, resp, session, rememberMe);
            String redirect;
            if (employee.isAdmin()) {
                redirect = req.getContextPath() + "/admin/dashboard";
            } else if (employee.isBranchStaff()) {
                redirect = req.getContextPath() + "/staff/booking";
            } else {
                redirect = req.getContextPath() + "/branch/dashboard";
            }
            resp.sendRedirect(redirect);
            return;
        }

        // Phan biet cac truong hop dung pass nhung khong the dang nhap:
        // 1. Tai khoan bi khoa/vo hieu hoa -> bao rieng.
        // 2. Chua verify email -> bao verify (khong phai "sai pass").
        // 3. Con lai -> sai username/password.
        if (authService.isInactiveAccount(username, password)) {
            req.setAttribute("errorMsg",
                    "Your account has been deactivated. Please contact support for assistance.");
        } else if (authService.isUnverifiedAccount(username, password)) {
            req.setAttribute("errorMsg",
                    "Your email is not verified yet. Please check your inbox for the verification link.");
        } else {
            req.setAttribute("errorMsg", "Username or password incorrect.");
        }
        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    /**
     * Xu ly "Remember me": neu duoc chon, keo dai thoi gian song cua session
     * len 7 ngay VA ghi de cookie JSESSIONID de trinh duyet giu cookie sau khi
     * dong (mac dinh JSESSIONID la session cookie, mat khi dong browser). Neu
     * khong chon, giu nguyen session-timeout mac dinh trong web.xml (30 phut).
     */
    private static final int REMEMBER_ME_MAX_AGE_SECONDS = 7 * 24 * 60 * 60; // 7 ngay

    private void applyRememberMe(HttpServletRequest req, HttpServletResponse resp,
            HttpSession session, boolean rememberMe) {
        if (!rememberMe) {
            return;
        }

        session.setMaxInactiveInterval(REMEMBER_ME_MAX_AGE_SECONDS);

        // Ghi de cookie session (mac dinh ten la JSESSIONID) voi Max-Age = 7 ngay
        // de trinh duyet luu lai sau khi dong, thay vi xoa khi tat browser.
        Cookie sessionCookie = new Cookie("JSESSIONID", session.getId());
        sessionCookie.setMaxAge(REMEMBER_ME_MAX_AGE_SECONDS);
        String cookiePath = req.getContextPath();
        sessionCookie.setPath(cookiePath == null || cookiePath.isEmpty() ? "/" : cookiePath);
        sessionCookie.setHttpOnly(true);
        sessionCookie.setSecure(req.isSecure());
        resp.addCookie(sessionCookie);
    }

    /** Chỉ cho redirect nội bộ app (chống open redirect). */
    private String resolveSafeRedirect(HttpServletRequest req, String redirectAfterLogin) {
        String fallback = req.getContextPath() + "/home";
        if (redirectAfterLogin == null || redirectAfterLogin.isBlank()) {
            return fallback;
        }
        String ctx = req.getContextPath();
        if (!redirectAfterLogin.startsWith(ctx + "/")) {
            return fallback;
        }
        if (redirectAfterLogin.startsWith(ctx + "/auth/login")
                || redirectAfterLogin.startsWith(ctx + "/auth/register")) {
            return fallback;
        }
        return redirectAfterLogin;
    }
}
