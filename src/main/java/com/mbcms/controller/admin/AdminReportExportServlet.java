package com.mbcms.controller.admin;

import com.mbcms.service.ReportService;
import com.mbcms.service.impl.ReportServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.OutputStream;
import java.time.LocalDate;

@WebServlet("/admin/reports/export")
public class AdminReportExportServlet extends HttpServlet {

    private final ReportService reportService = new ReportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tab = req.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "ticketSales";
        }

        String branchStr = req.getParameter("branchId");
        Long branchId = (branchStr != null && !branchStr.isEmpty()) ? Long.parseLong(branchStr) : null;
        if ("revenue".equals(tab)) {
            branchId = null; // force null for system revenue
        }

        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");
        LocalDate from = (fromStr != null && !fromStr.isEmpty()) ? LocalDate.parse(fromStr) : null;
        LocalDate to = (toStr != null && !toStr.isEmpty()) ? LocalDate.parse(toStr) : null;

        try {
            byte[] csvBytes = reportService.exportCsv(tab, branchId, from, to);
            resp.setContentType("text/csv");
            resp.setHeader("Content-Disposition", "attachment; filename=\"report_" + tab + ".csv\"");
            resp.setContentLength(csvBytes.length);
            try (OutputStream out = resp.getOutputStream()) {
                out.write(csvBytes);
            }
        } catch (IllegalArgumentException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, e.getMessage());
        }
    }
}
