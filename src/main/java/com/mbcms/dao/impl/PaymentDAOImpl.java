package com.mbcms.dao.impl;

import com.mbcms.dao.PaymentDAO;
import com.mbcms.model.Payment;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.model.PaymentSummary;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.List;

/**
 * PaymentDAOImpl - thuc hien PaymentDAO (SQL Server, mssql-jdbc).
 *
 * Tuan thu BaseDAO: PreparedStatement, dong tai nguyen trong finally.
 * markSuccess() KHONG dong connection vi connection thuoc transaction cua Service.
 */
public class PaymentDAOImpl extends BaseDAO implements PaymentDAO {

    @Override
    public Payment findByBookingId(long bookingId) {
        String sql = "SELECT * FROM dbo.payments WHERE booking_id = ?";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            return rs.next() ? mapRow(rs) : null;
        } catch (SQLException e) {
            throw new RuntimeException("findByBookingId loi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public void upsertPending(long bookingId, String method, BigDecimal amount) {
        // Chi reset ve PENDING khi chua SUCCESS (tranh ghi de payment da thanh toan).
        String updateSql =
            "UPDATE dbo.payments " +
            "SET method = ?, amount = ?, [status] = 'PENDING', " +
            "    transaction_ref = NULL, paid_at = NULL " +
            "WHERE booking_id = ? AND [status] <> 'SUCCESS'";
        String insertSql =
            "INSERT INTO dbo.payments (booking_id, method, amount, [status]) " +
            "VALUES (?, ?, ?, 'PENDING')";

        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();

            ps = conn.prepareStatement(updateSql);
            ps.setString(1, method);
            ps.setBigDecimal(2, amount);
            ps.setLong(3, bookingId);
            int rows = ps.executeUpdate();
            ps.close();
            ps = null;

            if (rows == 0) {
                // 0 row = chua co payment HOAC da SUCCESS.
                // Neu chua co -> INSERT; neu da SUCCESS -> khong dung toi.
                if (findByBookingId(bookingId) == null) {
                    ps = conn.prepareStatement(insertSql);
                    ps.setLong(1, bookingId);
                    ps.setString(2, method);
                    ps.setBigDecimal(3, amount);
                    ps.executeUpdate();
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("upsertPending loi: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public int markSuccess(Connection conn, long bookingId, String transactionRef) {
        // Idempotent: chi danh dau SUCCESS khi dang PENDING.
        // KHONG dong connection (thuoc transaction cua Service).
        String sql =
            "UPDATE dbo.payments " +
            "SET [status] = 'SUCCESS', transaction_ref = ?, paid_at = SYSUTCDATETIME() " +
            "WHERE booking_id = ? AND [status] = 'PENDING'";
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, transactionRef);
            ps.setLong(2, bookingId);
            return ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("markSuccess loi: " + e.getMessage(), e);
        } finally {
            // Chi dong PreparedStatement, GIU connection cho transaction.
            if (ps != null) {
                try { ps.close(); } catch (SQLException ignored) {}
            }
        }
    }

    // ── Payment history / monitoring (owner: HungNT) ─────────────────────────

    /** JOIN chung cho PaymentRecord (payments -> bookings -> showtime/movie/branch/customer). */
    private static final String RECORD_SELECT =
            "SELECT p.payment_id, p.booking_id, p.method, p.amount, " +
            "       p.[status] AS pay_status, p.transaction_ref, p.paid_at, " +
            "       b.booking_code, b.[status] AS booking_status, b.created_at, " +
            "       b.customer_username, c.full_name, c.email, " +
            "       m.title AS movie_title, r.branch_id, br.name AS branch_name, " +
            "       st.start_time " +
            "FROM dbo.payments  p " +
            "JOIN dbo.bookings  b  ON b.booking_id  = p.booking_id " +
            "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id " +
            "JOIN dbo.movies    m  ON m.movie_id     = st.movie_id " +
            "JOIN dbo.rooms     r  ON r.room_id       = st.room_id " +
            "JOIN dbo.branches  br ON br.branch_id    = r.branch_id " +
            "JOIN dbo.customers c  ON c.username      = b.customer_username ";

    @Override
    public List<PaymentRecord> search(PaymentSearchCriteria c) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(c, params);
        // Sap xep theo thoi diem giao dich (paid_at; chua co thi created_at) moi nhat truoc.
        String sql = RECORD_SELECT + where +
                " ORDER BY COALESCE(p.paid_at, b.created_at) DESC, p.payment_id DESC " +
                " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            int i = bindParams(ps, params, 1);
            ps.setInt(i++, Math.max(0, c.getOffset()));
            ps.setInt(i, c.getLimit() <= 0 ? 20 : c.getLimit());
            rs = ps.executeQuery();
            List<PaymentRecord> list = new ArrayList<>();
            while (rs.next()) list.add(mapRecord(rs));
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("search payments loi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public int count(PaymentSearchCriteria c) {
        List<Object> params = new ArrayList<>();
        String where = buildWhere(c, params);
        String sql =
            "SELECT COUNT(*) FROM dbo.payments p " +
            "JOIN dbo.bookings  b  ON b.booking_id  = p.booking_id " +
            "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id " +
            "JOIN dbo.rooms     r  ON r.room_id       = st.room_id " +
            "JOIN dbo.customers c  ON c.username      = b.customer_username " + where;
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            bindParams(ps, params, 1);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException e) {
            throw new RuntimeException("count payments loi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public PaymentSummary summarize(Long branchId) {
        // Gom theo (status, method) trong 1 query roi tong hop o Java.
        StringBuilder sql = new StringBuilder(
            "SELECT p.[status] AS pay_status, p.method, COUNT(*) AS cnt, " +
            "       COALESCE(SUM(p.amount),0) AS amt, MIN(b.created_at) AS oldest " +
            "FROM dbo.payments  p " +
            "JOIN dbo.bookings  b  ON b.booking_id  = p.booking_id " +
            "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id " +
            "JOIN dbo.rooms     r  ON r.room_id       = st.room_id ");
        if (branchId != null) sql.append("WHERE r.branch_id = ? ");
        sql.append("GROUP BY p.[status], p.method");

        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            if (branchId != null) ps.setLong(1, branchId);
            rs = ps.executeQuery();

            PaymentSummary s = new PaymentSummary();
            BigDecimal successAmount = BigDecimal.ZERO;
            while (rs.next()) {
                String st = rs.getString("pay_status");
                String method = rs.getString("method");
                int cnt = rs.getInt("cnt");

                if (Payment.STATUS_PENDING.equals(st)) {
                    s.setCountPending(s.getCountPending() + cnt);
                    Timestamp oldest = rs.getTimestamp("oldest");
                    if (oldest != null) {
                        java.time.LocalDateTime t = oldest.toLocalDateTime();
                        if (s.getOldestPendingCreatedAt() == null
                                || t.isBefore(s.getOldestPendingCreatedAt())) {
                            s.setOldestPendingCreatedAt(t);
                        }
                    }
                } else if (Payment.STATUS_SUCCESS.equals(st)) {
                    s.setCountSuccess(s.getCountSuccess() + cnt);
                    successAmount = successAmount.add(rs.getBigDecimal("amt"));
                } else if (Payment.STATUS_FAILED.equals(st)) {
                    s.setCountFailed(s.getCountFailed() + cnt);
                }
                s.getMethodCounts().merge(method, cnt, Integer::sum);
            }
            s.setTotalSuccessAmount(successAmount);
            return s;
        } catch (SQLException e) {
            throw new RuntimeException("summarize payments loi: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /** Build menh de WHERE dong; moi gia tri qua tham so ? (chong SQLi). */
    private String buildWhere(PaymentSearchCriteria c, List<Object> params) {
        StringBuilder w = new StringBuilder(" WHERE 1=1 ");
        if (c.getBranchId() != null) {
            w.append("AND r.branch_id = ? ");
            params.add(c.getBranchId());
        }
        if (c.getCustomerUsername() != null) {
            w.append("AND b.customer_username = ? ");
            params.add(c.getCustomerUsername());
        }
        if (c.getStatus() != null) {
            w.append("AND p.[status] = ? ");
            params.add(c.getStatus());
        }
        if (c.getMethod() != null) {
            w.append("AND p.method = ? ");
            params.add(c.getMethod());
        }
        if (c.getDateFrom() != null) {
            w.append("AND COALESCE(p.paid_at, b.created_at) >= ? ");
            params.add(Timestamp.valueOf(c.getDateFrom().atStartOfDay()));
        }
        if (c.getDateTo() != null) {
            w.append("AND COALESCE(p.paid_at, b.created_at) < ? ");
            params.add(Timestamp.valueOf(c.getDateTo().plusDays(1).atStartOfDay()));
        }
        if (c.getKeyword() != null && !c.getKeyword().isBlank()) {
            w.append("AND (b.booking_code LIKE ? OR p.transaction_ref LIKE ? OR c.full_name LIKE ?) ");
            String like = "%" + c.getKeyword().trim() + "%";
            params.add(like); params.add(like); params.add(like);
        }
        return w.toString();
    }

    /** Gan params (Long/String/Timestamp) tu vi tri startIndex; tra ve vi tri ke tiep. */
    private int bindParams(PreparedStatement ps, List<Object> params, int startIndex) throws SQLException {
        int i = startIndex;
        for (Object p : params) {
            if (p instanceof Long) ps.setLong(i++, (Long) p);
            else if (p instanceof Timestamp) ps.setTimestamp(i++, (Timestamp) p);
            else ps.setString(i++, (String) p);
        }
        return i;
    }

    /** Gio hien thi: DB luu UTC (SYSUTCDATETIME) -> doi sang gio VN cho UI. */
    private static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private LocalDateTime utcToVn(Timestamp ts) {
        if (ts == null) return null;
        return ts.toLocalDateTime().atZone(ZoneOffset.UTC)
                .withZoneSameInstant(VN_ZONE).toLocalDateTime();
    }

    private PaymentRecord mapRecord(ResultSet rs) throws SQLException {
        PaymentRecord pr = new PaymentRecord();
        pr.setPaymentId(rs.getLong("payment_id"));
        pr.setBookingId(rs.getLong("booking_id"));
        pr.setMethod(rs.getString("method"));
        pr.setAmount(rs.getBigDecimal("amount"));
        pr.setStatus(rs.getString("pay_status"));
        pr.setTransactionRef(rs.getString("transaction_ref"));
        pr.setPaidAt(utcToVn(rs.getTimestamp("paid_at")));   // UTC -> gio VN cho UI

        pr.setBookingCode(rs.getString("booking_code"));
        pr.setBookingStatus(rs.getString("booking_status"));
        pr.setCreatedAt(utcToVn(rs.getTimestamp("created_at"))); // UTC -> gio VN cho UI

        pr.setCustomerUsername(rs.getString("customer_username"));
        pr.setCustomerFullName(rs.getString("full_name"));
        pr.setCustomerEmail(rs.getString("email"));

        pr.setMovieTitle(rs.getString("movie_title"));
        pr.setBranchId(rs.getLong("branch_id"));
        pr.setBranchName(rs.getString("branch_name"));
        Timestamp start = rs.getTimestamp("start_time");
        pr.setStartTime(start != null ? start.toLocalDateTime() : null);
        return pr;
    }

    private Payment mapRow(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getLong("payment_id"));
        p.setBookingId(rs.getLong("booking_id"));
        p.setMethod(rs.getString("method"));
        p.setAmount(rs.getBigDecimal("amount"));
        p.setStatus(rs.getString("status"));
        p.setTransactionRef(rs.getString("transaction_ref"));
        Timestamp paid = rs.getTimestamp("paid_at");
        p.setPaidAt(paid != null ? paid.toLocalDateTime() : null);
        return p;
    }
}
