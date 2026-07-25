package com.mbcms.service.impl;

import com.mbcms.dao.FeedbackDAO;
import com.mbcms.dao.impl.FeedbackDAOImpl;
import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Feedback;
import com.mbcms.model.Notification;
import com.mbcms.model.Customer;
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
            return "ERR:You can only submit a complaint for a showtime that you successfully booked.";
        }

        Feedback f = new Feedback();
        f.setCustomerUsername(customerUsername);
        f.setCategory(Feedback.CAT_COMPLAINT);
        f.setRelatedShowtimeId(relatedShowtimeId);
        f.setSubject(subject.trim());
        f.setMessage(message.trim());

        // Fetch customer details to populate name & email (required NOT NULL columns)
        CustomerDAO customerDAO = new CustomerDAOImpl();
        Customer cust = customerDAO.findByUsername(customerUsername);
        if (cust != null) {
            f.setName(cust.getFullName());
            f.setEmail(cust.getEmail());
        } else {
            f.setName(customerUsername);
            f.setEmail("unknown@example.com");
        }

        f.setStatus(Feedback.STATUS_NEW);

        long id = feedbackDAO.insert(f);
        if (id < 0) return "ERR:Failed to save complaint. Please try again later.";
        return id;
    }

    // ── Submit Support Request ────────────────────────────────────────────────

    @Override
    public Object submitSupportRequest(String customerUsername, String subCategory,
                                       Long relatedBookingId, String subject, String message) {

        // Validate sub_category
        if (subCategory == null || !VALID_SUB_CATEGORIES.contains(subCategory)) {
            return "ERR:Invalid support request category.";
        }

        // Validate fields
        String subjectErr = validateSubject(subject);
        if (subjectErr != null) return "ERR:" + subjectErr;

        String messageErr = validateMessage(message);
        if (messageErr != null) return "ERR:" + messageErr;

        // Security: if BOOKING sub-category, verify ownership (prevent IDOR)
        if (Feedback.SUB_BOOKING.equals(subCategory)) {
            if (relatedBookingId == null) {
                return "ERR:Please select a related booking ID.";
            }
            if (!feedbackDAO.isBookingOwnedByCustomer(relatedBookingId, customerUsername)) {
                return "ERR:Invalid booking ID or it does not belong to your account.";
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

        // Fetch customer details to populate name & email (required NOT NULL columns)
        CustomerDAO customerDAO = new CustomerDAOImpl();
        Customer cust = customerDAO.findByUsername(customerUsername);
        if (cust != null) {
            f.setName(cust.getFullName());
            f.setEmail(cust.getEmail());
        } else {
            f.setName(customerUsername);
            f.setEmail("unknown@example.com");
        }

        f.setStatus(Feedback.STATUS_NEW);

        long id = feedbackDAO.insert(f);
        if (id < 0) return "ERR:Failed to save support request. Please try again later.";
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
    public List<Feedback> getTopPendingFeedbacks(Long branchScope) {
        return feedbackDAO.findTopPending(branchScope, 3);
    }

    @Override
    public String updateStatus(long feedbackId, String newStatus, String response,
                               String handledBy, Long branchScope) {

        // Validate status value
        if (!VALID_STATUSES.contains(newStatus)) {
            return "Invalid status.";
        }

        // Response is required when resolving or closing
        if ((Feedback.STATUS_RESOLVED.equals(newStatus) || Feedback.STATUS_CLOSED.equals(newStatus))
                && ValidationUtil.isNullOrEmpty(response)) {
            return "Please enter a response before marking as resolved or closed.";
        }

        // Verify feedback exists
        Feedback existing = feedbackDAO.findById(feedbackId);
        if (existing == null) {
            return "Feedback not found.";
        }

        // Enforce branch scope for non-Admin roles
        if (branchScope != null) {
            if (existing.getBranchId() == null || !branchScope.equals(existing.getBranchId())) {
                return "You do not have permission to update this feedback.";
            }
        }

        boolean ok = feedbackDAO.updateStatus(feedbackId, newStatus,
                ValidationUtil.isNullOrEmpty(response) ? null : response.trim(),
                handledBy, branchScope);

        if (!ok) return "Failed to update. Please try again.";

        // Notify customer if resolved
        if ((Feedback.STATUS_RESOLVED.equals(newStatus) || Feedback.STATUS_CLOSED.equals(newStatus))
                && existing.getCustomerUsername() != null) {
            try {
                String categoryLabel = Feedback.CAT_COMPLAINT.equals(existing.getCategory())
                        ? "Your complaint" : "Your support request";
                notificationService.create(
                        existing.getCustomerUsername(),
                        categoryLabel + " has been resolved",
                        "Response: " + (response != null ? response.trim() : ""),
                        Notification.TYPE_FEEDBACK,
                        feedbackId);
            } catch (Exception e) {
                System.err.println("[FeedbackService] Error sending notification: " + e.getMessage());
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
        if (ValidationUtil.isNullOrEmpty(subject)) return "Subject cannot be empty.";
        int len = subject.trim().length();
        if (len < 5)   return "Subject must be at least 5 characters.";
        if (len > 150) return "Subject cannot exceed 150 characters.";
        return null;
    }

    private String validateMessage(String message) {
        if (ValidationUtil.isNullOrEmpty(message)) return "Message cannot be empty.";
        int len = message.trim().length();
        if (len < 10)   return "Message must be at least 10 characters.";
        if (len > 2000) return "Message cannot exceed 2000 characters.";
        return null;
    }
}