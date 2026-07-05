package com.mbcms.dao.impl;

import com.mbcms.dao.BranchDAO;
import com.mbcms.model.Branch;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Time;
import java.sql.Timestamp;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class BranchDAOImpl extends BaseDAO implements BranchDAO {

    public List<Branch> findAll() {
        String sql = "SELECT branch_id, name, address, city, phone, email, active, created_at, opening_time, closing_time "
                + "FROM branches ORDER BY name";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            List<Branch> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapRowBasic(rs));  // only 7 base columns, no created_at
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van branches.findAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Branch findById(long branchId) {
        String sql = "SELECT branch_id, name, address, city, phone, email, active, created_at, opening_time, closing_time "
                + "FROM branches WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van branches.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
    
    @Override
    public List<Branch> findAllActive() {
        String sql = "SELECT branch_id, name, address, city, phone, email, active, created_at, opening_time, closing_time "
                + "FROM branches WHERE active = 1 ORDER BY name";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            List<Branch> branches = new ArrayList<>();
            while (rs.next()) {
                branches.add(mapRowBasic(rs));  // only 7 base columns, no created_at
            }
            return branches;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van branches.findAllActive: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public List<Branch> findAll(boolean includeInactive) {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT branch_id, name, address, city, phone, email, active, created_at, opening_time, closing_time "
                + "FROM branches ";
        if (!includeInactive) {
            sql += "WHERE active = 1 ";
        }
        sql += "ORDER BY name ASC";

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
            throw new RuntimeException("Loi truy van branches.findAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public boolean insert(Branch branch) {
        String sql = "INSERT INTO branches (name, address, city, phone, email, active, created_at, opening_time, closing_time) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, branch.getName());
            ps.setString(2, branch.getAddress());
            ps.setString(3, branch.getCity());
            ps.setString(4, branch.getPhone());
            ps.setString(5, branch.getEmail());
            ps.setBoolean(6, branch.isActive());
            ps.setTimestamp(7, branch.getCreatedAt() != null ? Timestamp.valueOf(branch.getCreatedAt()) : Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setTime(8, branch.getOpeningTime() != null ? Time.valueOf(branch.getOpeningTime()) : null);
            ps.setTime(9, branch.getClosingTime() != null ? Time.valueOf(branch.getClosingTime()) : null);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi insert branches: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean update(Branch branch) {
        String sql = "UPDATE branches SET name = ?, address = ?, city = ?, phone = ?, email = ?, active = ?, opening_time = ?, closing_time = ? "
                + "WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, branch.getName());
            ps.setString(2, branch.getAddress());
            ps.setString(3, branch.getCity());
            ps.setString(4, branch.getPhone());
            ps.setString(5, branch.getEmail());
            ps.setBoolean(6, branch.isActive());
            ps.setTime(7, branch.getOpeningTime() != null ? Time.valueOf(branch.getOpeningTime()) : null);
            ps.setTime(8, branch.getClosingTime() != null ? Time.valueOf(branch.getClosingTime()) : null);
            ps.setLong(9, branch.getBranchId());

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi update branches: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateStatus(long branchId, boolean active) {
        String sql = "UPDATE branches SET active = ? WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setLong(2, branchId);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateStatus branches: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateOperatingHours(long branchId, LocalTime openingTime, LocalTime closingTime) {
        String sql = "UPDATE branches SET opening_time = ?, closing_time = ? WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setTime(1, openingTime != null ? Time.valueOf(openingTime) : null);
            ps.setTime(2, closingTime != null ? Time.valueOf(closingTime) : null);
            ps.setLong(3, branchId);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateOperatingHours branches: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    /**
     * Map only the 7 base columns that every SELECT includes.
     * Use this when the query does NOT select created_at / opening_time / closing_time.
     */
    private Branch mapRowBasic(ResultSet rs) throws SQLException {
        Branch b = new Branch();
        b.setBranchId(rs.getLong("branch_id"));
        b.setName(rs.getString("name"));
        b.setAddress(rs.getString("address"));
        b.setCity(rs.getString("city"));
        b.setPhone(rs.getString("phone"));
        b.setEmail(rs.getString("email"));
        b.setActive(rs.getBoolean("active"));
        return b;
    }

    /**
     * Map all columns including created_at, opening_time, closing_time.
     * Use only when the query explicitly SELECTs those columns.
     */
    private Branch mapRow(ResultSet rs) throws SQLException {
        Branch b = mapRowBasic(rs);

        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            b.setCreatedAt(ts.toLocalDateTime());
        }

        Time open = rs.getTime("opening_time");
        if (open != null) {
            b.setOpeningTime(open.toLocalTime());
        }

        Time close = rs.getTime("closing_time");
        if (close != null) {
            b.setClosingTime(close.toLocalTime());
        }

        return b;
    }

    @Override
    public List<Branch> findAllWithStats(boolean includeInactive) {
        List<Branch> list = new ArrayList<>();
        String sql = "SELECT "
                + "    b.branch_id, b.name, b.address, b.city, b.phone, b.email, b.active, b.created_at, b.opening_time, b.closing_time, "
                + "    (SELECT COUNT(*) FROM rooms r WHERE r.branch_id = b.branch_id AND r.active = 1) AS rooms_count, "
                + "    (SELECT COUNT(*) FROM seats s JOIN rooms r ON s.room_id = r.room_id WHERE r.branch_id = b.branch_id AND r.active = 1 AND s.active = 1) AS seats_count, "
                + "    (SELECT COUNT(*) FROM showtimes st JOIN rooms r ON st.room_id = r.room_id WHERE r.branch_id = b.branch_id AND CAST(st.start_time AS DATE) = CAST(GETDATE() AS DATE)) AS today_showtimes, "
                + "    (SELECT COALESCE(SUM(bk.total_amount), 0) FROM bookings bk JOIN showtimes st ON bk.showtime_id = st.showtime_id JOIN rooms r ON st.room_id = r.room_id WHERE r.branch_id = b.branch_id AND bk.status IN ('CONFIRMED', 'USED') "
                + "AND bk.created_at >= DATEADD(HOUR, -7, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) "
                + "AND bk.created_at < DATEADD(HOUR, -7, DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 1, GETDATE())), 0))) AS monthly_revenue, "
                + "    (SELECT TOP 1 full_name FROM employees WHERE branch_id = b.branch_id AND role = 'BRANCH_MANAGER' AND active = 1) AS manager_name "
                + "FROM branches b ";
        if (!includeInactive) {
            sql += "WHERE b.active = 1 ";
        }
        sql += "ORDER BY b.name ASC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Branch b = mapRow(rs);
                b.setRoomsCount(rs.getInt("rooms_count"));
                b.setSeatsCount(rs.getInt("seats_count"));
                b.setTodayShowtimes(rs.getInt("today_showtimes"));
                b.setMonthlyRevenue(rs.getDouble("monthly_revenue"));
                
                String manager = rs.getString("manager_name");
                b.setManagerName(rs.wasNull() ? null : manager);
                
                list.add(b);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in BranchDAO.findAllWithStats: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public boolean hasFutureShowtimes(long branchId) {
        String sql = "SELECT COUNT(*) FROM dbo.showtimes st "
                + "JOIN dbo.rooms r ON r.room_id = st.room_id "
                + "WHERE r.branch_id = ? AND st.start_time >= GETDATE() "
                + "AND st.status <> 'CANCELLED'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Loi hasFutureShowtimes branch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean hasActiveFutureBookings(long branchId) {
        String sql = "SELECT COUNT(*) FROM dbo.bookings b "
                + "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id "
                + "JOIN dbo.rooms r ON r.room_id = st.room_id "
                + "WHERE r.branch_id = ? AND st.start_time >= GETDATE()"
                + "AND b.status IN ('PENDING','CONFIRMED') "
                + "AND (b.status != 'PENDING' "
                + "     OR DATEDIFF(MINUTE, b.created_at, SYSUTCDATETIME()) < 10)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Loi hasActiveFutureBookings branch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean saveBranchDetails(Branch branch, LocalTime openingTime, LocalTime closingTime, boolean active) {
        String sql = "UPDATE branches SET name = ?, address = ?, city = ?, phone = ?, email = ?, "
                + "opening_time = ?, closing_time = ?, active = ? WHERE branch_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            ps = conn.prepareStatement(sql);
            ps.setString(1, branch.getName());
            ps.setString(2, branch.getAddress());
            ps.setString(3, branch.getCity());
            ps.setString(4, branch.getPhone());
            ps.setString(5, branch.getEmail());
            ps.setTime(6, openingTime != null ? Time.valueOf(openingTime) : null);
            ps.setTime(7, closingTime != null ? Time.valueOf(closingTime) : null);
            ps.setBoolean(8, active);
            ps.setLong(9, branch.getBranchId());

            boolean ok = ps.executeUpdate() == 1;
            if (!ok) {
                conn.rollback();
                return false;
            }
            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            throw new RuntimeException("Loi saveBranchDetails branches: " + e.getMessage(), e);
        } finally {
            // Khoi phuc autoCommit truoc khi tra connection ve pool (tranh hong transaction request sau)
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
