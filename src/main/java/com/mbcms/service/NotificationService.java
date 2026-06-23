package com.mbcms.service;

import com.mbcms.model.Notification;
import com.mbcms.model.Promotion;
import java.util.List;

/**
 * NotificationService - business logic cho thong bao.
 */
public interface NotificationService {

    /** Lay N thong bao gan nhat cho dropdown header. */
    List<Notification> getRecentForUser(String username, int limit);

    /** Lay co phan trang cho trang /customer/notifications. */
    List<Notification> getPagedForUser(String username, int page, int pageSize);

    /** Dem tong so thong bao (dung tinh tong trang). */
    int countAll(String username);

    /** Dem so chua doc (dung cho cham do do tren bell). */
    int countUnread(String username);

    /** Danh dau 1 thong bao la da doc. */
    boolean markAsRead(long notiId, String username);

    /** Danh dau tat ca la da doc. */
    boolean markAllAsRead(String username);

    /**
     * Tao 1 thong bao moi.
     * Dung boi BookingService, PromotionService, ShowtimeReminderScheduler.
     */
    long create(String customerUsername, String title, String content,
                String type, Long referenceId);

    /**
     * Gui thong bao xac nhan dat ve + email cho customer.
     * Goi tu BookingConfirmServlet sau khi confirmBooking thanh cong.
     */
    void sendBookingConfirmation(com.mbcms.model.Booking booking, String customerEmail);

    /**
     * Phat thu chuong khuyen mai den tat ca customer dang hoat dong.
     * Goi tu PromotionCreateServlet / PromotionToggleServlet khi promo active.
     */
    void broadcastPromotion(Promotion promotion);

    /**
     * Gui thong bao nhac nho suất chieu cho 1 booking cu the.
     * Goi boi ShowtimeReminderScheduler.
     * Tra ve false neu da gui roi (tranh trung lap).
     */
    boolean sendReminderIfNotSent(com.mbcms.model.Booking booking,
                                   String customerEmail,
                                   String movieTitle,
                                   java.time.LocalDateTime showtimeStart);

    /** Map type -> Bootstrap Icons class de hien thi tren UI. */
    String iconClassFor(String type);

    /** Sinh link dieu huong khi click vao thong bao. */
    String linkFor(Notification notification, String contextPath);
    
    void broadcastPromotionByCode(String promoCode);
    
}