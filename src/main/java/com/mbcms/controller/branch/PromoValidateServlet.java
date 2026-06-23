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
            result.put("message", "Mã và tổng tiền tạm tính không được để trống");
            mapper.writeValue(resp.getWriter(), result);
            return;
        }

        BigDecimal subtotal;
        try {
            subtotal = new BigDecimal(subtotalStr.trim());
        } catch (NumberFormatException e) {
            result.put("valid", false);
            result.put("message", "Tổng tiền tạm tính không đúng định dạng số");
            mapper.writeValue(resp.getWriter(), result);
            return;
        }

        try {
            Promotion promo = promotionDAO.findByCode(code.trim().toUpperCase());
            if (promo == null) {
                result.put("valid", false);
                result.put("message", "Mã khuyến mãi không tồn tại.");
            } else if (!promo.isActive() || !"Active".equals(promo.getStatus())) {
                result.put("valid", false);
                result.put("message", "Mã khuyến mãi hiện không kích hoạt hoặc đã hết hạn.");
            } else if (promo.getMaxUses() != null && promo.getUsedCount() >= promo.getMaxUses()) {
                result.put("valid", false);
                result.put("message", "Mã khuyến mãi đã hết lượt sử dụng.");
            } else if (promo.getMinOrderAmount() != null && subtotal.compareTo(promo.getMinOrderAmount()) < 0) {
                result.put("valid", false);
                result.put("message", "Đơn hàng chưa đạt giá trị tối thiểu để áp dụng mã này (Tối thiểu: " + promo.getMinOrderAmount() + " VND).");
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
                result.put("message", "Áp dụng thành công: " + promo.getName());
            }
        } catch (Exception e) {
            result.put("valid", false);
            result.put("message", "Lỗi xử lý khuyến mãi: " + e.getMessage());
        }

        mapper.writeValue(resp.getWriter(), result);
    }
}
