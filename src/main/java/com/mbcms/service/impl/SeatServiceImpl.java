package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.SeatService;
import com.mbcms.util.RoomLayoutUtil;

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
    public boolean updateSeatStatus(long seatId, long roomId, boolean active) {
        verifySeatInRoom(seatId, roomId);
        if (!active) {
            if (seatDAO.hasFutureBookings(seatId)) {
                throw new IllegalArgumentException(
                        "Cannot mark this seat as maintenance because it has future bookings.");
            }
        }
        boolean ok = seatDAO.updateSeatStatus(seatId, active);
        if (ok) {
            seatDAO.syncRoomCapacityFromActiveSeats(roomId);
        }
        return ok;
    }

    @Override
    public boolean updateSeatType(long seatId, long roomId, String seatType) {
        // (1) Ghe phai thuoc dung phong gui len -> chong gia mao seatId cua phong khac.
        verifySeatInRoom(seatId, roomId);
        // (2) Co ve cho suat chieu tuong lai -> CHAN (doi loai lam doi gia, khong duoc
        //     doi ghe khach da mua: tranh mua VIP ma thanh Standard).
        if (seatDAO.hasFutureBookings(seatId)) {
            throw new IllegalArgumentException(
                    "Cannot change this seat type because it has future bookings.");
        }
        // (3) Whitelist: chi nhan STANDARD hoac VIP. KHONG tin client (co the gui gia tri bay).
        if (seatType == null || (!seatType.equals(Seat.TYPE_STANDARD) && !seatType.equals(Seat.TYPE_VIP))) {
            throw new IllegalArgumentException("Invalid seat type (STANDARD, VIP).");
        }
        // Qua ca 3 kiem tra -> ghi xuong DB.
        return seatDAO.updateSeatType(seatId, seatType);
    }

    @Override
    public boolean regenerateLayout(long roomId, int rowsCount, int colsCount, String defaultType) {
        RoomLayoutUtil.validateGrid(rowsCount, colsCount);

        if (defaultType == null || (!defaultType.equals(Seat.TYPE_STANDARD) && !defaultType.equals(Seat.TYPE_VIP))) {
            throw new IllegalArgumentException("Invalid default seat type.");
        }

        Room room = roomDAO.findById(roomId);
        if (room == null) {
            throw new IllegalArgumentException("Hall does not exist.");
        }

        if (roomDAO.hasFutureShowtimes(roomId)) {
            throw new IllegalArgumentException(
                    "Cannot reset the seat layout because this hall has future showtimes.");
        }
        if (seatDAO.hasAnyBookingsForRoom(roomId)) {
            throw new IllegalArgumentException(
                    "This hall has booking history. You cannot delete all seats; edit seats on the current layout.");
        }

        int capacity = rowsCount * colsCount;
        List<Seat> seats = RoomLayoutUtil.generateGrid(
                roomId, room.getRoomType(), rowsCount, colsCount, capacity, defaultType);
        room.setCapacity(capacity);
        room.setName(room.getName());
        room.setRoomType(room.getRoomType());
        return roomDAO.replaceSeatsAndUpdateRoom(room, seats);
    }

    private void verifySeatInRoom(long seatId, long roomId) {
        Seat seat = seatDAO.findById(seatId);
        if (seat == null || seat.getRoomId() != roomId) {
            throw new IllegalArgumentException("Seat does not belong to this hall.");
        }
    }
}
