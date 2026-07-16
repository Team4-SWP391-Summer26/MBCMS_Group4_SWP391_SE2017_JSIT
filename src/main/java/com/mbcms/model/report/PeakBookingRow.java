package com.mbcms.model.report;

public class PeakBookingRow {
    private int hourOfDay;
    private int bookingsCount;

    public PeakBookingRow() {}

    public PeakBookingRow(int hourOfDay, int bookingsCount) {
        this.hourOfDay = hourOfDay;
        this.bookingsCount = bookingsCount;
    }

    public int getHourOfDay() { return hourOfDay; }
    public void setHourOfDay(int hourOfDay) { this.hourOfDay = hourOfDay; }

    public int getBookingsCount() { return bookingsCount; }
    public void setBookingsCount(int bookingsCount) { this.bookingsCount = bookingsCount; }
}
