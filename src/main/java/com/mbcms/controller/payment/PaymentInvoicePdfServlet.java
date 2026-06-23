package com.mbcms.controller.payment;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.PaymentDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.PaymentDAOImpl;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Employee;
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
 * PaymentInvoicePdfServlet - tai hoa don PDF cho console (Admin + Branch Manager).
 * Feature: Invoice generation (SRS 3.3.2.3 - actor Admin/Branch Manager).
 *
 * Scope tu session: Admin tai duoc moi booking; Branch Manager chi booking thuoc
 * branch cua minh (ticket.branchId == currentBranchId).
 */
@WebServlet({"/admin/payments/receipt/pdf", "/branch/payments/receipt/pdf"})
public class PaymentInvoicePdfServlet extends HttpServlet {

    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");
    private final BookingDAO bookingDao = new BookingDAOImpl();
    private final PaymentDAO paymentDao = new PaymentDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Employee emp = (Employee) session.getAttribute("currentUser");

        Long bookingId = parseLong(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing bookingId.");
            return;
        }

        BookingTicket ticket = bookingDao.findTicket(bookingId);
        if (ticket == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found.");
            return;
        }
        // Branch Manager: chi cho phep booking thuoc branch cua minh.
        if (!emp.isAdmin()) {
            Long branchId = (Long) session.getAttribute("currentBranchId");
            if (branchId == null || ticket.getBranchId() != branchId) {
                resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Outside your branch.");
                return;
            }
        }

        Payment payment = paymentDao.findByBookingId(bookingId);
        LocalDateTime paidAtVn = (payment != null && payment.getPaidAt() != null)
                ? payment.getPaidAt().atZone(ZoneOffset.UTC).withZoneSameInstant(VN_ZONE).toLocalDateTime()
                : null;

        byte[] pdf = InvoicePdfUtil.build(ticket, payment, paidAtVn);
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"invoice-" + ticket.getBookingCode() + ".pdf\"");
        resp.setContentLength(pdf.length);
        resp.getOutputStream().write(pdf);
        resp.getOutputStream().flush();
    }

    private Long parseLong(String s) {
        if (s == null) return null;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return null; }
    }
}
