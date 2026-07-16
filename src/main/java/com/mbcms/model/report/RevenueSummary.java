package com.mbcms.model.report;

import java.math.BigDecimal;
import java.util.List;

public class RevenueSummary {
    private BigDecimal totalRevenue;
    private BigDecimal ticketRevenue;
    private BigDecimal fnbRevenue;
    private int totalBookings;
    private List<BranchRevenueRow> byBranch;

    public RevenueSummary() {}

    public RevenueSummary(BigDecimal totalRevenue, BigDecimal ticketRevenue, BigDecimal fnbRevenue, int totalBookings, List<BranchRevenueRow> byBranch) {
        this.totalRevenue = totalRevenue;
        this.ticketRevenue = ticketRevenue;
        this.fnbRevenue = fnbRevenue;
        this.totalBookings = totalBookings;
        this.byBranch = byBranch;
    }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public BigDecimal getTicketRevenue() { return ticketRevenue; }
    public void setTicketRevenue(BigDecimal ticketRevenue) { this.ticketRevenue = ticketRevenue; }

    public BigDecimal getFnbRevenue() { return fnbRevenue; }
    public void setFnbRevenue(BigDecimal fnbRevenue) { this.fnbRevenue = fnbRevenue; }

    public int getTotalBookings() { return totalBookings; }
    public void setTotalBookings(int totalBookings) { this.totalBookings = totalBookings; }

    public List<BranchRevenueRow> getByBranch() { return byBranch; }
    public void setByBranch(List<BranchRevenueRow> byBranch) { this.byBranch = byBranch; }
}
