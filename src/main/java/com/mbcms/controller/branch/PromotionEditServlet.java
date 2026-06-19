package com.mbcms.controller.branch;

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
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

@WebServlet("/branch/promotions/edit")
public class PromotionEditServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/promotions/form.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        ConsoleSupport.ensureBranchName(req);
        
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        try {
            long id = Long.parseLong(idStr.trim());
            PromotionDAO promotionDAO = new PromotionDAOImpl();
            Promotion p = promotionDAO.findById(id);
            if (p == null) {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
                return;
            }

            req.setAttribute("isEdit", true);
            req.setAttribute("promo", p);
            
            // Format dates back for HTML inputs
            req.setAttribute("rawStartDate", p.getValidFrom().toLocalDate().toString());
            req.setAttribute("rawEndDate", p.getValidTo().toLocalDate().toString());
            req.setAttribute("rawDiscountValue", p.getDiscountValue().stripTrailingZeros().toPlainString());
            req.setAttribute("rawMinOrderAmount", p.getMinOrderAmount().stripTrailingZeros().toPlainString());
            req.setAttribute("rawMaxUses", p.getMaxUses() != null ? p.getMaxUses().toString() : "");

            req.getRequestDispatcher(VIEW).forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        ConsoleSupport.ensureBranchName(req);

        String idStr = req.getParameter("promoId");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        long id;
        try {
            id = Long.parseLong(idStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        PromotionDAO promotionDAO = new PromotionDAOImpl();
        Promotion existing = promotionDAO.findById(id);
        if (existing == null) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        String code = req.getParameter("code");
        String name = req.getParameter("name");
        String discountType = req.getParameter("discountType");
        String discountValueStr = req.getParameter("discountValue");
        String minOrderAmountStr = req.getParameter("minOrderAmount");
        String maxUsesStr = req.getParameter("maxUses");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");
        boolean active = req.getParameter("active") != null;

        Promotion p = new Promotion();
        p.setPromoId(id);
        p.setCode(code != null ? code.trim().toUpperCase() : "");
        p.setName(name != null ? name.trim() : "");
        p.setDiscountType(discountType);
        p.setActive(active);
        p.setUsedCount(existing.getUsedCount()); // keep existing usage count

        String errorMsg = null;

        // Validation logic
        if (p.getCode().isEmpty() || p.getCode().length() > 20 || !p.getCode().matches("^[a-zA-Z0-9]+$")) {
            errorMsg = "Code is required, alphanumeric only, and maximum 20 characters.";
        } else if (p.getName().isEmpty() || p.getName().length() > 150) {
            errorMsg = "Name is required and maximum 150 characters.";
        } else if (!"PERCENT".equals(discountType) && !"FIXED_AMOUNT".equals(discountType)) {
            errorMsg = "Invalid discount type.";
        } else {
            // Validate discount value
            try {
                BigDecimal discountValue = new BigDecimal(discountValueStr.trim());
                if (discountValue.compareTo(BigDecimal.ZERO) <= 0) {
                    errorMsg = "Discount value must be a positive number.";
                } else if ("PERCENT".equals(discountType) && discountValue.compareTo(new BigDecimal("100")) > 0) {
                    errorMsg = "Percentage discount value cannot exceed 100%.";
                } else {
                    p.setDiscountValue(discountValue);
                }
            } catch (Exception e) {
                errorMsg = "Discount value must be a valid number.";
            }
        }

        // Validate min order amount
        if (errorMsg == null) {
            try {
                BigDecimal minOrder = (minOrderAmountStr == null || minOrderAmountStr.trim().isEmpty()) 
                        ? BigDecimal.ZERO 
                        : new BigDecimal(minOrderAmountStr.trim());
                if (minOrder.compareTo(BigDecimal.ZERO) < 0) {
                    errorMsg = "Minimum order amount cannot be negative.";
                } else {
                    p.setMinOrderAmount(minOrder);
                }
            } catch (Exception e) {
                errorMsg = "Minimum order amount must be a valid number.";
            }
        }

        // Validate max uses
        if (errorMsg == null) {
            try {
                if (maxUsesStr == null || maxUsesStr.trim().isEmpty()) {
                    p.setMaxUses(null);
                } else {
                    int maxUses = Integer.parseInt(maxUsesStr.trim());
                    if (maxUses <= 0) {
                        errorMsg = "Max uses must be a positive integer.";
                    } else {
                        p.setMaxUses(maxUses);
                    }
                }
            } catch (Exception e) {
                errorMsg = "Max uses must be a positive integer.";
            }
        }

        // Validate dates
        if (errorMsg == null) {
            try {
                if (startDateStr == null || startDateStr.trim().isEmpty() || 
                    endDateStr == null || endDateStr.trim().isEmpty()) {
                    errorMsg = "Start date and end date are required.";
                } else {
                    LocalDate start = LocalDate.parse(startDateStr.trim());
                    LocalDate end = LocalDate.parse(endDateStr.trim());
                    if (end.isBefore(start)) {
                        errorMsg = "End date must be on or after start date.";
                    } else {
                        p.setValidFrom(start.atStartOfDay());
                        p.setValidTo(end.atTime(LocalTime.MAX));
                    }
                }
            } catch (DateTimeParseException e) {
                errorMsg = "Invalid date format.";
            }
        }

        // Check code uniqueness excluding this ID
        if (errorMsg == null && promotionDAO.existsByCodeExcludeId(p.getCode(), p.getPromoId())) {
            errorMsg = "Promotion code already exists.";
        }

        if (errorMsg != null) {
            req.setAttribute("errorMsg", errorMsg);
            req.setAttribute("isEdit", true);
            req.setAttribute("promo", p);
            // Put raw string values back to restore input states
            req.setAttribute("rawDiscountValue", discountValueStr);
            req.setAttribute("rawMinOrderAmount", minOrderAmountStr);
            req.setAttribute("rawMaxUses", maxUsesStr);
            req.setAttribute("rawStartDate", startDateStr);
            req.setAttribute("rawEndDate", endDateStr);
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }

        // Update and redirect
        boolean success = promotionDAO.update(p);
        if (success) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?updated=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
        }
    }
}
