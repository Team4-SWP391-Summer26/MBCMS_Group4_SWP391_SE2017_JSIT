package com.mbcms.controller.admin;

import com.mbcms.dao.PromotionDAO;
import com.mbcms.dao.impl.PromotionDAOImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/admin/promotions/delete")
public class AdminPromotionDeleteServlet extends HttpServlet {

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
            PromotionDAO promotionDAO = new PromotionDAOImpl();
            boolean success = promotionDAO.delete(id);
            if (success) {
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?deleted=1");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
        } catch (RuntimeException e) {
            if ("IN_USE".equals(e.getMessage())) {
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=in_use");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/promotions?error=1");
            }
        }
    }
}
