package com.mbcms.controller.movie;

import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.service.GuestMovieService;
import com.mbcms.service.PricingService;
import com.mbcms.service.impl.GuestMovieServiceImpl;
import com.mbcms.service.impl.PricingServiceImpl;
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
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;

/**
 * MovieDetailServlet - owner: AnhND.
 *
 * URL: /movies/detail?id={movieId}
 * Chức năng: Guest xem chi tiết phim, hỗ trợ xem suất chiếu nhóm theo chi nhánh và phòng.
 */
@WebServlet("/movies/detail")
public class MovieDetailServlet extends HttpServlet {

    private static final DateTimeFormatter ISO_LOCAL = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    private final GuestMovieService guestMovieService = new GuestMovieServiceImpl();
    private final ShowtimeDAO showtimeDAO = new ShowtimeDAOImpl();
    private final PricingService pricingService = new PricingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long movieId = parseLong(req.getParameter("id"));
        if (movieId == null) {
            resp.sendRedirect(req.getContextPath() + "/movies?status=NOW_SHOWING");
            return;
        }

        Movie movie = guestMovieService.getMovieDetail(movieId);
        if (movie == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay phim id=" + movieId);
            return;
        }

        LocalDate selectedDate;
        String dateParam = req.getParameter("date");
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                selectedDate = LocalDate.parse(dateParam.trim());
            } catch (Exception e) {
                selectedDate = LocalDate.now();
            }
        } else {
            selectedDate = LocalDate.now();
        }

        Long selectedBranchId = null;
        String branchParam = req.getParameter("branchId");
        if (branchParam != null && !branchParam.trim().isEmpty() && !"all".equalsIgnoreCase(branchParam.trim())) {
            try {
                selectedBranchId = Long.parseLong(branchParam.trim());
            } catch (NumberFormatException ignored) {}
        }

        List<Branch> branches = guestMovieService.getBranches();

        boolean showtimesAvailable = "NOW_SHOWING".equals(movie.getStatus());

        List<BranchShowtimes> branchShowtimesList = new ArrayList<>();
        Set<String> availableFormats = new LinkedHashSet<>();
        Set<String> availableSubtitleTypes = new LinkedHashSet<>();

        if (showtimesAvailable) {
            // Always scan all branches for hero chips (format / Sub-Dub summary)
            for (Branch b : branches) {
                boolean includeInList = selectedBranchId == null || b.getBranchId() == selectedBranchId;
                List<Showtime> sts = showtimeDAO.findByBranch(b.getBranchId(), movieId, null, selectedDate);
                sts.removeIf(st -> !Showtime.STATUS_SCHEDULED.equals(st.getStatus()));

                for (Showtime st : sts) {
                    if (st.getFormat() != null && !st.getFormat().isBlank()) {
                        availableFormats.add(st.getFormat());
                    }
                    if (st.getSubtitleType() != null && !st.getSubtitleType().isBlank()) {
                        availableSubtitleTypes.add(st.getSubtitleType());
                    }
                }

                if (!includeInList || sts.isEmpty()) {
                    continue;
                }

                Map<String, List<Showtime>> roomGroupsMap = new LinkedHashMap<>();
                for (Showtime st : sts) {
                    String groupKey = st.getRoomId() + "_" + st.getFormat() + "_" + st.getSubtitleType();
                    roomGroupsMap.computeIfAbsent(groupKey, k -> new ArrayList<>()).add(st);
                }

                List<RoomGroup> roomGroups = new ArrayList<>();
                for (Map.Entry<String, List<Showtime>> entry : roomGroupsMap.entrySet()) {
                    List<Showtime> groupSts = entry.getValue();
                    Showtime first = groupSts.get(0);

                    List<ShowtimeSlot> slots = new ArrayList<>();
                    for (Showtime st : groupSts) {
                        boolean isFull = st.getBookedSeats() >= st.getRoomCapacity();
                        LocalDateTime start = st.getStartTime();
                        slots.add(new ShowtimeSlot(
                                st.getShowtimeId(),
                                DateTimeUtil.formatAmPm(start),
                                start != null ? start.format(ISO_LOCAL) : "",
                                st.getBasePrice(),
                                isFull));
                    }

                    slots.sort(Comparator.comparing(ShowtimeSlot::getStartIso));

                    roomGroups.add(new RoomGroup(
                            first.getRoomName(),
                            first.getRoomType(),
                            first.getFormat(),
                            first.getSubtitleType(),
                            first.getBasePrice(),
                            slots
                    ));
                }

                branchShowtimesList.add(new BranchShowtimes(b, roomGroups));
            }

            // Fallback: next 7 days if selected date has no slots
            if (availableSubtitleTypes.isEmpty()) {
                for (Branch b : branches) {
                    for (int i = 1; i < 7; i++) {
                        LocalDate d = LocalDate.now().plusDays(i);
                        List<Showtime> sts = showtimeDAO.findByBranch(b.getBranchId(), movieId, null, d);
                        for (Showtime st : sts) {
                            if (!Showtime.STATUS_SCHEDULED.equals(st.getStatus())) {
                                continue;
                            }
                            if (st.getFormat() != null && !st.getFormat().isBlank()) {
                                availableFormats.add(st.getFormat());
                            }
                            if (st.getSubtitleType() != null && !st.getSubtitleType().isBlank()) {
                                availableSubtitleTypes.add(st.getSubtitleType());
                            }
                        }
                    }
                }
            }
        }

        List<DateTab> dateTabs = new ArrayList<>();
        DateTimeFormatter dayFmt = DateTimeFormatter.ofPattern("EEE", Locale.ENGLISH);
        DateTimeFormatter dateLabelFmt = DateTimeFormatter.ofPattern("dd/MM");
        for (int i = 0; i < 7; i++) {
            LocalDate d = LocalDate.now().plusDays(i);
            dateTabs.add(new DateTab(d, d.format(dayFmt).toUpperCase(), d.format(dateLabelFmt), d.equals(selectedDate)));
        }

        req.setAttribute("movie", movie);
        req.setAttribute("branches", branches);
        req.setAttribute("dateTabs", dateTabs);
        req.setAttribute("selectedDate", selectedDate.toString());
        req.setAttribute("selectedBranchId", selectedBranchId == null ? "all" : String.valueOf(selectedBranchId));
        req.setAttribute("branchShowtimesList", branchShowtimesList);
        req.setAttribute("showtimesAvailable", showtimesAvailable);
        req.setAttribute("availableFormats", availableFormats);
        req.setAttribute("availableSubtitleTypes", availableSubtitleTypes);
        req.setAttribute("vipSurchargePercent", pricingService.getVipSurchargePercent());

        req.getRequestDispatcher("/WEB-INF/views/movie/detail.jsp").forward(req, resp);
    }

    private Long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static class DateTab {
        private final LocalDate date;
        private final String day;
        private final String label;
        private final boolean active;

        public DateTab(LocalDate date, String day, String label, boolean active) {
            this.date = date;
            this.day = day;
            this.label = label;
            this.active = active;
        }

        public LocalDate getDate() { return date; }
        public String getDay() { return day; }
        public String getLabel() { return label; }
        public boolean isActive() { return active; }
        public boolean getActive() { return active; }
    }

    public static class BranchShowtimes {
        private final Branch branch;
        private final List<RoomGroup> roomGroups;

        public BranchShowtimes(Branch branch, List<RoomGroup> roomGroups) {
            this.branch = branch;
            this.roomGroups = roomGroups;
        }

        public Branch getBranch() { return branch; }
        public List<RoomGroup> getRoomGroups() { return roomGroups; }
    }

    public static class RoomGroup {
        private final String roomName;
        private final String roomType;
        private final String format;
        private final String subtitleType;
        private final java.math.BigDecimal minPrice;
        private final List<ShowtimeSlot> slots;

        public RoomGroup(String roomName, String roomType, String format, String subtitleType,
                java.math.BigDecimal minPrice, List<ShowtimeSlot> slots) {
            this.roomName = roomName;
            this.roomType = roomType;
            this.format = format;
            this.subtitleType = subtitleType;
            this.minPrice = minPrice;
            this.slots = slots;
        }

        public String getRoomName() { return roomName; }
        public String getRoomType() { return roomType; }
        public String getFormat() { return format; }
        public String getSubtitleType() { return subtitleType; }
        public java.math.BigDecimal getMinPrice() { return minPrice; }
        public List<ShowtimeSlot> getSlots() { return slots; }
    }

    public static class ShowtimeSlot {
        private final long showtimeId;
        private final String time;
        private final String startIso;
        private final java.math.BigDecimal price;
        private final boolean full;

        public ShowtimeSlot(long showtimeId, String time, String startIso,
                java.math.BigDecimal price, boolean full) {
            this.showtimeId = showtimeId;
            this.time = time;
            this.startIso = startIso;
            this.price = price;
            this.full = full;
        }

        public long getShowtimeId() { return showtimeId; }
        public String getTime() { return time; }
        public String getStartIso() { return startIso; }
        public java.math.BigDecimal getPrice() { return price; }
        public boolean isFull() { return full; }
        public boolean getFull() { return full; }
    }
}
