package com.mbcms.controller.branch;

import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.model.Showtime;
import com.mbcms.service.ShowtimeService;
import com.mbcms.service.impl.ShowtimeServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;
import java.util.Set;

/**
 * ShowtimeCreateServlet - owner: <b>HungNT</b>. SRS 3.5.2.2 Showtime Details
 * Screen - phan Create (UC20 Schedule showtimes; UC19 Assign movies to rooms;
 * UC39 Set price).
 *
 * GET /branch/showtimes/create - hien form tao showtime. POST
 * /branch/showtimes/create - validate + tao; thanh cong thi redirect ve
 * /branch/showtimes?created=1 (PRG pattern - tranh F5 tao trung).
 *
 * Parse + validate form nam o ShowtimeFormHelper (dung chung voi Edit).
 */
@WebServlet("/branch/showtimes/create")
public class ShowtimeCreateServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/showtime/form.jsp";

    /** Gioi han khoang ngay o che do "Multiple days" (UC20). */
    private static final int MAX_RANGE_DAYS = 31;

    static final String MSG_FORMAT_ROOM_MISMATCH =
            "Format and room type do not match: IMAX showtimes require an IMAX room, "
            + "and IMAX rooms only screen IMAX.";

    /**
     * GET: chi mo form trong, nap san danh sach phim + phong cho 2 dropdown.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        loadFormData(req);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    /**
     * POST: nhan du lieu form, tao showtime. Theo chuan PRG
     * (Post-Redirect-Get).
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Lay branch_id cua manager dang dang nhap tu session (do AuthFilter set san).
        // getSession(false) = khong tu tao session moi; dung branchId nay de gioi han
        // manager chi tao suat cho chi nhanh cua minh.
        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");

        try {
            String error;
            if ("range".equals(req.getParameter("dateMode"))) {
                // Che do "Multiple days": tao 1 suat/ngay cho moi ngay hop le trong
                // khoang. Thanh cong (>=1 suat) thi tu redirect ben trong -> tra null.
                error = handleCreateRange(req, resp, branchId);
            } else {
                // handleCreate tra ve null neu OK, hoac chuoi loi de hien cho user.
                error = handleCreate(req, branchId);
                if (error == null) {
                    // Thanh cong -> REDIRECT sang trang list (khong forward). Lam vay de
                    // user co F5 lai cung khong gui POST lai -> tranh tao trung 2 suat.
                    resp.sendRedirect(buildListRedirect(req, "created", "showtime-list"));
                    return;
                }
            }
            if (error == null) {
                return; // range mode da redirect
            }
            // Loi nghiep vu (trung lich / sai phong...) -> de message cho JSP hien.
            req.setAttribute("errorMsg", error);
        } catch (RuntimeException ex) {
            // Loi he thong (vd mat ket noi DB): ghi log, bao loi chung chung cho user.
            getServletContext().log("System error while creating showtime", ex);
            req.setAttribute("errorMsg", "System error, please try again later.");
        }

        // Co loi -> mo lai form va giu nguyen gia tri user da go (form.jsp doc lai tu param).
        loadFormData(req);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    /**
     * Validate + tao showtime.
     *
     * @return null neu thanh cong; nguoc lai tra ve thong bao loi.
     */
    private String handleCreate(HttpServletRequest req, long branchId) {
        // 1. Parse + validate input tu form vao object Showtime (logic dung chung voi Edit).
        //    populate() tra ve chuoi loi neu input sai (vd thieu gio, gia am...).
        Showtime st = new Showtime();
        String error = ShowtimeFormHelper.populate(req, st, branchId);
        if (error != null) {
            return error;
        }
        // 2. Suat moi tao luon o trang thai SCHEDULED (da len lich).
        st.setStatus(Showtime.STATUS_SCHEDULED);

        // 3. Goi service xu ly nghiep vu, roi DICH ma ket qua sang cau thong bao tieng Anh.
        ShowtimeService service = new ShowtimeServiceImpl();
        String result = service.createShowtime(st, branchId);

        switch (result) {
            case ShowtimeService.RESULT_OK:
                return null;
            case ShowtimeService.RESULT_CONFLICT:
                return "Schedule conflict: this room already has a showtime overlapping that time.";
            case ShowtimeService.RESULT_FORMAT_ROOM_MISMATCH:
                return MSG_FORMAT_ROOM_MISMATCH;
            case ShowtimeService.RESULT_ROOM_INVALID:
            default:
                return "Invalid room.";
        }
    }

    /**
     * Che do "Multiple days" (UC20): tao 1 suat moi ngay (cung gio/phim/phong/gia)
     * cho cac ngay trong khoang [from..to] roi vao cac thu da tick.
     *
     * Moi ngay di qua DUNG ham validate cua che do don le
     * (ShowtimeFormHelper.populate) + service check trung lich. Ngay bi trung
     * lich hoac da qua gio thi SKIP (khong huy ca batch); loi khac (phim/phong/
     * gia sai...) ap dung cho moi ngay nen dung ngay va bao loi len form.
     *
     * @return null neu da tao duoc &gt;=1 suat (da redirect kem tong ket);
     *         nguoc lai tra chuoi loi de hien tren form.
     */
    private String handleCreateRange(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws IOException {
        LocalDate from;
        LocalDate to;
        try {
            from = LocalDate.parse(trimToEmpty(req.getParameter("dateFrom")));
            to = LocalDate.parse(trimToEmpty(req.getParameter("dateTo")));
        } catch (DateTimeParseException e) {
            return "Please enter both From and To dates.";
        }
        if (to.isBefore(from)) {
            return "\"To\" date must not be before \"From\" date.";
        }
        if (ChronoUnit.DAYS.between(from, to) + 1 > MAX_RANGE_DAYS) {
            return "Date range is too long (max " + MAX_RANGE_DAYS + " days).";
        }
        Set<DayOfWeek> days = parseDays(req.getParameterValues("days"));
        if (days.isEmpty()) {
            return "Select at least one day of the week.";
        }

        ShowtimeService service = new ShowtimeServiceImpl();
        DateTimeFormatter ddMM = DateTimeFormatter.ofPattern("dd/MM");
        int created = 0;
        LocalDate firstCreated = null;
        List<String> skipped = new ArrayList<>();
        boolean matchedAny = false;

        for (LocalDate d = from; !d.isAfter(to); d = d.plusDays(1)) {
            if (!days.contains(d.getDayOfWeek())) {
                continue;
            }
            matchedAny = true;

            Showtime st = new Showtime();
            String error = ShowtimeFormHelper.populate(req, st, branchId, d.toString());
            if (error != null) {
                // Loi duy nhat phu thuoc ngay -> chi skip ngay do (vd hom nay
                // nhung gio chieu da qua). Loi khac -> dung ca batch.
                if (ShowtimeFormHelper.ERR_START_IN_PAST.equals(error)) {
                    skipped.add(d.format(ddMM) + " (start time already past)");
                    continue;
                }
                return error;
            }
            st.setStatus(Showtime.STATUS_SCHEDULED);

            String result = service.createShowtime(st, branchId);
            switch (result) {
                case ShowtimeService.RESULT_OK:
                    created++;
                    if (firstCreated == null) {
                        firstCreated = d;
                    }
                    break;
                case ShowtimeService.RESULT_CONFLICT:
                    skipped.add(d.format(ddMM) + " (schedule conflict)");
                    break;
                case ShowtimeService.RESULT_FORMAT_ROOM_MISMATCH:
                    return MSG_FORMAT_ROOM_MISMATCH;
                case ShowtimeService.RESULT_ROOM_INVALID:
                default:
                    return "Invalid room.";
            }
        }

        if (!matchedAny) {
            return "No dates in the range fall on the selected weekdays.";
        }
        if (created == 0) {
            return "No showtimes were created. Skipped: " + String.join(", ", skipped) + ".";
        }

        // Tong ket qua session flash (qua dai cho query param); list servlet doc 1 lan roi xoa.
        String msg = "Created " + created + " showtime" + (created > 1 ? "s" : "") + "."
                + (skipped.isEmpty() ? "" : " Skipped " + skipped.size() + ": " + String.join(", ", skipped) + ".");
        req.getSession(false).setAttribute("flashSuccessMsg", msg);
        resp.sendRedirect(req.getContextPath() + "/branch/showtimes?date=" + firstCreated + "#showtime-list");
        return null;
    }

    /** Parse checkbox "days" (gia tri 1..7 theo ISO: 1=Mon .. 7=Sun). */
    private Set<DayOfWeek> parseDays(String[] values) {
        Set<DayOfWeek> days = EnumSet.noneOf(DayOfWeek.class);
        if (values == null) {
            return days;
        }
        for (String v : values) {
            try {
                days.add(DayOfWeek.of(Integer.parseInt(v.trim())));
            } catch (RuntimeException ignored) {
                // gia tri la (sua tay form) -> bo qua
            }
        }
        return days;
    }

    private String trimToEmpty(String s) {
        return s == null ? "" : s.trim();
    }

    /**
     * Load movies + rooms cho 2 dropdown cua form (+ ten branch cho sidebar).
     */
    private void loadFormData(HttpServletRequest req) {
        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req);
        MovieDAO movieDAO = new MovieDAOImpl();
        RoomDAO roomDAO = new RoomDAOImpl();
        req.setAttribute("movies", movieDAO.findActiveMoviesForBranch(branchId));
        req.setAttribute("rooms", roomDAO.findActiveByBranch(branchId));
    }

    private String buildListRedirect(HttpServletRequest req, String flag, String fragment) {
        StringBuilder url = new StringBuilder(req.getContextPath()).append("/branch/showtimes?");
        String date = firstNonBlank(req.getParameter("returnDate"), req.getParameter("date"));
        if (isIsoDate(date)) {
            url.append("date=").append(date).append("&");
        }
        url.append(flag).append("=1");
        if (fragment != null && !fragment.trim().isEmpty()) {
            url.append("#").append(fragment);
        }
        return url.toString();
    }

    private String firstNonBlank(String first, String second) {
        if (first != null && !first.trim().isEmpty()) {
            return first.trim();
        }
        return second == null ? null : second.trim();
    }

    private boolean isIsoDate(String value) {
        return value != null && value.matches("\\d{4}-\\d{2}-\\d{2}");
    }
}
