package com.mbcms.service;

import com.mbcms.model.Booking;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.model.PaymentSummary;

import java.util.List;

/**
 * PaymentService - business logic cho luong thanh toan online (VNPay).
 * mo phong). Owner: HungNT.
 *
 * Luong: 1. preparePayment  -> man hinh chon phuong thuc (booking PENDING).
 *        2. initiatePayment  -> tao payment PENDING + sang cong gia lap.
 *        3. markPaymentSuccess (callback) -> transaction: payments SUCCESS +
 *           bookings CONFIRMED + notification (SRS 3.8.4 Handle Payment Callback).
 */
public interface PaymentService {

    /** Ket qua xu ly callback thanh toan. */
    enum Result {
        SUCCESS,       // vua confirm thanh cong
        ALREADY_PAID,  // booking da CONFIRMED tu truoc (callback lap) - idempotent
        EXPIRED        // booking het han / khong con PENDING -> khong confirm
    }

    /**
     * Load booking de hien thi man hinh thanh toan. Kiem tra owner + phai PENDING
     * va chua het han. Tra ve booking (kem seatIds).
     *
     * @throws IllegalArgumentException booking khong ton tai
     * @throws SecurityException        khong phai owner
     * @throws IllegalStateException    khong con o trang thai thanh toan duoc
     */
    Booking preparePayment(long bookingId, String customerUsername);

    /**
     * Khoi tao thanh toan voi phuong thuc da chon: tao/cap nhat payment PENDING
     * (amount = booking.total_amount). Tra ve booking de cong gia lap hien thi.
     *
     * @throws IllegalArgumentException method khong hop le hoac booking khong ton tai
     * @throws SecurityException        khong phai owner
     * @throws IllegalStateException    booking khong con PENDING
     */
    Booking initiatePayment(long bookingId, String method, String customerUsername);

    /**
     * Xu ly callback thanh toan thanh cong: 1 transaction JDBC cap nhat
     * payments.status=SUCCESS + transaction_ref + bookings.status=CONFIRMED +
     * tao PAYMENT notification. Idempotent (callback goi nhieu lan an toan).
     *
     * @throws SecurityException khong phai owner
     */
    Result markPaymentSuccess(long bookingId, String method,
                              String customerUsername, String transactionRef);

    /**
     * Payment history: danh sach giao dich theo bo loc (da phan trang).
     * Scope (branchId/customerUsername) phai duoc Servlet set tu session.
     */
    List<PaymentRecord> searchPayments(PaymentSearchCriteria criteria);

    /** Tong so giao dich khop bo loc - phuc vu phan trang. */
    int countPayments(PaymentSearchCriteria criteria);

    /** Payment status monitoring: tong hop trang thai/method. branchId=null -> toan he thong. */
    PaymentSummary getPaymentSummary(Long branchId);
}
