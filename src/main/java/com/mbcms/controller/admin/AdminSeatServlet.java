package com.mbcms.controller.admin;

import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.PricingService;
import com.mbcms.service.RoomService;
import com.mbcms.service.SeatService;
import com.mbcms.service.impl.PricingServiceImpl;
import com.mbcms.service.impl.RoomServiceImpl;
import com.mbcms.service.impl.SeatServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.*;

@WebServlet("/admin/seats")
public class AdminSeatServlet extends HttpServlet {

    private final SeatService seatService = new SeatServiceImpl();
    private final RoomService roomService = new RoomServiceImpl();
    private final PricingService pricingService = new PricingServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        Long roomId = parseLong(req.getParameter("roomId"));
        if (roomId == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing roomId parameter.");
            return;
        }

        Room room = roomService.getRoomById(roomId);
        if (room == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Hall not found.");
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
        req.setAttribute("vipSurchargePercent", pricingService.getVipSurchargePercent());

        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));

        req.getRequestDispatcher("/WEB-INF/views/admin/seats.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String action = req.getParameter("action");
        if (action == null) {
            String roomIdParam = req.getParameter("roomId");
            if (roomIdParam != null && !roomIdParam.isBlank()) {
                resp.sendRedirect(req.getContextPath() + "/admin/seats?roomId=" + roomIdParam.trim()
                        + "&errorMsg=" + java.net.URLEncoder.encode("Invalid action.", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg="
                        + java.net.URLEncoder.encode("Invalid action.", "UTF-8"));
            }
            return;
        }

        try {
            if ("regenerate".equals(action)) {
                handleRegenerate(req, resp);
            } else if ("updateSeat".equals(action)) {
                handleUpdateSeatAJAX(req, resp);
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/seats?errorMsg=Unknown action.");
            }
        } catch (IllegalArgumentException e) {
            if ("updateSeat".equals(action)) {
                sendErrorJSON(resp, e.getMessage());
            } else {
                String roomIdParam = req.getParameter("roomId");
                if (roomIdParam != null && !roomIdParam.isBlank()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/seats?roomId=" + roomIdParam + "&errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
                }
            }
        } catch (Exception e) {
            getServletContext().log("Error in AdminSeatServlet: ", e);
            if ("updateSeat".equals(action)) {
                sendErrorJSON(resp, "System error.");
            } else {
                String roomIdParam = req.getParameter("roomId");
                if (roomIdParam != null && !roomIdParam.isBlank()) {
                    resp.sendRedirect(req.getContextPath() + "/admin/seats?roomId=" + roomIdParam + "&errorMsg=A system error occurred.");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=A system error occurred.");
                }
            }
        }
    }

    private void handleRegenerate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        int rowsCount = Integer.parseInt(req.getParameter("rowsCount"));
        int colsCount = Integer.parseInt(req.getParameter("colsCount"));
        String defaultType = req.getParameter("defaultType");

        boolean success = seatService.regenerateLayout(roomId, rowsCount, colsCount, defaultType);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/seats?roomId=" + roomId + "&successMsg=" + java.net.URLEncoder.encode("Seat layout reset successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/seats?roomId=" + roomId + "&errorMsg=" + java.net.URLEncoder.encode("Failed to reset seat layout.", "UTF-8"));
        }
    }

    private void handleUpdateSeatAJAX(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long seatId = Long.parseLong(req.getParameter("seatId"));
        long roomId = Long.parseLong(req.getParameter("roomId"));
        String type = req.getParameter("seatType");
        String activeStr = req.getParameter("active");

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        boolean success = false;
        if (activeStr != null) {
            boolean active = Boolean.parseBoolean(activeStr);
            success = seatService.updateSeatStatus(seatId, roomId, active);
        } else if (type != null) {
            success = seatService.updateSeatType(seatId, roomId, type);
        }

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
}
