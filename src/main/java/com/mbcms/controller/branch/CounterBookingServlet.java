package com.mbcms.controller.branch;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.Movie;
import com.mbcms.model.Payment;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.model.FoodItem;
import com.mbcms.service.BookingService;
import com.mbcms.service.FoodService;
import com.mbcms.service.PaymentService;
import com.mbcms.service.PricingService;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.service.impl.FoodServiceImpl;
import com.mbcms.service.impl.PaymentServiceImpl;
import com.mbcms.service.impl.PricingServiceImpl;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;
import com.mbcms.util.VnPayUtil;
import com.mbcms.util.VnPayConfig;
import java.math.RoundingMode;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * CounterBookingServlet - Coordinator for walk-in/counter bookings. Mapped to:
 * /staff/booking
 */
@WebServlet("/staff/booking")
public class CounterBookingServlet extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAOImpl();
    private final RoomDAO roomDAO = new RoomDAOImpl();
    private final SeatDAO seatDAO = new SeatDAOImpl();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAOImpl();

    private final BookingService bookingService = new BookingServiceImpl();
    private final PricingService pricingService = new PricingServiceImpl();
    private final SeatAvailabilityService seatService = new SeatAvailabilityServiceImpl();
    private final PaymentService paymentService = new PaymentServiceImpl();
    private final FoodService foodService = new FoodServiceImpl();
    private final CustomerDAO customerDAO = new CustomerDAOImpl();

    private final ObjectMapper mapper = new ObjectMapper()
            .registerModule(new com.fasterxml.jackson.datatype.jsr310.JavaTimeModule());

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // [Flow Step: JSP -> Servlet] GET request received to load the walk-in booking screen or fetch list options
        Long branchId = (Long) req.getSession().getAttribute("currentBranchId");
        if (branchId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        ConsoleSupport.ensureBranchName(req);

        String action = req.getParameter("action");
        if (action != null) {
            handleAjax(action, branchId, req, resp);
            return;
        }

        String success = req.getParameter("success");
        if (success != null) {
            req.setAttribute("success", success);
            req.setAttribute("successBookingCode", req.getParameter("bookingCode"));
            req.setAttribute("successBookingId", req.getParameter("bookingId"));
        }

        String err = req.getParameter("err");
        if (err != null) {
            req.setAttribute("err", err);
        }

        // [Flow Step: Servlet -> Database] Query DB via DAOs to populate checkout filters (active movies & rooms)
        List<Movie> movies = movieDAO.findActiveMovies();
        List<Room> rooms = roomDAO.findActiveByBranch(branchId);

        req.setAttribute("movies", movies);
        req.setAttribute("rooms", rooms);
        
        // [Flow Step: Servlet -> JSP] Forward request parameters, stats, and active lists to counter-booking.jsp view
        req.getRequestDispatcher("/WEB-INF/views/branch/booking/counter-booking.jsp").forward(req, resp);
    }

    /** True neu room thuoc branch (chong xem/dat cheo chi nhanh). */
    private boolean roomBelongsToBranch(long roomId, long branchId) {
        return roomDAO.findActiveByBranch(branchId).stream()
                .anyMatch(r -> r.getRoomId() == roomId);
    }

    /** Walk-in fallback guest01; registered customer must exist in DB. */
    private String resolveCustomerUsername(String param) {
        if (param == null || param.trim().isEmpty()) {
            return "guest01";
        }
        String username = param.trim();
        if ("guest01".equalsIgnoreCase(username)) {
            return "guest01";
        }
        Customer c = customerDAO.findByUsername(username);
        if (c == null || !c.isActive()) {
                throw new IllegalArgumentException("Customer does not exist or has been locked.");
        }
        return c.getUsername();
    }

    private void handleAjax(String action, long branchId, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        if ("getShowtimes".equals(action)) {
            // [Flow Step: JSP -> Servlet] AJAX GET requests for showtimes filtering by movieId and date
            Long movieId = null;
            String movieIdParam = req.getParameter("movieId");
            if (movieIdParam != null && !movieIdParam.trim().isEmpty()) {
                movieId = Long.parseLong(movieIdParam.trim());
            }

            java.time.LocalDate date = null;
            String dateParam = req.getParameter("date");
            if (dateParam != null && !dateParam.trim().isEmpty()) {
                date = java.time.LocalDate.parse(dateParam.trim());
            }

            // [Flow Step: Servlet -> Database] Query showtime list based on parameters via ShowtimeDAO
            List<Showtime> showtimes = showtimeDAO.findByBranch(branchId, movieId, null, date);

            // Format showtimes safely as serializable Maps
            List<Map<String, Object>> showtimeMaps = new ArrayList<>();
            DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
            DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");

            java.time.LocalDateTime now = java.time.LocalDateTime.now();
            for (Showtime st : showtimes) {
                if ("SCHEDULED".equals(st.getStatus()) && st.getStartTime().isAfter(now)) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("showtimeId", st.getShowtimeId());
                    map.put("movieId", st.getMovieId());
                    map.put("movieTitle", st.getMovieTitle());
                    map.put("roomId", st.getRoomId());
                    map.put("roomName", st.getRoomName());
                    map.put("roomType", st.getRoomType());
                    map.put("roomCapacity", st.getRoomCapacity());
                    map.put("bookedSeats", st.getBookedSeats());
                    map.put("basePrice", st.getBasePrice());
                    map.put("format", st.getFormat());
                    map.put("subtitleType", st.getSubtitleType());
                    map.put("startTime", st.getStartTime().format(timeFmt));
                    map.put("endTime", st.getEndTime().format(timeFmt));
                    map.put("date", st.getStartTime().format(dateFmt));
                    showtimeMaps.add(map);
                }
            }
            mapper.writeValue(resp.getWriter(), showtimeMaps);

        } else if ("getSeats".equals(action)) {
            // [Flow Step: JSP -> Servlet] AJAX GET requests for seat map with showtimeId parameter
            String showtimeIdParam = req.getParameter("showtimeId");
            if (showtimeIdParam == null || showtimeIdParam.trim().isEmpty()) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing showtimeId");
                return;
            }

            long showtimeId = Long.parseLong(showtimeIdParam.trim());
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Showtime not found");
                return;
            }
            // Branch scope: chi load so do ghe cua suat thuoc chi nhanh staff
            if (!roomBelongsToBranch(showtime.getRoomId(), branchId)) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Showtime not in your branch");
                return;
            }

            // [Flow Step: Servlet -> Database] Query DB via Service to load room layout, booked seats, and soft-locked seats list
            Map<String, List<Seat>> seatsByRow = seatService.getSeatsByRow(showtimeId);
            Set<Long> bookedSeatIds = seatService.getBookedSeatIds(showtimeId);
            Set<Long> heldSeatIds = seatService.getHeldSeatIds(showtimeId);

            // Convert to safe map objects
            Map<String, List<Map<String, Object>>> seatsByRowMap = new LinkedHashMap<>();
            for (Map.Entry<String, List<Seat>> entry : seatsByRow.entrySet()) {
                List<Map<String, Object>> seatList = new ArrayList<>();
                for (Seat seat : entry.getValue()) {
                    Map<String, Object> sm = new HashMap<>();
                    sm.put("seatId", seat.getSeatId());
                    sm.put("roomId", seat.getRoomId());
                    sm.put("rowLabel", seat.getRowLabel());
                    sm.put("colNumber", seat.getColNumber());
                    sm.put("seatType", seat.getSeatType());
                    sm.put("active", seat.isActive());
                    seatList.add(sm);
                }
                seatsByRowMap.put(entry.getKey(), seatList);
            }

            Map<String, Object> result = new HashMap<>();
            result.put("showtimeBasePrice", showtime.getBasePrice());
            result.put("seatsByRow", seatsByRowMap);
            result.put("bookedSeatIds", bookedSeatIds);
            result.put("heldSeatIds", heldSeatIds);

            mapper.writeValue(resp.getWriter(), result);

        } else if ("getBookingDetail".equals(action)) {
            String bookingIdParam = req.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing bookingId");
                return;
            }
            long bookingId = Long.parseLong(bookingIdParam.trim());
            com.mbcms.model.BookingTicket ticket = bookingService.getTicketForBranch(bookingId, branchId);
            if (ticket == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }
            mapper.writeValue(resp.getWriter(), ticket);
        } else if ("getFoodItems".equals(action)) {
            // [Flow Step: Servlet -> Database] Query DB via Service to load all active food and beverage stock menu items
            List<FoodItem> foodItems = foodService.getActiveFoodItemsByBranch(branchId);
            mapper.writeValue(resp.getWriter(), foodItems);
        } else if ("getBookingFoodItems".equals(action)) {
            String bookingIdParam = req.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.trim().isEmpty()) {
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing bookingId");
                return;
            }
            long bookingId = Long.parseLong(bookingIdParam.trim());
            if (bookingService.getTicketForBranch(bookingId, branchId) == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
                return;
            }
            Map<FoodItem, Integer> foodItems = foodService.getFoodItemsByBookingId(bookingId);
            List<Map<String, Object>> result = new ArrayList<>();
            for (Map.Entry<FoodItem, Integer> entry : foodItems.entrySet()) {
                Map<String, Object> itemMap = new HashMap<>();
                itemMap.put("foodId", entry.getKey().getFoodId());
                itemMap.put("name", entry.getKey().getName());
                itemMap.put("quantity", entry.getValue());
                itemMap.put("price", entry.getKey().getPrice());
                result.add(itemMap);
            }
            mapper.writeValue(resp.getWriter(), result);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        try {
            // [Flow Step: JSP -> Servlet] AJAX POST request received containing counter booking checkout details
            Long branchId = (Long) req.getSession().getAttribute("currentBranchId");
            if (branchId == null) {
                throw new SecurityException("Invalid session.");
            }

            String showtimeIdParam = req.getParameter("showtimeId");
            if (showtimeIdParam == null || showtimeIdParam.trim().isEmpty()) {
                throw new IllegalArgumentException("Please select a showtime.");
            }

            long showtimeId = Long.parseLong(showtimeIdParam.trim());
            
            // [Flow Step: Servlet -> Database] Query DB via DAO to verify showtime entity
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                throw new IllegalArgumentException("Matching showtime was not found.");
            }

            // Verify showtime belongs to the staff's branch
            if (!roomBelongsToBranch(showtime.getRoomId(), branchId)) {
                throw new SecurityException("This showtime does not belong to your branch.");
            }

            // Parse selected seat IDs
            List<Long> seatIds = new ArrayList<>();
            String seatIdsParam = req.getParameter("seatIds");
            if (seatIdsParam != null && !seatIdsParam.trim().isEmpty()) {
                for (String idStr : seatIdsParam.split(",")) {
                    if (!idStr.trim().isEmpty()) {
                        seatIds.add(Long.parseLong(idStr.trim()));
                    }
                }
            } else {
                String[] seatIdsArr = req.getParameterValues("seatIds");
                if (seatIdsArr != null) {
                    for (String idStr : seatIdsArr) {
                        seatIds.add(Long.parseLong(idStr.trim()));
                    }
                }
            }

            if (seatIds.isEmpty()) {
                throw new IllegalArgumentException("Please select at least 1 seat.");
            }

            String promoCode = req.getParameter("promoCode");
            String notes = req.getParameter("notes");
            String paymentMethod = req.getParameter("paymentMethod");
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                paymentMethod = "CASH";
            }

            // Parse food items parameter
            String foodItemsParam = req.getParameter("foodItems");
            Map<Long, Integer> selectedFood = new HashMap<>();
            BigDecimal foodSubtotal = BigDecimal.ZERO;
            if (foodItemsParam != null && !foodItemsParam.trim().isEmpty()) {
                try {
                    List<Map<String, Object>> foodList = mapper.readValue(foodItemsParam, List.class);
                    for (Map<String, Object> map : foodList) {
                        Long foodId = Long.parseLong(map.get("foodId").toString());
                        Integer qty = Integer.parseInt(map.get("quantity").toString());
                        if (qty > 0) {
                            qty = Math.min(qty, 10);
                            selectedFood.put(foodId, qty);
                            // [Flow Step: Servlet -> Database] Query DB via service to look up food items prices
                            FoodItem item = foodService.getFoodItemById(foodId);
                            if (item != null) {
                                foodSubtotal = foodSubtotal.add(item.getPrice().multiply(BigDecimal.valueOf(qty)));
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Error parsing foodItems: " + e.getMessage());
                }
            }
            Booking createdBooking = null;

            String customerUsername = resolveCustomerUsername(req.getParameter("customerUsername"));

            if ("VNPAY".equalsIgnoreCase(paymentMethod.trim())) {
                // [Flow Step: Servlet -> Service -> Database] Initiate VNPAY payment pending booking
                createdBooking = bookingService.createPendingBooking(customerUsername, showtimeId, seatIds, promoCode, notes, foodSubtotal);

                foodService.saveFoodOrder(createdBooking.getBookingId(), selectedFood, "PENDING");

                // Initialize payment status in payments table
                paymentService.initiatePayment(createdBooking.getBookingId(), Payment.METHOD_VNPAY, customerUsername);

                // Generate VNPay URL redirecting back to staff callback
                String returnUrl = VnPayUtil.buildAppUrl(req, "/staff/booking/vnpay-return");
                long amountVnd = createdBooking.getTotalAmount()
                        .setScale(0, RoundingMode.HALF_UP).longValue();

                String paymentUrl = VnPayUtil.buildPaymentUrl(
                        createdBooking.getBookingId(),
                        createdBooking.getBookingCode(),
                        amountVnd,
                        req.getRemoteAddr(),
                        returnUrl);

                result.put("success", true);
                result.put("bookingId", createdBooking.getBookingId());
                result.put("bookingCode", createdBooking.getBookingCode());
                result.put("totalAmount", createdBooking.getTotalAmount());
                result.put("redirectUrl", paymentUrl);
                result.put("message", "Redirecting to the VNPay payment gateway...");
            } else {
                // For Cash: existing flow
                // Calculate base total for verification
                List<Seat> allSeats = seatDAO.findByRoom(showtime.getRoomId());
                List<Seat> selectedSeats = new ArrayList<>();
                for (Seat seat : allSeats) {
                    if (seatIds.contains(seat.getSeatId())) {
                        selectedSeats.add(seat);
                    }
                }
                BigDecimal subtotal = pricingService.calculateTotal(showtime.getBasePrice(), selectedSeats);

                // Construct Booking Model (Subtotal is tickets subtotal only)
                Booking booking = new Booking();
                booking.setShowtimeId(showtimeId);
                booking.setCustomerUsername(customerUsername);
                booking.setSubtotal(subtotal);
                booking.setNotes(notes);

                // [Flow Step: Servlet -> Service -> Database] Process instant cash booking registration in database
                createdBooking = bookingService.createCounterBooking(booking, seatIds, promoCode, foodSubtotal);

                if (!selectedFood.isEmpty()) {
                    // [Flow Step: Service -> Database] Save food order record and decrement stock counts in database
                    foodService.saveFoodOrder(createdBooking.getBookingId(), selectedFood, "PREPARING");
                    foodService.decrementStockForBooking(createdBooking.getBookingId());
                }

                // [Flow Step: Service -> WebSocket] Broadcast seat status conversion (HARD_LOCK) to seat monitor clients
                String staffUsername = (String) req.getSession().getAttribute("username");
                if (staffUsername == null) {
                    staffUsername = "staff";
                }
                com.mbcms.ws.SeatWebSocketServer.notifyHardLock(showtimeId, seatIds, staffUsername);

                result.put("success", true);
                result.put("bookingId", createdBooking.getBookingId());
                result.put("bookingCode", createdBooking.getBookingCode());
                result.put("totalAmount", createdBooking.getTotalAmount());
                result.put("message", "Payment completed and booking confirmed successfully!");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Booking error: " + e.getMessage());
        }

        // [Flow Step: Servlet -> JSP] Return transaction response (bookingId, totals, URLs) as JSON payload response
        mapper.writeValue(resp.getWriter(), result);
    }
}
