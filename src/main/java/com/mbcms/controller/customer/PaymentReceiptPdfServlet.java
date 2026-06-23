package com.mbcms.controller.customer;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.PaymentDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.PaymentDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Customer;
import com.mbcms.model.Payment;
import com.mbcms.util.InvoicePdfUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;

/**
 * PaymentReceiptPdfServlet - tai hoa don PDF (Customer). Feature: Invoice generation.
 * Owner-scoped: chi chu booking tai duoc PDF cua minh.
 */
@WebServlet("/customer/payment/receipt/pdf")
public class PaymentReceiptPdfServlet extends HttpServlet {

    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private final BookingDAO bookingDao = new BookingDAOImpl();
    private final PaymentDAO paymentDao = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Customer customer = (Customer) session.getAttribute("currentUser");

        Long bookingId = parseLong(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/payments");
            return;
        }

        Booking booking = bookingDao.findById(bookingId);
        if (booking == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found.");
            return;
        }
        if (!booking.getCustomerUsername().equals(customer.getUsername())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Not your booking.");
            return;
        }

        BookingTicket ticket = bookingDao.findTicket(bookingId);
        Payment payment = paymentDao.findByBookingId(bookingId);
        LocalDateTime paidAtVn = (payment != null && payment.getPaidAt() != null)
                ? payment.getPaidAt().atZone(ZoneOffset.UTC).withZoneSameInstant(VN_ZONE).toLocalDateTime()
                : null;

        byte[] pdf = InvoicePdfUtil.build(ticket, payment, paidAtVn);
        writePdf(resp, "receipt-" + ticket.getBookingCode() + ".pdf", pdf);
    }

    private static void writePdf(HttpServletResponse resp, String filename, byte[] pdf) throws IOException {
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition", "attachment; filename=\"" + filename + "\"");
        resp.setContentLength(pdf.length);
        resp.getOutputStream().write(pdf);
        resp.getOutputStream().flush();
    }

    private Long parseLong(String s) {
        if (s == null) return null;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return null; }
    }
}
