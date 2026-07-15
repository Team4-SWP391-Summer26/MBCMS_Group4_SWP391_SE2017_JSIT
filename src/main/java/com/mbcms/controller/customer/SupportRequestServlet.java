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
 * SupportRequestServlet - UC: Customer Support Requests.
 *
 * GET  /customer/support → hien thi form yeu cau ho tro + lich su
 * POST /customer/support → xu ly submit yeu cau ho tro
 *
 * Bao ve boi AuthFilter (/customer/* → phai dang nhap, role CUSTOMER).
 */
@WebServlet("/customer/support")
public class SupportRequestServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/customer/support-form.jsp";

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

        // Lay danh sach booking de chon khi sub_category=BOOKING
        List<Booking> myBookings = bookingDAO.findByCustomer(customer.getUsername())
                .stream()
                .filter(b -> "CONFIRMED".equals(b.getStatus()) || "USED".equals(b.getStatus()))
                .toList();

        // Lich su yeu cau ho tro
        List<Feedback> mySupports = feedbackService.getMyFeedbacks(customer.getUsername())
                .stream()
                .filter(f -> Feedback.CAT_SUPPORT.equals(f.getCategory()))
                .toList();

        req.setAttribute("myBookings", myBookings);
        req.setAttribute("mySupports", mySupports);
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

        String subCategory = trim(req.getParameter("subCategory"));
        String bookingIdStr = trim(req.getParameter("relatedBookingId"));
        String subject = trim(req.getParameter("subject"));
        String message = trim(req.getParameter("message"));

        Long relatedBookingId = null;
        if (bookingIdStr != null && !bookingIdStr.isEmpty()) {
            try {
                relatedBookingId = Long.parseLong(bookingIdStr);
            } catch (NumberFormatException e) {
                req.setAttribute("errorMsg", "Invalid booking ID.");
                doGet(req, resp);
                return;
            }
        }

        Object result = feedbackService.submitSupportRequest(
                customer.getUsername(), subCategory, relatedBookingId, subject, message);

        if (result instanceof String errMsg) {
            req.setAttribute("errorMsg", ((String) result).replace("ERR:", ""));
            doGet(req, resp);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/customer/support?success=1");
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
