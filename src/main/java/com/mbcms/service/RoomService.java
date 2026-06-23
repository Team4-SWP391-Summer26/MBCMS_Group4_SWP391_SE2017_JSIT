package com.mbcms.service;

import com.mbcms.model.Room;
import java.util.List;

public interface RoomService {
    List<Room> getAllRooms(boolean includeInactive);
    List<Room> getRoomsByBranch(long branchId, boolean includeInactive);
    Room getRoomById(long roomId);
    boolean addRoom(Room room);
    boolean updateRoom(Room room);
    boolean toggleRoomStatus(long roomId, boolean active);
    boolean deleteRoom(long roomId);
}
