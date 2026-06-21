package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Promotion;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.service.BookingService;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;

/**
 * BookingServiceImpl – xử lý toàn bộ booking flow.
 *
 * JSP tính status inline: !active→MAINTENANCE, inBooked→BOOKED, else→AVAILABLE.
 *
 * Price logic: STANDARD : basePrice × 1.00 VIP : basePrice × 1.30
 */
public class BookingServiceImpl implements BookingService {

    private static final double VIP_SURCHARGE = 0.30;

    private final BookingDAO bookingDao = new BookingDAOImpl();
    private final SeatDAO seatDao = new SeatDAOImpl();
    private final ShowtimeDAO showtimeDao = new ShowtimeDAOImpl();
    private final PromotionDAO promoDao = new PromotionDAOImpl();
    private final BranchDAO  branchDao  = new BranchDAOImpl();
    private final MovieDAO   movieDao   = new MovieDAOImpl();

    // ── validatePromoCode ─────────────────────────────────────────────────
    @Override
    public Promotion validatePromoCode(String code, BigDecimal subtotal) {
        if (code == null || code.isBlank()) {
            return null;
        }

        Promotion p = promoDao.findByCode(code.trim());
        if (p == null) {
            return null;
        }

        LocalDateTime now = LocalDateTime.now();
        if (!p.isActive()) {
            throw new IllegalArgumentException("This promo code has been deactivated.");
        }
        if (p.getValidFrom() != null && now.isBefore(p.getValidFrom())) {
            throw new IllegalArgumentException("This promo code is not valid yet.");
        }
        if (p.getValidTo() != null && now.isAfter(p.getValidTo())) {
            throw new IllegalArgumentException("This promo code has expired.");
        }
        if (p.getMaxUses() != null && p.getUsedCount() >= p.getMaxUses()) {
            throw new IllegalArgumentException("This promo code has reached its usage limit.");
        }
        if (p.getMinOrderAmount() != null && subtotal.compareTo(p.getMinOrderAmount()) < 0) {
            throw new IllegalArgumentException(String.format(
                    "Minimum order of %.0f VND required for this promo code.",
                    p.getMinOrderAmount().doubleValue()));
        }
        return p;
    }

    // ── createPendingBooking ──────────────────────────────────────────────
    @Override
    public Booking createPendingBooking(String customerUsername, long showtimeId,
            List<Long> seatIds, String promoCode, String notes) {
        if (seatIds == null || seatIds.isEmpty()) {
            throw new IllegalArgumentException("Please select at least one seat.");
        }

        // Lấy showtime
        Showtime st = showtimeDao.findById(showtimeId);
        if (st == null) {
            throw new IllegalArgumentException("Showtime not found.");
        }
        if (!"SCHEDULED".equals(st.getStatus())) {
            throw new IllegalArgumentException("This showtime is no longer available.");
        }

        // Lấy seats để tính surcharge – dùng List<Seat> từ seatDao
        List<Seat> allSeats = seatDao.findByRoom(st.getRoomId());
        Map<Long, Seat> seatMap = new HashMap<>();
        for (Seat s : allSeats) {
            seatMap.put(s.getSeatId(), s);
        }
        BigDecimal subtotal = calcSubtotal(seatIds, seatMap, st.getBasePrice());

        // Validate promo
        Promotion promo = validatePromoCode(promoCode, subtotal);
        BigDecimal discount = promo != null ? calcDiscount(promo, subtotal) : BigDecimal.ZERO;
        BigDecimal total = subtotal.subtract(discount).max(BigDecimal.ZERO);

        // Tạo Booking model
        Booking booking = new Booking();
        booking.setCustomerUsername(customerUsername);
        booking.setShowtimeId(showtimeId);
        booking.setPromoId(promo != null ? promo.getPromoId() : null);
        booking.setSubtotal(subtotal);
        booking.setDiscountAmount(discount);
        booking.setTotalAmount(total);
        booking.setNotes(notes);
        // createBooking() xử lý UPDLOCK + INSERT atomic bên trong
        return bookingDao.createBooking(booking, seatIds);
    }

    // ── confirmBooking ────────────────────────────────────────────────────
    @Override
    public Booking confirmBooking(long bookingId, String customerUsername) {
        int updated = bookingDao.confirmBooking(bookingId, customerUsername);
        if (updated == 0) {
            // 0 row affected: booking hết hạn hoặc sai trạng thái
            Booking b = bookingDao.findById(bookingId);
            if (b == null) {
                throw new IllegalArgumentException("Booking not found.");
            }
            if (!Booking.STATUS_PENDING.equals(b.getStatus())) {
                throw new IllegalStateException(
                        "Booking is not PENDING. Current status: " + b.getStatus());
            }
            // PENDING nhưng updated=0 → đã hết hạn
            throw new IllegalStateException("Your seat hold has expired. Please book again.");
        }

        // Tăng used_count nếu có promo
        Booking confirmed = bookingDao.findByIdWithSeats(bookingId);
        if (confirmed != null && confirmed.getPromoId() != null) {
            try {
                promoDao.incrementUsedCount(confirmed.getPromoId());
            } catch (Exception e) {
                System.err.println("WARN: Không tăng được promo used_count: " + e.getMessage());
            }
        }

        // Notify WebSocket: ghế → HARD_LOCK confirmed
        if (confirmed != null && confirmed.getSeatIds() != null) {
            com.mbcms.ws.SeatWebSocketServer.notifyHardLock(
                    confirmed.getShowtimeId(), confirmed.getSeatIds(), customerUsername);
        }

        return confirmed;
    }

    // ── getBookingHistory / getBookingDetail ──────────────────────────────
    @Override
    public List<Booking> getBookingHistory(String customerUsername) {
        return bookingDao.findByCustomer(customerUsername);
    }

    @Override
    public Booking getBookingDetail(long bookingId, String customerUsername) {
        Booking b = bookingDao.findByIdWithSeats(bookingId);
        if (b == null) {
            return null;
        }
        if (!b.getCustomerUsername().equals(customerUsername)) {
            throw new SecurityException("You are not allowed to view this booking.");
        }
        return b;
    }

    @Override
    public BookingTicket getTicket(long bookingId, String customerUsername) {
        // Owner check truoc khi tra ve view-model day du (tranh xem ve nguoi khac).
        Booking b = bookingDao.findById(bookingId);
        if (b == null) {
            return null;
        }
        if (!b.getCustomerUsername().equals(customerUsername)) {
            throw new SecurityException("You are not allowed to view this booking.");
        }
        return bookingDao.findTicket(bookingId);
    }
  @Override
    public Booking createCounterBooking(Booking booking, List<Long> seatIds, String promoCode, String customerPhone) {
        // 1. Tim kiem thanh vien bang SĐT (neu khong co -> mac dinh guest01)
        String username = "guest01";
        if (customerPhone != null && !customerPhone.trim().isEmpty()) {
            Customer member = customerDAO.findByPhone(customerPhone.trim());
            if (member != null) {
                username = member.getUsername();
            }
        }
        booking.setCustomerUsername(username);

        // 2. Ap dung ma khuyen mai neu co
        Long promoId = null;
        BigDecimal discount = BigDecimal.ZERO;
        if (promoCode != null && !promoCode.trim().isEmpty()) {
            Promotion promo = promotionDAO.findByCode(promoCode.trim().toUpperCase());
            if (promo != null && promo.isActive() && "Active".equals(promo.getStatus())) {
                BigDecimal minAmt = promo.getMinOrderAmount();
                // Kiem tra gia tri don hang toi thieu
                if (minAmt == null || booking.getSubtotal().compareTo(minAmt) >= 0) {
                    promoId = promo.getPromoId();
                    if (Promotion.TYPE_PERCENT.equals(promo.getDiscountType())) {
                        discount = booking.getSubtotal()
                                .multiply(promo.getDiscountValue())
                                .divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
                    } else if (Promotion.TYPE_FIXED_AMOUNT.equals(promo.getDiscountType())) {
                        discount = promo.getDiscountValue();
                    }

                    // Khong duoc giam nhieu hon gia tri don hang
                    if (discount.compareTo(booking.getSubtotal()) > 0) {
                        discount = booking.getSubtotal();
                    }
                }
            }
        }
        booking.setPromoId(promoId);
        booking.setDiscountAmount(discount);
        booking.setTotalAmount(booking.getSubtotal().subtract(discount));

        // 3. Goi DAO ghi nhan Booking + Seats + CASH Payment trong 1 transaction
        return bookingDAO.createCounterBooking(booking, seatIds);

    @Override
    public List<BookingTicket> getBookingHistoryTickets(String customerUsername) {
        return bookingDao.findTicketsByCustomer(customerUsername);
    }

    // ── expirePendingBookings ─────────────────────────────────────────────
    @Override
    public int releaseExpiredLocks() {
        return bookingDao.releaseExpiredLocks();
    }

    // ── Private helpers ───────────────────────────────────────────────────
    private BigDecimal calcSubtotal(List<Long> selectedIds,
            Map<Long, Seat> seatMap,
            BigDecimal basePrice) {
        BigDecimal total = BigDecimal.ZERO;
        for (Long id : selectedIds) {
            Seat seat = seatMap.get(id);
            BigDecimal price = basePrice;
            if (seat != null) {
                if ("VIP".equals(seat.getSeatType())) {
                    price = basePrice.multiply(BigDecimal.valueOf(1 + VIP_SURCHARGE));
                }
            }
            total = total.add(price.setScale(0, RoundingMode.HALF_UP));
        }
        return total;
    }

    private BigDecimal calcDiscount(Promotion promo, BigDecimal subtotal) {
        if ("PERCENT".equals(promo.getDiscountType())) {
            return subtotal.multiply(promo.getDiscountValue())
                    .divide(BigDecimal.valueOf(100), 0, RoundingMode.HALF_UP);
        }
        return promo.getDiscountValue().min(subtotal); // FIXED_AMOUNT
    }

    @Override
    public int cancelBooking(long bookingId, String customerUsername) {
        return bookingDao.cancelBooking(bookingId, customerUsername);
    }
}
