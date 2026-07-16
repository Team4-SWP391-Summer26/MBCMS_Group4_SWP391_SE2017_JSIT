package com.mbcms.dto;

import com.mbcms.model.report.DailyRevenueRow;
import com.mbcms.model.report.PaymentMixRow;
import com.mbcms.model.report.SystemHealthDTO;
import com.mbcms.model.report.UserGrowthRow;
import com.mbcms.model.report.RevenueSummary;
import com.mbcms.model.report.PopularMovieRow;

import java.util.List;

public class DashboardMetricsDTO {
    private RevenueSummary revenueSummary;
    private List<PopularMovieRow> popularMovies;

    private int activeUsers;
    private int newUsers;
    private int activeCinemas;
    private int totalCinemas;

    private List<PaymentMixRow> paymentMix;
    private List<DailyRevenueRow> dailyRevenueTrend;
    private List<UserGrowthRow> userGrowth;
    private SystemHealthDTO systemHealth;

    public DashboardMetricsDTO() {}

    public RevenueSummary getRevenueSummary() { return revenueSummary; }
    public void setRevenueSummary(RevenueSummary revenueSummary) { this.revenueSummary = revenueSummary; }

    public List<PopularMovieRow> getPopularMovies() { return popularMovies; }
    public void setPopularMovies(List<PopularMovieRow> popularMovies) { this.popularMovies = popularMovies; }

    public int getActiveUsers() { return activeUsers; }
    public void setActiveUsers(int activeUsers) { this.activeUsers = activeUsers; }

    public int getNewUsers() { return newUsers; }
    public void setNewUsers(int newUsers) { this.newUsers = newUsers; }

    public int getActiveCinemas() { return activeCinemas; }
    public void setActiveCinemas(int activeCinemas) { this.activeCinemas = activeCinemas; }

    public int getTotalCinemas() { return totalCinemas; }
    public void setTotalCinemas(int totalCinemas) { this.totalCinemas = totalCinemas; }

    public List<PaymentMixRow> getPaymentMix() { return paymentMix; }
    public void setPaymentMix(List<PaymentMixRow> paymentMix) { this.paymentMix = paymentMix; }

    public List<DailyRevenueRow> getDailyRevenueTrend() { return dailyRevenueTrend; }
    public void setDailyRevenueTrend(List<DailyRevenueRow> dailyRevenueTrend) { this.dailyRevenueTrend = dailyRevenueTrend; }

    public List<UserGrowthRow> getUserGrowth() { return userGrowth; }
    public void setUserGrowth(List<UserGrowthRow> userGrowth) { this.userGrowth = userGrowth; }

    public SystemHealthDTO getSystemHealth() { return systemHealth; }
    public void setSystemHealth(SystemHealthDTO systemHealth) { this.systemHealth = systemHealth; }
}
