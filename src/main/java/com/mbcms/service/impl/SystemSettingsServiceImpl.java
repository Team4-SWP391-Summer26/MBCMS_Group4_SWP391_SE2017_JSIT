package com.mbcms.service.impl;

import com.mbcms.dao.SystemSettingDAO;
import com.mbcms.dao.impl.SystemSettingDAOImpl;
import com.mbcms.service.SystemSettingsService;
import com.mbcms.util.AppConfig;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

public class SystemSettingsServiceImpl implements SystemSettingsService {

    private static final long CACHE_TTL_MS = 30_000L;

    private final SystemSettingDAO dao;

    private final AtomicReference<CacheEntry> cache = new AtomicReference<>();

    public SystemSettingsServiceImpl() {
        this(new SystemSettingDAOImpl());
    }

    public SystemSettingsServiceImpl(SystemSettingDAO dao) {
        this.dao = dao;
    }

    @Override
    public int getVipSurchargePercent() {
        return getInt(KEY_VIP_SURCHARGE_PERCENT, AppConfig.getVipSurchargePercentFallback(), 0, 200);
    }

    @Override
    public int getMaxSeatsPerBooking() {
        return getInt(KEY_MAX_SEATS_PER_BOOKING, 8, 1, 20);
    }

    @Override
    public int getPendingHoldMinutes() {
        return getInt(KEY_PENDING_HOLD_MINUTES, 10, 1, 60);
    }

    @Override
    public int getShowtimeGapMinutes() {
        return getInt(KEY_SHOWTIME_GAP_MINUTES, 30, 0, 120);
    }

    @Override
    public Map<String, Integer> getAllIntSettings() {
        Map<String, Integer> map = new LinkedHashMap<>();
        map.put(KEY_VIP_SURCHARGE_PERCENT, getVipSurchargePercent());
        map.put(KEY_MAX_SEATS_PER_BOOKING, getMaxSeatsPerBooking());
        map.put(KEY_PENDING_HOLD_MINUTES, getPendingHoldMinutes());
        map.put(KEY_SHOWTIME_GAP_MINUTES, getShowtimeGapMinutes());
        return map;
    }

    @Override
    public void updateSettings(int vipPercent, int maxSeats, int pendingMinutes, int gapMinutes) {
        requireRange("VIP surcharge percent", vipPercent, 0, 200);
        requireRange("Max seats per booking", maxSeats, 1, 20);
        requireRange("Pending hold minutes", pendingMinutes, 1, 60);
        requireRange("Showtime gap minutes", gapMinutes, 0, 120);

        Map<String, String> values = new LinkedHashMap<>();
        values.put(KEY_VIP_SURCHARGE_PERCENT, String.valueOf(vipPercent));
        values.put(KEY_MAX_SEATS_PER_BOOKING, String.valueOf(maxSeats));
        values.put(KEY_PENDING_HOLD_MINUTES, String.valueOf(pendingMinutes));
        values.put(KEY_SHOWTIME_GAP_MINUTES, String.valueOf(gapMinutes));
        dao.upsertAll(values);
        invalidateCache();
    }

    @Override
    public void invalidateCache() {
        cache.set(null);
    }

    private int getInt(String key, int fallback, int min, int max) {
        Map<String, Integer> snap = snapshot();
        Integer v = snap.get(key);
        if (v == null) {
            return fallback;
        }
        if (v < min || v > max) {
            return fallback;
        }
        return v;
    }

    private Map<String, Integer> snapshot() {
        long now = System.currentTimeMillis();
        CacheEntry cur = cache.get();
        if (cur != null && now - cur.loadedAtMs < CACHE_TTL_MS) {
            return cur.values;
        }
        Map<String, Integer> loaded = loadFromDb();
        cache.set(new CacheEntry(loaded, now));
        return loaded;
    }

    private Map<String, Integer> loadFromDb() {
        Map<String, Integer> map = new LinkedHashMap<>();
        try {
            putParsed(map, KEY_VIP_SURCHARGE_PERCENT, dao.findValue(KEY_VIP_SURCHARGE_PERCENT));
            putParsed(map, KEY_MAX_SEATS_PER_BOOKING, dao.findValue(KEY_MAX_SEATS_PER_BOOKING));
            putParsed(map, KEY_PENDING_HOLD_MINUTES, dao.findValue(KEY_PENDING_HOLD_MINUTES));
            putParsed(map, KEY_SHOWTIME_GAP_MINUTES, dao.findValue(KEY_SHOWTIME_GAP_MINUTES));
        } catch (RuntimeException e) {
            // Table missing before re-seed — fall back to AppConfig / defaults via getInt.
            System.err.println("[SystemSettings] load failed, using fallbacks: " + e.getMessage());
        }
        return map;
    }

    private static void putParsed(Map<String, Integer> map, String key, String raw) {
        if (raw == null || raw.isBlank()) {
            return;
        }
        try {
            map.put(key, Integer.parseInt(raw.trim()));
        } catch (NumberFormatException ignored) {
            // skip invalid row
        }
    }

    private static void requireRange(String label, int value, int min, int max) {
        if (value < min || value > max) {
            throw new IllegalArgumentException(label + " must be between " + min + " and " + max + ".");
        }
    }

    private static final class CacheEntry {
        final Map<String, Integer> values;
        final long loadedAtMs;

        CacheEntry(Map<String, Integer> values, long loadedAtMs) {
            this.values = values;
            this.loadedAtMs = loadedAtMs;
        }
    }
}
