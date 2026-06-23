package com.mbcms.service.impl;

import com.mbcms.dao.UserDAO;
import com.mbcms.dao.impl.UserDAOImpl;
import com.mbcms.dto.UserDTO;
import com.mbcms.dto.UserStatsDTO;
import com.mbcms.service.UserService;
import org.mindrot.jbcrypt.BCrypt;

import java.time.LocalDateTime;
import java.util.List;
import java.util.regex.Pattern;

public class UserServiceImpl implements UserService {

    private final UserDAO userDAO = new UserDAOImpl();
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@(.+)$");

    @Override
    public List<UserDTO> getUsers(String search, String role, Long branchId, String status, int page, int pageSize) {
        int offset = (page - 1) * pageSize;
        return userDAO.searchUsers(search, role, branchId, status, offset, pageSize);
    }

    @Override
    public int getTotalUsersCount(String search, String role, Long branchId, String status) {
        return userDAO.countUsers(search, role, branchId, status);
    }

    @Override
    public UserStatsDTO getUserStats() {
        return userDAO.getUserStats();
    }

    @Override
    public UserDTO getUserByUsername(String username) {
        if (username == null || username.trim().isEmpty()) {
            return null;
        }
        return userDAO.findByUsername(username.trim());
    }

    @Override
    public boolean addUser(UserDTO user, String rawPassword) {
        validateUserCommon(user);

        if (rawPassword == null || rawPassword.trim().isEmpty()) {
            throw new IllegalArgumentException("Mật khẩu không được để trống khi thêm mới.");
        }
        if (rawPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu phải có ít nhất 6 ký tự.");
        }

        // Check duplicates
        if (userDAO.existsByUsername(user.getUsername())) {
            throw new IllegalArgumentException("Tên đăng nhập đã tồn tại trong hệ thống.");
        }
        if (userDAO.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email đã đăng ký tài khoản khác.");
        }

        String passwordHash = BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));
        user.setActive(true);
        user.setCreatedAt(LocalDateTime.now());

        if ("CUSTOMER".equalsIgnoreCase(user.getRole())) {
            return userDAO.insertCustomer(user, passwordHash);
        } else {
            return userDAO.insertEmployee(user, passwordHash);
        }
    }

    @Override
    public boolean editUser(UserDTO user, String rawPassword, String currentUserSessionUsername) {
        if (user == null || user.getUsername() == null || user.getUsername().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không hợp lệ.");
        }

        UserDTO existing = userDAO.findByUsername(user.getUsername());
        if (existing == null) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }

        // Backend enforcement: username is readonly on edit. Ensure we do not overwrite or change it
        user.setUsername(existing.getUsername());

        // Validate common details
        validateUserCommon(user);

        // Check email uniqueness if email is changing
        if (!existing.getEmail().equalsIgnoreCase(user.getEmail()) && userDAO.existsByEmail(user.getEmail())) {
            throw new IllegalArgumentException("Email đã đăng ký tài khoản khác.");
        }

        // Self-modification checks
        boolean isSelf = existing.getUsername().equalsIgnoreCase(currentUserSessionUsername);
        if (isSelf) {
            // Cannot deactivate oneself
            if (!user.isActive()) {
                throw new IllegalArgumentException("Bạn không thể vô hiệu hóa tài khoản của chính mình.");
            }
            // Cannot change role of oneself
            if (!existing.getRole().equalsIgnoreCase(user.getRole())) {
                throw new IllegalArgumentException("Bạn không thể thay đổi vai trò của chính mình.");
            }
        }

        String passwordHash = null;
        if (rawPassword != null && !rawPassword.trim().isEmpty()) {
            if (rawPassword.length() < 6) {
                throw new IllegalArgumentException("Mật khẩu mới phải có ít nhất 6 ký tự.");
            }
            passwordHash = BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));
        }

        boolean roleChanged = !existing.getRole().equalsIgnoreCase(user.getRole());

        if (roleChanged) {
            // Check transactions if role is changing between Customer <-> Employee
            boolean oldIsCustomer = "CUSTOMER".equalsIgnoreCase(existing.getRole());
            boolean newIsCustomer = "CUSTOMER".equalsIgnoreCase(user.getRole());

            if (oldIsCustomer != newIsCustomer) {
                if (oldIsCustomer && userDAO.hasRelatedTransactions(existing.getUsername(), "CUSTOMER")) {
                    throw new IllegalArgumentException("Không thể thay đổi vai trò vì khách hàng đã có lịch sử đặt vé hoặc phản hồi.");
                }
            }

            // Perform role change: Insert into new table first, then delete from old
            if (newIsCustomer) {
                // Move from employee to customer
                if (passwordHash == null) {
                    // We need to keep the old password hash since no new password was provided
                    // Let's retrieve employee password hash or throw exception
                    // Wait, we can fetch it or just request the password hash
                    // Since existing is an employee, we can check how to copy it.
                    // But in our UserDTO we didn't store passwordHash, so let's query the employee password hash
                    throw new IllegalArgumentException("Cần nhập mật khẩu mới khi chuyển đổi vai trò người dùng.");
                }
                
                boolean inserted = userDAO.insertCustomer(user, passwordHash);
                if (inserted) {
                    userDAO.deleteEmployee(existing.getUsername());
                    return true;
                }
                return false;
            } else {
                // Move from customer to employee
                if (passwordHash == null) {
                    throw new IllegalArgumentException("Cần nhập mật khẩu mới khi chuyển đổi vai trò người dùng.");
                }
                
                boolean inserted = userDAO.insertEmployee(user, passwordHash);
                if (inserted) {
                    userDAO.deleteCustomer(existing.getUsername());
                    return true;
                }
                return false;
            }
        } else {
            // Role did not change
            if ("CUSTOMER".equalsIgnoreCase(user.getRole())) {
                return userDAO.updateCustomer(user, passwordHash);
            } else {
                return userDAO.updateEmployee(user, passwordHash);
            }
        }
    }

    @Override
    public boolean toggleStatus(String username, boolean active, String currentUserSessionUsername) {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không hợp lệ.");
        }
        UserDTO existing = userDAO.findByUsername(username.trim());
        if (existing == null) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }

        if (existing.getUsername().equalsIgnoreCase(currentUserSessionUsername)) {
            throw new IllegalArgumentException("Bạn không thể thay đổi trạng thái của chính mình.");
        }

        return userDAO.updateActiveStatus(existing.getUsername(), existing.getRole(), active);
    }

    @Override
    public boolean deleteUser(String username, String currentUserSessionUsername) {
        if (username == null || username.trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không hợp lệ.");
        }
        UserDTO existing = userDAO.findByUsername(username.trim());
        if (existing == null) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }

        if (existing.getUsername().equalsIgnoreCase(currentUserSessionUsername)) {
            throw new IllegalArgumentException("Bạn không thể xóa tài khoản của chính mình.");
        }

        // Check transaction check for customer deletion
        if ("CUSTOMER".equalsIgnoreCase(existing.getRole()) && userDAO.hasRelatedTransactions(existing.getUsername(), "CUSTOMER")) {
            throw new IllegalArgumentException("Không thể xóa khách hàng này vì đã có lịch sử đặt vé hoặc phản hồi.");
        }

        if ("CUSTOMER".equalsIgnoreCase(existing.getRole())) {
            return userDAO.deleteCustomer(existing.getUsername());
        } else {
            return userDAO.deleteEmployee(existing.getUsername());
        }
    }

    @Override
    public boolean sendPasswordResetEmail(String username) {
        // Mock method as shown in Mockup 2
        UserDTO existing = userDAO.findByUsername(username);
        if (existing == null) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }
        // Simulation only
        return true;
    }

    private void validateUserCommon(UserDTO u) {
        if (u == null) {
            throw new IllegalArgumentException("Thông tin người dùng không được trống.");
        }
        if (u.getUsername() == null || u.getUsername().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên đăng nhập không được để trống.");
        }
        if (u.getFullName() == null || u.getFullName().trim().isEmpty()) {
            throw new IllegalArgumentException("Họ và tên không được để trống.");
        }
        if (u.getEmail() == null || u.getEmail().trim().isEmpty()) {
            throw new IllegalArgumentException("Email không được để trống.");
        }
        if (!EMAIL_PATTERN.matcher(u.getEmail().trim()).matches()) {
            throw new IllegalArgumentException("Email không đúng định dạng.");
        }
        if (u.getRole() == null || u.getRole().trim().isEmpty()) {
            throw new IllegalArgumentException("Vai trò không được để trống.");
        }

        String role = u.getRole().trim().toUpperCase();
        if (!"CUSTOMER".equals(role) && !"ADMIN".equals(role) && !"BRANCH_MANAGER".equals(role) && !"BRANCH_STAFF".equals(role)) {
            throw new IllegalArgumentException("Vai trò không hợp lệ.");
        }

        // BranchId check
        if ("BRANCH_MANAGER".equals(role) || "BRANCH_STAFF".equals(role)) {
            if (u.getBranchId() == null || u.getBranchId() <= 0) {
                throw new IllegalArgumentException("Vui lòng chọn chi nhánh gán cho Quản lý / Nhân viên.");
            }
        } else {
            // ADMIN or CUSTOMER must not have a branchId
            u.setBranchId(null);
        }

        u.setUsername(u.getUsername().trim());
        u.setEmail(u.getEmail().trim());
        u.setFullName(u.getFullName().trim());
        if (u.getPhone() != null) u.setPhone(u.getPhone().trim());
        if (u.getAddress() != null) u.setAddress(u.getAddress().trim());
    }
}
