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
            System.err.println("[ERROR] EmployeeDAO.findByUsername - " + e.getMessage());
            e.printStackTrace();
            return null;
        } finally {
            closeAll(rs, ps, conn);
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