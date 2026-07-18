package com.mbcms.service.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.NotificationDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.dao.impl.NotificationDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.Notification;
import com.mbcms.model.Promotion;
import com.mbcms.service.NotificationService;
import com.mbcms.util.EmailUtil;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.List;

/**
 * NotificationServiceImpl - xu ly business logic thong bao. Theo pattern cua
 * AuthServiceImpl: constructor mac dinh khoi tao DAO that, constructor inject
 * danh cho unit test.
 */
public class NotificationServiceImpl implements NotificationService {

    private static final int MAX_LIMIT = 50;
    private static final int PAGE_SIZE = 20;
    private static final DateTimeFormatter DISPLAY_FMT
            = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    private final NotificationDAO notificationDAO;
    private final CustomerDAO customerDAO;
    private final PromotionDAO promotionDAO;

    public NotificationServiceImpl() {
        this.notificationDAO = new NotificationDAOImpl();
        this.customerDAO = new CustomerDAOImpl();
        this.promotionDAO = new PromotionDAOImpl();
    }

// Update inject constructor:
    public NotificationServiceImpl(NotificationDAO notificationDAO,
            CustomerDAO customerDAO, PromotionDAO promotionDAO) {
        this.notificationDAO = notificationDAO;
        this.customerDAO = customerDAO;
        this.promotionDAO    = promotionDAO;
    }

    // ── Read ──────────────────────────────────────────────────────────────────
    @Override
    public List<Notification> getRecentForUser(String username, int limit) {
        if (username == null || username.trim().isEmpty()) {
            return Collections.emptyList();
        }
        int safeLimit = Math.max(1, Math.min(limit, MAX_LIMIT));
        return notificationDAO.findRecentByUsername(username.trim(), safeLimit);
    }

    @Override
    public List<Notification> getPagedForUser(String username, int page, int pageSize) {
        if (username == null || username.trim().isEmpty()) {
            return Collections.emptyList();
        }
        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, Math.min(pageSize, MAX_LIMIT));
        int offset = (safePage - 1) * safePageSize;
        return notificationDAO.findPagedByUsername(username.trim(), offset, safePageSize);
    }

    @Override
    public int countAll(String username) {
        if (username == null || username.trim().isEmpty()) {
            return 0;
        }
        return notificationDAO.countByUsername(username.trim());
    }

    @Override
    public int countUnread(String username) {
        if (username == null || username.trim().isEmpty()) {
            return 0;
        }
        return notificationDAO.countUnread(username.trim());
    }

    // ── Write ─────────────────────────────────────────────────────────────────
    @Override
    public boolean markAsRead(long notiId, String username) {
        if (username == null || username.trim().isEmpty() || notiId <= 0) {
            return false;
        }
        return notificationDAO.markAsRead(notiId, username.trim());
    }

    @Override
    public boolean markAllAsRead(String username) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        return notificationDAO.markAllAsRead(username.trim());
    }

    @Override
    public long create(String customerUsername, String title, String content,
            String type, Long referenceId) {
        if (customerUsername == null || customerUsername.trim().isEmpty()) {
            throw new IllegalArgumentException("customerUsername khong duoc rong.");
        }
        if (title == null || title.trim().isEmpty()) {
            throw new IllegalArgumentException("title khong duoc rong.");
        }
        if (!isValidType(type)) {
            throw new IllegalArgumentException("type khong hop le: " + type);
        }

        Notification n = new Notification();
        n.setCustomerUsername(customerUsername.trim());
        n.setTitle(title.trim());
        n.setContent(content != null ? content.trim() : "");
        n.setType(type);
        n.setReferenceId(referenceId);

        return notificationDAO.insert(n);
    }

    // ── Booking / Payment confirmation ────────────────────────────────────────
    /**
     * Gui thong bao + email xac nhan dat ve thanh cong. Booking confirmation va
     * Payment confirmation xay ra cung 1 luc trong he thong nay (khong co
     * payment gateway rieng), nen gop 2 loai thanh 1 event.
     *
     * Gui email bat dong bo (new Thread) de khong block luong HTTP, giong
     * pattern trong AuthServiceImpl.registerCustomer().
     */
    @Override
    public void sendBookingConfirmation(Booking booking, String customerEmail) {
        if (booking == null) {
            return;
        }

        String username = booking.getCustomerUsername();
        long bookingId = booking.getBookingId();
        String code = booking.getBookingCode();

        // 1. Thong bao xac nhan dat ve (BOOKING)
        String bookingTitle = "Booking Confirmed - " + code;
        String bookingContent = "Your ticket has been confirmed. Booking code: " + code
                + ". Total payment: "
                + String.format("%,.0f", booking.getTotalAmount()) + " VND.";
        create(username, bookingTitle, bookingContent, Notification.TYPE_BOOKING, bookingId);

        // 2. Thong bao xac nhan thanh toan (PAYMENT) – cung booking_id
        String paymentTitle = "Payment Successful - " + code;
        String paymentContent = "Payment of " + String.format("%,.0f", booking.getTotalAmount())
                + " VND for ticket " + code + " has been recorded.";
        create(username, paymentTitle, paymentContent, Notification.TYPE_PAYMENT, bookingId);

        // 3. Email xac nhan – gui bat dong bo
        if (customerEmail != null && !customerEmail.isEmpty()) {
            final String email = customerEmail;
            final Booking bFinal = booking;
            new Thread(() -> {
                try {
                    EmailUtil.sendBookingConfirmationEmail(email, bFinal);
                } catch (Exception e) {
                    System.err.println("[NotificationService] Loi gui email xac nhan: " + e.getMessage());
                }
            }, "email-booking-" + code).start();
        }
    }

    // ── Showtime reminder ─────────────────────────────────────────────────────
    /**
     * Gui thong bao nhac nho suất chieu neu chua gui. Dung
     * existsReminderForBooking() de tranh gui trung lap moi lan scheduler chay.
     */
    @Override
    public boolean sendReminderIfNotSent(Booking booking, String customerEmail,
            String movieTitle, LocalDateTime showtimeStart) {
        if (booking == null) {
            return false;
        }

        long bookingId = booking.getBookingId();

        // Kiem tra da gui chua de tranh gui trung
        if (notificationDAO.existsReminderForBooking(bookingId)) {
            return false;
        }

        String startStr = showtimeStart != null ? showtimeStart.format(DISPLAY_FMT) : "soon";

        String title = "Reminder: \"" + movieTitle + "\" starts at " + startStr;
        String content = "Your showtime (ticket code: " + booking.getBookingCode()
                + ") starts at " + startStr + ". Please arrive 15 minutes early.";

        create(booking.getCustomerUsername(), title, content,
                Notification.TYPE_REMINDER, bookingId);

        // Email nhac nho bat dong bo
        if (customerEmail != null && !customerEmail.isEmpty()) {
            final String email = customerEmail;
            new Thread(() -> {
                try {
                    EmailUtil.sendReminderEmail(email, booking.getBookingCode(),
                            movieTitle, startStr);
                } catch (Exception e) {
                    System.err.println("[NotificationService] Loi gui email nhac nho: " + e.getMessage());
                }
            }, "email-reminder-" + bookingId).start();
        }

        return true;
    }

    // ── Promotion broadcast ───────────────────────────────────────────────────
    /**
     * Phat thu chuong khuyen mai den tat ca customer con active. Query
     * findAllActiveUsernames() tra ve List<String> nen neu co nhieu customer,
     * vong lap nay co the chay lau → goi tu background thread trong servlet.
     */
    @Override
    public void broadcastPromotion(Promotion promotion) {
        if (promotion == null || !promotion.isActive()) {
            return;
        }

        List<String> usernames = customerDAO.findAllActiveUsernames();
        if (usernames == null || usernames.isEmpty()) {
            return;
        }

        String title = "New Promotion: " + promotion.getName();
        String content = buildPromoContent(promotion);

        for (String username : usernames) {
            try {
                create(username, title, content, Notification.TYPE_PROMOTION,
                        promotion.getPromoId());
            } catch (Exception e) {
                // Log loi nhung tiep tuc gui cho cac user con lai
                System.err.println("[NotificationService] Loi gui promo cho "
                        + username + ": " + e.getMessage());
            }
        }

        // Email broadcast bat dong bo
        new Thread(() -> {
            try {
                EmailUtil.sendPromotionBroadcastEmail(usernames, promotion);
            } catch (Exception e) {
                System.err.println("[NotificationService] Loi gui email promo: " + e.getMessage());
            }
        }, "email-promo-" + promotion.getPromoId()).start();
    }

    @Override
    public void broadcastPromotionByCode(String promoCode) {
        if (promoCode == null || promoCode.trim().isEmpty()) {
            return;
        }
        Promotion promotion = promotionDAO.findByCode(promoCode.trim().toUpperCase());
        if (promotion == null || !promotion.isActive()) {
            return;
        }
        broadcastPromotion(promotion);   // reuse existing logic — real promoId now populated
    }

    // ── UI helpers ────────────────────────────────────────────────────────────
    /**
     * Map type -> Bootstrap Icons class de hien thi tren UI. Dat trong service
     * vi day la business/display rule, khong phai SQL.
     */
    @Override
    public String iconClassFor(String type) {
        if (type == null) {
            return "bi-bell";
        }
        switch (type) {
            case Notification.TYPE_BOOKING:
                return "bi-ticket-perforated";
            case Notification.TYPE_PAYMENT:
                return "bi-credit-card";
            case Notification.TYPE_PROMOTION:
                return "bi-gift";
            case Notification.TYPE_REMINDER:
                return "bi-alarm";
            case Notification.TYPE_SYSTEM:
                return "bi-info-circle";
            case Notification.TYPE_FEEDBACK:
                return "bi-chat-square-text";
            default:
                return "bi-bell";
        }
    }

    /**
     * Sinh link dieu huong dua tren type va reference_id. contextPath truyen
     * vao de servlet co the goi voi req.getContextPath().
     */
    @Override
    public String linkFor(Notification notification, String contextPath) {
        if (notification == null || notification.getReferenceId() == null) {
            return "#";
        }
        String ctx = contextPath != null ? contextPath : "";

        switch (notification.getType()) {
            case Notification.TYPE_BOOKING:
            case Notification.TYPE_PAYMENT:
            case Notification.TYPE_REMINDER:
                return ctx + "/customer/booking/detail?bookingId="
                        + notification.getReferenceId();
            case Notification.TYPE_FEEDBACK:
                return ctx + "/customer/feedbacks";
            default:
                return "#";
        }
    }

    // ── Private helpers ───────────────────────────────────────────────────────
    private boolean isValidType(String type) {
        return Notification.TYPE_BOOKING.equals(type)
                || Notification.TYPE_PAYMENT.equals(type)
                || Notification.TYPE_PROMOTION.equals(type)
                || Notification.TYPE_REMINDER.equals(type)
                || Notification.TYPE_SYSTEM.equals(type)
                || Notification.TYPE_FEEDBACK.equals(type);
    }

    private String buildPromoContent(Promotion promotion) {
        StringBuilder sb = new StringBuilder("Code: ").append(promotion.getCode()).append(". ");
        if ("PERCENT".equals(promotion.getDiscountType())) {
            sb.append("Save ").append(promotion.getDiscountValue().toPlainString()).append("%");
        } else {
            sb.append("Save ").append(
                    String.format("%,.0f", promotion.getDiscountValue())).append(" VND");
        }
        if (promotion.getValidTo() != null) {
            sb.append(" - Valid until: ").append(promotion.getValidTo().format(DISPLAY_FMT));
        }
        return sb.toString();
    }
}
