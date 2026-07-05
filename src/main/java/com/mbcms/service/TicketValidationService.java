package com.mbcms.service;

import com.mbcms.model.ShowtimeAttendance;
import com.mbcms.model.TicketValidationResult;

import java.time.LocalDate;
import java.util.List;

/**
 * TicketValidationService - nghiep vu kiem soat ve tai cua vao (Branch Staff).
 *
 * Flow: staff nhap booking code thu cong (thay QR scanner):
 *  1. validateTicket(code, branchId)  -> tra trang thai ve, KHONG thay doi DB
 *  2. checkInTicket(code, branchId)   -> validate lai + CONFIRMED -> USED +
 *     booking_seats.is_checked_in = 1 (atomic, chong duplicate entry)
 *  3. getAttendance(branchId, date)   -> thong ke khach vao rap theo suat
 */
public interface TicketValidationService {

    /**
     * Kiem tra ve theo booking code trong pham vi chi nhanh cua staff.
     * Read-only: dung cho buoc "soi ve" truoc khi bam Check-in.
     */
    TicketValidationResult validateTicket(String bookingCode, long branchId);

    /**
     * Check-in ve: validate + doi trang thai trong 1 giao dich DB co guard
     * (WHERE status='CONFIRMED') nen ve da dung khong the vao lan 2.
     */
    TicketValidationResult checkInTicket(String bookingCode, long branchId);

    /**
     * Attendance tracking: danh sach suat chieu cua chi nhanh trong ngay kem
     * so ghe da ban / so khach da check-in.
     */
    List<ShowtimeAttendance> getAttendance(long branchId, LocalDate date);
}
