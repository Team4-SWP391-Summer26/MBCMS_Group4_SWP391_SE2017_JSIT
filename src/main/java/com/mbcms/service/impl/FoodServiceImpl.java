package com.mbcms.service.impl;

import com.mbcms.dao.FoodDAO;
import com.mbcms.dao.impl.FoodDAOImpl;
import com.mbcms.model.FoodItem;
import com.mbcms.model.FoodOrderDetail;
import com.mbcms.service.FoodService;

import java.util.List;
import java.util.Map;

public class FoodServiceImpl implements FoodService {

    private final FoodDAO foodDao = new FoodDAOImpl();

    @Override
    public List<FoodItem> getActiveFoodItems() {
        return foodDao.findAllActive();
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
}
