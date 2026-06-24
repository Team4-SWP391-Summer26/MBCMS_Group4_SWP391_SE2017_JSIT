package com.mbcms.util;

import com.mbcms.model.Room;
import com.mbcms.model.Seat;

import java.util.ArrayList;
import java.util.List;

/** Shared seat grid rules for addRoom, updateRoom capacity, and regenerate layout. */
public final class RoomLayoutUtil {

    public static final int MAX_ROWS = 26;
    public static final int DEFAULT_COLS = 10;
    public static final int MAX_COLS = 30;
    public static final int MAX_CAPACITY = MAX_ROWS * DEFAULT_COLS;

    private RoomLayoutUtil() {
    }

    public static void validateCapacity(int capacity) {
        if (capacity <= 0) {
            throw new IllegalArgumentException("Sức chứa tối đa phải lớn hơn 0.");
        }
        if (capacity > MAX_CAPACITY) {
            throw new IllegalArgumentException(
                    "Sức chứa tối đa " + MAX_CAPACITY + " ghế (tối đa " + MAX_ROWS + " hàng × "
                            + DEFAULT_COLS + " cột). Dùng Seat Layout để cấu hình lưới lớn hơn.");
        }
    }

    public static void validateGrid(int rowsCount, int colsCount) {
        if (rowsCount <= 0 || rowsCount > MAX_ROWS) {
            throw new IllegalArgumentException("Số hàng ghế phải từ 1 đến " + MAX_ROWS + " (A–Z).");
        }
        if (colsCount <= 0 || colsCount > MAX_COLS) {
            throw new IllegalArgumentException("Số cột ghế phải từ 1 đến " + MAX_COLS + ".");
        }
    }

    /** Default grid: ceil(capacity / 10) rows, 10 cols — same rules as legacy addRoom. */
    public static List<Seat> generateDefaultGrid(Room room, int capacity) {
        validateCapacity(capacity);
        int cols = DEFAULT_COLS;
        int rows = (capacity + cols - 1) / cols;
        if (rows > MAX_ROWS) {
            throw new IllegalArgumentException("Sức chứa vượt quá " + MAX_ROWS + " hàng với lưới mặc định.");
        }
        return generateGrid(room.getRoomId(), room.getRoomType(), rows, cols, capacity, null);
    }

    public static List<Seat> generateGrid(long roomId, String roomType, int rowsCount, int colsCount,
            int maxSeats, String defaultSeatType) {
        validateGrid(rowsCount, colsCount);
        int limit = maxSeats > 0 ? maxSeats : rowsCount * colsCount;
        List<Seat> seats = new ArrayList<>();
        int count = 0;
        for (int r = 0; r < rowsCount; r++) {
            String rowLabel = String.valueOf((char) ('A' + r));
            for (int c = 1; c <= colsCount; c++) {
                if (count >= limit) {
                    break;
                }
                Seat seat = new Seat();
                seat.setRoomId(roomId);
                seat.setRowLabel(rowLabel);
                seat.setColNumber(c);
                seat.setSeatType(resolveSeatType(roomType, defaultSeatType, rowsCount, r));
                seat.setActive(true);
                seats.add(seat);
                count++;
            }
        }
        return seats;
    }

    private static String resolveSeatType(String roomType, String defaultSeatType, int rows, int rowIndex) {
        if (defaultSeatType != null) {
            return defaultSeatType;
        }
        if (Room.TYPE_VIP.equals(roomType)) {
            return Seat.TYPE_VIP;
        }
        if (rows >= 4 && rowIndex >= rows - 2) {
            return Seat.TYPE_VIP;
        }
        return Seat.TYPE_STANDARD;
    }
}
