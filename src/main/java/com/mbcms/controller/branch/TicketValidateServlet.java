package com.mbcms.controller.branch;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mbcms.model.BookingTicket;
import com.mbcms.model.ShowtimeAttendance;
import com.mbcms.model.TicketValidationResult;
import com.mbcms.service.TicketValidationService;
import com.mbcms.service.impl.TicketValidationServiceImpl;
import com.mbcms.util.DateTimeUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * TicketValidateServlet - kiem soat ve tai cua vao cho Branch Staff.
 * Mapped: /staff/ticket-validate
 *
 * GET  : render console (form nhap ma ve + bang attendance theo ngay)
 * POST : JSON API — action=validate (soi ve, read-only)
 *                   action=checkin  (CONFIRMED -> USED, chong duplicate entry)
 * Thay the QR scanner bang nhap ma ve thu cong (khong can thiet bi quet).
 */
@WebServlet("/staff/ticket-validate")
public class TicketValidateServlet extends HttpServlet {

    private static final DateTimeFormatter DTF = DateTimeFormatter.ofPattern("HH:mm dd/MM/yyyy");

    private final TicketValidationService validationService = new TicketValidationServiceImpl();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long branchId = (Long) req.getSession().getAttribute("currentBranchId");
        if (branchId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        ConsoleSupport.ensureBranchName(req);

        LocalDate date = parseDateOrToday(req.getParameter("date"));
        List<ShowtimeAttendance> attendance = validationService.getAttendance(branchId, date);

        int totalBooked = 0;
        int totalCheckedIn = 0;
        for (ShowtimeAttendance a : attendance) {
            totalBooked += a.getBookedSeats();
            totalCheckedIn += a.getCheckedInSeats();
        }

        req.setAttribute("attendance", attendance);
        req.setAttribute("selectedDate", date.toString());          // yyyy-MM-dd cho input[type=date]
        req.setAttribute("totalBooked", totalBooked);
        req.setAttribute("totalCheckedIn", totalCheckedIn);

        req.getRequestDispatcher("/WEB-INF/views/branch/ticket-validate.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> json = new HashMap<>();

        Long branchId = (Long) req.getSession().getAttribute("currentBranchId");
        if (branchId == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            json.put("status", "ERROR");
            json.put("message", "Invalid session. Please sign in again.");
            mapper.writeValue(resp.getWriter(), json);
            return;
        }

        String action = req.getParameter("action");
        String code = req.getParameter("code");

        try {
            TicketValidationResult result;
            if ("checkin".equals(action)) {
                result = validationService.checkInTicket(code, branchId);
            } else if ("validate".equals(action)) {
                result = validationService.validateTicket(code, branchId);
            } else {
                json.put("status", "ERROR");
                json.put("message", "Invalid action.");
                mapper.writeValue(resp.getWriter(), json);
                return;
            }
            mapper.writeValue(resp.getWriter(), toJson(result));
        } catch (RuntimeException e) {
            json.put("status", "ERROR");
            json.put("message", "System error while validating the ticket: " + e.getMessage());
            mapper.writeValue(resp.getWriter(), json);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private Map<String, Object> toJson(TicketValidationResult result) {
        Map<String, Object> json = new HashMap<>();
        json.put("status", result.getStatus());
        json.put("message", result.getMessage());
        json.put("allowEntry", result.isAllowEntry());

        if (result.getCheckInTime() != null) {
            json.put("checkInTime", formatUtcAsLocal(result.getCheckInTime()));
        }

        BookingTicket t = result.getTicket();
        if (t != null) {
            Map<String, Object> ticket = new HashMap<>();
            ticket.put("bookingCode", t.getBookingCode());
            ticket.put("movieTitle", t.getMovieTitle());
            ticket.put("rated", t.getMovieRated());
            ticket.put("posterUrl", t.getPosterUrl());
            ticket.put("roomName", t.getRoomName());
            ticket.put("format", t.getFormat());
            ticket.put("subtitleType", t.getSubtitleType());
            ticket.put("startTime", t.getStartTime() != null ? t.getStartTime().format(DTF) : "");
            ticket.put("seats", t.getSeatLabels());
            ticket.put("seatCount", t.getSeatLabels() != null ? t.getSeatLabels().size() : 0);
            ticket.put("customerName", t.getCustomerFullName() != null
                    ? t.getCustomerFullName() : "Walk-in Guest");
            ticket.put("totalAmount", t.getTotalAmount());
            json.put("ticket", ticket);
        }
        return json;
    }

    /** check_in_time luu UTC (SYSUTCDATETIME) -> hien thi theo gio Viet Nam. */
    private String formatUtcAsLocal(LocalDateTime utc) {
        return DateTimeUtil.utcToVietnam(utc).format(DTF);
    }

    private LocalDate parseDateOrToday(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return LocalDate.now();
        }
        try {
            return LocalDate.parse(raw.trim());
        } catch (DateTimeParseException e) {
            return LocalDate.now();
        }
    }
}
