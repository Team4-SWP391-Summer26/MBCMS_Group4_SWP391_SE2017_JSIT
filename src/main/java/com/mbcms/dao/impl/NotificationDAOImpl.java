package com.mbcms.dao.impl;

import com.mbcms.dao.NotificationDAO;
import com.mbcms.model.Notification;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * NotificationDAOImpl - theo pattern cua CustomerDAOImpl.
 * SQL dialect: SQL Server (dung TOP thay LIMIT, BIT thay BOOLEAN).
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
    
    /**
     * Lay N thong bao gan nhat cua 1 customer, moi nhat truoc.
     * Dung cho dropdown bell tren header.
     * Luu y: TOP (?) phai la tham so thu 1 vi no xuat hien truoc WHERE trong SQL.
     */
    @Override
    public List<Notification> findRecentByUsername(String username, int limit) {
        String sql = "SELECT TOP (?) noti_id, customer_username, title, content, type, "
                + "is_read, reference_id, created_at "
                + "FROM dbo.notifications WHERE customer_username = ? "
                + "ORDER BY created_at DESC";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Notification> result = new ArrayList<>();

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setString(2, username);
            rs = ps.executeQuery();
            while (rs.next()) {
                result.add(mapRow(rs));
            }
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van notifications.findRecentByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Lay co phan trang bang OFFSET...FETCH (SQL Server 2012+).
     * Dung cho trang /customer/notifications.
     */
    @Override
    public List<Notification> findPagedByUsername(String username, int offset, int limit) {
        String sql = "SELECT noti_id, customer_username, title, content, type, "
                + "is_read, reference_id, created_at "
                + "FROM dbo.notifications WHERE customer_username = ? "
                + "ORDER BY created_at DESC "
                + "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Notification> result = new ArrayList<>();

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            ps.setInt(2, offset);
            ps.setInt(3, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                result.add(mapRow(rs));
            }
            return result;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van notifications.findPagedByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Dem tong so thong bao cua 1 customer, dung cho tinh tong trang.
     */
    @Override
    public int countByUsername(String username) {
        String sql = "SELECT COUNT(*) FROM dbo.notifications WHERE customer_username = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van notifications.countByUsername: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Dem so thong bao chua doc.
     * Tan dung filtered index IX_notifications_unread (is_read = 0).
     */
    @Override
    public int countUnread(String username) {
        String sql = "SELECT COUNT(*) FROM dbo.notifications "
                + "WHERE customer_username = ? AND is_read = 0";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van notifications.countUnread: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Danh dau 1 thong bao la da doc.
     * Co kem customer_username trong WHERE de tranh 1 user
     * danh dau doc thong bao cua nguoi khac.
     */
    @Override
    public boolean markAsRead(long notiId, String username) {
        String sql = "UPDATE dbo.notifications SET is_read = 1 "
                + "WHERE noti_id = ? AND customer_username = ?";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, notiId);
            ps.setString(2, username);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi thuc thi notifications.markAsRead: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    /**
     * Danh dau toan bo thong bao chua doc cua 1 customer la da doc.
     * Tan dung filtered index IX_notifications_unread.
     */
    @Override
    public boolean markAllAsRead(String username) {
        String sql = "UPDATE dbo.notifications SET is_read = 1 "
                + "WHERE customer_username = ? AND is_read = 0";

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, username);
            return ps.executeUpdate() >= 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi thuc thi notifications.markAllAsRead: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    /**
     * Kiem tra da gui reminder cho booking nay chua.
     * Dung boi ShowtimeReminderScheduler de tranh gui nhac lap.
     */
    @Override
    public boolean existsReminderForBooking(long bookingId) {
        String sql = "SELECT 1 FROM dbo.notifications "
                + "WHERE type = 'REMINDER' AND reference_id = ?";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi truy van notifications.existsReminderForBooking: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /**
     * Them moi 1 thong bao.
     * Dung cho cac service khac goi sau khi booking/payment/promotion thanh cong.
     */
    @Override
    public long insert(Notification notification) {
        String sql = "INSERT INTO dbo.notifications "
                + "(customer_username, title, content, type, reference_id) "
                + "VALUES (?, ?, ?, ?, ?)";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet keys = null;

        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

            ps.setString(1, notification.getCustomerUsername());
            ps.setString(2, notification.getTitle());
            ps.setString(3, notification.getContent());
            ps.setString(4, notification.getType());

            if (notification.getReferenceId() != null) {
                ps.setLong(5, notification.getReferenceId());
            } else {
                ps.setNull(5, Types.BIGINT);
            }

            ps.executeUpdate();
            keys = ps.getGeneratedKeys();
            return keys.next() ? keys.getLong(1) : -1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi thuc thi notifications.insert: " + e.getMessage(), e);
        } finally {
            closeAll(keys, ps, conn);
        }
    }

    /**
     * Chuyen du lieu tu ResultSet thanh object Notification.
     */
    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotiId(rs.getLong("noti_id"));
        n.setCustomerUsername(rs.getString("customer_username"));
        n.setTitle(rs.getString("title"));
        n.setContent(rs.getString("content"));
        n.setType(rs.getString("type"));
        n.setRead(rs.getBoolean("is_read"));

        long refId = rs.getLong("reference_id");
        n.setReferenceId(rs.wasNull() ? null : refId);

        Timestamp created = rs.getTimestamp("created_at");
        n.setCreatedAt(created != null ? created.toLocalDateTime() : null);

        return n;
    }
}