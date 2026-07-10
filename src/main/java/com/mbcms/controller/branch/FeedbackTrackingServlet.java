package com.mbcms.controller.branch;

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
 * FeedbackTrackingServlet - Feedback Tracking cho Branch Manager va Branch Staff.
 *
 * GET  /branch/feedbacks            → danh sach feedback cua chi nhanh
 * POST /branch/feedbacks?action=update → cap nhat trang thai + phan hoi
 * GET  /branch/feedbacks?action=export → xuat CSV
 *
 * Bao ve boi RoleFilter (BRANCH_MANAGER hoac BRANCH_STAFF).
 */
@WebServlet(urlPatterns = {
    "/branch/feedbacks", "/branch/feedbacks/update", "/branch/feedbacks/export",
    "/staff/feedbacks", "/staff/feedbacks/update", "/staff/feedbacks/export"
})
public class FeedbackTrackingServlet extends HttpServlet {

    private static final String VIEW     = "/WEB-INF/views/branch/feedback/list.jsp";
    private static final int    PAGE_SIZE = 20;

    private final FeedbackService feedbackService = new FeedbackServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Employee employee = getEmployee(req);
        if (employee == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        ConsoleSupport.ensureBranchName(req);
        Long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "No branch assigned.");
            return;
        }

        String action = req.getParameter("action");
        if ("export".equals(action)) {
            handleExport(req, resp, branchId);
            return;
        }

        // Filter params
        String category = req.getParameter("category");
        String status   = req.getParameter("status");
        String search   = req.getParameter("search");
        LocalDate fromDate = parseDate(req.getParameter("fromDate"));
        LocalDate toDate   = parseDate(req.getParameter("toDate"));

        int page = parsePage(req);

        int total      = feedbackService.countByFilter(branchId, category, status, search, fromDate, toDate);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        List<Feedback> feedbacks = feedbackService.getByFilter(branchId, category, status, search, fromDate, toDate, page, PAGE_SIZE);
        Map<String, Integer> summary = feedbackService.getStatusSummary(branchId);

        String uri = req.getRequestURI();
        String prefix = uri.contains("/staff/") ? "/staff" : "/branch";
        req.setAttribute("baseUrl",   prefix + "/feedbacks");
        req.setAttribute("updateUrl", prefix + "/feedbacks");
        req.setAttribute("isStaff",   uri.contains("/staff/"));

        req.setAttribute("feedbacks",    feedbacks);
        req.setAttribute("summary",      summary);
        req.setAttribute("totalCount",   total);
        req.setAttribute("currentPage",  page);
        req.setAttribute("totalPages",   totalPages);
        req.setAttribute("selCategory",  category);
        req.setAttribute("selStatus",    status);
        req.setAttribute("search",       search);
        req.setAttribute("selFromDate",  req.getParameter("fromDate"));
        req.setAttribute("selToDate",    req.getParameter("toDate"));

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Employee employee = getEmployee(req);
        if (employee == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        Long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "No branch assigned.");
            return;
        }

        String uri = req.getRequestURI();
        String prefix = uri.contains("/staff/") ? "/staff" : "/branch";

        long feedbackId;
        try {
            feedbackId = Long.parseLong(req.getParameter("feedbackId"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + prefix + "/feedbacks?error=invalid_id");
            return;
        }

        String newStatus = trim(req.getParameter("newStatus"));
        String response  = trim(req.getParameter("response"));

        String error = feedbackService.updateStatus(feedbackId, newStatus, response,
                employee.getUsername(), branchId);

        if (error != null) {
            resp.sendRedirect(req.getContextPath() + prefix + "/feedbacks?error="
                    + java.net.URLEncoder.encode(error, StandardCharsets.UTF_8));
        } else {
            resp.sendRedirect(req.getContextPath() + prefix + "/feedbacks?success=updated");
        }
    }

    // ── Export CSV ────────────────────────────────────────────────────────────

    private void handleExport(HttpServletRequest req, HttpServletResponse resp, Long branchId)
            throws IOException {
        String category = req.getParameter("category");
        String status   = req.getParameter("status");
        String search   = req.getParameter("search");
        LocalDate fromDate = parseDate(req.getParameter("fromDate"));
        LocalDate toDate   = parseDate(req.getParameter("toDate"));

        List<Feedback> data = feedbackService.getForExport(branchId, category, status, search, fromDate, toDate);

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"feedbacks_branch.csv\"");

        try (PrintWriter out = resp.getWriter()) {
            // BOM for Excel UTF-8 recognition
            out.print('\ufeff');
            out.println("ID,Category,SubCategory,Name,Email,Subject,Status,HandledBy,CreatedAt,ResolvedAt");
            for (Feedback f : data) {
                out.printf("%d,%s,%s,\"%s\",%s,\"%s\",%s,%s,%s,%s%n",
                        f.getFeedbackId(),
                        nvl(f.getCategory()),
                        nvl(f.getSubCategory()),
                        escape(f.getName()),
                        nvl(f.getEmail()),
                        escape(f.getSubject()),
                        nvl(f.getStatus()),
                        nvl(f.getHandledBy()),
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
            int p = Integer.parseInt(req.getParameter("page"));
            return Math.max(1, p);
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
