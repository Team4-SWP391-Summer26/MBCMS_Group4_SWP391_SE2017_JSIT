package com.mbcms.controller.branch;

import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Showtime;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * ShowtimeListServlet - owner: <b>HungNT</b>. SRS 3.5.2.1 Showtime List Screen,
 * layout theo man 22_mgr-showtimes cua Frontend demo prototype
 * (UC20/UC21/UC22).
 *
 * GET /branch/showtimes - man hinh day-centric: chon ngay (date pills), KPI cua
 * ngay do, schedule timeline theo phong, va bang showtime (filter them theo
 * movie/room).
 *
 * Nam duoi /branch/* nen AuthFilter + RoleFilter (BRANCH_MANAGER) +
 * BranchFilter da chay truoc; "currentBranchId" trong session chac chan !=
 * null.
 */
@WebServlet("/branch/showtimes")
public class ShowtimeListServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/showtime/list.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req); // ten branch cho sidebar + scope notice

        // --- Filter params; ngay mac dinh la hom nay (man hinh day-centric nhu prototype) ---
        Long movieId = parseLongOrNull(req.getParameter("movieId"));
        Long roomId = parseLongOrNull(req.getParameter("roomId"));
        LocalDate date = parseDateOrNull(req.getParameter("date"));
        LocalDate todayVn = DateTimeUtil.nowVietnam().toLocalDate();
        LocalDate selectedDate = (date != null) ? date : todayVn;

        ShowtimeDAO showtimeDAO = new ShowtimeDAOImpl();
        MovieDAO movieDAO = new MovieDAOImpl();
        RoomDAO roomDAO = new RoomDAOImpl();

        // Bang: theo movie/room filter. Timeline + KPI: toan canh ca ngay (khong loc movie/room).
        List<Showtime> tableShowtimes = showtimeDAO.findByBranch(branchId, movieId, roomId, selectedDate);
        List<Showtime> dayShowtimes = (movieId == null && roomId == null)
                ? tableShowtimes
                : showtimeDAO.findByBranch(branchId, null, null, selectedDate);

        // --- KPI cua ngay (tu du lieu showtime co san) ---
        int seatsSold = 0;
        int totalCapacity = 0;
        int scheduledCount = 0;
        for (Showtime st : dayShowtimes) {
            if (Showtime.STATUS_SCHEDULED.equals(st.getStatus())) {
                scheduledCount++;
                seatsSold += st.getBookedSeats();
                totalCapacity += st.getRoomCapacity();
            }
        }
        int occupancyPct = (totalCapacity > 0) ? (seatsSold * 100 / totalCapacity) : 0;

        // --- Date pills: 7 ngay tu hom nay (gio Vietnam) ---
        List<Map<String, String>> datePills = new ArrayList<>();
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH);
        DateTimeFormatter dmFmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 0; i < 7; i++) {
            LocalDate d = todayVn.plusDays(i);
            Map<String, String> pill = new HashMap<>();
            pill.put("iso", d.toString());
            pill.put("day", d.format(dayFmt));
            pill.put("dm", d.format(dmFmt));
            datePills.add(pill);
        }

        req.setAttribute("showtimes", tableShowtimes);
        req.setAttribute("dayShowtimes", dayShowtimes);
        // "now" de JSP tinh status dong (suat SCHEDULED qua gio = Ended/Now showing)
        // va an nut Edit/Cancel voi suat da bat dau. Dung gio VN (cung moc form/DAO).
        LocalDateTime nowVn = DateTimeUtil.nowVietnam();
        req.setAttribute("nowLdt", nowVn);
        // Dropdown filter chi liet ke phim da cap cho chi nhanh nay (movie_branch).
        req.setAttribute("movies", movieDAO.findActiveMoviesForBranch(branchId));
        req.setAttribute("rooms", roomDAO.findActiveByBranch(branchId));
        req.setAttribute("filterMovieId", movieId);
        req.setAttribute("filterRoomId", roomId);
        req.setAttribute("selectedDate", selectedDate.toString());
        req.setAttribute("selectedDateLong",
                selectedDate.format(DateTimeFormatter.ofPattern("EEEE, dd MMMM yyyy", Locale.ENGLISH)));
        req.setAttribute("datePills", datePills);
        req.setAttribute("kpiCount", scheduledCount);
        req.setAttribute("kpiSeatsSold", seatsSold);
        req.setAttribute("kpiOccupancy", occupancyPct);

        // Flash tu che do "Multiple days" cua Create (tong ket dai, khong nhet vao
        // query param duoc): doc 1 lan tu session roi xoa ngay (one-shot).
        Object flash = req.getSession(false).getAttribute("flashSuccessMsg");
        if (flash != null) {
            req.getSession(false).removeAttribute("flashSuccessMsg");
            req.setAttribute("successMsg", flash.toString());
        }

        // PRG: cac servlet Create/Edit/Cancel redirect ve day kem query param -> toast
        if ("1".equals(req.getParameter("created"))) {
            req.setAttribute("successMsg", "Added successfully.");          // MSG04
        } else if ("1".equals(req.getParameter("updated"))) {
            req.setAttribute("successMsg", "Updated successfully.");        // MSG03
        } else if ("1".equals(req.getParameter("cancelled"))) {
            req.setAttribute("successMsg", "Showtime cancelled successfully.");
        } else if ("1".equals(req.getParameter("alreadyStarted"))) {
            req.setAttribute("errorMsg",
                    "Cannot edit this showtime because it has already started. "
                            + "Use the eye (Monitor) button to view occupancy, or pick an upcoming screening.");
        } else if ("1".equals(req.getParameter("notEditable"))) {
            req.setAttribute("errorMsg",
                    "Cannot edit this showtime because it is cancelled or already ended.");
        } else if ("1".equals(req.getParameter("notFound"))) {
            req.setAttribute("errorMsg",
                    "Showtime not found (removed, or not assigned to this cinema).");
        } else if (req.getParameter("cancelErr") != null) {
            switch (req.getParameter("cancelErr")) {
                case "HAS_BOOKINGS":
                    req.setAttribute("errorMsg",
                            "Cannot cancel: this showtime already has active bookings.");
                    break;
                case "NOT_EDITABLE":
                    req.setAttribute("errorMsg",
                            "This showtime can no longer be cancelled (already started, cancelled, or ended).");
                    break;
                default:
                    req.setAttribute("errorMsg", "System error, please try again later.");
            }
        }

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    private Long parseLongOrNull(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private LocalDate parseDateOrNull(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(s.trim()); // yyyy-MM-dd tu input type=date
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
