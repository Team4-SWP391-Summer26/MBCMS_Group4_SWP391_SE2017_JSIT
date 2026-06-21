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
            // handleCreate tra ve null neu OK, hoac chuoi loi de hien cho user.
            String error = handleCreate(req, branchId);
            if (error == null) {
                // Thanh cong -> REDIRECT sang trang list (khong forward). Lam vay de
                // user co F5 lai cung khong gui POST lai -> tranh tao trung 2 suat.
                resp.sendRedirect(req.getContextPath() + "/branch/showtimes?created=1");
                return;
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
        String error = ShowtimeFormHelper.populate(req, st);
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
            case ShowtimeService.RESULT_ROOM_INVALID:
            default:
                return "Invalid room.";
        }
    }

    /**
     * Load movies + rooms cho 2 dropdown cua form (+ ten branch cho sidebar).
     */
    private void loadFormData(HttpServletRequest req) {
        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req);
        MovieDAO movieDAO = new MovieDAOImpl();
        RoomDAO roomDAO = new RoomDAOImpl();
        req.setAttribute("movies", movieDAO.findActiveMovies());
        req.setAttribute("rooms", roomDAO.findActiveByBranch(branchId));
    }
}
