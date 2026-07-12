package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.service.FoodService;
import com.mbcms.service.impl.FoodServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * BookingDetailServlet - GET /customer/booking/detail?bookingId=X
 *
 * Hien thi thong tin chi tiet 1 booking cua customer hien tai.
 */
@WebServlet("/customer/booking/detail")
public class BookingDetailServlet extends HttpServlet {

    private final BookingService bookingService = new BookingServiceImpl();
    private final FoodService foodService = new FoodServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("currentUser") instanceof Customer customer)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String bookingIdParam = req.getParameter("bookingId");
        if (bookingIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            long bookingId = Long.parseLong(bookingIdParam.trim());
            try {
                bookingService.releaseExpiredLocks();
            } catch (RuntimeException e) {
                getServletContext().log("Could not clean expired pending bookings before detail load", e);
            }
            Booking booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
                return;
            }
            req.setAttribute("booking", booking);
            req.setAttribute("confirmed", "1".equals(req.getParameter("confirmed")) || "true".equals(req.getParameter("confirmed")));
            req.setAttribute("foodAdded", "1".equals(req.getParameter("foodAdded")));
            
            // Fetch food order details
            req.setAttribute("concessions", foodService.getFoodItemsByBookingId(bookingId));
            req.setAttribute("foodOrder", foodService.getFoodOrderByBookingId(bookingId));
            
            req.getRequestDispatcher("/WEB-INF/views/customer/booking/detail.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);
        }
    }
}
