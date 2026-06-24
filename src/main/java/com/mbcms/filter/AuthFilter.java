package com.mbcms.filter;

import com.mbcms.model.Customer;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * AuthFilter - Kiem tra dang nhap Bao ve: /customer/*, /branch/*, /staff/*,
 * /admin/*
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
            String requestURI = request.getRequestURI();
            String queryString = request.getQueryString();
            if (queryString != null && !queryString.isBlank()) {
                requestURI = requestURI + "?" + queryString;
            }
            HttpSession redirectSession = request.getSession(true);
            redirectSession.setAttribute("redirectAfterLogin", requestURI);
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }

        String ctx = request.getContextPath();
        if (request.getRequestURI().startsWith(ctx + "/customer/")) {
            Object principal = session.getAttribute("currentUser");
            if (!(principal instanceof Customer)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Ban khong co quyen truy cap trang nay");
                return;
            }
        }

        chain.doFilter(req, res);
    }
}
