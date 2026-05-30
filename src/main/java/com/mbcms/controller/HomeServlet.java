package com.mbcms.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * HomeServlet - trang chu guest.
 * Browse/featured movies: owner <b>AnhND</b> (Report 4).
 */
@WebServlet("/home")
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // TODO AnhND: Load featured + NOW_SHOWING movies (MovieService -> MovieDAO)
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
