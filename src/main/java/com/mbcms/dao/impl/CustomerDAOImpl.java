package com.mbcms.dao.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.model.Customer;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * CustomerDAOImpl - Implementation of CustomerDAO accessing the customers table.
 */
public class CustomerDAOImpl extends BaseDAO implements CustomerDAO {

    @Override
    public Customer findByUsername(String username) {
        String sql = "SELECT username, email, password_hash, full_name, phone, "
                + "date_of_birth, address, active, email_verified, reset_token, created_at "
                + "FROM customers WHERE username = ?";

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
            throw new RuntimeException("Loi truy van customers.findByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public Customer findByEmail(String email) {
        String sql = "SELECT username, email, password_hash, full_name, phone, "
                + "date_of_birth, address, active, email_verified, reset_token, created_at "
                + "FROM customers WHERE email = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van customers.findByEmail: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean updateResetToken(String username, String resetToken) {
        String sql = "UPDATE customers SET reset_token = ? WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, resetToken);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi cap nhat customers.updateResetToken: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updatePasswordHash(String username, String passwordHash) {
        String sql = "UPDATE customers SET password_hash = ?, reset_token = NULL WHERE username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, passwordHash);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi cap nhat customers.updatePasswordHash: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    private Customer mapRow(ResultSet rs) throws SQLException {
        Customer c = new Customer();
        c.setUsername(rs.getString("username"));
        c.setEmail(rs.getString("email"));
        c.setPasswordHash(rs.getString("password_hash"));
        c.setFullName(rs.getString("full_name"));
        c.setPhone(rs.getString("phone"));
        java.sql.Date dob = rs.getDate("date_of_birth");
        c.setDateOfBirth(dob != null ? dob.toLocalDate() : null);
        c.setAddress(rs.getString("address"));
        c.setActive(rs.getBoolean("active"));
        c.setEmailVerified(rs.getBoolean("email_verified"));
        c.setResetToken(rs.getString("reset_token"));
        java.sql.Timestamp created = rs.getTimestamp("created_at");
        c.setCreatedAt(created != null ? created.toLocalDateTime() : null);
        return c;
    }
}
