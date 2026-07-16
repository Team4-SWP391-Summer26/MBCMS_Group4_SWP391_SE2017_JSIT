package com.mbcms.model.report;

import java.math.BigDecimal;

public class PopularMovieRow {
    private long movieId;
    private String title;
    private String posterUrl;
    private int ticketsSold;
    private BigDecimal revenue;
    private double occupancyRate;

    public PopularMovieRow() {}

    public PopularMovieRow(long movieId, String title, String posterUrl, int ticketsSold, BigDecimal revenue, double occupancyRate) {
        this.movieId = movieId;
        this.title = title;
        this.posterUrl = posterUrl;
        this.ticketsSold = ticketsSold;
        this.revenue = revenue;
        this.occupancyRate = occupancyRate;
    }

    public long getMovieId() { return movieId; }
    public void setMovieId(long movieId) { this.movieId = movieId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getPosterUrl() { return posterUrl; }
    public void setPosterUrl(String posterUrl) { this.posterUrl = posterUrl; }

    public int getTicketsSold() { return ticketsSold; }
    public void setTicketsSold(int ticketsSold) { this.ticketsSold = ticketsSold; }

    public BigDecimal getRevenue() { return revenue; }
    public void setRevenue(BigDecimal revenue) { this.revenue = revenue; }

    public double getOccupancyRate() { return occupancyRate; }
    public void setOccupancyRate(double occupancyRate) { this.occupancyRate = occupancyRate; }
}
