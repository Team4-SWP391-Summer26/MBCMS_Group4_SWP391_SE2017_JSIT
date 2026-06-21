/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mbcms.dao;

import com.mbcms.model.Seat;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
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

    /**
     * Cap nhat seat_type cho nhieu ghe trong CUNG 1 transaction (Manage seat types).
     * Moi cau UPDATE rang buoc them room_id = ? -> seatId gui tu form bi sua tay
     * (thuoc phong khac) se khong bi update. Owner: HungNT.
     *
     * @param roomId    phong dang chinh (gioi han pham vi update)
     * @param seatTypes map seatId -> seat_type moi ('STANDARD' | 'VIP')
     * @return so ghe thuc su duoc cap nhat
     */
    int updateSeatTypes(long roomId, Map<Long, String> seatTypes);

    /** Nhan ghe dang "A5" tu danh sach seat_id, sap xep theo row/col. */
    List<String> findLabelsBySeatIds(List<Long> seatIds);

}
