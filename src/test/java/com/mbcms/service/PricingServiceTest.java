package com.mbcms.service;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import java.math.BigDecimal;
import java.util.Collections;
import java.util.List;

import org.junit.jupiter.api.Test;

import com.mbcms.model.Seat;
import com.mbcms.service.impl.PricingServiceImpl;

/**
 * Unit test cho PricingService (UC39 Set price). Quy tac: STANDARD x1.0, VIP
 * x1.2, lam tron ve don vi VND.
 */
class PricingServiceTest {

    private final PricingService pricing = new PricingServiceImpl();

    @Test
    void standardSeatKeepsBasePrice() {
        assertEquals(new BigDecimal("100000"),
                pricing.calculateSeatPrice(new BigDecimal("100000"), Seat.TYPE_STANDARD));
    }

    @Test
    void vipSeatCosts20PercentMore() {
        assertEquals(new BigDecimal("120000"),
                pricing.calculateSeatPrice(new BigDecimal("100000"), Seat.TYPE_VIP));
    }

    @Test
    void vipPriceIsRoundedToWholeVnd() {
        // 99999 x 1.2 = 119998.8 -> lam tron HALF_UP = 119999
        assertEquals(new BigDecimal("119999"),
                pricing.calculateSeatPrice(new BigDecimal("99999"), Seat.TYPE_VIP));
    }

    @Test
    void totalSumsMixedSeatTypes() {
        // 2 STANDARD + 1 VIP voi base 100k = 100k + 100k + 120k = 320k
        List<Seat> seats = List.of(
                seatOf(Seat.TYPE_STANDARD),
                seatOf(Seat.TYPE_STANDARD),
                seatOf(Seat.TYPE_VIP));
        assertEquals(new BigDecimal("320000"),
                pricing.calculateTotal(new BigDecimal("100000"), seats));
    }

    @Test
    void unknownSeatTypeIsRejected() {
        assertThrows(IllegalArgumentException.class,
                () -> pricing.calculateSeatPrice(new BigDecimal("100000"), "COUPLE"));
    }

    @Test
    void nullSeatTypeIsRejected() {
        assertThrows(IllegalArgumentException.class,
                () -> pricing.calculateSeatPrice(new BigDecimal("100000"), null));
    }

    @Test
    void nonPositiveBasePriceIsRejected() {
        assertThrows(IllegalArgumentException.class,
                () -> pricing.calculateSeatPrice(BigDecimal.ZERO, Seat.TYPE_STANDARD));
        assertThrows(IllegalArgumentException.class,
                () -> pricing.calculateSeatPrice(null, Seat.TYPE_STANDARD));
    }

    @Test
    void emptySeatListIsRejected() {
        assertThrows(IllegalArgumentException.class,
                () -> pricing.calculateTotal(new BigDecimal("100000"), Collections.emptyList()));
    }

    private static Seat seatOf(String type) {
        Seat s = new Seat();
        s.setSeatType(type);
        return s;
    }
}
