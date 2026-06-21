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
import com.mbcms.model.Booking;
import com.mbcms.model.Movie;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.service.BookingService;
import com.mbcms.service.PricingService;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.service.impl.PricingServiceImpl;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;

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
 * CounterBookingServlet - Coordinator for walk-in/counter bookings.
 * Mapped to: /staff/booking
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
    
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // Retrieve current branch ID from session
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

        // Render checkout screen
        List<Movie> movies = movieDAO.findActiveMovies();
        List<Room> rooms = roomDAO.findActiveByBranch(branchId);
        
        req.setAttribute("movies", movies);
        req.setAttribute("rooms", rooms);
        req.getRequestDispatcher("/WEB-INF/views/branch/booking/counter-booking.jsp").forward(req, resp);
    }

    private void handleAjax(String action, long branchId, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");
        
        if ("getShowtimes".equals(action)) {
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

            List<Showtime> showtimes = showtimeDAO.findByBranch(branchId, movieId, null, date);
            
            // Format showtimes safely as serializable Maps
            List<Map<String, Object>> showtimeMaps = new ArrayList<>();
            DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
            DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM/yyyy");
            
            for (Showtime st : showtimes) {
                if ("SCHEDULED".equals(st.getStatus())) {
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

            Map<String, List<Seat>> seatsByRow = seatService.getSeatsByRow(showtimeId);
            Set<Long> bookedSeatIds = seatService.getBookedSeatIds(showtimeId);

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
            
            mapper.writeValue(resp.getWriter(), result);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();
        
        try {
            String showtimeIdParam = req.getParameter("showtimeId");
            if (showtimeIdParam == null || showtimeIdParam.trim().isEmpty()) {
                throw new IllegalArgumentException("Vui lòng chọn suất chiếu.");
            }
            
            long showtimeId = Long.parseLong(showtimeIdParam.trim());
            Showtime showtime = showtimeDAO.findById(showtimeId);
            if (showtime == null) {
                throw new IllegalArgumentException("Không tìm thấy suất chiếu tương ứng.");
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
                throw new IllegalArgumentException("Vui lòng chọn ít nhất 1 ghế.");
            }

            String customerPhone = req.getParameter("customerPhone");
            String promoCode = req.getParameter("promoCode");
            String notes = req.getParameter("notes");

            // Calculate base total for verification
            List<Seat> allSeats = seatDAO.findByRoom(showtime.getRoomId());
            List<Seat> selectedSeats = new ArrayList<>();
            for (Seat seat : allSeats) {
                if (seatIds.contains(seat.getSeatId())) {
                    selectedSeats.add(seat);
                }
            }
            BigDecimal subtotal = pricingService.calculateTotal(showtime.getBasePrice(), selectedSeats);

            // Construct Booking Model
            Booking booking = new Booking();
            booking.setShowtimeId(showtimeId);
            booking.setSubtotal(subtotal);
            booking.setNotes(notes);

            // Execute service transaction
            Booking createdBooking = bookingService.createCounterBooking(booking, seatIds, promoCode, customerPhone);
            
            // Notify WebSocket server of the hard lock
            String staffUsername = (String) req.getSession().getAttribute("username");
            if (staffUsername == null) {
                staffUsername = "staff";
            }
            com.mbcms.ws.SeatWebSocketServer.notifyHardLock(showtimeId, seatIds, staffUsername);
            
            result.put("success", true);
            result.put("bookingId", createdBooking.getBookingId());
            result.put("bookingCode", createdBooking.getBookingCode());
            result.put("totalAmount", createdBooking.getTotalAmount());
            result.put("message", "Đã thanh toán thành công và xác nhận đặt vé!");
            
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "Lỗi đặt vé: " + e.getMessage());
        }

        mapper.writeValue(resp.getWriter(), result);
    }
}
