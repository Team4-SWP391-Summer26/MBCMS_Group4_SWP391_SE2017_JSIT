package com.mbcms.controller.admin;

import com.mbcms.model.Branch;
import com.mbcms.service.BranchService;
import com.mbcms.service.impl.BranchServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet({"/admin/dashboard", "/admin"})
public class AdminDashboardServlet extends HttpServlet {

    private final BranchService branchService = new BranchServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getServletPath().equals("/admin")) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            return;
        }

        try {
            // Load branches with stats (rooms, seats, manager, revenue)
            // in a single query — avoids the old N+1 per-room seat loop
            List<Branch> branches = branchService.getAllBranchesWithStats(true);

            int totalBranches  = branches.size();
            int activeBranches = (int) branches.stream().filter(Branch::isActive).count();

            // Aggregate totals from stats already loaded on each Branch
            int totalRooms = 0;
            int totalSeats = 0;
            for (Branch b : branches) {
                totalRooms += b.getRoomsCount();
                totalSeats += b.getSeatsCount();
            }

            req.setAttribute("branches",       branches);
            req.setAttribute("totalBranches",  totalBranches);
            req.setAttribute("activeBranches", activeBranches);
            req.setAttribute("totalRooms",     totalRooms);
            req.setAttribute("totalSeats",     totalSeats);

            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")
               .forward(req, resp);

        } catch (Exception e) {
            getServletContext().log("Error loading admin dashboard", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                           "Unable to load dashboard.");
        }
    }
}