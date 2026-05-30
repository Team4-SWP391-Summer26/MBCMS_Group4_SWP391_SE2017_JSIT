package com.mbcms.model;

import java.time.LocalDateTime;

/**
 * FoodOrder - map bang `food_orders` (1:0..1 voi booking).
 * status: PENDING -> PREPARING -> READY -> DELIVERED
 */
public class FoodOrder {

    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_PREPARING = "PREPARING";
    public static final String STATUS_READY = "READY";
    public static final String STATUS_DELIVERED = "DELIVERED";

    private long foodOrderId;
    private long bookingId;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime readyAt;
    private LocalDateTime deliveredAt;

    public FoodOrder() {}

    public long getFoodOrderId() { return foodOrderId; }
    public void setFoodOrderId(long foodOrderId) { this.foodOrderId = foodOrderId; }

    public long getBookingId() { return bookingId; }
    public void setBookingId(long bookingId) { this.bookingId = bookingId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getReadyAt() { return readyAt; }
    public void setReadyAt(LocalDateTime readyAt) { this.readyAt = readyAt; }

    public LocalDateTime getDeliveredAt() { return deliveredAt; }
    public void setDeliveredAt(LocalDateTime deliveredAt) { this.deliveredAt = deliveredAt; }
}
