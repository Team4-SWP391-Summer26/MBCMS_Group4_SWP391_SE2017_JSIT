package com.mbcms.controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * LoginServlet - owner: <b>TrangNT</b> (Report 4).
 * Servlet chi forward/redirect; goi {@link com.mbcms.service.AuthService}, khong SQL.
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
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // TODO TrangNT: Login
        // - Doc loginId + password (thong nhat ten param voi login.jsp)
        // - AuthService.loginCustomer / loginEmployee + BCrypt
        // - Session fixation: invalidate session cu, tao moi, set currentUser
        // - Redirect theo role (customer -> /home; employee -> dashboard tuong ung)
        req.setAttribute("errorMsg", "Chua implement - owner TrangNT");
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }
}
