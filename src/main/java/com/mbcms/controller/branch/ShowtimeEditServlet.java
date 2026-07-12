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

/**
 * ShowtimeEditServlet - owner: <b>HungNT</b>. SRS 3.5.2.2 Showtime Details
 * Screen - phan Edit (UC21 Edit showtime).
 *
 * GET /branch/showtimes/edit?id=N - hien form voi du lieu suat hien tai. POST
 * /branch/showtimes/edit - validate + cap nhat; thanh cong redirect ve
 * /branch/showtimes?updated=1 (PRG).
 *
 * Chi sua duoc suat SCHEDULED thuoc branch cua manager (service verify). Tai
 * dung form.jsp + ShowtimeFormHelper cua Create.
 */
@WebServlet("/branch/showtimes/edit")
public class ShowtimeEditServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/showtime/form.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");

        Long id = parseId(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(buildListRedirect(req, "notFound", null));
            return;
        }

        Showtime st = new ShowtimeServiceImpl().getShowtimeForBranch(id, branchId);

        // Tach ly do de list hien message ro (khong don het vao "not found").
        // Server van verify lai trong updateShowtime khi submit.
        if (st == null) {
            resp.sendRedirect(buildListRedirect(req, "notFound", null));
            return;
        }
        if (!Showtime.STATUS_SCHEDULED.equals(st.getStatus())) {
            resp.sendRedirect(buildListRedirect(req, "notEditable", "showtime-" + id));
            return;
        }
        if (!st.getStartTime().isAfter(com.mbcms.util.DateTimeUtil.nowVietnam())) {
            resp.sendRedirect(buildListRedirect(req, "alreadyStarted", "showtime-" + id));
            return;
        }

        req.setAttribute("st", st); // form.jsp do san gia tri hien tai
        loadFormData(req);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");

        Long id = parseId(req.getParameter("id"));
        if (id == null) {
            resp.sendRedirect(buildListRedirect(req, "notFound", null));
            return;
        }

        try {
            String error = handleUpdate(req, id, branchId);
            if (error == null) {
                // PRG: list.jsp hien toast MSG03 "Updated successfully."
                resp.sendRedirect(buildListRedirect(req, "updated", "showtime-" + id));
                return;
            }
            req.setAttribute("errorMsg", error);
        } catch (RuntimeException ex) {
            getServletContext().log("System error while updating showtime", ex);
            req.setAttribute("errorMsg", "System error, please try again later.");
        }

        // Loi -> hien lai form edit (param giu gia tri vua nhap)
        Showtime st = new ShowtimeServiceImpl().getShowtimeForBranch(id, branchId);
        req.setAttribute("st", st);
        loadFormData(req);
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    /**
     * Validate + cap nhat showtime.
     *
     * @return null neu thanh cong; nguoc lai tra ve thong bao loi.
     */
    private String handleUpdate(HttpServletRequest req, long showtimeId, long branchId) {
        Showtime st = new Showtime();
        String error = ShowtimeFormHelper.populate(req, st, branchId);
        if (error != null) {
            return error;
        }
        st.setShowtimeId(showtimeId);

        ShowtimeService service = new ShowtimeServiceImpl();
        String result = service.updateShowtime(st, branchId);

        switch (result) {
            case ShowtimeService.RESULT_OK:
                return null;
            case ShowtimeService.RESULT_CONFLICT:
                return "Schedule conflict: this room already has a showtime overlapping that time.";
            case ShowtimeService.RESULT_ROOM_INVALID:
                return "Invalid room.";
            case ShowtimeService.RESULT_NOT_EDITABLE:
                return "This showtime can no longer be edited (already started, cancelled, or ended).";
            case ShowtimeService.RESULT_HAS_BOOKINGS:
                return "Cannot edit this showtime because it already has bookings.";
            case ShowtimeService.RESULT_NOT_FOUND:
            default:
                return "Showtime not found.";
        }
    }

    private void loadFormData(HttpServletRequest req) {
        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req);
        MovieDAO movieDAO = new MovieDAOImpl();
        RoomDAO roomDAO = new RoomDAOImpl();
        req.setAttribute("movies", movieDAO.findActiveMoviesForBranch(branchId));
        req.setAttribute("rooms", roomDAO.findActiveByBranch(branchId));
    }

    private Long parseId(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
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
