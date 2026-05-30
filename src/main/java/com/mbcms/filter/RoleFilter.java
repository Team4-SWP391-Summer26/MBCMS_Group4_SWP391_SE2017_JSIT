package com.mbcms.filter;

import com.mbcms.model.Employee;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * RoleFilter - Kiem tra quyen truy cap theo URL prefix.
 * Chay SAU AuthFilter nen "currentUser" chac chan != null.
 *
 * /admin/*  -> ADMIN
 * /branch/* -> BRANCH_MANAGER
 * /staff/*  -> BRANCH_STAFF
 *
 * Cac khu vuc nay deu danh cho Employee; neu currentUser khong phai
 * Employee (vd Customer) -> tu choi.
 */
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        HttpSession session = request.getSession(false);

        Object principal = (session != null) ? session.getAttribute("currentUser") : null;
        String uri = request.getRequestURI();
        String ctx = request.getContextPath();

        boolean allowed = false;
        if (principal instanceof Employee) {
            Employee emp = (Employee) principal;
            if (uri.startsWith(ctx + "/admin/")) {
                allowed = emp.isAdmin();
            } else if (uri.startsWith(ctx + "/branch/")) {
                allowed = emp.isBranchManager();
            } else if (uri.startsWith(ctx + "/staff/")) {
                allowed = emp.isBranchStaff();
            } else {
                allowed = true;
            }
        }

        if (!allowed) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Ban khong co quyen truy cap trang nay");
            return;
        }

        chain.doFilter(req, res);
    }
}
