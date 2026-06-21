package com.mbcms.controller.booking;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * PaymentServlet - booking step 5 (Payment).
 *
 * HIEN TAI: chi FORWARD vao payment.jsp de team xem/test GIAO DIEN (frontend scaffold).
 * payment.jsp dang dung du lieu MAU.
 *
 * TODO(backend - Payment owner): thay phan doGet/doPost bang logic that:
 *  - doGet: load booking dang PENDING tu showtimeId + seatIds, do du lieu that
 *           (movie, seats, prices, booking_code, QR) qua request attribute.
 *  - doPost: xac nhan thanh toan -> cap nhat payment/booking status -> sang Confirm.
 */
@WebServlet("/booking/payment")
public class PaymentServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/booking/payment.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
