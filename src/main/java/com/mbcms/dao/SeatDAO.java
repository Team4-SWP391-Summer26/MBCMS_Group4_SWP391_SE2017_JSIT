/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mbcms.dao;

import com.mbcms.model.Seat;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Set;

/**
 *
 * @author Lenovo
 */
public interface SeatDAO {
    
    List<Seat> findByRoom(long roomId);
    Set<Long> findBookedSeatIds(long showtimeId);
    
    /**
     * Kiểm tra ghế bằng UPDLOCK + HOLDLOCK trong transaction đang mở.
     * Trả về list seatId đã bị chiếm (rỗng = tất cả còn trống).
     * Phải truyền vào Connection đang trong transaction của createBooking.
     */
    List<Long> checkAndLockSeats(long showtimeId, List<Long> seatIds,
                                  Connection conn) throws SQLException;
}
