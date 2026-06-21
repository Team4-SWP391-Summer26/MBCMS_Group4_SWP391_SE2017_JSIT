package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * BookingHistoryServlet - GET /customer/booking/history
 *
 * Danh sach tat ca booking cua customer, moi nhat truoc.
 */
@WebServlet("/customer/booking/history")
public class BookingHistoryServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Customer customer = (Customer) session.getAttribute("currentUser");

        List<Booking> bookings = bookingService.getBookingHistory(customer.getUsername());
        req.setAttribute("bookings", bookings);
        req.getRequestDispatcher("/WEB-INF/views/customer/booking/history.jsp").forward(req, resp);
    }
}