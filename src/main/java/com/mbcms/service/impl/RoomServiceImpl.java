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
                throw new IllegalArgumentException("Hall name already exists in this branch.");
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
            throw new IllegalArgumentException("Hall does not exist.");
        }

        List<Room> existingRooms = roomDAO.findAllByBranch(existing.getBranchId(), true);
        for (Room r : existingRooms) {
            if (r.getRoomId() != room.getRoomId() && r.getName().equalsIgnoreCase(room.getName().trim())) {
                throw new IllegalArgumentException("Hall name already exists in this branch.");
            }
        }

        boolean capacityChanged = existing.getCapacity() != room.getCapacity();
        if (capacityChanged) {
            RoomLayoutUtil.validateCapacity(room.getCapacity());
            if (roomDAO.hasFutureShowtimes(room.getRoomId())) {
                throw new IllegalArgumentException(
                        "Cannot change capacity because this hall has future showtimes.");
            }
            if (seatDAO.hasAnyBookingsForRoom(room.getRoomId())) {
                throw new IllegalArgumentException(
                        "This hall has booking history. Adjust seats in Seat Layout instead of changing capacity here.");
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
                        "Cannot deactivate this hall because it has future showtimes.");
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
            throw new IllegalArgumentException("Hall information is empty.");
        }
        if (ValidationUtil.isNullOrEmpty(r.getName())) {
            throw new IllegalArgumentException("Hall name is required.");
        }
        if (r.getCapacity() <= 0) {
            throw new IllegalArgumentException("Capacity must be greater than 0.");
        }
        if (r.getRoomType() == null || (!r.getRoomType().equals(Room.TYPE_STANDARD)
                && !r.getRoomType().equals(Room.TYPE_VIP)
                && !r.getRoomType().equals(Room.TYPE_IMAX))) {
            throw new IllegalArgumentException("Invalid hall type (STANDARD, VIP, IMAX).");
        }
    }
}
