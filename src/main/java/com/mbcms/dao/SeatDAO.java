package com.mbcms.dao;

import com.mbcms.model.Seat;
import java.util.List;
import java.util.Set;

public interface SeatDAO {
    
    List<Seat> findByRoom(long roomId);
    
    Set<Long> findBookedSeatIds(long showtimeId);

    /** Them danh sach ghe (bulk insert). */
    boolean insertSeats(List<Seat> seats);

    /** Xoa toan bo ghe cua 1 phong (dung khi thiet lap lai layout). */
    boolean deleteSeatsByRoom(long roomId);

    /** Cap nhat trang thai active cua ghe (bao tri/kich hoat). */
    boolean updateSeatStatus(long seatId, boolean active);

    /** Cap nhat loai ghe (Standard, VIP, Couple). */
    boolean updateSeatType(long seatId, String seatType);

    /** Kiem tra xem ghe co bat ky booking nao trong tuong lai hay khong. */
    boolean hasFutureBookings(long seatId);
}
