package com.mbcms.service;

import com.mbcms.model.Feedback;
import java.util.List;
import java.util.Map;

/**
 * FeedbackService - business logic cho Complaint, Support Request va Feedback Tracking.
 */
public interface FeedbackService {

    // ── Customer: Submit Complaint ────────────────────────────────────────────

    /**
     * Gui khieu nai (COMPLAINT) ve mot suat chieu cu the.
     * Validate: subject (5-150 ky tu), message (10-2000 ky tu),
     * showtime_id phai co booking CONFIRMED/USED cua customer nay.
     *
     * @param customerUsername  username dang nhap
     * @param relatedShowtimeId suat chieu khieu nai (bat buoc)
     * @param subject           tieu de
     * @param message           noi dung chi tiet
     * @return feedback_id moi tao, hoac thong bao loi (String bat dau bang "ERR:")
     */
    Object submitComplaint(String customerUsername, long relatedShowtimeId,
                           String subject, String message);

    // ── Customer: Submit Support Request ─────────────────────────────────────

    /**
     * Gui yeu cau ho tro (SUPPORT).
     * Validate: subCategory (BOOKING/ACCOUNT/OTHER), subject (5-150), message (10-2000).
     * Neu subCategory=BOOKING: relatedBookingId phai thuoc ve customer.
     *
     * @param customerUsername  username dang nhap
     * @param subCategory       BOOKING | ACCOUNT | OTHER
     * @param relatedBookingId  null neu khong phai BOOKING sub-category
     * @param subject           tieu de
     * @param message           noi dung chi tiet
     * @return feedback_id moi tao, hoac thong bao loi (String bat dau bang "ERR:")
     */
    Object submitSupportRequest(String customerUsername, String subCategory,
                                Long relatedBookingId, String subject, String message);

    // ── Customer: History ─────────────────────────────────────────────────────

    /**
     * Tat ca feedback (moi category) cua 1 customer, moi nhat truoc.
     */
    List<Feedback> getMyFeedbacks(String customerUsername);

    // ── Tracking: Staff / Manager / Admin ─────────────────────────────────────

    /**
     * Tong so feedback theo filter (phan trang).
     *
     * @param branchScope null = Admin (toan he thong), co gia tri = gioi han branch cu the
     */
    int countByFilter(Long branchScope, String category, String status, String search,
                      java.time.LocalDate fromDate, java.time.LocalDate toDate);

    /**
     * Danh sach feedback co phan trang.
     */
    List<Feedback> getByFilter(Long branchScope, String category, String status, String search,
                               java.time.LocalDate fromDate, java.time.LocalDate toDate,
                               int page, int pageSize);

    /**
     * Summary cards: dem theo status de hien thi.
     */
    Map<String, Integer> getStatusSummary(Long branchScope);

    /**
     * Top 3 feedback dang cho xu ly (status = NEW / Pending), sap xep theo
     * thoi gian gui som nhat truoc, giup staff uu tien xu ly cac khieu nai/
     * yeu cau ho tro chua duoc giai quyet lau nhat.
     *
     * @param branchScope null = Admin (toan he thong), co gia tri = gioi han branch cu the
     */
    List<Feedback> getTopPendingFeedbacks(Long branchScope);

    /**
     * Cap nhat status va tra loi khieu nai.
     * Validate: newStatus hop le, response bat buoc khi RESOLVED/CLOSED.
     * Enforce: branchScope dam bao Staff/Manager chi update feedback cua branch minh.
     *
     * @param handledBy    username cua employee thuc hien
     * @param branchScope  null = Admin; co gia tri = branch phai khop voi feedback.branch_id
     * @return null neu thanh cong; chuoi loi neu that bai
     */
    String updateStatus(long feedbackId, String newStatus, String response,
                        String handledBy, Long branchScope);

    /**
     * Lay danh sach toi da 5000 record de export CSV.
     */
    List<Feedback> getForExport(Long branchScope, String category, String status, String search,
                                java.time.LocalDate fromDate, java.time.LocalDate toDate);
}