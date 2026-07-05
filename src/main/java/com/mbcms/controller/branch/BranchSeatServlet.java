package com.mbcms.controller.branch;

import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.RoomService;
import com.mbcms.service.SeatService;
import com.mbcms.service.impl.RoomServiceImpl;
import com.mbcms.service.impl.SeatServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/branch/seats", "/branch/seats-type"})
public class BranchSeatServlet extends HttpServlet {

    private static final String LEGACY_PATH = "/branch/seats-type";

    private final SeatService seatService = new SeatServiceImpl();
    private final RoomService roomService = new RoomServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (redirectLegacySeatType(req, resp)) {
            return;
        }

        HttpSession session = req.getSession(false);
        Long branchId = (session != null) ? (Long) session.getAttribute("currentBranchId") : null;

        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to access this page.");
            return;
        }

        Long roomId = parseLong(req.getParameter("roomId"));
        if (roomId == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing roomId parameter.");
            return;
        }

        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to manage this hall.");
            return;
        }

        List<Seat> seats = seatService.getSeatsByRoom(roomId);
        
        // Group by row
        Map<String, List<Seat>> seatsByRow = new LinkedHashMap<>();
        for (Seat seat : seats) {
            seatsByRow.computeIfAbsent(seat.getRowLabel(), k -> new ArrayList<>()).add(seat);
        }

        req.setAttribute("room", room);
        req.setAttribute("seatsByRow", seatsByRow);
        req.setAttribute("roomId", roomId);
        
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));

        req.getRequestDispatcher("/WEB-INF/views/branch/seats.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (redirectLegacySeatType(req, resp)) {
            return;
        }

        HttpSession session = req.getSession(false);
        Long branchId = (session != null) ? (Long) session.getAttribute("currentBranchId") : null;

        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to access this page.");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/branch/seats?errorMsg=Invalid action.");
            return;
        }

        long roomId = Long.parseLong(req.getParameter("roomId"));
        Room room = roomService.getRoomById(roomId);
        // [BAO MAT] room.branchId == session.currentBranchId? Phong phai thuoc dung
        // chi nhanh cua manager dang dang nhap -> chong sua roomId sang phong rap khac.
        if (room == null || room.getBranchId() != branchId) {
            if ("updateSeat".equals(action)) {
                sendErrorJSON(resp, "You do not have permission to manage this hall.");
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=You do not have permission to manage this hall.");
            }
            return;
        }

        try {
            if ("regenerate".equals(action)) {
                handleRegenerate(req, resp, roomId);
            } else if ("updateSeat".equals(action)) {
                handleUpdateSeatAJAX(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&errorMsg=Unknown action.");
            }
        } catch (IllegalArgumentException e) {
            if ("updateSeat".equals(action)) {
                sendErrorJSON(resp, e.getMessage());
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
            }
        } catch (Exception e) {
            getServletContext().log("Error in BranchSeatServlet: ", e);
            if ("updateSeat".equals(action)) {
                sendErrorJSON(resp, "System error.");
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&errorMsg=A system error occurred.");
            }
        }
    }

    private void handleRegenerate(HttpServletRequest req, HttpServletResponse resp, long roomId) throws IOException {
        int rowsCount = Integer.parseInt(req.getParameter("rowsCount"));
        int colsCount = Integer.parseInt(req.getParameter("colsCount"));
        String defaultType = req.getParameter("defaultType");

        boolean success = seatService.regenerateLayout(roomId, rowsCount, colsCount, defaultType);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&successMsg=" + java.net.URLEncoder.encode("Seat layout reset successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/seats?roomId=" + roomId + "&errorMsg=" + java.net.URLEncoder.encode("Failed to reset seat layout.", "UTF-8"));
        }
    }

    // Xu ly AJAX action=updateSeat: doc tham so JS gui len, goi Service, tra ve JSON.
    private void handleUpdateSeatAJAX(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long seatId = Long.parseLong(req.getParameter("seatId"));
        long roomId = Long.parseLong(req.getParameter("roomId"));
        String type = req.getParameter("seatType");
        String activeStr = req.getParameter("active");

        // Tra ve JSON (khong redirect) vi day la goi AJAX tu seat-layout.js.
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        boolean success = false;
        if (activeStr != null) {
            boolean active = Boolean.parseBoolean(activeStr);
            success = seatService.updateSeatStatus(seatId, roomId, active);
        } else if (type != null) {
            // -> vao SeatServiceImpl.updateSeatType: 3 buoc kiem tra roi moi UPDATE.
            success = seatService.updateSeatType(seatId, roomId, type);
        }

        // JS doc dung chuoi nay: success=true -> ve lai mau ghe; false -> bao loi.
        if (success) {
            out.print("{\"success\":true}");
        } else {
            out.print("{\"success\":false,\"message\":\"Update failed.\"}");
        }
        out.flush();
    }

    private void sendErrorJSON(HttpServletResponse resp, String message) throws IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        out.print("{\"success\":false,\"message\":\"" + message.replace("\"", "\\\"") + "\"}");
        out.flush();
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }

    /** Redirect old /branch/seats-type URLs to the unified seat layout flow. */
    private boolean redirectLegacySeatType(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!LEGACY_PATH.equals(req.getServletPath())) {
            return false;
        }
        String roomId = req.getParameter("roomId");
        String target = req.getContextPath()
                + ((roomId != null && !roomId.isBlank())
                ? "/branch/seats?roomId=" + roomId.trim()
                : "/branch/halls");
        resp.sendRedirect(target);
        return true;
    }
}
