package com.mbcms.dao;

import com.mbcms.model.Room;

import java.util.List;

/**
 * RoomDAO - truy van bang `rooms`.
 * Owner: HungNT (dung cho Showtime Management - UC19 Assign hall).
 */
public interface RoomDAO {

    /**
     * Lay danh sach phong active = 1 cua 1 branch
     * (SRS 3.5.2.2: "Inactive rooms cannot have new showtimes").
     */
    List<Room> findActiveByBranch(long branchId);

    /** Tim phong theo id; null neu khong ton tai. Dung de verify phong thuoc dung branch. */
    Room findById(long roomId);
}
