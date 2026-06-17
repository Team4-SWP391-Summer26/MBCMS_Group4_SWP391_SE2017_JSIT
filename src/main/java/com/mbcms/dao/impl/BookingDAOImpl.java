package com.mbcms.dao.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.model.Booking;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * BookingDAOImpl - thuc hien BookingDAO.
 *
 * Seat-locking logic: - booking_seats co cot: booking_id, seat_id, lock_status
 * (LOCKED|CONFIRMED|RELEASED), unit_price, locked_at. - PENDING booking +
 * LOCKED seats = seat dang bi giu. - Khi CONFIRMED: cap nhat
 * booking_seats.lock_status = 'CONFIRMED'. - Khi CANCELLED / het gio: cap nhat
 * lock_status = 'RELEASED'. - releaseExpiredLocks(): tim PENDING booking tao >
 * 10 phut va giai phong.
 *
 * SQL dialect: SQL Server (mssql-jdbc).
 */
public class BookingDAOImpl extends BaseDAO implements BookingDAO {

    private static final int LOCK_EXPIRE_MINUTES = 10;

    // ── createBooking ─────────────────────────────────────────────────────────
    @Override
    public Booking createBooking(Booking booking, List<Long> seatIds) {
        // Sinh booking_code duy nhat
        booking.setBookingCode("BK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        booking.setStatus(Booking.STATUS_PENDING);

        String insertBooking
                = "INSERT INTO bookings (customer_username, showtime_id, promo_id, booking_code, "
                + "  subtotal, discount_amount, total_amount, status, notes, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        String insertSeat
                = "INSERT INTO booking_seats (booking_id, seat_id, lock_status, unit_price, locked_at) "
                + "VALUES (?, ?, 'LOCKED', ?, GETDATE())";

        // SQL Server: lay generated key
        String insertBookingWithKey = insertBooking;

        Connection conn = null;
        PreparedStatement psBooking = null;
        PreparedStatement psSeat = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Insert booking, lay generated key
            psBooking = conn.prepareStatement(insertBookingWithKey, Statement.RETURN_GENERATED_KEYS);
            psBooking.setString(1, booking.getCustomerUsername());
            psBooking.setLong(2, booking.getShowtimeId());
            if (booking.getPromoId() != null) {
                psBooking.setLong(3, booking.getPromoId());
            } else {
                psBooking.setNull(3, Types.BIGINT);
            }
            psBooking.setString(4, booking.getBookingCode());
            psBooking.setBigDecimal(5, booking.getSubtotal());
            psBooking.setBigDecimal(6, booking.getDiscountAmount() != null
                    ? booking.getDiscountAmount() : BigDecimal.ZERO);
            psBooking.setBigDecimal(7, booking.getTotalAmount());
            psBooking.setString(8, booking.getStatus());
            psBooking.setString(9, booking.getNotes());
            psBooking.executeUpdate();

            rs = psBooking.getGeneratedKeys();
            if (!rs.next()) {
                throw new SQLException("Khong lay duoc generated key cua booking");
            }
            long newId = rs.getLong(1);
            booking.setBookingId(newId);

            // 2. Insert booking_seats (LOCKED)
            psSeat = conn.prepareStatement(insertSeat);
            for (Long seatId : seatIds) {
                psSeat.setLong(1, newId);
                psSeat.setLong(2, seatId);
                // unit_price = totalAmount / so luong ghe (don gian; co the tinh chi tiet hon)
                BigDecimal unitPrice = booking.getSubtotal()
                        .divide(BigDecimal.valueOf(seatIds.size()), 0, java.math.RoundingMode.HALF_UP);
                psSeat.setBigDecimal(3, unitPrice);
                psSeat.addBatch();
            }
            psSeat.executeBatch();

            conn.commit();
            booking.setSeatIds(seatIds);
            return booking;

        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Loi createBooking: " + e.getMessage(), e);
        } finally {
            closeAll(rs, psBooking, null);
            closeAll(psSeat, null);
            closeAll(null, conn);
        }
    }

    // ── findById ──────────────────────────────────────────────────────────────
    @Override
    public Booking findById(long bookingId) {
        String sql
                = "SELECT b.booking_id, b.customer_username, b.showtime_id, b.promo_id, "
                + "  b.booking_code, b.subtotal, b.discount_amount, b.total_amount, "
                + "  b.status, b.notes, b.created_at "
                + "FROM bookings b WHERE b.booking_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            if (rs.next()) {
                Booking b = mapRow(rs);
                b.setSeatIds(loadSeatIds(conn, bookingId));
                return b;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi findById booking: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    // ── findByCode ────────────────────────────────────────────────────────────
    @Override
    public Booking findByCode(String bookingCode) {
        String sql
                = "SELECT booking_id, customer_username, showtime_id, promo_id, "
                + "  booking_code, subtotal, discount_amount, total_amount, "
                + "  status, notes, created_at "
                + "FROM bookings WHERE booking_code = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, bookingCode);
            rs = ps.executeQuery();
            if (rs.next()) {
                Booking b = mapRow(rs);
                b.setSeatIds(loadSeatIds(conn, b.getBookingId()));
                return b;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi findByCode booking: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    // ── findByCustomer ────────────────────────────────────────────────────────
    @Override
    public List<Booking> findByCustomer(String customerUsername) {
        String sql
                = "SELECT booking_id, customer_username, showtime_id, promo_id, "
                + "  booking_code, subtotal, discount_amount, total_amount, "
                + "  status, notes, created_at "
                + "FROM bookings WHERE customer_username = ? "
                + "ORDER BY created_at DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Booking> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, customerUsername);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi findByCustomer booking: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    // ── updateStatus ──────────────────────────────────────────────────────────
    @Override
    public boolean updateStatus(long bookingId, String newStatus) {
        // Khi CONFIRMED: cap nhat booking_seats.lock_status -> CONFIRMED
        // Khi CANCELLED: cap nhat booking_seats.lock_status -> RELEASED
        String updateBooking = "UPDATE bookings SET status = ? WHERE booking_id = ?";
        String updateSeats;
        if (Booking.STATUS_CONFIRMED.equals(newStatus)) {
            updateSeats = "UPDATE booking_seats SET lock_status = 'CONFIRMED' WHERE booking_id = ?";
        } else if (Booking.STATUS_CANCELLED.equals(newStatus)) {
            updateSeats = "UPDATE booking_seats SET lock_status = 'RELEASED' WHERE booking_id = ?";
        } else {
            updateSeats = null;
        }

        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            ps1 = conn.prepareStatement(updateBooking);
            ps1.setString(1, newStatus);
            ps1.setLong(2, bookingId);
            int rows = ps1.executeUpdate();

            if (updateSeats != null) {
                ps2 = conn.prepareStatement(updateSeats);
                ps2.setLong(1, bookingId);
                ps2.executeUpdate();
            }

            conn.commit();
            return rows > 0;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Loi updateStatus booking: " + e.getMessage(), e);
        } finally {
            closeAll(ps1, null);
            closeAll(ps2, conn);
        }
    }

    // ── getUnavailableSeatIds ─────────────────────────────────────────────────
    @Override
    public List<Long> getUnavailableSeatIds(long showtimeId, List<Long> seatIds) {
        if (seatIds == null || seatIds.isEmpty()) {
            return new ArrayList<>();
        }

        // Build IN (?,?,...)
        StringBuilder sb = new StringBuilder(
                "SELECT DISTINCT bs.seat_id "
                + "FROM booking_seats bs "
                + "JOIN bookings b ON b.booking_id = bs.booking_id "
                + "WHERE b.showtime_id = ? "
                + "  AND bs.lock_status IN ('LOCKED','CONFIRMED') "
                + "  AND bs.seat_id IN (");
        for (int i = 0; i < seatIds.size(); i++) {
            sb.append(i > 0 ? ",?" : "?");
        }
        sb.append(")");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Long> unavailable = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sb.toString());
            ps.setLong(1, showtimeId);
            for (int i = 0; i < seatIds.size(); i++) {
                ps.setLong(i + 2, seatIds.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                unavailable.add(rs.getLong("seat_id"));
            }
            return unavailable;
        } catch (SQLException e) {
            throw new RuntimeException("Loi getUnavailableSeatIds: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    // ── releaseExpiredLocks ───────────────────────────────────────────────────
    @Override
    public int releaseExpiredLocks() {
        /*
         * Tim PENDING booking tao qua LOCK_EXPIRE_MINUTES phut:
         *   1. Cap nhat bookings.status = CANCELLED
         *   2. Cap nhat booking_seats.lock_status = RELEASED
         */
        String findExpired
                = "SELECT booking_id FROM bookings "
                + "WHERE status = 'PENDING' "
                + "  AND DATEDIFF(MINUTE, created_at, GETDATE()) >= " + LOCK_EXPIRE_MINUTES;

        String cancelBookings
                = "UPDATE bookings SET status = 'CANCELLED' "
                + "WHERE status = 'PENDING' "
                + "  AND DATEDIFF(MINUTE, created_at, GETDATE()) >= " + LOCK_EXPIRE_MINUTES;

        String releaseSeats
                = "UPDATE booking_seats SET lock_status = 'RELEASED' "
                + "WHERE lock_status = 'LOCKED' "
                + "  AND booking_id IN ("
                + "    SELECT booking_id FROM bookings "
                + "    WHERE status = 'CANCELLED' "
                + "      AND DATEDIFF(MINUTE, created_at, GETDATE()) >= " + LOCK_EXPIRE_MINUTES
                + "  )";

        Connection conn = null;
        PreparedStatement ps1 = null;
        PreparedStatement ps2 = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // Giai phong seats truoc (foreign key phu thuoc booking)
            ps2 = conn.prepareStatement(releaseSeats);
            ps2.executeUpdate();

            ps1 = conn.prepareStatement(cancelBookings);
            int affected = ps1.executeUpdate();

            conn.commit();
            return affected;
        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Loi releaseExpiredLocks: " + e.getMessage(), e);
        } finally {
            closeAll(ps1, null);
            closeAll(ps2, conn);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private Booking mapRow(ResultSet rs) throws SQLException {
        Booking b = new Booking();
        b.setBookingId(rs.getLong("booking_id"));
        b.setCustomerUsername(rs.getString("customer_username"));
        b.setShowtimeId(rs.getLong("showtime_id"));
        long promoId = rs.getLong("promo_id");
        b.setPromoId(rs.wasNull() ? null : promoId);
        b.setBookingCode(rs.getString("booking_code"));
        b.setSubtotal(rs.getBigDecimal("subtotal"));
        b.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        b.setTotalAmount(rs.getBigDecimal("total_amount"));
        b.setStatus(rs.getString("status"));
        b.setNotes(rs.getString("notes"));
        Timestamp ts = rs.getTimestamp("created_at");
        b.setCreatedAt(ts != null ? ts.toLocalDateTime() : null);
        return b;
    }

    private List<Long> loadSeatIds(Connection conn, long bookingId) throws SQLException {
        String sql = "SELECT seat_id FROM booking_seats WHERE booking_id = ?";
        List<Long> ids = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getLong("seat_id"));
                }
            }
        }
        return ids;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }
}
