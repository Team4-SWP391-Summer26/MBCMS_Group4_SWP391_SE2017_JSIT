package com.mbcms.dao;

import com.mbcms.model.Booking;
import java.util.List;

/**
 * BookingDAO - CRUD + seat-lock operations cho booking flow.
 *
 * Seat locking strategy (DB-level):
 *   booking_seats.lock_status = 'LOCKED'    khi PENDING,
 *                              = 'CONFIRMED' khi payment xong,
 *                              = 'RELEASED'  khi het gio / cancel.
 *   getSeatStatusForShowtime dung de ve so do ghe.
 */
public interface BookingDAO {

    // ── Booking CRUD ──────────────────────────────────────────────────────────

    /** Tao booking moi (INSERT bookings + booking_seats trong 1 transaction). */
    Booking createBooking(Booking booking, List<Long> seatIds);

    /** Tim booking theo ID. */
    Booking findById(long bookingId);

    /** Tim booking theo booking code (unique). */
    Booking findByCode(String bookingCode);

    /** Tat ca booking cua 1 customer, sap xep moi nhat truoc. */
    List<Booking> findByCustomer(String customerUsername);

    /**
     * Cap nhat status booking.
     * PENDING -> CONFIRMED (sau payment success),
     * PENDING -> CANCELLED (het gio / user cancel).
     */
    boolean updateStatus(long bookingId, String newStatus);

    // ── Seat locking ──────────────────────────────────────────────────────────
    /**
     * Kiem tra ghe co bi lock / da dat boi booking khac khong.
     * Return: list seatId da bi chiem -> dung truoc khi tao booking.
     */
    List<Long> getUnavailableSeatIds(long showtimeId, List<Long> seatIds);

    /**
     * Giai phong lock PENDING booking da qua 10 phut chua thanh toan.
     * Return: so booking duoc giai phong.
     */
    int releaseExpiredLocks();
}