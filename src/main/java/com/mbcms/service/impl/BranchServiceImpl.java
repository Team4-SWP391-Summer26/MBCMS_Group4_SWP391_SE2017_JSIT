package com.mbcms.service.impl;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.service.BranchService;
import com.mbcms.util.ValidationUtil;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

public class BranchServiceImpl implements BranchService {

    private final BranchDAO branchDAO;

    public BranchServiceImpl() {
        this.branchDAO = new BranchDAOImpl();
    }

    public BranchServiceImpl(BranchDAO branchDAO) {
        this.branchDAO = branchDAO;
    }

    @Override
    public List<Branch> getAllBranches(boolean includeInactive) {
        return branchDAO.findAll(includeInactive);
    }

    @Override
    public Branch getBranchById(long branchId) {
        return branchDAO.findById(branchId);
    }

    @Override
    public boolean addBranch(Branch branch) {
        validateBranch(branch);
        
        // Check duplicate name
        List<Branch> all = branchDAO.findAll(true);
        for (Branch b : all) {
            if (b.getName().equalsIgnoreCase(branch.getName().trim())) {
                throw new IllegalArgumentException("Tên chi nhánh đã tồn tại trong hệ thống.");
            }
        }

        branch.setName(branch.getName().trim());
        branch.setAddress(branch.getAddress().trim());
        branch.setCity(branch.getCity().trim());
        if (branch.getPhone() != null) branch.setPhone(branch.getPhone().trim());
        if (branch.getEmail() != null) branch.setEmail(branch.getEmail().trim());
        branch.setActive(true);
        branch.setCreatedAt(LocalDateTime.now());
        if (branch.getOpeningTime() == null) branch.setOpeningTime(LocalTime.of(8, 0));
        if (branch.getClosingTime() == null) branch.setClosingTime(LocalTime.of(23, 0));

        return branchDAO.insert(branch);
    }

    @Override
    public boolean updateBranch(Branch branch) {
        validateBranch(branch);

        Branch existing = branchDAO.findById(branch.getBranchId());
        if (existing == null) {
            throw new IllegalArgumentException("Chi nhánh không tồn tại.");
        }

        // Check duplicate name with other branches
        List<Branch> all = branchDAO.findAll(true);
        for (Branch b : all) {
            if (b.getBranchId() != branch.getBranchId() && b.getName().equalsIgnoreCase(branch.getName().trim())) {
                throw new IllegalArgumentException("Tên chi nhánh đã tồn tại trong hệ thống.");
            }
        }

        existing.setName(branch.getName().trim());
        existing.setAddress(branch.getAddress().trim());
        existing.setCity(branch.getCity().trim());
        existing.setPhone(branch.getPhone() != null ? branch.getPhone().trim() : null);
        existing.setEmail(branch.getEmail() != null ? branch.getEmail().trim() : null);

        return branchDAO.update(existing);
    }

    @Override
    public boolean toggleBranchStatus(long branchId, boolean active) {
        return branchDAO.updateStatus(branchId, active);
    }

    @Override
    public boolean updateOperatingHours(long branchId, LocalTime openingTime, LocalTime closingTime) {
        if (openingTime == null || closingTime == null) {
            throw new IllegalArgumentException("Giờ hoạt động không được để trống.");
        }
        if (!closingTime.isAfter(openingTime)) {
            throw new IllegalArgumentException("Giờ đóng cửa phải sau giờ mở cửa.");
        }
        return branchDAO.updateOperatingHours(branchId, openingTime, closingTime);
    }

    private void validateBranch(Branch b) {
        if (b == null) {
            throw new IllegalArgumentException("Thông tin chi nhánh trống.");
        }
        if (ValidationUtil.isNullOrEmpty(b.getName())) {
            throw new IllegalArgumentException("Tên chi nhánh không được để trống.");
        }
        if (ValidationUtil.isNullOrEmpty(b.getAddress())) {
            throw new IllegalArgumentException("Địa chỉ không được để trống.");
        }
        if (ValidationUtil.isNullOrEmpty(b.getCity())) {
            throw new IllegalArgumentException("Thành phố không được để trống.");
        }
        if (!ValidationUtil.isNullOrEmpty(b.getEmail()) && !ValidationUtil.isValidEmail(b.getEmail())) {
            throw new IllegalArgumentException("Email không đúng định dạng.");
        }
        if (!ValidationUtil.isNullOrEmpty(b.getPhone()) && !ValidationUtil.isValidPhone(b.getPhone())) {
            throw new IllegalArgumentException("Số điện thoại không đúng định dạng Việt Nam.");
        }
    }

    @Override
    public List<Branch> getAllBranchesWithStats(boolean includeInactive) {
        return branchDAO.findAllWithStats(includeInactive);
    }
}
