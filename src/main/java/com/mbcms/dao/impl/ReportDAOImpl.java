package com.mbcms.dao.impl;

import com.mbcms.dao.ReportDAO;
import com.mbcms.model.report.*;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ReportDAOImpl extends BaseDAO implements ReportDAO {

    private static final String CTE_BOOKING_REVENUES =
        "WITH BookingRevenues AS ( " +
        "    SELECT b.booking_id, CAST(b.created_at AS DATE) AS sale_date, b.showtime_id, b.created_at, " +
        "           b.total_amount - ISNULL(( " +
        "               SELECT SUM(bfi.quantity * fi.price) " +
        "               FROM dbo.food_orders fo " +
        "               JOIN dbo.booking_food_items bfi ON fo.food_order_id = bfi.food_order_id " +
        "               JOIN dbo.food_items fi ON fi.food_id = bfi.food_id " +
        "               WHERE fo.booking_id = b.booking_id " +
        "           ), 0) AS ticket_revenue, " +
        "           ISNULL(( " +
        "               SELECT SUM(bfi.quantity * fi.price) " +
        "               FROM dbo.food_orders fo " +
        "               JOIN dbo.booking_food_items bfi ON fo.food_order_id = bfi.food_order_id " +
        "               JOIN dbo.food_items fi ON fi.food_id = bfi.food_id " +
        "               WHERE fo.booking_id = b.booking_id " +
        "           ), 0) AS fnb_revenue, " +
        "           (SELECT COUNT(*) FROM dbo.booking_seats bs WHERE bs.booking_id = b.booking_id) AS tickets_sold, " +
        "           b.total_amount AS total_revenue " +
        "    FROM dbo.bookings b " +
        "    WHERE b.status IN ('CONFIRMED', 'USED') " +
        ") ";

    @Override
    public List<TicketSalesRow> getTicketSales(Long branchId, LocalDate from, LocalDate to, Long movieId) {
        List<TicketSalesRow> list = new ArrayList<>();
        String sql = CTE_BOOKING_REVENUES +
            "SELECT br.sale_date, m.title, SUM(br.tickets_sold) AS tickets_sold, SUM(br.ticket_revenue) AS revenue " +
            "FROM BookingRevenues br " +
            "JOIN dbo.showtimes st ON st.showtime_id = br.showtime_id " +
            "JOIN dbo.movies m ON m.movie_id = st.movie_id " +
            "JOIN dbo.rooms r ON r.room_id = st.room_id " +
            "WHERE br.sale_date BETWEEN ? AND ? " +
            (branchId != null ? "  AND r.branch_id = ? " : "") +
            (movieId != null ? "  AND m.movie_id = ? " : "") +
            "GROUP BY br.sale_date, m.title " +
            "ORDER BY br.sale_date DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            int paramIndex = 3;
            if (branchId != null) ps.setLong(paramIndex++, branchId);
            if (movieId != null) ps.setLong(paramIndex, movieId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new TicketSalesRow(
                        rs.getDate("sale_date").toLocalDate(),
                        rs.getString("title"),
                        rs.getInt("tickets_sold"),
                        rs.getBigDecimal("revenue")
                    ));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting ticket sales", e);
        }
        return list;
    }

    @Override
    public List<FnbSalesRow> getFnbSales(Long branchId, LocalDate from, LocalDate to) {
        List<FnbSalesRow> list = new ArrayList<>();
        String sql =
            "SELECT fi.name AS item_name, fi.category, SUM(bfi.quantity) AS qty_sold, SUM(bfi.quantity * fi.price) AS revenue " +
            "FROM dbo.bookings b " +
            "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id " +
            "JOIN dbo.rooms r ON r.room_id = st.room_id " +
            "JOIN dbo.food_orders fo ON fo.booking_id = b.booking_id " +
            "JOIN dbo.booking_food_items bfi ON bfi.food_order_id = fo.food_order_id " +
            "JOIN dbo.food_items fi ON fi.food_id = bfi.food_id " +
            "WHERE b.status IN ('CONFIRMED', 'USED') " +
            "  AND CAST(b.created_at AS DATE) BETWEEN ? AND ? " +
            (branchId != null ? "  AND r.branch_id = ? " : "") +
            "GROUP BY fi.name, fi.category " +
            "ORDER BY revenue DESC";


        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            if (branchId != null) ps.setLong(3, branchId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new FnbSalesRow(
                        rs.getString("item_name"),
                        rs.getString("category"),
                        rs.getInt("qty_sold"),
                        rs.getBigDecimal("revenue")
                    ));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting F&B sales", e);
        }
        return list;
    }

    @Override
    public List<BranchRevenueRow> getBranchRevenue(Long branchId, LocalDate from, LocalDate to) {
        List<BranchRevenueRow> list = new ArrayList<>();
        String sql = CTE_BOOKING_REVENUES +
            "SELECT br_table.branch_id, br_table.name AS branch_name, " +
            "       ISNULL(SUM(br.ticket_revenue), 0) AS ticket_revenue, " +
            "       ISNULL(SUM(br.fnb_revenue), 0) AS fnb_revenue, " +
            "       ISNULL(SUM(br.total_revenue), 0) AS total_revenue, " +
            "       COUNT(br.booking_id) AS bookings_count " +
            "FROM dbo.branches br_table " +
            "LEFT JOIN dbo.rooms r ON r.branch_id = br_table.branch_id " +
            "LEFT JOIN dbo.showtimes st ON st.room_id = r.room_id " +
            "LEFT JOIN BookingRevenues br ON br.showtime_id = st.showtime_id " +
            "   AND br.sale_date BETWEEN ? AND ? " +
            (branchId != null ? "WHERE br_table.branch_id = ? " : "") +
            "GROUP BY br_table.branch_id, br_table.name " +
            "ORDER BY total_revenue DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            if (branchId != null) ps.setLong(3, branchId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new BranchRevenueRow(
                        rs.getLong("branch_id"),
                        rs.getString("branch_name"),
                        rs.getBigDecimal("ticket_revenue"),
                        rs.getBigDecimal("fnb_revenue"),
                        rs.getBigDecimal("total_revenue"),
                        rs.getInt("bookings_count")
                    ));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting branch revenue", e);
        }
        return list;
    }

    @Override
    public RevenueSummary getSystemRevenue(LocalDate from, LocalDate to) {
        RevenueSummary summary = new RevenueSummary();
        summary.setTotalRevenue(BigDecimal.ZERO);
        summary.setTicketRevenue(BigDecimal.ZERO);
        summary.setFnbRevenue(BigDecimal.ZERO);
        summary.setTotalBookings(0);

        List<BranchRevenueRow> branches = getBranchRevenue(null, from, to);
        summary.setByBranch(branches);

        for (BranchRevenueRow r : branches) {
            summary.setTotalRevenue(summary.getTotalRevenue().add(r.getTotalRevenue()));
            summary.setTicketRevenue(summary.getTicketRevenue().add(r.getTicketRevenue()));
            summary.setFnbRevenue(summary.getFnbRevenue().add(r.getFnbRevenue()));
            summary.setTotalBookings(summary.getTotalBookings() + r.getBookingsCount());
        }

        return summary;
    }

    @Override
    public List<PopularMovieRow> getPopularMovies(Long branchId, LocalDate from, LocalDate to, int limit) {
        List<PopularMovieRow> list = new ArrayList<>();
        String sql = CTE_BOOKING_REVENUES +
            "SELECT TOP (?) m.movie_id, m.title, m.poster_url, " +
            "       SUM(br.tickets_sold) AS tickets_sold, " +
            "       SUM(br.ticket_revenue) AS revenue " +
            "FROM BookingRevenues br " +
            "JOIN dbo.showtimes st ON st.showtime_id = br.showtime_id " +
            "JOIN dbo.movies m ON m.movie_id = st.movie_id " +
            "JOIN dbo.rooms r ON r.room_id = st.room_id " +
            "WHERE br.sale_date BETWEEN ? AND ? " +
            (branchId != null ? "  AND r.branch_id = ? " : "") +
            "GROUP BY m.movie_id, m.title, m.poster_url " +
            "ORDER BY tickets_sold DESC";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, limit > 0 ? limit : 10);
            ps.setDate(2, java.sql.Date.valueOf(from));
            ps.setDate(3, java.sql.Date.valueOf(to));
            if (branchId != null) ps.setLong(4, branchId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new PopularMovieRow(
                        rs.getLong("movie_id"),
                        rs.getString("title"),
                        rs.getString("poster_url"),
                        rs.getInt("tickets_sold"),
                        rs.getBigDecimal("revenue"),
                        0.0 // Occupancy rate is complex, leave 0 for now as it needs all showtimes capacity
                    ));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting popular movies", e);
        }
        return list;
    }

    @Override
    public List<PeakBookingRow> getPeakBookingTimes(Long branchId, LocalDate from, LocalDate to) {
        List<PeakBookingRow> list = new ArrayList<>();
        String sql = CTE_BOOKING_REVENUES +
            "SELECT DATEPART(HOUR, br.created_at) AS hour_of_day, COUNT(br.booking_id) AS bookings_count " +
            "FROM BookingRevenues br " +
            "JOIN dbo.showtimes st ON st.showtime_id = br.showtime_id " +
            "JOIN dbo.rooms r ON r.room_id = st.room_id " +
            "WHERE br.sale_date BETWEEN ? AND ? " +
            (branchId != null ? "  AND r.branch_id = ? " : "") +
            "GROUP BY DATEPART(HOUR, br.created_at) " +
            "ORDER BY hour_of_day";

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(from));
            ps.setDate(2, java.sql.Date.valueOf(to));
            if (branchId != null) ps.setLong(3, branchId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new PeakBookingRow(
                        rs.getInt("hour_of_day"),
                        rs.getInt("bookings_count")
                    ));
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Error getting peak booking times", e);
        }
        return list;
    }

    @Override
    public com.mbcms.dto.DashboardMetricsDTO getDashboardMetrics(LocalDate from, LocalDate to) {
        com.mbcms.dto.DashboardMetricsDTO dto = new com.mbcms.dto.DashboardMetricsDTO();

        try (Connection conn = getConnection()) {
            // 1. Basic Counts (Users & Cinemas)
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.customers WHERE active = 1")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) dto.setActiveUsers(rs.getInt(1)); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.customers WHERE created_at >= ?")) {
                ps.setDate(1, java.sql.Date.valueOf(from));
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) dto.setNewUsers(rs.getInt(1)); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.branches WHERE active = 1")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) dto.setActiveCinemas(rs.getInt(1)); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.branches")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) dto.setTotalCinemas(rs.getInt(1)); }
            }

            // 2. System Health
            com.mbcms.model.report.SystemHealthDTO health = new com.mbcms.model.report.SystemHealthDTO();
            try (PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM dbo.feedbacks WHERE status = 'NEW'")) {
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) health.setPendingReviews(rs.getInt(1)); }
            }
            try (PreparedStatement ps = conn.prepareStatement("SELECT CAST(SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END) AS FLOAT) / NULLIF(COUNT(*), 0) FROM dbo.bookings WHERE created_at BETWEEN ? AND ?")) {
                ps.setDate(1, java.sql.Date.valueOf(from));
                ps.setDate(2, java.sql.Date.valueOf(to.plusDays(1))); // Include end day
                try (ResultSet rs = ps.executeQuery()) { if (rs.next()) health.setBookingSuccessRate(rs.getDouble(1) * 100); }
            }
            dto.setSystemHealth(health);

            // 3. User Growth
            java.util.List<com.mbcms.model.report.UserGrowthRow> growth = new java.util.ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT CAST(created_at AS DATE) as dt, COUNT(*) FROM dbo.customers WHERE created_at >= ? GROUP BY CAST(created_at AS DATE) ORDER BY dt")) {
                ps.setDate(1, java.sql.Date.valueOf(from));
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        growth.add(new com.mbcms.model.report.UserGrowthRow(rs.getDate(1).toLocalDate(), rs.getInt(2)));
                    }
                }
            }
            dto.setUserGrowth(growth);

            // 4. Payment Mix
            java.util.List<com.mbcms.model.report.PaymentMixRow> mix = new java.util.ArrayList<>();
            try (PreparedStatement ps = conn.prepareStatement("SELECT method, COUNT(*) FROM dbo.payments WHERE paid_at BETWEEN ? AND ? GROUP BY method")) {
                ps.setDate(1, java.sql.Date.valueOf(from));
                ps.setDate(2, java.sql.Date.valueOf(to.plusDays(1)));
                try (ResultSet rs = ps.executeQuery()) {
                    int total = 0;
                    while (rs.next()) {
                        com.mbcms.model.report.PaymentMixRow row = new com.mbcms.model.report.PaymentMixRow();
                        row.setMethod(rs.getString(1));
                        row.setCount(rs.getInt(2));
                        total += row.getCount();
                        mix.add(row);
                    }
                    if (total > 0) {
                        for (com.mbcms.model.report.PaymentMixRow r : mix) {
                            r.setPercentage(r.getCount() * 100.0 / total);
                        }
                    }
                }
            }
            dto.setPaymentMix(mix);

            // 5. Daily Revenue Trend
            java.util.List<com.mbcms.model.report.DailyRevenueRow> trend = new java.util.ArrayList<>();
            String trendSql = CTE_BOOKING_REVENUES +
                "SELECT br.sale_date, r.branch_id, SUM(br.ticket_revenue + br.fnb_revenue) " +
                "FROM BookingRevenues br " +
                "JOIN dbo.showtimes st ON st.showtime_id = br.showtime_id " +
                "JOIN dbo.rooms r ON r.room_id = st.room_id " +
                "WHERE br.sale_date BETWEEN ? AND ? " +
                "GROUP BY br.sale_date, r.branch_id " +
                "ORDER BY br.sale_date";

            try (PreparedStatement ps = conn.prepareStatement(trendSql)) {
                ps.setDate(1, java.sql.Date.valueOf(from));
                ps.setDate(2, java.sql.Date.valueOf(to));
                try (ResultSet rs = ps.executeQuery()) {
                    LocalDate currentDt = null;
                    com.mbcms.model.report.DailyRevenueRow currentRow = null;

                    while (rs.next()) {
                        LocalDate dt = rs.getDate(1).toLocalDate();
                        Long branchId = rs.getLong(2);
                        java.math.BigDecimal rev = rs.getBigDecimal(3);

                        if (currentRow == null || !dt.equals(currentDt)) {
                            currentRow = new com.mbcms.model.report.DailyRevenueRow();
                            currentRow.setDate(dt);
                            currentRow.setRevenueByBranch(new java.util.HashMap<>());
                            currentRow.setTotalRevenue(java.math.BigDecimal.ZERO);
                            trend.add(currentRow);
                            currentDt = dt;
                        }
                        currentRow.getRevenueByBranch().put(branchId, rev);
                        currentRow.setTotalRevenue(currentRow.getTotalRevenue().add(rev));
                    }
                }
            }
            dto.setDailyRevenueTrend(trend);

        } catch (SQLException e) {
            throw new RuntimeException("Error getting dashboard metrics", e);
        }

        return dto;
    }
}
