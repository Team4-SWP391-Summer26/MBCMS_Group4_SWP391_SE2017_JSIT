package com.mbcms.dao;

import com.mbcms.model.Branch;

/**
 * BranchDAO - truy van bang `branches` (chi doc). Owner: HungNT - dung cho
 * manager console (hien ten branch trong sidebar va scope notice). CRUD branch
 * la phan cua HoangHM, KHONG nam o day.
 */
public interface BranchDAO {

    /**
     * Tim branch theo id; null neu khong ton tai.
     */
    Branch findById(long branchId);
}
