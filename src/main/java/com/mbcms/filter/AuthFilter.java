package com.mbcms.filter;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter - Kiem tra dang nhap
 * Bao ve: /customer/*, /branch/*, /staff/*, /admin/*
 */
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        boolean loggedIn = (session != null && session.getAttribute("currentUser") != null);

        if (!loggedIn) {
            // Luu URL dang truy cap de redirect sau khi login
            String requestURI = request.getRequestURI();
            request.getSession().setAttribute("redirectAfterLogin", requestURI);
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        chain.doFilter(req, res);
    }
}
