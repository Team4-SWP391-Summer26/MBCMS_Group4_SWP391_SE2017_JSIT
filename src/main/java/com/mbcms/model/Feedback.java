package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * Feedback - map bang `feedbacks`.
 * customerUsername nullable (Guest gui duoc); branchId nullable (gop y toan he thong).
 * status: NEW | IN_PROGRESS | RESOLVED | CLOSED
 * category: COMPLAINT | SUPPORT | GENERAL
 */
public class Feedback {

    // ── Status constants ─────────────────────────────────────────────────────
    public static final String STATUS_NEW         = "NEW";
    public static final String STATUS_IN_PROGRESS = "IN_PROGRESS";
    public static final String STATUS_RESOLVED    = "RESOLVED";
    public static final String STATUS_CLOSED      = "CLOSED";

    // ── Category constants ───────────────────────────────────────────────────
    public static final String CAT_COMPLAINT = "COMPLAINT";
    public static final String CAT_SUPPORT   = "SUPPORT";
    public static final String CAT_GENERAL   = "GENERAL";

    // ── Sub-category constants (for SUPPORT) ────────────────────────────────
    public static final String SUB_BOOKING = "BOOKING";
    public static final String SUB_ACCOUNT = "ACCOUNT";
    public static final String SUB_OTHER   = "OTHER";

    private long feedbackId;
    private String customerUsername;
    private Long branchId;
    private String name;
    private String email;
    private String subject;
    private String message;
    private String status;
    private String response;
    private LocalDateTime createdAt;
    private LocalDateTime resolvedAt;

    // ── Extended fields ──────────────────────────────────────────────────────
    private String category     = CAT_GENERAL; // default GENERAL
    private String subCategory;                // only for SUPPORT
    private Long   relatedBookingId;
    private Long   relatedShowtimeId;
    private String handledBy;                  // employee username

    public Feedback() {
    }

    public long getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(long feedbackId) {
        this.feedbackId = feedbackId;
    }

    public String getCustomerUsername() {
        return customerUsername;
    }

    public void setCustomerUsername(String customerUsername) {
        this.customerUsername = customerUsername;
    }

    public Long getBranchId() {
        return branchId;
    }

    public void setBranchId(Long branchId) {
        this.branchId = branchId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getSubject() {
        return subject;
    }

    public void setSubject(String subject) {
        this.subject = subject;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getResponse() {
        return response;
    }

    public void setResponse(String response) {
        this.response = response;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getResolvedAt() {
        return resolvedAt;
    }

    public void setResolvedAt(LocalDateTime resolvedAt) {
        this.resolvedAt = resolvedAt;
    }

    // ── Extended getters/setters ─────────────────────────────────────────────
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubCategory() { return subCategory; }
    public void setSubCategory(String subCategory) { this.subCategory = subCategory; }

    public Long getRelatedBookingId() { return relatedBookingId; }
    public void setRelatedBookingId(Long relatedBookingId) { this.relatedBookingId = relatedBookingId; }

    public Long getRelatedShowtimeId() { return relatedShowtimeId; }
    public void setRelatedShowtimeId(Long relatedShowtimeId) { this.relatedShowtimeId = relatedShowtimeId; }

    public String getHandledBy() { return handledBy; }
    public void setHandledBy(String handledBy) { this.handledBy = handledBy; }
}
