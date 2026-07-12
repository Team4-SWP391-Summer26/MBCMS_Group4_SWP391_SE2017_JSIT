package com.mbcms.controller.admin;

import com.mbcms.service.SystemSettingsService;
import com.mbcms.util.SystemSettings;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/**
 * Admin Settings — VIP %, max seats, PENDING hold, showtime gap.
 * URL: /admin/settings
 */
@WebServlet("/admin/settings")
public class AdminSettingsServlet extends HttpServlet {

    private final SystemSettingsService settingsService = SystemSettings.get();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            Map<String, Integer> settings = settingsService.getAllIntSettings();
            req.setAttribute("vipPercent", settings.get(SystemSettingsService.KEY_VIP_SURCHARGE_PERCENT));
            req.setAttribute("maxSeats", settings.get(SystemSettingsService.KEY_MAX_SEATS_PER_BOOKING));
            req.setAttribute("pendingMinutes", settings.get(SystemSettingsService.KEY_PENDING_HOLD_MINUTES));
            req.setAttribute("gapMinutes", settings.get(SystemSettingsService.KEY_SHOWTIME_GAP_MINUTES));
            req.setAttribute("successMsg", req.getParameter("successMsg"));
            req.setAttribute("errorMsg", req.getParameter("errorMsg"));
            req.getRequestDispatcher("/WEB-INF/views/admin/settings.jsp").forward(req, resp);
        } catch (Exception e) {
            getServletContext().log("Error in AdminSettingsServlet#doGet: ", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading settings.");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int vip = parseInt(req.getParameter("vipPercent"));
            int maxSeats = parseInt(req.getParameter("maxSeats"));
            int pending = parseInt(req.getParameter("pendingMinutes"));
            int gap = parseInt(req.getParameter("gapMinutes"));

            settingsService.updateSettings(vip, maxSeats, pending, gap);

            resp.sendRedirect(req.getContextPath() + "/admin/settings?successMsg="
                    + enc("Settings saved. New bookings and showtimes will use these values."));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/settings?errorMsg="
                    + enc("Please enter valid whole numbers."));
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/settings?errorMsg=" + enc(e.getMessage()));
        } catch (Exception e) {
            getServletContext().log("Error in AdminSettingsServlet#doPost: ", e);
            resp.sendRedirect(req.getContextPath() + "/admin/settings?errorMsg="
                    + enc("Could not save settings. Re-run schema+seed if system_settings is missing."));
        }
    }

    private static int parseInt(String raw) {
        if (raw == null || raw.isBlank()) {
            throw new NumberFormatException("blank");
        }
        return Integer.parseInt(raw.trim());
    }

    private static String enc(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }
}
