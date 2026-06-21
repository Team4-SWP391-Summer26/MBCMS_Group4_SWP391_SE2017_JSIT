package com.mbcms.dao;

import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import java.sql.Connection;
import java.util.List;

/**
 * BookingDAO - CRUD + seat-lock operations cho booking flow.
 *
 * Seat locking strategy (DB-level): booking_seats.lock_status = 'LOCKED' khi
 * PENDING, = 'CONFIRMED' khi payment xong, = 'RELEASED' khi het gio / cancel.
 * getSeatStatusForShowtime dung de ve so do ghe.
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
     * Tạo đặt vé tại quầy cho nhân viên (Branch Staff) trong 1 Transaction. Bao
     * gồm kiểm tra ghế trống, chèn bookings, chèn booking_seats, chèn payments
     * (CASH - SUCCESS) và cập nhật số lần dùng khuyến mãi.
     */
    Booking createCounterBooking(Booking booking, List<Long> seatIds);
}
