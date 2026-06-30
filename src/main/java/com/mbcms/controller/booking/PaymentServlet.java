package com.mbcms.controller.booking;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.PaymentService;
import com.mbcms.service.impl.PaymentServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import com.mbcms.util.BookingCustomerGuard;

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
    private final BookingDAO bookingDao = new BookingDAOImpl();

    // ====================================================================
    // PHAN 1 - DI (buoc 1/2): mo trang thanh toan. Nap booking PENDING (co
    // owner-check) + tinh dong ho giu ghe 10 phut, roi forward sang payment.jsp.
    // Khach bam "Thanh toan" tren do se POST sang FakeGatewayServlet (buoc 2).
    // ====================================================================
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

        Long bookingId = parseLong(req.getParameter("bookingId"));
        if (bookingId == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }

        try {
            // Nap booking PENDING + owner-check (nem loi neu khong phai chu / da tra / het han).
            Booking booking = paymentService.preparePayment(bookingId, customer.getUsername());

            req.setAttribute("booking", booking);
            // So giay con lai cua dong ho giu ghe (10 phut) -> JS dem nguoc tren payment.jsp.
            req.setAttribute("remainingSeconds", remainingSeconds(booking));
            // err: tu callback chuyen ve (signature | failed) de hien canh bao
            req.setAttribute("payError", req.getParameter("err"));
            req.getRequestDispatcher(VIEW).forward(req, resp);

        } catch (SecurityException e) {
            // Khong phai chu booking -> trang 403.
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);

        } catch (IllegalStateException e) {
            // Da thanh toan -> xem chi tiet; con lai (het han) -> ve lich su
            if (e.getMessage() != null && e.getMessage().contains("already been paid")) {
                // Da CONFIRMED roi (idempotent): khong cho tra lai, chuyen sang xem ve.
                resp.sendRedirect(req.getContextPath()
                        + "/customer/booking/detail?bookingId=" + bookingId);
            } else {
                // Het han giu ghe / trang thai khac -> ve lich su kem co bao het han.
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
        if (bookingDao.isPendingHoldExpired(booking.getBookingId())) {
            return 0;
        }
        // So giay da troi = now(UTC) - created_at. Dung UTC cho khop voi DB (tranh lech mui gio).
        long elapsed = Duration.between(
                booking.getCreatedAt(), java.time.LocalDateTime.now(java.time.ZoneOffset.UTC)).getSeconds();
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
