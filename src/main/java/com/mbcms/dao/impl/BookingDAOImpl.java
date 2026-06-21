package com.mbcms.dao.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.exception.SeatUnavailableException;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

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

    // ── createBooking ─────────────────────────────────────────────────────────
    @Override
    public Booking createBooking(Booking booking, List<Long> seatIds) {
        booking.setBookingCode("BK-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase());
        booking.setStatus(Booking.STATUS_PENDING);

        // ── Build IN placeholders ──────────────────────────────────────────
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < seatIds.size(); i++) {
            if (i>0){
                placeholders.append(",?");
            }else{
                placeholders.append("?");
            }
            
        }

        // ── SQL ───────────────────────────────────────────────────────────
        String checkSql
                = "SELECT bs.seat_id "
                + "FROM dbo.booking_seats bs WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + "WHERE b.showtime_id = ? "
                + "  AND b.[status] != 'CANCELLED' "
                + "  AND ( "
                + "    b.[status] IN ('CONFIRMED','USED') "
                + "    OR (b.[status] = 'PENDING' "
                + "        AND DATEDIFF(MINUTE, b.created_at, SYSUTCDATETIME()) < 10) "
                + "  ) "
                + "  AND bs.seat_id IN (" + placeholders + ")";

        String insertBooking
                = "INSERT INTO dbo.bookings "
                + "  (customer_username, showtime_id, promo_id, booking_code, "
                + "   subtotal, discount_amount, total_amount, [status], notes) "
                + "VALUES (?,?,?,?,?,?,?,?,?)";

        String insertSeat
                = "INSERT INTO dbo.booking_seats (booking_id, seat_id) VALUES (?,?)";

        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psBooking = null;
        PreparedStatement psSeat = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // ── Bước 1: CHECK + LOCK (UPDLOCK + HOLDLOCK) ─────────────────
            psCheck = conn.prepareStatement(checkSql);
            psCheck.setLong(1, booking.getShowtimeId());
            for (int i = 0; i < seatIds.size(); i++) {
                psCheck.setLong(i + 2, seatIds.get(i));
            }
            rs = psCheck.executeQuery();

            // Nếu query trả về bất kỳ row nào → ghế đã bị chiếm
            List<Long> conflictIds = new ArrayList<>();
            while (rs.next()) {
                conflictIds.add(rs.getLong("seat_id"));
            }

            if (!conflictIds.isEmpty()) {
                conn.rollback(); // release lock ngay
                throw new SeatUnavailableException(conflictIds);
            }

            // ── Bước 2: INSERT bookings ────────────────────────────────────
            // (vẫn trong transaction đang giữ UPDLOCK)
            psBooking = conn.prepareStatement(insertBooking, Statement.RETURN_GENERATED_KEYS);
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
                throw new SQLException("Không lấy được generated key");
            }
            long newId = rs.getLong(1);
            booking.setBookingId(newId);

            // ── Bước 3: INSERT booking_seats ──────────────────────────────
            psSeat = conn.prepareStatement(insertSeat);
            for (Long seatId : seatIds) {
                psSeat.setLong(1, newId);
                psSeat.setLong(2, seatId);
                psSeat.addBatch();
            }
            psSeat.executeBatch();

            conn.commit(); // release UPDLOCK
            booking.setSeatIds(seatIds);
            return booking;

        } catch (SeatUnavailableException e) {
            throw e; // đã rollback rồi, ném thẳng lên Service
        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Lỗi createBooking: " + e.getMessage(), e);

        } finally {
            closeAll(rs, psCheck, null);
            closeAll(psBooking, null);
            closeAll(psSeat, conn);
        }
    }

    // ── findById / findByIdWithSeats ──────────────────────────────────────
 
    @Override
    public Booking findById(long bookingId) {
        String sql = "SELECT * FROM dbo.bookings WHERE booking_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } catch (SQLException e) {
            throw new RuntimeException("findById lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
 
    @Override
    public Booking findByIdWithSeats(long bookingId) {
        Booking b = findById(bookingId);
        if (b != null) b.setSeatIds(loadSeatIds(bookingId));
        return b;
    }

    // ── findTicket (view-model day du cho e-ticket) ───────────────────────

    /** SELECT chung cho BookingTicket (JOIN showtimes+movies+rooms+branches+customers). */
    private static final String TICKET_SELECT =
            "SELECT b.booking_id, b.booking_code, b.[status], b.subtotal, " +
            "       b.discount_amount, b.total_amount, b.created_at, " +
            "       m.title AS movie_title, m.rated, m.duration_min, m.poster_url, " +
            "       st.start_time, st.format, st.subtitle_type, " +
            "       br.name AS branch_name, r.name AS room_name, " +
            "       c.full_name, c.email " +
            "FROM dbo.bookings b " +
            "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id " +
            "JOIN dbo.movies    m  ON m.movie_id     = st.movie_id " +
            "JOIN dbo.rooms     r  ON r.room_id      = st.room_id " +
            "JOIN dbo.branches  br ON br.branch_id   = r.branch_id " +
            "JOIN dbo.customers c  ON c.username     = b.customer_username ";

    @Override
    public BookingTicket findTicket(long bookingId) {
        String sql = TICKET_SELECT + "WHERE b.booking_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            if (!rs.next()) return null;
            BookingTicket t = mapTicket(rs);
            t.setSeatLabels(loadSeatLabels(bookingId));
            return t;
        } catch (SQLException e) {
            throw new RuntimeException("findTicket lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public List<BookingTicket> findTicketsByCustomer(String customerUsername) {
        String sql = TICKET_SELECT +
                "WHERE b.customer_username = ? ORDER BY st.start_time DESC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, customerUsername);
            rs = ps.executeQuery();
            List<BookingTicket> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapTicket(rs));
            }
            // Nap nhan ghe cho tung ve (sau khi dong rs chinh)
            for (BookingTicket t : list) {
                t.setSeatLabels(loadSeatLabels(t.getBookingId()));
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("findTicketsByCustomer lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /** Map 1 row tu TICKET_SELECT -> BookingTicket (chua gom seat labels). */
    private BookingTicket mapTicket(ResultSet rs) throws SQLException {
        BookingTicket t = new BookingTicket();
        t.setBookingId(rs.getLong("booking_id"));
        t.setBookingCode(rs.getString("booking_code"));
        t.setStatus(rs.getString("status"));
        t.setSubtotal(rs.getBigDecimal("subtotal"));
        t.setDiscountAmount(rs.getBigDecimal("discount_amount"));
        t.setTotalAmount(rs.getBigDecimal("total_amount"));
        Timestamp created = rs.getTimestamp("created_at");
        t.setCreatedAt(created != null ? created.toLocalDateTime() : null);

        t.setMovieTitle(rs.getString("movie_title"));
        t.setMovieRated(rs.getString("rated"));
        t.setDurationMin(rs.getInt("duration_min"));
        t.setPosterUrl(rs.getString("poster_url"));

        Timestamp start = rs.getTimestamp("start_time");
        t.setStartTime(start != null ? start.toLocalDateTime() : null);
        t.setFormat(rs.getString("format"));
        t.setSubtitleType(rs.getString("subtitle_type"));
        t.setBranchName(rs.getString("branch_name"));
        t.setRoomName(rs.getString("room_name"));

        t.setCustomerFullName(rs.getString("full_name"));
        t.setCustomerEmail(rs.getString("email"));
        return t;
    }

    /** Nhan ghe dang "C5" = row_label + col_number, sap xep theo vi tri. */
    private List<String> loadSeatLabels(long bookingId) {
        String sql =
            "SELECT s.row_label, s.col_number " +
            "FROM dbo.booking_seats bs " +
            "JOIN dbo.seats s ON s.seat_id = bs.seat_id " +
            "WHERE bs.booking_id = ? " +
            "ORDER BY s.row_label, s.col_number";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            List<String> labels = new ArrayList<>();
            while (rs.next()) {
                labels.add(rs.getString("row_label") + rs.getInt("col_number"));
            }
            return labels;
        } catch (SQLException e) {
            throw new RuntimeException("loadSeatLabels lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
 
    @Override
    public Booking findByCode(String bookingCode) {
        String sql = "SELECT * FROM dbo.bookings WHERE booking_code = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, bookingCode);
            rs = ps.executeQuery();
            if (rs.next()) {
                Booking b = mapRow(rs);
                b.setSeatIds(loadSeatIds(b.getBookingId()));
                return b;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("findByCode lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
 
    @Override
    public List<Booking> findByCustomer(String customerUsername) {
        String sql = "SELECT * FROM dbo.bookings " +
                     "WHERE customer_username = ? ORDER BY created_at DESC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, customerUsername);
            rs = ps.executeQuery();
            List<Booking> list = new ArrayList<>();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("findByCustomer lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
    
    

    // ── updateStatus ──────────────────────────────────────────────────────────
    @Override
    public boolean updateStatus(long bookingId, String newStatus) {
        // Chỉ UPDATE bookings — không động tới booking_seats
        String sql = "UPDATE dbo.bookings SET [status] = ? WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setLong(2, bookingId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateStatus booking: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public int confirmBooking(long bookingId, String customerUsername) {
        // Chỉ confirm khi PENDING và chưa hết hạn
        String sql =
            "UPDATE dbo.bookings SET [status] = 'CONFIRMED' " +
            "WHERE booking_id = ? AND customer_username = ? " +
            "  AND [status] = 'PENDING' AND DATEADD(MINUTE, 10, created_at) > SYSUTCDATETIME()";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            ps.setString(2, customerUsername);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("confirmBooking lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    // ── confirmBooking (connection-aware, dung trong transaction payment) ──
    @Override
    public int confirmBooking(Connection conn, long bookingId, String customerUsername) {
        // Cung dieu kien voi overload tu mo connection, nhung dung conn truyen
        // vao tu PaymentService de atomic voi payments. KHONG commit/close conn.
        String sql =
            "UPDATE dbo.bookings SET [status] = 'CONFIRMED' " +
            "WHERE booking_id = ? AND customer_username = ? " +
            "  AND [status] = 'PENDING' AND DATEADD(MINUTE, 10, created_at) > SYSUTCDATETIME()";
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            ps.setString(2, customerUsername);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("confirmBooking(conn) lỗi: " + e.getMessage(), e);
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException ignored) {}
            }
        }
    }

    // ── cancelBooking ─────────────────────────────────────────────────────
 
    @Override
    public int cancelBooking(long bookingId, String customerUsername) {
        String sql =
            "UPDATE dbo.bookings SET [status] = 'CANCELLED' " +
            "WHERE booking_id = ? AND customer_username = ? AND [status] = 'PENDING'";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            ps.setString(2, customerUsername);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("cancelBooking lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

// ── releaseExpiredLocks ───────────────────────────────────────────────────
    @Override
    public int releaseExpiredLocks() {
        // Chỉ CANCEL booking hết hạn — không cần UPDATE booking_seats
        // getUnavailableSeatIds tự loại PENDING cũ khi query theo thời gian
        String sql
                = "UPDATE dbo.bookings SET [status] = 'CANCELLED' "
                + "WHERE [status] = 'PENDING' "
                + "  AND DATEDIFF(MINUTE, created_at, SYSUTCDATETIME()) >= 10";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Loi releaseExpiredLocks: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
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

    // ── Private helpers ───────────────────────────────────────────────────
 
    private String generateCode() {
        return "BK-" + UUID.randomUUID().toString().substring(0, 6).toUpperCase();
    }
 
    private List<Long> loadSeatIds(long bookingId) {
        String sql = "SELECT seat_id FROM dbo.booking_seats " +
                     "WHERE booking_id = ? ORDER BY seat_id";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            List<Long> ids = new ArrayList<>();
            while (rs.next()) ids.add(rs.getLong("seat_id"));
            return ids;
        } catch (SQLException e) {
            throw new RuntimeException("loadSeatIds lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
            }
        }
    }

    private void restoreAndClose(Connection conn) {
        if (conn != null) {
            try { conn.setAutoCommit(true); } catch (SQLException ignored) {}
            closeAll((PreparedStatement) null, conn);
        }
    }
}
