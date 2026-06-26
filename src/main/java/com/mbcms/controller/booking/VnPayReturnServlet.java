package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.VnPayCallbackService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.util.BookingCustomerGuard;
import com.mbcms.util.VnPayUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * VNPay Return URL - browser redirect sau khi user thanh toan tren cong VNPay
 * Sandbox. Verify chu ky HMAC-SHA512, xac nhan booking neu vnp_ResponseCode=00.
 */
@WebServlet("/booking/payment/vnpay-return")
public class VnPayReturnServlet extends HttpServlet {

    private final VnPayCallbackService callbackService = new VnPayCallbackService();
    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        handle(req, resp);
    }

    // ====================================================================
    // PHAN 2 - VE: sau khi khach tra xong, VNPay redirect browser ve day kem
    // cac tham so vnp_* (ket qua + chu ky). Servlet KHONG tu quyet dinh dung
    // sai - no giao cho VnPayCallbackService.process() kiem 3 lop roi dinh tuyen
    // theo ket qua (thanh cong -> hien ve; loi -> quay lai trang thanh toan).
    // ====================================================================
    private void handle(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Map<String, String> vnpParams = extractVnpParams(req);
        // process(): verify chu ky -> kiem ma phan hoi -> kiem so tien -> ghi DB.
        VnPayCallbackService.Result result = callbackService.process(vnpParams);
        long bookingId = result.getBookingId();

        if (bookingId == 0 && result.getBooking() != null) {
            bookingId = result.getBooking().getBookingId();
        }
        if (bookingId == 0) {
            String txnRef = vnpParams.get("vnp_TxnRef");
            Long parsed = VnPayUtil.parseBookingId(txnRef);
            if (parsed != null) {
                bookingId = parsed;
            }
        }

        // Dinh tuyen theo ket qua: thanh cong -> hien ve; loi -> ve trang payment kem ma loi.
        switch (result.getOutcome()) {
            // Email xac nhan da duoc gui 1 lan trong PaymentServiceImpl.markPaymentSuccess
            // -> KHONG gui lai o day (tranh trung email khi F5).
            case SUCCESS, ALREADY_PAID -> forwardConfirm(req, resp, result.getBooking()); // -> confirm.jsp (ve + QR)
            case EXPIRED -> redirectPayment(resp, req, bookingId, "expired");          // het han giu ghe
            case PAYMENT_FAILED -> redirectPayment(resp, req, bookingId, "failed");    // khach huy / the loi
            case INVALID_SIGNATURE -> redirectPayment(resp, req, bookingId, "signature"); // sai chu ky
            case AMOUNT_MISMATCH -> redirectPayment(resp, req, bookingId, "amount");   // lech so tien
            case INVALID_TXN_REF, BOOKING_NOT_FOUND ->
                resp.sendRedirect(req.getContextPath() + "/customer/booking/history"); // khong xac dinh duoc booking
            default ->
                redirectPayment(resp, req, bookingId, "failed");
        }
    }

    private void forwardConfirm(HttpServletRequest req, HttpServletResponse resp, Booking booking)
            throws ServletException, IOException {
        if (booking == null) {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
            return;
        }
        // Callback di qua trinh duyet khach nen van co session -> bat buoc dang nhap.
        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }
        HttpSession session = req.getSession();
        // OWNER-CHECK lan nua: ve phai cua chinh nguoi dang dang nhap.
        if (!booking.getCustomerUsername().equals(customer.getUsername())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.getRequestDispatcher("/WEB-INF/views/common/error403.jsp").forward(req, resp);
            return;
        }
        session.removeAttribute("pendingBookingId");

        Booking withSeats = booking;
        try {
            withSeats = bookingService.getBookingDetail(booking.getBookingId(), customer.getUsername());
        } catch (Exception ignored) {
        }

        // Bao WebSocket khoa cung ghe (cap nhat real-time so do ghe cho user khac).
        if (withSeats != null && withSeats.getSeatIds() != null) {
            try {
                com.mbcms.ws.SeatWebSocketServer.notifyHardLock(
                        withSeats.getShowtimeId(), withSeats.getSeatIds(), customer.getUsername());
            } catch (Exception e) {
                System.err.println("WARN: notifyHardLock on VNPay return: " + e.getMessage());
            }
        }

        try {
            req.setAttribute("ticket",
                    bookingService.getTicket(booking.getBookingId(), customer.getUsername()));
        } catch (Exception ignore) { /* fallback: confirm.jsp dung 'booking' */ }
        req.setAttribute("booking", withSeats != null ? withSeats : booking);
        // forward (khong redirect) -> URL van la vnpay-return nhung noi dung la trang xac nhan.
        req.getRequestDispatcher("/WEB-INF/views/booking/confirm.jsp").forward(req, resp);
    }

    // Khi loi: quay ve trang thanh toan kem ma loi (de payment.jsp hien canh bao);
    // neu khong biet bookingId thi ve lich su.
    private void redirectPayment(HttpServletResponse resp, HttpServletRequest req,
            long bookingId, String err) throws IOException {
        if (bookingId > 0) {
            resp.sendRedirect(req.getContextPath()
                    + "/booking/payment?bookingId=" + bookingId + "&err=" + err);
        } else {
            resp.sendRedirect(req.getContextPath() + "/customer/booking/history");
        }
    }

    // Loc chi cac tham so bat dau bang "vnp_" (moi key lay gia tri dau) = dung tap VNPay da ky.
    private Map<String, String> extractVnpParams(HttpServletRequest req) {
        Map<String, String> map = new HashMap<>();
        req.getParameterMap().forEach((key, values) -> {
            if (key.startsWith("vnp_") && values != null && values.length > 0) {
                map.put(key, values[0]);
            }
        });
        return map;
    }
}
