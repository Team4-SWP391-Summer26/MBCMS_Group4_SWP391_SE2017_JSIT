package com.mbcms.dao;

import com.mbcms.model.Seat;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

public interface SeatDAO {

    List<Seat> findByRoom(long roomId);

    /** Ghế đã thanh toán / xác nhận (CONFIRMED, USED). */
    Set<Long> findBookedSeatIds(long showtimeId);

    /** Ghế đang giữ chỗ chờ thanh toán (PENDING chưa hết hạn 10 phút). */
    Set<Long> findHeldSeatIds(long showtimeId);

    /** Ghế không chọn được: held + booked. */
    Set<Long> findOccupiedSeatIds(long showtimeId);

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

    /** Any booking_seats row referencing a seat in this room (blocks full seat delete). */
    boolean hasAnyBookingsForRoom(long roomId);

    Seat findById(long seatId);

    int countActiveSeatsByRoom(long roomId);

    void syncRoomCapacityFromActiveSeats(long roomId);

    /**
     * Kiểm tra ghế bằng UPDLOCK + HOLDLOCK trong transaction đang mở.
     * Trả về list seatId đã bị chiếm (rỗng = tất cả còn trống).
     */
    List<Long> checkAndLockSeats(
            long showtimeId,
            List<Long> seatIds,
            Connection conn) throws SQLException;

    /** Lấy nhãn ghế dạng A1, A2, B5... */
    List<String> findLabelsBySeatIds(List<Long> seatIds);
}