package com.mbcms.controller.movie;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * MovieListServlet - owner: <b>AnhND</b> (Browse / Search / Filter movies).
 */
@WebServlet("/movies")
public class MovieListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // TODO AnhND: ?status=NOW_SHOWING|UPCOMING, search, filter, pagination
        req.getRequestDispatcher("/WEB-INF/views/movie/list.jsp").forward(req, resp);
    }
}
