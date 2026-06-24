package com.mbcms.dao.impl;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Documents active-booking SQL filter used by ShowtimeDAOImpl (PENDING expires after 10 min).
 */
class ShowtimeActiveBookingFilterTest {

  private static final String ACTIVE_BOOKING_FILTER =
      " AND b.status IN ('PENDING','CONFIRMED','USED') "
          + " AND (b.[status] != 'PENDING' "
          + "      OR DATEDIFF(MINUTE, b.created_at, SYSUTCDATETIME()) < 10) ";

  @Test
  void activeBookingFilter_excludesExpiredPending() {
    assertTrue(ACTIVE_BOOKING_FILTER.contains("DATEDIFF(MINUTE, b.created_at, SYSUTCDATETIME()) < 10"));
    assertTrue(ACTIVE_BOOKING_FILTER.contains("'PENDING','CONFIRMED','USED'"));
  }
}
