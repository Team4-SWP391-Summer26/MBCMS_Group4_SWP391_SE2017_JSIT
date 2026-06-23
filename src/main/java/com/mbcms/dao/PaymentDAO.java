package com.mbcms.dao;

import com.mbcms.model.Payment;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.model.PaymentSummary;

import java.math.BigDecimal;
import java.sql.Connection;
import java.util.List;

/**
 * PaymentDAO - thao tac bang `payments` (1:1 voi bookings).
 *
 * State machine: PENDING -> SUCCESS | FAILED (refund out of scope).
 *
 * Cac method nhan {@link Connection} duoc dung BEN TRONG transaction cua
 * PaymentService (Handle Payment Callback - SRS 3.8.4): cap nhat payments +
 * bookings + notifications phai atomic. DAO khong commit/close connection do.
 */
public interface PaymentDAO {

    /** Tim payment theo booking (UNIQUE booking_id). null neu chua co. */
    Payment findByBookingId(long bookingId);

    /**
     * Dam bao co 1 payment PENDING cho booking truoc khi sang cong thanh toan.
     * - Chua co  -> INSERT (status=PENDING).
     * - Da co va CHUA SUCCESS -> UPDATE method/amount, reset ve PENDING.
     * - Da SUCCESS -> giu nguyen (da thanh toan, idempotent).
     */
    void upsertPending(long bookingId, String method, BigDecimal amount);

    /**
     * Danh dau payment SUCCESS trong transaction chung (dung connection truyen vao).
     * Idempotent: chi update khi dang PENDING. Return so row affected
     * (0 = khong con PENDING -> da xu ly hoac chua khoi tao).
     */
    int markSuccess(Connection conn, long bookingId, String transactionRef);

    /**
     * Payment history: danh sach giao dich theo bo loc, da phan trang
     * (criteria.offset/limit). Scope theo branchId/customerUsername trong criteria.
     */
    List<PaymentRecord> search(PaymentSearchCriteria criteria);

    /** Tong so giao dich khop bo loc (bo qua offset/limit) - cho phan trang. */
    int count(PaymentSearchCriteria criteria);

    /**
     * Payment status monitoring: tong hop so luong theo trang thai + method +
     * giao dich PENDING cu nhat. branchId = null -> toan he thong (Admin).
     */
    PaymentSummary summarize(Long branchId);
}
