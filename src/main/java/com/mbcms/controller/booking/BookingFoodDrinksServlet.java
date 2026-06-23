package com.mbcms.controller.booking;

import com.mbcms.model.Customer;
import com.mbcms.model.FoodItem;
import com.mbcms.service.FoodService;
import com.mbcms.service.impl.FoodServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * BookingFoodDrinksServlet – /booking/food-drinks
 * Step 3: Select Food & Drinks concessions catalog.
 */
@WebServlet("/booking/food-drinks")
public class BookingFoodDrinksServlet extends HttpServlet {

    private FoodService foodService;

    @Override
    public void init() {
        foodService = new FoodServiceImpl();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        String bookingIdParam = req.getParameter("bookingId");
        String showtimeIdParam = req.getParameter("showtimeId");
        String seatIdsParam = req.getParameter("seatIds");

        if (bookingIdParam != null) {
            try {
                long bookingId = Long.parseLong(bookingIdParam.trim());
                com.mbcms.service.BookingService bookingService = new com.mbcms.service.impl.BookingServiceImpl();
                com.mbcms.model.Booking booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
                if (booking != null) {
                    showtimeIdParam = String.valueOf(booking.getShowtimeId());
                    // Format seat labels or ids as CSV
                    List<Long> seatIds = booking.getSeatIds();
                    StringBuilder sb = new StringBuilder();
                    if (seatIds != null) {
                        for (int i = 0; i < seatIds.size(); i++) {
                            sb.append(seatIds.get(i));
                            if (i < seatIds.size() - 1) sb.append(",");
                        }
                    }
                    seatIdsParam = sb.toString();
                    req.setAttribute("bookingId", bookingId);
                    
                    // Pre-load existing concessions
                    Map<FoodItem, Integer> existingFood = foodService.getFoodItemsByBookingId(bookingId);
                    req.setAttribute("existingFood", existingFood);
                }
            } catch (Exception ignored) {}
        }

        if (showtimeIdParam == null || seatIdsParam == null || seatIdsParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // Get list of active concessions
        List<FoodItem> foodItems = foodService.getActiveFoodItems();

        req.setAttribute("foodItems", foodItems);
        req.setAttribute("showtimeId", showtimeIdParam);
        req.setAttribute("seatIds", seatIdsParam);

        req.getRequestDispatcher("/WEB-INF/views/booking/food-drinks.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String bookingIdParam = req.getParameter("bookingId");
        String showtimeIdParam = req.getParameter("showtimeId");
        String seatIdsParam = req.getParameter("seatIds");

        List<FoodItem> foodItems = foodService.getActiveFoodItems();
        Map<Long, Integer> selectedFood = new HashMap<>();

        for (FoodItem item : foodItems) {
            String qtyStr = req.getParameter("food_qty_" + item.getFoodId());
            if (qtyStr != null && !qtyStr.trim().isEmpty()) {
                try {
                    int qty = Integer.parseInt(qtyStr.trim());
                    if (qty > 0) {
                        qty = Math.min(qty, 10);
                        selectedFood.put(item.getFoodId(), qty);
                    }
                } catch (NumberFormatException ignored) {}
            }
        }

        if (bookingIdParam != null && !bookingIdParam.trim().isEmpty()) {
            try {
                long bookingId = Long.parseLong(bookingIdParam.trim());
                // Save food order directly as PENDING
                foodService.saveFoodOrder(bookingId, selectedFood, "PENDING");
                resp.sendRedirect(req.getContextPath() + "/customer/booking/detail?bookingId=" + bookingId + "&foodAdded=1");
                return;
            } catch (Exception ignored) {}
        }

        if (showtimeIdParam == null || seatIdsParam == null || seatIdsParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }

        // Store selected food in session
        if (session != null) {
            session.setAttribute("selectedFoodItems", selectedFood);
        }

        resp.sendRedirect(req.getContextPath() + "/booking/checkout?showtimeId=" + showtimeIdParam + "&seatIds=" + seatIdsParam);
    }
}
