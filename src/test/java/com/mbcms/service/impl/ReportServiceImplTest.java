package com.mbcms.service.impl;

import com.mbcms.dao.ReportDAO;
import com.mbcms.model.report.*;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ReportServiceImplTest {

    @Mock private ReportDAO reportDao;

    private ReportServiceImpl service;

    @BeforeEach
    void setUp() {
        service = new ReportServiceImpl(reportDao);
    }

    // ── systemRevenue: must reject branchScope != null ────────────────────────
    @Test
    @DisplayName("systemRevenue() with non-null branchScope should throw SecurityException")
    void systemRevenue_rejectsNonNullBranchScope() {
        assertThrows(SecurityException.class,
                () -> service.systemRevenue(1L, LocalDate.now().minusDays(7), LocalDate.now()));
    }

    @Test
    @DisplayName("systemRevenue() with null branchScope should succeed and aggregate DAO data")
    void systemRevenue_acceptsNullBranchScope() {
        LocalDate from = LocalDate.now().minusDays(7);
        LocalDate to = LocalDate.now();

        List<BranchRevenueRow> rows = List.of(
            new BranchRevenueRow(1L, "Branch A", new BigDecimal("1000"), new BigDecimal("200"), new BigDecimal("1200"), 10),
            new BranchRevenueRow(2L, "Branch B", new BigDecimal("500"),  new BigDecimal("100"), new BigDecimal("600"),  5)
        );
        when(reportDao.getBranchRevenue(isNull(), eq(from), eq(to))).thenReturn(rows);

        RevenueSummary result = service.systemRevenue(null, from, to);

        assertNotNull(result);
        assertEquals(new BigDecimal("1800"), result.getTotalRevenue());
        assertEquals(new BigDecimal("1500"), result.getTicketRevenue());
        assertEquals(new BigDecimal("300"),  result.getFnbRevenue());
        assertEquals(15, result.getTotalBookings());
        assertEquals(2, result.getByBranch().size());
    }

    // ── Date validation ────────────────────────────────────────────────────────
    @Test
    @DisplayName("ticketSales() with from > to should throw IllegalArgumentException")
    void ticketSales_rejectsFromAfterTo() {
        LocalDate from = LocalDate.now();
        LocalDate to   = LocalDate.now().minusDays(1);
        assertThrows(IllegalArgumentException.class,
                () -> service.ticketSales(null, from, to, null));
    }

    @Test
    @DisplayName("ticketSales() with range > 1 year should throw IllegalArgumentException")
    void ticketSales_rejectsRangeExceedingOneYear() {
        LocalDate from = LocalDate.now().minusDays(400);
        LocalDate to   = LocalDate.now();
        assertThrows(IllegalArgumentException.class,
                () -> service.ticketSales(null, from, to, null));
    }

    // ── peakBookingTimes: must fill 24 hours even when DAO returns partial data ─
    @Test
    @DisplayName("peakBookingTimes() always returns exactly 24 entries (hours 0–23)")
    void peakBookingTimes_alwaysReturns24Rows() {
        LocalDate from = LocalDate.now().minusDays(7);
        LocalDate to = LocalDate.now();

        // DAO only returns hours 8, 9, 19 (typical cinema booking hours)
        List<PeakBookingRow> partialData = List.of(
            new PeakBookingRow(8, 12),
            new PeakBookingRow(9, 20),
            new PeakBookingRow(19, 35)
        );
        when(reportDao.getPeakBookingTimes(isNull(), eq(from), eq(to))).thenReturn(partialData);

        List<PeakBookingRow> result = service.peakBookingTimes(null, from, to);

        assertEquals(24, result.size(), "Must return exactly 24 rows (one per hour)");
        // Verify known hours match
        assertEquals(12, result.get(8).getBookingsCount());
        assertEquals(20, result.get(9).getBookingsCount());
        assertEquals(35, result.get(19).getBookingsCount());
        // Hours with no data must be 0
        assertEquals(0, result.get(0).getBookingsCount());
        assertEquals(0, result.get(23).getBookingsCount());
    }

    // ── Default date range ─────────────────────────────────────────────────────
    @Test
    @DisplayName("fnbSales() with null dates should default to last 30 days")
    void fnbSales_defaultsToLast30Days() {
        LocalDate expectedTo   = LocalDate.now();
        LocalDate expectedFrom = expectedTo.minusDays(29);

        when(reportDao.getFnbSales(isNull(), eq(expectedFrom), eq(expectedTo)))
            .thenReturn(List.of());

        List<FnbSalesRow> result = service.fnbSales(null, null, null);
        assertNotNull(result);
        // Verify the DAO was called with the expected default range
        verify(reportDao).getFnbSales(isNull(), eq(expectedFrom), eq(expectedTo));
    }

    // ── popularMovies: default limit ───────────────────────────────────────────
    @Test
    @DisplayName("popularMovies() with limit <= 0 should default to 10 in DAO call")
    void popularMovies_passesLimitToDAO() {
        LocalDate from = LocalDate.now().minusDays(7);
        LocalDate to = LocalDate.now();

        when(reportDao.getPopularMovies(isNull(), eq(from), eq(to), eq(0)))
            .thenReturn(List.of());

        service.popularMovies(null, from, to, 0);
        verify(reportDao).getPopularMovies(isNull(), eq(from), eq(to), eq(0));
    }
}
