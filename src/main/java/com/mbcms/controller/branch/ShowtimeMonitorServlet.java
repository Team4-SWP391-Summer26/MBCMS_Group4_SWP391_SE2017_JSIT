package com.mbcms.controller.branch;

import com.mbcms.model.Showtime;
import com.mbcms.model.Seat;
import com.mbcms.service.SeatAvailabilityService;
import com.mbcms.service.impl.SeatAvailabilityServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * ShowtimeMonitorServlet - UC: Real-time showtime seat occupancy monitor.
 * Mapped to: /branch/showtimes/monitor
 * Accessible by: BRANCH_MANAGER, BRANCH_STAFF (Branch scope enforced).
 */
@WebServlet("/branch/showtimes/monitor")
public class ShowtimeMonitorServlet extends HttpServlet {

    private final SeatAvailabilityService seatAvailabilityService = new SeatAvailabilityServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String role = (String) session.getAttribute("userRole");
        Long branchId = (Long) session.getAttribute("currentBranchId");

        if (branchId == null || (!"BRANCH_MANAGER".equals(role) && !"BRANCH_STAFF".equals(role))) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập chức năng này.");
            return;
        }

        ConsoleSupport.ensureBranchName(req);

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/branch/showtimes?notFound=1");
            return;
        }

        long showtimeId;
        try {
            showtimeId = Long.parseLong(idParam.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/showtimes?notFound=1");
            return;
        }

        Showtime showtime = seatAvailabilityService.getShowtime(showtimeId);
        if (showtime == null) {
            resp.sendRedirect(req.getContextPath() + "/branch/showtimes?notFound=1");
            return;
        }

        // Branch scope: verify that the showtime's room belongs to the current branch
        Long showtimeBranchId = new com.mbcms.dao.impl.RoomDAOImpl().findById(showtime.getRoomId()).getBranchId();
        if (showtimeBranchId == null || !showtimeBranchId.equals(branchId)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền theo dõi suất chiếu của chi nhánh khác.");
            return;
        }

        // Load data
        Map<String, List<Seat>> seatsByRow = seatAvailabilityService.getSeatsByRow(showtimeId);
        Set<Long> bookedSeatIds = seatAvailabilityService.getBookedSeatIds(showtimeId);

        req.setAttribute("showtime", showtime);
        req.setAttribute("seatsByRow", seatsByRow);
        req.setAttribute("bookedSeatIds", bookedSeatIds);

        req.getRequestDispatcher("/WEB-INF/views/branch/showtime/monitor.jsp").forward(req, resp);
    }
}
