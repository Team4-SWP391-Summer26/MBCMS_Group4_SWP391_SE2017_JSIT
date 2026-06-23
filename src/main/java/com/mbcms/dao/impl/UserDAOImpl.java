package com.mbcms.dao.impl;

import com.mbcms.dao.UserDAO;
import com.mbcms.dto.UserDTO;
import com.mbcms.dto.UserStatsDTO;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class UserDAOImpl extends BaseDAO implements UserDAO {

    @Override
    public List<UserDTO> searchUsers(String search, String role, Long branchId, String status, int offset, int limit) {
        List<UserDTO> list = new ArrayList<>();
        String sql = "SELECT username, email, full_name, phone, role, branch_id, branch_name, active, created_at, date_of_birth, address FROM ("
                + "  SELECT username, email, full_name, phone, 'CUSTOMER' AS role, NULL AS branch_id, NULL AS branch_name, active, created_at, date_of_birth, address"
                + "  FROM customers"
                + "  UNION ALL"
                + "  SELECT e.username, e.email, e.full_name, e.phone, e.role, e.branch_id, b.name AS branch_name, e.active, e.created_at, NULL AS date_of_birth, NULL AS address"
                + "  FROM employees e"
                + "  LEFT JOIN branches b ON e.branch_id = b.branch_id"
                + ") AS u"
                + " WHERE 1=1"
                + "   AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ?)"
                + "   AND (? = '' OR u.role = ?)"
                + "   AND (? = 0 OR u.branch_id = ?)"
                + "   AND (? = '' OR (? = 'Active' AND u.active = 1) OR (? = 'Inactive' AND u.active = 0))"
                + " ORDER BY u.created_at DESC"
                + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);

            String likePattern = "%" + (search != null ? search.trim() : "") + "%";
            String r = (role != null) ? role.trim() : "";
            long bid = (branchId != null) ? branchId : 0L;
            String s = (status != null) ? status.trim() : "";

            ps.setString(1, likePattern);
            ps.setString(2, likePattern);
            ps.setString(3, likePattern);
            ps.setString(4, r);
            ps.setString(5, r);
            ps.setLong(6, bid);
            ps.setLong(7, bid);
            ps.setString(8, s);
            ps.setString(9, s);
            ps.setString(10, s);
            ps.setInt(11, offset);
            ps.setInt(12, limit);

            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.searchUsers: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public int countUsers(String search, String role, Long branchId, String status) {
        String sql = "SELECT COUNT(*) FROM ("
                + "  SELECT username, email, full_name, phone, 'CUSTOMER' AS role, NULL AS branch_id, active, created_at"
                + "  FROM customers"
                + "  UNION ALL"
                + "  SELECT username, email, full_name, phone, role, branch_id, active, created_at"
                + "  FROM employees"
                + ") AS u"
                + " WHERE 1=1"
                + "   AND (u.username LIKE ? OR u.email LIKE ? OR u.full_name LIKE ?)"
                + "   AND (? = '' OR u.role = ?)"
                + "   AND (? = 0 OR u.branch_id = ?)"
                + "   AND (? = '' OR (? = 'Active' AND u.active = 1) OR (? = 'Inactive' AND u.active = 0))";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);

            String likePattern = "%" + (search != null ? search.trim() : "") + "%";
            String r = (role != null) ? role.trim() : "";
            long bid = (branchId != null) ? branchId : 0L;
            String s = (status != null) ? status.trim() : "";

            ps.setString(1, likePattern);
            ps.setString(2, likePattern);
            ps.setString(3, likePattern);
            ps.setString(4, r);
            ps.setString(5, r);
            ps.setLong(6, bid);
            ps.setLong(7, bid);
            ps.setString(8, s);
            ps.setString(9, s);
            ps.setString(10, s);

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.countUsers: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public UserStatsDTO getUserStats() {
        String sql = "SELECT "
                + "  (SELECT COUNT(*) FROM customers) + (SELECT COUNT(*) FROM employees) AS total_users, "
                + "  (SELECT COUNT(*) FROM customers) AS customers_count, "
                + "  (SELECT COUNT(*) FROM employees WHERE role = 'BRANCH_MANAGER') AS managers_count, "
                + "  (SELECT COUNT(*) FROM employees WHERE role = 'BRANCH_STAFF') AS staff_count, "
                + "  (SELECT COUNT(*) FROM employees WHERE role = 'ADMIN') AS admins_count";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                UserStatsDTO stats = new UserStatsDTO();
                stats.setTotalUsers(rs.getInt("total_users"));
                stats.setCustomersCount(rs.getInt("customers_count"));
                stats.setBranchManagersCount(rs.getInt("managers_count"));
                stats.setBranchStaffCount(rs.getInt("staff_count"));
                stats.setAdminsCount(rs.getInt("admins_count"));
                return stats;
            }
            return new UserStatsDTO();
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.getUserStats: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public UserDTO findByUsername(String username) {
        String sql = "SELECT username, email, full_name, phone, role, branch_id, branch_name, active, created_at, date_of_birth, address FROM ("
                + "  SELECT username, email, full_name, phone, 'CUSTOMER' AS role, NULL AS branch_id, NULL AS branch_name, active, created_at, date_of_birth, address"
                + "  FROM customers WHERE username = ?"
                + "  UNION ALL"
                + "  SELECT e.username, e.email, e.full_name, e.phone, e.role, e.branch_id, b.name AS branch_name, e.active, e.created_at, NULL AS date_of_birth, NULL AS address"
                + "  FROM employees e"
                + "  LEFT JOIN branches b ON e.branch_id = b.branch_id"
                + "  WHERE e.username = ?"
                + ") AS u";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, username);

            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.findByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean existsByUsername(String username) {
        String sql = "SELECT 1 FROM ("
                + "  SELECT username FROM customers WHERE username = ?"
                + "  UNION ALL"
                + "  SELECT username FROM employees WHERE username = ?"
                + ") AS u";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, username);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.existsByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean existsByEmail(String email) {
        String sql = "SELECT 1 FROM ("
                + "  SELECT email FROM customers WHERE email = ?"
                + "  UNION ALL"
                + "  SELECT email FROM employees WHERE email = ?"
                + ") AS u";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, email);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.existsByEmail: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean hasRelatedTransactions(String username, String role) {
        if (!"CUSTOMER".equalsIgnoreCase(role)) {
            return false; // Employees do not have bookings/notifications FK constraints in the default schema
        }

        String sql = "SELECT SUM(cnt) FROM ("
                + "  SELECT COUNT(*) AS cnt FROM bookings WHERE customer_username = ?"
                + "  UNION ALL"
                + "  SELECT COUNT(*) AS cnt FROM feedbacks WHERE customer_username = ?"
                + "  UNION ALL"
                + "  SELECT COUNT(*) AS cnt FROM notifications WHERE customer_username = ?"
                + ") AS t";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, username);
            ps.setString(3, username);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in UserDAO.hasRelatedTransactions: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    private UserDTO mapRow(ResultSet rs) throws SQLException {
        UserDTO u = new UserDTO();
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setFullName(rs.getString("full_name"));
        u.setPhone(rs.getString("phone"));
        u.setRole(rs.getString("role"));

        long bid = rs.getLong("branch_id");
        u.setBranchId(rs.wasNull() ? null : bid);
        u.setBranchName(rs.getString("branch_name"));
        u.setActive(rs.getBoolean("active"));

        java.sql.Timestamp created = rs.getTimestamp("created_at");
        if (created != null) {
            u.setCreatedAt(created.toLocalDateTime());
        }

        java.sql.Date dob = rs.getDate("date_of_birth");
        if (dob != null) {
            u.setDateOfBirth(dob.toLocalDate());
        }

        u.setAddress(rs.getString("address"));
        return u;
    }

    @Override
    public boolean insertCustomer(UserDTO user, String passwordHash) {
        String sql = "INSERT INTO customers (username, email, password_hash, full_name, phone, date_of_birth, address, active, email_verified, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, passwordHash);
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setDate(6, user.getDateOfBirth() != null ? java.sql.Date.valueOf(user.getDateOfBirth()) : null);
            ps.setString(7, user.getAddress());
            ps.setBoolean(8, user.isActive());
            ps.setTimestamp(9, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi insertCustomer: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateCustomer(UserDTO user, String passwordHash) {
        String sql;
        if (passwordHash != null && !passwordHash.trim().isEmpty()) {
            sql = "UPDATE customers SET email = ?, full_name = ?, phone = ?, date_of_birth = ?, address = ?, active = ?, password_hash = ? WHERE username = ?";
        } else {
            sql = "UPDATE customers SET email = ?, full_name = ?, phone = ?, date_of_birth = ?, address = ?, active = ? WHERE username = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getPhone());
            ps.setDate(4, user.getDateOfBirth() != null ? java.sql.Date.valueOf(user.getDateOfBirth()) : null);
            ps.setString(5, user.getAddress());
            ps.setBoolean(6, user.isActive());
            if (passwordHash != null && !passwordHash.trim().isEmpty()) {
                ps.setString(7, passwordHash);
                ps.setString(8, user.getUsername());
            } else {
                ps.setString(7, user.getUsername());
            }
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateCustomer: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean deleteCustomer(String username) {
        String sql = "DELETE FROM customers WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi deleteCustomer: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean insertEmployee(UserDTO user, String passwordHash) {
        String sql = "INSERT INTO employees (username, email, password_hash, full_name, phone, role, branch_id, active, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getEmail());
            ps.setString(3, passwordHash);
            ps.setString(4, user.getFullName());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getRole());
            if (user.getBranchId() != null) {
                ps.setLong(7, user.getBranchId());
            } else {
                ps.setNull(7, java.sql.Types.BIGINT);
            }
            ps.setBoolean(8, user.isActive());
            ps.setTimestamp(9, java.sql.Timestamp.valueOf(java.time.LocalDateTime.now()));
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi insertEmployee: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateEmployee(UserDTO user, String passwordHash) {
        String sql;
        if (passwordHash != null && !passwordHash.trim().isEmpty()) {
            sql = "UPDATE employees SET email = ?, full_name = ?, phone = ?, role = ?, branch_id = ?, active = ?, password_hash = ? WHERE username = ?";
        } else {
            sql = "UPDATE employees SET email = ?, full_name = ?, phone = ?, role = ?, branch_id = ?, active = ? WHERE username = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getRole());
            if (user.getBranchId() != null) {
                ps.setLong(5, user.getBranchId());
            } else {
                ps.setNull(5, java.sql.Types.BIGINT);
            }
            ps.setBoolean(6, user.isActive());
            if (passwordHash != null && !passwordHash.trim().isEmpty()) {
                ps.setString(7, passwordHash);
                ps.setString(8, user.getUsername());
            } else {
                ps.setString(7, user.getUsername());
            }
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateEmployee: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean deleteEmployee(String username) {
        String sql = "DELETE FROM employees WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi deleteEmployee: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateActiveStatus(String username, String role, boolean active) {
        String sql = "CUSTOMER".equalsIgnoreCase(role)
                ? "UPDATE customers SET active = ? WHERE username = ?"
                : "UPDATE employees SET active = ? WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setString(2, username);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateActiveStatus: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updatePassword(String username, String role, String passwordHash) {
        String sql = "CUSTOMER".equalsIgnoreCase(role)
                ? "UPDATE customers SET password_hash = ? WHERE username = ?"
                : "UPDATE employees SET password_hash = ? WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, passwordHash);
            ps.setString(2, username);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updatePassword: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }
}
