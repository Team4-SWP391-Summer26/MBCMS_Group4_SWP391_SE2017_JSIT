package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.util.BookingCustomerGuard;
import com.mbcms.util.QRCodeUtil;

import com.google.zxing.WriterException;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.OutputStream;

/**
 * BookingQrServlet - GET /booking/qr?bookingId=X
 *
 * He thong TU DONG sinh ma QR (PNG, ZXing) chua booking_code de nhung vao ve
 * dien tu, phuc vu kiem tra ve tai cua rap. Chi chu so huu booking moi xem duoc
 * (owner-check qua BookingService.getBookingDetail).
 */
@WebServlet("/booking/qr")
public class BookingQrServlet extends HttpServlet {

    private static final int QR_SIZE = 200; // 200x200px theo SRS

    private final BookingService bookingService = new BookingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Phai dang nhap Customer (anh QR nhung trong ve dien tu cua khach).
        Customer customer = BookingCustomerGuard.requireCustomer(req, resp);
        if (customer == null) {
            return;
        }

        long bookingId;
        try {
            bookingId = Long.parseLong(req.getParameter("bookingId").trim());
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            // OWNER-CHECK: getBookingDetail nem SecurityException neu khong phai chu booking
            // -> nguoi khac khong xem duoc QR ve cua minh.
            Booking booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
            if (booking == null || booking.getBookingCode() == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            // Stream thang PNG ve browser, KHONG luu file anh tren server.
            resp.setContentType("image/png");
            resp.setHeader("Cache-Control", "private, max-age=300");
            try (OutputStream out = resp.getOutputStream()) {
                // Ma hoa booking_code (vd "BK-000001") thanh QR 200x200 px bang ZXing.
                QRCodeUtil.writePng(booking.getBookingCode(), QR_SIZE, out);
            }

        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (WriterException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "QR generation failed");
        }
    }
}
