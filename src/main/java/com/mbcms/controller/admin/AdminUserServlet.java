package com.mbcms.controller.admin;

import com.mbcms.dto.UserDTO;
import com.mbcms.dto.UserStatsDTO;
import com.mbcms.model.Branch;
import com.mbcms.service.BranchService;
import com.mbcms.service.UserService;
import com.mbcms.service.impl.BranchServiceImpl;
import com.mbcms.service.impl.UserServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserService userService = new UserServiceImpl();
    private final BranchService branchService = new BranchServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) {
            action = "list";
        }

        try {
            switch (action) {
                case "add":
                    showAddForm(req, resp);
                    break;
                case "edit":
                    showEditForm(req, resp);
                    break;
                case "list":
                default:
                    showUserList(req, resp);
                    break;
            }
        } catch (Exception e) {
            getServletContext().log("Lỗi doGet AdminUserServlet: ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi hệ thống khi tải trang quản lý người dùng.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Hành động không hợp lệ.", "UTF-8"));
            return;
        }

        HttpSession session = req.getSession(false);
        String sessionUser = (session != null) ? (String) session.getAttribute("username") : null;

        try {
            switch (action) {
                case "add":
                    handleAddUser(req, resp);
                    break;
                case "edit":
                    handleEditUser(req, resp, sessionUser);
                    break;
                case "toggleStatus":
                    handleToggleStatus(req, resp, sessionUser);
                    break;
                case "delete":
                    handleDeleteUser(req, resp, sessionUser);
                    break;
                case "resetPassword":
                    handleResetPassword(req, resp);
                    break;
                case "export":
                    handleExportCSV(req, resp);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Hành động không xác định.", "UTF-8"));
            }
        } catch (IllegalArgumentException e) {
            // Send error back to respective form or list
            String redirAction = req.getParameter("action");
            String username = req.getParameter("username");
            String path = req.getContextPath() + "/admin/users";
            if ("edit".equals(redirAction) && username != null) {
                path += "?action=edit&username=" + username;
            } else if ("add".equals(redirAction)) {
                path += "?action=add";
            }
            String separator = path.contains("?") ? "&" : "?";
            resp.sendRedirect(path + separator + "errorMsg=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Lỗi doPost AdminUserServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Đã xảy ra lỗi hệ thống.", "UTF-8"));
        }
    }

    private void showUserList(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        String role = req.getParameter("role");
        String branchIdStr = req.getParameter("branchId");
        String status = req.getParameter("status"); // Active, Inactive, or empty (All)
        String pageStr = req.getParameter("page");

        Long branchId = null;
        if (branchIdStr != null && !branchIdStr.isBlank()) {
            try {
                branchId = Long.parseLong(branchIdStr);
            } catch (NumberFormatException ignored) {}
        }

        int currentPage = 1;
        if (pageStr != null && !pageStr.isBlank()) {
            try {
                currentPage = Integer.parseInt(pageStr);
                if (currentPage < 1) currentPage = 1;
            } catch (NumberFormatException ignored) {}
        }

        int pageSize = 10;
        int totalUsers = userService.getTotalUsersCount(search, role, branchId, status);
        int totalPages = (int) Math.ceil((double) totalUsers / pageSize);
        if (totalPages == 0) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;

        List<UserDTO> users = userService.getUsers(search, role, branchId, status, currentPage, pageSize);
        UserStatsDTO stats = userService.getUserStats();
        List<Branch> branches = branchService.getAllBranches(true);

        req.setAttribute("users", users);
        req.setAttribute("stats", stats);
        req.setAttribute("branches", branches);
        req.setAttribute("selectedBranchId", branchId);
        req.setAttribute("selectedRole", role);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("searchQuery", search);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("totalUsersCount", totalUsers);

        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));

        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }

    private void showAddForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Branch> branches = branchService.getAllBranches(true);
        req.setAttribute("branches", branches);
        req.setAttribute("isAdd", true);
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));
        req.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(req, resp);
    }

    private void showEditForm(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        if (username == null || username.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Tên đăng nhập không hợp lệ.", "UTF-8"));
            return;
        }

        UserDTO user = userService.getUserByUsername(username.trim());
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Người dùng không tồn tại.", "UTF-8"));
            return;
        }

        List<Branch> branches = branchService.getAllBranches(true);
        req.setAttribute("branches", branches);
        req.setAttribute("user", user);
        req.setAttribute("isAdd", false);
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.getRequestDispatcher("/WEB-INF/views/admin/edit_user.jsp").forward(req, resp);
    }

    private void handleAddUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        UserDTO u = extractUserFromRequest(req);
        String password = req.getParameter("password");

        boolean success = userService.addUser(u, password);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?successMsg=" + URLEncoder.encode("Thêm người dùng mới thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users?action=add&errorMsg=" + URLEncoder.encode("Thêm thất bại.", "UTF-8"));
        }
    }

    private void handleEditUser(HttpServletRequest req, HttpServletResponse resp, String sessionUser) throws IOException {
        UserDTO u = extractUserFromRequest(req);
        String password = req.getParameter("password");

        boolean success = userService.editUser(u, password, sessionUser);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?successMsg=" + URLEncoder.encode("Cập nhật thông tin người dùng thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users?action=edit&username=" + u.getUsername() + "&errorMsg=" + URLEncoder.encode("Cập nhật thất bại.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, String sessionUser) throws IOException {
        String username = req.getParameter("username");
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        boolean success = userService.toggleStatus(username, active, sessionUser);
        String msg = active ? "Kích hoạt tài khoản thành công!" : "Đã vô hiệu hóa tài khoản thành công!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?successMsg=" + URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Thay đổi trạng thái thất bại.", "UTF-8"));
        }
    }

    private void handleDeleteUser(HttpServletRequest req, HttpServletResponse resp, String sessionUser) throws IOException {
        String username = req.getParameter("username");

        boolean success = userService.deleteUser(username, sessionUser);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?successMsg=" + URLEncoder.encode("Xóa tài khoản thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users?errorMsg=" + URLEncoder.encode("Xóa tài khoản thất bại.", "UTF-8"));
        }
    }

    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = req.getParameter("username");

        boolean success = userService.sendPasswordResetEmail(username);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?action=edit&username=" + username + "&successMsg=" + URLEncoder.encode("Đã gửi email khôi phục mật khẩu giả lập thành công!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/users?action=edit&username=" + username + "&errorMsg=" + URLEncoder.encode("Gửi thất bại.", "UTF-8"));
        }
    }

    private void handleExportCSV(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String search = req.getParameter("search");
        String role = req.getParameter("role");
        String branchIdStr = req.getParameter("branchId");
        String status = req.getParameter("status");

        Long branchId = null;
        if (branchIdStr != null && !branchIdStr.isBlank()) {
            try {
                branchId = Long.parseLong(branchIdStr);
            } catch (NumberFormatException ignored) {}
        }

        // Retrieve all users matching filter (up to 1000 for export)
        List<UserDTO> users = userService.getUsers(search, role, branchId, status, 1, 1000);

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"users_export.csv\"");

        // Print BOM for UTF-8 to display correctly in Excel
        PrintWriter writer = resp.getWriter();
        writer.write('\ufeff');

        writer.println("Tên đăng nhập,Email,Họ và tên,Số điện thoại,Vai trò,Chi nhánh gán,Trạng thái");
        for (UserDTO u : users) {
            String branchName = u.getBranchName() != null ? u.getBranchName() : "—";
            String statusText = u.isActive() ? "Active" : "Inactive";
            writer.println(escapeCSV(u.getUsername()) + ","
                    + escapeCSV(u.getEmail()) + ","
                    + escapeCSV(u.getFullName()) + ","
                    + escapeCSV(u.getPhone()) + ","
                    + escapeCSV(u.getRole()) + ","
                    + escapeCSV(branchName) + ","
                    + escapeCSV(statusText));
        }
        writer.flush();
    }

    private String escapeCSV(String val) {
        if (val == null) return "";
        if (val.contains(",") || val.contains("\"") || val.contains("\n")) {
            return "\"" + val.replace("\"", "\"\"") + "\"";
        }
        return val;
    }

    private UserDTO extractUserFromRequest(HttpServletRequest req) {
        UserDTO u = new UserDTO();
        u.setUsername(req.getParameter("username"));
        u.setEmail(req.getParameter("email"));
        u.setFullName(req.getParameter("fullName"));
        u.setPhone(req.getParameter("phone"));
        u.setRole(req.getParameter("role"));

        String branchIdStr = req.getParameter("branchId");
        if (branchIdStr != null && !branchIdStr.isBlank()) {
            try {
                u.setBranchId(Long.parseLong(branchIdStr));
            } catch (NumberFormatException ignored) {}
        }

        String activeStr = req.getParameter("active");
        u.setActive(activeStr == null || "true".equalsIgnoreCase(activeStr) || "on".equalsIgnoreCase(activeStr));

        String dobStr = req.getParameter("dateOfBirth");
        if (dobStr != null && !dobStr.isBlank()) {
            try {
                u.setDateOfBirth(LocalDate.parse(dobStr));
            } catch (Exception ignored) {}
        }

        u.setAddress(req.getParameter("address"));
        return u;
    }
}
