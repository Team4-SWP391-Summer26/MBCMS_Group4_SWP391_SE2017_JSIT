package com.mbcms.controller;

import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.impl.MovieDAOImpl;
import com.mbcms.model.Movie;
import com.mbcms.model.Genre;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * HomeServlet - trang chu guest. Browse/featured movies: owner <b>AnhND</b>
 * (Report 4).
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    private final MovieDAO movieDAO = new MovieDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Nghiep vu Home (khong do het catalog ra trang chu):
        // - Spotlight: toi da 5 phim NOW_SHOWING co NHIEU suat sap toi nhat (phim hot).
        // - Now Showing: 10 phim (2 hang x 5) con ban ve duoc; View all -> /movies.
        // - Coming Soon: 5 phim UPCOMING sap ra rap gan nhat (1 hang day).
        List<Movie> spotlight = movieDAO.findSpotlightMovies(5);
        List<Movie> nowShowing = movieDAO.findHomeNowShowing(10);
        List<Movie> comingSoon = movieDAO.findUpcomingMovies(5);
        List<Genre> genres = movieDAO.findAllGenres();

        Movie featured = spotlight.isEmpty() ? null : spotlight.get(0);

        req.setAttribute("featuredMovie", featured);
        req.setAttribute("spotlight", spotlight);
        req.setAttribute("nowShowing", nowShowing);
        req.setAttribute("comingSoon", comingSoon);
        req.setAttribute("genres", genres);

        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
