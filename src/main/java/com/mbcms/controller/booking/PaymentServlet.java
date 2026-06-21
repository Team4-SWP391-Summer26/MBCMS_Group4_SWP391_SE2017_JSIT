package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.PaymentService;
import com.mbcms.service.impl.PaymentServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;

/**
 * PaymentServlet - booking step 5 (Payment) - owner: HungNT.
 *
 * GET /booking/payment?bookingId=X
 *   - Load booking PENDING that (owner check), do du lieu that vao payment.jsp.
 *   - Da CONFIRMED -> chuyen sang trang chi tiet (idempotent).
 *   - Het han / sai trang thai -> ve lich su voi thong bao.
 *
 * Bam tra tien -> form POST sang /booking/payment/gateway (redirect VNPay Sandbox).
 */
@WebServlet("/booking/payment")
public class PaymentServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/booking/payment.jsp";

    private final PaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        Long bookingId = parseLong(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            Booking booking = paymentService.preparePayment(bookingId, customer.getUsername());

            req.setAttribute("booking", booking);
            req.setAttribute("remainingSeconds", remainingSeconds(booking));
            // err: tu callback chuyen ve (signature | failed) de hien canh bao
            req.setAttribute("payError", req.getParameter("err"));
            req.getRequestDispatcher(VIEW).forward(req, resp);

        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);

        } catch (IllegalStateException e) {
            // Da thanh toan -> xem chi tiet; con lai (het han) -> ve lich su
            if (e.getMessage() != null && e.getMessage().contains("đã được thanh toán")) {
                resp.sendRedirect(req.getContextPath()
                        + "/customer/booking/detail?bookingId=" + bookingId);
            } else {
                resp.sendRedirect(req.getContextPath()
                        + "/customer/booking/history?expired=1");
            }

        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
        }
    }

    /** So giay con lai cua cua so giu ghe (10 phut tu created_at UTC). */
    private long remainingSeconds(Booking booking) {
        if (booking.getCreatedAt() == null) {
            return 600;
        }
        long elapsed = Duration.between(
                booking.getCreatedAt(), LocalDateTime.now(ZoneOffset.UTC)).getSeconds();
        long remaining = 600 - elapsed;
        return remaining < 0 ? 0 : remaining;
    }

    private Long parseLong(String s) {
        if (s == null) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
