package com.mbcms.service;

import java.math.BigDecimal;
import java.util.List;

import com.mbcms.model.Seat;

/**
 * PricingService - tinh gia ve theo loai ghe (UC39 Set price). Owner: HungNT.
 *
 * Quy tac (chot 13/06/2026, SDS bang seats: "Affects price multiplier"): final
 * price = showtimes.base_price x multiplier theo seats.seat_type STANDARD x1.0
 * ; VIP x1.2
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
}
