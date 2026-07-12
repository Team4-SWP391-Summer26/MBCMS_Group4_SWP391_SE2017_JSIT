package com.mbcms.controller.branch;

import com.mbcms.model.Room;
import com.mbcms.service.RoomService;
import com.mbcms.service.impl.RoomServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/branch/halls")
public class BranchHallServlet extends HttpServlet {

    private final RoomService roomService = new RoomServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        Long branchId = (session != null) ? (Long) session.getAttribute("currentBranchId") : null;

        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to manage this branch.");
            return;
        }

        List<Room> rooms = roomService.getRoomsByBranch(branchId, true);
        req.setAttribute("rooms", rooms);
        
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));

        req.getRequestDispatcher("/WEB-INF/views/branch/halls.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        HttpSession session = req.getSession(false);
        Long branchId = (session != null) ? (Long) session.getAttribute("currentBranchId") : null;

        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You do not have permission to manage this branch.");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=Invalid action.");
            return;
        }

        try {
            switch (action) {
                case "add":
                    handleAdd(req, resp, branchId);
                    break;
                case "edit":
                    handleEdit(req, resp, branchId);
                    break;
                case "toggleStatus":
                    handleToggleStatus(req, resp, branchId);
                    break;
                case "delete":
                    handleDelete(req, resp, branchId);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=Unknown action.");
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Error in BranchHallServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=A system error occurred.");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        String name = req.getParameter("name");
        int capacity = Integer.parseInt(req.getParameter("capacity"));
        String roomType = req.getParameter("roomType");

        Room r = new Room();
        r.setBranchId(branchId);
        r.setName(name);
        r.setCapacity(capacity);
        r.setRoomType(roomType);

        boolean success = roomService.addRoom(r);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode("Hall added successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Failed to add hall.", "UTF-8"));
        }
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        String name = req.getParameter("name");
        String roomType = req.getParameter("roomType");

        // Verify ownership
        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("You do not have permission to edit this hall.");
        }

        room.setName(name);
        room.setRoomType(roomType);

        boolean success = roomService.updateRoom(room);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode("Hall updated successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Failed to update hall.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        // Verify ownership
        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("You do not have permission to edit this hall.");
        }

        boolean success = roomService.toggleRoomStatus(roomId, active);
        String msg = active ? "Hall activated successfully!" : "Hall deactivated successfully!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Failed to change status.", "UTF-8"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));

        // Verify ownership
        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("You do not have permission to delete this hall.");
        }

        boolean success = roomService.deleteRoom(roomId);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode("Hall deleted successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Failed to delete hall.", "UTF-8"));
        }
    }
}
