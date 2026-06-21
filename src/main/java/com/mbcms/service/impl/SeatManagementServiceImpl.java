package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.SeatDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.SeatDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Seat;
import com.mbcms.service.SeatManagementService;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Tang Service cho Manage seat types (Feature 3). Owner: HungNT.
 * Chua toan bo business rule, DAO chi lo SQL.
 */
public class SeatManagementServiceImpl implements SeatManagementService {

    private final SeatDAO seatDAO;
    private final RoomDAO roomDAO;

    /** Constructor mac dinh khi chay that: tu tao DAO impl. */
    public SeatManagementServiceImpl() {
        this.seatDAO = new SeatDAOImpl();
        this.roomDAO = new RoomDAOImpl();
    }

    /** Constructor cho unit test (inject DAO gia). */
    public SeatManagementServiceImpl(SeatDAO seatDAO, RoomDAO roomDAO) {
        this.seatDAO = seatDAO;
        this.roomDAO = roomDAO;
    }

    @Override
    public List<Seat> getSeatsForRoom(long roomId, long branchId) {
        // Verify phong thuoc dung branch cua manager -> khong lo phong branch khac.
        Room room = roomDAO.findById(roomId);
        if (room == null || room.getBranchId() != branchId) {
            return null;
        }
        return seatDAO.findByRoom(roomId);
    }

    @Override
    public String updateSeatTypes(long roomId, long branchId, Map<Long, String> seatTypes) {
        // Buoc 1 - Bao mat: phong phai thuoc branch cua manager va con active.
        // roomId gui tu form, user co the sua tay -> KHONG tin, check lai o server.
        Room room = roomDAO.findById(roomId);
        if (room == null || room.getBranchId() != branchId || !room.isActive()) {
            return RESULT_ROOM_INVALID;
        }

        // Buoc 2 - Whitelist: chi chap nhan STANDARD / VIP (chong gia tri la).
        for (String type : seatTypes.values()) {
            if (!Seat.TYPE_STANDARD.equals(type) && !Seat.TYPE_VIP.equals(type)) {
                return RESULT_INVALID_INPUT;
            }
        }

        // Buoc 3 - Chi update ghe THUC SU doi loai va THUOC dung phong.
        // So sanh voi loai hien tai trong DB; seatId gui len khong nam trong phong
        // se bi bo qua (khong co trong currentTypeById).
        Map<Long, String> currentTypeById = new HashMap<>();
        for (Seat s : seatDAO.findByRoom(roomId)) {
            currentTypeById.put(s.getSeatId(), s.getSeatType());
        }

        Map<Long, String> changed = new HashMap<>();
        for (Map.Entry<Long, String> e : seatTypes.entrySet()) {
            String current = currentTypeById.get(e.getKey());
            if (current != null && !current.equals(e.getValue())) {
                changed.put(e.getKey(), e.getValue());
            }
        }

        // Khong co gi thay doi -> van coi la thanh cong (idempotent), khoi cham DB.
        if (!changed.isEmpty()) {
            seatDAO.updateSeatTypes(roomId, changed);
        }
        return RESULT_OK;
    }
}
