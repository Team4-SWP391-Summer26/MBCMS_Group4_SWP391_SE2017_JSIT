package com.mbcms.dao;

import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import java.sql.Connection;
import java.util.List;

/**
 * BookingDAO - CRUD + seat-lock operations cho booking flow.
 * Seat hold: PENDING bookings expire 10 minutes after created_at (SYSUTCDATETIME).
 */
public interface BookingDAO {

    // ── Booking CRUD ──────────────────────────────────────────────────────────
    /**
     * Tao booking moi (INSERT bookings + booking_seats trong 1 transaction).
     */
    Booking createBooking(Booking booking, List<Long> seatIds);

    /**
     * Tim booking theo ID.
     */
    Booking findById(long bookingId);

    /**
     * Tim booking theo booking code (unique).
     */
    Booking findByCode(String bookingCode);

    /**
     * Tat ca booking cua 1 customer, sap xep moi nhat truoc.
     */
    List<Booking> findByCustomer(String customerUsername);
    
     /** Tìm booking theo ID, kèm load seatIds từ booking_seats. */
    Booking findByIdWithSeats(long bookingId);

    /**
     * View-model day du cho man Confirm / e-ticket: JOIN bookings + showtimes +
     * movies + rooms + branches + customers, kem nhan ghe (row_label+col_number).
     * Return null neu khong tim thay.
     */
    BookingTicket findTicket(long bookingId);

    /** Danh sach BookingTicket (day du) cua 1 customer, suat moi nhat truoc. */
    List<BookingTicket> findTicketsByCustomer(String customerUsername);
    
    /**
     * PENDING → CANCELLED (hết hạn hoặc user huỷ).
     * Chỉ huỷ được PENDING, không huỷ CONFIRMED.
     */
    int cancelBooking(long bookingId, String customerUsername);

    /**
     * Cap nhat status booking. PENDING -> CONFIRMED (sau payment success),
     * PENDING -> CANCELLED (het gio / user cancel).
     */
    boolean updateStatus(long bookingId, String newStatus);

    /**
     * Cap nhat subtotal va total_amount cua booking.
     */
    boolean updateBookingTotals(long bookingId, Long promoId, java.math.BigDecimal newSubtotal,
            java.math.BigDecimal discountAmount, java.math.BigDecimal newTotalAmount);
    
    /**
     * Kiem tra ghe co bi lock / da dat boi booking khac khong. Return: list
     * seatId da bi chiem -> dung truoc khi tao booking.
     * PENDING → CONFIRMED (sau payment thành công).
     * Chỉ update khi status=PENDING và expires_at > NOW.
     * Return số row affected (0 = hết hạn hoặc sai trạng thái).
     */
    int confirmBooking(long bookingId, String customerUsername);

    /**
     * Overload connection-aware: PENDING → CONFIRMED ben trong transaction
     * cua payment callback (SRS 3.8.4). Dung chung Connection voi PaymentDAO
     * de payments + bookings cap nhat atomic. KHONG commit/close connection.
     * Return so row affected (0 = het han hoac sai trang thai).
     */
    int confirmBooking(Connection conn, long bookingId, String customerUsername);

    /**
     * Giai phong lock PENDING booking da qua 10 phut chua thanh toan. Return:
     * so booking duoc giai phong.
     */
    int releaseExpiredLocks();

    /**
     * True if booking is PENDING and created_at + 10 min has passed (UTC, same as confirmBooking SQL).
     */
    boolean isPendingHoldExpired(long bookingId);

    /**
     * Tạo đặt vé tại quầy cho nhân viên (Branch Staff) trong 1 Transaction. Bao
     * gồm kiểm tra ghế trống, chèn bookings, chèn booking_seats, chèn payments
     * (CASH - SUCCESS) và cập nhật số lần dùng khuyến mãi.
     */
    Booking createCounterBooking(Booking booking, List<Long> seatIds);
    
    List<Booking> findConfirmedForReminder(int minutesFrom, int minutesTo);
    
    int markCompletedBookingsAsUsed();

    // ── Ticket validation / check-in (Branch Staff) ──────────────────────────

    /**
     * Check-in ca booking tai cua vao (1 transaction):
     *  1) bookings: CONFIRMED -> USED (guard WHERE status='CONFIRMED' de chong
     *     duplicate entry — ve da USED thi UPDATE 0 row, khong check-in lai duoc).
     *  2) booking_seats: is_checked_in=1 + check_in_time=SYSUTCDATETIME().
     * Return so row bookings duoc update: 1 = check-in thanh cong, 0 = ve khong
     * o trang thai CONFIRMED (chua thanh toan / da huy / da vao rap).
     */
    int checkInBooking(long bookingId);

    /**
     * Thoi diem check-in cua booking (MAX check_in_time trong booking_seats),
     * doc theo UTC (cung he voi SYSUTCDATETIME luc ghi). Null neu chua check-in.
     */
    java.time.LocalDateTime findCheckInTime(long bookingId);

    /**
     * Attendance tracking: thong ke so ghe da dat vs so khach da check-in cho
     * tung suat chieu cua 1 chi nhanh trong 1 ngay (theo start_time).
     * Chi dem booking CONFIRMED/USED; bo qua suat CANCELLED.
     */
    List<com.mbcms.model.ShowtimeAttendance> findAttendanceByBranch(long branchId, java.time.LocalDate date);
}
