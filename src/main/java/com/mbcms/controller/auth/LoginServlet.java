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
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String username  = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Vui long nhap tai khoan va mat khau.");
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
            getServletContext().log("Loi he thong khi dang nhap", ex);
            req.setAttribute("errorMsg", "He thong dang gap su co, vui long thu lai sau.");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        if (customer != null) {
            HttpSession old = req.getSession(false);
            if (old != null) old.invalidate();
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", customer);
            session.setAttribute("userRole",    "CUSTOMER");
            session.setAttribute("username",    customer.getUsername());
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        if (employee != null) {
            HttpSession old = req.getSession(false);
            if (old != null) old.invalidate();
            HttpSession session = req.getSession(true);
            session.setAttribute("currentUser", employee);
            session.setAttribute("userRole",    employee.getRole());
            session.setAttribute("username",    employee.getUsername());
            if (employee.getBranchId() != null) {
                session.setAttribute("branchId", employee.getBranchId());
            }
            String redirect = employee.isAdmin()
                    ? req.getContextPath() + "/admin/dashboard"
                    : req.getContextPath() + "/branch/dashboard";
            resp.sendRedirect(redirect);
            return;
        }

        // Ca hai null = thuc su sai tai khoan/mat khau.
        req.setAttribute("errorMsg", "Tai khoan hoac mat khau khong chinh xac.");
        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }
}