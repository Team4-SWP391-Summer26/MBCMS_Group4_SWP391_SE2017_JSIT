package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * Employee - tai khoan nhan vien he thong.
 * Map bang `employees` (PK tu nhien: username).
 *
 * role:      ADMIN | BRANCH_MANAGER | BRANCH_STAFF
 * branchId:  NULL khi ADMIN; NOT NULL khi BRANCH_MANAGER/BRANCH_STAFF
 */
public class Employee {

    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_BRANCH_MANAGER = "BRANCH_MANAGER";
    public static final String ROLE_BRANCH_STAFF = "BRANCH_STAFF";

    private String username;
    private String email;
    private String passwordHash;
    private String fullName;
    private String phone;
    private String role;
    private Long branchId;
    private boolean active = true;
    private LocalDateTime createdAt;

    public Employee() {}

    public boolean isAdmin() { return ROLE_ADMIN.equals(role); }
    public boolean isBranchManager() { return ROLE_BRANCH_MANAGER.equals(role); }
    public boolean isBranchStaff() { return ROLE_BRANCH_STAFF.equals(role); }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Long getBranchId() { return branchId; }
    public void setBranchId(Long branchId) { this.branchId = branchId; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
