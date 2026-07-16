package com.mbcms.model.report;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

public class DailyRevenueRow {
    private LocalDate date;
    private BigDecimal totalRevenue;
    private Map<Long, BigDecimal> revenueByBranch; // Map<branchId, revenue>

    public DailyRevenueRow() {}

    public DailyRevenueRow(LocalDate date, BigDecimal totalRevenue, Map<Long, BigDecimal> revenueByBranch) {
        this.date = date;
        this.totalRevenue = totalRevenue;
        this.revenueByBranch = revenueByBranch;
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public Map<Long, BigDecimal> getRevenueByBranch() { return revenueByBranch; }
    public void setRevenueByBranch(Map<Long, BigDecimal> revenueByBranch) { this.revenueByBranch = revenueByBranch; }
}
