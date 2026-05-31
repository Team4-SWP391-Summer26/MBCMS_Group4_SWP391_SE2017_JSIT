package com.mbcms.dao.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.model.Customer;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * MAU DAO - copy pattern nay khi tao *DAOImpl khac.
 * Chi giu 1 method mau; cac method khac team tu them vao interface + impl.
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
            // null CHI danh cho "khong tim thay user". Loi DB (mat ket noi, pool loi...)
            // phai nem ra de KHONG bi nguy trang thanh "sai mat khau" o tang tren.
            throw new RuntimeException("Loi truy van customers.findByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
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
