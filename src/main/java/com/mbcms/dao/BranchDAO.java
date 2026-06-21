package com.mbcms.dao;

import com.mbcms.model.Branch;
import java.util.List;

/**
 * BranchDAO - truy van bang `branches` (chi doc).
 * Owner: HungNT - dung cho manager console (hien ten branch trong sidebar
 * va scope notice). CRUD branch la phan cua HoangHM, KHONG nam o day.
 */
public interface BranchDAO {

    /** Tim branch theo id; null neu khong ton tai. */
    Branch findById(long branchId);
    
    /**
     * Lay danh sach tat ca branch active = 1, sap xep theo ten.
     * Dung cho customer flow: chon chi nhanh -> chon phim -> chon suat -> chon ghe.
     */
    List<Branch> findAllActive();
}
