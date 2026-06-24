package com.mbcms.controller.admin;

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

@WebServlet("/admin/promotions/toggle")
public class AdminPromotionToggleServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationServiceImpl();
    private final PromotionDAO promotionDAO = new PromotionDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
            return;
        }

        try {
            long id = Long.parseLong(idStr.trim());
            Promotion before = promotionDAO.findById(id);
            if (before == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
                return;
            }

            boolean wasInactive = !before.isActive();

            boolean success = promotionDAO.toggleActive(id);
            if (success) {
                // If toggled to active, broadcast
                if (wasInactive) {
                    Promotion afterToggle = promotionDAO.findById(id);
                    if (afterToggle != null && afterToggle.isActive()) {
                        new Thread(
                                () -> notificationService.broadcastPromotion(afterToggle),
                                "admin-promo-broadcast-" + id
                        ).start();
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?toggled=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
        }
    }
}
