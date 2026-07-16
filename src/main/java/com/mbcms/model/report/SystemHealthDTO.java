package com.mbcms.model.report;

public class SystemHealthDTO {
    private double bookingSuccessRate;
    private int pendingReviews;

    public SystemHealthDTO() {}

    public double getBookingSuccessRate() { return bookingSuccessRate; }
    public void setBookingSuccessRate(double bookingSuccessRate) { this.bookingSuccessRate = bookingSuccessRate; }

    public int getPendingReviews() { return pendingReviews; }
    public void setPendingReviews(int pendingReviews) { this.pendingReviews = pendingReviews; }
}
