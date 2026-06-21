package com.mbcms.dao.impl;

import com.mbcms.dao.NotificationDAO;
import com.mbcms.model.Notification;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Types;

/**
 * NotificationDAOImpl - SQL Server. is_read + created_at dung DEFAULT cua bang.
 * insert() KHONG dong connection (thuoc transaction cua Service).
 */
public class NotificationDAOImpl extends BaseDAO implements NotificationDAO {

    @Override
    public void insert(Connection conn, Notification n) {
        String sql =
            "INSERT INTO dbo.notifications " +
            "  (customer_username, title, content, type, reference_id) " +
            "VALUES (?, ?, ?, ?, ?)";
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, n.getCustomerUsername());
            ps.setString(2, n.getTitle());
            ps.setString(3, n.getContent());
            ps.setString(4, n.getType());
            if (n.getReferenceId() != null) {
                ps.setLong(5, n.getReferenceId());
            } else {
                ps.setNull(5, Types.BIGINT);
            }
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Notification insert loi: " + e.getMessage(), e);
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException ignored) {}
            }
        }
    }
}
