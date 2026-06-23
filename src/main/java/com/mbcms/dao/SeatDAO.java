package com.mbcms.dao;

import com.mbcms.model.Seat;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
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

    /** Kiem tra xem ghe co booking trong tuong lai hay khong. */
    boolean hasFutureBookings(long seatId);

    /**
     * Kiểm tra ghế bằng UPDLOCK + HOLDLOCK trong transaction đang mở.
     * Trả về list seatId đã bị chiếm (rỗng = tất cả còn trống).
     */
    List<Long> checkAndLockSeats(
            long showtimeId,
            List<Long> seatIds,
            Connection conn) throws SQLException;

    /**
     * Cập nhật seat_type cho nhiều ghế trong cùng transaction.
     */
    int updateSeatTypes(
            long roomId,
            Map<Long, String> seatTypes);

    /** Lấy nhãn ghế dạng A1, A2, B5... */
    List<String> findLabelsBySeatIds(List<Long> seatIds);
}