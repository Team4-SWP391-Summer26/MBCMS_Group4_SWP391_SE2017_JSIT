package com.mbcms.controller.admin;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.MovieBranchDAO;
import com.mbcms.dao.MovieDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.dao.impl.MovieBranchDAOImpl;
import com.mbcms.dao.impl.MovieDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * AdminDashboardServlet - owner: <b>HungNT</b>.
 * Trang chinh cua Admin console (/admin/dashboard): vai thong ke + loi vao
 * cac module. Nam duoi /admin/* nen RoleFilter (ADMIN) da chay truoc.
 */
@WebServlet({"/admin/dashboard", "/admin"})
public class AdminDashboardServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/dashboard.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // /admin -> chuyen ve /admin/dashboard cho gon URL.
        if (req.getServletPath().equals("/admin")) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        MovieDAO movieDAO = new MovieDAOImpl();
        BranchDAO branchDAO = new BranchDAOImpl();
        MovieBranchDAO movieBranchDAO = new MovieBranchDAOImpl();

        req.setAttribute("movieCount", movieDAO.findActiveMovies().size());
        req.setAttribute("branchCount", branchDAO.findAll().size());
        req.setAttribute("distributionCount", movieBranchDAO.countAll());

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
