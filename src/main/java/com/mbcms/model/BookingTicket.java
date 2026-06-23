package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

/**
 * BookingTicket - view model (read-only) cho man hinh Confirm / e-ticket.
 *
 * Gom du lieu da JOIN tu nhieu bang (bookings + showtimes + movies + rooms +
 * branches + seats + customers) de hien thi 1 ve dien tu day du, thay vi chi
 * "Showtime #id" + "Seat #id". KHONG map 1-1 voi 1 bang nao.
 */
public class BookingTicket {

    private long bookingId;
    private String bookingCode;
    private String status;

    private BigDecimal subtotal;
    private BigDecimal discountAmount;
    private BigDecimal totalAmount;
    private LocalDateTime createdAt;

    // Movie
    private String movieTitle;
    private String movieRated;
    private int durationMin;
    private String posterUrl;

    // Showtime / room / branch
    private LocalDateTime startTime;
    private String format;        // 2D / 3D / IMAX
    private String subtitleType;  // SUB / DUB / ORIGINAL
    private long branchId;
    private String branchName;
    private String roomName;

    // Customer
    private String customerFullName;
    private String customerEmail;

    // Ghe da chon (label dang "C5", "C6")
    private List<String> seatLabels;

    public BookingTicket() {}

    public long getBookingId() { return bookingId; }
    public void setBookingId(long bookingId) { this.bookingId = bookingId; }

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public BigDecimal getSubtotal() { return subtotal; }
    public void setSubtotal(BigDecimal subtotal) { this.subtotal = subtotal; }

    public BigDecimal getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(BigDecimal discountAmount) { this.discountAmount = discountAmount; }

    public BigDecimal getTotalAmount() { return totalAmount; }
    public void setTotalAmount(BigDecimal totalAmount) { this.totalAmount = totalAmount; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getMovieTitle() { return movieTitle; }
    public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }

    public String getMovieRated() { return movieRated; }
    public void setMovieRated(String movieRated) { this.movieRated = movieRated; }

    public int getDurationMin() { return durationMin; }
    public void setDurationMin(int durationMin) { this.durationMin = durationMin; }

    public String getPosterUrl() { return posterUrl; }
    public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public String getFormat() { return format; }
    public void setFormat(String format) { this.format = format; }

    public String getSubtitleType() { return subtitleType; }
    public void setSubtitleType(String subtitleType) { this.subtitleType = subtitleType; }

    public long getBranchId() { return branchId; }
    public void setBranchId(long branchId) { this.branchId = branchId; }

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public String getCustomerFullName() { return customerFullName; }
    public void setCustomerFullName(String customerFullName) { this.customerFullName = customerFullName; }

    public String getCustomerEmail() { return customerEmail; }
    public void setCustomerEmail(String customerEmail) { this.customerEmail = customerEmail; }

    public List<String> getSeatLabels() { return seatLabels; }
    public void setSeatLabels(List<String> seatLabels) { this.seatLabels = seatLabels; }
}
