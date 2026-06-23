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
import java.util.List;

@WebServlet("/branch/promotions")
public class PromotionListServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/branch/promotions/list.jsp";

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ConsoleSupport.ensureBranchName(req);

        // Fetch query parameters for filtering
        String search = req.getParameter("search");
        String type = req.getParameter("type");
        String status = req.getParameter("status");

        PromotionDAO promotionDAO = new PromotionDAOImpl();

        // Retrieve statistics
        int totalPromotions = promotionDAO.getTotalPromotionsCount();
        int activePromotions = promotionDAO.getActivePromotionsCount();
        int usedThisMonth = promotionDAO.getUsedThisMonthCount();
        BigDecimal revenueImpact = promotionDAO.getRevenueImpactThisMonth();

        // Retrieve filtered list of promotions
        List<Promotion> list = promotionDAO.findByFilters(search, type, status);

        // Set attributes
        req.setAttribute("promotions", list);
        req.setAttribute("statTotal", totalPromotions);
        req.setAttribute("statActive", activePromotions);
        req.setAttribute("statUsed", usedThisMonth);
        req.setAttribute("statRevenue", revenueImpact);

        req.setAttribute("filterSearch", search);
        req.setAttribute("filterType", type);
        req.setAttribute("filterStatus", status);

        // Handle success/error feedback messages (PRG)
        if ("1".equals(req.getParameter("created"))) {
            req.setAttribute("successMsg", "Added successfully.");
        } else if ("1".equals(req.getParameter("updated"))) {
            req.setAttribute("successMsg", "Updated successfully.");
        } else if ("1".equals(req.getParameter("toggled"))) {
            req.setAttribute("successMsg", "Promotion status toggled successfully.");
        } else if ("1".equals(req.getParameter("deleted"))) {
            req.setAttribute("successMsg", "Promotion deleted successfully.");
        } else if ("1".equals(req.getParameter("error"))) {
            req.setAttribute("errorMsg", "An error occurred. Please try again.");
        } else if ("dup_code".equals(req.getParameter("error"))) {
            req.setAttribute("errorMsg", "Promotion code must be unique.");
        } else if ("in_use".equals(req.getParameter("error"))) {
            req.setAttribute("errorMsg", "Cannot delete: This promotion has already been applied to booking records.");
        }

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
