package com.mbcms.ws;

/**
 * DTO trao đổi qua WebSocket. Serialize/deserialize thủ công bằng JSON string
 * đơn giản (không cần Jackson trong WebSocket endpoint).
 *
 * Format JSON: { "action" : "SELECT" | "DESELECT" | "HARD_LOCK" |
 * "HARD_RELEASE", "seatId" : 123, "showtimeId" : 456, "username" : "userA" }
 *
 * SELECT = user click chọn ghế (soft lock) DESELECT = user bỏ chọn ghế (release
 * soft lock) HARD_LOCK = booking PENDING đã tạo (từ server broadcast)
 * HARD_RELEASE= booking hết hạn / cancelled (từ server broadcast)
 */
public class SeatSelectionMessage {

    public static final String SELECT = "SELECT";
    public static final String DESELECT = "DESELECT";
    public static final String HARD_LOCK = "HARD_LOCK";
    public static final String HARD_RELEASE = "HARD_RELEASE";
    public static final String INIT = "INIT";  // server gửi trạng thái ban đầu

    private String action;
    private long seatId;
    private long showtimeId;
    private String username;

    public SeatSelectionMessage() {
    }

    public SeatSelectionMessage(String action, long seatId, long showtimeId, String username) {
        this.action = action;
        this.seatId = seatId;
        this.showtimeId = showtimeId;
        this.username = username;
    }

    // ── Serialize thủ công ────────────────────────────────────────────────
    public String toJson() {
        return String.format(
                "{\"action\":\"%s\",\"seatId\":%d,\"showtimeId\":%d,\"username\":\"%s\"}",
                action, seatId, showtimeId, username != null ? username : ""
        );
    }

    public static SeatSelectionMessage fromJson(String json) {
        SeatSelectionMessage msg = new SeatSelectionMessage();
        msg.action = extractString(json, "action");
        msg.seatId = extractLong(json, "seatId");
        msg.showtimeId = extractLong(json, "showtimeId");
        msg.username = extractString(json, "username");
        return msg;
    }

    private static String extractString(String json, String key) {
        String pattern = "\"" + key + "\":\"";
        int start = json.indexOf(pattern);
        if (start < 0) {
            return "";
        }
        start += pattern.length();
        int end = json.indexOf("\"", start);
        return end < 0 ? "" : json.substring(start, end);
    }

    private static long extractLong(String json, String key) {
        String pattern = "\"" + key + "\":";
        int start = json.indexOf(pattern);
        if (start < 0) {
            return 0;
        }
        start += pattern.length();
        int end = start;
        while (end < json.length() && (Character.isDigit(json.charAt(end)))) {
            end++;
        }
        try {
            return Long.parseLong(json.substring(start, end));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    public String getAction() {
        return action;
    }

    public long getSeatId() {
        return seatId;
    }

    public long getShowtimeId() {
        return showtimeId;
    }

    public String getUsername() {
        return username;
    }
}
