package com.mbcms.dao;

import java.util.Set;

/**
 * MovieBranchDAO - truy van bang `movie_branch` (phan phoi phim cho chi nhanh).
 * Owner: HungNT. Dung cho man Admin "Assign movie to branch" (Phase 2).
 */
public interface MovieBranchDAO {

    /** Cac movie_id da duoc cap cho 1 chi nhanh. */
    Set<Long> findMovieIdsByBranch(long branchId);

    /** Tong so cap (phim, chi nhanh) da phan phoi - cho thong ke dashboard. */
    int countAll();

    /**
     * Dat lai danh sach phim duoc cap cho 1 chi nhanh = {@code targetMovieIds}.
     * Thuc hien dang DIFF trong 1 transaction: chi INSERT phim moi them va
     * DELETE phim bo chon -> giu nguyen assigned_at cua phim khong doi.
     *
     * @return so cap (movie,branch) thuc su thay doi (them + bo).
     */
    int updateAssignments(long branchId, Set<Long> targetMovieIds);
}
