package com.mbcms.controller.booking;

import com.mbcms.service.VnPayCallbackService;
import com.mbcms.util.VnPayUtil;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;

/**
 * VNPay IPN (Instant Payment Notification) - server-to-server callback.
 * Khong can session; verify chu ky roi xac nhan booking (idempotent).
 * Tra ve plain text theo format VNPay yeu cau.
 */
@WebServlet("/booking/payment/vnpay-ipn")
public class VnPayIpnServlet extends HttpServlet {

    private final VnPayCallbackService callbackService = new VnPayCallbackService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        handle(req, resp);
    }

    private void handle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Map<String, String> vnpParams = new HashMap<>();
        req.getParameterMap().forEach((key, values) -> {
            if (key.startsWith("vnp_") && values != null && values.length > 0) {
                vnpParams.put(key, values[0]);
            }
        });

        VnPayCallbackService.Result result = callbackService.process(vnpParams);
        String body = switch (result.getOutcome()) {
            case SUCCESS, ALREADY_PAID -> "RspCode=00&Message=Confirm Success";
            case INVALID_SIGNATURE -> "RspCode=97&Message=Invalid Checksum";
            case BOOKING_NOT_FOUND, INVALID_TXN_REF -> "RspCode=01&Message=Order not found";
            case EXPIRED -> "RspCode=02&Message=Order expired";
            case PAYMENT_FAILED -> "RspCode=99&Message=Payment failed";
        };

        resp.setCharacterEncoding(StandardCharsets.UTF_8.name());
        resp.setContentType("text/plain; charset=UTF-8");
        resp.getWriter().write(body);
    }
}
