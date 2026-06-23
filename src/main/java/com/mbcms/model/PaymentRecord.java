package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * PaymentRecord - view-model 1 dong Payment history (owner: HungNT).
 *
 * Gop payments + bookings + showtimes/movies/branches/customers qua JOIN
 * (xem PaymentDAOImpl.RECORD_SELECT). Chi doc, phuc vu man hinh lich su va
 * theo doi trang thai thanh toan. KHONG dung de ghi.
 */
public class PaymentRecord {

    // payments
    private long paymentId;
    private long bookingId;
    private String method;            // CASH | VNPAY
    private BigDecimal amount;
    private String status;            // PENDING | SUCCESS | FAILED
    private String transactionRef;    // null voi CASH / chua thanh toan
    private LocalDateTime paidAt;      // null khi chua SUCCESS

    // bookings
    private String bookingCode;
    private String bookingStatus;     // PENDING | CONFIRMED | USED | CANCELLED
    private LocalDateTime createdAt;

    // customers
    private String customerUsername;
    private String customerFullName;
    private String customerEmail;

    // movie + showtime + branch (cho hien thi & scope)
    private String movieTitle;
    private long branchId;
    private String branchName;
    private LocalDateTime startTime;

    public PaymentRecord() {}

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

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }

    public String getBookingStatus() { return bookingStatus; }
    public void setBookingStatus(String bookingStatus) { this.bookingStatus = bookingStatus; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getCustomerUsername() { return customerUsername; }
    public void setCustomerUsername(String customerUsername) { this.customerUsername = customerUsername; }

    public String getCustomerFullName() { return customerFullName; }
    public void setCustomerFullName(String customerFullName) { this.customerFullName = customerFullName; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public String getMovieTitle() { return movieTitle; }
    public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }

    public long getBranchId() { return branchId; }
    public void setBranchId(long branchId) { this.branchId = branchId; }

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }
}
