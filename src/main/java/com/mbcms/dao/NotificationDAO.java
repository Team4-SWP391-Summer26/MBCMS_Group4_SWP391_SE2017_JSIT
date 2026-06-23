package com.mbcms.dao;

import com.mbcms.model.Notification;
import java.sql.Connection;
import java.util.List;

/**
 * NotificationDAO - truy cap bang `notifications`.
 */
public interface NotificationDAO {
    
    /**
     * INSERT notification dung Connection truyen vao (transaction chung).
     * KHONG commit/close connection.
     */
    void insert(Connection conn, Notification n);

    /** Lay N thong bao gan nhat (dung cho dropdown header). */
    List<Notification> findRecentByUsername(String username, int limit);

    /** Lay co phan trang (dung cho trang /customer/notifications). */
    List<Notification> findPagedByUsername(String username, int offset, int limit);

    /** Dem tong so thong bao cua 1 customer (dung cho phan trang). */
    int countByUsername(String username);

    /** Dem so thong bao chua doc (dung cho cham do do tren bell). */
    int countUnread(String username);

    /** Danh dau 1 thong bao la da doc, co kem username de tranh truy cap cheo. */
    boolean markAsRead(long notiId, String username);

    /** Danh dau toan bo thong bao chua doc cua 1 customer la da doc. */
    boolean markAllAsRead(String username);

    /**
     * Kiem tra xem da co REMINDER cho booking nay chua,
     * tranh scheduler gui nhac nhiem vu trung lap.
     */
    boolean existsReminderForBooking(long bookingId);

    /** Them moi 1 thong bao, tra ve noti_id moi hoac -1 neu loi. */
    long insert(Notification notification);
}