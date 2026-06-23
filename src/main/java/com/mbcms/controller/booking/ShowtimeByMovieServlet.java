package com.mbcms.controller.booking;

import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.service.CinemaBrowseService;
import com.mbcms.service.impl.CinemaBrowseServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * ShowtimeByMovieServlet
 *
 * Buoc 3 cua luong dat ve: chon suat chieu CUA phim DA chon, TRONG chi nhanh da chon.
 *
 * GET /booking/showtimes?branchId={id}&movieId={id}
 *     -> cac suat chieu SCHEDULED, sap toi, gom nhom theo ngay
 *     -> nguoi dung chon 1 suat, chuyen sang /booking/seats?showtimeId={id}
 *        (man hinh chon ghe - da co san o SeatAvailabilityServlet)
 */
@WebServlet("/booking/showtimes")
public class ShowtimeByMovieServlet extends HttpServlet {

    private final CinemaBrowseService browseService = new CinemaBrowseServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long branchId = parseLong(req.getParameter("branchId"));
        Long movieId = parseLong(req.getParameter("movieId"));

        if (branchId == null || movieId == null) {
            resp.sendRedirect(req.getContextPath() + "/booking/branches");
            return;
        }

        Branch branch = browseService.getActiveBranch(branchId);
        if (branch == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay chi nhanh id=" + branchId);
            return;
        }

        Movie movie = browseService.getMovie(movieId);
        if (movie == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay phim id=" + movieId);
            return;
        }

        Map<LocalDate, List<Showtime>> showtimesByDate =
                browseService.getShowtimesByBranchAndMovie(branchId, movieId);

        req.setAttribute("branch", branch);
        req.setAttribute("movie", movie);
        req.setAttribute("dayGroups", toDayGroups(showtimesByDate));

        req.getRequestDispatcher("/WEB-INF/views/booking/showtimes.jsp").forward(req, resp);
    }

    /**
     * Chuyen Map<LocalDate, List<Showtime>> (thu tu tang dan, tu TreeMap cua service)
     * thanh List<DayGroup> voi nhan ngay/gio da dinh dang san - de JSP chi viec
     * lap qua va in ra, khong phai tu xu ly LocalDate/LocalDateTime trong EL.
     */
    private List<DayGroup> toDayGroups(Map<LocalDate, List<Showtime>> showtimesByDate) {
        DateTimeFormatter dateLabelFmt = DateTimeFormatter.ofPattern("EEE, dd/MM", Locale.ENGLISH);
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
        LocalDate today = LocalDate.now();

        List<DayGroup> groups = new ArrayList<>();
        for (Map.Entry<LocalDate, List<Showtime>> entry : showtimesByDate.entrySet()) {
            LocalDate date = entry.getKey();
            List<ShowtimeSlot> slots = new ArrayList<>();
            for (Showtime st : entry.getValue()) {
                slots.add(new ShowtimeSlot(st.getShowtimeId(), st.getStartTime().format(timeFmt),
                        st.getFormat(), st.getSubtitleType(), st.getRoomName(), st.getBasePrice(),
                        Math.max(0, st.getRoomCapacity() - st.getBookedSeats())));
            }
            groups.add(new DayGroup(date.format(dateLabelFmt), date.equals(today), slots));
        }
        return groups;
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    /** View-model: 1 ngay chieu + danh sach suat trong ngay do (du lieu da format san cho JSP). */
    public static class DayGroup {
        private final String dateLabel;
        private final boolean today;
        private final List<ShowtimeSlot> showtimes;

        DayGroup(String dateLabel, boolean today, List<ShowtimeSlot> showtimes) {
            this.dateLabel = dateLabel;
            this.today = today;
            this.showtimes = showtimes;
        }

        public String getDateLabel() { return dateLabel; }
        public boolean isToday() { return today; }
        public List<ShowtimeSlot> getShowtimes() { return showtimes; }
    }

    /** View-model: 1 suat chieu cu the trong ngay (gio da format san, ghe con trong da tinh san). */
    public static class ShowtimeSlot {
        private final long showtimeId;
        private final String timeLabel;
        private final String format;
        private final String subtitleType;
        private final String roomName;
        private final java.math.BigDecimal basePrice;
        private final int availableSeats;

        ShowtimeSlot(long showtimeId, String timeLabel, String format, String subtitleType,
                     String roomName, java.math.BigDecimal basePrice, int availableSeats) {
            this.showtimeId = showtimeId;
            this.timeLabel = timeLabel;
            this.format = format;
            this.subtitleType = subtitleType;
            this.roomName = roomName;
            this.basePrice = basePrice;
            this.availableSeats = availableSeats;
        }

        public long getShowtimeId() { return showtimeId; }
        public String getTimeLabel() { return timeLabel; }
        public String getFormat() { return format; }
        public String getSubtitleType() { return subtitleType; }
        public String getRoomName() { return roomName; }
        public java.math.BigDecimal getBasePrice() { return basePrice; }
        public int getAvailableSeats() { return availableSeats; }
    }
}
