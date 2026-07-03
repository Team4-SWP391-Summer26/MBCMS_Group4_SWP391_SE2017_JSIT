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
            getServletContext().log("Error in AdminBranchServlet#doGet: ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading branch data.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Invalid action.");
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
                    resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=Unknown action.");
            }
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("Error in AdminBranchServlet: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg=A system error occurred.");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Branch b = parseBranchFromRequest(req);
        boolean success = branchService.addBranch(b);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode("Branch added successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Failed to add branch.", "UTF-8"));
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
                    + java.net.URLEncoder.encode("Branch information updated successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Update failed.", "UTF-8"));
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        boolean success = branchService.toggleBranchStatus(branchId, active);
        String msg = active ? "Branch activated successfully!" : "Branch deactivated successfully!";
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode(msg, "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Failed to change status.", "UTF-8"));
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long branchId = Long.parseLong(req.getParameter("branchId"));
        boolean success = branchService.toggleBranchStatus(branchId, false);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?successMsg="
                    + java.net.URLEncoder.encode("Branch deactivated successfully!", "UTF-8"));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/branches?errorMsg="
                    + java.net.URLEncoder.encode("Failed to delete or deactivate branch.", "UTF-8"));
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
            throw new IllegalArgumentException("Invalid time format.");
        }
    }
}
