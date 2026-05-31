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

    AuthService authService = new AuthServiceImpl();
    Customer customer;
    Employee employee;

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

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (username == null || username.trim().isEmpty()
                || password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Please enter username and password.");
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        username = username.trim();

        if (customer != null) {
            req.getSession().setAttribute("currentUser", customer);
            req.getSession().setAttribute("userRole", "CUSTOMER");//Them role sau
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        if (employee != null) {
            req.getSession().setAttribute("currentUser", employee);
            req.getSession().setAttribute("userRole", employee.getRole());//Them role sau
            if (employee.getBranchId() != null) {
                req.getSession().setAttribute("branchId", employee.getBranchId());//them brnach sau
            }
            String redirect;
            if (employee.isAdmin()) {
                redirect = req.getContextPath() + "/admin/dashboard";
            } else {
                redirect = req.getContextPath() + "/branch/dashboard";
            }
            resp.sendRedirect(redirect);
            return;
        }

        // Ca hai null = thuc su sai tai khoan/mat khau.
        req.setAttribute("errorMsg", "Username or password incorrect");
        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }
}
