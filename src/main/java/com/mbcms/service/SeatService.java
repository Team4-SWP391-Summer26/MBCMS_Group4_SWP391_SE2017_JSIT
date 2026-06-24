package com.mbcms.service;

import com.mbcms.model.Seat;
import java.util.List;

public interface SeatService {
    List<Seat> getSeatsByRoom(long roomId);
    boolean updateSeatStatus(long seatId, long roomId, boolean active);
    boolean updateSeatType(long seatId, long roomId, String seatType);
    boolean regenerateLayout(long roomId, int rowsCount, int colsCount, String defaultType);
}
