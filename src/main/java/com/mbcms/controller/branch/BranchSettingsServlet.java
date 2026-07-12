package com.mbcms.controller.branch;

import com.mbcms.model.Branch;
import com.mbcms.service.BranchService;
import com.mbcms.service.impl.BranchServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

/**
 * Branch Manager — edit operating hours for own branch only.
 * URL: /branch/settings
 */
@WebServlet("/branch/settings")
public class BranchSettingsServlet extends HttpServlet {

    private static final DateTimeFormatter TIME_HTML = DateTimeFormatter.ofPattern("HH:mm");

    private final BranchService branchService = new BranchServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long branchId = requireBranchId(req, resp);
        if (branchId == null) {
            return;
        }
        ConsoleSupport.ensureBranchName(req);

        Branch branch = branchService.getBranchById(branchId);
        if (branch == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Branch not found.");
            return;
        }

        req.setAttribute("branch", branch);
        req.setAttribute("openingTimeValue", formatTime(branch.getOpeningTime(), "08:00"));
        req.setAttribute("closingTimeValue", formatTime(branch.getClosingTime(), "23:00"));
        req.setAttribute("successMsg", req.getParameter("successMsg"));
        req.setAttribute("errorMsg", req.getParameter("errorMsg"));
        req.getRequestDispatcher("/WEB-INF/views/branch/settings.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Long branchId = requireBranchId(req, resp);
        if (branchId == null) {
            return;
        }

        try {
            LocalTime open = parseTime(req.getParameter("openingTime"));
            LocalTime close = parseTime(req.getParameter("closingTime"));
            boolean ok = branchService.updateOperatingHours(branchId, open, close);
            if (!ok) {
                redirect(req, resp, "errorMsg", "Could not update operating hours.");
                return;
            }
            redirect(req, resp, "successMsg",
                    "Operating hours saved. New showtimes must stay within "
                            + open.format(TIME_HTML) + " – " + close.format(TIME_HTML) + ".");
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "errorMsg", e.getMessage());
        } catch (Exception e) {
            getServletContext().log("Error in BranchSettingsServlet#doPost: ", e);
            redirect(req, resp, "errorMsg", "A system error occurred.");
        }
    }

    private Long requireBranchId(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return null;
        }
        Long branchId = (Long) session.getAttribute("currentBranchId");
        if (branchId == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "You do not have permission to manage this branch.");
            return null;
        }
        return branchId;
    }

    private static LocalTime parseTime(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Opening and closing times are required.");
        }
        try {
            String v = value.trim();
            if (v.length() > 5) {
                v = v.substring(0, 5);
            }
            return LocalTime.parse(v);
        } catch (DateTimeParseException e) {
            throw new IllegalArgumentException("Invalid time format. Use HH:mm.");
        }
    }

    private static String formatTime(LocalTime t, String fallback) {
        if (t == null) {
            return fallback;
        }
        return t.format(TIME_HTML);
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp, String key, String msg)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + "/branch/settings?" + key + "="
                + URLEncoder.encode(msg == null ? "" : msg, StandardCharsets.UTF_8));
    }
}
