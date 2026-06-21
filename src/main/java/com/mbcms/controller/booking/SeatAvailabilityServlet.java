package com.mbcms.controller.booking;

import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * SeatAvailabilityServlet
 *
 * GET /booking/seats?showtimeId={id} → load trang seats.jsp voi trang thai ghe
 * hien tai tu DB → WebSocket xu ly update realtime sau khi trang da load
 */
@WebServlet("/booking/seats")
public class SeatAvailabilityServlet extends HttpServlet {

    private static final DateTimeFormatter DT_FMT
            = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private final SeatAvailabilityService seatService = new SeatAvailabilityServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long showtimeId = parseLong(req.getParameter("showtimeId"));
        if (showtimeId == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thieu tham so: showtimeId");
            return;
        }

        try {
            Showtime showtime = seatService.getShowtime(showtimeId);
            if (showtime == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Khong tim thay suat chieu id=" + showtimeId);
                return;
            }

            Map<String, List<Seat>> seatsByRow = seatService.getSeatsByRow(showtimeId);
            Set<Long> bookedSeatIds = seatService.getBookedSeatIds(showtimeId);
            int availableCount = seatService.countAvailable(showtimeId);

            req.setAttribute("showtime", showtime);
            req.setAttribute("seatsByRow", seatsByRow);
            req.setAttribute("bookedSeatIds", bookedSeatIds);
            req.setAttribute("availableCount", availableCount);
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("startTimeStr", showtime.getStartTime().format(DT_FMT));

            req.getRequestDispatcher("/WEB-INF/views/booking/seats.jsp").forward(req, resp);

        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, e.getMessage());
        }
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
