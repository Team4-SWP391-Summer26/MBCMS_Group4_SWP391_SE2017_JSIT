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

@WebServlet("/branch/promotions/delete")
public class PromotionDeleteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // [Flow Step: JSP -> Servlet] Post request received to soft-delete a promotion with parameter 'id'
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            return;
        }

        try {
            long id = Long.parseLong(idStr.trim());
            PromotionDAO promotionDAO = new PromotionDAOImpl();
            
            // [Flow Step: Servlet -> Database] Query DB via PromotionDAO to load the promotion details
            Promotion p = promotionDAO.findById(id);
            if (p == null) {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
                return;
            }

            Long sessionBranchId = (Long) req.getSession(false).getAttribute("currentBranchId");
            if (sessionBranchId == null || !sessionBranchId.equals(p.getBranchId())) {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
                return;
            }

            // [Flow Step: Servlet -> Database] Execute soft-deletion update in the DB via PromotionDAO.delete()
            boolean success = promotionDAO.delete(id);
            if (success) {
                // [Flow Step: Servlet -> Browser] Redirection back to promotions list with success code
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?deleted=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
        } catch (RuntimeException e) {
            if ("IN_USE".equals(e.getMessage())) {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=in_use");
            } else {
                resp.sendRedirect(req.getContextPath() + "/branch/promotions?error=1");
            }
        }
    }
}
