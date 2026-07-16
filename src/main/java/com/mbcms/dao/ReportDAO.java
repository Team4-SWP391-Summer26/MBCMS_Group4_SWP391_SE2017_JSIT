package com.mbcms.dao;

import com.mbcms.model.report.*;

import java.time.LocalDate;
import java.util.List;

public interface ReportDAO {
    List<TicketSalesRow> getTicketSales(Long branchId, LocalDate from, LocalDate to, Long movieId);
    List<FnbSalesRow> getFnbSales(Long branchId, LocalDate from, LocalDate to);
    List<BranchRevenueRow> getBranchRevenue(Long branchId, LocalDate from, LocalDate to);
    RevenueSummary getSystemRevenue(LocalDate from, LocalDate to);
    List<PopularMovieRow> getPopularMovies(Long branchId, LocalDate from, LocalDate to, int limit);
    List<PeakBookingRow> getPeakBookingTimes(Long branchId, LocalDate from, LocalDate to);
    com.mbcms.dto.DashboardMetricsDTO getDashboardMetrics(LocalDate from, LocalDate to);
}
