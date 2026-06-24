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
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet("/admin/branches")
public class AdminBranchServlet extends HttpServlet {

    private final BranchService branchService = new BranchServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("edit".equals(action) || "add".equals(action)) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches");
            return;
        }

        try {
            List<Branch> branches = branchService.getAllBranchesWithStats(true);
            req.setAttribute("branches", branches);
            req.setAttribute("successMsg", req.getParameter("successMsg"));
            req.setAttribute("errorMsg", req.getParameter("errorMsg"));
            req.getRequestDispatcher("/WEB-INF/views/admin/branches.jsp").forward(req, resp);
        } catch (Exception e) {
            getServletContext().log("Lỗi doGet AdminBranchServlet: ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi tải dữ liệu chi nhánh.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Hành động không hợp lệ.");
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
                    resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Hành động không xác định.");
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Lỗi trong AdminBranchServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Đã xảy ra lỗi hệ thống.");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Branch b = parseBranchFromRequest(req);
        boolean success = branchService.addBranch(b);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode("Thêm chi nhánh mới thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Thêm chi nhánh thất bại.", "UTF-8"));
        }
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        Branch b = parseBranchFromRequest(req);
        b.setBranchId(branchId);

        LocalTime open = parseTime(req.getParameter("openingTime"), LocalTime.of(8, 0));
        LocalTime close = parseTime(req.getParameter("closingTime"), LocalTime.of(23, 0));
        boolean active = "true".equalsIgnoreCase(req.getParameter("active"));

        boolean success = branchService.saveBranchDetails(b, open, close, active);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode("Cập nhật thông tin chi nhánh thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Cập nhật thất bại.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        boolean success = branchService.toggleBranchStatus(branchId, active);
        String msg = active ? "Kích hoạt chi nhánh thành công!" : "Vô hiệu hóa chi nhánh thành công!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Thay đổi trạng thái thất bại.", "UTF-8"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        boolean success = branchService.toggleBranchStatus(branchId, false);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode("Đã vô hiệu hóa chi nhánh thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Xóa/vô hiệu hóa chi nhánh thất bại.", "UTF-8"));
        }
    }

    private Branch parseBranchFromRequest(HttpServletRequest req) {
        Branch b = new Branch();
        b.setName(req.getParameter("name"));
        b.setAddress(req.getParameter("address"));
        b.setCity(req.getParameter("city"));
        b.setPhone(req.getParameter("phone"));
        b.setEmail(req.getParameter("email"));
        String openStr = req.getParameter("openingTime");
        String closeStr = req.getParameter("closingTime");
        b.setOpeningTime(openStr != null && !openStr.isBlank() ? parseTime(openStr, LocalTime.of(8, 0)) : LocalTime.of(8, 0));
        b.setClosingTime(closeStr != null && !closeStr.isBlank() ? parseTime(closeStr, LocalTime.of(23, 0)) : LocalTime.of(23, 0));
        return b;
    }

    private LocalTime parseTime(String value, LocalTime fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        try {
            if (value.length() > 5) {
                return LocalTime.parse(value.substring(0, 5));
            }
            return LocalTime.parse(value);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Định dạng thời gian không hợp lệ.");
        }
    }
}
