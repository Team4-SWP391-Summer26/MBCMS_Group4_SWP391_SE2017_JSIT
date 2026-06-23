package com.mbcms.dto;

public class UserStatsDTO {
    private int totalUsers;
    private int customersCount;
    private int branchManagersCount;
    private int branchStaffCount;
    private int adminsCount;

    public UserStatsDTO() {}

    public int getTotalUsers() { return totalUsers; }
    public void setTotalUsers(int totalUsers) { this.totalUsers = totalUsers; }

    public int getCustomersCount() { return customersCount; }
    public void setCustomersCount(int customersCount) { this.customersCount = customersCount; }

    public int getBranchManagersCount() { return branchManagersCount; }
    public void setBranchManagersCount(int branchManagersCount) { this.branchManagersCount = branchManagersCount; }

    public int getBranchStaffCount() { return branchStaffCount; }
    public void setBranchStaffCount(int branchStaffCount) { this.branchStaffCount = branchStaffCount; }

    public int getAdminsCount() { return adminsCount; }
    public void setAdminsCount(int adminsCount) { this.adminsCount = adminsCount; }
}
