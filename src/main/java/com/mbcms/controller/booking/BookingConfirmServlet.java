package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

/**
 * BookingConfirmServlet – /booking/confirm
 *
 * GET → show booking confirmation success/failure page (confirm.jsp) called by
 * BookingCheckoutServlet after creating a PENDING booking, OR by payment
 * gateway callback.
 *
 * POST → confirm (PENDING → CONFIRMED) then redirect to detail page. called
 * when there is a real payment step; for now the flow can auto-confirm from GET
 * for demo purposes.
 */
@WebServlet(name = "BookingConfirmServlet", urlPatterns = {"/booking/confirm"})
public class BookingConfirmServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();

    /**
     * GET /booking/confirm?bookingId=X
     *
     * BUG FIX: Original doGet was empty — redirect from BookingCheckoutServlet
     * hit this endpoint with GET and received a blank response.
     *
     * For the current (no external payment gateway) flow: 1. Confirm the
     * PENDING booking immediately. 2. Forward to confirm.jsp to show success.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        long bookingId;
        try {
            bookingId = Long.parseLong(bookingIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            Booking booking = bookingService.confirmBooking(bookingId, customer.getUsername());
            session.removeAttribute("pendingBookingId");
            request.setAttribute("booking", booking);
            // View-model day du cho e-ticket (movie/showtime/room/seat labels...)
            try {
                request.setAttribute("ticket",
                        bookingService.getTicket(bookingId, customer.getUsername()));
            } catch (Exception ignore) { /* fallback: confirm.jsp dung 'booking' */ }
            request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp")
                    .forward(request, response);

        } catch (IllegalStateException e) {
            request.setAttribute("errorMessage", e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp")
                    .forward(request, response);
        } catch (SecurityException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.getRequestDispatcher("/WEB-INF/views/common/error403.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "System error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/common/error500.jsp")
                    .forward(request, response);
        }
    }

    /**
     * POST /booking/confirm
     *
     * Used when a payment gateway callback confirms payment externally.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam == null) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        long bookingId;
        try {
            bookingId = Long.parseLong(bookingIdParam.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            bookingService.confirmBooking(bookingId, customer.getUsername());
            session.removeAttribute("pendingBookingId");
            response.sendRedirect(request.getContextPath()
                    + "/booking/detail?bookingId=" + bookingId + "&confirmed=1");

        } catch (IllegalStateException e) {
            response.sendRedirect(request.getContextPath()
                    + "/booking/detail?bookingId=" + bookingId + "&error="
                    + URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (SecurityException e) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.getRequestDispatcher("/WEB-INF/views/common/error403.jsp")
                    .forward(request, response);
        } catch (Exception e) {
            request.setAttribute("error", "System error: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/common/error500.jsp")
                    .forward(request, response);
        }
    }
}
