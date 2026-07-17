package com.mbcms.controller.booking;

import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.FoodItem;
import com.mbcms.model.Showtime;
import com.mbcms.service.BookingService;
import com.mbcms.service.FoodService;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.service.impl.FoodServiceImpl;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;
import com.mbcms.util.BookingCustomerGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * BookingFoodDrinksServlet – /booking/food-drinks
 * Step 3: Select Food & Drinks concessions catalog.
 */
@WebServlet("/booking/food-drinks")
public class BookingFoodDrinksServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_FMT
            = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private FoodService foodService;
    private BookingService bookingService;
    private SeatDAO seatDao;
    private SeatAvailabilityService seatService;

    @Override
    public void init() {
        foodService = new FoodServiceImpl();
        bookingService = new BookingServiceImpl();
        seatDao = new SeatDAOImpl();
        seatService = new SeatAvailabilityServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

        String bookingIdParam = req.getParameter("bookingId");
        String showtimeIdParam = req.getParameter("showtimeId");
        String seatIdsParam = req.getParameter("seatIds");
        Booking booking = null;

        if (bookingIdParam != null) {
            try {
                long bookingId = Long.parseLong(bookingIdParam.trim());
                booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
                if (booking != null) {
                    showtimeIdParam = String.valueOf(booking.getShowtimeId());
                    List<Long> seatIds = booking.getSeatIds();
                    StringBuilder sb = new StringBuilder();
                    if (seatIds != null) {
                        for (int i = 0; i < seatIds.size(); i++) {
                            sb.append(seatIds.get(i));
                            if (i < seatIds.size() - 1) {
                                sb.append(",");
                            }
                        }
                    }
                    seatIdsParam = sb.toString();
                    req.setAttribute("bookingId", bookingId);
                    req.setAttribute("booking", booking);

                    Map<FoodItem, Integer> existingFood = foodService.getFoodItemsByBookingId(bookingId);
                    req.setAttribute("existingFood", existingFood);
                }
            } catch (Exception ignored) {
            }
        }

        if (showtimeIdParam == null || seatIdsParam == null || seatIdsParam.trim().isEmpty()) {
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

        List<Long> seatIdList = parseSeatIds(seatIdsParam);
        Showtime showtime = seatService.getShowtime(showtimeId);
        if (showtime == null) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // Chi hien thi mon cua chi nhanh so huu suat chieu nay (khong lo mon chi nhanh khac).
        List<FoodItem> foodItems = foodService.getActiveFoodItemsForShowtime(showtimeId);

        req.setAttribute("foodItems", foodItems);
        req.setAttribute("showtimeId", showtimeId);
        req.setAttribute("showtime", showtime);
        req.setAttribute("showtimeDate", showtime.getStartTime().toLocalDate().toString());
        req.setAttribute("startTimeStr",
                showtime.getStartTime().toLocalDate().format(DATE_FMT)
                        + " · "
                        + com.mbcms.util.DateTimeUtil.formatAmPm(showtime.getStartTime()));
        req.setAttribute("seatIds", seatIdsParam);
        req.setAttribute("seatLabels", booking != null && booking.getSeatLabels() != null
                ? booking.getSeatLabels()
                : seatDao.findLabelsBySeatIds(seatIdList));

        req.getRequestDispatcher("/WEB-INF/views/booking/food-drinks.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

        String bookingIdParam = req.getParameter("bookingId");
        String showtimeIdParam = req.getParameter("showtimeId");
        String seatIdsParam = req.getParameter("seatIds");

        // Quet truc tiep cac param food_qty_<id> do form gui len.
        // Tinh hop le ve chi nhanh duoc enforce trong saveFoodOrder (chong tamper).
        Map<Long, Integer> selectedFood = new HashMap<>();
        java.util.Enumeration<String> paramNames = req.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String name = paramNames.nextElement();
            if (!name.startsWith("food_qty_")) {
                continue;
            }
            String qtyStr = req.getParameter(name);
            if (qtyStr == null || qtyStr.trim().isEmpty()) {
                continue;
            }
            try {
                long foodId = Long.parseLong(name.substring("food_qty_".length()));
                int qty = Integer.parseInt(qtyStr.trim());
                if (qty > 0) {
                    selectedFood.put(foodId, Math.min(qty, 10));
                }
            } catch (NumberFormatException ignored) {
            }
        }

        if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
            try {
                long bookingId = Long.parseLong(bookingIdParam.trim());
                bookingService.getBookingDetail(bookingId, customer.getUsername());

                // FOOD-002 guard: prevent a second food order for the same booking.
                // saveFoodOrder is an upsert (would silently overwrite); we explicitly
                // block it here at the service boundary so the DB UNIQUE constraint
                // on booking_id is never bypassed.
                com.mbcms.model.FoodOrder existing =
                        foodService.getFoodOrderByBookingId(bookingId);
                if (existing != null) {
                    resp.sendRedirect(req.getContextPath()
                            + "/customer/booking/detail?bookingId=" + bookingId
                            + "&foodError=already_ordered");
                    return;
                }

                foodService.saveFoodOrder(bookingId, selectedFood, "PENDING");
                bookingService.recalculateTotalsWithFood(bookingId, customer.getUsername(), selectedFood);
                resp.sendRedirect(req.getContextPath()
                        + "/customer/booking/detail?bookingId=" + bookingId + "&foodAdded=1");
                return;
            } catch (SecurityException e) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN);
                return;
            } catch (IllegalArgumentException e) {
                // Invalid food item / branch mismatch — pass bookingId back with error
                try {
                    long bookingId = Long.parseLong(bookingIdParam.trim());
                    resp.sendRedirect(req.getContextPath()
                            + "/customer/booking/detail?bookingId=" + bookingId
                            + "&foodError=" + java.net.URLEncoder.encode(e.getMessage(),
                                java.nio.charset.StandardCharsets.UTF_8));
                } catch (NumberFormatException ignored) {
                    resp.sendRedirect(req.getContextPath() + "/");
                }
                return;
            } catch (Exception ignored) {
            }
        }

        if (showtimeIdParam == null || seatIdsParam == null || seatIdsParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        HttpSession session = req.getSession();
        session.setAttribute("selectedFoodItems", selectedFood);

        resp.sendRedirect(req.getContextPath()
                + "/booking/checkout?showtimeId=" + showtimeIdParam + "&seatIds=" + seatIdsParam);
    }

    private List<Long> parseSeatIds(String seatIdsParam) {
        List<Long> result = new ArrayList<>();
        if (seatIdsParam == null || seatIdsParam.trim().isEmpty()) {
            return result;
        }
        for (String token : seatIdsParam.split(",")) {
            token = token.trim();
            if (!token.isEmpty()) {
                try {
                    result.add(Long.parseLong(token));
                } catch (NumberFormatException ignored) {
                }
            }
        }
        return result;
    }
}
