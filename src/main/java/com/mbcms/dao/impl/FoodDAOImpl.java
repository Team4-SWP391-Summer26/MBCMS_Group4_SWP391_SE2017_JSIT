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
                return mapRow(rs);
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

            // Chi nhanh cua booking (booking -> showtime -> room -> branch).
            // Moi mon them vao phai thuoc dung chi nhanh nay (chong chen mon cua chi nhanh khac).
            Long bookingBranchId = findBranchIdByBookingId(conn, bookingId);

            // 3. Batch chèn các items mới
            String insertItemSql = "INSERT INTO dbo.booking_food_items (food_order_id, food_id, quantity) VALUES (?, ?, ?)";
            psInsertItem = conn.prepareStatement(insertItemSql);
            for (Map.Entry<Long, Integer> entry : items.entrySet()) {
                FoodItem food = findById(entry.getKey());
                if (food == null) {
                    throw new IllegalArgumentException("Food item not found: " + entry.getKey());
                }
                if (!food.isActive()) {
                    throw new IllegalArgumentException("Food item is not available: " + food.getName());
                }
                if (bookingBranchId == null
                        || food.getBranchId() == null
                        || !bookingBranchId.equals(food.getBranchId())) {
                    throw new IllegalArgumentException(
                            "Món \"" + food.getName() + "\" không thuộc chi nhánh của suất chiếu này.");
                }
                int qty = entry.getValue() == null ? 0 : entry.getValue();
                qty = Math.max(1, Math.min(10, qty));
                psInsertItem.setLong(1, foodOrderId);
                psInsertItem.setLong(2, entry.getKey());
                psInsertItem.setInt(3, qty);
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
        deleteOrderByBookingId(bookingId);
    }

    @Override
    public void deleteOrderByBookingId(long bookingId) {
        String deleteItems = "DELETE FROM dbo.booking_food_items WHERE food_order_id IN "
                + "(SELECT food_order_id FROM dbo.food_orders WHERE booking_id = ?)";
        String deleteOrder = "DELETE FROM dbo.food_orders WHERE booking_id = ?";
        Connection conn = null;
        PreparedStatement psItems = null;
        PreparedStatement psOrder = null;
        try {
            conn = getConnection();
            psItems = conn.prepareStatement(deleteItems);
            psItems.setLong(1, bookingId);
            psItems.executeUpdate();
            psOrder = conn.prepareStatement(deleteOrder);
            psOrder.setLong(1, bookingId);
            psOrder.executeUpdate();
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi deleteOrderByBookingId: " + e.getMessage(), e);
        } finally {
            closeAll(psItems, null);
            closeAll(psOrder, conn);
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
    public Long findBranchIdByFoodOrderId(long foodOrderId) {
        String sql =
                "SELECT r.branch_id FROM dbo.food_orders fo "
                + "JOIN dbo.bookings b ON b.booking_id = fo.booking_id "
                + "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id "
                + "JOIN dbo.rooms r ON r.room_id = st.room_id "
                + "WHERE fo.food_order_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, foodOrderId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getLong("branch_id");
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findBranchIdByFoodOrderId: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    /** Chi nhanh cua booking (booking -> showtime -> room -> branch); null neu khong tim thay. */
    private Long findBranchIdByBookingId(Connection conn, long bookingId) throws SQLException {
        String sql =
                "SELECT r.branch_id FROM dbo.bookings b "
                + "JOIN dbo.showtimes st ON st.showtime_id = b.showtime_id "
                + "JOIN dbo.rooms r ON r.room_id = st.room_id "
                + "WHERE b.booking_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("branch_id");
                }
                return null;
            }
        }
    }

    @Override
    public Long findBranchIdByShowtimeId(long showtimeId) {
        String sql =
                "SELECT r.branch_id FROM dbo.showtimes st "
                + "JOIN dbo.rooms r ON r.room_id = st.room_id "
                + "WHERE st.showtime_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, showtimeId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getLong("branch_id");
            }
            return null;
        } catch (SQLException e) {
            throw new RuntimeException("Lỗi findBranchIdByShowtimeId: " + e.getMessage(), e);
        } finally {
            closeAll(rs, ps, conn);
        }
    }

    @Override
    public boolean updateOrderStatus(long foodOrderId, String status) {
        String normalized = (status == null) ? "" : status.trim().toUpperCase();

        // Phuc vu mon (PREPARING/READY/DELIVERED) chi hop le khi ve da thanh toan
        // (CONFIRMED/USED). Chan bypass tu booking PENDING (chua tra tien) / CANCELLED.
        if ("PREPARING".equals(normalized)
                || "READY".equals(normalized)
                || "DELIVERED".equals(normalized)) {
            String bookingStatus = null;
            String getBookingSql =
                    "SELECT b.status FROM dbo.food_orders fo "
                    + "JOIN dbo.bookings b ON b.booking_id = fo.booking_id "
                    + "WHERE fo.food_order_id = ?";
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = getConnection();
                ps = conn.prepareStatement(getBookingSql);
                ps.setLong(1, foodOrderId);
                rs = ps.executeQuery();
                if (rs.next()) {
                    bookingStatus = rs.getString("status");
                }
            } catch (SQLException e) {
                throw new RuntimeException("Lỗi updateOrderStatus (kiem tra booking): " + e.getMessage(), e);
            } finally {
                closeAll(rs, ps, conn);
            }

            if (bookingStatus == null) {
                return false;
            }
            if ("CANCELLED".equals(bookingStatus)) {
                throw new IllegalStateException("Đơn đặt vé này đã bị hủy. Không thể phục vụ đồ ăn.");
            }
            if ("PENDING".equals(bookingStatus)) {
                throw new IllegalStateException(
                        "Vé chưa thanh toán. Không thể phục vụ đồ ăn cho booking PENDING.");
            }
            if (!"CONFIRMED".equals(bookingStatus) && !"USED".equals(bookingStatus)) {
                throw new IllegalStateException(
                        "Trạng thái booking không hợp lệ để phục vụ đồ ăn: " + bookingStatus);
            }
        }

        String sql;
        if ("READY".equals(normalized)) {
            sql = "UPDATE dbo.food_orders SET status = ?, ready_at = SYSUTCDATETIME() WHERE food_order_id = ?";
        } else if ("DELIVERED".equals(normalized)) {
            sql = "UPDATE dbo.food_orders SET status = ?, delivered_at = SYSUTCDATETIME() WHERE food_order_id = ?";
        } else {
            sql = "UPDATE dbo.food_orders SET status = ? WHERE food_order_id = ?";
        }
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, normalized);
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

    // ── Branch menu management ───────────────────────────────────────

    private FoodItem mapRow(ResultSet rs) throws java.sql.SQLException {
        FoodItem item = new FoodItem();
        item.setFoodId(rs.getLong("food_id"));
        item.setName(rs.getString("name"));
        item.setDescription(rs.getString("description"));
        item.setPrice(rs.getBigDecimal("price"));
        item.setCategory(rs.getString("category"));
        item.setImageUrl(rs.getString("image_url"));
        item.setActive(rs.getBoolean("active"));
        long branchId = rs.getLong("branch_id");
        item.setBranchId(rs.wasNull() ? null : branchId);
        item.setStock(rs.getInt("stock"));
        return item;
    }

    @Override
    public List<FoodItem> findActiveByBranch(long branchId) {
        String sql = "SELECT * FROM dbo.food_items WHERE active = 1 AND branch_id = ? ORDER BY category DESC, name ASC";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<FoodItem> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi findActiveByBranch: " + e.getMessage(), e);
        } finally { closeAll(rs, ps, conn); }
    }

    @Override
    public List<FoodItem> findAllByBranch(long branchId) {
        String sql = "SELECT * FROM dbo.food_items WHERE branch_id = ? ORDER BY category, name";
        Connection conn = null; PreparedStatement ps = null; ResultSet rs = null;
        List<FoodItem> list = new ArrayList<>();
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, branchId);
            rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
            return list;
        } catch (SQLException e) {
            throw new RuntimeException("Loi findAllByBranch: " + e.getMessage(), e);
        } finally { closeAll(rs, ps, conn); }
    }

    @Override
    public boolean insert(FoodItem item) {
        String sql = "INSERT INTO dbo.food_items (name, description, price, category, image_url, active, branch_id, stock) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setBigDecimal(3, item.getPrice());
            ps.setString(4, item.getCategory());
            ps.setString(5, item.getImageUrl());
            ps.setBoolean(6, item.isActive());
            if (item.getBranchId() != null) ps.setLong(7, item.getBranchId());
            else ps.setNull(7, java.sql.Types.BIGINT);
            ps.setInt(8, item.getStock());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi insert food_item: " + e.getMessage(), e);
        } finally { closeAll(ps, conn); }
    }

    @Override
    public boolean update(FoodItem item) {
        String sql = "UPDATE dbo.food_items SET name=?, description=?, price=?, category=?, image_url=?, active=?, stock=? "
                   + "WHERE food_id=? AND branch_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, item.getName());
            ps.setString(2, item.getDescription());
            ps.setBigDecimal(3, item.getPrice());
            ps.setString(4, item.getCategory());
            ps.setString(5, item.getImageUrl());
            ps.setBoolean(6, item.isActive());
            ps.setInt(7, item.getStock());
            ps.setLong(8, item.getFoodId());
            ps.setLong(9, item.getBranchId());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi update food_item: " + e.getMessage(), e);
        } finally { closeAll(ps, conn); }
    }

    @Override
    public boolean updateStock(long foodId, int stock) {
        String sql = "UPDATE dbo.food_items SET stock=? WHERE food_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, stock);
            ps.setLong(2, foodId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateStock: " + e.getMessage(), e);
        } finally { closeAll(ps, conn); }
    }

    @Override
    public boolean updateStatus(long foodId, boolean active) {
        String sql = "UPDATE dbo.food_items SET active=? WHERE food_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setLong(2, foodId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi updateStatus food_item: " + e.getMessage(), e);
        } finally { closeAll(ps, conn); }
    }

    @Override
    public boolean delete(long foodId) {
        String sql = "DELETE FROM dbo.food_items WHERE food_id=?";
        Connection conn = null; PreparedStatement ps = null;
        try {
            conn = getConnection();
            ps = conn.prepareStatement(sql);
            ps.setLong(1, foodId);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            throw new RuntimeException("Loi delete food_item: " + e.getMessage(), e);
        } finally { closeAll(ps, conn); }
    }
}