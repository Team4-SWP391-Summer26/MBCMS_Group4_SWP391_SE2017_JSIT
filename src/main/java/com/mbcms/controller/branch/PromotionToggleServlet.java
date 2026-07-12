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
        
        // [Security Check] Verify active HTTP session
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentBranchId") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // [Flow Step: JSP -> Servlet] Post request triggers promotion toggle with id parameter
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        try {
            long id = Long.parseLong(idStr.trim());
            
            // [Flow Step: Servlet -> Database] Query DB via DAO to verify promotion existence
            Promotion before = promotionDAO.findById(id);
            if (before == null) {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
                return;
            }

            // Verify branch boundary permission (Security check)
            Long sessionBranchId = (Long) session.getAttribute("currentBranchId");
            if (sessionBranchId == null || !sessionBranchId.equals(before.getBranchId())) {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
                return;
            }

            boolean wasInactive = !before.isActive();

            // [Flow Step: Servlet -> Database] Execute active state toggle update in the DB via XOR bit update
            boolean success = promotionDAO.toggleActive(id);
            if (success) {
                // If it was toggled from Inactive to Active, fire the notification broadcast
                if (wasInactive) {
                    // [Flow Step: Servlet -> Database] Fetch updated promotion state from Database
                    Promotion afterToggle = promotionDAO.findById(id);
                    if (afterToggle != null && afterToggle.isActive()) {
                        // [Flow Step: Service] Spawn background thread to broadcast new active promotion notifications
                        new Thread(
                                () -> notificationService.broadcastPromotion(afterToggle),
                                "promo-broadcast-" + id
                        ).start();
                    }
                }
                // [Flow Step: Servlet -> Browser] Perform Post-Redirect-Get pattern redirect
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?toggled=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
        }
    }
}
