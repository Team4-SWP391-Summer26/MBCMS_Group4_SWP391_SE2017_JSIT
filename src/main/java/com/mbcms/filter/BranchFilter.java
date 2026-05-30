package com.mbcms.filter;

import com.mbcms.model.Employee;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * BranchFilter - Dam bao Branch Manager/Staff chi thao tac tren branch cua minh.
 * Set session attribute "currentBranchId" tu Employee.branchId neu chua co.
 * (ADMIN co branchId = null nen khong set.)
 */
public class BranchFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpSession session = request.getSession(false);

        if (session != null && session.getAttribute("currentBranchId") == null) {
            Object principal = session.getAttribute("currentUser");
            if (principal instanceof Employee) {
                Long branchId = ((Employee) principal).getBranchId();
                if (branchId != null) {
                    session.setAttribute("currentBranchId", branchId);
                }
            }
        }

        chain.doFilter(req, res);
    }
}
