package com.mbcms.service.impl;

import com.mbcms.dao.FeedbackDAO;
import com.mbcms.dao.impl.FeedbackDAOImpl;
import com.mbcms.model.Feedback;
import com.mbcms.model.Notification;
import com.mbcms.service.FeedbackService;
import com.mbcms.service.NotificationService;
import com.mbcms.util.ValidationUtil;

import java.util.*;

/**
 * FeedbackServiceImpl - business logic cho Complaint, Support Request, Feedback Tracking.
 *
 * Validation rules:
 *  - subject: 5-150 ky tu, khong rong
 *  - message: 10-2000 ky tu, khong rong
 *  - COMPLAINT: phai co relatedShowtimeId; customer phai co booking CONFIRMED/USED cho showtime do
 *  - SUPPORT + BOOKING: phai co relatedBookingId; booking phai thuoc ve customer (chong IDOR)
 *  - updateStatus: newStatus phai hop le; response bat buoc khi RESOLVED/CLOSED
 *  - branchScope: Staff/Manager chi duoc update feedback cua branch minh
 */
public class FeedbackServiceImpl implements FeedbackService {

    private static final Set<String> VALID_STATUSES = Set.of(
            Feedback.STATUS_NEW, Feedback.STATUS_IN_PROGRESS,
            Feedback.STATUS_RESOLVED, Feedback.STATUS_CLOSED);

    private static final Set<String> VALID_SUB_CATEGORIES = Set.of(
            Feedback.SUB_BOOKING, Feedback.SUB_ACCOUNT, Feedback.SUB_OTHER);

    private final FeedbackDAO feedbackDAO;
    private final NotificationService notificationService;

    public FeedbackServiceImpl() {
        this(new FeedbackDAOImpl(), new NotificationServiceImpl());
    }

    public FeedbackServiceImpl(FeedbackDAO feedbackDAO, NotificationService notificationService) {
        this.feedbackDAO          = feedbackDAO;
        this.notificationService  = notificationService;
    }

    // ── Submit Complaint ──────────────────────────────────────────────────────

    @Override
    public Object submitComplaint(String customerUsername, long relatedShowtimeId,
                                  String subject, String message) {

        // Validate fields
        String subjectErr = validateSubject(subject);
        if (subjectErr != null) return "ERR:" + subjectErr;

        String messageErr = validateMessage(message);
        if (messageErr != null) return "ERR:" + messageErr;

        // Security: verify customer has confirmed/used booking for this showtime
        if (!feedbackDAO.hasConfirmedBookingForShowtime(relatedShowtimeId, customerUsername)) {
            return "ERR:Bạn chỉ có thể gửi khiếu nại về suất chiếu mà bạn đã đặt vé thành công.";
        }

        Feedback f = new Feedback();
        f.setCustomerUsername(customerUsername);
        f.setCategory(Feedback.CAT_COMPLAINT);
        f.setRelatedShowtimeId(relatedShowtimeId);
        f.setSubject(subject.trim());
        f.setMessage(message.trim());
        // name & email populated from customer account (caller fills these before calling)
        // We intentionally leave them to be set by the servlet from session data.
        f.setStatus(Feedback.STATUS_NEW);

        long id = feedbackDAO.insert(f);
        if (id < 0) return "ERR:Không thể lưu khiếu nại. Vui lòng thử lại sau.";
        return id;
    }

    // ── Submit Support Request ────────────────────────────────────────────────

    @Override
    public Object submitSupportRequest(String customerUsername, String subCategory,
                                       Long relatedBookingId, String subject, String message) {

        // Validate sub_category
        if (subCategory == null || !VALID_SUB_CATEGORIES.contains(subCategory)) {
            return "ERR:Loại yêu cầu hỗ trợ không hợp lệ.";
        }

        // Validate fields
        String subjectErr = validateSubject(subject);
        if (subjectErr != null) return "ERR:" + subjectErr;

        String messageErr = validateMessage(message);
        if (messageErr != null) return "ERR:" + messageErr;

        // Security: if BOOKING sub-category, verify ownership (prevent IDOR)
        if (Feedback.SUB_BOOKING.equals(subCategory)) {
            if (relatedBookingId == null) {
                return "ERR:Vui lòng chọn mã đặt vé liên quan.";
            }
            if (!feedbackDAO.isBookingOwnedByCustomer(relatedBookingId, customerUsername)) {
                return "ERR:Mã đặt vé không hợp lệ hoặc không thuộc về tài khoản của bạn.";
            }
        } else {
            // ACCOUNT or OTHER — no booking ref needed
            relatedBookingId = null;
        }

        Feedback f = new Feedback();
        f.setCustomerUsername(customerUsername);
        f.setCategory(Feedback.CAT_SUPPORT);
        f.setSubCategory(subCategory);
        f.setRelatedBookingId(relatedBookingId);
        f.setSubject(subject.trim());
        f.setMessage(message.trim());
        f.setStatus(Feedback.STATUS_NEW);

        long id = feedbackDAO.insert(f);
        if (id < 0) return "ERR:Không thể lưu yêu cầu hỗ trợ. Vui lòng thử lại sau.";
        return id;
    }

    // ── Customer History ──────────────────────────────────────────────────────

    @Override
    public List<Feedback> getMyFeedbacks(String customerUsername) {
        return feedbackDAO.findByCustomer(customerUsername);
    }

    // ── Tracking ──────────────────────────────────────────────────────────────

    @Override
    public int countByFilter(Long branchScope, String category, String status, String search,
                             java.time.LocalDate fromDate, java.time.LocalDate toDate) {
        return feedbackDAO.countByFilter(branchScope, category, status, search, fromDate, toDate);
    }

    @Override
    public List<Feedback> getByFilter(Long branchScope, String category, String status, String search,
                                      java.time.LocalDate fromDate, java.time.LocalDate toDate,
                                      int page, int pageSize) {
        int safePage = Math.max(1, page);
        int safeSize = (pageSize > 0 && pageSize <= 100) ? pageSize : 20;
        return feedbackDAO.findByFilter(branchScope, category, status, search, fromDate, toDate, safePage, safeSize);
    }

    @Override
    public Map<String, Integer> getStatusSummary(Long branchScope) {
        return feedbackDAO.countGroupByStatus(branchScope);
    }

    @Override
    public String updateStatus(long feedbackId, String newStatus, String response,
                               String handledBy, Long branchScope) {

        // Validate status value
        if (!VALID_STATUSES.contains(newStatus)) {
            return "Trạng thái không hợp lệ.";
        }

        // Response is required when resolving or closing
        if ((Feedback.STATUS_RESOLVED.equals(newStatus) || Feedback.STATUS_CLOSED.equals(newStatus))
                && ValidationUtil.isNullOrEmpty(response)) {
            return "Vui lòng nhập nội dung phản hồi trước khi đánh dấu là đã giải quyết/đóng.";
        }

        // Verify feedback exists
        Feedback existing = feedbackDAO.findById(feedbackId);
        if (existing == null) {
            return "Không tìm thấy phản hồi.";
        }

        // Enforce branch scope for non-Admin roles
        if (branchScope != null) {
            if (existing.getBranchId() == null || !branchScope.equals(existing.getBranchId())) {
                return "Bạn không có quyền cập nhật phản hồi này.";
            }
        }

        boolean ok = feedbackDAO.updateStatus(feedbackId, newStatus,
                ValidationUtil.isNullOrEmpty(response) ? null : response.trim(),
                handledBy, branchScope);

        if (!ok) return "Không thể cập nhật. Vui lòng thử lại.";

        // Notify customer if resolved
        if ((Feedback.STATUS_RESOLVED.equals(newStatus) || Feedback.STATUS_CLOSED.equals(newStatus))
                && existing.getCustomerUsername() != null) {
            try {
                String categoryLabel = Feedback.CAT_COMPLAINT.equals(existing.getCategory())
                        ? "Khiếu nại" : "Yêu cầu hỗ trợ";
                notificationService.create(
                        existing.getCustomerUsername(),
                        categoryLabel + " của bạn đã được giải quyết",
                        "Phản hồi: " + (response != null ? response.trim() : ""),
                        Notification.TYPE_FEEDBACK,
                        feedbackId);
            } catch (Exception e) {
                System.err.println("[FeedbackService] Loi gui notification: " + e.getMessage());
            }
        }

        return null; // null = success
    }

    @Override
    public List<Feedback> getForExport(Long branchScope, String category, String status, String search,
                                       java.time.LocalDate fromDate, java.time.LocalDate toDate) {
        return feedbackDAO.findAllForExport(branchScope, category, status, search, fromDate, toDate);
    }

    // ── Validation helpers ────────────────────────────────────────────────────

    private String validateSubject(String subject) {
        if (ValidationUtil.isNullOrEmpty(subject)) return "Tiêu đề không được để trống.";
        int len = subject.trim().length();
        if (len < 5)   return "Tiêu đề phải có ít nhất 5 ký tự.";
        if (len > 150) return "Tiêu đề không được vượt quá 150 ký tự.";
        return null;
    }

    private String validateMessage(String message) {
        if (ValidationUtil.isNullOrEmpty(message)) return "Nội dung không được để trống.";
        int len = message.trim().length();
        if (len < 10)   return "Nội dung phải có ít nhất 10 ký tự.";
        if (len > 2000) return "Nội dung không được vượt quá 2000 ký tự.";
        return null;
    }
}
