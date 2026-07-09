package com.mbcms.util;

import com.mbcms.service.SystemSettingsService;
import com.mbcms.service.impl.SystemSettingsServiceImpl;

/**
 * Static facade so DAO/SQL helpers and PricingService can read Admin settings
 * without constructing a new service each call. Cache lives in the service impl.
 */
public final class SystemSettings {

    private static final SystemSettingsService SERVICE = new SystemSettingsServiceImpl();

    private SystemSettings() {}

    public static SystemSettingsService get() {
        return SERVICE;
    }

    public static int vipSurchargePercent() {
        return SERVICE.getVipSurchargePercent();
    }

    public static int maxSeatsPerBooking() {
        return SERVICE.getMaxSeatsPerBooking();
    }

    public static int pendingHoldMinutes() {
        return SERVICE.getPendingHoldMinutes();
    }

    public static int showtimeGapMinutes() {
        return SERVICE.getShowtimeGapMinutes();
    }

    public static void invalidateCache() {
        SERVICE.invalidateCache();
    }
}
