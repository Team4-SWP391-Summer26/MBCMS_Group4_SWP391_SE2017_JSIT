package com.mbcms.controller.booking;

import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.service.PricingService;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.PricingServiceImpl;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;
import com.mbcms.util.BookingCustomerGuard;
import com.mbcms.util.SystemSettings;
import com.mbcms.model.Customer;

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

    private static final DateTimeFormatter DATE_FMT
            = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final SeatAvailabilityService seatService = new SeatAvailabilityServiceImpl();
    private final PricingService pricingService = new PricingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Bat buoc dang nhap Customer truoc khi chon ghe (chan ngay tu dau).
        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

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
            Set<Long> heldSeatIds = seatService.getHeldSeatIds(showtimeId);
            int availableCount = seatService.countAvailable(showtimeId);

            req.setAttribute("showtime", showtime);
            req.setAttribute("seatsByRow", seatsByRow);
            req.setAttribute("bookedSeatIds", bookedSeatIds);
            req.setAttribute("heldSeatIds", heldSeatIds);
            req.setAttribute("availableCount", availableCount);
            req.setAttribute("showtimeId", showtimeId);
            req.setAttribute("showtimeDate", showtime.getStartTime().toLocalDate().toString());
            req.setAttribute("startTimeStr",
                    showtime.getStartTime().toLocalDate().format(DATE_FMT)
                            + " · "
                            + com.mbcms.util.DateTimeUtil.formatAmPm(showtime.getStartTime()));
            req.setAttribute("standardPrice",
                    pricingService.calculateSeatPrice(showtime.getBasePrice(), Seat.TYPE_STANDARD));
            req.setAttribute("vipPrice",
                    pricingService.calculateSeatPrice(showtime.getBasePrice(), Seat.TYPE_VIP));
            req.setAttribute("maxSeatsPerBooking", SystemSettings.maxSeatsPerBooking());

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
