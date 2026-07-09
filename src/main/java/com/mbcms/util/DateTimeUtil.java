package com.mbcms.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.Locale;

/**
 * Time helpers for display.
 *
 * DB audit/payment timestamps are stored with SYSUTCDATETIME(), while cinema
 * schedule timestamps are entered as Vietnam local time.
 */
public final class DateTimeUtil {

    public static final ZoneId VN_ZONE = ZoneId.of("Asia/Ho_Chi_Minh");

    private static final DateTimeFormatter AM_PM =
            DateTimeFormatter.ofPattern("h:mm a", Locale.US);

    private DateTimeUtil() {
    }

    public static LocalDateTime nowVietnam() {
        return LocalDateTime.now(VN_ZONE);
    }

    /** Customer-facing showtime label, e.g. {@code 10:00 AM} / {@code 2:30 PM}. */
    public static String formatAmPm(LocalDateTime dateTime) {
        if (dateTime == null) {
            return "";
        }
        return dateTime.format(AM_PM);
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
