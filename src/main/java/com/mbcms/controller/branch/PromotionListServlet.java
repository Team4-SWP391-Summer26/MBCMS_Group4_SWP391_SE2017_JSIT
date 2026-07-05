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
        // [Flow Step: JSP -> Servlet] The request originates from promotions list page (list.jsp) upon loading, or filtering forms
        long branchId = (Long) req.getSession(false).getAttribute("currentBranchId");
        ConsoleSupport.ensureBranchName(req);

        // Fetch query parameters for filtering
        String search = req.getParameter("search");
        String type = req.getParameter("type");
        String status = req.getParameter("status");

        PromotionDAO promotionDAO = new PromotionDAOImpl();

        // [Flow Step: Servlet -> Database] Retrieve statistics and branch metrics from Database via PromotionDAO
        int totalPromotions = promotionDAO.getTotalPromotionsCount(branchId);
        int activePromotions = promotionDAO.getActivePromotionsCount(branchId);
        int usedThisMonth = promotionDAO.getUsedThisMonthCount(branchId);
        BigDecimal revenueImpact = promotionDAO.getRevenueImpactThisMonth(branchId);

        // [Flow Step: Servlet -> Database] Fetch filtered list of promotions from DB based on filter parameters
        List<Promotion> list = promotionDAO.findByFilters(search, type, status, branchId);

        // Set attributes
        req.setAttribute("promotions", list);
        req.setAttribute("statTotal", totalPromotions);
        req.setAttribute("statActive", activePromotions);
        req.setAttribute("statUsed", usedThisMonth);
        req.setAttribute("statRevenue", revenueImpact);

        req.setAttribute("filterSearch", search);
        req.setAttribute("filterType", type);
        req.setAttribute("filterStatus", status);

        // Handle success/error feedback messages (PRG redirect parameters)
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

        // [Flow Step: Servlet -> JSP] Forward request payload and attributes to the list.jsp view for browser rendering
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
