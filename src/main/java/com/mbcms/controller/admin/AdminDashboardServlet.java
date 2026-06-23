package com.mbcms.controller.admin;

import com.mbcms.model.Branch;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.BranchService;
import com.mbcms.service.RoomService;
import com.mbcms.service.SeatService;
import com.mbcms.service.impl.BranchServiceImpl;
import com.mbcms.service.impl.RoomServiceImpl;
import com.mbcms.service.impl.SeatServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final BranchService branchService = new BranchServiceImpl();
    private final RoomService roomService = new RoomServiceImpl();
    private final SeatService seatService = new SeatServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req,
                         HttpServletResponse resp)
            throws ServletException, IOException {

        try {

            List<Branch> branches =
                    branchService.getAllBranches(true);

            List<Room> rooms =
                    roomService.getAllRooms(true);

            int totalBranches = branches.size();

            int activeBranches = (int) branches.stream()
                    .filter(Branch::isActive)
                    .count();

            int totalRooms = rooms.size();

            int totalSeats = 0;

            for (Room room : rooms) {

                List<Seat> seats =
                        seatService.getSeatsByRoom(room.getRoomId());

                totalSeats += seats.size();
            }

            req.setAttribute("totalBranches",
                    totalBranches);

            req.setAttribute("activeBranches",
                    activeBranches);

            req.setAttribute("totalRooms",
                    totalRooms);

            req.setAttribute("totalSeats",
                    totalSeats);

            req.setAttribute("branches",
                    branches);

            req.getRequestDispatcher(
                    "/WEB-INF/views/admin/dashboard.jsp")
                    .forward(req, resp);

        } catch (Exception e) {

            getServletContext().log(
                    "Error loading admin dashboard", e);

            resp.sendError(
                    HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Unable to load dashboard.");
        }
    }
}