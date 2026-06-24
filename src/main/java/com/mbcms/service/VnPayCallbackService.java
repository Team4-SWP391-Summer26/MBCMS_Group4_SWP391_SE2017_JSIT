package com.mbcms.service;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Payment;
import com.mbcms.service.impl.PaymentServiceImpl;
import com.mbcms.util.VnPayUtil;

import java.util.Map;
import java.math.BigDecimal;
import java.math.RoundingMode;

/**
 * Xu ly ket qua tra ve tu VNPay (Return URL + IPN) sau khi verify chu ky.
 */
public class VnPayCallbackService {

    public enum Outcome {
        SUCCESS, ALREADY_PAID, EXPIRED, PAYMENT_FAILED,
        INVALID_SIGNATURE, INVALID_TXN_REF, BOOKING_NOT_FOUND, AMOUNT_MISMATCH
    }

    public static final class Result {
        private final Outcome outcome;
        private final Booking booking;

        public Result(Outcome outcome, Booking booking) {
            this.outcome = outcome;
            this.booking = booking;
        }

        public Outcome getOutcome() { return outcome; }
        public Booking getBooking() { return booking; }
        public long getBookingId() {
            return booking != null ? booking.getBookingId() : 0;
        }
    }

    private final PaymentService paymentService;
    private final BookingDAO bookingDao;

    public VnPayCallbackService() {
        this(new PaymentServiceImpl(), new BookingDAOImpl());
    }

    /** For unit tests. */
    VnPayCallbackService(PaymentService paymentService, BookingDAO bookingDao) {
        this.paymentService = paymentService;
        this.bookingDao = bookingDao;
    }

    public Result process(Map<String, String> vnpParams) {
        if (!VnPayUtil.verifyReturn(vnpParams)) {
            return new Result(Outcome.INVALID_SIGNATURE, null);
        }

        String txnRef = vnpParams.get("vnp_TxnRef");
        Long bookingId = VnPayUtil.parseBookingId(txnRef);
        if (bookingId == null) {
            return new Result(Outcome.INVALID_TXN_REF, null);
        }

        Booking booking = bookingDao.findById(bookingId);
        if (booking == null) {
            return new Result(Outcome.BOOKING_NOT_FOUND, null);
        }

        String responseCode = vnpParams.get("vnp_ResponseCode");
        String transStatus = vnpParams.get("vnp_TransactionStatus");
        if (!VnPayUtil.isSuccessResponse(responseCode, transStatus)) {
            return new Result(Outcome.PAYMENT_FAILED, booking);
        }

        String amountStr = vnpParams.get("vnp_Amount");
        if (amountStr == null || amountStr.isBlank()) {
            return new Result(Outcome.AMOUNT_MISMATCH, booking);
        }
        try {
            long amountVnd = Long.parseLong(amountStr.trim()) / 100L;
            long expectedVnd = booking.getTotalAmount()
                    .setScale(0, RoundingMode.HALF_UP).longValue();
            if (amountVnd != expectedVnd) {
                return new Result(Outcome.AMOUNT_MISMATCH, booking);
            }
        } catch (NumberFormatException ignored) {
            return new Result(Outcome.AMOUNT_MISMATCH, booking);
        }

        String gatewayRef = vnpParams.get("vnp_TransactionNo");
        if (gatewayRef == null || gatewayRef.isBlank()) {
            gatewayRef = txnRef;
        }

        PaymentService.Result pr = paymentService.markPaymentSuccess(
                bookingId, Payment.METHOD_VNPAY,
                booking.getCustomerUsername(), gatewayRef);

        Booking updated = bookingDao.findByIdWithSeats(bookingId);

        return switch (pr) {
            case SUCCESS -> new Result(Outcome.SUCCESS, updated);
            case ALREADY_PAID -> new Result(Outcome.ALREADY_PAID, updated);
            case EXPIRED -> new Result(Outcome.EXPIRED, booking);
        };
    }
}
