package com.mbcms.controller.branch;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mbcms.model.FoodOrderDetail;
import com.mbcms.service.FoodService;
import com.mbcms.service.impl.FoodServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * StaffFoodOrderServlet handles concessions order fulfillment tracking console.
 * Mapped to /staff/food-orders
 */
@WebServlet("/staff/food-orders")
public class StaffFoodOrderServlet extends HttpServlet {

    private final FoodService foodService = new FoodServiceImpl();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Long branchId = (Long) req.getSession().getAttribute("currentBranchId");
        if (branchId == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        ConsoleSupport.ensureBranchName(req);

        List<FoodOrderDetail> orders = foodService.getFoodOrdersByBranch(branchId);
        req.setAttribute("orders", orders);

        req.getRequestDispatcher("/WEB-INF/views/branch/food-orders.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        Map<String, Object> result = new HashMap<>();

        try {
            Long branchId = (Long) req.getSession().getAttribute("currentBranchId");
            if (branchId == null) {
                resp.sendError(HttpServletResponse.SC_UNAUTHORIZED);
                return;
            }

            String action = req.getParameter("action");
            if ("updateStatus".equals(action)) {
                String orderIdParam = req.getParameter("foodOrderId");
                String status = req.getParameter("status");

                if (orderIdParam == null || status == null) {
                    throw new IllegalArgumentException("Missing foodOrderId or status parameter.");
                }

                long foodOrderId = Long.parseLong(orderIdParam.trim());
                boolean success = foodService.updateOrderStatus(foodOrderId, status.trim().toUpperCase());

                result.put("success", success);
                if (success) {
                    result.put("message", "Order status updated successfully.");
                } else {
                    result.put("message", "Failed to update order status.");
                }
            } else {
                throw new IllegalArgumentException("Invalid action.");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", e.getMessage());
        }

        mapper.writeValue(resp.getWriter(), result);
    }
}
