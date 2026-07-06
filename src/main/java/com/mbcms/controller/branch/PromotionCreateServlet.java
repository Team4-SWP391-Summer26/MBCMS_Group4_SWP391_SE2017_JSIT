package com.mbcms.controller.branch;

import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.PromotionDAOImpl;
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

@WebServlet("/branch/promotions/create")
public class PromotionCreateServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/promotions/form.jsp";
    private NotificationService notificationService = new NotificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        // [Security Check] Verify active HTTP session
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentBranchId") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        ConsoleSupport.ensureBranchName(req);

        // [Flow Step: Servlet -> JSP] Initialize an empty template model and forward to form.jsp view
        // Setting attributes to avoid JSP rendering errors (null values)
        req.setAttribute("isEdit", false);
        req.setAttribute("promo", new Promotion()); // Blank model placeholder
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
        
        // [Security Check] Verify active HTTP session
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentBranchId") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        ConsoleSupport.ensureBranchName(req);

        // [Flow Step: JSP -> Servlet] Parse raw input values sent by the form POST request
        String code = req.getParameter("code");
        String name = req.getParameter("name");
        String discountType = req.getParameter("discountType");
        String discountValueStr = req.getParameter("discountValue");
        String minOrderAmountStr = req.getParameter("minOrderAmount");
        String maxUsesStr = req.getParameter("maxUses");
        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");
        boolean active = req.getParameter("active") != null;

        // Initialize entities and DAO dependencies
        PromotionDAO promotionDAO = new PromotionDAOImpl();
        Promotion p = new Promotion();
        p.setCode(code != null ? code.trim().toUpperCase() : "");
        p.setName(name != null ? name.trim() : "");
        p.setDiscountType(discountType);
        p.setActive(active);

        String errorMsg = null;

        // ── Validation Phase ──────────────────────────────────────────────────
        // Rule 1: Code validation (must be alphanumeric, max 20 chars)
        if (p.getCode().isEmpty() || p.getCode().length() > 20 || !p.getCode().matches("^[a-zA-Z0-9]+$")) {
            errorMsg = "Code is required, alphanumeric only, and maximum 20 characters.";
        } 
        // Rule 2: Name validation (max 150 chars)
        else if (p.getName().isEmpty() || p.getName().length() > 150) {
            errorMsg = "Name is required and maximum 150 characters.";
        } 
        // Rule 3: Discount type validation
        else if (!"PERCENT".equals(discountType) && !"FIXED_AMOUNT".equals(discountType)) {
            errorMsg = "Invalid discount type.";
        } 
        // Rule 4: Discount value validation
        else {
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

        // Rule 5: Minimum order threshold validation
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

        // Rule 6: Max usage count validation
        if (errorMsg == null) {
            try {
                if (maxUsesStr == null || maxUsesStr.trim().isEmpty()) {
                    p.setMaxUses(null); // Null value indicates infinite usage availability
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

        // Rule 7: Validity date period checks
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

        // Rule 8: Uniqueness of code check in Database
        if (errorMsg == null && promotionDAO.existsByCode(p.getCode())) {
            errorMsg = "Promotion code already exists.";
        }

        // [Form Feedback Handler] If validation failed, re-render form with inputs preserved (UX friendly)
        if (errorMsg != null) {
            req.setAttribute("errorMsg", errorMsg);
            req.setAttribute("isEdit", false);
            req.setAttribute("promo", p);
            req.setAttribute("rawDiscountValue", discountValueStr);
            req.setAttribute("rawMinOrderAmount", minOrderAmountStr);
            req.setAttribute("rawMaxUses", maxUsesStr);
            req.setAttribute("rawStartDate", startDateStr);
            req.setAttribute("rawEndDate", endDateStr);
            req.setAttribute("todayStr", LocalDate.now().toString());
            req.getRequestDispatcher(VIEW).forward(req, resp);
            return;
        }

        // Apply scoped branchId from session
        long branchId = (Long) session.getAttribute("currentBranchId");
        p.setBranchId(branchId);

        // [Database Persist] Insert new record via PromotionDAO
        boolean success = promotionDAO.insert(p);
        if (success) {
            if (p.isActive()) {
                // [Flow Step: Notification Service] Spawn an asynchronous background worker thread to broadcast 
                // the new active promotion notification to all registered customers without blocking the main HTTP request thread.
                new Thread(() -> {
                    Promotion saved = promotionDAO.findByCode(code);
                    if (saved != null) {
                        notificationService.broadcastPromotion(saved);
                    }
                }, "promo-broadcast-" + code).start();
            }
            // PRG Pattern: Redirect browser to GET promotion list showing success parameter
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?created=1");
        } else {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
        }
    }
}
