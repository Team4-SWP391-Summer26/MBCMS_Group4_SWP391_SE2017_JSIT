package com.mbcms.controller.admin;

import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.dao.impl.PromotionDAOImpl;
import com.mbcms.model.Branch;
import com.mbcms.model.Promotion;
import com.mbcms.service.NotificationService;
import com.mbcms.service.impl.NotificationServiceImpl;
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
import java.util.List;

@WebServlet("/admin/promotions/create")
public class AdminPromotionCreateServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/admin/promotions/form.jsp";
    private final NotificationService notificationService = new NotificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        BranchDAO branchDAO = new BranchDAOImpl();
        List<Branch> branches = branchDAO.findAll(true);

        req.setAttribute("isEdit", false);
        req.setAttribute("promo", new Promotion()); // blank object
        req.setAttribute("branches", branches);
        req.setAttribute("rawDiscountValue", "");
        req.setAttribute("rawMinOrderAmount", "0");
        req.setAttribute("rawMaxUses", "");
        req.setAttribute("rawStartDate", "");
        req.setAttribute("rawEndDate", "");
        req.setAttribute("todayStr", java.time.LocalDate.now().toString());

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String code = req.getParameter("code");
        String name = req.getParameter("name");
        String discountType = req.getParameter("discountType");
        String discountValueStr = req.getParameter("discountValue");
        String minOrderAmountStr = req.getParameter("minOrderAmount");
        String maxUsesStr = req.getParameter("maxUses");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");
        String branchIdStr = req.getParameter("branchId");
        boolean active = req.getParameter("active") != null;

        PromotionDAO promotionDAO = new PromotionDAOImpl();
        BranchDAO branchDAO = new BranchDAOImpl();
        List<Branch> branches = branchDAO.findAll(true);

        Promotion p = new Promotion();
        p.setCode(code != null ? code.trim().toUpperCase() : "");
        p.setName(name != null ? name.trim() : "");
        p.setDiscountType(discountType);
        p.setActive(active);

        Long branchId = null;
        if (branchIdStr != null && !branchIdStr.trim().isEmpty()) {
            try {
                branchId = Long.parseLong(branchIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }
        p.setBranchId(branchId);

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
                if (startDateStr == null || startDateStr.trim().isEmpty()
                        || endDateStr == null || endDateStr.trim().isEmpty()) {
                    errorMsg = "Start date and end date are required.";
                } else {
                    LocalDate start = LocalDate.parse(startDateStr.trim());
                    LocalDate end = LocalDate.parse(endDateStr.trim());
                    if (end.isBefore(start)) {
                        errorMsg = "End date must be on or after start date.";
                    } else if (start.isBefore(LocalDate.now())) {
                        errorMsg = "Start date cannot be in the past.";
                    } else {
                        p.setValidFrom(start.atStartOfDay());
                        p.setValidTo(end.atTime(LocalTime.MAX));
                    }
                }
            } catch (DateTimeParseException e) {
                errorMsg = "Invalid date format.";
            }
        }

        // Check code uniqueness
        if (errorMsg == null && promotionDAO.existsByCode(p.getCode())) {
            errorMsg = "Promotion code already exists.";
        }

        if (errorMsg != null) {
            req.setAttribute("errorMsg", errorMsg);
            req.setAttribute("isEdit", false);
            req.setAttribute("promo", p);
            req.setAttribute("branches", branches);
            // Put raw string values back to restore input states
            req.setAttribute("rawDiscountValue", discountValueStr);
            req.setAttribute("rawMinOrderAmount", minOrderAmountStr);
            req.setAttribute("rawMaxUses", maxUsesStr);
            req.setAttribute("rawStartDate", startDateStr);
            req.setAttribute("rawEndDate", endDateStr);
            req.setAttribute("todayStr", LocalDate.now().toString());
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }

        // Save and redirect
        boolean success = promotionDAO.insert(p);
        if (success) {
            if (p.isActive()) {
                new Thread(() -> {
                    Promotion saved = promotionDAO.findByCode(code);
                    if (saved != null) {
                        notificationService.broadcastPromotion(saved);
                    }
                }, "admin-promo-broadcast-" + code).start();
            }
            resp.sendRedirect(req.getContextPath() + "/admin/promotions?created=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
        }
    }
}
