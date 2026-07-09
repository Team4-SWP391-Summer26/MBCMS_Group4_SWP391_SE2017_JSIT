package com.mbcms.service;

import java.math.BigDecimal;
import java.util.List;

import com.mbcms.model.Seat;

/**
 * PricingService - tinh gia ve theo loai ghe (UC39 Set price). Owner: HungNT.
 *
 * final price = showtimes.base_price x multiplier theo seats.seat_type
 * STANDARD x1.0; VIP x (1 + pricing.vipSurchargePercent/100) via AppConfig.
 */
public interface PricingService {

    /**
     * Gia 1 ghe = basePrice x multiplier cua seatType, lam tron ve don vi VND.
     *
     * @throws IllegalArgumentException neu basePrice null/<=0 hoac seatType
     * khong hop le
     */
    BigDecimal calculateSeatPrice(BigDecimal basePrice, String seatType);

    /**
     * Tong tien ve cua danh sach ghe da chon (chua tinh F&B / promotion).
     *
     * @throws IllegalArgumentException neu list rong hoac co ghe seatType khong
     * hop le
     */
    BigDecimal calculateTotal(BigDecimal basePrice, List<Seat> seats);

    /** VIP surcharge percent from AppConfig (e.g. 30). */
    int getVipSurchargePercent();
}
