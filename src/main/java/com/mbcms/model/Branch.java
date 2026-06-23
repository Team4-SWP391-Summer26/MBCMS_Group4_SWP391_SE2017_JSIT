package com.mbcms.model;

import java.time.LocalDateTime;
import java.time.LocalTime;

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
    private LocalTime openingTime;
    private LocalTime closingTime;

    // Transient statistics for admin dashboard/cinema management
    private int roomsCount;
    private int seatsCount;
    private int todayShowtimes;
    private double monthlyRevenue;
    private String managerName;

    public Branch() {
    }

    public long getBranchId() {
        return branchId;
    }

    public void setBranchId(long branchId) {
        this.branchId = branchId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalTime getOpeningTime() { return openingTime; }
    public void setOpeningTime(LocalTime openingTime) { this.openingTime = openingTime; }

    public LocalTime getClosingTime() { return closingTime; }
    public void setClosingTime(LocalTime closingTime) { this.closingTime = closingTime; }

    public int getRoomsCount() { return roomsCount; }
    public void setRoomsCount(int roomsCount) { this.roomsCount = roomsCount; }

    public int getSeatsCount() { return seatsCount; }
    public void setSeatsCount(int seatsCount) { this.seatsCount = seatsCount; }

    public int getTodayShowtimes() { return todayShowtimes; }
    public void setTodayShowtimes(int todayShowtimes) { this.todayShowtimes = todayShowtimes; }

    public double getMonthlyRevenue() { return monthlyRevenue; }
    public void setMonthlyRevenue(double monthlyRevenue) { this.monthlyRevenue = monthlyRevenue; }

    public String getManagerName() { return managerName; }
    public void setManagerName(String managerName) { this.managerName = managerName; }
    public void setCity(String city) {
        this.city = city;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

}
