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
        if (action == null) {
            action = "list";
        }

        try {
            if ("edit".equals(action)) {
                long branchId = Long.parseLong(req.getParameter("branchId"));
                Branch b = branchService.getBranchById(branchId);
                req.setAttribute("branch", b);
                req.setAttribute("isAdd", false);
                req.setAttribute("successMsg", req.getParameter("successMsg"));
                req.setAttribute("errorMsg", req.getParameter("errorMsg"));
                req.getRequestDispatcher("/WEB-INF/views/admin/edit_branch.jsp").forward(req, resp);
                return;
            } else if ("add".equals(action)) {
                req.setAttribute("isAdd", true);
                req.setAttribute("errorMsg", req.getParameter("errorMsg"));
                req.getRequestDispatcher("/WEB-INF/views/admin/edit_branch.jsp").forward(req, resp);
                return;
            }
            
            // List view
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
                case "updateHours":
                    handleUpdateHours(req, resp);
                    break;
                case "delete":
                    handleDelete(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Hành động không xác định.");
            }
        } catch (IllegalArgumentException e) {
            String redirAction = req.getParameter("action");
            String branchId = req.getParameter("branchId");
            String path = req.getContextPath() + "/admin/branches";
            if ("edit".equals(redirAction) && branchId != null) {
                path += "?action=edit&branchId=" + branchId;
            } else if ("add".equals(redirAction)) {
                path += "?action=add";
            }
            String separator = path.contains("?") ? "&" : "?";
            resp.sendRedirect(path + separator + "errorMsg=" + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Lỗi trong AdminBranchServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Đã xảy ra lỗi hệ thống.");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = req.getParameter("name");
        String address = req.getParameter("address");
        String city = req.getParameter("city");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String openStr = req.getParameter("openingTime");
        String closeStr = req.getParameter("closingTime");

        Branch b = new Branch();
        b.setName(name);
        b.setAddress(address);
        b.setCity(city);
        b.setPhone(phone);
        b.setEmail(email);
        b.setOpeningTime(openStr != null && !openStr.isBlank() ? LocalTime.parse(openStr) : LocalTime.of(8, 0));
        b.setClosingTime(closeStr != null && !closeStr.isBlank() ? LocalTime.parse(closeStr) : LocalTime.of(23, 0));

        boolean success = branchService.addBranch(b);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg=" + java.net.URLEncoder.encode("Thêm chi nhánh mới thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?action=add&errorMsg=" + java.net.URLEncoder.encode("Thêm chi nhánh thất bại.", "UTF-8"));
        }
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        String name = req.getParameter("name");
        String address = req.getParameter("address");
        String city = req.getParameter("city");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String openStr = req.getParameter("openingTime");
        String closeStr = req.getParameter("closingTime");
        String activeStr = req.getParameter("active");

        Branch b = new Branch();
        b.setBranchId(branchId);
        b.setName(name);
        b.setAddress(address);
        b.setCity(city);
        b.setPhone(phone);
        b.setEmail(email);
        b.setOpeningTime(openStr != null && !openStr.isBlank() ? LocalTime.parse(openStr) : LocalTime.of(8, 0));
        b.setClosingTime(closeStr != null && !closeStr.isBlank() ? LocalTime.parse(closeStr) : LocalTime.of(23, 0));
        b.setActive(activeStr != null && ("true".equalsIgnoreCase(activeStr) || "on".equalsIgnoreCase(activeStr)));

        boolean success = branchService.updateBranch(b);
        if (success) {
            branchService.updateOperatingHours(branchId, b.getOpeningTime(), b.getClosingTime());
            branchService.toggleBranchStatus(branchId, b.isActive());
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg=" + java.net.URLEncoder.encode("Cập nhật thông tin chi nhánh thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?action=edit&branchId=" + branchId + "&errorMsg=" + java.net.URLEncoder.encode("Cập nhật thất bại.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        boolean success = branchService.toggleBranchStatus(branchId, active);
        String msg = active ? "Kích hoạt chi nhánh thành công!" : "Vô hiệu hóa chi nhánh thành công!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg=" + java.net.URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=" + java.net.URLEncoder.encode("Thay đổi trạng thái thất bại.", "UTF-8"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));

        boolean success = branchService.toggleBranchStatus(branchId, false);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg=" + java.net.URLEncoder.encode("Đã vô hiệu hóa chi nhánh thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=" + java.net.URLEncoder.encode("Xóa/vô hiệu hóa chi nhánh thất bại.", "UTF-8"));
        }
    }

    private void handleUpdateHours(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        String openStr = req.getParameter("openingTime");
        String closeStr = req.getParameter("closingTime");

        try {
            LocalTime open = LocalTime.parse(openStr);
            LocalTime close = LocalTime.parse(closeStr);

            boolean success = branchService.updateOperatingHours(branchId, open, close);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg=" + java.net.URLEncoder.encode("Cập nhật giờ hoạt động thành công!", "UTF-8"));
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=" + java.net.URLEncoder.encode("Cập nhật giờ hoạt động thất bại.", "UTF-8"));
            }
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Định dạng thời gian không hợp lệ. Vui lòng thử lại.");
        }
    }
}