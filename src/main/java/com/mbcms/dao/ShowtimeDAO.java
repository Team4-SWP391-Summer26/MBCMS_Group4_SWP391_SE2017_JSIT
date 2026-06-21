package com.mbcms.dao;

import com.mbcms.model.Showtime;

import java.time.LocalDate;
import java.util.List;

/**
 * ShowtimeDAO - truy van bang `showtimes`.
 * Owner: HungNT (UC20 Schedule showtimes).
 */
public interface ShowtimeDAO {

    /**
     * Lay showtime cua 1 branch (JOIN movies + rooms, kem so ghe da dat).
     * Cac filter movieId/roomId/date la tuy chon (null = khong loc) - SRS 3.5.2.1.
     */
    List<Showtime> findByBranch(long branchId, Long movieId, Long roomId, LocalDate date);

    /**
     * Tao showtime moi TRONG 1 TRANSACTION:
     * check trung lich (overlap cung phong) -> rong moi INSERT -> commit.
     * UNIQUE(room_id, start_time) trong DB la luoi an toan thu 2.
     *
     * @return true = tao thanh cong; false = trung lich (da rollback).
     */
    boolean createWithConflictCheck(Showtime showtime);

    /** Tim showtime theo id (JOIN movies + rooms nhu findByBranch); null neu khong ton tai. */
    Showtime findById(long showtimeId);

    /**
     * Cap nhat showtime TRONG 1 TRANSACTION (UC21 Edit showtime).
     * Check trung lich nhu create nhung LOAI TRU CHINH NO (showtime_id <> ?)
     * de sua suat ma khong doi gio van luu duoc.
     *
     * @return true = cap nhat thanh cong; false = trung lich (da rollback).
     */
    boolean updateWithConflictCheck(Showtime showtime);

    /**
     * Co booking con hieu luc (PENDING/CONFIRMED/USED) tren suat nay khong?
     * Dung cho business rule: khong cancel suat da co nguoi dat.
     */
    boolean hasActiveBookings(long showtimeId);
    
    /** Cac suat chieu cua 1 phim, sap xep theo startTime. */
    List<Showtime> findByMovieId(long movieId);

    /**
     * Chi nhanh nay con suat chieu CHUA KET THUC cho phim nay khong?
     * (status = SCHEDULED va end_time > now -> dang chieu hoac sap chieu).
     * Dung de chan Admin bo phan phoi phim khoi chi nhanh khi con suat dang/se chieu.
     */
    boolean hasUnfinishedShowtimes(long branchId, long movieId);

    /**
     * Huy suat chieu (UC22): UPDATE status = 'CANCELLED', KHONG DELETE (giu lich su).
     * Chi huy duoc suat dang SCHEDULED.
     *
     * @return true = huy thanh cong; false = suat khong ton tai hoac khong o trang thai SCHEDULED.
     */
    boolean cancel(long showtimeId);
}
