package com.mbcms.controller.branch;

import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * BranchMovieServlet - owner: HungNT. Man "Movies" (READ-ONLY) cho Branch
 * Manager - chi xem cac phim da duoc Admin cap cho chi nhanh minh (qua
 * movie_branch); khong the them/sua/xoa - viec do thuoc ve Admin
 * (MovieBranchAdminServlet, /admin/movie-branches).
 *
 * GET /branch/movies
 *
 * Nam duoi /branch/* nen AuthFilter + RoleFilter (BRANCH_MANAGER) +
 * BranchFilter da chay truoc; "currentBranchId" trong session chac chan != null.
 */
@WebServlet("/branch/movies")
public class BranchMovieServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/movies.jsp";

    private final MovieDAO movieDAO = new MovieDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req); // ten branch cho sidebar + scope notice

        req.setAttribute("movies", movieDAO.findAssignedMoviesForBranch(branchId));

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
