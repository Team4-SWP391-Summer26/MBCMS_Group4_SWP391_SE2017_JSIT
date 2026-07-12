package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.NotificationDAO;
import com.mbcms.dao.PaymentDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.NotificationDAOImpl;
import com.mbcms.dao.impl.PaymentDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Customer;
import com.mbcms.model.Notification;
import com.mbcms.model.Payment;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.model.PaymentSummary;
import com.mbcms.model.Showtime;
import com.mbcms.service.NotificationService;
import com.mbcms.service.PaymentService;
import com.mbcms.util.DBUtil;
import com.mbcms.util.DateTimeUtil;

import java.sql.Connection;
import java.sql.SQLException;
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
    private final ShowtimeDAO showtimeDao = new ShowtimeDAOImpl();
    private final NotificationService notificationService = new NotificationServiceImpl();

    @Override
    public Booking preparePayment(long bookingId, String customerUsername) {
        Booking b = bookingDao.findByIdWithSeats(bookingId);
        if (b == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        // OWNER-CHECK: chi chu booking moi duoc tra tien -> chong tra ho / xem trom.
        if (!b.getCustomerUsername().equals(customerUsername)) {
            throw new SecurityException("You are not allowed to pay for this booking.");
        }
        // Da CONFIRMED -> idempotent: bao "da thanh toan" (servlet chuyen sang xem chi tiet).
        if (Booking.STATUS_CONFIRMED.equals(b.getStatus())) {
            throw new IllegalStateException("Booking has already been paid.");
        }
        // Chi PENDING moi duoc tra (CANCELLED/USED thi khong).
        if (!Booking.STATUS_PENDING.equals(b.getStatus())) {
            throw new IllegalStateException(
                    "Booking cannot be paid in its current status (" + b.getStatus() + ").");
        }
        // Qua 10 phut giu ghe -> het han, phai dat lai.
        if (bookingDao.isPendingHoldExpired(bookingId)) {
            throw new IllegalStateException("Your seat hold has expired. Please book again.");
        }
        // Suat phai con SCHEDULED va chua bat dau (manager co the huy sau khi hold).
        assertShowtimePayable(b.getShowtimeId());
        return b;
    }

    // [PHAN DI] Goi truoc khi redirect sang VNPay: kiem tra + tao payment PENDING.
    @Override
    public Booking initiatePayment(long bookingId, String method, String customerUsername) {
        String m = normalizeMethod(method);
        Booking b = preparePayment(bookingId, customerUsername); // owner + PENDING check
        paymentDao.upsertPending(bookingId, m, b.getTotalAmount());
        return b;
    }

    // ====================================================================
    // PHAN 2 - VE (ghi tien): goi sau khi callback qua 3 kiem tra.
    // 2 tinh chat phai nho khi thuyet trinh:
    //   - IDEMPOTENT: da CONFIRMED -> tra ALREADY_PAID, khong ghi lai (F5/callback lap vo hai).
    //   - 1 TRANSACTION: 5 buoc ghi (bookings, payments, promo, food, notification)
    //     hoac thanh cong het, hoac rollback het. Email gui SAU commit (ngoai transaction).
    // ====================================================================
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
        // [IDEMPOTENT] Callback goi lai / user F5 sau khi da CONFIRMED -> tra ALREADY_PAID,
        // KHONG ghi lai (tranh tru tien/tang used_count 2 lan).
        if (Booking.STATUS_CONFIRMED.equals(b.getStatus())) {
            return Result.ALREADY_PAID;
        }
        if (!Booking.STATUS_PENDING.equals(b.getStatus())) {
            return Result.EXPIRED; // CANCELLED / USED -> khong confirm
        }

        // Re-check showtime luc confirm (co the bi huy trong cua so hold 10 phut).
        Showtime st = showtimeDao.findById(b.getShowtimeId());
        if (st == null || !Showtime.STATUS_SCHEDULED.equals(st.getStatus())
                || !st.getStartTime().isAfter(DateTimeUtil.nowVietnam())) {
            return Result.SHOWTIME_INVALID;
        }

        // Dam bao co payment PENDING (phong truong hop vao callback truc tiep).
        Payment existing = paymentDao.findByBookingId(bookingId);
        if (existing == null) {
            paymentDao.upsertPending(bookingId, m, b.getTotalAmount());
        }

        Connection conn = null;
        try {
            conn = DBUtil.getConnection();
            conn.setAutoCommit(false); // [TRANSACTION] mo: 5 buoc duoi all-or-nothing

            // 1) bookings: PENDING -> CONFIRMED (van check het han ben trong SQL)
            int bk = bookingDao.confirmBooking(conn, bookingId, customerUsername);
            if (bk == 0) {
                conn.rollback();
                return Result.EXPIRED; // het han ngay truoc khi commit
            }

            // 2) payments: PENDING -> SUCCESS + transaction_ref + paid_at
            int pay = paymentDao.markSuccess(conn, bookingId, transactionRef);
            if (pay == 0) {
                conn.rollback();
                return Result.EXPIRED;
            }

            // 3) promo used_count++ — het luot thi ROLLBACK (khop counter cash), khong confirm gia giam.
            if (b.getPromoId() != null) {
                int promoUpdated = promotionDao.incrementUsedCount(conn, b.getPromoId());
                if (promoUpdated == 0) {
                    conn.rollback();
                    return Result.PROMO_EXHAUSTED;
                }
            }

            // 3.5) food_orders: PENDING -> PREPARING (if any concessions exist) + tru ton kho
            com.mbcms.dao.impl.FoodDAOImpl foodDao = new com.mbcms.dao.impl.FoodDAOImpl();
            foodDao.updateOrderStatusByBooking(conn, bookingId, "PREPARING");
            foodDao.decrementStockForBooking(conn, bookingId);

            // 4) notification PAYMENT cho customer
            notificationDao.insert(conn, buildPaymentNotification(b));

            conn.commit(); // GHI THAT ca 5 buoc cung luc; loi truoc day -> rollback sach

            // Gui EMAIL xac nhan NGOAI transaction: email cham/loi cung khong rollback tien da commit.
            sendBookingConfirmationQuietly(bookingId, customerUsername);

            return Result.SUCCESS;

        } catch (SQLException e) {
            rollbackQuietly(conn); // loi giua chung -> huy ca 5 buoc (atomic)
            throw new RuntimeException("markPaymentSuccess error: " + e.getMessage(), e);
        } finally {
            restoreAndClose(conn);
        }
    }

    // [7c/7d] Tim giao dich theo bo loc (status/keyword/branch/phan trang).
    @Override
    public List<PaymentRecord> searchPayments(PaymentSearchCriteria criteria) {
        return paymentDao.search(criteria);
    }

    // [7c/7d] Dem tong so giao dich khop bo loc (de tinh so trang).
    @Override
    public int countPayments(PaymentSearchCriteria criteria) {
        return paymentDao.count(criteria);
    }

    // [7d] Tong hop trang thai (PENDING/SUCCESS/FAILED + PENDING cu nhat) theo branch.
    @Override
    public PaymentSummary getPaymentSummary(Long branchId) {
        return paymentDao.summarize(branchId);
    }

    /** Suat con SCHEDULED va chua bat dau (gio VN) moi cho thanh toan. */
    private void assertShowtimePayable(long showtimeId) {
        Showtime st = showtimeDao.findById(showtimeId);
        if (st == null || !Showtime.STATUS_SCHEDULED.equals(st.getStatus())) {
            throw new IllegalStateException(
                    "This showtime is no longer available. Please book another screening.");
        }
        if (!st.getStartTime().isAfter(DateTimeUtil.nowVietnam())) {
            throw new IllegalStateException(
                    "This showtime has already started. Please book another screening.");
        }
    }

    // Chuan hoa + whitelist phuong thuc: chi chap nhan VNPAY (he thong khong dung tien mat online).
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

    // Gui email xac nhan (NGOAI transaction) - "Quietly": loi gi cung chi log, KHONG nem ra
    // de khong anh huong giao dich da commit thanh cong.
    private void sendBookingConfirmationQuietly(long bookingId, String customerUsername) {
        try {
            Booking confirmed = bookingDao.findByIdWithSeats(bookingId);
            if (confirmed == null) {
                return;
            }
            String email = null;
            Customer c = new com.mbcms.dao.impl.CustomerDAOImpl().findByUsername(customerUsername);
            if (c != null) {
                email = c.getEmail();
            }
            notificationService.sendBookingConfirmation(confirmed, email);
            // Bao real-time khoa cung ghe cho cac user dang xem so do.
            if (confirmed.getSeatIds() != null) {
                com.mbcms.ws.SeatWebSocketServer.notifyHardLock(
                        confirmed.getShowtimeId(), confirmed.getSeatIds(), customerUsername);
            }
        } catch (Exception e) {
            System.err.println("WARN: sendBookingConfirmation after payment: " + e.getMessage());
        }
    }

    // Rollback "im lang": huy transaction; loi rollback chi nuot (vi da co loi goc can nem ra).
    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    // Dat lai autoCommit=true TRUOC khi tra connection ve pool (pool ky vong autoCommit=true,
    // neu khong request sau muon dung connection nay se bi treo transaction), roi dong connection.
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
