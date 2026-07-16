package com.mbcms.model.report;

import java.math.BigDecimal;

public class BranchRevenueRow {
    private long branchId;
    private String branchName;
    private BigDecimal ticketRevenue;
    private BigDecimal fnbRevenue;
    private BigDecimal totalRevenue;
    private int bookingsCount;

    public BranchRevenueRow() {}

    public BranchRevenueRow(long branchId, String branchName, BigDecimal ticketRevenue, BigDecimal fnbRevenue, BigDecimal totalRevenue, int bookingsCount) {
        this.branchId = branchId;
        this.branchName = branchName;
        this.ticketRevenue = ticketRevenue;
        this.fnbRevenue = fnbRevenue;
        this.totalRevenue = totalRevenue;
        this.bookingsCount = bookingsCount;
    }

    public long getBranchId() { return branchId; }
    public void setBranchId(long branchId) { this.branchId = branchId; }

    public String getBranchName() { return branchName; }
    public void setBranchName(String branchName) { this.branchName = branchName; }

    public BigDecimal getTicketRevenue() { return ticketRevenue; }
    public void setTicketRevenue(BigDecimal ticketRevenue) { this.ticketRevenue = ticketRevenue; }

    public BigDecimal getFnbRevenue() { return fnbRevenue; }
    public void setFnbRevenue(BigDecimal fnbRevenue) { this.fnbRevenue = fnbRevenue; }

    public BigDecimal getTotalRevenue() { return totalRevenue; }
    public void setTotalRevenue(BigDecimal totalRevenue) { this.totalRevenue = totalRevenue; }

    public int getBookingsCount() { return bookingsCount; }
    public void setBookingsCount(int bookingsCount) { this.bookingsCount = bookingsCount; }
}
