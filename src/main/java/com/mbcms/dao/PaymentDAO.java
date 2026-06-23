package com.mbcms.dao;

import com.mbcms.model.Payment;

import java.math.BigDecimal;
import java.sql.Connection;

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
}
