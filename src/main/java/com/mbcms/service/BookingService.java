package com.mbcms.service;

import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Promotion;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * BookingService – business logic cho toàn bộ booking flow.
 *

 * Flow chính: 1. getSeatMapData(showtimeId) → SeatMapData để render sơ đồ ghế
 * 2. validatePromoCode(code, subtotal) → Promotion hợp lệ (null nếu không có)
 * 3. createPendingBooking(...) → PENDING booking, lock ghế atomic (UPDLOCK) 4.
 * confirmBooking(bookingId, user) → PENDING → CONFIRMED sau payment 5.
 * expirePendingBookings() → cleanup, gọi bởi Scheduler
 */
import com.mbcms.model.Booking;
import java.util.List;

public interface BookingService {

    /**
     * Xử lý đặt vé tại quầy cho nhân viên (Branch Staff). Bao gồm: kiểm tra ghế
     * trống, áp dụng khuyến mãi, liên kết thành viên, và thanh toán tiền mặt
     * thành công (CASH) trong 1 Transaction.
     */
    Booking createCounterBooking(Booking booking, List<Long> seatIds, String promoCode, BigDecimal concessionsSubtotal);
    // ── Promo ─────────────────────────────────────────────────────────────
    /**
     * Validate promo code: active, chưa hết hạn, chưa hết lượt, minOrderAmount.
     * Trả về Promotion nếu hợp lệ, null nếu code không tồn tại. Throw
     * IllegalArgumentException với message cụ thể nếu tồn tại nhưng không dùng
     * được.
     */
    Promotion validatePromoCode(String code, BigDecimal subtotal, BigDecimal concessionsSubtotal, Long branchId);

    // ── Booking CRUD ──────────────────────────────────────────────────────
    /**
     * Tạo PENDING booking và lock ghế (UPDLOCK atomic). Throw
     * SeatUnavailableException nếu có ghế bị chiếm.
     */
    Booking createPendingBooking(String customerUsername, long showtimeId,
            List<Long> seatIds, String promoCode, String notes, BigDecimal concessionsSubtotal);

    /**
     * PENDING → CONFIRMED sau payment thành công. Throw IllegalStateException
     * nếu booking hết hạn hoặc sai trạng thái.
     */
    Booking confirmBooking(long bookingId, String customerUsername);

    /**
     * Cap nhat subtotal, discount va total_amount — chi PENDING + owner.
     */
    boolean updateBookingTotals(long bookingId, String customerUsername,
            java.math.BigDecimal newSubtotal, java.math.BigDecimal discountAmount,
            java.math.BigDecimal newTotalAmount);

    /** True neu booking PENDING da qua 10 phut (UTC, cung logic SQL). */
    boolean isPendingHoldExpired(long bookingId);

    /**
     * Tinh lai tickets + food + promo, cap nhat totals cho booking PENDING.
     */
    boolean recalculateTotalsWithFood(long bookingId, String username,
            java.util.Map<Long, Integer> foodItems);

    /**
     * Lịch sử booking của customer, mới nhất trước.
     */
    List<Booking> getBookingHistory(String customerUsername);

    /**
     * Chi tiết 1 booking (kèm seatIds). Throw SecurityException nếu không phải
     * owner.
     */
    Booking getBookingDetail(long bookingId, String customerUsername);

    /**
     * View-model day du cho man Confirm / e-ticket (movie, showtime, room,
     * branch, seat labels, customer). Throw SecurityException neu khong phai
     * owner. Return null neu khong tim thay.
     */
    BookingTicket getTicket(long bookingId, String customerUsername);

    /**
     * Staff counter: load ticket by bookingId, verify branch scope (no owner username).
     */
    BookingTicket getTicketForBranch(long bookingId, long branchId);

    /**
     * Lich su booking dang view-model day du (movie/showtime/room/seat labels)
     * cho trang My Bookings.
     */
    List<BookingTicket> getBookingHistoryTickets(String customerUsername);


    public int cancelBooking(long bookingId, String customerUsername);

    /**
     * Cancel tất cả PENDING booking đã quá expires_at. Gọi bởi
     * BookingExpiryScheduler mỗi 60 giây.
     */
    int releaseExpiredLocks();
}
