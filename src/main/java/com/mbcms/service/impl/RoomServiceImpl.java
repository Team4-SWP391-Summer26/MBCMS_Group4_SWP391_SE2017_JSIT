package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.RoomService;
import com.mbcms.util.RoomLayoutUtil;
import com.mbcms.util.ValidationUtil;

import java.util.ArrayList;
import java.util.List;

public class RoomServiceImpl implements RoomService {

    private final RoomDAO roomDAO;
    private final SeatDAO seatDAO;

    public RoomServiceImpl() {
        this.roomDAO = new RoomDAOImpl();
        this.seatDAO = new SeatDAOImpl();
    }

    public RoomServiceImpl(RoomDAO roomDAO, SeatDAO seatDAO) {
        this.roomDAO = roomDAO;
        this.seatDAO = seatDAO;
    }

    @Override
    public List<Room> getAllRooms(boolean includeInactive) {
        return enrichWithActiveSeatCounts(roomDAO.findAll(includeInactive));
    }

    @Override
    public List<Room> getRoomsByBranch(long branchId, boolean includeInactive) {
        return enrichWithActiveSeatCounts(roomDAO.findAllByBranch(branchId, includeInactive));
    }

    @Override
    public Room getRoomById(long roomId) {
        Room room = roomDAO.findById(roomId);
        if (room != null) {
            room.setActiveSeatCount(seatDAO.countActiveSeatsByRoom(roomId));
        }
        return room;
    }

    @Override
    public boolean addRoom(Room room) {
        validateRoom(room);
        RoomLayoutUtil.validateCapacity(room.getCapacity());

        List<Room> existingRooms = roomDAO.findAllByBranch(room.getBranchId(), true);
        for (Room r : existingRooms) {
            if (r.getName().equalsIgnoreCase(room.getName().trim())) {
                throw new IllegalArgumentException("Tên phòng chiếu đã tồn tại trong chi nhánh này.");
            }
        }

        room.setName(room.getName().trim());
        room.setActive(true);

        List<Seat> seats = RoomLayoutUtil.generateDefaultGrid(room, room.getCapacity());
        return roomDAO.insertWithSeats(room, seats);
    }

    @Override
    public boolean updateRoom(Room room) {
        validateRoom(room);

        Room existing = roomDAO.findById(room.getRoomId());
        if (existing == null) {
            throw new IllegalArgumentException("Phòng chiếu không tồn tại.");
        }

        List<Room> existingRooms = roomDAO.findAllByBranch(existing.getBranchId(), true);
        for (Room r : existingRooms) {
            if (r.getRoomId() != room.getRoomId() && r.getName().equalsIgnoreCase(room.getName().trim())) {
                throw new IllegalArgumentException("Tên phòng chiếu đã tồn tại trong chi nhánh này.");
            }
        }

        boolean capacityChanged = existing.getCapacity() != room.getCapacity();
        if (capacityChanged) {
            RoomLayoutUtil.validateCapacity(room.getCapacity());
            if (roomDAO.hasFutureShowtimes(room.getRoomId())) {
                throw new IllegalArgumentException(
                        "Không thể thay đổi sức chứa vì đang có lịch chiếu trong tương lai.");
            }
            if (seatDAO.hasAnyBookingsForRoom(room.getRoomId())) {
                throw new IllegalArgumentException(
                        "Phòng đã từng có vé đặt. Chỉnh số ghế qua Seat Layout (tắt/bật ghế), không đổi capacity tại đây.");
            }
        }

        existing.setName(room.getName().trim());
        existing.setRoomType(room.getRoomType());

        if (!capacityChanged) {
            return roomDAO.update(existing);
        }

        existing.setCapacity(room.getCapacity());
        List<Seat> seats = RoomLayoutUtil.generateDefaultGrid(existing, existing.getCapacity());
        return roomDAO.replaceSeatsAndUpdateRoom(existing, seats);
    }

    @Override
    public boolean toggleRoomStatus(long roomId, boolean active) {
        if (!active) {
            if (roomDAO.hasFutureShowtimes(roomId)) {
                throw new IllegalArgumentException(
                        "Không thể vô hiệu hóa phòng chiếu vì đang có lịch chiếu trong tương lai.");
            }
        }
        return roomDAO.updateStatus(roomId, active);
    }

    @Override
    public boolean deleteRoom(long roomId) {
        return toggleRoomStatus(roomId, false);
    }

    private List<Room> enrichWithActiveSeatCounts(List<Room> rooms) {
        for (Room room : rooms) {
            room.setActiveSeatCount(seatDAO.countActiveSeatsByRoom(room.getRoomId()));
        }
        return rooms;
    }

    private void validateRoom(Room r) {
        if (r == null) {
            throw new IllegalArgumentException("Thông tin phòng chiếu trống.");
        }
        if (ValidationUtil.isNullOrEmpty(r.getName())) {
            throw new IllegalArgumentException("Tên phòng chiếu không được để trống.");
        }
        if (r.getCapacity() <= 0) {
            throw new IllegalArgumentException("Sức chứa tối đa phải lớn hơn 0.");
        }
        if (r.getRoomType() == null || (!r.getRoomType().equals(Room.TYPE_STANDARD)
                && !r.getRoomType().equals(Room.TYPE_VIP)
                && !r.getRoomType().equals(Room.TYPE_IMAX))) {
            throw new IllegalArgumentException("Loại phòng chiếu không hợp lệ (STANDARD, VIP, IMAX).");
        }
    }
}
