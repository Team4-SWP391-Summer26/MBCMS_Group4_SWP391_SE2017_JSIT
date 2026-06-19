package com.mbcms.dao;

import com.mbcms.model.Promotion;
import java.math.BigDecimal;
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
}
