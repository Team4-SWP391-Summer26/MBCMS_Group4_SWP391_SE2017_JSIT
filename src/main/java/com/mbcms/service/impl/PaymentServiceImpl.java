package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.NotificationDAO;
import com.mbcms.dao.PaymentDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.NotificationDAOImpl;
import com.mbcms.dao.impl.PaymentDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Notification;
import com.mbcms.model.Payment;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.model.PaymentSummary;
import com.mbcms.service.PaymentService;
import com.mbcms.util.DBUtil;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.List;

/**
 * PaymentServiceImpl - dieu phoi transaction thanh toan.
 *
 * markPaymentSuccess() mo 1 connection, setAutoCommit(false), goi 3 DAO
 * (payments + bookings + notifications) tren CUNG connection roi commit ->
 * atomic dung SRS 3.8.4. Idempotent nho dieu kien WHERE status='PENDING'.
 */
public class PaymentServiceImpl implements PaymentService {

    private final PaymentDAO paymentDao = new PaymentDAOImpl();
    private final BookingDAO bookingDao = new BookingDAOImpl();
    private final NotificationDAO notificationDao = new NotificationDAOImpl();
    private final PromotionDAO promotionDao = new PromotionDAOImpl();

    @Override
    public Booking preparePayment(long bookingId, String customerUsername) {
        Booking b = bookingDao.findByIdWithSeats(bookingId);
        if (b == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (!b.getCustomerUsername().equals(customerUsername)) {
            throw new SecurityException("You are not allowed to pay for this booking.");
        }
        if (Booking.STATUS_CONFIRMED.equals(b.getStatus())) {
            throw new IllegalStateException("Booking has already been paid.");
        }
        if (!Booking.STATUS_PENDING.equals(b.getStatus())) {
            throw new IllegalStateException(
                    "Booking cannot be paid in its current status (" + b.getStatus() + ").");
        }
        if (isSeatHoldExpired(b)) {
            throw new IllegalStateException("Your seat hold has expired. Please book again.");
        }
        return b;
    }

    @Override
    public Booking initiatePayment(long bookingId, String method, String customerUsername) {
        String m = normalizeMethod(method);
        Booking b = preparePayment(bookingId, customerUsername); // owner + PENDING check
        paymentDao.upsertPending(bookingId, m, b.getTotalAmount());
        return b;
    }

    @Override
    public Result markPaymentSuccess(long bookingId, String method,
            String customerUsername, String transactionRef) {
        String m = normalizeMethod(method);

        Booking b = bookingDao.findById(bookingId);
        if (b == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (!b.getCustomerUsername().equals(customerUsername)) {
            throw new SecurityException("You are not allowed to pay for this booking.");
        }
        // Callback lap lai sau khi da CONFIRMED -> idempotent, khong lam gi them.
        if (Booking.STATUS_CONFIRMED.equals(b.getStatus())) {
            return Result.ALREADY_PAID;
        }
        if (!Booking.STATUS_PENDING.equals(b.getStatus())) {
            return Result.EXPIRED; // CANCELLED / USED -> khong confirm
        }

        // Dam bao co payment PENDING (phong truong hop vao callback truc tiep).
        Payment existing = paymentDao.findByBookingId(bookingId);
        if (existing == null) {
            paymentDao.upsertPending(bookingId, m, b.getTotalAmount());
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false);

            // 1) bookings: PENDING -> CONFIRMED (van check het han ben trong SQL)
            int bk = bookingDao.confirmBooking(conn, bookingId, customerUsername);
            if (bk == 0) {
                conn.rollback();
                return Result.EXPIRED; // het han ngay truoc khi commit
            }

            // 2) payments: PENDING -> SUCCESS + transaction_ref + paid_at
            paymentDao.markSuccess(conn, bookingId, transactionRef);

            // 3) promo used_count++ neu booking co ma (cung transaction, khong vuot max_uses)
            if (b.getPromoId() != null) {
                promotionDao.incrementUsedCount(conn, b.getPromoId());
            }

            // 3.5) food_orders: PENDING -> PREPARING (if any concessions exist)
            new com.mbcms.dao.impl.FoodDAOImpl().updateOrderStatusByBooking(conn, bookingId, "PREPARING");

            // 4) notification PAYMENT cho customer
            notificationDao.insert(conn, buildPaymentNotification(b));

            conn.commit();

            Booking confirmed = bookingDao.findById(bookingId);
            if (confirmed != null && confirmed.getPromoId() != null) {
                try {
                    promotionDao.incrementUsedCount(confirmed.getPromoId());
                } catch (Exception e) {
                    System.err.println("WARN: Could not increment promo used_count: " + e.getMessage());
                }
            }

            return Result.SUCCESS;

        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("markPaymentSuccess lỗi: " + e.getMessage(), e);
        } finally {
            restoreAndClose(conn);
        }
    }

    @Override
    public List<PaymentRecord> searchPayments(PaymentSearchCriteria criteria) {
        return paymentDao.search(criteria);
    }

    @Override
    public int countPayments(PaymentSearchCriteria criteria) {
        return paymentDao.count(criteria);
    }

    @Override
    public PaymentSummary getPaymentSummary(Long branchId) {
        return paymentDao.summarize(branchId);
    }

    /** Cung logic 10 phut UTC nhu confirmBooking() va PaymentServlet. */
    private boolean isSeatHoldExpired(Booking booking) {
        if (booking.getCreatedAt() == null) {
            return false;
        }
        long elapsed = Duration.between(
                booking.getCreatedAt(), LocalDateTime.now(ZoneOffset.UTC)).getSeconds();
        return elapsed >= 600;
    }

    private String normalizeMethod(String method) {
        if (method == null) {
            throw new IllegalArgumentException("Payment method is required.");
        }
        String m = method.trim().toUpperCase();
        if (!Payment.METHOD_VNPAY.equals(m)) {
            throw new IllegalArgumentException("Only VNPay is supported.");
        }
        return m;
    }

    private Notification buildPaymentNotification(Booking b) {
        Notification n = new Notification();
        n.setCustomerUsername(b.getCustomerUsername());
        n.setTitle("Payment successful");
        n.setContent("Your payment for booking " + b.getBookingCode()
                + " was successful. Your booking is confirmed.");
        n.setType(Notification.TYPE_PAYMENT);
        n.setReferenceId(b.getBookingId());
        return n;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    private void restoreAndClose(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException ignored) {
            }
            DBUtil.closeConnection(conn);
        }
    }
}
