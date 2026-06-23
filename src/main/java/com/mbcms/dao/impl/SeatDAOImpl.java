package com.mbcms.dao.impl;

import com.mbcms.dao.SeatDAO;
import com.mbcms.model.Seat;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class SeatDAOImpl extends BaseDAO implements SeatDAO {

    @Override
    public List<Seat> findByRoom(long roomId) {
        List<Seat> seats = new ArrayList<>();
        String sql = "SELECT seat_id, room_id, row_label, col_number, seat_type, active "
                + "  FROM dbo.seats "
                + " WHERE room_id = ? "
                + " ORDER BY row_label ASC, col_number ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, roomId);
            rs = ps.executeQuery();

            while (rs.next()) {
                seats.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error querying seat.findByRoom: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return seats;
    }

    @Override
    public Set<Long> findBookedSeatIds(long showtimeId) {
        Set<Long> booked = new HashSet<>();
        String sql = "SELECT bs.seat_id " +
            "  FROM dbo.booking_seats bs " +
            "  JOIN dbo.bookings b ON b.booking_id = bs.booking_id " +
            " WHERE b.showtime_id = ? " +
            "   AND b.[status] IN ('PENDING', 'CONFIRMED')";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            rs = ps.executeQuery();

            while (rs.next()) {
                booked.add(rs.getLong("seat_id"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error querying seat.findBookedSeatIds: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return booked;
    }

    @Override
    public boolean insertSeats(List<Seat> seats) {
        if (seats == null || seats.isEmpty()) return true;
        String sql = "INSERT INTO dbo.seats (room_id, row_label, col_number, seat_type, active) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            ps = conn.prepareStatement(sql);

            for (Seat seat : seats) {
                ps.setLong(1, seat.getRoomId());
                ps.setString(2, seat.getRowLabel());
                ps.setInt(3, seat.getColNumber());
                ps.setString(4, seat.getSeatType());
                ps.setBoolean(5, seat.isActive());
                ps.addBatch();
            }

            ps.executeBatch();
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { /* ignored */ }
            }
            throw new RuntimeException("Error inserting seats in batch: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException ex) { /* ignored */ }
            }
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean deleteSeatsByRoom(long roomId) {
        String sql = "DELETE FROM dbo.seats WHERE room_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, roomId);

            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            throw new RuntimeException("Error deleting seats by room: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateSeatStatus(long seatId, boolean active) {
        String sql = "UPDATE dbo.seats SET active = ? WHERE seat_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setLong(2, seatId);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Error updating seat status: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateSeatType(long seatId, String seatType) {
        String sql = "UPDATE dbo.seats SET seat_type = ? WHERE seat_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, seatType);
            ps.setLong(2, seatId);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Error updating seat type: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean hasFutureBookings(long seatId) {
        String sql = "SELECT COUNT(*) FROM dbo.booking_seats bs "
                + "  JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + "  JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id "
                + " WHERE bs.seat_id = ? "
                + "   AND st.start_time >= SYSUTCDATETIME() "
                + "   AND b.[status] IN ('PENDING', 'CONFIRMED')";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, seatId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Error checking future bookings for seat: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    private Seat mapRow(ResultSet rs) throws SQLException {
        Seat s = new Seat();
        s.setSeatId(rs.getLong("seat_id"));
        s.setRoomId(rs.getLong("room_id"));
        s.setRowLabel(rs.getString("row_label"));
        s.setColNumber(rs.getInt("col_number"));
        s.setSeatType(rs.getString("seat_type"));
        s.setActive(rs.getBoolean("active"));
        return s;
    }
}
