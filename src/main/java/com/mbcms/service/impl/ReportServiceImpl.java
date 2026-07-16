package com.mbcms.service.impl;

import com.mbcms.dao.ReportDAO;
import com.mbcms.dao.impl.ReportDAOImpl;
import com.mbcms.model.report.*;
import com.mbcms.service.ReportService;

import java.io.ByteArrayOutputStream;
import java.io.PrintWriter;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ReportServiceImpl implements ReportService {

    private final ReportDAO reportDao;

    public ReportServiceImpl() {
        this.reportDao = new ReportDAOImpl();
    }

    public ReportServiceImpl(ReportDAO reportDao) {
        this.reportDao = reportDao;
    }

    private LocalDate[] getValidDateRange(LocalDate from, LocalDate to) {
        LocalDate end = to != null ? to : LocalDate.now();
        LocalDate start = from != null ? from : end.minusDays(29);

        if (start.isAfter(end)) {
            throw new IllegalArgumentException("'From Date' cannot be after 'To Date'.");
        }
        if (ChronoUnit.DAYS.between(start, end) > 365) {
            throw new IllegalArgumentException("Date range cannot exceed 1 year.");
        }
        return new LocalDate[]{start, end};
    }

    @Override
    public List<TicketSalesRow> ticketSales(Long branchId, LocalDate from, LocalDate to, Long movieId) {
        LocalDate[] range = getValidDateRange(from, to);
        return reportDao.getTicketSales(branchId, range[0], range[1], movieId);
    }

    @Override
    public List<FnbSalesRow> fnbSales(Long branchId, LocalDate from, LocalDate to) {
        LocalDate[] range = getValidDateRange(from, to);
        return reportDao.getFnbSales(branchId, range[0], range[1]);
    }

    @Override
    public List<BranchRevenueRow> branchRevenue(Long branchId, LocalDate from, LocalDate to) {
        LocalDate[] range = getValidDateRange(from, to);
        return reportDao.getBranchRevenue(branchId, range[0], range[1]);
    }

    @Override
    public RevenueSummary systemRevenue(Long branchScope, LocalDate from, LocalDate to) {
        if (branchScope != null) {
            throw new SecurityException("System revenue cannot be filtered by a specific branch.");
        }
        LocalDate[] range = getValidDateRange(from, to);
        List<BranchRevenueRow> rows = reportDao.getBranchRevenue(null, range[0], range[1]);

        java.math.BigDecimal totalRevenue  = java.math.BigDecimal.ZERO;
        java.math.BigDecimal ticketRevenue = java.math.BigDecimal.ZERO;
        java.math.BigDecimal fnbRevenue    = java.math.BigDecimal.ZERO;
        int totalBookings = 0;

        for (BranchRevenueRow row : rows) {
            totalRevenue  = totalRevenue.add(row.getTotalRevenue());
            ticketRevenue = ticketRevenue.add(row.getTicketRevenue());
            fnbRevenue    = fnbRevenue.add(row.getFnbRevenue());
            totalBookings += row.getBookingsCount();
        }

        return new RevenueSummary(totalRevenue, ticketRevenue, fnbRevenue, totalBookings, rows);
    }

    @Override
    public List<PopularMovieRow> popularMovies(Long branchId, LocalDate from, LocalDate to, int limit) {
        LocalDate[] range = getValidDateRange(from, to);
        return reportDao.getPopularMovies(branchId, range[0], range[1], limit);
    }

    @Override
    public List<PeakBookingRow> peakBookingTimes(Long branchId, LocalDate from, LocalDate to) {
        LocalDate[] range = getValidDateRange(from, to);
        List<PeakBookingRow> dbResult = reportDao.getPeakBookingTimes(branchId, range[0], range[1]);

        Map<Integer, Integer> counts = new HashMap<>();
        for (PeakBookingRow row : dbResult) {
            counts.put(row.getHourOfDay(), row.getBookingsCount());
        }

        List<PeakBookingRow> filledResult = new ArrayList<>();
        for (int i = 0; i < 24; i++) {
            filledResult.add(new PeakBookingRow(i, counts.getOrDefault(i, 0)));
        }
        return filledResult;
    }

    @Override
    public byte[] exportCsv(String reportType, Long branchId, LocalDate from, LocalDate to) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (PrintWriter writer = new PrintWriter(baos, false, StandardCharsets.UTF_8)) {
            // Write BOM for Excel UTF-8 support
            writer.write('\ufeff');

            switch (reportType) {
                case "ticketSales":
                    writer.println("Date,Movie Title,Tickets Sold,Revenue");
                    for (TicketSalesRow r : ticketSales(branchId, from, to, null)) {
                        writer.printf("%s,\"%s\",%d,%.2f%n", r.getDate(), escapeCsv(r.getMovieTitle()), r.getTicketsSold(), r.getRevenue());
                    }
                    break;
                case "fnbSales":
                    writer.println("Item Name,Category,Qty Sold,Revenue");
                    for (FnbSalesRow r : fnbSales(branchId, from, to)) {
                        writer.printf("\"%s\",\"%s\",%d,%.2f%n", escapeCsv(r.getItemName()), escapeCsv(r.getCategory()), r.getQtySold(), r.getRevenue());
                    }
                    break;
                case "branchRevenue":
                    writer.println("Branch Name,Ticket Revenue,F&B Revenue,Total Revenue,Bookings Count");
                    for (BranchRevenueRow r : branchRevenue(branchId, from, to)) {
                        writer.printf("\"%s\",%.2f,%.2f,%.2f,%d%n", escapeCsv(r.getBranchName()), r.getTicketRevenue(), r.getFnbRevenue(), r.getTotalRevenue(), r.getBookingsCount());
                    }
                    break;
                case "revenue":
                    writer.println("Branch Name,Ticket Revenue,F&B Revenue,Total Revenue,Bookings Count");
                    RevenueSummary sys = systemRevenue(null, from, to);
                    for (BranchRevenueRow r : sys.getByBranch()) {
                        writer.printf("\"%s\",%.2f,%.2f,%.2f,%d%n", escapeCsv(r.getBranchName()), r.getTicketRevenue(), r.getFnbRevenue(), r.getTotalRevenue(), r.getBookingsCount());
                    }
                    writer.printf("\"%s\",%.2f,%.2f,%.2f,%d%n", "SYSTEM TOTAL", sys.getTicketRevenue(), sys.getFnbRevenue(), sys.getTotalRevenue(), sys.getTotalBookings());
                    break;
                case "popularMovies":
                    writer.println("Movie Title,Tickets Sold,Revenue");
                    for (PopularMovieRow r : popularMovies(branchId, from, to, 50)) {
                        writer.printf("\"%s\",%d,%.2f%n", escapeCsv(r.getTitle()), r.getTicketsSold(), r.getRevenue());
                    }
                    break;
                case "peakBooking":
                    writer.println("Hour of Day,Bookings Count");
                    for (PeakBookingRow r : peakBookingTimes(branchId, from, to)) {
                        writer.printf("%02d:00,%d%n", r.getHourOfDay(), r.getBookingsCount());
                    }
                    break;
                default:
                    writer.println("Unknown report type: " + reportType);
            }
            writer.flush();
        }
        return baos.toByteArray();
    }

    private String escapeCsv(String val) {
        if (val == null) return "";
        return val.replace("\"", "\"\"");
    }

    @Override
    public com.mbcms.dto.DashboardMetricsDTO getDashboardMetrics(LocalDate from, LocalDate to) {
        LocalDate[] range = getValidDateRange(from, to);
        com.mbcms.dto.DashboardMetricsDTO dto = reportDao.getDashboardMetrics(range[0], range[1]);
        dto.setRevenueSummary(systemRevenue(null, range[0], range[1]));
        dto.setPopularMovies(popularMovies(null, range[0], range[1], 5));
        return dto;
    }
}
