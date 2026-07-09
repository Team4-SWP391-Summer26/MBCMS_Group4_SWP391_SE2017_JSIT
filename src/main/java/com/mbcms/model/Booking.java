package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Booking - map bang `bookings`. showtimeId da xac dinh movie + room + time
 * (khong luu lai - 3NF). status: PENDING -> CONFIRMED -> USED | CANCELLED.
 * promoId nullable (Long) - null neu khong dung promo. seatIds: danh sach ghe
 * (tu booking_seats) - load khi can.
 */
public class Booking {

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_CONFIRMED = "CONFIRMED";
    public static final String STATUS_USED = "USED";
    public static final String STATUS_CANCELLED = "CANCELLED";
    /** CONFIRMED, het suat (end_time), chua check-in — set boi scheduler. */
    public static final String STATUS_NO_SHOW = "NO_SHOW";

    private long bookingId;
    private String customerUsername;
    private long showtimeId;
    private Long promoId;
    private String bookingCode;
    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private String status;
    private String notes;
    private LocalDateTime createdAt;

    private List<Long> seatIds; // tu booking_seats
    private List<String> seatLabels; // nhan hien thi: row_label + col_number (vd A5)
    private java.time.LocalDateTime showtimeStartTime;
    private String movieTitle;
    private String posterUrl;

    public Booking() {
    }

    public long getBookingId() {
        return bookingId;
    }

    public void setBookingId(long bookingId) {
        this.bookingId = bookingId;
    }

    public String getCustomerUsername() {
        return customerUsername;
    }

    public void setCustomerUsername(String customerUsername) {
        this.customerUsername = customerUsername;
    }

    public long getShowtimeId() {
        return showtimeId;
    }

    public void setShowtimeId(long showtimeId) {
        this.showtimeId = showtimeId;
    }

    public Long getPromoId() {
        return promoId;
    }

    public void setPromoId(Long promoId) {
        this.promoId = promoId;
    }

    public String getBookingCode() {
        return bookingCode;
    }

    public void setBookingCode(String bookingCode) {
        this.bookingCode = bookingCode;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public List<Long> getSeatIds() {
        return seatIds;
    }

    public void setSeatIds(List<Long> seatIds) {
        this.seatIds = seatIds;
    }

    public List<String> getSeatLabels() {
        return seatLabels;
    }

    public void setSeatLabels(List<String> seatLabels) {
        this.seatLabels = seatLabels;
    }

    public java.time.LocalDateTime getShowtimeStartTime() {
        return showtimeStartTime;
    }

    public void setShowtimeStartTime(java.time.LocalDateTime showtimeStartTime) {
        this.showtimeStartTime = showtimeStartTime;
    }

    public String getMovieTitle() {
        return movieTitle;
    }

    public void setMovieTitle(String movieTitle) {
        this.movieTitle = movieTitle;
    }

    public String getPosterUrl() {
        return posterUrl;
    }

    public void setPosterUrl(String posterUrl) {
        this.posterUrl = posterUrl;
    }
}
