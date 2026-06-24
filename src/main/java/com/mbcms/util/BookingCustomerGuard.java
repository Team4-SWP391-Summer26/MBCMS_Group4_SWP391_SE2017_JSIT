package com.mbcms.util;

import com.mbcms.model.Customer;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** Reject non-Customer principals on customer booking flows. */
public final class BookingCustomerGuard {

    private BookingCustomerGuard() {
    }

    /**
     * @return Customer if session is valid; otherwise redirects and returns null.
     */
    public static Customer requireCustomer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        Object user = session.getAttribute("currentUser");
        if (!(user instanceof Customer customer)) {
            resp.sendRedirect(req.getContextPath() + "/");
            return null;
        }
        return customer;
    }
}
