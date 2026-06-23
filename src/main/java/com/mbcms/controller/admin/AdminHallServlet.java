package com.mbcms.controller.admin;

import com.mbcms.model.Branch;
import com.mbcms.model.Room;
import com.mbcms.service.BranchService;
import com.mbcms.service.RoomService;
import com.mbcms.service.impl.BranchServiceImpl;
import com.mbcms.service.impl.RoomServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/halls")
public class AdminHallServlet extends HttpServlet {

    private final RoomService roomService = new RoomServiceImpl();
    private final BranchService branchService = new BranchServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        Long branchId = parseLong(req.getParameter("branchId"));
        List<Room> rooms;
        if (branchId != null) {
            rooms = roomService.getRoomsByBranch(branchId, true);
        } else {
            rooms = roomService.getAllRooms(true);
        }

        List<Branch> branches = branchService.getAllBranches(true);
        req.setAttribute("rooms", rooms);
        req.setAttribute("branches", branches);
        req.setAttribute("selectedBranchId", branchId);
        
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));

        req.getRequestDispatcher("/WEB-INF/views/admin/halls.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=Hành động không hợp lệ.");
            return;
        }

        try {
            switch (action) {
                case "add":
                    handleAdd(req, resp);
                    break;
                case "edit":
                    handleEdit(req, resp);
                    break;
                case "toggleStatus":
                    handleToggleStatus(req, resp);
                    break;
                case "delete":
                    handleDelete(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=Hành động không xác định.");
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Lỗi trong AdminHallServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=Đã xảy ra lỗi hệ thống.");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
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
            resp.sendRedirect(req.getContextPath() + "/admin/halls?successMsg=" + java.net.URLEncoder.encode("Thêm phòng chiếu mới thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=" + java.net.URLEncoder.encode("Thêm phòng chiếu thất bại.", "UTF-8"));
        }
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        String name = req.getParameter("name");
        int capacity = Integer.parseInt(req.getParameter("capacity"));
        String roomType = req.getParameter("roomType");

        Room r = new Room();
        r.setRoomId(roomId);
        r.setName(name);
        r.setCapacity(capacity);
        r.setRoomType(roomType);

        boolean success = roomService.updateRoom(r);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?successMsg=" + java.net.URLEncoder.encode("Cập nhật phòng chiếu thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=" + java.net.URLEncoder.encode("Cập nhật phòng chiếu thất bại.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        boolean success = roomService.toggleRoomStatus(roomId, active);
        String msg = active ? "Kích hoạt phòng chiếu thành công!" : "Vô hiệu hóa phòng chiếu thành công!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?successMsg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=" + java.net.URLEncoder.encode("Thay đổi trạng thái thất bại.", "UTF-8"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));

        boolean success = roomService.deleteRoom(roomId);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?successMsg=" + java.net.URLEncoder.encode("Xóa phòng chiếu thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/halls?errorMsg=" + java.net.URLEncoder.encode("Xóa phòng chiếu thất bại.", "UTF-8"));
        }
    }

    private Long parseLong(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Long.parseLong(s.trim()); }
        catch (NumberFormatException e) { return null; }
    }
}
