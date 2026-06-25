package com.mbcms.controller.booking;

import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.service.CinemaBrowseService;
import com.mbcms.service.GuestMovieService;
import com.mbcms.service.impl.CinemaBrowseServiceImpl;
import com.mbcms.service.impl.GuestMovieServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * ShowtimeByMovieServlet
 *
 * GET /booking/showtimes?movieId={id}[&date={yyyy-MM-dd}][&branchId={id}]
 *
 * Entry point from home/movie-list "Book Tickets" button.
 * Shows all branches carrying this movie on the chosen date,
 * grouped by branch then room, with an optional branch filter.
 * Full movie detail (poster, genres, rating) is fetched via GuestMovieService.
 */
@WebServlet("/booking/showtimes")
public class ShowtimeByMovieServlet extends HttpServlet {

    private static final int SLOTS_PER_PAGE = 5;

    private final GuestMovieService guestMovieService = new GuestMovieServiceImpl();
    private final CinemaBrowseService browseService = new CinemaBrowseServiceImpl();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // --- parse params ---
        Long movieId = parseLong(req.getParameter("movieId"));
        if (movieId == null) {
            resp.sendRedirect(req.getContextPath() + "/movies?status=NOW_SHOWING");
            return;
        }

        // Use GuestMovieService to get the full movie (poster, genres, rated, description…)
        Movie movie = guestMovieService.getMovieDetail(movieId);
        if (movie == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Movie not found: " + movieId);
            return;
        }

        // Selected date (default today)
        LocalDate selectedDate;
        String dateParam = req.getParameter("date");
        if (dateParam != null && !dateParam.isBlank()) {
            try { selectedDate = LocalDate.parse(dateParam.trim()); }
            catch (Exception e) { selectedDate = LocalDate.now(); }
        } else {
            selectedDate = LocalDate.now();
        }

        // Optional branch filter
        Long selectedBranchId = null;
        String branchParam = req.getParameter("branchId");
        if (branchParam != null && !branchParam.isBlank() && !"all".equalsIgnoreCase(branchParam.trim())) {
            try { selectedBranchId = Long.parseLong(branchParam.trim()); }
            catch (NumberFormatException ignored) {}
        }

        // All active branches (for filter dropdown)
        List<Branch> allBranches = browseService.getActiveBranches();

        // Branches to query
        List<Branch> branchesToQuery = new ArrayList<>();
        if (selectedBranchId != null) {
            for (Branch b : allBranches) {
                if (b.getBranchId() == selectedBranchId) { branchesToQuery.add(b); break; }
            }
        } else {
            branchesToQuery.addAll(allBranches);
        }

        // Build branch-showtime groups
        DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
        LocalDateTime now = LocalDateTime.now();
        List<BranchShowtimes> branchShowtimesList = new ArrayList<>();

        for (Branch branch : branchesToQuery) {
            List<Showtime> sts = showtimeDAO.findByBranch(branch.getBranchId(), movieId, null, selectedDate);
            // keep only SCHEDULED and in the future
            sts.removeIf(st -> !Showtime.STATUS_SCHEDULED.equals(st.getStatus())
                    || st.getStartTime() == null || !st.getStartTime().isAfter(now));

            if (sts.isEmpty()) continue;

            // Group by room (roomId + format + subtitle)
            Map<String, List<Showtime>> roomMap = new LinkedHashMap<>();
            for (Showtime st : sts) {
                String key = st.getRoomId() + "_" + st.getFormat() + "_" + st.getSubtitleType();
                roomMap.computeIfAbsent(key, k -> new ArrayList<>()).add(st);
            }

            List<RoomGroup> roomGroups = new ArrayList<>();
            for (List<Showtime> group : roomMap.values()) {
                group.sort(Comparator.comparing(Showtime::getStartTime));
                Showtime first = group.get(0);
                List<SlotPage> pages = toPages(group, timeFmt);
                roomGroups.add(new RoomGroup(
                        first.getRoomName(), first.getRoomType(),
                        first.getFormat(), first.getSubtitleType(),
                        first.getBasePrice(), group.size(), pages));
            }
            branchShowtimesList.add(new BranchShowtimes(branch, roomGroups));
        }

        // 7-day date tabs
        List<DateTab> dateTabs = new ArrayList<>();
        DateTimeFormatter dayFmt  = DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH);
        DateTimeFormatter dateLbl = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 0; i < 7; i++) {
            LocalDate d = LocalDate.now().plusDays(i);
            dateTabs.add(new DateTab(d, d.format(dayFmt).toUpperCase(), d.format(dateLbl), d.equals(selectedDate)));
        }

        req.setAttribute("movie",               movie);
        req.setAttribute("allBranches",          allBranches);
        req.setAttribute("selectedDate",         selectedDate.toString());
        // Always pass as String so JSP EL comparisons never try to coerce "all" to Long
        req.setAttribute("selectedBranchId",     selectedBranchId == null ? "all" : String.valueOf(selectedBranchId));
        req.setAttribute("dateTabs",             dateTabs);
        req.setAttribute("branchShowtimesList",  branchShowtimesList);
        req.setAttribute("slotsPerPage",         SLOTS_PER_PAGE);

        req.getRequestDispatcher("/WEB-INF/views/booking/showtimes.jsp").forward(req, resp);
    }

    /** Split a room's showtime list into pages of SLOTS_PER_PAGE. */
    private List<SlotPage> toPages(List<Showtime> sorted, DateTimeFormatter timeFmt) {
        List<SlotPage> pages = new ArrayList<>();
        List<ShowtimeSlot> current = new ArrayList<>();
        for (Showtime st : sorted) {
            boolean full = st.getBookedSeats() >= st.getRoomCapacity();
            current.add(new ShowtimeSlot(st.getShowtimeId(), st.getStartTime().format(timeFmt),
                    st.getBasePrice(), full));
            if (current.size() == SLOTS_PER_PAGE) {
                pages.add(new SlotPage(new ArrayList<>(current)));
                current.clear();
            }
        }
        if (!current.isEmpty()) pages.add(new SlotPage(current));
        return pages;
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    // ── view-models ──────────────────────────────────────────────────────────

    public static class DateTab {
        private final LocalDate date; private final String day, label; private final boolean active;
        DateTab(LocalDate d, String day, String label, boolean active) { this.date=d; this.day=day; this.label=label; this.active=active; }
        public LocalDate getDate() { return date; }
        public String getDay()     { return day; }
        public String getLabel()   { return label; }
        public boolean isActive()  { return active; }
    }

    public static class BranchShowtimes {
        private final Branch branch; private final List<RoomGroup> roomGroups;
        BranchShowtimes(Branch b, List<RoomGroup> rg) { branch=b; roomGroups=rg; }
        public Branch getBranch()           { return branch; }
        public List<RoomGroup> getRoomGroups() { return roomGroups; }
    }

    public static class RoomGroup {
        private final String roomName, roomType, format, subtitleType;
        private final BigDecimal minPrice;
        private final int totalSlots;
        private final List<SlotPage> pages;
        RoomGroup(String rn, String rt, String fmt, String sub, BigDecimal mp, int total, List<SlotPage> pages) {
            this.roomName=rn; this.roomType=rt; this.format=fmt; this.subtitleType=sub;
            this.minPrice=mp; this.totalSlots=total; this.pages=pages;
        }
        public String getRoomName()      { return roomName; }
        public String getRoomType()      { return roomType; }
        public String getFormat()        { return format; }
        public String getSubtitleType()  { return subtitleType; }
        public BigDecimal getMinPrice()  { return minPrice; }
        public int getTotalSlots()       { return totalSlots; }
        public List<SlotPage> getPages() { return pages; }
    }

    public static class SlotPage {
        private final List<ShowtimeSlot> slots;
        SlotPage(List<ShowtimeSlot> s) { slots = s; }
        public List<ShowtimeSlot> getSlots() { return slots; }
    }

    public static class ShowtimeSlot {
        private final long showtimeId; private final String timeLabel;
        private final BigDecimal price; private final boolean full;
        ShowtimeSlot(long id, String t, BigDecimal p, boolean f) { showtimeId=id; timeLabel=t; price=p; full=f; }
        public long getShowtimeId()   { return showtimeId; }
        public String getTimeLabel()  { return timeLabel; }
        public BigDecimal getPrice()  { return price; }
        public boolean isFull()       { return full; }
    }
}