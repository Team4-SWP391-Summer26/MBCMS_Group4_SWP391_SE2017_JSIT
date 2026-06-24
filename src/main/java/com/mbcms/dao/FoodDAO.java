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
    /** Branch of the showtime linked to this food order; null if order not found. */
    Long findBranchIdByFoodOrderId(long foodOrderId);
    /** Branch of a showtime (showtime -> room -> branch); null if not found. */
    Long findBranchIdByShowtimeId(long showtimeId);
    /** Active items of one branch only (customer-facing menu). */
    List<FoodItem> findActiveByBranch(long branchId);
    boolean updateOrderStatusByBooking(long bookingId, String status);
    boolean updateOrderStatusByBooking(Connection conn, long bookingId, String status);
    // ── Branch menu management ───────────────────────────────────────
    /** Lay tat ca mon (ca inactive) cua 1 branch. */
    List<FoodItem> findAllByBranch(long branchId);

    /** Them mon moi. */
    boolean insert(FoodItem item);

    /** Cap nhat thong tin / gia mon. */
    boolean update(FoodItem item);

    /** Cap nhat ton kho. */
    boolean updateStock(long foodId, int stock);

    /** Bat/tat hien thi. */
    boolean updateStatus(long foodId, boolean active);

    /** Xoa vinh vien. */
    boolean delete(long foodId);
    
    void deleteOrderByBookingId(long bookingId);
}

