package com.mbcms.model.report;

public class PaymentMixRow {
    private String method;
    private int count;
    private double percentage;

    public PaymentMixRow() {}

    public PaymentMixRow(String method, int count, double percentage) {
        this.method = method;
        this.count = count;
        this.percentage = percentage;
    }

    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }

    public int getCount() { return count; }
    public void setCount(int count) { this.count = count; }

    public double getPercentage() { return percentage; }
    public void setPercentage(double percentage) { this.percentage = percentage; }
}
