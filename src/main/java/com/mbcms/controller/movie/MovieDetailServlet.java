package com.mbcms.controller.movie;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * MovieDetailServlet - owner: <b>AnhND</b> (View movie details, showtimes).
 */
@WebServlet("/movies/detail")
public class MovieDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // TODO AnhND: ?id= movieId, load showtimes theo ngay
        req.getRequestDispatcher("/WEB-INF/views/movie/detail.jsp").forward(req, resp);
    }
}
