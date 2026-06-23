package com.mbcms.dao;

import com.mbcms.model.Branch;
import java.time.LocalTime;
import java.util.List;

/**
 * BranchDAO - truy van bang `branches`.
 * CRUD branch la phan cua HoangHM.
 */
public interface BranchDAO {

    /** Tim branch theo id; null neu khong ton tai. */
    Branch findById(long branchId);

    /** Lay tat ca chi nhanh. */
    List<Branch> findAll(boolean includeInactive);

    /** Them moi chi nhanh. */
    boolean insert(Branch branch);

    /** Cap nhat thong tin chi nhanh. */
    boolean update(Branch branch);

    /** Bieu quyet active/inactive cho chi nhanh (soft delete). */
    boolean updateStatus(long branchId, boolean active);

    /** Cap nhat gio hoat dong cua chi nhanh. */
    boolean updateOperatingHours(long branchId, LocalTime openingTime, LocalTime closingTime);

    /** Lay tat ca chi nhanh kem cac thong ke (rooms, seats, today showtimes, monthly revenue, manager). */
    List<Branch> findAllWithStats(boolean includeInactive);
}
