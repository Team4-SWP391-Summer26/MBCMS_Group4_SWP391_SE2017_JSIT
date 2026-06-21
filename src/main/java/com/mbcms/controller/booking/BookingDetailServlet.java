package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;

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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Customer customer = (Customer) session.getAttribute("currentUser");

        String bookingIdParam = req.getParameter("bookingId");
        if (bookingIdParam == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            long bookingId = Long.parseLong(bookingIdParam.trim());
            Booking booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
            if (booking == null) {
                resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
                return;
            }
            req.setAttribute("booking", booking);
            req.setAttribute("confirmed", "1".equals(req.getParameter("confirmed")));
            req.getRequestDispatcher("/WEB-INF/views/customer/booking/detail.jsp").forward(req, resp);

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);
        }
    }
}