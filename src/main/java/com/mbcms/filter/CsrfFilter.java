package com.mbcms.filter;

import com.mbcms.util.CsrfUtil;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Set;

/**
 * Validates CSRF on POST. VNPay callbacks excluded (external redirect, no session token).
 */
public class CsrfFilter implements Filter {

    private static final Set<String> EXCLUDED_SUFFIXES = Set.of(
            "/booking/payment/vnpay-return",
            "/booking/payment/vnpay-ipn",
            "/staff/booking/vnpay-return"
    );

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(true);
        CsrfUtil.getOrCreateToken(session);

        if ("POST".equalsIgnoreCase(req.getMethod()) && !isExcluded(req)) {
            if (!CsrfUtil.validate(req, session)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    private boolean isExcluded(HttpServletRequest req) {
        String path = req.getRequestURI().substring(req.getContextPath().length());
        for (String suffix : EXCLUDED_SUFFIXES) {
            if (path.equals(suffix)) {
                return true;
            }
        }
        return false;
    }
}
