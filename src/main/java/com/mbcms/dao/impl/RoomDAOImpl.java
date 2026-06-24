package com.mbcms.dao.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.model.Room;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RoomDAOImpl extends BaseDAO implements RoomDAO {

    private static final String BASE_SELECT
            = "SELECT room_id, branch_id, name, capacity, room_type, active FROM rooms ";

    @Override
    public List<Room> findActiveByBranch(long branchId) {
        String sql = BASE_SELECT + "WHERE branch_id = ? AND active = 1 ORDER BY name";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            List<Room> rooms = new ArrayList<>();
            while (rs.next()) {
                rooms.add(mapRow(rs));
            }
            return rooms;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van rooms.findActiveByBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Room findById(long roomId) {
        String sql = BASE_SELECT + "WHERE room_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, roomId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van rooms.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public List<Room> findAllByBranch(long branchId, boolean includeInactive) {
        List<Room> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE branch_id = ? ";
        if (!includeInactive) {
            sql += "AND active = 1 ";
        }
        sql += "ORDER BY name ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van rooms.findAllByBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public List<Room> findAll(boolean includeInactive) {
        List<Room> list = new ArrayList<>();
        String sql = BASE_SELECT;
        if (!includeInactive) {
            sql += "WHERE active = 1 ";
        }
        sql += "ORDER BY branch_id ASC, name ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van rooms.findAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public boolean insert(Room room) {
        String sql = "INSERT INTO rooms (branch_id, name, capacity, room_type, active) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, room.getBranchId());
            ps.setString(2, room.getName());
            ps.setInt(3, room.getCapacity());
            ps.setString(4, room.getRoomType());
            ps.setBoolean(5, room.isActive());

            int affected = ps.executeUpdate();
            if (affected == 1) {
                rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    room.setRoomId(rs.getLong(1));
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Loi insert rooms: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean update(Room room) {
        String sql = "UPDATE rooms SET name = ?, capacity = ?, room_type = ? WHERE room_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, room.getName());
            ps.setInt(2, room.getCapacity());
            ps.setString(3, room.getRoomType());
            ps.setLong(4, room.getRoomId());

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi update rooms: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateStatus(long roomId, boolean active) {
        String sql = "UPDATE rooms SET active = ? WHERE room_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setLong(2, roomId);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateStatus rooms: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean hasFutureShowtimes(long roomId) {
        String sql = "SELECT COUNT(*) FROM showtimes WHERE room_id = ? AND start_time >= GETDATE() AND status <> 'CANCELLED'";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, roomId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Loi kiem tra future showtimes: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    private Room mapRow(ResultSet rs) throws SQLException {
        Room r = new Room();
        r.setRoomId(rs.getLong("room_id"));
        r.setBranchId(rs.getLong("branch_id"));
        r.setName(rs.getString("name"));
        r.setCapacity(rs.getInt("capacity"));
        r.setRoomType(rs.getString("room_type"));
        r.setActive(rs.getBoolean("active"));
        return r;
    }

    @Override
    public boolean insertWithSeats(Room room, List<com.mbcms.model.Seat> seats) {
        String insertRoom = "INSERT INTO rooms (branch_id, name, capacity, room_type, active) VALUES (?, ?, ?, ?, ?)";
        String insertSeat = "INSERT INTO seats (room_id, row_label, col_number, seat_type, active) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement psRoom = null;
        PreparedStatement psSeat = null;
        ResultSet keys = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            psRoom = conn.prepareStatement(insertRoom, Statement.RETURN_GENERATED_KEYS);
            psRoom.setLong(1, room.getBranchId());
            psRoom.setString(2, room.getName());
            psRoom.setInt(3, room.getCapacity());
            psRoom.setString(4, room.getRoomType());
            psRoom.setBoolean(5, room.isActive());
            if (psRoom.executeUpdate() != 1) {
                conn.rollback();
                return false;
            }
            keys = psRoom.getGeneratedKeys();
            if (!keys.next()) {
                conn.rollback();
                return false;
            }
            long roomId = keys.getLong(1);
            room.setRoomId(roomId);
            keys.close();
            psRoom.close();

            psSeat = conn.prepareStatement(insertSeat);
            for (com.mbcms.model.Seat seat : seats) {
                seat.setRoomId(roomId);
                psSeat.setLong(1, roomId);
                psSeat.setString(2, seat.getRowLabel());
                psSeat.setInt(3, seat.getColNumber());
                psSeat.setString(4, seat.getSeatType());
                psSeat.setBoolean(5, seat.isActive());
                psSeat.addBatch();
            }
            psSeat.executeBatch();
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            throw new RuntimeException("Loi insertWithSeats: " + e.getMessage(), e);
        } finally {
            closeAll(keys, psSeat, conn);
        }
    }

    @Override
    public boolean replaceSeatsAndUpdateRoom(Room room, List<com.mbcms.model.Seat> seats) {
        String updateRoom = "UPDATE rooms SET name = ?, capacity = ?, room_type = ? WHERE room_id = ?";
        String deleteSeats = "DELETE FROM dbo.seats WHERE room_id = ?";
        String insertSeat = "INSERT INTO seats (room_id, row_label, col_number, seat_type, active) VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            ps = conn.prepareStatement(deleteSeats);
            ps.setLong(1, room.getRoomId());
            ps.executeUpdate();
            ps.close();

            ps = conn.prepareStatement(insertSeat);
            for (com.mbcms.model.Seat seat : seats) {
                ps.setLong(1, room.getRoomId());
                ps.setString(2, seat.getRowLabel());
                ps.setInt(3, seat.getColNumber());
                ps.setString(4, seat.getSeatType());
                ps.setBoolean(5, seat.isActive());
                ps.addBatch();
            }
            ps.executeBatch();
            ps.close();

            ps = conn.prepareStatement(updateRoom);
            ps.setString(1, room.getName());
            ps.setInt(2, room.getCapacity());
            ps.setString(3, room.getRoomType());
            ps.setLong(4, room.getRoomId());
            if (ps.executeUpdate() != 1) {
                conn.rollback();
                return false;
            }
            ps.close();

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            throw new RuntimeException("Loi replaceSeatsAndUpdateRoom: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {
                }
            }
            closeAll(ps, conn);
        }
    }
}
