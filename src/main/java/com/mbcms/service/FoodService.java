package com.mbcms.service;

import com.mbcms.model.FoodItem;
import com.mbcms.model.FoodOrderDetail;
import java.util.List;
import java.util.Map;

public interface FoodService {
    List<FoodItem> getActiveFoodItems();
    FoodItem getFoodItemById(long foodId);
    void saveFoodOrder(long bookingId, Map<Long, Integer> items, String status);
    Map<FoodItem, Integer> getFoodItemsByBookingId(long bookingId);
    com.mbcms.model.FoodOrder getFoodOrderByBookingId(long bookingId);
    List<FoodOrderDetail> getFoodOrdersByBranch(long branchId);
    boolean updateOrderStatus(long foodOrderId, String status);
    boolean updateOrderStatusByBooking(long bookingId, String status);
    // ── Branch menu management ───────────────────────────────────────
    List<FoodItem> getMenuByBranch(long branchId);
    boolean addItem(FoodItem item, long branchId);
    boolean editItem(FoodItem item, long branchId);
    boolean removeItem(long foodId, long branchId);
    boolean updateStock(long foodId, int stock, long branchId);
    boolean toggleStatus(long foodId, boolean active, long branchId);
}