package com.mbcms.dao;

import com.mbcms.model.Room;
import java.util.List;

/**

 * RoomDAO - truy van bang `rooms`. Owner: HungNT (dung cho Showtime Management
 * - UC19 Assign hall).
 */
public interface RoomDAO {

    /**
     * Lay danh sach phong active = 1 cua 1 branch (SRS 3.5.2.2: "Inactive rooms
     * cannot have new showtimes").
     */
    List<Room> findActiveByBranch(long branchId);

    Room findById(long roomId);

    /** Lay tat ca phong chieu, co the loc theo branchId va hoat dong. */
    List<Room> findAllByBranch(long branchId, boolean includeInactive);

    /** Lay tat ca cac phong chieu trong he thong. */
    List<Room> findAll(boolean includeInactive);

    /** Them phong chieu moi. */
    boolean insert(Room room);

    /** Cap nhat phong chieu. */
    boolean update(Room room);

    /** Kich hoat / Vo hieu hoa phong chieu. */
    boolean updateStatus(long roomId, boolean active);

    /** Kiem tra xem phong chieu co lich chieu nao trong tuong lai hay khong. */
    boolean hasFutureShowtimes(long roomId);

    /** Insert room + seats atomically; sets roomId on success. */
    boolean insertWithSeats(Room room, java.util.List<com.mbcms.model.Seat> seats);

    /** Delete all seats, insert new grid, update room in one transaction. */
    boolean replaceSeatsAndUpdateRoom(Room room, java.util.List<com.mbcms.model.Seat> seats);
}
