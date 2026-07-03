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

    /** Ghế đã thanh toán (CONFIRMED, USED) — hiển thị "Booked". */
    Set<Long> getBookedSeatIds(long showtimeId);

    /** Ghế đang giữ chỗ chờ thanh toán (PENDING) — hiển thị "Held by others". */
    Set<Long> getHeldSeatIds(long showtimeId);

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
