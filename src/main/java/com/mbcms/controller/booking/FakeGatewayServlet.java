package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.Payment;
import com.mbcms.service.PaymentService;
import com.mbcms.service.impl.PaymentServiceImpl;
import com.mbcms.util.BookingCustomerGuard;
import com.mbcms.util.VnPayConfig;
import com.mbcms.util.VnPayUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.RoundingMode;

/**
 * Payment gateway entry - POST tu payment.jsp.
 * Redirect sang VNPay Sandbox (online payment duy nhat).
 */
@WebServlet("/booking/payment/gateway")
public class FakeGatewayServlet extends HttpServlet {

    private final PaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handle(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

        Long bookingId = parseLong(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            Booking booking = paymentService.initiatePayment(
                    bookingId, Payment.METHOD_VNPAY, customer.getUsername());
            redirectToVnPay(req, resp, booking);

        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);

        } catch (IllegalStateException e) {
            resp.sendRedirect(req.getContextPath()
                    + "/booking/payment?bookingId=" + bookingId);

        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath()
                    + "/booking/payment?bookingId=" + bookingId + "&err=method");
        }
    }

    private void redirectToVnPay(HttpServletRequest req, HttpServletResponse resp,
            Booking booking) throws IOException {
        if (!VnPayConfig.isConfigured()) {
            resp.sendRedirect(req.getContextPath()
                    + "/booking/payment?bookingId=" + booking.getBookingId()
                    + "&err=vnpay_config");
            return;
        }

        String returnUrl = VnPayUtil.buildAppUrl(req, "/booking/payment/vnpay-return");
        long amountVnd = booking.getTotalAmount()
                .setScale(0, RoundingMode.HALF_UP).longValue();

        String paymentUrl = VnPayUtil.buildPaymentUrl(
                booking.getBookingId(),
                booking.getBookingCode(),
                amountVnd,
                req.getRemoteAddr(),
                returnUrl);

        resp.sendRedirect(paymentUrl);
    }

    private Long parseLong(String s) {
        if (s == null) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
