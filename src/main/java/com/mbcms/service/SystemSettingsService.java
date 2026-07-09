package com.mbcms.service;

import java.util.Map;

/**
 * Admin-configurable business rules (VIP %, max seats, PENDING hold, showtime gap).
 * Values live in dbo.system_settings; cached briefly for hot paths.
 */
public interface SystemSettingsService {

    String KEY_VIP_SURCHARGE_PERCENT = "vip_surcharge_percent";
    String KEY_MAX_SEATS_PER_BOOKING = "max_seats_per_booking";
    String KEY_PENDING_HOLD_MINUTES = "pending_hold_minutes";
    String KEY_SHOWTIME_GAP_MINUTES = "showtime_gap_minutes";

    int getVipSurchargePercent();

    int getMaxSeatsPerBooking();

    int getPendingHoldMinutes();

    int getShowtimeGapMinutes();

    /** Snapshot for Admin Settings form. */
    Map<String, Integer> getAllIntSettings();

    /**
     * Validate and persist. Keys must be the four known settings.
     * Invalid values throw IllegalArgumentException with English message for UI.
     */
    void updateSettings(int vipPercent, int maxSeats, int pendingMinutes, int gapMinutes);

    /** Drop in-memory cache after Admin save (or for tests). */
    void invalidateCache();
}
