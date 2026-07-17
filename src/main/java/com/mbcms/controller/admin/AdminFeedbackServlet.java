package com.mbcms.controller.admin;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.model.Employee;
import com.mbcms.model.Feedback;
import com.mbcms.service.FeedbackService;
import com.mbcms.service.impl.FeedbackServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Map;

/**
 * AdminFeedbackServlet - Feedback Tracking cho Admin (toan he thong, khong gioi han branch).
 *
 * GET  /admin/feedbacks            → danh sach tat ca feedback
 * POST /admin/feedbacks            → cap nhat trang thai + phan hoi (action=update)
 * GET  /admin/feedbacks?action=export → xuat CSV
 *
 * Bao ve boi RoleFilter (/admin/* → ADMIN only).
 */
@WebServlet("/admin/feedbacks")
public class AdminFeedbackServlet extends HttpServlet {

    private static final String VIEW      = "/WEB-INF/views/admin/feedback/list.jsp";
    private static final int    PAGE_SIZE = 20;

    private final FeedbackService feedbackService = new FeedbackServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("export".equals(action)) {
            handleExport(req, resp);
            return;
        }

        // Filter params
        String category = req.getParameter("category");
        String status   = req.getParameter("status");
        String search   = req.getParameter("search");
        String branchParam = req.getParameter("branchId");
        Long branchFilter = null;
        if (branchParam != null && !branchParam.isEmpty()) {
            try { branchFilter = Long.parseLong(branchParam); }
            catch (NumberFormatException ignored) {}
        }
        LocalDate fromDate = parseDate(req.getParameter("fromDate"));
        LocalDate toDate   = parseDate(req.getParameter("toDate"));

        int page = parsePage(req);

        // Admin scope = null (no branch restriction)
        int total      = feedbackService.countByFilter(branchFilter, category, status, search, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        List<Feedback> feedbacks = feedbackService.getByFilter(branchFilter, category, status, search, fromDate, toDate, page, PAGE_SIZE);
        Map<String, Integer> summary = feedbackService.getStatusSummary(null); // system-wide

        List<Branch> branches = new BranchDAOImpl().findAll(true);

        req.setAttribute("feedbacks",    feedbacks);
        req.setAttribute("summary",      summary);
        req.setAttribute("totalCount",   total);
        req.setAttribute("currentPage",  page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("selCategory",  category);
        req.setAttribute("selStatus",    status);
        req.setAttribute("search",       search);
        req.setAttribute("selBranchId",  branchFilter);
        req.setAttribute("branches",     branches);
        req.setAttribute("selFromDate",  req.getParameter("fromDate"));
        req.setAttribute("selToDate",    req.getParameter("toDate"));

        // Flash messages
        req.setAttribute("successMsg", req.getParameter("success") != null
                ? "Feedback updated successfully." : null);
        req.setAttribute("errorMsg", req.getParameter("error") != null
                ? req.getParameter("error") : null);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Get current admin from session
        Employee admin = getEmployee(req);
        if (admin == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        long feedbackId;
        try {
            feedbackId = Long.parseLong(req.getParameter("feedbackId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/feedbacks?error=invalid_id");
            return;
        }

        String newStatus = trim(req.getParameter("newStatus"));
        String response  = trim(req.getParameter("response"));

        // Admin has no branch scope restriction (null)
        String error = feedbackService.updateStatus(feedbackId, newStatus, response,
                admin.getUsername(), null);

        if (error != null) {
            resp.sendRedirect(req.getContextPath() + "/admin/feedbacks?error="
                    + java.net.URLEncoder.encode(error, StandardCharsets.UTF_8));
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/feedbacks?success=1");
        }
    }

    // ── Export CSV ────────────────────────────────────────────────────────────

    private void handleExport(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String category = req.getParameter("category");
        String status   = req.getParameter("status");
        String search   = req.getParameter("search");
        Long branchFilter = null;
        String branchParam = req.getParameter("branchId");
        if (branchParam != null && !branchParam.isEmpty()) {
            try { branchFilter = Long.parseLong(branchParam); }
            catch (NumberFormatException ignored) {}
        }
        LocalDate fromDate = parseDate(req.getParameter("fromDate"));
        LocalDate toDate   = parseDate(req.getParameter("toDate"));

        List<Feedback> data = feedbackService.getForExport(branchFilter, category, status, search, fromDate, toDate);

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"feedbacks_all.csv\"");

        try (PrintWriter out = resp.getWriter()) {
            out.print('\ufeff');
            out.println("ID,Category,SubCategory,Name,Email,Subject,Status,HandledBy,BranchId,CreatedAt,ResolvedAt");
            for (Feedback f : data) {
                out.printf("%d,%s,%s,\"%s\",%s,\"%s\",%s,%s,%s,%s,%s%n",
                        f.getFeedbackId(),
                        nvl(f.getCategory()),
                        nvl(f.getSubCategory()),
                        escape(f.getName()),
                        nvl(f.getEmail()),
                        escape(f.getSubject()),
                        nvl(f.getStatus()),
                        nvl(f.getHandledBy()),
                        f.getBranchId() != null ? f.getBranchId() : "",
                        f.getCreatedAt() != null ? f.getCreatedAt().toString() : "",
                        f.getResolvedAt() != null ? f.getResolvedAt().toString() : "");
            }
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private Employee getEmployee(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object obj = session.getAttribute("currentUser");
        return (obj instanceof Employee e) ? e : null;
    }

    private int parsePage(HttpServletRequest req) {
        try {
            return Math.max(1, Integer.parseInt(req.getParameter("page")));
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    private LocalDate parseDate(String s) {
        if (s == null || s.isBlank()) return null;
        try { return LocalDate.parse(s); } catch (DateTimeParseException e) { return null; }
    }

    private String trim(String s) { return s == null ? null : s.trim(); }
    private String nvl(String s)  { return s == null ? "" : s; }
    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\"", "\"\"");
    }
}
