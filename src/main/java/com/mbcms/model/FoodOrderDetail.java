package com.mbcms.model;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * FoodOrderDetail - View model representing a concessions order with detailed items
 * and ticket context for display and tracking.
 */
public class FoodOrderDetail {
    private long foodOrderId;
    private long bookingId;
    private String bookingCode;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime readyAt;
    private LocalDateTime deliveredAt;
    
    private String customerName;
    private String movieTitle;
    private String roomName;
    private String startTime;
    
    // Map of food item name to its ordered quantity
    private Map<String, Integer> items = new HashMap<>();
    
    public FoodOrderDetail() {}

    public long getFoodOrderId() { return foodOrderId; }
    public void setFoodOrderId(long foodOrderId) { this.foodOrderId = foodOrderId; }

    public long getBookingId() { return bookingId; }
    public void setBookingId(long bookingId) { this.bookingId = bookingId; }

    public String getBookingCode() { return bookingCode; }
    public void setBookingCode(String bookingCode) { this.bookingCode = bookingCode; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getReadyAt() { return readyAt; }
    public void setReadyAt(LocalDateTime readyAt) { this.readyAt = readyAt; }

    public LocalDateTime getDeliveredAt() { return deliveredAt; }
    public void setDeliveredAt(LocalDateTime deliveredAt) { this.deliveredAt = deliveredAt; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getMovieTitle() { return movieTitle; }
    public void setMovieTitle(String movieTitle) { this.movieTitle = movieTitle; }

    public String getRoomName() { return roomName; }
    public void setRoomName(String roomName) { this.roomName = roomName; }

    public String getStartTime() { return startTime; }
    public void setStartTime(String startTime) { this.startTime = startTime; }

    public Map<String, Integer> getItems() { return items; }
    public void setItems(Map<String, Integer> items) { this.items = items; }
    
    public void addItem(String name, int qty) {
        this.items.put(name, qty);
    }
}
