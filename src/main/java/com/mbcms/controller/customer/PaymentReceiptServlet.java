package com.mbcms.controller.customer;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.PaymentDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.PaymentDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Customer;
import com.mbcms.model.Payment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;

/**
 * PaymentReceiptServlet - man Payment Receipt phia Customer (owner: HungNT).
 * Theo SRS 3.3.2.3: hoa don tu Bookings + Payments (KHAC voi e-ticket).
 *
 * Scope chinh chu: bookingId tu request nhung owner check bat buoc
 * (booking.customer_username == session user) -> khong xem hoa don nguoi khac.
 * Receipt itemize dung phan da thanh toan (ve - giam gia = payment.amount);
 * F&B la order rieng, khong nam trong payment.
 */
@WebServlet("/customer/payment/receipt")
public class PaymentReceiptServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/customer/payment/receipt.jsp";
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
        // Owner check: chi chu booking moi xem duoc hoa don.
        if (!booking.getCustomerUsername().equals(customer.getUsername())) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Not your booking.");
            return;
        }

        BookingTicket ticket = bookingDao.findTicket(bookingId);
        Payment payment = paymentDao.findByBookingId(bookingId); // co the null neu chua khoi tao

        // Itemize ve: Qty = so ghe, unit = subtotal / so ghe, amount = subtotal.
        int seatCount = ticket.getSeatLabels() == null ? 0 : ticket.getSeatLabels().size();
        BigDecimal subtotal = ticket.getSubtotal() == null ? BigDecimal.ZERO : ticket.getSubtotal();
        BigDecimal unitPrice = seatCount > 0
                ? subtotal.divide(BigDecimal.valueOf(seatCount), 0, RoundingMode.HALF_UP)
                : subtotal;

        // paid_at luu UTC -> doi sang gio VN cho hien thi.
        LocalDateTime paidAtVn = (payment != null && payment.getPaidAt() != null)
                ? payment.getPaidAt().atZone(ZoneOffset.UTC).withZoneSameInstant(VN_ZONE).toLocalDateTime()
                : null;

        req.setAttribute("ticket", ticket);
        req.setAttribute("payment", payment);
        req.setAttribute("paidAt", paidAtVn);
        req.setAttribute("seatCount", seatCount);
        req.setAttribute("unitPrice", unitPrice);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    private Long parseLong(String s) {
        if (s == null) return null;
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
