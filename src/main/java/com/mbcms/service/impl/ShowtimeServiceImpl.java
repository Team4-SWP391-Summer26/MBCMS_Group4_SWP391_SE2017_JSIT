package com.mbcms.service.impl;

import com.mbcms.dao.RoomDAO;
import com.mbcms.dao.ShowtimeDAO;
import com.mbcms.dao.impl.RoomDAOImpl;
import com.mbcms.dao.impl.ShowtimeDAOImpl;
import com.mbcms.model.Room;
import com.mbcms.model.Showtime;
import com.mbcms.service.ShowtimeService;

import java.time.LocalDateTime;

/**
 * Tang Service cho Showtime: chua TOAN BO business rule (verify branch,
 * trang thai, booking). Servlet chi goi cac ham o day, KHONG tu kiem tra logic.
 * DAO chi lo cau SQL. Nho vay khi defend, moi quy tac nghiep vu deu nam 1 cho.
 */
public class ShowtimeServiceImpl implements ShowtimeService {

    // 2 DAO ma service nay can: showtime (suat chieu) va room (kiem tra phong).
    private final ShowtimeDAO showtimeDAO;
    private final RoomDAO roomDAO;

    /** Constructor mac dinh dung khi chay that: tu tao DAO impl. */
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
        // Buoc 1 - Bao mat: verify room (phong) ma user chon co dung thuoc
        // branch cua manager dang dang nhap khong, va phong con active khong.
        // Ly do: roomId gui len tu form HTML, user co the sua tay de chen suat
        // vao phong cua branch khac -> KHONG duoc tin, phai check lai o server.
        Room room = roomDAO.findById(showtime.getRoomId());
        if (room == null || room.getBranchId() != branchId || !room.isActive()) {
            return RESULT_ROOM_INVALID;
        }

        // Buoc 2 - Nghiep vu: giao cho DAO check trung lich + INSERT trong cung
        // 1 transaction. Tra ve true neu insert thanh cong, false neu trung lich.
        boolean created = showtimeDAO.createWithConflictCheck(showtime);
        return created ? RESULT_OK : RESULT_CONFLICT;
    }

    @Override
    public Showtime getShowtimeForBranch(long showtimeId, long branchId) {
        Showtime st = showtimeDAO.findById(showtimeId);
        // Gop 2 truong hop "khong tim thay" va "cua branch khac" thanh CUNG ket qua
        // (tra null) -> tranh lo cho user biet suat cua branch khac co ton tai hay khong.
        if (st == null || !belongsToBranch(st, branchId)) {
            return null;
        }
        return st;
    }

    @Override
    public String updateShowtime(Showtime showtime, long branchId) {
        // Buoc 1: lay suat hien tai tu DB de kiem tra (khong dung gia tri tu form).
        // Phai ton tai VA thuoc dung branch cua manager moi cho sua.
        Showtime existing = showtimeDAO.findById(showtime.getShowtimeId());
        if (existing == null || !belongsToBranch(existing, branchId)) {
            return RESULT_NOT_FOUND;
        }
        // Buoc 2: chi suat dang SCHEDULED moi sua duoc.
        // Suat da CANCELLED (huy) hoac ENDED (chieu xong) thi khoa lai, khong sua.
        if (!Showtime.STATUS_SCHEDULED.equals(existing.getStatus())) {
            return RESULT_NOT_EDITABLE;
        }
        // Buoc 2.5: chi sua suat CHUA bat dau. Suat dang chieu / da chieu xong (start <= now)
        // thi khoa - khong dua vao status (status ENDED hien chua co job tu set).
        if (!existing.getStartTime().isAfter(LocalDateTime.now())) {
            return RESULT_NOT_EDITABLE;
        }

        // Buoc 3: khi edit, manager co the doi sang phong khac -> phong MOI nay
        // cung phai thuoc branch + active (check giong luc create).
        Room newRoom = roomDAO.findById(showtime.getRoomId());
        if (newRoom == null || newRoom.getBranchId() != branchId || !newRoom.isActive()) {
            return RESULT_ROOM_INVALID;
        }

        // Buoc 4: DAO check trung lich (loai tru chinh suat dang sua) + UPDATE trong transaction.
        boolean updated = showtimeDAO.updateWithConflictCheck(showtime);
        return updated ? RESULT_OK : RESULT_CONFLICT;
    }

    @Override
    public String cancelShowtime(long showtimeId, long branchId) {
        // Buoc 1: suat phai ton tai + thuoc branch cua manager.
        Showtime existing = showtimeDAO.findById(showtimeId);
        if (existing == null || !belongsToBranch(existing, branchId)) {
            return RESULT_NOT_FOUND;
        }
        // Buoc 2: chi huy duoc suat dang SCHEDULED (suat da huy/da chieu xong thi thoi).
        if (!Showtime.STATUS_SCHEDULED.equals(existing.getStatus())) {
            return RESULT_NOT_EDITABLE;
        }
        // Buoc 2.5: chi huy suat CHUA bat dau. Suat dang chieu / da chieu xong (start <= now)
        // thi khoa - khong the huy mot suat da/dang dien ra.
        if (!existing.getStartTime().isAfter(LocalDateTime.now())) {
            return RESULT_NOT_EDITABLE;
        }
        // Business rule: suat da co booking (PENDING/CONFIRMED/USED) thi khong huy
        // (refund out of scope). Notify customers la module notifications - lam sau.
        if (showtimeDAO.hasActiveBookings(showtimeId)) {
            return RESULT_HAS_BOOKINGS;
        }

        // Buoc 4: qua het cac check -> doi status sang CANCELLED (soft cancel).
        boolean cancelled = showtimeDAO.cancel(showtimeId);
        return cancelled ? RESULT_OK : RESULT_NOT_EDITABLE;
    }

    /**
     * Helper kiem tra quyen: suat chieu "thuoc" branch nao la dua vao phong cua no.
     * Bang showtimes khong co cot branch_id truc tiep, ma di qua room -> branch.
     */
    private boolean belongsToBranch(Showtime st, long branchId) {
        Room room = roomDAO.findById(st.getRoomId());
        return room != null && room.getBranchId() == branchId;
    }
}
