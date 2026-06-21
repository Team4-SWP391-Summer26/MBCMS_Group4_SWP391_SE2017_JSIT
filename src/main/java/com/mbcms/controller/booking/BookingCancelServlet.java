package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * BookingCancelServlet – POST /customer/booking/cancel
 *
 * Huỷ một PENDING booking của customer hiện tại.
 *
 * Business rules (thực thi ở DAO):
 *   - Chỉ huỷ được booking có status = PENDING.
 *   - Chỉ huỷ được booking thuộc về customer đang đăng nhập.
 *   - CONFIRMED / USED / CANCELLED → không được huỷ, redirect với cancelErr.
 *
 * Flow:
 *   POST /customer/booking/cancel?bookingId=X
 *     → Nếu có param "showtimeId" (cancel từ trang checkout):
 *         redirect /booking/seats?showtimeId=X&cancelled=1   (quay lại chọn ghế)
 *     → Ngược lại (cancel từ trang lịch sử/chi tiết):
 *         redirect /customer/booking/detail?bookingId=X&cancelled=1
 */
@WebServlet("/customer/booking/cancel")
public class BookingCancelServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        // ── Parse bookingId ───────────────────────────────────────────────
        Long bookingId = parseId(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        // "showtimeId" hiện diện khi cancel từ trang checkout → quay về chọn ghế
        String showtimeIdParam = req.getParameter("showtimeId");

        String detailUrl = req.getContextPath() + "/customer/booking/detail?bookingId=" + bookingId;

        // ── Gọi service ───────────────────────────────────────────────────
        try {
            int rows = bookingService.cancelBooking(bookingId, customer.getUsername());

            // Xoá pendingBookingId khỏi session nếu đúng booking này
            Object pendingId = session.getAttribute("pendingBookingId");
            if (pendingId != null && Long.parseLong(pendingId.toString()) == bookingId) {
                session.removeAttribute("pendingBookingId");
            }

            if (rows > 0) {
                if (showtimeIdParam != null && !showtimeIdParam.isBlank()) {
                    // Cancel từ checkout → về lại trang chọn ghế
                    resp.sendRedirect(req.getContextPath()
                            + "/booking/seats?showtimeId=" + showtimeIdParam
                            + "&cancelled=1");
                } else {
                    // Cancel từ trang lịch sử/chi tiết
                    resp.sendRedirect(detailUrl + "&cancelled=1");
                }
            } else {
                // 0 rows: không thể huỷ (sai owner / không PENDING / không tồn tại)
                resp.sendRedirect(detailUrl + "&cancelErr=NOT_CANCELLABLE");
            }

        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);

        } catch (RuntimeException e) {
            getServletContext().log("System error while cancelling booking id=" + bookingId, e);
            resp.sendRedirect(detailUrl + "&cancelErr=SYSTEM");
        }
    }

    // ── Helper ────────────────────────────────────────────────────────────
    private Long parseId(String s) {
        if (s == null || s.trim().isEmpty()) return null;
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
