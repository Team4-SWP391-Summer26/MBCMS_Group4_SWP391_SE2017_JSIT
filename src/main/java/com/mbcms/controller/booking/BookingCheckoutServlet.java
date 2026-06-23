package com.mbcms.controller.booking;

import com.mbcms.exception.SeatUnavailableException;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.FoodItem;
import com.mbcms.service.BookingService;
import com.mbcms.service.FoodService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.service.impl.FoodServiceImpl;
import com.mbcms.ws.SeatWebSocketServer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * BookingCheckoutServlet – /booking/checkout
 *
 * GET  → Tạo PENDING booking ngay khi người dùng chuyển từ trang chọn ghế,
 *         rồi hiển thị checkout.jsp với bookingId đã pending.
 *
 * POST → Xử lý "Áp dụng mã KM" (applyPromo=true) hoặc "Xác nhận thanh toán"
 *         (forward sang BookingConfirmServlet).
 *
 * seatIds có thể đến dưới dạng:
 *   - Chuỗi CSV:      seatIds=1,2,3   (từ JS redirect trong seats.jsp)
 *   - Multi-param:    seatIds=1&seatIds=2  (từ hidden inputs trong checkout.jsp)
 */
@WebServlet("/booking/checkout")
public class BookingCheckoutServlet extends HttpServlet {

    private BookingService bookingService;
    private SeatDAO seatDao;
    private FoodService foodService;

    @Override
    public void init() {
        bookingService = new BookingServiceImpl();
        seatDao = new SeatDAOImpl();
        foodService = new FoodServiceImpl();
    }

    // ── GET: tạo PENDING booking rồi hiển thị checkout page ──────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        String showtimeIdParam = req.getParameter("showtimeId");
        List<Long> seatIds = parseSeatIds(req);

        if (showtimeIdParam == null || seatIds.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        long showtimeId;
        try {
            showtimeId = Long.parseLong(showtimeIdParam.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // Tạo PENDING booking ngay khi người dùng vào trang checkout
        try {
            Booking booking = bookingService.createPendingBooking(
                    customer.getUsername(), showtimeId, seatIds,
                    req.getParameter("promoCode"), null);

            processFoodOrder(booking, session, req);

            // Lưu vào session để confirm page dùng
            session.setAttribute("pendingBookingId", booking.getBookingId());

            req.setAttribute("booking",    booking);
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("promoCode",  req.getParameter("promoCode"));
            req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);

        } catch (SeatUnavailableException e) {
            // Ghế đã bị người khác chiếm → quay lại chọn ghế
            resp.sendRedirect(req.getContextPath()
                    + "/booking/seats?showtimeId=" + showtimeId
                    + "&seatConflict=1");

        } catch (IllegalArgumentException e) {
            req.setAttribute("checkoutError", e.getMessage());
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("seatLabels", seatDao.findLabelsBySeatIds(seatIds));
            req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("error", "System error: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/common/error500.jsp").forward(req, resp);
        }
    }

    // ── POST: áp dụng promo hoặc xác nhận thanh toán ─────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        String     showtimeIdParam = req.getParameter("showtimeId");
        List<Long> seatIds         = parseSeatIds(req);
        String     promoCode       = req.getParameter("promoCode");
        String     notes           = req.getParameter("notes");
        boolean    applyPromo      = "true".equals(req.getParameter("applyPromo"));

        // bookingId được truyền qua hidden field từ checkout.jsp
        String bookingIdParam = req.getParameter("bookingId");

        if (showtimeIdParam == null || seatIds.isEmpty()) {
            req.setAttribute("checkoutError", "Missing booking information. Please try again.");
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("seatLabels", seatDao.findLabelsBySeatIds(seatIds));
            req.setAttribute("showtimeId", showtimeIdParam);
            req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);
            return;
        }

        long showtimeId;
        try {
            showtimeId = Long.parseLong(showtimeIdParam.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // "Áp dụng mã KM" → huỷ pending booking cũ, tạo lại với promo mới
        // để subtotal/discount/total được tính lại (calcDiscount chỉ chạy
        // bên trong createPendingBooking).
        if (applyPromo) {
            Long oldBookingId = parseBookingId(bookingIdParam, session);
            if (oldBookingId != null) {
                try {
                    bookingService.cancelBooking(oldBookingId, customer.getUsername());
                } catch (Exception e) {
                    System.err.println("WARN: Không huỷ được booking cũ trước khi áp promo: " + e.getMessage());
                }
            }

            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("promoCode",  promoCode);

            try {
                // Tạo lại pending booking (re-lock cùng ghế) với promo mới
                // → subtotal/discount/total được tính lại đúng.
                Booking booking = bookingService.createPendingBooking(
                        customer.getUsername(), showtimeId, seatIds, promoCode, null);
                processFoodOrder(booking, session, req);
                session.setAttribute("pendingBookingId", booking.getBookingId());
                req.setAttribute("booking", booking);

            } catch (SeatUnavailableException e) {
                resp.sendRedirect(req.getContextPath()
                        + "/booking/seats?showtimeId=" + showtimeId + "&seatConflict=1");
                return;

            } catch (IllegalArgumentException e) {
                // Promo không hợp lệ (hết hạn, sai min order, v.v.)
                // → vẫn re-lock ghế nhưng KHÔNG áp promo, để giá hiển thị đúng giá gốc.
                req.setAttribute("checkoutError", e.getMessage());
                try {
                    Booking fallback = bookingService.createPendingBooking(
                            customer.getUsername(), showtimeId, seatIds, null, null);
                    processFoodOrder(fallback, session, req);
                    session.setAttribute("pendingBookingId", fallback.getBookingId());
                    req.setAttribute("booking", fallback);
                } catch (Exception inner) {
                    req.setAttribute("checkoutError", "System error: " + inner.getMessage());
                }
            }

            req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);
            return;
        }

        // Xác nhận thanh toán: lấy bookingId từ hidden field hoặc session
        Long bookingId = parseBookingId(bookingIdParam, session);
        if (bookingId == null) {
            req.setAttribute("checkoutError", "Invalid booking session. Please select seats again.");
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("seatLabels", seatDao.findLabelsBySeatIds(seatIds));
            req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);
            return;
        }

        // Chuyển sang bước thanh toán (PaymentServlet) thay vì confirm thẳng.
        // Booking->CONFIRMED chỉ xảy ra sau khi payment callback thành công.
        resp.sendRedirect(req.getContextPath()
                + "/booking/payment?bookingId=" + bookingId);
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    /**
     * Parse seatIds từ request, hỗ trợ hai định dạng:
     *   1. Multi-param: seatIds=1&seatIds=2
     *   2. CSV:         seatIds=1,2,3
     */
    private List<Long> parseSeatIds(HttpServletRequest req) {
        String[] params = req.getParameterValues("seatIds");
        List<Long> result = new ArrayList<>();
        if (params == null) return result;
        for (String p : params) {
            for (String token : p.split(",")) {
                token = token.trim();
                if (!token.isEmpty()) {
                    try { result.add(Long.parseLong(token)); }
                    catch (NumberFormatException ignored) {}
                }
            }
        }
        return result;
    }

    /** Lấy bookingId: ưu tiên hidden field, fallback session. */
    private Long parseBookingId(String param, HttpSession session) {
        if (param != null && !param.trim().isEmpty()) {
            try { return Long.parseLong(param.trim()); }
            catch (NumberFormatException ignored) {}
        }
        Object sessionVal = session.getAttribute("pendingBookingId");
        if (sessionVal instanceof Long) return (Long) sessionVal;
        if (sessionVal instanceof Number) return ((Number) sessionVal).longValue();
        return null;
    }

    private void processFoodOrder(Booking booking, HttpSession session, HttpServletRequest req) {
        if (session == null) return;
        Map<Long, Integer> selectedFood = (Map<Long, Integer>) session.getAttribute("selectedFoodItems");
        BigDecimal foodSubtotal = BigDecimal.ZERO;
        if (selectedFood != null && !selectedFood.isEmpty()) {
            for (Map.Entry<Long, Integer> entry : selectedFood.entrySet()) {
                FoodItem item = foodService.getFoodItemById(entry.getKey());
                if (item != null) {
                    foodSubtotal = foodSubtotal.add(item.getPrice().multiply(BigDecimal.valueOf(entry.getValue())));
                }
            }
            if (foodSubtotal.compareTo(BigDecimal.ZERO) > 0) {
                // Update booking model
                booking.setSubtotal(booking.getSubtotal().add(foodSubtotal));
                booking.setTotalAmount(booking.getTotalAmount().add(foodSubtotal));
                // Update booking DB
                bookingService.updateBookingTotals(booking.getBookingId(), booking.getSubtotal(), booking.getTotalAmount());
            }
            // Save food order as PENDING
            foodService.saveFoodOrder(booking.getBookingId(), selectedFood, "PENDING");
        } else {
            // clear food order if it was previously saved but user cleared it
            foodService.saveFoodOrder(booking.getBookingId(), null, "PENDING");
        }
        
        req.setAttribute("foodSubtotal", foodSubtotal);
        if (selectedFood != null && !selectedFood.isEmpty()) {
            req.setAttribute("concessions", foodService.getFoodItemsByBookingId(booking.getBookingId()));
        }
    }
}