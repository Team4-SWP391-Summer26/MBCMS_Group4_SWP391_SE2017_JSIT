package com.mbcms.dao.impl;

import com.mbcms.dao.PromotionDAO;
import com.mbcms.model.Promotion;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class PromotionDAOImpl extends BaseDAO implements PromotionDAO {

    private static final String BASE_SELECT
            = "SELECT promo_id, code, name, discount_type, discount_value, min_order_amount, "
            + "valid_from, valid_to, max_uses, used_count, active, is_deleted, branch_id FROM promotions ";
    private static final String VN_MONTH_UTC_FILTER =
            "AND b.created_at >= DATEADD(HOUR, -7, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)) "
            + "AND b.created_at < DATEADD(HOUR, -7, DATEADD(month, DATEDIFF(month, 0, DATEADD(month, 1, GETDATE())), 0)) ";

    @Override
    public List<Promotion> findAll() {
        String sql = BASE_SELECT + "WHERE is_deleted = 0 ORDER BY promo_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Promotion> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.findAll: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public List<Promotion> findByFilters(String search, String type, String status, Long branchId) {
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE is_deleted = 0 ");

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (code LIKE ? OR name LIKE ?) ");
        }
        if (type != null && !type.trim().isEmpty()) {
            sql.append("AND discount_type = ? ");
        }
        if (status != null && !status.trim().isEmpty()) {
            switch (status.trim()) {
                case "Active":
                    sql.append("AND active = 1 AND valid_from <= GETDATE() AND valid_to >= GETDATE() ");
                    break;
                case "Expired":
                    sql.append("AND active = 1 AND valid_to < GETDATE() ");
                    break;
                case "Inactive":
                    sql.append("AND (active = 0 OR (active = 1 AND valid_from > GETDATE())) ");
                    break;
            }
        }
        if (branchId != null) {
            if (branchId == -1L) {
                sql.append("AND branch_id IS NULL ");
            } else {
                sql.append("AND branch_id = ? ");
            }
        }

        sql.append("ORDER BY promo_id DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Promotion> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchPattern = "%" + search.trim() + "%";
                ps.setString(idx++, searchPattern);
                ps.setString(idx++, searchPattern);
            }
            if (type != null && !type.trim().isEmpty()) {
                ps.setString(idx++, type.trim());
            }
            if (branchId != null && branchId != -1L) {
                ps.setLong(idx++, branchId);
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.findByFilters: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return list;
    }

    @Override
    public Promotion findById(long promoId) {
        String sql = BASE_SELECT + "WHERE promo_id = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, promoId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.findById: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return null;
    }

    @Override
    public Promotion findByCode(String code) {
        if (code == null) {
            return null;
        }
        String sql = BASE_SELECT + "WHERE code = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, code.trim().toUpperCase());
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapRow(rs);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.findByCode: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return null;
    }

    @Override
    public boolean existsByCode(String code) {
        if (code == null) {
            return false;
        }
        String sql = "SELECT 1 FROM promotions WHERE code = ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, code.trim().toUpperCase());
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.existsByCode: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean existsByCodeExcludeId(String code, long promoId) {
        if (code == null) {
            return false;
        }
        String sql = "SELECT 1 FROM promotions WHERE code = ? AND promo_id <> ? AND is_deleted = 0";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, code.trim().toUpperCase());
            ps.setLong(2, promoId);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.existsByCodeExcludeId: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean insert(Promotion p) {
        String sql = "INSERT INTO promotions (code, name, discount_type, discount_value, min_order_amount, "
                + "valid_from, valid_to, max_uses, used_count, active, branch_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, p.getCode().trim().toUpperCase());
            ps.setString(2, p.getName().trim());
            ps.setString(3, p.getDiscountType());
            ps.setBigDecimal(4, p.getDiscountValue());
            ps.setBigDecimal(5, p.getMinOrderAmount() != null ? p.getMinOrderAmount() : BigDecimal.ZERO);
            ps.setTimestamp(6, Timestamp.valueOf(p.getValidFrom()));
            ps.setTimestamp(7, Timestamp.valueOf(p.getValidTo()));
            if (p.getMaxUses() != null) {
                ps.setInt(8, p.getMaxUses());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.setInt(9, p.getUsedCount());
            ps.setBoolean(10, p.isActive());
            if (p.getBranchId() != null) {
                ps.setLong(11, p.getBranchId());
            } else {
                ps.setNull(11, java.sql.Types.BIGINT);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.insert: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean update(Promotion p) {
        String sql = "UPDATE promotions SET code = ?, name = ?, discount_type = ?, discount_value = ?, "
                + "min_order_amount = ?, valid_from = ?, valid_to = ?, max_uses = ?, active = ?, branch_id = ? "
                + "WHERE promo_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, p.getCode().trim().toUpperCase());
            ps.setString(2, p.getName().trim());
            ps.setString(3, p.getDiscountType());
            ps.setBigDecimal(4, p.getDiscountValue());
            ps.setBigDecimal(5, p.getMinOrderAmount() != null ? p.getMinOrderAmount() : BigDecimal.ZERO);
            ps.setTimestamp(6, Timestamp.valueOf(p.getValidFrom()));
            ps.setTimestamp(7, Timestamp.valueOf(p.getValidTo()));
            if (p.getMaxUses() != null) {
                ps.setInt(8, p.getMaxUses());
            } else {
                ps.setNull(8, java.sql.Types.INTEGER);
            }
            ps.setBoolean(9, p.isActive());
            if (p.getBranchId() != null) {
                ps.setLong(10, p.getBranchId());
            } else {
                ps.setNull(10, java.sql.Types.BIGINT);
            }
            ps.setLong(11, p.getPromoId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.update: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean toggleActive(long promoId) {
        String sql = "UPDATE promotions SET active = active ^ 1 WHERE promo_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, promoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.toggleActive: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public int getTotalPromotionsCount(Long branchId) {
        String sql = "SELECT COUNT(*) FROM promotions WHERE is_deleted = 0";
        if (branchId != null) {
            sql += " AND branch_id = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            if (branchId != null) {
                ps.setLong(1, branchId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.getTotalPromotionsCount: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return 0;
    }

    @Override
    public int getActivePromotionsCount(Long branchId) {
        String sql = "SELECT COUNT(*) FROM promotions WHERE active = 1 AND is_deleted = 0 AND valid_from <= GETDATE() AND valid_to >= GETDATE()";
        if (branchId != null) {
            sql += " AND branch_id = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            if (branchId != null) {
                ps.setLong(1, branchId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.getActivePromotionsCount: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return 0;
    }

    @Override
    public int getUsedThisMonthCount(Long branchId) {
        String sql = "SELECT COUNT(*) FROM bookings b ";
        if (branchId != null) {
            sql += "JOIN showtimes st ON b.showtime_id = st.showtime_id "
                + "JOIN rooms r ON st.room_id = r.room_id ";
        }
        sql += "WHERE b.promo_id IS NOT NULL "
                + "AND b.status IN ('CONFIRMED','USED') "
                + VN_MONTH_UTC_FILTER;
        if (branchId != null) {
            sql += " AND r.branch_id = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            if (branchId != null) {
                ps.setLong(1, branchId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.getUsedThisMonthCount: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return 0;
    }

    @Override
    public BigDecimal getRevenueImpactThisMonth(Long branchId) {
        String sql = "SELECT SUM(b.discount_amount) FROM bookings b ";
        if (branchId != null) {
            sql += "JOIN showtimes st ON b.showtime_id = st.showtime_id "
                + "JOIN rooms r ON st.room_id = r.room_id ";
        }
        sql += "WHERE b.promo_id IS NOT NULL "
                + "AND b.status IN ('CONFIRMED','USED') "
                + VN_MONTH_UTC_FILTER;
        if (branchId != null) {
            sql += " AND r.branch_id = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            if (branchId != null) {
                ps.setLong(1, branchId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal val = rs.getBigDecimal(1);
                return val != null ? val : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.getRevenueImpactThisMonth: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
        return BigDecimal.ZERO;
    }
    
        @Override
    public boolean incrementUsedCount(long promoId) {
        String sql = "UPDATE dbo.promotions SET used_count = used_count + 1 "
                + "WHERE promo_id = ? AND (max_uses IS NULL OR used_count < max_uses)";
        
        Connection conn = null; 
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, promoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("incrementUsedCount lỗi: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public int incrementUsedCount(Connection conn, long promoId) throws SQLException {
        // Dung conn truyen vao tu PaymentService de atomic voi confirm + payment.
        // KHONG commit/close conn.
        String sql = "UPDATE dbo.promotions SET used_count = used_count + 1 "
                + "WHERE promo_id = ? AND (max_uses IS NULL OR used_count < max_uses)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, promoId);
            return ps.executeUpdate();
        }
    }

    @Override
    public boolean delete(long promoId) {
        String sql = "UPDATE promotions SET is_deleted = 1, active = 0 WHERE promo_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, promoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Loi in PromotionDAOImpl.delete: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    private Promotion mapRow(ResultSet rs) throws SQLException {
        Promotion p = new Promotion();
        p.setPromoId(rs.getLong("promo_id"));
        p.setCode(rs.getString("code"));
        p.setName(rs.getString("name"));
        p.setDiscountType(rs.getString("discount_type"));
        p.setDiscountValue(rs.getBigDecimal("discount_value"));
        p.setMinOrderAmount(rs.getBigDecimal("min_order_amount"));
        Timestamp validFromTs = rs.getTimestamp("valid_from");
        Timestamp validToTs = rs.getTimestamp("valid_to");
        p.setValidFrom(validFromTs != null ? validFromTs.toLocalDateTime() : null);
        p.setValidTo(validToTs != null ? validToTs.toLocalDateTime() : null);

        int maxUsesVal = rs.getInt("max_uses");
        if (rs.wasNull()) {
            p.setMaxUses(null);
        } else {
            p.setMaxUses(maxUsesVal);
        }

        p.setUsedCount(rs.getInt("used_count"));
        p.setActive(rs.getBoolean("active"));
        p.setDeleted(rs.getBoolean("is_deleted"));
        
        long branchIdVal = rs.getLong("branch_id");
        if (rs.wasNull()) {
            p.setBranchId(null);
        } else {
            p.setBranchId(branchIdVal);
        }
        return p;
    }
}
