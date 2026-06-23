package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.RoomService;
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
        return roomDAO.findAll(includeInactive);
    }

    @Override
    public List<Room> getRoomsByBranch(long branchId, boolean includeInactive) {
        return roomDAO.findAllByBranch(branchId, includeInactive);
    }

    @Override
    public Room getRoomById(long roomId) {
        return roomDAO.findById(roomId);
    }

    @Override
    public boolean addRoom(Room room) {
        validateRoom(room);

        // Check duplicate name within the same branch
        List<Room> existingRooms = roomDAO.findAllByBranch(room.getBranchId(), true);
        for (Room r : existingRooms) {
            if (r.getName().equalsIgnoreCase(room.getName().trim())) {
                throw new IllegalArgumentException("Tên phòng chiếu đã tồn tại trong chi nhánh này.");
            }
        }

        room.setName(room.getName().trim());
        room.setActive(true);

        boolean success = roomDAO.insert(room);
        if (success) {
            // Automatically generate default seat layout
            // Let's assume a standard grid of 10 seats per row
            int capacity = room.getCapacity();
            int cols = 10;
            int rows = (capacity + cols - 1) / cols; // Ceil division

            List<Seat> seats = new ArrayList<>();
            int count = 0;
            for (int r = 0; r < rows; r++) {
                String rowLabel = String.valueOf((char) ('A' + r));
                for (int c = 1; c <= cols; c++) {
                    if (count >= capacity) break;
                    
                    Seat seat = new Seat();
                    seat.setRoomId(room.getRoomId());
                    seat.setRowLabel(rowLabel);
                    seat.setColNumber(c);
                    
                    // Default seat type
                    if (Room.TYPE_VIP.equals(room.getRoomType())) {
                        seat.setSeatType(Seat.TYPE_VIP);
                    } else {
                        // In standard/IMAX rooms, default last 2 rows to VIP, others standard
                        if (rows >= 4 && r >= rows - 2) {
                            seat.setSeatType(Seat.TYPE_VIP);
                        } else {
                            seat.setSeatType(Seat.TYPE_STANDARD);
                        }
                    }
                    seat.setActive(true);
                    seats.add(seat);
                    count++;
                }
            }
            seatDAO.insertSeats(seats);
        }
        return success;
    }

    @Override
    public boolean updateRoom(Room room) {
        validateRoom(room);

        Room existing = roomDAO.findById(room.getRoomId());
        if (existing == null) {
            throw new IllegalArgumentException("Phòng chiếu không tồn tại.");
        }

        // Check duplicate name with other rooms in same branch
        List<Room> existingRooms = roomDAO.findAllByBranch(existing.getBranchId(), true);
        for (Room r : existingRooms) {
            if (r.getRoomId() != room.getRoomId() && r.getName().equalsIgnoreCase(room.getName().trim())) {
                throw new IllegalArgumentException("Tên phòng chiếu đã tồn tại trong chi nhánh này.");
            }
        }

        // Check if capacity changed and if there are bookings/showtimes
        // Save the flag BEFORE mutating existing, otherwise the second check is always false
        boolean capacityChanged = existing.getCapacity() != room.getCapacity();
        if (capacityChanged) {
            if (roomDAO.hasFutureShowtimes(room.getRoomId())) {
                throw new IllegalArgumentException("Không thể thay đổi sức chứa của phòng chiếu vì đang có lịch chiếu trong tương lai.");
            }
            existing.setCapacity(room.getCapacity());
        }

        existing.setName(room.getName().trim());
        existing.setRoomType(room.getRoomType());

        boolean success = roomDAO.update(existing);
        if (success && capacityChanged) {
            // Re-generate seats to match new capacity
            seatDAO.deleteSeatsByRoom(existing.getRoomId());
            int capacity = existing.getCapacity();
            int cols = 10;
            int rows = (capacity + cols - 1) / cols;

            List<Seat> seats = new ArrayList<>();
            int count = 0;
            for (int r = 0; r < rows; r++) {
                String rowLabel = String.valueOf((char) ('A' + r));
                for (int c = 1; c <= cols; c++) {
                    if (count >= capacity) break;

                    Seat seat = new Seat();
                    seat.setRoomId(existing.getRoomId());
                    seat.setRowLabel(rowLabel);
                    seat.setColNumber(c);
                    if (Room.TYPE_VIP.equals(existing.getRoomType())) {
                        seat.setSeatType(Seat.TYPE_VIP);
                    } else {
                        if (rows >= 4 && r >= rows - 2) {
                            seat.setSeatType(Seat.TYPE_VIP);
                        } else {
                            seat.setSeatType(Seat.TYPE_STANDARD);
                        }
                    }
                    seat.setActive(true);
                    seats.add(seat);
                    count++;
                }
            }
            seatDAO.insertSeats(seats);
        }
        return success;
    }

    @Override
    public boolean toggleRoomStatus(long roomId, boolean active) {
        if (!active) {
            // Soft delete/disable
            if (roomDAO.hasFutureShowtimes(roomId)) {
                throw new IllegalArgumentException("Không thể vô hiệu hóa phòng chiếu vì đang có lịch chiếu trong tương lai.");
            }
        }
        return roomDAO.updateStatus(roomId, active);
    }

    @Override
    public boolean deleteRoom(long roomId) {
        if (roomDAO.hasFutureShowtimes(roomId)) {
            throw new IllegalArgumentException("Không thể xóa phòng chiếu vì đang có lịch chiếu trong tương lai.");
        }
        // Soft delete
        return roomDAO.updateStatus(roomId, false);
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
