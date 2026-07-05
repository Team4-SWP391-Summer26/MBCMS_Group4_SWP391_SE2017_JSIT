package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.util.BookingCustomerGuard;
import com.mbcms.ws.SeatWebSocketServer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * BookingCancelServlet – POST /customer/booking/cancel
 *
 * Huỷ một PENDING booking của customer hiện tại.
 *
 * Business rules (thực thi ở DAO):
 *   - Chỉ huỷ được booking có status = PENDING.
 *   - Chỉ huỷ được booking thuộc về customer đang đăng nhập.
 *   - CONFIRMED / USED / CANCELLED → không được huỷ.
 *
 * Flow:
 *   POST từ checkout (có showtimeId) → /customer/booking/history?cancelled=1
 *   POST từ lịch sử/chi tiết      → /customer/booking/detail?bookingId=X&cancelled=1
 */
@WebServlet("/customer/booking/cancel")
public class BookingCancelServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

        Long bookingId = parseId(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        String showtimeIdParam = req.getParameter("showtimeId");
        boolean fromCheckout = showtimeIdParam != null && !showtimeIdParam.isBlank();
        String detailUrl = req.getContextPath() + "/customer/booking/detail?bookingId=" + bookingId;
        String ctx = req.getContextPath();

        Booking pending = loadPendingBooking(bookingId, customer.getUsername());

        int rows;
        try {
            rows = bookingService.cancelBooking(bookingId, customer.getUsername());
        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);
            return;
        } catch (Exception e) {
            getServletContext().log("Cancel failed for booking id=" + bookingId, e);
            redirectCancelError(resp, fromCheckout, showtimeIdParam, detailUrl, ctx);
            return;
        }

        if (rows > 0) {
            // DB đã CANCELLED — cleanup/WS không được làm user thấy SYSTEM nếu redirect thất bại.
            try {
                afterSuccessfulCancel(req.getSession(false), bookingId, pending);
            } catch (Exception e) {
                getServletContext().log(
                        "Post-cancel cleanup failed for booking id=" + bookingId, e);
            }
            redirectCancelSuccess(resp, fromCheckout, showtimeIdParam, detailUrl, ctx);
            return;
        }

        redirectNotCancellable(resp, fromCheckout, showtimeIdParam, detailUrl, ctx);
    }

    private Booking loadPendingBooking(long bookingId, String username) {
        try {
            Booking booking = bookingService.getBookingDetail(bookingId, username);
            if (booking != null && Booking.STATUS_PENDING.equals(booking.getStatus())) {
                return booking;
            }
        } catch (Exception e) {
            getServletContext().log("Could not preload booking id=" + bookingId + " before cancel", e);
        }
        return null;
    }

    private void afterSuccessfulCancel(HttpSession session, long bookingId, Booking pending) {
        clearBookingSession(session, bookingId);
        if (pending == null) {
            return;
        }
        List<Long> seatIds = pending.getSeatIds();
        if (seatIds == null || seatIds.isEmpty()) {
            return;
        }
        SeatWebSocketServer.notifyHardRelease(pending.getShowtimeId(), seatIds);
    }

    private void redirectCancelSuccess(HttpServletResponse resp, boolean fromCheckout,
            String showtimeIdParam, String detailUrl, String ctx) throws IOException {
        if (fromCheckout) {
            resp.sendRedirect(ctx + "/customer/booking/history?cancelled=1");
        } else {
            resp.sendRedirect(detailUrl + "&cancelled=1");
        }
    }

    private void redirectNotCancellable(HttpServletResponse resp, boolean fromCheckout,
            String showtimeIdParam, String detailUrl, String ctx) throws IOException {
        if (fromCheckout) {
            resp.sendRedirect(ctx + "/customer/booking/history?cancelErr=NOT_CANCELLABLE");
        } else {
            resp.sendRedirect(detailUrl + "&cancelErr=NOT_CANCELLABLE");
        }
    }

    private void redirectCancelError(HttpServletResponse resp, boolean fromCheckout,
            String showtimeIdParam, String detailUrl, String ctx) throws IOException {
        if (fromCheckout) {
            resp.sendRedirect(ctx + "/customer/booking/history?cancelErr=SYSTEM");
        } else {
            resp.sendRedirect(ctx + "/customer/booking/history?cancelErr=SYSTEM");
        }
    }

    /** Xoá session giữ booking / F&B — an toàn với mọi kiểu pendingBookingId. */
    private void clearBookingSession(HttpSession session, long bookingId) {
        if (session == null) {
            return;
        }
        try {
            Long pendingId = toLong(session.getAttribute("pendingBookingId"));
            if (pendingId != null && pendingId == bookingId) {
                session.removeAttribute("pendingBookingId");
            }
            session.removeAttribute("selectedFoodItems");
        } catch (IllegalStateException e) {
            // Session đã hết hạn — booking vẫn đã huỷ ở DB.
            getServletContext().log("Session expired during cancel cleanup booking id=" + bookingId, e);
        }
    }

    private Long parseId(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private Long toLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        try {
            return Long.parseLong(value.toString().trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
