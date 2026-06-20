package com.mbcms.service;

import com.mbcms.model.Movie;

import java.util.List;
import java.util.Set;

/**
 * MovieDistributionService - business logic cho man Admin "Assign movie to branch".
 * Admin cap/thu hoi phim cho tung chi nhanh (ghi bang movie_branch). Owner: HungNT.
 *
 * Moi quy tac (branch ton tai, chi nhan phim ACTIVE) nam o tang nay - servlet
 * KHONG tu kiem tra.
 */
public interface MovieDistributionService {

    String RESULT_OK = "OK";
    String RESULT_BRANCH_INVALID = "BRANCH_INVALID";
    String RESULT_HAS_SHOWTIMES = "HAS_SHOWTIMES"; // go phim ma chi nhanh con suat chua chieu xong

    /** Tat ca phim active trong catalog (de hien checklist). */
    List<Movie> getAssignableMovies();

    /**
     * movie_id da cap cho 1 chi nhanh; null neu branch khong ton tai
     * (khong tiet lo branch khac).
     */
    Set<Long> getAssignedMovieIds(long branchId);

    /**
     * Luu phan phoi cho chi nhanh = {@code movieIds}. Chi chap nhan phim ACTIVE
     * hop le (bo qua movie_id la / khong active - chong tampering tu form).
     * KHONG cho go phim ma chi nhanh con suat chieu chua ket thuc.
     *
     * @return RESULT_OK | RESULT_BRANCH_INVALID | RESULT_HAS_SHOWTIMES
     */
    String saveAssignments(long branchId, Set<Long> movieIds);
}
