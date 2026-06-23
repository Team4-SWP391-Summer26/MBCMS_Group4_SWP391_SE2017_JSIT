package com.mbcms.dao.impl;

import com.mbcms.dao.SeatDAO;
import com.mbcms.model.Seat;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class SeatDAOImpl extends BaseDAO implements SeatDAO {

    @Override
    public List<Seat> findByRoom(long roomId) {
        List<Seat> seats = new ArrayList<>();

        String sql = "SELECT seat_id, room_id, row_label, col_number, seat_type, active "
                + "FROM dbo.seats "
                + "WHERE room_id = ? "
                + "ORDER BY row_label ASC, col_number ASC";

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
        // CONFIRMED/USED: always booked; PENDING: only if not yet expired (< 10 min)
        String sql = "SELECT bs.seat_id "
                + "  FROM dbo.booking_seats bs "
                + "  JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + " WHERE b.showtime_id = ? "
                + "   AND b.[status] IN ('PENDING', 'CONFIRMED', 'USED') "
                + "   AND (b.[status] != 'PENDING' "
                + "        OR DATEDIFF(MINUTE, b.created_at, SYSUTCDATETIME()) < 10)";

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
        if (seats == null || seats.isEmpty()) {
            return true;
        }

        String sql = "INSERT INTO dbo.seats "
                + "(room_id, row_label, col_number, seat_type, active) "
                + "VALUES (?, ?, ?, ?, ?)";

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
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                }
            }

            throw new RuntimeException("Error inserting seats in batch: " + e.getMessage(), e);

        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ex) {
                }
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
        String sql = "SELECT COUNT(*) "
                + "FROM dbo.booking_seats bs "
                + "JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id "
                + "WHERE bs.seat_id = ? "
                + "AND st.start_time >= SYSUTCDATETIME() "
                + "AND b.[status] IN ('PENDING', 'CONFIRMED')";

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

    @Override
    public List<Long> checkAndLockSeats(long showtimeId,
            List<Long> seatIds,
            Connection conn) throws SQLException {

        String template
                = "SELECT bs.seat_id "
                + "FROM dbo.booking_seats bs WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + "WHERE b.showtime_id = ? "
                + "AND b.[status] != 'CANCELLED' "
                + "AND ("
                + " b.[status] IN ('CONFIRMED','USED') "
                + " OR (b.[status] = 'PENDING' "
                + " AND DATEDIFF(MINUTE,b.created_at,SYSUTCDATETIME()) < 10)"
                + ") "
                + "AND bs.seat_id IN (%s)";

        String inClause = String.join(",",
                Collections.nCopies(seatIds.size(), "?"));

        String sql = String.format(template, inClause);

        List<Long> conflict = new ArrayList<>();

        try (PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, showtimeId);

            for (int i = 0; i < seatIds.size(); i++) {
                ps.setLong(i + 2, seatIds.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    conflict.add(rs.getLong("seat_id"));
                }
            }
        }

        return conflict;
    }

    @Override
    public int updateSeatTypes(long roomId, Map<Long, String> seatTypes) {

        String sql = "UPDATE dbo.seats "
                + "SET seat_type = ? "
                + "WHERE seat_id = ? AND room_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(sql);

            for (Map.Entry<Long, String> e : seatTypes.entrySet()) {
                ps.setString(1, e.getValue());
                ps.setLong(2, e.getKey());
                ps.setLong(3, roomId);
                ps.addBatch();
            }

            int[] results = ps.executeBatch();
            conn.commit();

            int affected = 0;

            for (int r : results) {
                affected += (r > 0 || r == PreparedStatement.SUCCESS_NO_INFO)
                        ? 1 : 0;
            }

            return affected;

        } catch (SQLException e) {
            rollbackQuietly(conn);
            throw new RuntimeException("Loi cap nhat seats.updateSeatTypes: "
                    + e.getMessage(), e);

        } finally {
            restoreAutoCommitQuietly(conn);
            closeAll(ps, conn);
        }
    }

    @Override
    public List<String> findLabelsBySeatIds(List<Long> seatIds) {

        if (seatIds == null || seatIds.isEmpty()) {
            return Collections.emptyList();
        }

        StringBuilder placeholders = new StringBuilder();

        for (int i = 0; i < seatIds.size(); i++) {
            if (i > 0) {
                placeholders.append(",");
            }
            placeholders.append("?");
        }

        String sql = "SELECT row_label, col_number "
                + "FROM dbo.seats "
                + "WHERE seat_id IN (" + placeholders + ") "
                + "ORDER BY row_label, col_number";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);

            for (int i = 0; i < seatIds.size(); i++) {
                ps.setLong(i + 1, seatIds.get(i));
            }

            rs = ps.executeQuery();

            List<String> labels = new ArrayList<>();

            while (rs.next()) {
                labels.add(
                        rs.getString("row_label")
                        + rs.getInt("col_number")
                );
            }

            return labels;

        } catch (SQLException e) {
            throw new RuntimeException("findLabelsBySeatIds lỗi: "
                    + e.getMessage(), e);

        } finally {
            closeAll(rs, ps, conn);
        }
    }

    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException e) {
                System.err.println("Loi rollback seats: " + e.getMessage());
            }
        }
    }

    private void restoreAutoCommitQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("Loi restore autocommit: " + e.getMessage());
            }
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