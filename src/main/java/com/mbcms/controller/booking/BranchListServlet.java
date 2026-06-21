package com.mbcms.controller.booking;

import com.mbcms.model.Branch;
import com.mbcms.service.CinemaBrowseService;
import com.mbcms.service.impl.CinemaBrowseServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

/**
 * BranchListServlet
 *
 * Buoc 1 cua luong dat ve: chon chi nhanh (branch).
 *
 * GET /booking/branches
 *     -> liet ke cac chi nhanh dang active
 *     -> nguoi dung chon 1 chi nhanh, chuyen sang /booking/movies?branchId={id}
 */
@WebServlet("/booking/branches")
public class BranchListServlet extends HttpServlet {

    private final CinemaBrowseService browseService = new CinemaBrowseServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        List<Branch> branches = browseService.getActiveBranches();
        req.setAttribute("branches", branches);

        req.getRequestDispatcher("/WEB-INF/views/booking/branches.jsp").forward(req, resp);
    }
}
