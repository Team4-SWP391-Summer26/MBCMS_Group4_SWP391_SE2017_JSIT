package com.mbcms.controller.booking;

import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.service.CinemaBrowseService;
import com.mbcms.service.impl.CinemaBrowseServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * MovieByBranchServlet
 *
 * Buoc 2 cua luong dat ve: chon phim TRONG chi nhanh da chon o buoc 1.
 *
 * GET /booking/movies?branchId={id}
 *     -> chi hien cac phim dang co suat chieu (SCHEDULED, sap toi) tai branch do
 *     -> nguoi dung chon 1 phim, chuyen sang /booking/showtimes?branchId={id}&movieId={id}
 */
@WebServlet("/booking/movies")
public class MovieByBranchServlet extends HttpServlet {

    private final CinemaBrowseService browseService = new CinemaBrowseServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long branchId = parseLong(req.getParameter("branchId"));
        if (branchId == null) {
            resp.sendRedirect(req.getContextPath() + "/booking/branches");
            return;
        }

        Branch branch = browseService.getActiveBranch(branchId);
        if (branch == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Khong tim thay chi nhanh id=" + branchId);
            return;
        }

        List<Movie> movies = browseService.getMoviesByBranch(branchId);

        req.setAttribute("branch", branch);
        req.setAttribute("movies", movies);

        req.getRequestDispatcher("/WEB-INF/views/booking/movies.jsp").forward(req, resp);
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }
}
