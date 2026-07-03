package com.mbcms.controller.branch;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.model.Promotion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

/**
 * PromoValidateServlet - Kiểm tra và tính toán mã giảm giá qua AJAX. Mapped:
 * /staff/promo-validate
 */
@WebServlet("/staff/promo-validate")
public class PromoValidateServlet extends HttpServlet {

    private final PromotionDAO promotionDAO = new PromotionDAOImpl();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json;charset=UTF-8");
        String code = req.getParameter("code");
        String subtotalStr = req.getParameter("subtotal");

        Map<String, Object> result = new HashMap<>();

        if (code == null || code.trim().isEmpty() || subtotalStr == null || subtotalStr.trim().isEmpty()) {
            result.put("valid", false);
            result.put("message", "Promo code and subtotal are required.");
            mapper.writeValue(resp.getWriter(), result);
            return;
        }

        BigDecimal subtotal;
        try {
            subtotal = new BigDecimal(subtotalStr.trim());
        } catch (NumberFormatException e) {
            result.put("valid", false);
            result.put("message", "Subtotal must be a valid number.");
            mapper.writeValue(resp.getWriter(), result);
            return;
        }

        jakarta.servlet.http.HttpSession session = req.getSession(false);
        Long branchId = session != null ? (Long) session.getAttribute("currentBranchId") : null;

        try {
            Promotion promo = promotionDAO.findByCode(code.trim().toUpperCase());
            if (promo == null) {
                result.put("valid", false);
                result.put("message", "Promo code does not exist.");
            } else if (promo.getBranchId() != null && (branchId == null || !promo.getBranchId().equals(branchId))) {
                result.put("valid", false);
                result.put("message", "Promo code is not available for this branch.");
            } else if (!promo.isActive() || !"Active".equals(promo.getStatus())) {
                result.put("valid", false);
                result.put("message", "Promo code is inactive or expired.");
            } else if (promo.getMaxUses() != null && promo.getUsedCount() >= promo.getMaxUses()) {
                result.put("valid", false);
                result.put("message", "Promo code has reached its usage limit.");
            } else if (promo.getMinOrderAmount() != null && subtotal.compareTo(promo.getMinOrderAmount()) < 0) {
                result.put("valid", false);
                result.put("message", "Order subtotal has not reached the minimum required for this promo code (Minimum: " + promo.getMinOrderAmount() + " VND).");
            } else {
                // Tinh toan chiet khau
                BigDecimal discount = BigDecimal.ZERO;
                if (Promotion.TYPE_PERCENT.equals(promo.getDiscountType())) {
                    discount = subtotal.multiply(promo.getDiscountValue())
                            .divide(BigDecimal.valueOf(100), 0, java.math.RoundingMode.HALF_UP);
                } else if (Promotion.TYPE_FIXED_AMOUNT.equals(promo.getDiscountType())) {
                    discount = promo.getDiscountValue();
                }

                if (discount.compareTo(subtotal) > 0) {
                    discount = subtotal; // giam toi da bang subtotal
                }

                BigDecimal total = subtotal.subtract(discount);

                result.put("valid", true);
                result.put("promoId", promo.getPromoId());
                result.put("discountAmount", discount);
                result.put("totalAmount", total);
                result.put("message", "Applied successfully: " + promo.getName());
            }
        } catch (Exception e) {
            result.put("valid", false);
            result.put("message", "Promo processing error: " + e.getMessage());
        }

        mapper.writeValue(resp.getWriter(), result);
    }
}
