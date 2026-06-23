package com.mbcms.service;

import com.mbcms.model.Seat;
import com.mbcms.model.Showtime;

import java.util.List;
import java.util.Map;
import java.util.Set;

public interface SeatAvailabilityService {

    /**
     * Danh sach ghe cua phong thuoc showtime, sap xep row -> col.
     */
    List<Seat> getSeats(long showtimeId);

    /**
     * Set seat_id da bi dat (PENDING chua het han + CONFIRMED + USED).
     */
    Set<Long> getBookedSeatIds(long showtimeId);

    /**
     * Ghe nhom theo row — dung de render so do trong JSP. Key = rowLabel (A, B,
     * C...), Value = List<Seat> sap xep theo col_number.
     */
    Map<String, List<Seat>> getSeatsByRow(long showtimeId);

    /**
     * So ghe con trong.
     */
    int countAvailable(long showtimeId);

    /**
     * Kiem tra 1 ghe co dat duoc khong.
     */
    boolean isSeatAvailable(long showtimeId, long seatId);

    /**
     * Thong tin showtime.
     */
    Showtime getShowtime(long showtimeId);
}
