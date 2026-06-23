package com.mbcms.controller.branch;

import com.mbcms.model.Booking;
import com.mbcms.service.VnPayCallbackService;
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
 * CounterVnPayReturnServlet - Xử lý VNPay callback cho đặt vé tại quầy (staff).
 */
@WebServlet("/staff/booking/vnpay-return")
public class CounterVnPayReturnServlet extends HttpServlet {

    private final VnPayCallbackService callbackService = new VnPayCallbackService();
    private final com.mbcms.service.BookingService bookingService = new com.mbcms.service.impl.BookingServiceImpl();
    private final com.mbcms.dao.BookingDAO bookingDao = new com.mbcms.dao.impl.BookingDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handle(req, resp);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("username") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

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

        Booking booking = result.getBooking();
        String bookingCode = (booking != null) ? booking.getBookingCode() : "";

        switch (result.getOutcome()) {
            case SUCCESS, ALREADY_PAID -> {
                // Đăng ký WebSocket notifyHardLock ở đây
                if (booking != null) {
                    try {
                        com.mbcms.ws.SeatWebSocketServer.notifyHardLock(
                                booking.getShowtimeId(),
                                booking.getSeatIds(),
                                "staff"
                        );
                    } catch (Exception ignore) {}
                }
                resp.sendRedirect(req.getContextPath() + "/staff/booking?success=1&bookingCode=" + bookingCode + "&bookingId=" + bookingId);
            }
            default -> {
                if (bookingId > 0) {
                    try {
                        Booking b = bookingDao.findByIdWithSeats(bookingId);
                        if (b != null && Booking.STATUS_PENDING.equals(b.getStatus())) {
                            bookingService.cancelBooking(bookingId, "guest01");
                            com.mbcms.ws.SeatWebSocketServer.notifyHardRelease(b.getShowtimeId(), b.getSeatIds());
                        }
                    } catch (Exception e) {
                        System.err.println("Error cancelling failed counter booking: " + e.getMessage());
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/staff/booking?err=vnpay_failed");
            }
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
