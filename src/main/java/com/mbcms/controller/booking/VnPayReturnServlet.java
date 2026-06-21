package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.VnPayCallbackService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.util.VnPayUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * VNPay Return URL - browser redirect sau khi user thanh toan tren cong VNPay Sandbox.
 * Verify chu ky HMAC-SHA512, xac nhan booking neu vnp_ResponseCode=00.
 */
@WebServlet("/booking/payment/vnpay-return")
public class VnPayReturnServlet extends HttpServlet {

    private final VnPayCallbackService callbackService = new VnPayCallbackService();
    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handle(req, resp);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Map<String, String> vnpParams = extractVnpParams(req);
        VnPayCallbackService.Result result = callbackService.process(vnpParams);
        long bookingId = result.getBookingId();

        if (bookingId == 0 && result.getBooking() != null) {
            bookingId = result.getBooking().getBookingId();
        }
        if (bookingId == 0) {
            String txnRef = vnpParams.get("vnp_TxnRef");
            Long parsed = VnPayUtil.parseBookingId(txnRef);
            if (parsed != null) {
                bookingId = parsed;
            }
        }

        switch (result.getOutcome()) {
            case SUCCESS, ALREADY_PAID -> forwardConfirm(req, resp, result.getBooking());
            case EXPIRED -> redirectPayment(resp, req, bookingId, "expired");
            case PAYMENT_FAILED -> redirectPayment(resp, req, bookingId, "failed");
            case INVALID_SIGNATURE -> redirectPayment(resp, req, bookingId, "signature");
            case INVALID_TXN_REF, BOOKING_NOT_FOUND ->
                    resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            default -> redirectPayment(resp, req, bookingId, "failed");
        }
    }

    private void forwardConfirm(HttpServletRequest req, HttpServletResponse resp, Booking booking)
            throws ServletException, IOException {
        if (booking == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }
        HttpSession session = req.getSession(false);
        if (session != null) {
            Customer customer = (Customer) session.getAttribute("currentUser");
            if (customer != null
                    && !booking.getCustomerUsername().equals(customer.getUsername())) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);
                return;
            }
            session.removeAttribute("pendingBookingId");
            if (customer != null) {
                try {
                    req.setAttribute("ticket",
                            bookingService.getTicket(booking.getBookingId(), customer.getUsername()));
                } catch (Exception ignore) { /* fallback: confirm.jsp dung 'booking' */ }
            }
        }
        req.setAttribute("booking", booking);
        req.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(req, resp);
    }

    private void redirectPayment(HttpServletResponse resp, HttpServletRequest req,
            long bookingId, String err) throws IOException {
        if (bookingId > 0) {
            resp.sendRedirect(req.getContextPath()
                    + "/booking/payment?bookingId=" + bookingId + "&err=" + err);
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
        }
    }

    private Map<String, String> extractVnpParams(HttpServletRequest req) {
        Map<String, String> map = new HashMap<>();
        req.getParameterMap().forEach((key, values) -> {
            if (key.startsWith("vnp_") && values != null && values.length > 0) {
                map.put(key, values[0]);
            }
        });
        return map;
    }
}
