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
     * Yeu cau session hien tai la mot Customer hop le.
     * Neu KHONG (guest chua dang nhap HOAC admin/branch/staff): luu lai URL dang
     * truy cap (chi voi GET) vao session duoi key "redirectAfterLogin" — dung
     * dung key ma LoginServlet doc — roi dieu huong sang /auth/login. Dang nhap
     * xong, LoginServlet se dua khach quay lai dung trang dat ve dang do.
     *
     * @return Customer neu hop le; nguoc lai da redirect va tra ve null.
     */
    public static Customer requireCustomer(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        Object user = (session == null) ? null : session.getAttribute("currentUser");

        if (user instanceof Customer customer) {
            return customer;
        }

        // Guest hoac non-Customer -> nho lai trang dich (GET) roi ve trang dang nhap.
        if ("GET".equalsIgnoreCase(req.getMethod())) {
            String uri = req.getRequestURI();
            String qs = req.getQueryString();
            String returnUrl = (qs == null || qs.isBlank()) ? uri : uri + "?" + qs;
            req.getSession(true).setAttribute("redirectAfterLogin", returnUrl);
        }
        resp.sendRedirect(req.getContextPath() + "/auth/login");
        return null;
    }
}
