package com.mbcms.controller.branch;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.model.Seat;
import com.mbcms.service.SeatManagementService;
import com.mbcms.service.impl.SeatManagementServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * SeatTypeServlet - owner: <b>HungNT</b>.
 * Manage seat types (Feature 3): phan loai ghe STANDARD / VIP theo phong.
 *
 * GET  /branch/seats           - chon phong (dropdown).
 * GET  /branch/seats?roomId=N  - hien so do ghe cua phong de phan loai.
 * POST /branch/seats           - luu loai ghe; thanh cong redirect
 *      ve /branch/seats?roomId=N&saved=1 (PRG - tranh F5 gui lai POST).
 *
 * Nam duoi /branch/* nen AuthFilter + RoleFilter (BRANCH_MANAGER) + BranchFilter
 * da chay truoc; "currentBranchId" trong session chac chan != null.
 */
@WebServlet("/branch/seats-type")
public class SeatTypeServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/seat/manage.jsp";
    private static final String PARAM_PREFIX = "type_"; // ten input: type_<seatId>

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req); // ten branch cho sidebar + scope notice

        // Dropdown: phong active cua branch nay.
        RoomDAO roomDAO = new RoomDAOImpl();
        req.setAttribute("rooms", roomDAO.findActiveByBranch(branchId));

        Long roomId = parseLongOrNull(req.getParameter("roomId"));
        if (roomId != null) {
            SeatManagementService service = new SeatManagementServiceImpl();
            List<Seat> seats = service.getSeatsForRoom(roomId, branchId);
            if (seats == null) {
                // Phong khong thuoc branch nay (hoac khong ton tai).
                req.setAttribute("errorMsg", "Invalid room.");
            } else {
                req.setAttribute("selectedRoomId", roomId);
                req.setAttribute("seatsByRow", groupByRow(seats));

                int vip = 0;
                for (Seat s : seats) {
                    if (Seat.TYPE_VIP.equals(s.getSeatType())) {
                        vip++;
                    }
                }
                req.setAttribute("totalSeats", seats.size());
                req.setAttribute("vipCount", vip);
                req.setAttribute("standardCount", seats.size() - vip);
            }
        }

        // PRG: POST redirect ve day kem query param -> toast.
        if ("1".equals(req.getParameter("saved"))) {
            req.setAttribute("successMsg", "Seat types updated successfully."); // MSG03
        } else if ("ROOM_INVALID".equals(req.getParameter("err"))) {
            req.setAttribute("errorMsg", "Invalid room.");
        } else if ("INVALID_INPUT".equals(req.getParameter("err"))) {
            req.setAttribute("errorMsg", "Invalid seat type.");
        }

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");

        Long roomId = parseLongOrNull(req.getParameter("roomId"));
        if (roomId == null) {
            resp.sendRedirect(req.getContextPath() + "/branch/seats");
            return;
        }

        // Gom loai ghe tu cac input ten "type_<seatId>".
        Map<Long, String> submitted = collectSeatTypes(req);

        try {
            SeatManagementService service = new SeatManagementServiceImpl();
            String result = service.updateSeatTypes(roomId, branchId, submitted);

            if (SeatManagementService.RESULT_OK.equals(result)) {
                resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&saved=1");
            } else {
                // Loi nghiep vu -> ve lai phong do kem ma loi (GET hien thong bao).
                resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&err=" + result);
            }
        } catch (RuntimeException ex) {
            getServletContext().log("System error while updating seat types", ex);
            resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&err=SYSTEM");
        }
    }

    /** Doc moi input "type_<seatId>" thanh map seatId -> loai ghe. */
    private Map<Long, String> collectSeatTypes(HttpServletRequest req) {
        Map<Long, String> map = new HashMap<>();
        Enumeration<String> names = req.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name.startsWith(PARAM_PREFIX)) {
                Long seatId = parseLongOrNull(name.substring(PARAM_PREFIX.length()));
                if (seatId != null) {
                    map.put(seatId, req.getParameter(name).trim());
                }
            }
        }
        return map;
    }

    /** Nhom ghe theo hang, giu thu tu (findByRoom da ORDER BY row, col). */
    private Map<String, List<Seat>> groupByRow(List<Seat> seats) {
        Map<String, List<Seat>> byRow = new LinkedHashMap<>();
        for (Seat s : seats) {
            byRow.computeIfAbsent(s.getRowLabel(), k -> new java.util.ArrayList<>()).add(s);
        }
        return byRow;
    }

    private Long parseLongOrNull(String s) {
        if (s == null || s.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
