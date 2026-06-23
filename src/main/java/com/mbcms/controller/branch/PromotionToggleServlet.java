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

@WebServlet("/branch/promotions/toggle")
public class PromotionToggleServlet extends HttpServlet {

    NotificationService notificationService = new NotificationServiceImpl();
    PromotionDAO promotionDAO = new PromotionDAOImpl();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        try {
            long id = Long.parseLong(idStr.trim());
            Promotion before = promotionDAO.findById(id);
            boolean wasInactive = (before != null && !before.isActive());

            boolean success = promotionDAO.toggleActive(id);
            if (success) {
                // Neu vua duoc bat active (inactive → active), phat thu chuong khuyen mai
                if (wasInactive) {
                    Promotion afterToggle = promotionDAO.findById(id);
                    if (afterToggle != null && afterToggle.isActive()) {
                        new Thread(
                                () -> notificationService.broadcastPromotion(afterToggle),
                                "promo-broadcast-" + id
                        ).start();
                    }
                }
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?toggled=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
        }
    }
}
