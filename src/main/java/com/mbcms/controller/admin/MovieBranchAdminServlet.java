package com.mbcms.controller.admin;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.service.MovieDistributionService;
import com.mbcms.service.impl.MovieDistributionServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * MovieBranchAdminServlet - owner: <b>HungNT</b>.
 * Admin (head office) CAP phim cho tung chi nhanh (ghi bang movie_branch).
 * Branch Manager sau do chi xep lich (showtimes) tu phim chi nhanh duoc cap.
 *
 * GET  /admin/movie-branches            - chon chi nhanh (mac dinh chi nhanh dau).
 * GET  /admin/movie-branches?branchId=N - checklist phim, tick = da cap.
 * POST /admin/movie-branches            - luu phan phoi; PRG -> ?branchId=N&saved=1.
 *
 * Nam duoi /admin/* nen AuthFilter + RoleFilter (ADMIN) da chay truoc.
 * KHONG dung BranchFilter scope (Admin thao tac moi chi nhanh).
 */
@WebServlet("/admin/movie-branches")
public class MovieBranchAdminServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/movie_branch.jsp";
    private static final String PARAM = "movieIds"; // checkbox value = movie_id

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        BranchDAO branchDAO = new BranchDAOImpl();
        List<Branch> branches = branchDAO.findAll();
        req.setAttribute("branches", branches);

        // Mac dinh chon chi nhanh dau neu URL khong chi dinh.
        Long selected = parseLongOrNull(req.getParameter("branchId"));
        if (selected == null && !branches.isEmpty()) {
            selected = branches.get(0).getBranchId();
        }

        MovieDistributionService service = new MovieDistributionServiceImpl();
        if (selected != null) {
            Set<Long> assigned = service.getAssignedMovieIds(selected);
            if (assigned == null) {
                req.setAttribute("errorMsg", "Invalid branch."); // id la tren URL
            } else {
                req.setAttribute("selectedBranchId", selected);
                req.setAttribute("movies", service.getAssignableMovies());
                req.setAttribute("assignedIds", assigned);
            }
        }

        // PRG toast.
        if ("1".equals(req.getParameter("saved"))) {
            req.setAttribute("successMsg", "Movie distribution updated successfully.");
        } else if ("BRANCH_INVALID".equals(req.getParameter("err"))) {
            req.setAttribute("errorMsg", "Invalid branch.");
        } else if ("HAS_SHOWTIMES".equals(req.getParameter("err"))) {
            req.setAttribute("errorMsg", "Cannot remove a movie that still has upcoming/ongoing "
                    + "showtimes at this branch. Cancel those showtimes first.");
        } else if ("SYSTEM".equals(req.getParameter("err"))) {
            req.setAttribute("errorMsg", "System error, please try again later.");
        }

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String base = req.getContextPath() + "/admin/movie-branches";

        Long branchId = parseLongOrNull(req.getParameter("branchId"));
        if (branchId == null) {
            resp.sendRedirect(base);
            return;
        }

        // Gom movie_id duoc tick. Checkbox khong tick -> khong gui len -> bi bo cap.
        Set<Long> movieIds = new HashSet<>();
        String[] vals = req.getParameterValues(PARAM);
        if (vals != null) {
            for (String v : vals) {
                Long id = parseLongOrNull(v);
                if (id != null) {
                    movieIds.add(id);
                }
            }
        }

        try {
            String result = new MovieDistributionServiceImpl().saveAssignments(branchId, movieIds);
            if (MovieDistributionService.RESULT_OK.equals(result)) {
                resp.sendRedirect(base + "?branchId=" + branchId + "&saved=1");
            } else {
                resp.sendRedirect(base + "?branchId=" + branchId + "&err=" + result);
            }
        } catch (RuntimeException ex) {
            getServletContext().log("System error while saving movie distribution", ex);
            resp.sendRedirect(base + "?branchId=" + branchId + "&err=SYSTEM");
        }
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
}
