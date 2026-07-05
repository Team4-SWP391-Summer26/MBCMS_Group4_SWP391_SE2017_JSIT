package com.mbcms.controller.booking;

import com.mbcms.exception.SeatUnavailableException;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.FoodService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.service.impl.FoodServiceImpl;
import com.mbcms.util.BookingCustomerGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

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

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

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

        HttpSession session = req.getSession();

        // Tạo hoặc tái sử dụng PENDING booking (tránh conflict khi F5 refresh)
        try {
            BigDecimal foodSubtotal = getFoodSubtotal(session);
            Booking booking = resolveOrCreatePendingBooking(
                    customer, session, showtimeId, seatIds,
                    req.getParameter("promoCode"), foodSubtotal);

            processFoodOrder(booking, session, req);

            req.setAttribute("booking",    booking);
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            attachPromoAttributes(req, booking);
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

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }
        HttpSession session = req.getSession();

        String     showtimeIdParam = req.getParameter("showtimeId");
        List<Long> seatIds         = parseSeatIds(req);
        String     promoCode       = req.getParameter("promoCode");
        String     notes           = req.getParameter("notes");
        boolean    applyPromo      = "true".equals(req.getParameter("applyPromo"));
        boolean    removePromo     = "true".equals(req.getParameter("removePromo"));

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

        // "Áp dụng mã KM" → cập nhật promo trực tiếp trên pending booking hiện
        // có (KHÔNG huỷ + tạo lại), nhờ vậy ghế đang giữ không bị mất/re-lock.
        if (applyPromo || removePromo) {
            Long bookingIdToUpdate = parseBookingId(bookingIdParam, session);
            BigDecimal foodSubtotal = getFoodSubtotal(session);

            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("foodSubtotal", foodSubtotal);

            if (bookingIdToUpdate == null) {
                req.setAttribute("checkoutError", "Invalid booking session. Please select seats again.");
                req.setAttribute("seatLabels", seatDao.findLabelsBySeatIds(seatIds));
                req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);
                return;
            }

            try {
                Booking booking;
                if (removePromo) {
                    booking = bookingService.applyPromoToBooking(
                            bookingIdToUpdate, customer.getUsername(), null, foodSubtotal);
                    req.setAttribute("promoMessage", "Promotion removed.");
                } else {
                    if (promoCode == null || promoCode.trim().isEmpty()) {
                        req.setAttribute("promoError", "Please enter a promotion code.");
                        booking = bookingService.getBookingDetail(bookingIdToUpdate, customer.getUsername());
                        processFoodOrder(booking, session, req);
                        attachPromoAttributes(req, booking);
                        req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);
                        return;
                    }
                    booking = bookingService.applyPromoToBooking(
                            bookingIdToUpdate, customer.getUsername(), promoCode, foodSubtotal);
                    req.setAttribute("promoMessage", "Promotion applied successfully.");
                }
                processFoodOrder(booking, session, req);
                req.setAttribute("booking", booking);
                attachPromoAttributes(req, booking);

            } catch (IllegalArgumentException e) {
                req.setAttribute("promoError", e.getMessage());
                req.setAttribute("promoInput", promoCode != null ? promoCode.trim() : "");
                try {
                    Booking current = bookingService.getBookingDetail(bookingIdToUpdate, customer.getUsername());
                    req.setAttribute("booking", current);
                    processFoodOrder(current, session, req);
                    attachPromoAttributes(req, current);
                } catch (Exception inner) {
                    req.setAttribute("promoError", friendlyPromoError(inner));
                }

            } catch (IllegalStateException e) {
                resp.sendRedirect(req.getContextPath()
                        + "/booking/seats?showtimeId=" + showtimeId + "&seatConflict=1");
                return;

            } catch (SecurityException e) {
                req.setAttribute("promoError", "You are not allowed to update this booking.");

            } catch (RuntimeException e) {
                req.setAttribute("promoError", friendlyPromoError(e));
                req.setAttribute("promoInput", promoCode != null ? promoCode.trim() : "");
                try {
                    Booking current = bookingService.getBookingDetail(bookingIdToUpdate, customer.getUsername());
                    req.setAttribute("booking", current);
                    processFoodOrder(current, session, req);
                    attachPromoAttributes(req, current);
                } catch (Exception ignored) {
                    req.setAttribute("seatLabels", seatDao.findLabelsBySeatIds(seatIds));
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

        // Chuyển sang bước thanh toán — verify ownership trước khi redirect
        try {
            bookingService.getBookingDetail(bookingId, customer.getUsername());
        } catch (SecurityException e) {
            req.setAttribute("checkoutError", "You are not allowed to pay for this booking.");
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("seatIds",    seatIds);
            req.setAttribute("seatLabels", seatDao.findLabelsBySeatIds(seatIds));
            req.getRequestDispatcher("/WEB-INF/views/booking/checkout.jsp").forward(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath()
                + "/booking/payment?bookingId=" + bookingId);
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    private Booking resolveOrCreatePendingBooking(Customer customer, HttpSession session,
            long showtimeId, List<Long> seatIds, String promoCode, BigDecimal foodSubtotal)
            throws SeatUnavailableException {
        Long existingId = parseBookingId(null, session);
        if (existingId != null) {
            try {
                Booking existing = bookingService.getBookingDetail(existingId, customer.getUsername());
                if (existing != null
                        && Booking.STATUS_PENDING.equals(existing.getStatus())
                        && !bookingService.isPendingHoldExpired(existingId)
                        && existing.getShowtimeId() == showtimeId
                        && seatIdsEqual(existing.getSeatIds(), seatIds)) {
                    return existing;
                }
            } catch (Exception ignored) {
            }
        }

        Booking booking = bookingService.createPendingBooking(
                customer.getUsername(), showtimeId, seatIds, promoCode, null, foodSubtotal);
        session.setAttribute("pendingBookingId", booking.getBookingId());
        return booking;
    }

    private boolean seatIdsEqual(List<Long> a, List<Long> b) {
        if (a == null || b == null) {
            return false;
        }
        if (a.size() != b.size()) {
            return false;
        }
        return new HashSet<>(a).equals(new HashSet<>(b));
    }

    private BigDecimal getFoodSubtotal(HttpSession session) {
        if (session == null) {
            return BigDecimal.ZERO;
        }
        Map<Long, Integer> selectedFood = (Map<Long, Integer>) session.getAttribute("selectedFoodItems");
        return foodService.computeValidatedFoodSubtotal(selectedFood);
    }

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
        BigDecimal foodSubtotal = getFoodSubtotal(session);
        if (selectedFood != null && !selectedFood.isEmpty()) {
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

    private void attachPromoAttributes(HttpServletRequest req, Booking booking) {
        req.setAttribute("appliedPromoCode", bookingService.resolveAppliedPromoCode(booking));
    }

    /** Map DB/runtime failures to a checkout-safe message (avoid raw SQLException in UI). */
    private String friendlyPromoError(Throwable e) {
        Throwable root = e;
        while (root.getCause() != null) {
            root = root.getCause();
        }
        String msg = root.getMessage() != null ? root.getMessage() : e.getMessage();
        if (msg != null && msg.toLowerCase().contains("branch_id")) {
            return "Promotion system is not fully configured (missing branch_id on promotions). "
                    + "Ask admin to run database/migrations/2026-06-25_add_branch_id_to_promotions.sql.";
        }
        return "Could not apply promotion. Please try again or contact support.";
    }
}