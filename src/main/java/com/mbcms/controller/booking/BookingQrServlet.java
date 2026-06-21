package com.mbcms.controller.booking;

import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.service.BookingService;
import com.mbcms.service.impl.BookingServiceImpl;
import com.mbcms.util.QrCodeUtil;

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

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        Customer customer = (Customer) session.getAttribute("currentUser");

        long bookingId;
        try {
            bookingId = Long.parseLong(req.getParameter("bookingId").trim());
        } catch (Exception e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        try {
            Booking booking = bookingService.getBookingDetail(bookingId, customer.getUsername());
            if (booking == null || booking.getBookingCode() == null) {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }

            resp.setContentType("image/png");
            resp.setHeader("Cache-Control", "private, max-age=300");
            try (OutputStream out = resp.getOutputStream()) {
                QrCodeUtil.writePng(booking.getBookingCode(), QR_SIZE, out);
            }

        } catch (SecurityException e) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
        } catch (WriterException e) {
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "QR generation failed");
        }
    }
}
