package com.mbcms.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import com.mbcms.model.Seat;
import com.mbcms.service.PricingService;
import com.mbcms.util.AppConfig;

/**
 * Tinh gia ve theo loai ghe. Pure function - khong cham DB, de unit test.
 * VIP multiplier doc tu SystemSettings (Admin /admin/settings), fallback AppConfig.
 */
public class PricingServiceImpl implements PricingService {

    private static final BigDecimal STANDARD_MULTIPLIER = BigDecimal.ONE;

    @Override
    public BigDecimal calculateSeatPrice(BigDecimal basePrice, String seatType) {
        if (basePrice == null || basePrice.signum() <= 0) {
            throw new IllegalArgumentException("basePrice must be positive");
        }
        return basePrice.multiply(multiplierOf(seatType)).setScale(0, RoundingMode.HALF_UP);
    }

    @Override
    public BigDecimal calculateTotal(BigDecimal basePrice, List<Seat> seats) {
        if (seats == null || seats.isEmpty()) {
            throw new IllegalArgumentException("seats must not be empty");
        }
        BigDecimal total = BigDecimal.ZERO;
        for (Seat seat : seats) {
            total = total.add(calculateSeatPrice(basePrice, seat.getSeatType()));
        }
        return total;
    }

    @Override
    public int getVipSurchargePercent() {
        return com.mbcms.util.SystemSettings.vipSurchargePercent();
    }

    private BigDecimal multiplierOf(String seatType) {
        if (Seat.TYPE_STANDARD.equals(seatType)) {
            return STANDARD_MULTIPLIER;
        }
        if (Seat.TYPE_VIP.equals(seatType)) {
            return AppConfig.getVipMultiplier();
        }
        throw new IllegalArgumentException("Unknown seat type: " + seatType);
    }
}
