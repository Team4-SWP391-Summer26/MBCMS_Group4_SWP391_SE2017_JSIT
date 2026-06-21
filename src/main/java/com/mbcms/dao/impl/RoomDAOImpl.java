package com.mbcms.dao.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.model.Room;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
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
}
