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
            + "valid_from, valid_to, max_uses, used_count, active FROM promotions ";

    @Override
    public List<Promotion> findAll() {
        String sql = BASE_SELECT + "ORDER BY promo_id DESC";
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
    public List<Promotion> findByFilters(String search, String type, String status) {
        StringBuilder sql = new StringBuilder(BASE_SELECT + "WHERE 1=1 ");

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
        String sql = BASE_SELECT + "WHERE promo_id = ?";
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
        String sql = BASE_SELECT + "WHERE code = ?";
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
        String sql = "SELECT 1 FROM promotions WHERE code = ?";
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
        String sql = "SELECT 1 FROM promotions WHERE code = ? AND promo_id <> ?";
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
                + "valid_from, valid_to, max_uses, used_count, active) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
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
                + "min_order_amount = ?, valid_from = ?, valid_to = ?, max_uses = ?, active = ? "
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
            ps.setLong(10, p.getPromoId());
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
    public int getTotalPromotionsCount() {
        String sql = "SELECT COUNT(*) FROM promotions";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
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
    public int getActivePromotionsCount() {
        String sql = "SELECT COUNT(*) FROM promotions WHERE active = 1 AND valid_from <= GETDATE() AND valid_to >= GETDATE()";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
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
    public int getUsedThisMonthCount() {
        String sql = "SELECT COUNT(*) FROM bookings "
                + "WHERE promo_id IS NOT NULL "
                + "AND status IN ('CONFIRMED','USED','PENDING') "
                + "AND created_at >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
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
    public BigDecimal getRevenueImpactThisMonth() {
        String sql = "SELECT SUM(discount_amount) FROM bookings "
                + "WHERE promo_id IS NOT NULL "
                + "AND status IN ('CONFIRMED','USED') "
                + "AND created_at >= DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
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
    public boolean delete(long promoId) {
        String sql = "DELETE FROM promotions WHERE promo_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, promoId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            // Check for SQL Server foreign key constraint violation (Error Code 547)
            if (e.getErrorCode() == 547) {
                throw new RuntimeException("IN_USE");
            }
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
        p.setValidFrom(rs.getTimestamp("valid_from").toLocalDateTime());
        p.setValidTo(rs.getTimestamp("valid_to").toLocalDateTime());

        int maxUsesVal = rs.getInt("max_uses");
        if (rs.wasNull()) {
            p.setMaxUses(null);
        } else {
            p.setMaxUses(maxUsesVal);
        }

        p.setUsedCount(rs.getInt("used_count"));
        p.setActive(rs.getBoolean("active"));
        return p;
    }
}
