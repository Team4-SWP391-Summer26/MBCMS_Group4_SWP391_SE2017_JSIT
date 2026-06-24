package com.mbcms.service.impl;

import com.mbcms.dao.FoodDAO;
import com.mbcms.dao.impl.FoodDAOImpl;
import com.mbcms.model.FoodItem;
import com.mbcms.model.FoodOrderDetail;
import com.mbcms.service.FoodService;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public class FoodServiceImpl implements FoodService {

    private final FoodDAO foodDao = new FoodDAOImpl();

    @Override
    public List<FoodItem> getActiveFoodItems() {
        return foodDao.findAllActive();
    }

    @Override
    public List<FoodItem> getActiveFoodItemsByBranch(long branchId) {
        return foodDao.findActiveByBranch(branchId);
    }

    @Override
    public List<FoodItem> getActiveFoodItemsForShowtime(long showtimeId) {
        Long branchId = foodDao.findBranchIdByShowtimeId(showtimeId);
        if (branchId == null) {
            return java.util.Collections.emptyList();
        }
        return foodDao.findActiveByBranch(branchId);
    }

    @Override
    public FoodItem getFoodItemById(long foodId) {
        return foodDao.findById(foodId);
    }

    @Override
    public void saveFoodOrder(long bookingId, Map<Long, Integer> items, String status) {
        foodDao.saveFoodOrder(bookingId, items, status);
    }

    @Override
    public Map<FoodItem, Integer> getFoodItemsByBookingId(long bookingId) {
        return foodDao.findFoodItemsByBookingId(bookingId);
    }

    @Override
    public com.mbcms.model.FoodOrder getFoodOrderByBookingId(long bookingId) {
        return foodDao.findByBookingId(bookingId);
    }

    @Override
    public List<FoodOrderDetail> getFoodOrdersByBranch(long branchId) {
        return foodDao.findFoodOrdersByBranch(branchId);
    }

    @Override
    public boolean updateOrderStatus(long foodOrderId, String status) {
        return foodDao.updateOrderStatus(foodOrderId, status);
    }

    @Override
    public boolean updateOrderStatusByBooking(long bookingId, String status) {
        return foodDao.updateOrderStatusByBooking(bookingId, status);
    }

    // ── Branch menu management ───────────────────────────────────────

    @Override
    public List<FoodItem> getMenuByBranch(long branchId) {
        return foodDao.findAllByBranch(branchId);
    }

    @Override
    public boolean addItem(FoodItem item, long branchId) {
        if (item.getName() == null || item.getName().trim().isEmpty())
            throw new IllegalArgumentException("Ten mon khong duoc de trong.");
        if (item.getPrice() == null || item.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0)
            throw new IllegalArgumentException("Gia khong hop le.");
        if (item.getStock() < 0)
            throw new IllegalArgumentException("Ton kho khong duoc am.");
        item.setBranchId(branchId);
        return foodDao.insert(item);
    }

    @Override
    public boolean editItem(FoodItem item, long branchId) {
        FoodItem existing = foodDao.findById(item.getFoodId());
        if (existing == null || !Long.valueOf(branchId).equals(existing.getBranchId()))
            throw new IllegalArgumentException("Mon khong ton tai hoac khong thuoc chi nhanh nay.");
        if (item.getName() == null || item.getName().trim().isEmpty())
            throw new IllegalArgumentException("Ten mon khong duoc de trong.");
        if (item.getPrice() == null || item.getPrice().compareTo(java.math.BigDecimal.ZERO) < 0)
            throw new IllegalArgumentException("Gia khong hop le.");
        if (item.getStock() < 0)
            throw new IllegalArgumentException("Ton kho khong duoc am.");
        item.setBranchId(branchId);
        return foodDao.update(item);
    }

    @Override
    public boolean removeItem(long foodId, long branchId) {
        FoodItem existing = foodDao.findById(foodId);
        if (existing == null || !Long.valueOf(branchId).equals(existing.getBranchId()))
            throw new IllegalArgumentException("Mon khong ton tai hoac khong thuoc chi nhanh nay.");
        return foodDao.delete(foodId);
    }

    @Override
    public boolean updateStock(long foodId, int stock, long branchId) {
        if (stock < 0) throw new IllegalArgumentException("Ton kho khong duoc am.");
        FoodItem existing = foodDao.findById(foodId);
        if (existing == null || !Long.valueOf(branchId).equals(existing.getBranchId()))
            throw new IllegalArgumentException("Mon khong ton tai hoac khong thuoc chi nhanh nay.");
        return foodDao.updateStock(foodId, stock);
    }

    @Override
    public boolean toggleStatus(long foodId, boolean active, long branchId) {
        FoodItem existing = foodDao.findById(foodId);
        if (existing == null || !Long.valueOf(branchId).equals(existing.getBranchId()))
            throw new IllegalArgumentException("Mon khong ton tai hoac khong thuoc chi nhanh nay.");
        return foodDao.updateStatus(foodId, active);
    }
    @Override
    public void deleteOrderByBookingId(long bookingId) {
        foodDao.deleteOrderByBookingId(bookingId);
    }

    @Override
    public boolean belongsToBranch(long foodOrderId, long branchId) {
        Long orderBranchId = foodDao.findBranchIdByFoodOrderId(foodOrderId);
        return orderBranchId != null && orderBranchId == branchId;
    }

    @Override
    public BigDecimal computeValidatedFoodSubtotal(Map<Long, Integer> items) {
        if (items == null || items.isEmpty()) {
            return BigDecimal.ZERO;
        }
        BigDecimal total = BigDecimal.ZERO;
        for (Map.Entry<Long, Integer> entry : items.entrySet()) {
            int qty = entry.getValue() == null ? 0 : entry.getValue();
            if (qty <= 0) {
                continue;
            }
            qty = Math.max(1, Math.min(10, qty));
            FoodItem item = foodDao.findById(entry.getKey());
            if (item != null && item.isActive()) {
                total = total.add(item.getPrice().multiply(BigDecimal.valueOf(qty)));
            }
        }
        return total;
    }
}
