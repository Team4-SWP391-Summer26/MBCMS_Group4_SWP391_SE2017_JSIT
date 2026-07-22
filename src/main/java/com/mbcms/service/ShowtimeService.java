package com.mbcms.service;

import com.mbcms.model.Showtime;

/**
 * ShowtimeService - business logic cho Showtime Management. Owner: HungNT (UC20
 * Schedule showtimes, UC19 Assign hall, UC39 Set price).
 */
public interface ShowtimeService {

    String RESULT_OK = "OK";
    String RESULT_ROOM_INVALID = "ROOM_INVALID";   // room khong thuoc branch / khong active
    String RESULT_CONFLICT = "CONFLICT";           // trung lich voi suat khac cung phong
    String RESULT_NOT_FOUND = "NOT_FOUND";         // suat khong ton tai / khong thuoc branch nay
    String RESULT_NOT_EDITABLE = "NOT_EDITABLE";   // suat khong o trang thai SCHEDULED
    String RESULT_HAS_BOOKINGS = "HAS_BOOKINGS";   // da co booking -> khong duoc cancel / edit
    String RESULT_FORMAT_ROOM_MISMATCH = "FORMAT_ROOM_MISMATCH"; // IMAX format <-> IMAX room khong khop

    /**
     * Tao showtime moi cho branch cua manager dang dang nhap. Verify room thuoc
     * dung branch (chong sua form/tampering) roi giao cho DAO check trung lich
     * + insert trong transaction.
     *
     * @return RESULT_OK | RESULT_ROOM_INVALID | RESULT_CONFLICT
     */
    String createShowtime(Showtime showtime, long branchId);

    /**
     * Lay showtime de hien form Edit; null neu khong ton tai HOAC khong thuoc
     * branch nay (khong tiet lo suat cua branch khac).
     */
    Showtime getShowtimeForBranch(long showtimeId, long branchId);

    /**
     * Cap nhat showtime (UC21). Chi sua duoc suat SCHEDULED cua branch minh.
     * Conflict check loai tru chinh suat dang sua.
     *
     * @return RESULT_OK | RESULT_NOT_FOUND | RESULT_NOT_EDITABLE |
     * RESULT_ROOM_INVALID | RESULT_CONFLICT
     */
    String updateShowtime(Showtime showtime, long branchId);

    /**
     * Huy showtime (UC22). Business rule: khong huy suat da co booking con hieu
     * luc (PENDING/CONFIRMED/USED) - refund out of scope.
     *
     * @return RESULT_OK | RESULT_NOT_FOUND | RESULT_NOT_EDITABLE |
     * RESULT_HAS_BOOKINGS
     */
    String cancelShowtime(long showtimeId, long branchId);
}
