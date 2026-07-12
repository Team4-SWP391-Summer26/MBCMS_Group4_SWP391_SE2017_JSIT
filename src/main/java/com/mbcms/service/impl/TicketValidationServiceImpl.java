package com.mbcms.service.impl;

import com.mbcms.dao.BookingDAO;
import com.mbcms.dao.impl.BookingDAOImpl;
import com.mbcms.model.Booking;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.ShowtimeAttendance;
import com.mbcms.model.TicketValidationResult;
import com.mbcms.service.TicketValidationService;
import com.mbcms.util.DateTimeUtil;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

/**
 * TicketValidationServiceImpl - kiem soat ve tai cua vao.
 *
 * Business rules (SRS):
 *  - Chi ve CONFIRMED (da thanh toan) moi duoc vao rap.
 *  - Duplicate entry: bookings.status USED -> tu choi (ALREADY_USED); guard
 *    that su nam o SQL "UPDATE ... WHERE status='CONFIRMED'" (atomic).
 *  - Cua so vao rap: tu ENTRY_WINDOW_MINUTES phut truoc gio chieu den het
 *    suat (start_time + duration). Ngoai cua so -> TOO_EARLY / EXPIRED.
 *  - Branch scope: staff chi kiem soat ve cua chi nhanh minh.
 */
public class TicketValidationServiceImpl implements TicketValidationService {

    /** Cho khach vao rap som nhat 45 phut truoc gio chieu. */
    private static final int ENTRY_WINDOW_MINUTES = 45;

    private final BookingDAO bookingDAO = new BookingDAOImpl();

    @Override
    public TicketValidationResult validateTicket(String bookingCode, long branchId) {
        TicketValidationResult result = new TicketValidationResult();

        if (bookingCode == null || bookingCode.trim().isEmpty()) {
            result.setStatus(TicketValidationResult.NOT_FOUND);
            result.setMessage("Please enter a ticket code.");
            return result;
        }

        Booking booking = bookingDAO.findByCode(bookingCode.trim().toUpperCase());
        if (booking == null) {
            result.setStatus(TicketValidationResult.NOT_FOUND);
            result.setMessage("No ticket found with code \"" + bookingCode.trim().toUpperCase() + "\".");
            return result;
        }

        BookingTicket ticket = bookingDAO.findTicket(booking.getBookingId());
        if (ticket == null) {
            result.setStatus(TicketValidationResult.NOT_FOUND);
            result.setMessage("Ticket details were not found.");
            return result;
        }

        // Branch scope: khong lo thong tin ve cua chi nhanh khac
        if (ticket.getBranchId() != branchId) {
            result.setStatus(TicketValidationResult.WRONG_BRANCH);
            result.setMessage("This ticket belongs to another branch and cannot be checked in here.");
            return result;
        }

        result.setTicket(ticket);

        switch (booking.getStatus()) {
            case Booking.STATUS_USED:
                result.setStatus(TicketValidationResult.ALREADY_USED);
                result.setMessage("This ticket has already been used. Entry denied.");
                result.setCheckInTime(bookingDAO.findCheckInTime(booking.getBookingId()));
                return result;
            case Booking.STATUS_PENDING:
                result.setStatus(TicketValidationResult.NOT_PAID);
                result.setMessage("This ticket has not been paid yet (PENDING). Please direct the guest to the counter.");
                return result;
            case Booking.STATUS_CANCELLED:
                result.setStatus(TicketValidationResult.CANCELLED);
                result.setMessage("This ticket has been cancelled and is no longer valid.");
                return result;
            case Booking.STATUS_NO_SHOW:
                result.setStatus(TicketValidationResult.NO_SHOW);
                result.setMessage("This ticket is marked NO_SHOW (showtime ended without check-in). Entry denied.");
                return result;
            default:
                break; // CONFIRMED -> kiem tra suat chieu
        }

        // Validate entry theo suat chieu hien tai.
        // Dung gio Viet Nam (start_time nhap theo gio VN) - khong phu thuoc tz server.
        LocalDateTime now = DateTimeUtil.nowVietnam();
        LocalDateTime start = ticket.getStartTime();
        LocalDateTime end = start.plusMinutes(ticket.getDurationMin());

        if (now.isBefore(start.minusMinutes(ENTRY_WINDOW_MINUTES))) {
            result.setStatus(TicketValidationResult.TOO_EARLY);
            result.setMessage("It is too early to enter. Doors open " + ENTRY_WINDOW_MINUTES
                    + " minutes before showtime.");
            return result;
        }
        if (now.isAfter(end)) {
            result.setStatus(TicketValidationResult.EXPIRED);
            result.setMessage("The showtime has ended. This ticket is no longer valid.");
            return result;
        }

        result.setStatus(TicketValidationResult.VALID);
        result.setMessage("Valid ticket. Entry is allowed.");
        return result;
    }

    @Override
    public TicketValidationResult checkInTicket(String bookingCode, long branchId) {
        // Validate lai ngay truoc khi ghi (khong tin state cu tren man hinh)
        TicketValidationResult result = validateTicket(bookingCode, branchId);
        if (!result.isAllowEntry()) {
            return result;
        }

        long bookingId = result.getTicket().getBookingId();
        int rows = bookingDAO.checkInBooking(bookingId);
        if (rows == 0) {
            // Race: request khac vua check-in giua validate va update.
            // Guard SQL (WHERE status='CONFIRMED') dam bao khong co double entry.
            result.setStatus(TicketValidationResult.ALREADY_USED);
            result.setMessage("This ticket was just checked in by another request. Entry denied.");
            result.setCheckInTime(bookingDAO.findCheckInTime(bookingId));
            return result;
        }

        result.setStatus(TicketValidationResult.CHECKED_IN);
        result.setMessage("Check-in successful. Please let the guest enter.");
        result.setCheckInTime(bookingDAO.findCheckInTime(bookingId));
        return result;
    }

    @Override
    public List<ShowtimeAttendance> getAttendance(long branchId, LocalDate date) {
        return bookingDAO.findAttendanceByBranch(branchId, date);
    }
}
