package com.mbcms.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.util.Date;

/**
 * Time helpers for display.
 *
 * DB audit/payment timestamps are stored with SYSUTCDATETIME(), while cinema
 * schedule timestamps are entered as Vietnam local time.
 */
public final class DateTimeUtil {

    public static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private DateTimeUtil() {
    }

    public static LocalDateTime nowVietnam() {
        return LocalDateTime.now(VN_ZONE);
    }

    public static LocalDateTime utcToVietnam(LocalDateTime utc) {
        if (utc == null) {
            return null;
        }
        return utc.atZone(ZoneOffset.UTC)
                .withZoneSameInstant(VN_ZONE)
                .toLocalDateTime();
    }

    public static LocalDateTime vietnamStartOfDayToUtc(LocalDate date) {
        if (date == null) {
            return null;
        }
        return date.atStartOfDay(VN_ZONE)
                .withZoneSameInstant(ZoneOffset.UTC)
                .toLocalDateTime();
    }

    public static Date utcToVietnamDate(LocalDateTime utc) {
        if (utc == null) {
            return null;
        }
        return Date.from(utc.atZone(ZoneOffset.UTC).toInstant());
    }

    public static Date vietnamLocalToDate(LocalDateTime local) {
        if (local == null) {
            return null;
        }
        return Date.from(local.atZone(VN_ZONE).toInstant());
    }
}
