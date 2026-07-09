package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * TicketValidationResult - ket qua kiem tra ve tai cua vao (Branch Staff).
 * Status codes:
 *  VALID           - ve CONFIRMED, dung suat, cho phep check-in
 *  CHECKED_IN      - vua check-in thanh cong (sau action checkin)
 *  NOT_FOUND       - khong tim thay booking code
 *  WRONG_BRANCH    - ve thuoc chi nhanh khac
 *  ALREADY_USED    - ve da check-in truoc do (duplicate entry bi chan)
 *  NOT_PAID        - booking PENDING, chua thanh toan
 *  CANCELLED       - booking da huy
 *  NO_SHOW         - het suat, khach khong check-in
 *  TOO_EARLY       - chua den gio vao rap (som hon cua so cho phep)
 *  EXPIRED         - suat chieu da ket thuc
 */
public class TicketValidationResult {

    public static final String VALID = "VALID";
    public static final String CHECKED_IN = "CHECKED_IN";
    public static final String NOT_FOUND = "NOT_FOUND";
    public static final String WRONG_BRANCH = "WRONG_BRANCH";
    public static final String ALREADY_USED = "ALREADY_USED";
    public static final String NOT_PAID = "NOT_PAID";
    public static final String CANCELLED = "CANCELLED";
    public static final String NO_SHOW = "NO_SHOW";
    public static final String TOO_EARLY = "TOO_EARLY";
    public static final String EXPIRED = "EXPIRED";

    private String status;
    private String message;
    private BookingTicket ticket;       // null neu NOT_FOUND / WRONG_BRANCH
    private LocalDateTime checkInTime;  // set khi ALREADY_USED / CHECKED_IN

    public TicketValidationResult() {}

    public TicketValidationResult(String status, String message) {
        this.status = status;
        this.message = message;
    }

    /** Ve o trang thai cho phep bam nut check-in. */
    public boolean isAllowEntry() {
        return VALID.equals(status);
    }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public BookingTicket getTicket() { return ticket; }
    public void setTicket(BookingTicket ticket) { this.ticket = ticket; }

    public LocalDateTime getCheckInTime() { return checkInTime; }
    public void setCheckInTime(LocalDateTime checkInTime) { this.checkInTime = checkInTime; }
}
