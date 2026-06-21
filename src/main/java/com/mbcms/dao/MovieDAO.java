package com.mbcms.dao;

import com.mbcms.model.Movie;

import java.util.List;

/**
 * MovieDAO - truy van bang `movies`. Owner: HungNT (dung cho Showtime
 * Management - UC20).
 */
public interface MovieDAO {

    /**
     * Lay danh sach phim active = 1 (do vao dropdown chon phim khi tao
     * showtime).
     */
    List<Movie> findActiveMovies();

    /**
     * Phim active DA DUOC CAP cho 1 chi nhanh (qua movie_branch) - do vao dropdown
     * Create/Edit showtime. Branch Manager chi xep lich phim chi nhanh minh duoc cap.
     */
    List<Movie> findActiveMoviesForBranch(long branchId);

    /**
     * Phim nay da duoc Admin cap cho chi nhanh nay chua?
     * Chong tampering: movieId gui tu form co the bi sua tay.
     */
    boolean isAssignedToBranch(long movieId, long branchId);

    /** Tim phim theo id; null neu khong ton tai. Dung de lay duration_min tinh end_time. */
    Movie findById(long movieId);
    
    /**
     * Lay danh sach phim (DISTINCT) co it nhat 1 suat chieu SCHEDULED, sap toi
     * (start_time > now), tai 1 branch cu the. JOIN showtimes + rooms de loc
     * theo branch_id. Dung cho customer flow: chon chi nhanh -> chon phim.
     * Sap xep theo title.
     */
    List<Movie> findByBranch(long branchId);
}
