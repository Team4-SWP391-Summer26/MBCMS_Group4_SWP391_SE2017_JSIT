package com.mbcms.service;

import com.mbcms.model.Branch;
import com.mbcms.model.Movie;
import com.mbcms.model.Showtime;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * CinemaBrowseService - business logic cho luong khach hang dat ve:
 *      chon chi nhanh (branch) -> chon phim cua chi nhanh do (movie)
 *      -> chon suat chieu cua phim do (showtime) -> chon ghe (xem SeatAvailabilityService).
 *
 * Day la luong "duyet/browse" (read-only), khac voi ShowtimeService
 * (CRUD suat chieu danh cho branch manager).
 */
public interface CinemaBrowseService {

    /** Danh sach chi nhanh dang active, sap xep theo ten. */
    List<Branch> getActiveBranches();

    /** Tim 1 chi nhanh active theo id; null neu khong ton tai / da ngung hoat dong. */
    Branch getActiveBranch(long branchId);

    /** Danh sach phim dang co suat chieu sap toi tai 1 chi nhanh. */
    List<Movie> getMoviesByBranch(long branchId);

    /** Tim 1 phim active theo id; null neu khong ton tai. */
    Movie getMovie(long movieId);

    /**
     * Cac suat chieu (SCHEDULED, sap toi) cua 1 phim tai 1 chi nhanh,
     * gom nhom theo ngay chieu (LocalDate) va sap theo gio tang dan trong moi ngay.
     * Dung LinkedHashMap ben trong impl de giu thu tu ngay tang dan.
     */
    Map<LocalDate, List<Showtime>> getShowtimesByBranchAndMovie(long branchId, long movieId);
}
