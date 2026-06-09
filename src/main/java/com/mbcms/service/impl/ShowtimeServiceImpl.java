package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Showtime;
import com.mbcms.service.ShowtimeService;

public class ShowtimeServiceImpl implements ShowtimeService {

    private final ShowtimeDAO showtimeDAO;
    private final RoomDAO roomDAO;

    public ShowtimeServiceImpl() {
        this.showtimeDAO = new ShowtimeDAOImpl();
        this.roomDAO = new RoomDAOImpl();
    }

    /** Constructor cho unit test (inject mock DAO). */
    public ShowtimeServiceImpl(ShowtimeDAO showtimeDAO, RoomDAO roomDAO) {
        this.showtimeDAO = showtimeDAO;
        this.roomDAO = roomDAO;
    }

    @Override
    public String createShowtime(Showtime showtime, long branchId) {
        // Verify room thuoc dung branch cua manager + dang active.
        // Khong tin roomId tu form (user co the sua HTML truoc khi submit).
        Room room = roomDAO.findById(showtime.getRoomId());
        if (room == null || room.getBranchId() != branchId || !room.isActive()) {
            return RESULT_ROOM_INVALID;
        }

        // DAO check trung lich + insert trong cung transaction
        boolean created = showtimeDAO.createWithConflictCheck(showtime);
        return created ? RESULT_OK : RESULT_CONFLICT;
    }

    @Override
    public Showtime getShowtimeForBranch(long showtimeId, long branchId) {
        Showtime st = showtimeDAO.findById(showtimeId);
        if (st == null || !belongsToBranch(st, branchId)) {
            return null; // khong ton tai HOAC cua branch khac -> doi xu nhu nhau
        }
        return st;
    }

    @Override
    public String updateShowtime(Showtime showtime, long branchId) {
        Showtime existing = showtimeDAO.findById(showtime.getShowtimeId());
        if (existing == null || !belongsToBranch(existing, branchId)) {
            return RESULT_NOT_FOUND;
        }
        if (!Showtime.STATUS_SCHEDULED.equals(existing.getStatus())) {
            return RESULT_NOT_EDITABLE; // CANCELLED/ENDED thi khong sua nua
        }

        // Room moi (co the doi phong khi edit) van phai thuoc branch + active
        Room newRoom = roomDAO.findById(showtime.getRoomId());
        if (newRoom == null || newRoom.getBranchId() != branchId || !newRoom.isActive()) {
            return RESULT_ROOM_INVALID;
        }

        boolean updated = showtimeDAO.updateWithConflictCheck(showtime);
        return updated ? RESULT_OK : RESULT_CONFLICT;
    }

    @Override
    public String cancelShowtime(long showtimeId, long branchId) {
        Showtime existing = showtimeDAO.findById(showtimeId);
        if (existing == null || !belongsToBranch(existing, branchId)) {
            return RESULT_NOT_FOUND;
        }
        if (!Showtime.STATUS_SCHEDULED.equals(existing.getStatus())) {
            return RESULT_NOT_EDITABLE;
        }
        // Business rule: suat da co booking (PENDING/CONFIRMED/USED) thi khong huy
        // (refund out of scope). Notify customers la module notifications - lam sau.
        if (showtimeDAO.hasActiveBookings(showtimeId)) {
            return RESULT_HAS_BOOKINGS;
        }

        boolean cancelled = showtimeDAO.cancel(showtimeId);
        return cancelled ? RESULT_OK : RESULT_NOT_EDITABLE;
    }

    /** Showtime thuoc branch khi room cua no thuoc branch do. */
    private boolean belongsToBranch(Showtime st, long branchId) {
        Room room = roomDAO.findById(st.getRoomId());
        return room != null && room.getBranchId() == branchId;
    }
}
