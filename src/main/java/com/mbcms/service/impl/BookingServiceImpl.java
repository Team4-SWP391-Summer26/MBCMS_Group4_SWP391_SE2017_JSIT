package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.Customer;
import com.mbcms.model.Promotion;
import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;
import com.mbcms.service.BookingService;
import com.mbcms.service.FoodService;
import com.mbcms.service.NotificationService;
import com.mbcms.service.impl.FoodServiceImpl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
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

    public BookingServiceImpl() {
        this.bookingDao = new BookingDAOImpl();
        this.seatDao = new SeatDAOImpl();
        this.showtimeDao = new ShowtimeDAOImpl();
        this.promoDao = new PromotionDAOImpl();
        this.notificationService = new NotificationServiceImpl();
        this.foodService = new FoodServiceImpl();
    }

    /** Constructor for unit tests (inject mocks). */
    BookingServiceImpl(BookingDAO bookingDao, SeatDAO seatDao, ShowtimeDAO showtimeDao,
            PromotionDAO promoDao, NotificationService notificationService) {
        this(bookingDao, seatDao, showtimeDao, promoDao, notificationService, new FoodServiceImpl());
    }

    BookingServiceImpl(BookingDAO bookingDao, SeatDAO seatDao, ShowtimeDAO showtimeDao,
            PromotionDAO promoDao, NotificationService notificationService, FoodService foodService) {
        this.bookingDao = bookingDao;
        this.seatDao = seatDao;
        this.showtimeDao = showtimeDao;
        this.promoDao = promoDao;
        this.notificationService = notificationService;
        this.foodService = foodService;
    }

    private final BookingDAO bookingDao;
    private final SeatDAO seatDao;
    private final ShowtimeDAO showtimeDao;
    private final PromotionDAO promoDao;
    private final NotificationService notificationService;
    private final FoodService foodService;

    // ── validatePromoCode ─────────────────────────────────────────────────
    @Override
    public Promotion validatePromoCode(String code, BigDecimal subtotal, BigDecimal concessionsSubtotal, Long branchId) {
        if (code == null || code.trim().isEmpty()) {
            return null;
        }

        Promotion p = promoDao.findByCode(code.trim().toUpperCase());
        if (p == null) {
            throw new IllegalArgumentException("Promotion code not found");
        }

        LocalDateTime now = LocalDateTime.now(ZoneOffset.UTC);
        if (!p.isActive() || !"Active".equals(p.getStatus())) {
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
        if (p.getBranchId() != null && branchId != null && !p.getBranchId().equals(branchId)) {
            throw new IllegalArgumentException("This promo code is not applicable to this branch.");
        }
        return p;
    }

    // ── createPendingBooking ──────────────────────────────────────────────
    @Override
    public Booking createPendingBooking(String customerUsername, long showtimeId,
            List<Long> seatIds, String promoCode, String notes, BigDecimal concessionsSubtotal) {
        if (seatIds == null || seatIds.isEmpty()) {
            throw new IllegalArgumentException("Please select at least one seat.");
        }
        if (seatIds.size() > 8) {
            throw new IllegalArgumentException("Maximum 8 seats per booking.");
        }

        // Lấy showtime
        Showtime st = showtimeDao.findById(showtimeId);
        validateShowtimeForBooking(st);

        // Lấy seats để tính surcharge – dùng List<Seat> từ seatDao
        List<Seat> allSeats = seatDao.findByRoom(st.getRoomId());
        Map<Long, Seat> seatMap = new HashMap<>();
        for (Seat s : allSeats) {
            seatMap.put(s.getSeatId(), s);
        }

        for (Long seatId : seatIds) {
            Seat seat = seatMap.get(seatId);
            if (seat == null || seat.getRoomId() != st.getRoomId()) {
                throw new IllegalArgumentException("Invalid seat selection.");
            }
            if (!seat.isActive()) {
                throw new IllegalArgumentException(
                        "Seat " + seat.getRowLabel() + seat.getColNumber() + " is unavailable.");
            }
        }

        BigDecimal ticketsSubtotal = calcSubtotal(seatIds, seatMap, st.getBasePrice());
        BigDecimal totalConcessions = concessionsSubtotal != null ? concessionsSubtotal : BigDecimal.ZERO;

        // Get branchId from showtime's room
        Room room = new RoomDAOImpl().findById(st.getRoomId());
        Long branchId = room != null ? room.getBranchId() : null;
        
        
        // Tạo Booking model
        Booking booking = new Booking();
        booking.setCustomerUsername(customerUsername);
        booking.setShowtimeId(showtimeId);
        booking.setPromoId(null);
        booking.setSubtotal(ticketsSubtotal.add(totalConcessions));
        booking.setDiscountAmount(BigDecimal.ZERO);
        booking.setTotalAmount(ticketsSubtotal.add(totalConcessions));
        booking.setNotes(notes);
        // createBooking() xử lý UPDLOCK + INSERT atomic bên trong
        Booking result = bookingDao.createBooking(booking, seatIds);
        
        if (result != null && promoCode != null && !promoCode.trim().isEmpty()) {
            result = applyPromoToBooking(result.getBookingId(), customerUsername, promoCode, concessionsSubtotal);
        }
        
        // Bo sung thong tin hien thi cho context bar checkout (ten phim + gio chieu + poster)
        if (result != null) {
            result.setMovieTitle(st.getMovieTitle());
            result.setShowtimeStartTime(st.getStartTime());
            result.setPosterUrl(st.getPosterUrl());
        }
        return result;
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
                if (!promoDao.incrementUsedCount(confirmed.getPromoId())) {
                    System.err.println("WARN: Promo usage limit reached for promo_id=" + confirmed.getPromoId());
                }
            } catch (Exception e) {
                System.err.println("WARN: Không tăng được promo used_count: " + e.getMessage());
            }
        }

        // Notify WebSocket: ghế → HARD_LOCK confirmed
        if (confirmed != null && confirmed.getSeatIds() != null) {
            com.mbcms.ws.SeatWebSocketServer.notifyHardLock(
                    confirmed.getShowtimeId(), confirmed.getSeatIds(), customerUsername);
        }

        // ── Gui thong bao xac nhan dat ve + thanh toan cho customer ──────────
        // Wrapped trong try/catch rieng: loi thong bao KHONG duoc anh huong
        // den ket qua booking (giong pattern cua promo used_count o tren).
        if (confirmed != null) {
            try {
                String email = null;
                try {
                    Customer c = new CustomerDAOImpl().findByUsername(confirmed.getCustomerUsername());
                    if (c != null) email = c.getEmail();
                } catch (Exception ignored) {}

                notificationService.sendBookingConfirmation(confirmed, email);
            } catch (Exception e) {
                System.err.println("WARN: Khong tao duoc notification: " + e.getMessage());
            }
        }

        return confirmed;
    }

    @Override
    public boolean isPendingHoldExpired(long bookingId) {
        return bookingDao.isPendingHoldExpired(bookingId);
    }
    
    // ── applyPromoToBooking ─────────────────────────────────────────────────
    @Override
    public Booking applyPromoToBooking(long bookingId, String customerUsername,
            String promoCode, BigDecimal concessionsSubtotal) {
        Booking b = bookingDao.findByIdWithSeats(bookingId);
        if (b == null) {
            throw new IllegalArgumentException("Booking not found.");
        }
        if (!b.getCustomerUsername().equals(customerUsername)) {
            throw new SecurityException("You are not allowed to update this booking.");
        }
        if (!Booking.STATUS_PENDING.equals(b.getStatus())) {
            throw new IllegalStateException(
                    "Booking is not PENDING. Current status: " + b.getStatus());
        }
        if (isPendingHoldExpired(bookingId)) {
            throw new IllegalStateException("Your seat hold has expired. Please book again.");
        }

        Showtime st = showtimeDao.findById(b.getShowtimeId());
        if (st == null) {
            throw new IllegalArgumentException("Showtime not found.");
        }

        List<Long> seatIds = b.getSeatIds();
        if (seatIds == null || seatIds.isEmpty()) {
            throw new IllegalStateException("Booking has no seats.");
        }

        List<Seat> allSeats = seatDao.findByRoom(st.getRoomId());
        Map<Long, Seat> seatMap = new HashMap<>();
        for (Seat s : allSeats) {
            seatMap.put(s.getSeatId(), s);
        }

        BigDecimal ticketsSubtotal = calcSubtotal(seatIds, seatMap, st.getBasePrice());

        Room room = new RoomDAOImpl().findById(st.getRoomId());
        Long branchId = room != null ? room.getBranchId() : null;

        // validatePromoCode throws IllegalArgumentException nếu promo không hợp
        // lệ — để nguyên propagate lên, KHÔNG đụng tới booking/seat đang giữ.
        Promotion promo = validatePromoCode(promoCode, ticketsSubtotal, concessionsSubtotal, branchId);
        BigDecimal discount = promo != null ? calcDiscount(promo, ticketsSubtotal) : BigDecimal.ZERO;

        BigDecimal totalConcessions = concessionsSubtotal != null ? concessionsSubtotal : BigDecimal.ZERO;
        BigDecimal subtotal = ticketsSubtotal.add(totalConcessions);
        BigDecimal total = ticketsSubtotal.subtract(discount).max(BigDecimal.ZERO).add(totalConcessions);
        Long promoId = promo != null ? promo.getPromoId() : null;

        boolean updated = bookingDao.updateBookingTotals(bookingId, promoId, subtotal, discount, total);
        if (!updated) {
            // Race: booking vừa hết PENDING (confirm/expire) giữa lúc tính toán.
            throw new IllegalStateException("Your seat hold has expired. Please book again.");
        }

        return bookingDao.findByIdWithSeats(bookingId);
    }
    
    @Override
    public boolean recalculateTotalsWithFood(long bookingId, String username,
            Map<Long, Integer> foodItems) {
        Booking b = getBookingDetail(bookingId, username);
        if (b == null || !Booking.STATUS_PENDING.equals(b.getStatus())) {
            return false;
        }
        if (isPendingHoldExpired(bookingId)) {
            return false;
        }

        BigDecimal foodSubtotal = foodService.computeValidatedFoodSubtotal(foodItems);

        // Lấy lại promo code hiện tại của booking (nếu có) để giữ nguyên promo
        // đang áp dụng — applyPromoToBooking tự validate lại + tính discount +
        // update totals, tránh lặp lại logic tính tiền ở đây.
        String currentPromoCode = null;
        if (b.getPromoId() != null) {
            Promotion currentPromo = promoDao.findById(b.getPromoId());
            currentPromoCode = currentPromo != null ? currentPromo.getCode() : null;
        }

        try {
            applyPromoToBooking(bookingId, username, currentPromoCode, foodSubtotal);
            return true;
        } catch (IllegalArgumentException e) {
            // Promo hiện tại không còn hợp lệ nữa (vd: vừa hết hạn/hết lượt
            // giữa lúc khách thêm đồ ăn) → fallback: cập nhật totals KHÔNG có
            // promo, để booking không bị kẹt.
            try {
                applyPromoToBooking(bookingId, username, null, foodSubtotal);
                return true;
            } catch (Exception inner) {
                return false;
            }
        } catch (IllegalStateException e) {
            return false;
        }
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
    public BookingTicket getTicketForBranch(long bookingId, long branchId) {
        BookingTicket ticket = bookingDao.findTicket(bookingId);
        if (ticket == null) {
            return null;
        }
        if (ticket.getBranchId() != branchId) {
            throw new SecurityException("Booking not in your branch.");
        }
        return ticket;
    }
    @Override
    public Booking createCounterBooking(Booking booking, List<Long> seatIds, String promoCode, BigDecimal concessionsSubtotal) {
        if (seatIds == null || seatIds.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng chọn ít nhất 1 ghế.");
        }
        if (seatIds.size() > 8) {
            throw new IllegalArgumentException("Tối đa 8 ghế mỗi lần đặt.");
        }

        Showtime st = showtimeDao.findById(booking.getShowtimeId());
        validateShowtimeForBooking(st);

        // Validate ghe: phai thuoc dung phong cua showtime va dang active
        // (chong dat ghe sai phong / ghe inactive o luong quay tien mat).
        List<Seat> roomSeats = seatDao.findByRoom(st.getRoomId());
        Map<Long, Seat> counterSeatMap = new HashMap<>();
        for (Seat s : roomSeats) {
            counterSeatMap.put(s.getSeatId(), s);
        }
        for (Long seatId : seatIds) {
            Seat seat = counterSeatMap.get(seatId);
            if (seat == null || seat.getRoomId() != st.getRoomId()) {
                throw new IllegalArgumentException("Ghế không hợp lệ cho suất chiếu này.");
            }
            if (!seat.isActive()) {
                throw new IllegalArgumentException(
                        "Ghế " + seat.getRowLabel() + seat.getColNumber() + " không khả dụng.");
            }
        }

        String customerUsername = booking.getCustomerUsername();
        if (customerUsername == null || customerUsername.trim().isEmpty()) {
            customerUsername = "guest01";
        }
        booking.setCustomerUsername(customerUsername.trim());

        BigDecimal ticketsSubtotal = booking.getSubtotal();

        Room room = new RoomDAOImpl().findById(st.getRoomId());
        Long branchId = room != null ? room.getBranchId() : null;

        Promotion promo = validatePromoCode(promoCode, ticketsSubtotal, concessionsSubtotal, branchId);
        BigDecimal discount = promo != null ? calcDiscount(promo, ticketsSubtotal) : BigDecimal.ZERO;

        BigDecimal totalConcessions = concessionsSubtotal != null ? concessionsSubtotal : BigDecimal.ZERO;

        booking.setPromoId(promo != null ? promo.getPromoId() : null);
        booking.setDiscountAmount(discount);
        booking.setSubtotal(ticketsSubtotal.add(totalConcessions));
        booking.setTotalAmount(ticketsSubtotal.subtract(discount).max(BigDecimal.ZERO).add(totalConcessions));

        return bookingDao.createCounterBooking(booking, seatIds);
    }

    @Override
    public List<BookingTicket> getBookingHistoryTickets(String customerUsername) {
        return bookingDao.findTicketsByCustomer(customerUsername);
    }

    // ── expirePendingBookings ─────────────────────────────────────────────
    @Override
    public int releaseExpiredLocks() {
        return bookingDao.releaseExpiredLocks();
    }
    
    @Override
    public int markCompletedBookingsAsUsed() {
        return bookingDao.markCompletedBookingsAsUsed();
    }
    // ── Private helpers ───────────────────────────────────────────────────
    private void validateShowtimeForBooking(Showtime st) {
        if (st == null) {
            throw new IllegalArgumentException("Showtime not found.");
        }
        if (!"SCHEDULED".equals(st.getStatus())) {
            throw new IllegalArgumentException("This showtime is no longer available.");
        }
        if (st.getStartTime().isBefore(LocalDateTime.now(ZoneOffset.UTC))) {
            throw new IllegalArgumentException("Cannot book a showtime in the past.");
        }
    }

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
