package com.mbcms.dao.impl;

import com.mbcms.dao.EmployeeDAO;
import com.mbcms.model.Employee;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * EmployeeDAOImpl - truy cap bang {@code employees}.
 * Pattern chuan: PreparedStatement + closeAll trong finally.
 */
public class EmployeeDAOImpl extends BaseDAO implements EmployeeDAO {

    @Override
    public Employee findByUsername(String username) {
        String sql = "SELECT username, email, password_hash, full_name, phone, "
                + "role, branch_id, active, created_at "
                + "FROM employees WHERE username = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            // null CHI danh cho "khong tim thay user". Loi DB (mat ket noi, pool loi...)
            // phai nem ra de KHONG bi nguy trang thanh "sai mat khau" o tang tren.
            throw new RuntimeException("Loi truy van employees.findByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
    
    @Override
    public Employee findByEmail(String email) {
        if (email == null) return null;

        final String sql =
                "SELECT username, email, password_hash, full_name, phone, "
                + "date_of_birth, address, active, email_verified, reset_token, created_at "
                + "FROM customers WHERE LOWER(email) = LOWER(?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps   = conn.prepareStatement(sql);
            ps.setString(1, email.trim());
            rs   = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } catch (SQLException e) {
            throw new RuntimeException(
                    "Loi truy van customers.findByEmail: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }
    
    /**
     * Update mat khau moi da duoc hash bang BCrypt.
     * Luu y: DAO chi update DB, khong tu hash password o day.
     */
    @Override
    public boolean updatePassword(String username, String newPasswordHash) {
        String sql = "UPDATE employees SET password_hash = ? WHERE username = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, newPasswordHash);
            ps.setString(2, username);

            // executeUpdate tra ve so dong bi anh huong.
            // = 1 nghia la update thanh cong, = 0 nghia la khong tim thay username.
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van employees.updatePassword: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }
    private Employee mapRow(ResultSet rs) throws SQLException {
        Employee e = new Employee();
        e.setUsername(rs.getString("username"));
        e.setEmail(rs.getString("email"));
        e.setPasswordHash(rs.getString("password_hash"));
        e.setFullName(rs.getString("full_name"));
        e.setPhone(rs.getString("phone"));
        e.setRole(rs.getString("role"));

        long branchId = rs.getLong("branch_id");
        e.setBranchId(rs.wasNull() ? null : branchId);

        e.setActive(rs.getBoolean("active"));

        java.sql.Timestamp created = rs.getTimestamp("created_at");
        e.setCreatedAt(created != null ? created.toLocalDateTime() : null);

        return e;
    }
}