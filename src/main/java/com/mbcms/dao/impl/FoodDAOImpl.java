package com.mbcms.dao.impl;

import com.mbcms.dao.FoodDAO;
import com.mbcms.model.FoodItem;
import com.mbcms.model.FoodOrderDetail;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class FoodDAOImpl extends BaseDAO implements FoodDAO {

    @Override
    public List<FoodItem> findAllActive() {
        String sql = "SELECT * FROM dbo.food_items WHERE active = 1 ORDER BY category DESC, name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<FoodItem> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                FoodItem item = new FoodItem();
                item.setFoodId(rs.getLong("food_id"));
                item.setName(rs.getString("name"));
                item.setDescription(rs.getString("description"));
                item.setPrice(rs.getBigDecimal("price"));
                item.setCategory(rs.getString("category"));
                item.setImageUrl(rs.getString("image_url"));
                item.setActive(rs.getBoolean("active"));
                list.add(item);
            }
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findAllActive concessions: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public FoodItem findById(long foodId) {
        String sql = "SELECT * FROM dbo.food_items WHERE food_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, foodId);
            rs = ps.executeQuery();
            if (rs.next()) {
                FoodItem item = new FoodItem();
                item.setFoodId(rs.getLong("food_id"));
                item.setName(rs.getString("name"));
                item.setDescription(rs.getString("description"));
                item.setPrice(rs.getBigDecimal("price"));
                item.setCategory(rs.getString("category"));
                item.setImageUrl(rs.getString("image_url"));
                item.setActive(rs.getBoolean("active"));
                return item;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findById concession: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public void saveFoodOrder(long bookingId, Map<Long, Integer> items, String status) {
        if (items == null || items.isEmpty()) {
            // Nếu lưu rỗng thì xoá sạch order nếu có (để dọn rác)
            deleteOrderIfExists(bookingId);
            return;
        }

        Connection conn = null;
        PreparedStatement psGetOrder = null;
        PreparedStatement psInsertOrder = null;
        PreparedStatement psDeleteItems = null;
        PreparedStatement psInsertItem = null;
        ResultSet rs = null;

        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra xem order đã tồn tại chưa
            String getOrderSql = "SELECT food_order_id FROM dbo.food_orders WHERE booking_id = ?";
            psGetOrder = conn.prepareStatement(getOrderSql);
            psGetOrder.setLong(1, bookingId);
            rs = psGetOrder.executeQuery();

            long foodOrderId = 0;
            if (rs.next()) {
                foodOrderId = rs.getLong("food_order_id");
                // Cập nhật trạng thái
                String updateOrderSql = "UPDATE dbo.food_orders SET status = ? WHERE food_order_id = ?";
                try (PreparedStatement psUpdateOrder = conn.prepareStatement(updateOrderSql)) {
                    psUpdateOrder.setString(1, status);
                    psUpdateOrder.setLong(2, foodOrderId);
                    psUpdateOrder.executeUpdate();
                }
            } else {
                // Tạo mới order
                String insertOrderSql = "INSERT INTO dbo.food_orders (booking_id, status, created_at) VALUES (?, ?, SYSUTCDATETIME())";
                psInsertOrder = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS);
                psInsertOrder.setLong(1, bookingId);
                psInsertOrder.setString(2, status);
                psInsertOrder.executeUpdate();
                try (ResultSet genKeys = psInsertOrder.getGeneratedKeys()) {
                    if (genKeys.next()) {
                        foodOrderId = genKeys.getLong(1);
                    } else {
                        throw new SQLException("Không lấy được food_order_id được sinh ra.");
                    }
                }
            }

            // 2. Xoá các items cũ
            String deleteItemsSql = "DELETE FROM dbo.booking_food_items WHERE food_order_id = ?";
            psDeleteItems = conn.prepareStatement(deleteItemsSql);
            psDeleteItems.setLong(1, foodOrderId);
            psDeleteItems.executeUpdate();

            // 3. Batch chèn các items mới
            String insertItemSql = "INSERT INTO dbo.booking_food_items (food_order_id, food_id, quantity) VALUES (?, ?, ?)";
            psInsertItem = conn.prepareStatement(insertItemSql);
            for (Map.Entry<Long, Integer> entry : items.entrySet()) {
                psInsertItem.setLong(1, foodOrderId);
                psInsertItem.setLong(2, entry.getKey());
                psInsertItem.setInt(3, entry.getValue());
                psInsertItem.addBatch();
            }
            psInsertItem.executeBatch();

            conn.commit();
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ignored) {
                }
            }
            throw new RuntimeException("Lỗi saveFoodOrder: " + e.getMessage(), e);
        } finally {
            closeAll(rs, psGetOrder, null);
            closeAll(psInsertOrder, null);
            closeAll(psDeleteItems, null);
            closeAll(psInsertItem, conn);
        }
    }

    private void deleteOrderIfExists(long bookingId) {
        String sql = "DELETE FROM dbo.food_orders WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            ps.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi deleteOrderIfExists: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public Map<FoodItem, Integer> findFoodItemsByBookingId(long bookingId) {
        String sql = "SELECT fi.*, bfi.quantity " +
                "FROM dbo.booking_food_items bfi " +
                "JOIN dbo.food_orders fo ON fo.food_order_id = bfi.food_order_id " +
                "JOIN dbo.food_items fi ON fi.food_id = bfi.food_id " +
                "WHERE fo.booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Map<FoodItem, Integer> map = new LinkedHashMap<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            while (rs.next()) {
                FoodItem item = new FoodItem();
                item.setFoodId(rs.getLong("food_id"));
                item.setName(rs.getString("name"));
                item.setDescription(rs.getString("description"));
                item.setPrice(rs.getBigDecimal("price"));
                item.setCategory(rs.getString("category"));
                item.setImageUrl(rs.getString("image_url"));
                item.setActive(rs.getBoolean("active"));

                int qty = rs.getInt("quantity");
                map.put(item, qty);
            }
            return map;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findFoodItemsByBookingId: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public com.mbcms.model.FoodOrder findByBookingId(long bookingId) {
        String sql = "SELECT * FROM dbo.food_orders WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, bookingId);
            rs = ps.executeQuery();
            if (rs.next()) {
                com.mbcms.model.FoodOrder order = new com.mbcms.model.FoodOrder();
                order.setFoodOrderId(rs.getLong("food_order_id"));
                order.setBookingId(rs.getLong("booking_id"));
                order.setStatus(rs.getString("status"));
                Timestamp created = rs.getTimestamp("created_at");
                order.setCreatedAt(created != null ? created.toLocalDateTime() : null);
                Timestamp ready = rs.getTimestamp("ready_at");
                order.setReadyAt(ready != null ? ready.toLocalDateTime() : null);
                Timestamp deliv = rs.getTimestamp("delivered_at");
                order.setDeliveredAt(deliv != null ? deliv.toLocalDateTime() : null);
                return order;
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findByBookingId: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public List<FoodOrderDetail> findFoodOrdersByBranch(long branchId) {
        String sql = "SELECT fo.food_order_id, fo.booking_id, fo.status, fo.created_at, fo.ready_at, fo.delivered_at, "
                +
                "       b.booking_code, s.start_time, m.title AS movie_title, r.name AS room_name, " +
                "       c.full_name AS customer_name, fi.name AS food_name, bfi.quantity " +
                "FROM dbo.food_orders fo " +
                "JOIN dbo.bookings b ON b.booking_id = fo.booking_id " +
                "JOIN dbo.showtimes s ON s.showtime_id = b.showtime_id " +
                "JOIN dbo.rooms r ON r.room_id = s.room_id " +
                "JOIN dbo.movies m ON m.movie_id = s.movie_id " +
                "LEFT JOIN dbo.customers c ON c.username = b.customer_username " +
                "JOIN dbo.booking_food_items bfi ON bfi.food_order_id = fo.food_order_id " +
                "JOIN dbo.food_items fi ON fi.food_id = bfi.food_id " +
                "WHERE r.branch_id = ? AND b.status <> 'CANCELLED' " +
                "ORDER BY fo.created_at DESC, fo.food_order_id";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Map<Long, FoodOrderDetail> orderMap = new LinkedHashMap<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();
            while (rs.next()) {
                long oid = rs.getLong("food_order_id");
                FoodOrderDetail detail = orderMap.get(oid);
                if (detail == null) {
                    detail = new FoodOrderDetail();
                    detail.setFoodOrderId(oid);
                    detail.setBookingId(rs.getLong("booking_id"));
                    detail.setBookingCode(rs.getString("booking_code"));
                    detail.setStatus(rs.getString("status"));
                    detail.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());

                    Timestamp ready = rs.getTimestamp("ready_at");
                    detail.setReadyAt(ready != null ? ready.toLocalDateTime() : null);

                    Timestamp deliv = rs.getTimestamp("delivered_at");
                    detail.setDeliveredAt(deliv != null ? deliv.toLocalDateTime() : null);

                    String custName = rs.getString("customer_name");
                    detail.setCustomerName(
                            custName != null && !custName.trim().isEmpty() ? custName : "Guest (Walk-in)");
                    detail.setMovieTitle(rs.getString("movie_title"));
                    detail.setRoomName(rs.getString("room_name"));

                    Timestamp stTime = rs.getTimestamp("start_time");
                    if (stTime != null) {
                        detail.setStartTime(stTime.toLocalDateTime()
                                .format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm")));
                    }
                    orderMap.put(oid, detail);
                }
                detail.addItem(rs.getString("food_name"), rs.getInt("quantity"));
            }
            return new ArrayList<>(orderMap.values());
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findFoodOrdersByBranch: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean updateOrderStatus(long foodOrderId, String status) {
        if ("PREPARING".equalsIgnoreCase(status)) {
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = getConnection();
                conn.setAutoCommit(false);

                // 1. Get food order info
                long bookingId = 0;
                String currentFoodStatus = null;
                String getOrderSql = "SELECT booking_id, status FROM dbo.food_orders WHERE food_order_id = ?";
                ps = conn.prepareStatement(getOrderSql);
                ps.setLong(1, foodOrderId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    bookingId = rs.getLong("booking_id");
                    currentFoodStatus = rs.getString("status");
                }
                rs.close();
                ps.close();

                if (bookingId == 0) {
                    conn.rollback();
                    return false;
                }

                // 2. Get booking info
                String bookingStatus = null;
                String customerUsername = null;
                BigDecimal totalAmount = BigDecimal.ZERO;
                Long promoId = null;
                long showtimeId = 0;
                Timestamp createdAt = null;

                String getBookingSql = "SELECT status, customer_username, total_amount, promo_id, showtime_id, created_at FROM dbo.bookings WHERE booking_id = ?";
                ps = conn.prepareStatement(getBookingSql);
                ps.setLong(1, bookingId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    bookingStatus = rs.getString("status");
                    customerUsername = rs.getString("customer_username");
                    totalAmount = rs.getBigDecimal("total_amount");
                    long pId = rs.getLong("promo_id");
                    if (!rs.wasNull()) {
                        promoId = pId;
                    }
                    showtimeId = rs.getLong("showtime_id");
                    createdAt = rs.getTimestamp("created_at");
                }
                rs.close();
                ps.close();

                if (bookingStatus == null) {
                    conn.rollback();
                    return false;
                }

                if ("PENDING".equals(bookingStatus)) {
                    // Check expiry (10 minutes)
                    if (createdAt != null) {
                        long elapsedMillis = System.currentTimeMillis() - (createdAt.getTime());
                        if (elapsedMillis >= 600 * 1000) {
                            conn.rollback();
                            throw new IllegalStateException(
                                    "Hóa đơn đã hết hạn giữ vé (10 phút). Không thể thanh toán.");
                        }
                    }

                    // Confirm Booking
                    String confirmBookingSql = "UPDATE dbo.bookings SET status = 'CONFIRMED' WHERE booking_id = ? AND status = 'PENDING'";
                    ps = conn.prepareStatement(confirmBookingSql);
                    ps.setLong(1, bookingId);
                    int bkUpdated = ps.executeUpdate();
                    ps.close();
                    if (bkUpdated == 0) {
                        conn.rollback();
                        return false;
                    }

                    // Record CASH payment
                    boolean paymentExists = false;
                    String checkPaySql = "SELECT 1 FROM dbo.payments WHERE booking_id = ?";
                    ps = conn.prepareStatement(checkPaySql);
                    ps.setLong(1, bookingId);
                    rs = ps.executeQuery();
                    if (rs.next()) {
                        paymentExists = true;
                    }
                    rs.close();
                    ps.close();

                    if (paymentExists) {
                        String updatePaymentSql = "UPDATE dbo.payments SET method = 'CASH', amount = ?, status = 'SUCCESS', paid_at = SYSUTCDATETIME() WHERE booking_id = ?";
                        ps = conn.prepareStatement(updatePaymentSql);
                        ps.setBigDecimal(1, totalAmount);
                        ps.setLong(2, bookingId);
                        ps.executeUpdate();
                        ps.close();
                    } else {
                        String insertPaymentSql = "INSERT INTO dbo.payments (booking_id, method, amount, status, transaction_ref, paid_at) VALUES (?, 'CASH', ?, 'SUCCESS', NULL, SYSUTCDATETIME())";
                        ps = conn.prepareStatement(insertPaymentSql);
                        ps.setLong(1, bookingId);
                        ps.setBigDecimal(2, totalAmount);
                        ps.executeUpdate();
                        ps.close();
                    }

                    // Increment promo used_count if any
                    if (promoId != null) {
                        String promoSql = "UPDATE dbo.promotions SET used_count = used_count + 1 WHERE promo_id = ?";
                        ps = conn.prepareStatement(promoSql);
                        ps.setLong(1, promoId);
                        ps.executeUpdate();
                        ps.close();
                    }

                    // Load seat IDs for WebSocket notification
                    List<Long> seatIds = new ArrayList<>();
                    String getSeatsSql = "SELECT seat_id FROM dbo.booking_seats WHERE booking_id = ?";
                    ps = conn.prepareStatement(getSeatsSql);
                    ps.setLong(1, bookingId);
                    rs = ps.executeQuery();
                    while (rs.next()) {
                        seatIds.add(rs.getLong("seat_id"));
                    }
                    rs.close();
                    ps.close();

                    // Send WebSocket hard lock notification
                    if (!seatIds.isEmpty()) {
                        try {
                            com.mbcms.ws.SeatWebSocketServer.notifyHardLock(showtimeId, seatIds, "staff");
                        } catch (Exception ignore) {
                        }
                    }

                    // Send notification
                    try {
                        String insertNotificationSql = "INSERT INTO dbo.notifications (customer_username, title, content, type, reference_id, is_read, created_at) VALUES (?, ?, ?, ?, ?, 0, SYSUTCDATETIME())";
                        ps = conn.prepareStatement(insertNotificationSql);
                        ps.setString(1, customerUsername);
                        ps.setString(2, "Payment successful");
                        ps.setString(3, "Your counter cash payment for booking has been confirmed.");
                        ps.setString(4, "PAYMENT");
                        ps.setLong(5, bookingId);
                        ps.executeUpdate();
                        ps.close();
                    } catch (Exception ignore) {
                    }

                } else if ("CANCELLED".equals(bookingStatus)) {
                    conn.rollback();
                    throw new IllegalStateException("Đơn đặt vé này đã bị hủy. Không thể chế biến đồ ăn.");
                }

                // Finally update the food order status to PREPARING
                String updateOrderSql = "UPDATE dbo.food_orders SET status = 'PREPARING' WHERE food_order_id = ?";
                ps = conn.prepareStatement(updateOrderSql);
                ps.setLong(1, foodOrderId);
                int rows = ps.executeUpdate();
                ps.close();

                conn.commit();
                return rows > 0;

            } catch (SQLException e) {
                if (conn != null) {
                    try {
                        conn.rollback();
                    } catch (SQLException ignored) {
                    }
                }
                throw new RuntimeException("Lỗi updateOrderStatus (PREPARING): " + e.getMessage(), e);
            } finally {
                if (rs != null)
                    try {
                        rs.close();
                    } catch (SQLException ignored) {
                    }
                if (ps != null)
                    try {
                        ps.close();
                    } catch (SQLException ignored) {
                    }
                if (conn != null) {
                    try {
                        conn.setAutoCommit(true);
                    } catch (SQLException ignored) {
                    }
                    closeAll(null, null, conn);
                }
            }
        }

        // Default behavior for other statuses
        String sql;
        if ("READY".equals(status)) {
            sql = "UPDATE dbo.food_orders SET status = ?, ready_at = SYSUTCDATETIME() WHERE food_order_id = ?";
        } else if ("DELIVERED".equals(status)) {
            sql = "UPDATE dbo.food_orders SET status = ?, delivered_at = SYSUTCDATETIME() WHERE food_order_id = ?";
        } else {
            sql = "UPDATE dbo.food_orders SET status = ? WHERE food_order_id = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setLong(2, foodOrderId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi updateOrderStatus: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateOrderStatusByBooking(long bookingId, String status) {
        String sql = "UPDATE dbo.food_orders SET status = ? WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setLong(2, bookingId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi updateOrderStatusByBooking: " + e.getMessage(), e);
        } finally {
            closeAll(ps, conn);
        }
    }

    @Override
    public boolean updateOrderStatusByBooking(Connection conn, long bookingId, String status) {
        String sql = "UPDATE dbo.food_orders SET status = ? WHERE booking_id = ?";
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(sql);
            ps.setString(1, status);
            ps.setLong(2, bookingId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi updateOrderStatusByBooking(conn): " + e.getMessage(), e);
        } finally {
            if (ps != null) {
                try {
                    ps.close();
                } catch (SQLException ignored) {
                }
            }
        }
    }
}
