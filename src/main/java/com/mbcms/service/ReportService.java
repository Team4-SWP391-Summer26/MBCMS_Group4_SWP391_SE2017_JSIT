package com.mbcms.service;

import com.mbcms.model.report.*;

import java.time.LocalDate;
import java.util.List;

public interface ReportService {
    List<TicketSalesRow> ticketSales(Long branchId, LocalDate from, LocalDate to, Long movieId);
    List<FnbSalesRow> fnbSales(Long branchId, LocalDate from, LocalDate to);
    List<BranchRevenueRow> branchRevenue(Long branchId, LocalDate from, LocalDate to);
    RevenueSummary systemRevenue(Long branchScope, LocalDate from, LocalDate to);
    List<PopularMovieRow> popularMovies(Long branchId, LocalDate from, LocalDate to, int limit);
    List<PeakBookingRow> peakBookingTimes(Long branchId, LocalDate from, LocalDate to);
    com.mbcms.dto.DashboardMetricsDTO getDashboardMetrics(LocalDate from, LocalDate to);
    byte[] exportCsv(String reportType, Long branchId, LocalDate from, LocalDate to);
}
