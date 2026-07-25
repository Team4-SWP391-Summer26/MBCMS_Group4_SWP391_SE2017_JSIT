package com.mbcms.dao;

import com.mbcms.model.Feedback;
import java.util.List;
import java.util.Map;

/**
 * FeedbackDAO - CRUD + tracking operations cho ban feedbacks mo rong.
 * Ho tro ca Complaint (COMPLAINT) va Support Request (SUPPORT).
 */
public interface FeedbackDAO {

    // ── Insert ───────────────────────────────────────────────────────────────

    /**
     * Them feedback moi. branch_id duoc tu dong resolve:
     *  - category=COMPLAINT: lay tu related_showtime_id -> rooms -> branches
     *  - category=SUPPORT + sub_category=BOOKING: lay tu related_booking_id -> showtimes -> rooms -> branches
     *  - category=GENERAL: NULL (toan he thong)
     * Tra ve feedback_id duoc sinh ra, hoac -1 neu that bai.
     */
    long insert(Feedback feedback);

    // ── Queries for Customers ────────────────────────────────────────────────

    /**
     * Tat ca feedback cua 1 customer (tat ca category), sap xep moi nhat truoc.
     */
    List<Feedback> findByCustomer(String customerUsername);

    /**
     * Tim feedback theo ID. Tra ve null neu khong tim thay.
     */
    Feedback findById(long feedbackId);

    /**
     * Kiem tra booking co thuoc ve customer khong (chong IDOR).
     * True neu booking_id ton tai va customer_username khop.
     */
    boolean isBookingOwnedByCustomer(long bookingId, String customerUsername);

    /**
     * Kiem tra showtime co lien quan den booking da CONFIRMED/USED cua customer khong.
     * True neu customer co booking CONFIRMED|USED cho showtime_id do.
     */
    boolean hasConfirmedBookingForShowtime(long showtimeId, String customerUsername);

    // ── Queries for Staff / Manager / Admin tracking ─────────────────────────

    /**
     * Tong so feedback theo filter (de tinh phan trang).
     *
     * @param branchScope  null = toan he thong (Admin), co gia tri = gioi han 1 branch
     * @param category     null = tat ca, "COMPLAINT" hoac "SUPPORT"
     * @param status       null = tat ca, "NEW"/"IN_PROGRESS"/"RESOLVED"/"CLOSED"
     * @param search       null = khong tim kiem; tim trong name, email, subject
     * @param fromDate     null = khong gioi han duoi, ngay bat dau gui
     * @param toDate       null = khong gioi han tren, ngay ket thuc gui
     */
    int countByFilter(Long branchScope, String category, String status, String search,
                      java.time.LocalDate fromDate, java.time.LocalDate toDate);

    /**
     * Danh sach feedback co phan trang, theo filter. Sap xep: NEW|IN_PROGRESS truoc, moi nhat truoc.
     */
    List<Feedback> findByFilter(Long branchScope, String category, String status, String search,
                                java.time.LocalDate fromDate, java.time.LocalDate toDate,
                                int page, int pageSize);

    /**
     * Dem so feedback nhom theo status de hien thi summary cards.
     * Tra ve Map<status, count>.
     */
    Map<String, Integer> countGroupByStatus(Long branchScope);

    /**
     * Lay top N feedback dang cho xu ly (status = NEW), sap xep theo thoi gian
     * gui som nhat truoc (created_at ASC) de staff uu tien xu ly cac feedback
     * cho lau nhat.
     *
     * @param branchScope null = toan he thong (Admin), co gia tri = gioi han 1 branch
     * @param limit       so luong ban ghi toi da can lay (vd: 3)
     */
    List<Feedback> findTopPending(Long branchScope, int limit);

    // ── Status update ────────────────────────────────────────────────────────

    /**
     * Cap nhat status + response + handled_by + resolved_at.
     * resolved_at tu dong set khi newStatus = RESOLVED hoac CLOSED.
     *
     * @param branchScope null = Admin (khong kiem tra branch); co gia tri = kiem tra branch_id
     * @return true neu update thanh cong (1 row affected)
     */
    boolean updateStatus(long feedbackId, String newStatus, String response,
                         String handledBy, Long branchScope);

    // ── Export ───────────────────────────────────────────────────────────────

    /**
     * Lay toi da 5000 record de export CSV. Dung cung filter voi findByFilter.
     */
    List<Feedback> findAllForExport(Long branchScope, String category, String status, String search,
                                    java.time.LocalDate fromDate, java.time.LocalDate toDate);
}