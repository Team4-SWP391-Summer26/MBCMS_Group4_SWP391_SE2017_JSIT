package com.mbcms.dao;

import com.mbcms.model.Promotion;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

public interface PromotionDAO {

    List<Promotion> findAll();

    List<Promotion> findByFilters(String search, String type, String status);

    Promotion findById(long promoId);

    Promotion findByCode(String code);

    boolean existsByCode(String code);

    boolean existsByCodeExcludeId(String code, long promoId);

    boolean insert(Promotion promotion);

    boolean update(Promotion promotion);

    boolean toggleActive(long promoId);

    int getTotalPromotionsCount();

    int getActivePromotionsCount();

    int getUsedThisMonthCount();

    BigDecimal getRevenueImpactThisMonth();

    boolean delete(long promoId);
    boolean incrementUsedCount(long promoId);

    /** Connection-aware: tang used_count trong transaction co san (vd payment confirm). */
    int incrementUsedCount(Connection conn, long promoId) throws SQLException;
}
