package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.SeatService;

import java.util.ArrayList;
import java.util.List;

public class SeatServiceImpl implements SeatService {

    private final SeatDAO seatDAO;
    private final RoomDAO roomDAO;

    public SeatServiceImpl() {
        this.seatDAO = new SeatDAOImpl();
        this.roomDAO = new RoomDAOImpl();
    }

    public SeatServiceImpl(SeatDAO seatDAO, RoomDAO roomDAO) {
        this.seatDAO = seatDAO;
        this.roomDAO = roomDAO;
    }

    @Override
    public List<Seat> getSeatsByRoom(long roomId) {
        return seatDAO.findByRoom(roomId);
    }

    @Override
    public boolean updateSeatStatus(long seatId, boolean active) {
        if (!active) {
            // Check if there are future bookings for this specific seat
            if (seatDAO.hasFutureBookings(seatId)) {
                throw new IllegalArgumentException("Không thể đưa ghế này vào diện bảo trì vì đang có vé đặt trước cho suất chiếu trong tương lai.");
            }
        }
        return seatDAO.updateSeatStatus(seatId, active);
    }

    @Override
    public boolean updateSeatType(long seatId, String seatType) {
        if (seatDAO.hasFutureBookings(seatId)) {
            throw new IllegalArgumentException("Không thể thay đổi loại ghế này vì đang có vé đặt trước cho suất chiếu trong tương lai.");
        }
        if (seatType == null || (!seatType.equals(Seat.TYPE_STANDARD) 
                && !seatType.equals(Seat.TYPE_VIP))) {
            throw new IllegalArgumentException("Loại ghế không hợp lệ (STANDARD, VIP, COUPLE).");
        }
        return seatDAO.updateSeatType(seatId, seatType);
    }

    @Override
    public boolean regenerateLayout(long roomId, int rowsCount, int colsCount, String defaultType) {
        if (rowsCount <= 0 || rowsCount > 26) {
            throw new IllegalArgumentException("Số lượng hàng ghế phải từ 1 đến 26 (tương ứng A-Z).");
        }
        if (colsCount <= 0 || colsCount > 30) {
            throw new IllegalArgumentException("Số lượng cột ghế phải từ 1 đến 30.");
        }
        if (defaultType == null || (!defaultType.equals(Seat.TYPE_STANDARD) 
                && !defaultType.equals(Seat.TYPE_VIP))) {
            throw new IllegalArgumentException("Loại ghế mặc định không hợp lệ.");
        }

        Room room = roomDAO.findById(roomId);
        if (room == null) {
            throw new IllegalArgumentException("Phòng chiếu không tồn tại.");
        }

        // Check if room has future showtimes
        if (roomDAO.hasFutureShowtimes(roomId)) {
            throw new IllegalArgumentException("Không thể thiết lập lại sơ đồ ghế vì đang có lịch chiếu cho phòng này trong tương lai.");
        }

        // 1. Delete all old seats
        seatDAO.deleteSeatsByRoom(roomId);

        // 2. Generate new seats
        List<Seat> seats = new ArrayList<>();
        for (int r = 0; r < rowsCount; r++) {
            String rowLabel = String.valueOf((char) ('A' + r));
            for (int c = 1; c <= colsCount; c++) {
                Seat seat = new Seat();
                seat.setRoomId(roomId);
                seat.setRowLabel(rowLabel);
                seat.setColNumber(c);
                seat.setSeatType(defaultType);
                seat.setActive(true);
                seats.add(seat);
            }
        }

        boolean success = seatDAO.insertSeats(seats);
        if (success) {
            // 3. Update room capacity
            room.setCapacity(rowsCount * colsCount);
            roomDAO.update(room);
        }
        return success;
    }
}
