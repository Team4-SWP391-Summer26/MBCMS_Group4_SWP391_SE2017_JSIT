package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

import com.mbcms.util.BookingCustomerGuard;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * BookingConfirmServlet – /booking/confirm
 *
 * GET → show booking confirmation page after VNPay callback has already
 * confirmed the booking. This servlet ONLY DISPLAYS the booking status;
 * it does NOT call confirmBooking() — that is done exclusively by
 * VnPayCallbackServlet to prevent free-ticket bypass.
 */
@WebServlet(name = "BookingConfirmServlet", urlPatterns = {"/booking/confirm"})
public class BookingConfirmServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(request, response);
        if (customer == null) {
            return;
        }
        HttpSession session = request.getSession();

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
            // Display-only: load confirmed booking (owner-checked by service)
            Booking booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history");
                return;
            }
            if (Booking.STATUS_PENDING.equals(booking.getStatus())) {
                response.sendRedirect(request.getContextPath()
                        + "/booking/payment?bookingId=" + bookingId);
                return;
            }
            if (!Booking.STATUS_CONFIRMED.equals(booking.getStatus())) {
                response.sendRedirect(request.getContextPath() + "/customer/booking/history");
                return;
            }
            session.removeAttribute("pendingBookingId");
            request.setAttribute("booking", booking);
            try {
                request.setAttribute("ticket",
                        bookingService.getTicket(bookingId, customer.getUsername()));
            } catch (Exception ignore) { /* confirm.jsp falls back to 'booking' */ }
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

    /** POST /booking/confirm is not used in the VNPay flow — redirect to detail. */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(request, response);
        if (customer == null) {
            return;
        }

        String bookingIdParam = request.getParameter("bookingId");
        if (bookingIdParam != null) {
            try {
                long bookingId = Long.parseLong(bookingIdParam.trim());
                response.sendRedirect(request.getContextPath()
                        + "/customer/booking/detail?bookingId=" + bookingId);
                return;
            } catch (NumberFormatException ignored) {
            }
        }
        response.sendRedirect(request.getContextPath() + "/customer/booking/history");
    }
}
