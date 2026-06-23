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
        Movie featured = movieDAO.findFeaturedMovie();
        List<Movie> nowShowing = movieDAO.findMoviesByStatus("NOW_SHOWING", 8);
        List<Movie> comingSoon = movieDAO.findMoviesByStatus("UPCOMING", 4);
        List<Genre> genres = movieDAO.findAllGenres();

        req.setAttribute("featuredMovie", featured);
        req.setAttribute("nowShowing", nowShowing);
        req.setAttribute("comingSoon", comingSoon);
        req.setAttribute("genres", genres);

        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
