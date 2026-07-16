package com.mbcms.controller.branch;

import com.mbcms.service.ReportService;
import com.mbcms.service.impl.ReportServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/branch/reports")
public class BranchReportServlet extends HttpServlet {

    private final ReportService reportService = new ReportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");

        String tab = req.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "ticketSales";
        }
        if ("revenue".equals(tab)) {
            tab = "ticketSales"; // Block revenue tab for branch
        }

        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");
        LocalDate from = (fromStr != null && !fromStr.isEmpty()) ? LocalDate.parse(fromStr) : null;
        LocalDate to = (toStr != null && !toStr.isEmpty()) ? LocalDate.parse(toStr) : null;

        try {
            switch (tab) {
                case "ticketSales":
                    req.setAttribute("ticketSales", reportService.ticketSales(branchId, from, to, null));
                    break;
                case "fnbSales":
                    req.setAttribute("fnbSales", reportService.fnbSales(branchId, from, to));
                    break;
                case "branchRevenue":
                    req.setAttribute("branchRevenue", reportService.branchRevenue(branchId, from, to));
                    break;
                case "popularMovies":
                    req.setAttribute("popularMovies", reportService.popularMovies(branchId, from, to, 10));
                    break;
                case "peakBooking":
                    req.setAttribute("peakBooking", reportService.peakBookingTimes(branchId, from, to));
                    break;
                default:
                    tab = "ticketSales";
                    req.setAttribute("ticketSales", reportService.ticketSales(branchId, from, to, null));
            }
        } catch (IllegalArgumentException e) {
            req.setAttribute("errorMessage", e.getMessage());
        }

        req.setAttribute("activeTab", tab);
        req.setAttribute("from", fromStr);
        req.setAttribute("to", toStr);
        req.getRequestDispatcher("/WEB-INF/views/branch/reports.jsp").forward(req, resp);
    }
}
