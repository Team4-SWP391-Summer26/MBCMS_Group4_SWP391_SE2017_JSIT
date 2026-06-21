package com.mbcms.service.impl;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

import com.mbcms.model.Seat;
import com.mbcms.service.PricingService;

/**
 * Tinh gia ve theo loai ghe. Pure function - khong cham DB, de unit test.
 * Multiplier la hang so trong code (nhom chot 13/06/2026); doi gia tri tai day
 * neu nhom quyet dinh lai.
 */
public class PricingServiceImpl implements PricingService {

    private static final BigDecimal STANDARD_MULTIPLIER = new BigDecimal("1.0");
    private static final BigDecimal VIP_MULTIPLIER = new BigDecimal("1.2");

    @Override
    public BigDecimal calculateSeatPrice(BigDecimal basePrice, String seatType) {
        if (basePrice == null || basePrice.signum() <= 0) {
            throw new IllegalArgumentException("basePrice must be positive");
        }
        // Gia VND khong co phan le -> lam tron ve don vi dong.
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

    private BigDecimal multiplierOf(String seatType) {
        if (Seat.TYPE_STANDARD.equals(seatType)) {
            return STANDARD_MULTIPLIER;
        }
        if (Seat.TYPE_VIP.equals(seatType)) {
            return VIP_MULTIPLIER;
        }
        // Fail fast: seatType la du lieu tu DB (CHECK constraint), gap gia tri
        // la nghia la data/schema lech version -> bao loi ngay thay vi tinh sai gia.
        throw new IllegalArgumentException("Unknown seat type: " + seatType);
    }
}
