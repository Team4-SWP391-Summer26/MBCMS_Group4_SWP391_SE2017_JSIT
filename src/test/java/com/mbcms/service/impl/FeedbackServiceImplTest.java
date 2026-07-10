package com.mbcms.service.impl;

import com.mbcms.dao.FeedbackDAO;
import com.mbcms.model.Feedback;
import com.mbcms.model.Notification;
import com.mbcms.service.NotificationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class FeedbackServiceImplTest {

    @Mock
    private FeedbackDAO feedbackDAO;

    @Mock
    private NotificationService notificationService;

    private FeedbackServiceImpl feedbackService;

    @BeforeEach
    void setUp() {
        feedbackService = new FeedbackServiceImpl(feedbackDAO, notificationService);
    }

    // ── submitComplaint Tests ──────────────────────────────────────────────

    @Test
    void submitComplaint_subjectTooShort_returnsError() {
        Object result = feedbackService.submitComplaint("user1", 101L, "Abc", "This is a detailed message of 10+ characters.");
        assertTrue(result instanceof String);
        assertTrue(((String) result).startsWith("ERR:Tiêu đề"));
    }

    @Test
    void submitComplaint_messageTooShort_returnsError() {
        Object result = feedbackService.submitComplaint("user1", 101L, "Valid Subject", "Short");
        assertTrue(result instanceof String);
        assertTrue(((String) result).startsWith("ERR:Nội dung"));
    }

    @Test
    void submitComplaint_noConfirmedBooking_returnsError() {
        when(feedbackDAO.hasConfirmedBookingForShowtime(101L, "user1")).thenReturn(false);

        Object result = feedbackService.submitComplaint("user1", 101L, "Valid Subject", "This is a detailed message of 10+ characters.");
        assertTrue(result instanceof String);
        assertEquals("ERR:Bạn chỉ có thể gửi khiếu nại về suất chiếu mà bạn đã đặt vé thành công.", result);
    }

    @Test
    void submitComplaint_success_returnsFeedbackId() {
        when(feedbackDAO.hasConfirmedBookingForShowtime(101L, "user1")).thenReturn(true);
        when(feedbackDAO.insert(any(Feedback.class))).thenReturn(12345L);

        Object result = feedbackService.submitComplaint("user1", 101L, "Valid Subject", "This is a detailed message of 10+ characters.");
        assertEquals(12345L, result);

        ArgumentCaptor<Feedback> captor = ArgumentCaptor.forClass(Feedback.class);
        verify(feedbackDAO).insert(captor.capture());
        Feedback captured = captor.getValue();
        assertEquals("user1", captured.getCustomerUsername());
        assertEquals(Feedback.CAT_COMPLAINT, captured.getCategory());
        assertEquals(101L, captured.getRelatedShowtimeId());
        assertEquals("Valid Subject", captured.getSubject());
        assertEquals("This is a detailed message of 10+ characters.", captured.getMessage());
        assertEquals(Feedback.STATUS_NEW, captured.getStatus());
    }

    // ── submitSupportRequest Tests ──────────────────────────────────────────

    @Test
    void submitSupportRequest_invalidSubCategory_returnsError() {
        Object result = feedbackService.submitSupportRequest("user1", "INVALID", null, "Valid Subject", "This is a detailed message of 10+ characters.");
        assertTrue(result instanceof String);
        assertEquals("ERR:Loại yêu cầu hỗ trợ không hợp lệ.", result);
    }

    @Test
    void submitSupportRequest_bookingSubCategoryWithoutBookingId_returnsError() {
        Object result = feedbackService.submitSupportRequest("user1", Feedback.SUB_BOOKING, null, "Valid Subject", "This is a detailed message of 10+ characters.");
        assertTrue(result instanceof String);
        assertEquals("ERR:Vui lòng chọn mã đặt vé liên quan.", result);
    }

    @Test
    void submitSupportRequest_bookingSubCategoryNotOwned_returnsError() {
        when(feedbackDAO.isBookingOwnedByCustomer(555L, "user1")).thenReturn(false);

        Object result = feedbackService.submitSupportRequest("user1", Feedback.SUB_BOOKING, 555L, "Valid Subject", "This is a detailed message of 10+ characters.");
        assertTrue(result instanceof String);
        assertEquals("ERR:Mã đặt vé không hợp lệ hoặc không thuộc về tài khoản của bạn.", result);
    }

    @Test
    void submitSupportRequest_success_returnsFeedbackId() {
        when(feedbackDAO.isBookingOwnedByCustomer(555L, "user1")).thenReturn(true);
        when(feedbackDAO.insert(any(Feedback.class))).thenReturn(12345L);

        Object result = feedbackService.submitSupportRequest("user1", Feedback.SUB_BOOKING, 555L, "Valid Subject", "This is a detailed message of 10+ characters.");
        assertEquals(12345L, result);

        ArgumentCaptor<Feedback> captor = ArgumentCaptor.forClass(Feedback.class);
        verify(feedbackDAO).insert(captor.capture());
        Feedback captured = captor.getValue();
        assertEquals("user1", captured.getCustomerUsername());
        assertEquals(Feedback.CAT_SUPPORT, captured.getCategory());
        assertEquals(Feedback.SUB_BOOKING, captured.getSubCategory());
        assertEquals(555L, captured.getRelatedBookingId());
        assertEquals("Valid Subject", captured.getSubject());
        assertEquals("This is a detailed message of 10+ characters.", captured.getMessage());
        assertEquals(Feedback.STATUS_NEW, captured.getStatus());
    }

    // ── updateStatus Tests ──────────────────────────────────────────────────

    @Test
    void updateStatus_invalidStatus_returnsError() {
        String result = feedbackService.updateStatus(123L, "INVALID_STATUS", "Resp", "admin1", null);
        assertEquals("Trạng thái không hợp lệ.", result);
    }

    @Test
    void updateStatus_missingResponseOnResolved_returnsError() {
        String result = feedbackService.updateStatus(123L, Feedback.STATUS_RESOLVED, "", "admin1", null);
        assertEquals("Vui lòng nhập nội dung phản hồi trước khi đánh dấu là đã giải quyết/đóng.", result);
    }

    @Test
    void updateStatus_feedbackNotFound_returnsError() {
        when(feedbackDAO.findById(123L)).thenReturn(null);
        String result = feedbackService.updateStatus(123L, Feedback.STATUS_IN_PROGRESS, "Working on it", "admin1", null);
        assertEquals("Không tìm thấy phản hồi.", result);
    }

    @Test
    void updateStatus_crossBranchAccessBlocked_returnsError() {
        Feedback fb = new Feedback();
        fb.setFeedbackId(123L);
        fb.setBranchId(1L); // Branch 1

        when(feedbackDAO.findById(123L)).thenReturn(fb);

        // Manager from branch 2 (branchScope = 2L) tries to update branch 1 feedback
        String result = feedbackService.updateStatus(123L, Feedback.STATUS_IN_PROGRESS, "Working on it", "manager2", 2L);
        assertEquals("Bạn không có quyền cập nhật phản hồi này.", result);
    }

    @Test
    void updateStatus_success_updatesAndNotifies() {
        Feedback fb = new Feedback();
        fb.setFeedbackId(123L);
        fb.setCustomerUsername("user1");
        fb.setCategory(Feedback.CAT_COMPLAINT);
        fb.setBranchId(1L);

        when(feedbackDAO.findById(123L)).thenReturn(fb);
        when(feedbackDAO.updateStatus(123L, Feedback.STATUS_RESOLVED, "Resolved message", "manager1", 1L)).thenReturn(true);

        String result = feedbackService.updateStatus(123L, Feedback.STATUS_RESOLVED, "Resolved message", "manager1", 1L);
        assertNull(result);

        // Verify DB update called
        verify(feedbackDAO).updateStatus(123L, Feedback.STATUS_RESOLVED, "Resolved message", "manager1", 1L);

        // Verify Notification sent
        verify(notificationService).create(
                eq("user1"),
                eq("Khiếu nại của bạn đã được giải quyết"),
                contains("Resolved message"),
                eq(Notification.TYPE_FEEDBACK),
                eq(123L)
        );
    }
}
