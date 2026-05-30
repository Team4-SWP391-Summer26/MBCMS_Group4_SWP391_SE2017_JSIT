package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Payment - map bang `payments` (1:1 voi booking).
 * method: CASH | MOMO | VNPAY | CREDIT_CARD
 * status: PENDING -> SUCCESS | FAILED | REFUNDED
 */
public class Payment {

    public static final String METHOD_CASH = "CASH";
    public static final String METHOD_MOMO = "MOMO";
    public static final String METHOD_VNPAY = "VNPAY";
    public static final String METHOD_CREDIT_CARD = "CREDIT_CARD";

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";
    public static final String STATUS_REFUNDED = "REFUNDED";

    private long paymentId;
    private long bookingId;
    private String method;
    private BigDecimal amount;
    private String status;
    private String transactionRef;
    private LocalDateTime paidAt;

    public Payment() {}

    public long getPaymentId() { return paymentId; }
    public void setPaymentId(long paymentId) { this.paymentId = paymentId; }

    public long getBookingId() { return bookingId; }
    public void setBookingId(long bookingId) { this.bookingId = bookingId; }

    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
}
