package com.mbcms.controller.admin;

import com.mbcms.service.ReportService;
import com.mbcms.service.impl.ReportServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/admin/reports")
public class AdminReportServlet extends HttpServlet {

    private final ReportService reportService = new ReportServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tab = req.getParameter("tab");
        if (tab == null || tab.trim().isEmpty()) {
            tab = "dashboard";
        }

        String branchStr = req.getParameter("branchId");
        Long branchId = (branchStr != null && !branchStr.isEmpty()) ? Long.parseLong(branchStr) : null;

        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");
        LocalDate from = (fromStr != null && !fromStr.isEmpty()) ? LocalDate.parse(fromStr) : null;
        LocalDate to = (toStr != null && !toStr.isEmpty()) ? LocalDate.parse(toStr) : null;

        try {
            switch (tab) {
                case "dashboard":
                    req.setAttribute("metrics", reportService.getDashboardMetrics(from, to));
                    break;
                case "ticketSales":
                    req.setAttribute("ticketSales", reportService.ticketSales(branchId, from, to, null));
                    break;
                case "fnbSales":
                    req.setAttribute("fnbSales", reportService.fnbSales(branchId, from, to));
                    break;
                case "branchRevenue":
                    req.setAttribute("branchRevenue", reportService.branchRevenue(branchId, from, to));
                    break;
                case "revenue":
                    req.setAttribute("revenue", reportService.systemRevenue(null, from, to)); // force branchId = null for system revenue
                    break;
                case "popularMovies":
                    req.setAttribute("popularMovies", reportService.popularMovies(branchId, from, to, 10));
                    break;
                case "peakBooking":
                    req.setAttribute("peakBooking", reportService.peakBookingTimes(branchId, from, to));
                    break;
                default:
                    tab = "dashboard";
                    req.setAttribute("metrics", reportService.getDashboardMetrics(from, to));
            }
        } catch (IllegalArgumentException | SecurityException e) {
            req.setAttribute("errorMessage", e.getMessage());
        }

        req.setAttribute("activeTab", tab);
        req.setAttribute("from", fromStr);
        req.setAttribute("to", toStr);
        req.setAttribute("selectedBranchId", branchId);

        // Cần truyền list branches ra view để render dropdown filter branch
        // req.setAttribute("branches", new BranchDAOImpl().findAll());
        // Thay vì query dao thẳng, ta có thể dùng filter này trên view bằng script lấy qua api, hoặc đơn giản để view xử lý.

        req.getRequestDispatcher("/WEB-INF/views/admin/reports.jsp").forward(req, resp);
    }
}
