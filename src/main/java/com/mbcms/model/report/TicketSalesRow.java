package com.mbcms.model.report;

import java.math.BigDecimal;
import java.time.LocalDate;

public class TicketSalesRow {
    private LocalDate date;
    private String movieTitle;
    private int ticketsSold;
    private BigDecimal revenue;

    public TicketSalesRow() {}

    public TicketSalesRow(LocalDate date, String movieTitle, int ticketsSold, BigDecimal revenue) {
        this.date = date;
        this.movieTitle = movieTitle;
        this.ticketsSold = ticketsSold;
        this.revenue = revenue;
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public String getMovieTitle() { return movieTitle; }
    public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }

    public int getTicketsSold() { return ticketsSold; }
    public void setTicketsSold(int ticketsSold) { this.ticketsSold = ticketsSold; }

    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }
}
