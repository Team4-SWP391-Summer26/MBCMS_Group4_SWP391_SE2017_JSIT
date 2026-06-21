package com.mbcms.controller.booking;

import com.mbcms.model.BookingTicket;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * BookingHistoryServlet - GET /customer/booking/history
 *
 * Trang "My Bookings": danh sach ve (BookingTicket day du) + so lieu tong quan
 * (upcoming / past visits / spent this year) + dem so theo trang thai.
 */
@WebServlet("/customer/booking/history")
public class BookingHistoryServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        List<BookingTicket> tickets =
                bookingService.getBookingHistoryTickets(customer.getUsername());

        LocalDateTime now = LocalDateTime.now();
        int year = now.getYear();

        int countConfirmed = 0, countPending = 0, countUsed = 0, countCancelled = 0;
        int upcoming = 0, pastVisits = 0;
        BigDecimal spentThisYear = BigDecimal.ZERO;

        for (BookingTicket t : tickets) {
            String st = t.getStatus();
            if ("CONFIRMED".equals(st)) {
                countConfirmed++;
                if (t.getStartTime() != null && t.getStartTime().isAfter(now)) {
                    upcoming++;
                }
            } else if ("PENDING".equals(st)) {
                countPending++;
            } else if ("USED".equals(st)) {
                countUsed++;
                pastVisits++;
            } else if ("CANCELLED".equals(st)) {
                countCancelled++;
            }

            // Chi tinh tien da thanh toan (CONFIRMED + USED) trong nam hien tai
            if (("CONFIRMED".equals(st) || "USED".equals(st))
                    && t.getTotalAmount() != null
                    && t.getStartTime() != null
                    && t.getStartTime().getYear() == year) {
                spentThisYear = spentThisYear.add(t.getTotalAmount());
            }
        }

        req.setAttribute("tickets", tickets);
        req.setAttribute("countAll", tickets.size());
        req.setAttribute("countConfirmed", countConfirmed);
        req.setAttribute("countPending", countPending);
        req.setAttribute("countUsed", countUsed);
        req.setAttribute("countCancelled", countCancelled);
        req.setAttribute("upcoming", upcoming);
        req.setAttribute("pastVisits", pastVisits);
        req.setAttribute("spentThisYear", spentThisYear);

        req.getRequestDispatcher("/WEB-INF/views/customer/booking/history.jsp")
                .forward(req, resp);
    }
}
