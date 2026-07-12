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
        validateHours(branch.getOpeningTime(), branch.getClosingTime());

        List<Branch> all = branchDAO.findAll(true);
        for (Branch b : all) {
            if (b.getName().equalsIgnoreCase(branch.getName().trim())) {
                throw new IllegalArgumentException("Branch name already exists.");
            }
        }

        branch.setName(branch.getName().trim());
        branch.setAddress(branch.getAddress().trim());
        // city already normalized in validateBranch
        if (branch.getPhone() != null) {
            branch.setPhone(branch.getPhone().trim());
        }
        if (branch.getEmail() != null) {
            branch.setEmail(branch.getEmail().trim());
        }
        branch.setActive(true);
        branch.setCreatedAt(LocalDateTime.now());
        if (branch.getOpeningTime() == null) {
            branch.setOpeningTime(LocalTime.of(8, 0));
        }
        if (branch.getClosingTime() == null) {
            branch.setClosingTime(LocalTime.of(23, 0));
        }

        return branchDAO.insert(branch);
    }

    @Override
    public boolean updateBranch(Branch branch) {
        validateBranch(branch);

        Branch existing = branchDAO.findById(branch.getBranchId());
        if (existing == null) {
            throw new IllegalArgumentException("Branch does not exist.");
        }

        List<Branch> all = branchDAO.findAll(true);
        for (Branch b : all) {
            if (b.getBranchId() != branch.getBranchId() && b.getName().equalsIgnoreCase(branch.getName().trim())) {
                throw new IllegalArgumentException("Branch name already exists.");
            }
        }

        existing.setName(branch.getName().trim());
        existing.setAddress(branch.getAddress().trim());
        existing.setCity(branch.getCity()); // normalized in validateBranch
        existing.setPhone(branch.getPhone() != null ? branch.getPhone().trim() : null);
        existing.setEmail(branch.getEmail() != null ? branch.getEmail().trim() : null);
        existing.setActive(branch.isActive());
        if (branch.getOpeningTime() != null) existing.setOpeningTime(branch.getOpeningTime());
        if (branch.getClosingTime() != null) existing.setClosingTime(branch.getClosingTime());

        return branchDAO.update(existing);
    }

    @Override
    public boolean saveBranchDetails(Branch branch, LocalTime openingTime, LocalTime closingTime, boolean active) {
        validateBranch(branch);
        validateHours(openingTime, closingTime);

        Branch existing = branchDAO.findById(branch.getBranchId());
        if (existing == null) {
            throw new IllegalArgumentException("Branch does not exist.");
        }

        if (!active && existing.isActive()) {
            ensureCanDeactivate(branch.getBranchId());
        }

        existing.setName(branch.getName().trim());
        existing.setAddress(branch.getAddress().trim());
        existing.setCity(branch.getCity()); // normalized in validateBranch
        existing.setPhone(branch.getPhone() != null ? branch.getPhone().trim() : null);
        existing.setEmail(branch.getEmail() != null ? branch.getEmail().trim() : null);
        existing.setOpeningTime(openingTime);
        existing.setClosingTime(closingTime);
        existing.setActive(active);

        return branchDAO.saveBranchDetails(existing, openingTime, closingTime, active);
    }

    @Override
    public boolean toggleBranchStatus(long branchId, boolean active) {
        if (!active) {
            ensureCanDeactivate(branchId);
        }
        return branchDAO.updateStatus(branchId, active);
    }

    @Override
    public boolean updateOperatingHours(long branchId, LocalTime openingTime, LocalTime closingTime) {
        validateHours(openingTime, closingTime);
        return branchDAO.updateOperatingHours(branchId, openingTime, closingTime);
    }

    @Override
    public List<Branch> getAllBranchesWithStats(boolean includeInactive) {
        return branchDAO.findAllWithStats(includeInactive);
    }

    private void ensureCanDeactivate(long branchId) {
        if (branchDAO.hasFutureShowtimes(branchId)) {
            throw new IllegalArgumentException(
                    "Cannot deactivate this branch because it still has future showtimes.");
        }
        if (branchDAO.hasActiveFutureBookings(branchId)) {
            throw new IllegalArgumentException(
                    "Cannot deactivate this branch because it still has active bookings for future showtimes.");
        }
    }

    private void validateHours(LocalTime openingTime, LocalTime closingTime) {
        if (openingTime == null || closingTime == null) {
            throw new IllegalArgumentException("Operating hours are required.");
        }
        if (!closingTime.isAfter(openingTime)) {
            throw new IllegalArgumentException("Closing time must be after opening time.");
        }
    }

    private void validateBranch(Branch b) {
        if (b == null) {
            throw new IllegalArgumentException("Branch information is empty.");
        }
        if (ValidationUtil.isNullOrEmpty(b.getName())) {
            throw new IllegalArgumentException("Branch name is required.");
        }
        if (ValidationUtil.isNullOrEmpty(b.getAddress())) {
            throw new IllegalArgumentException("Address is required.");
        }
        if (ValidationUtil.isNullOrEmpty(b.getCity())) {
            throw new IllegalArgumentException("City is required.");
        }
        String city = ValidationUtil.normalizeVnCity(b.getCity());
        if (city == null) {
            throw new IllegalArgumentException(
                    "City must be a supported Vietnamese city (e.g. Ha Noi, TP. Ho Chi Minh, Da Nang).");
        }
        b.setCity(city);
        if (!ValidationUtil.isNullOrEmpty(b.getEmail()) && !ValidationUtil.isValidEmail(b.getEmail())) {
            throw new IllegalArgumentException("Invalid email format.");
        }
        // Phone validation relaxed: accept any non-empty string
        // (format varies: spaces, dashes, dots)
    }
}
