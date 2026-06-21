package com.mbcms.dao.impl;

import com.mbcms.dao.PaymentDAO;
import com.mbcms.model.Payment;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

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
