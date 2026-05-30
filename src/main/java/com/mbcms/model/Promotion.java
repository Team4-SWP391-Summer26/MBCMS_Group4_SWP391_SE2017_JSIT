package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Promotion - map bang `promotions`.
 * discountType: PERCENT (vd 10 = 10%) | FIXED_AMOUNT (vd 50000 = 50,000 VND).
 */
public class Promotion {

    public static final String TYPE_PERCENT = "PERCENT";
    public static final String TYPE_FIXED_AMOUNT = "FIXED_AMOUNT";

    private long promoId;
    private String code;
    private String name;
    private String discountType;
    private BigDecimal discountValue;
    private BigDecimal minOrderAmount;
    private LocalDateTime validFrom;
    private LocalDateTime validTo;
    private Integer maxUses;
    private int usedCount;
    private boolean active = true;

    public Promotion() {}

    public long getPromoId() { return promoId; }
    public void setPromoId(long promoId) { this.promoId = promoId; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getDiscountType() { return discountType; }
    public void setDiscountType(String discountType) { this.discountType = discountType; }

    public BigDecimal getDiscountValue() { return discountValue; }
    public void setDiscountValue(BigDecimal discountValue) { this.discountValue = discountValue; }

    public BigDecimal getMinOrderAmount() { return minOrderAmount; }
    public void setMinOrderAmount(BigDecimal minOrderAmount) { this.minOrderAmount = minOrderAmount; }

    public LocalDateTime getValidFrom() { return validFrom; }
    public void setValidFrom(LocalDateTime validFrom) { this.validFrom = validFrom; }

    public LocalDateTime getValidTo() { return validTo; }
    public void setValidTo(LocalDateTime validTo) { this.validTo = validTo; }

    public Integer getMaxUses() { return maxUses; }
    public void setMaxUses(Integer maxUses) { this.maxUses = maxUses; }

    public int getUsedCount() { return usedCount; }
    public void setUsedCount(int usedCount) { this.usedCount = usedCount; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
