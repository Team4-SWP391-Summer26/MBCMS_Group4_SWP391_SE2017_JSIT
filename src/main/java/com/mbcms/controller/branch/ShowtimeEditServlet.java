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
 * ShowtimeEditServlet - owner: <b>HungNT</b>.
 * SRS 3.5.2.2 Showtime Details Screen - phan Edit (UC21 Edit showtime).
 *
 * GET  /branch/showtimes/edit?id=N - hien form voi du lieu suat hien tai.
 * POST /branch/showtimes/edit      - validate + cap nhat; thanh cong redirect
 *      ve /branch/showtimes?updated=1 (PRG).
 *
 * Chi sua duoc suat SCHEDULED thuoc branch cua manager (service verify).
 * Tai dung form.jsp + ShowtimeFormHelper cua Create.
 */
@WebServlet("/branch/showtimes/edit")
public class ShowtimeEditServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/showtime/form.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");

        Long id = parseId(req.getParameter("id"));
        Showtime st = (id == null) ? null
                : new ShowtimeServiceImpl().getShowtimeForBranch(id, branchId);

        // Khong ton tai / cua branch khac / da CANCELLED-ENDED -> ve list
        if (st == null || !Showtime.STATUS_SCHEDULED.equals(st.getStatus())) {
            resp.sendRedirect(req.getContextPath() + "/branch/showtimes?notFound=1");
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
            resp.sendRedirect(req.getContextPath() + "/branch/showtimes?notFound=1");
            return;
        }

        try {
            String error = handleUpdate(req, id, branchId);
            if (error == null) {
                // PRG: list.jsp hien toast MSG03 "Updated successfully."
                resp.sendRedirect(req.getContextPath() + "/branch/showtimes?updated=1");
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
                return "This showtime can no longer be edited (already cancelled or ended).";
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
}
