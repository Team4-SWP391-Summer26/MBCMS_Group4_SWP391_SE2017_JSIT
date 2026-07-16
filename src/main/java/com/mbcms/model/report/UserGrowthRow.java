package com.mbcms.model.report;

import java.time.LocalDate;

public class UserGrowthRow {
    private LocalDate date;
    private int newUsersCount;

    public UserGrowthRow() {}

    public UserGrowthRow(LocalDate date, int newUsersCount) {
        this.date = date;
        this.newUsersCount = newUsersCount;
    }

    public LocalDate getDate() { return date; }
    public void setDate(LocalDate date) { this.date = date; }

    public int getNewUsersCount() { return newUsersCount; }
    public void setNewUsersCount(int newUsersCount) { this.newUsersCount = newUsersCount; }
}
