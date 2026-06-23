package com.mbcms.dao;

import com.mbcms.model.FoodItem;
import com.mbcms.model.FoodOrderDetail;
import java.sql.Connection;
import java.util.List;
import java.util.Map;

public interface FoodDAO {
    List<FoodItem> findAllActive();
    FoodItem findById(long foodId);
    void saveFoodOrder(long bookingId, Map<Long, Integer> items, String status);
    Map<FoodItem, Integer> findFoodItemsByBookingId(long bookingId);
    com.mbcms.model.FoodOrder findByBookingId(long bookingId);
    List<FoodOrderDetail> findFoodOrdersByBranch(long branchId);
    boolean updateOrderStatus(long foodOrderId, String status);
    boolean updateOrderStatusByBooking(long bookingId, String status);
    boolean updateOrderStatusByBooking(Connection conn, long bookingId, String status);
}
