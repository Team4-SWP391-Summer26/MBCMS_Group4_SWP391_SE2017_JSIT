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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý chi nhánh này.");
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
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền quản lý chi nhánh.");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=Hành động không hợp lệ.");
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
                    resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=Hành động không xác định.");
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Lỗi trong BranchHallServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=Đã xảy ra lỗi hệ thống.");
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
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode("Thêm phòng chiếu mới thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Thêm phòng chiếu thất bại.", "UTF-8"));
        }
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        String name = req.getParameter("name");
        String roomType = req.getParameter("roomType");

        // Verify ownership
        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Không có quyền chỉnh sửa phòng chiếu này.");
        }

        room.setName(name);
        room.setRoomType(roomType);

        boolean success = roomService.updateRoom(room);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode("Cập nhật phòng chiếu thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Cập nhật phòng chiếu thất bại.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        // Verify ownership
        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Không có quyền chỉnh sửa phòng chiếu này.");
        }

        boolean success = roomService.toggleRoomStatus(roomId, active);
        String msg = active ? "Kích hoạt phòng chiếu thành công!" : "Vô hiệu hóa phòng chiếu thành công!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Thay đổi trạng thái thất bại.", "UTF-8"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, long branchId) throws IOException {
        long roomId = Long.parseLong(req.getParameter("roomId"));

        // Verify ownership
        Room room = roomService.getRoomById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            throw new IllegalArgumentException("Không có quyền xóa phòng chiếu này.");
        }

        boolean success = roomService.deleteRoom(roomId);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?successMsg=" + java.net.URLEncoder.encode("Xóa phòng chiếu thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/halls?errorMsg=" + java.net.URLEncoder.encode("Xóa phòng chiếu thất bại.", "UTF-8"));
        }
    }
}
