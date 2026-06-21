package com.mbcms.dao;

import com.mbcms.model.Notification;

import java.sql.Connection;

/**
 * NotificationDAO - ghi thong bao in-app (bang `notifications`).
 *
 * Hien tai chi phuc vu Payment callback (SRS 3.8.4 - tao PAYMENT notification
 * trong cung transaction). Tinh nang Notifications day du (TrangNT) co the mo
 * rong interface nay sau.
 */
public interface NotificationDAO {

    /**
     * INSERT notification dung Connection truyen vao (transaction chung).
     * KHONG commit/close connection.
     */
    void insert(Connection conn, Notification n);
}
