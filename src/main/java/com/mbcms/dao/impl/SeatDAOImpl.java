/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
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
import java.util.Set;

/**
 *
 * @author Lenovo
 */
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

            //tap hop ghe cua mot phong
            while (rs.next()) {
                seats.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error querying seat.findByRoom: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        //tra tat ca ghe thay vi mot doi tuong
        return seats;
    }

    @Override
    public Set<Long> findBookedSeatIds(long showtimeId) {
        Set<Long> booked = new HashSet<>();
        String sql = "SELECT bs.seat_id "
                + "  FROM dbo.booking_seats bs "
                + "  JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + " WHERE b.showtime_id = ? "
                + "   AND b.[status] IN ('PENDING', 'CONFIRMED')";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            rs = ps.executeQuery();

            //tap hop ghe da duoc chon cua mot phong
            while (rs.next()) {
                booked.add(rs.getLong("seat_id"));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error querying seat.findByRoom: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        //tra tat ca ghe thay vi mot doi tuong
        return booked;
    }

    // ── checkAndLockSeats ─────────────────────────────────────────────────
    /**
     * Dùng UPDLOCK + HOLDLOCK trong transaction đang mở của
     * createBooking.Thread khác sẽ bị block ở đây cho đến khi transaction
     * commit/rollback.Trả về list seatId bị chiếm (rỗng = tất cả còn trống →
     * tiếp tục INSERT).
     *
     * @param showtimeId
     * @param seatIds
     * @return
     */
    @Override
    public List<Long> checkAndLockSeats(long showtimeId, List<Long> seatIds,
            Connection conn) throws SQLException {
        String SQL_CHECK_LOCK_TEMPLATE
                = "SELECT bs.seat_id "
                + "FROM dbo.booking_seats bs WITH (UPDLOCK, HOLDLOCK) "
                + "JOIN dbo.bookings b ON b.booking_id = bs.booking_id "
                + "WHERE b.showtime_id = ? "
                + "  AND b.[status] != 'CANCELLED' "
                + "  AND ( "
                + "    b.[status] IN ('CONFIRMED', 'USED') "
                + "    OR ( "
                + "      b.[status] = 'PENDING' "
                + "      AND DATEDIFF(MINUTE, b.created_at, SYSUTCDATETIME()) < 10 "
                + "    ) "
                + "  ) "
                + "  AND bs.seat_id IN (%s)";
        String inClause = String.join(",", Collections.nCopies(seatIds.size(), "?"));
        String sql = String.format(SQL_CHECK_LOCK_TEMPLATE, inClause);

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

    /**
     * Chuyen du lieu tu ResultSet thanh object Seat.
     */
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
