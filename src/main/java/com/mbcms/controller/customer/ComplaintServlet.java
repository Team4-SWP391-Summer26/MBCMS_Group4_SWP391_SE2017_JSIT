package com.mbcms.controller.customer;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.Feedback;
import com.mbcms.service.FeedbackService;
import com.mbcms.service.impl.FeedbackServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * ComplaintServlet - UC: Submit Complaints (Customer).
 *
 * GET  /customer/complaints        → hien thi form gui khieu nai + lich su
 * POST /customer/complaints        → xu ly submit khieu nai
 *
 * Bao ve boi AuthFilter (/customer/* → phai dang nhap, role CUSTOMER).
 */
@WebServlet("/customer/complaints")
public class ComplaintServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/customer/complaint-form.jsp";
    private static final int PAGE_SIZE = 10;

    private final FeedbackService feedbackService = new FeedbackServiceImpl();
    private final BookingDAO bookingDAO = new BookingDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = getCustomer(req);
        if (customer == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // Lay danh sach booking CONFIRMED/USED cua customer de chon suất chiếu
        List<Booking> confirmedBookings = bookingDAO.findByCustomer(customer.getUsername())
                .stream()
                .filter(b -> "CONFIRMED".equals(b.getStatus()) || "USED".equals(b.getStatus()))
                .toList();

        // Lich su khieu nai cua customer
        List<Feedback> myComplaints = feedbackService.getMyFeedbacks(customer.getUsername())
                .stream()
                .filter(f -> Feedback.CAT_COMPLAINT.equals(f.getCategory()))
                .toList();

        req.setAttribute("confirmedBookings", confirmedBookings);
        req.setAttribute("myComplaints", myComplaints);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = getCustomer(req);
        if (customer == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String showtimeIdStr = trim(req.getParameter("showtimeId"));
        String subject       = trim(req.getParameter("subject"));
        String message       = trim(req.getParameter("message"));

        // Validate showtime param
        long showtimeId = -1;
        try {
            showtimeId = Long.parseLong(showtimeIdStr);
        } catch (NumberFormatException e) {
            req.setAttribute("errorMsg", "Please select a showtime to submit a complaint.");
            doGet(req, resp);
            return;
        }

        Object result = feedbackService.submitComplaint(
                customer.getUsername(), showtimeId, subject, message);

        if (result instanceof String errMsg) {
            // Remove "ERR:" prefix for display
            req.setAttribute("errorMsg", ((String) result).replace("ERR:", ""));
            doGet(req, resp);
            return;
        }

        // Success
        resp.sendRedirect(req.getContextPath() + "/customer/complaints?success=1");
    }

    private Customer getCustomer(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("currentUser");
        return (obj instanceof Customer c) ? c : null;
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }
}
