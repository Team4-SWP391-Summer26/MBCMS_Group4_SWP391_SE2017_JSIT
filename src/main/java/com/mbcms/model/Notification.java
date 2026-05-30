package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * Notification - map bang `notifications`.
 * type: BOOKING | PAYMENT | PROMOTION | REMINDER | SYSTEM
 * referenceId: loose ref toi booking_id/payment_id... (khong co FK).
 */
public class Notification {

    public static final String TYPE_BOOKING = "BOOKING";
    public static final String TYPE_PAYMENT = "PAYMENT";
    public static final String TYPE_PROMOTION = "PROMOTION";
    public static final String TYPE_REMINDER = "REMINDER";
    public static final String TYPE_SYSTEM = "SYSTEM";

    private long notiId;
    private String customerUsername;
    private String title;
    private String content;
    private String type;
    private boolean read;
    private Long referenceId;
    private LocalDateTime createdAt;

    public Notification() {}

    public long getNotiId() { return notiId; }
    public void setNotiId(long notiId) { this.notiId = notiId; }

    public String getCustomerUsername() { return customerUsername; }
    public void setCustomerUsername(String customerUsername) { this.customerUsername = customerUsername; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public Long getReferenceId() { return referenceId; }
    public void setReferenceId(Long referenceId) { this.referenceId = referenceId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
