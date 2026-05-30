package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * Branch - map bang `branches` (chi nhanh rap). Soft-delete qua active.
 */
public class Branch {
    private long branchId;
    private String name;
    private String address;
    private String city;
    private String phone;
    private String email;
    private boolean active = true;
    private LocalDateTime createdAt;

    public Branch() {}

    public long getBranchId() { return branchId; }
    public void setBranchId(long branchId) { this.branchId = branchId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
