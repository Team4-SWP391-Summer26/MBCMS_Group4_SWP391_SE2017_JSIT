package com.mbcms.dao.impl;

import com.mbcms.dao.FeedbackDAO;
import com.mbcms.model.Feedback;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * FeedbackDAOImpl - trien khai FeedbackDAO tren SQL Server.
 * Su dung BaseDAO pattern (getConnection() / closeAll()).
 */
public class FeedbackDAOImpl extends BaseDAO implements FeedbackDAO {

    // ── SQL fragments ─────────────────────────────────────────────────────────

    /** Select all columns - order must match mapRow(). */
    private static final String SELECT_ALL =
            "SELECT f.feedback_id, f.customer_username, f.branch_id, "
            + "f.name, f.email, f.subject, f.message, f.[status], f.response, "
            + "f.created_at, f.resolved_at, "
            + "f.category, f.sub_category, f.related_booking_id, f.related_showtime_id, f.handled_by "
            + "FROM dbo.feedbacks f";

    // ── insert ────────────────────────────────────────────────────────────────

    @Override
    public long insert(Feedback f) {
        // Auto-resolve branch_id from showtime or booking
        String resolveBranch = buildBranchResolveSql(f);

        String sql = "INSERT INTO dbo.feedbacks "
                + "(customer_username, branch_id, name, email, subject, message, "
                + " category, sub_category, related_booking_id, related_showtime_id) "
                + "VALUES (?, " + resolveBranch + ", ?, ?, ?, ?, ?, ?, ?, ?); "
                + "SELECT SCOPE_IDENTITY();";

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            int i = 1;
            ps.setString(i++, f.getCustomerUsername());
            // branch_id is inline sub-select – no placeholder needed here
            ps.setString(i++, f.getName());
            ps.setString(i++, f.getEmail());
            ps.setString(i++, f.getSubject());
            ps.setString(i++, f.getMessage());
            ps.setString(i++, f.getCategory());
            if (f.getSubCategory() != null) ps.setString(i++, f.getSubCategory());
            else                             ps.setNull(i++, Types.VARCHAR);
            if (f.getRelatedBookingId() != null) ps.setLong(i++, f.getRelatedBookingId());
            else                                  ps.setNull(i++, Types.BIGINT);
            if (f.getRelatedShowtimeId() != null) ps.setLong(i++, f.getRelatedShowtimeId());
            else                                   ps.setNull(i++, Types.BIGINT);

            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] insert error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return -1L;
    }

    /**
     * Tao sub-select de lay branch_id tu showtime hoac booking.
     * Neu khong co, tra ve NULL literal.
     */
    private String buildBranchResolveSql(Feedback f) {
        if (Feedback.CAT_COMPLAINT.equals(f.getCategory()) && f.getRelatedShowtimeId() != null) {
            // Resolve branch from showtime -> room -> branch
            return "(SELECT r.branch_id FROM dbo.showtimes s "
                    + "JOIN dbo.rooms r ON s.room_id = r.room_id "
                    + "WHERE s.showtime_id = " + f.getRelatedShowtimeId() + ")";
        }
        if (Feedback.CAT_SUPPORT.equals(f.getCategory())
                && Feedback.SUB_BOOKING.equals(f.getSubCategory())
                && f.getRelatedBookingId() != null) {
            // Resolve branch from booking -> showtime -> room -> branch
            return "(SELECT r.branch_id FROM dbo.bookings b "
                    + "JOIN dbo.showtimes s ON b.showtime_id = s.showtime_id "
                    + "JOIN dbo.rooms r ON s.room_id = r.room_id "
                    + "WHERE b.booking_id = " + f.getRelatedBookingId() + ")";
        }
        return "NULL";
    }

    // ── Customer queries ──────────────────────────────────────────────────────

    @Override
    public List<Feedback> findByCustomer(String customerUsername) {
        String sql = SELECT_ALL + " WHERE f.customer_username = ? ORDER BY f.created_at DESC";
        return queryList(sql, customerUsername);
    }

    @Override
    public Feedback findById(long feedbackId) {
        String sql = SELECT_ALL + " WHERE f.feedback_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, feedbackId);
            rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] findById error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return null;
    }

    @Override
    public boolean isBookingOwnedByCustomer(long bookingId, String customerUsername) {
        String sql = "SELECT 1 FROM dbo.bookings WHERE booking_id = ? AND customer_username = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            ps.setString(2, customerUsername);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] isBookingOwnedByCustomer error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return false;
    }

    @Override
    public boolean hasConfirmedBookingForShowtime(long showtimeId, String customerUsername) {
        String sql = "SELECT 1 FROM dbo.bookings "
                + "WHERE showtime_id = ? AND customer_username = ? "
                + "AND [status] IN ('CONFIRMED', 'USED')";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            ps.setString(2, customerUsername);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] hasConfirmedBookingForShowtime error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return false;
    }

    // ── Tracking queries ──────────────────────────────────────────────────────

    @Override
    public int countByFilter(Long branchScope, String category, String status, String search,
                             java.time.LocalDate fromDate, java.time.LocalDate toDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM dbo.feedbacks f WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, branchScope, category, status, search, fromDate, toDate);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            setParams(ps, params);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] countByFilter error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return 0;
    }

    @Override
    public List<Feedback> findByFilter(Long branchScope, String category, String status, String search,
                                       java.time.LocalDate fromDate, java.time.LocalDate toDate,
                                       int page, int pageSize) {
        StringBuilder sql = new StringBuilder(SELECT_ALL + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, branchScope, category, status, search, fromDate, toDate);

        // Order: open statuses first, then newest
        sql.append(" ORDER BY CASE f.[status] WHEN 'NEW' THEN 0 WHEN 'IN_PROGRESS' THEN 1 ELSE 2 END, f.created_at DESC");

        int offset = (page - 1) * pageSize;
        sql.append(" OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");
        params.add(offset);
        params.add(pageSize);

        return queryListWithParams(sql.toString(), params);
    }

    @Override
    public Map<String, Integer> countGroupByStatus(Long branchScope) {
        StringBuilder sql = new StringBuilder(
                "SELECT f.[status], COUNT(*) FROM dbo.feedbacks f WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (branchScope != null) {
            sql.append(" AND f.branch_id = ?");
            params.add(branchScope);
        }
        sql.append(" GROUP BY f.[status]");

        Map<String, Integer> result = new LinkedHashMap<>();
        result.put(Feedback.STATUS_NEW, 0);
        result.put(Feedback.STATUS_IN_PROGRESS, 0);
        result.put(Feedback.STATUS_RESOLVED, 0);
        result.put(Feedback.STATUS_CLOSED, 0);

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            setParams(ps, params);
            rs = ps.executeQuery();
            while (rs.next()) {
                result.put(rs.getString(1), rs.getInt(2));
            }
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] countGroupByStatus error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return result;
    }

    @Override
    public List<Feedback> findTopPending(Long branchScope, int limit) {
        int safeLimit = (limit > 0 && limit <= 50) ? limit : 3;

        StringBuilder sql = new StringBuilder(
                "SELECT TOP (" + safeLimit + ") f.feedback_id, f.customer_username, f.branch_id, "
                + "f.name, f.email, f.subject, f.message, f.[status], f.response, "
                + "f.created_at, f.resolved_at, "
                + "f.category, f.sub_category, f.related_booking_id, f.related_showtime_id, f.handled_by "
                + "FROM dbo.feedbacks f WHERE f.[status] = ?");
        List<Object> params = new ArrayList<>();
        params.add(Feedback.STATUS_NEW);

        if (branchScope != null) {
            sql.append(" AND f.branch_id = ?");
            params.add(branchScope);
        }

        // Earliest submission time first, so staff can prioritize the
        // longest-waiting unresolved feedback.
        sql.append(" ORDER BY f.created_at ASC");

        return queryListWithParams(sql.toString(), params);
    }

    @Override
    public boolean updateStatus(long feedbackId, String newStatus, String response,
                                String handledBy, Long branchScope) {
        StringBuilder sql = new StringBuilder(
                "UPDATE dbo.feedbacks SET [status] = ?, response = ?, handled_by = ?");

        // Auto set resolved_at when closing
        if (Feedback.STATUS_RESOLVED.equals(newStatus) || Feedback.STATUS_CLOSED.equals(newStatus)) {
            sql.append(", resolved_at = SYSUTCDATETIME()");
        } else {
            sql.append(", resolved_at = NULL");
        }

        sql.append(" WHERE feedback_id = ?");
        if (branchScope != null) {
            sql.append(" AND branch_id = ?");  // enforce branch scope
        }

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            int i = 1;
            ps.setString(i++, newStatus);
            if (response != null) ps.setString(i++, response);
            else                   ps.setNull(i++, Types.NVARCHAR);
            if (handledBy != null) ps.setString(i++, handledBy);
            else                    ps.setNull(i++, Types.VARCHAR);
            ps.setLong(i++, feedbackId);
            if (branchScope != null) ps.setLong(i++, branchScope);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] updateStatus error: " + e.getMessage());
        } finally {
            closeAll(ps, conn);
        }
        return false;
    }

    @Override
    public List<Feedback> findAllForExport(Long branchScope, String category, String status, String search,
                                           java.time.LocalDate fromDate, java.time.LocalDate toDate) {
        StringBuilder sql = new StringBuilder(SELECT_ALL + " WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, branchScope, category, status, search, fromDate, toDate);
        sql.append(" ORDER BY f.created_at DESC");
        sql.append(" OFFSET 0 ROWS FETCH NEXT 5000 ROWS ONLY");
        return queryListWithParams(sql.toString(), params);
    }

    // ── Private helpers ───────────────────────────────────────────────────────

    private void appendFilters(StringBuilder sql, List<Object> params,
                                Long branchScope, String category, String status, String search,
                                java.time.LocalDate fromDate, java.time.LocalDate toDate) {
        if (branchScope != null) {
            sql.append(" AND f.branch_id = ?");
            params.add(branchScope);
        }
        if (category != null && !category.isEmpty()) {
            sql.append(" AND f.category = ?");
            params.add(category);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND f.[status] = ?");
            params.add(status);
        }
        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (f.name LIKE ? OR f.email LIKE ? OR f.subject LIKE ?)");
            String like = "%" + search.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (fromDate != null) {
            sql.append(" AND f.created_at >= ?");
            params.add(java.sql.Timestamp.valueOf(fromDate.atStartOfDay()));
        }
        if (toDate != null) {
            sql.append(" AND f.created_at < ?");
            params.add(java.sql.Timestamp.valueOf(toDate.plusDays(1).atStartOfDay()));
        }
    }

    private List<Feedback> queryList(String sql, String param) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Feedback> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, param);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] queryList error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    private List<Feedback> queryListWithParams(String sql, List<Object> params) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Feedback> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            setParams(ps, params);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (SQLException e) {
            System.err.println("[FeedbackDAO] queryListWithParams error: " + e.getMessage());
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    private void setParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object p = params.get(i);
            if (p instanceof String) ps.setString(i + 1, (String) p);
            else if (p instanceof Long) ps.setLong(i + 1, (Long) p);
            else if (p instanceof Integer) ps.setInt(i + 1, (Integer) p);
            else ps.setObject(i + 1, p);
        }
    }

    /** Map 1 ResultSet row -> Feedback object. Column order matches SELECT_ALL. */
    private Feedback mapRow(ResultSet rs) throws SQLException {
        Feedback f = new Feedback();
        f.setFeedbackId(rs.getLong("feedback_id"));
        f.setCustomerUsername(rs.getString("customer_username"));
        long bid = rs.getLong("branch_id");
        f.setBranchId(rs.wasNull() ? null : bid);
        f.setName(rs.getString("name"));
        f.setEmail(rs.getString("email"));
        f.setSubject(rs.getString("subject"));
        f.setMessage(rs.getString("message"));
        f.setStatus(rs.getString("status"));
        f.setResponse(rs.getString("response"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        f.setCreatedAt(createdAt != null ? createdAt.toLocalDateTime() : null);
        Timestamp resolvedAt = rs.getTimestamp("resolved_at");
        f.setResolvedAt(resolvedAt != null ? resolvedAt.toLocalDateTime() : null);
        // Extended fields
        f.setCategory(rs.getString("category"));
        f.setSubCategory(rs.getString("sub_category"));
        long rbid = rs.getLong("related_booking_id");
        f.setRelatedBookingId(rs.wasNull() ? null : rbid);
        long rsid = rs.getLong("related_showtime_id");
        f.setRelatedShowtimeId(rs.wasNull() ? null : rsid);
        f.setHandledBy(rs.getString("handled_by"));
        return f;
    }
}