package com.mbcms.service;

import com.mbcms.model.Branch;
import java.time.LocalTime;
import java.util.List;

public interface BranchService {
    List<Branch> getAllBranches(boolean includeInactive);
    Branch getBranchById(long branchId);
    boolean addBranch(Branch branch);
    boolean updateBranch(Branch branch);
    boolean saveBranchDetails(Branch branch, LocalTime openingTime, LocalTime closingTime, boolean active);
    boolean toggleBranchStatus(long branchId, boolean active);
    boolean updateOperatingHours(long branchId, LocalTime openingTime, LocalTime closingTime);
    List<Branch> getAllBranchesWithStats(boolean includeInactive);
}
