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
        
        // [Security Check] Retrieve the HTTP Session without creating a new one (getSession(false))
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        
        // Guard Clause: If session does not exist or user has no currentBranchId, redirect to login page
        // This avoids throwing NullPointerException when calling session.getAttribute()
        if (session == null || session.getAttribute("currentBranchId") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }
        
        // [Data Extraction] Retrieve the current branch ID bound to the authenticated user's session
        long branchId = (Long) session.getAttribute("currentBranchId");
        
        // Helper support call to load the branch name and store it in request scope (for rendering header/sidebar)
        ConsoleSupport.ensureBranchName(req);

        // [Filter Parsing] Fetch query parameters sent from search/filter forms on list.jsp
        String search = req.getParameter("search"); // Text search keyword for promo name or code
        String type = req.getParameter("type");     // Discount type filter (e.g., PERCENTAGE, FLAT)
        String status = req.getParameter("status"); // Active status filter (e.g., ACTIVE, INACTIVE)

        // Instantiate Data Access Object implementation to interact with SQL Server Database
        PromotionDAO promotionDAO = new PromotionDAOImpl();

        // [Database Query - Statistics] Retrieve dashboard KPI statistics specific to the user's branch
        int totalPromotions = promotionDAO.getTotalPromotionsCount(branchId);
        int activePromotions = promotionDAO.getActivePromotionsCount(branchId);
        int usedThisMonth = promotionDAO.getUsedThisMonthCount(branchId);
        BigDecimal revenueImpact = promotionDAO.getRevenueImpactThisMonth(branchId);

        // [Database Query - Main Data] Query database for promotions matching filters and branch scope
        List<Promotion> list = promotionDAO.findByFilters(search, type, status, branchId);

        // [Context Setting] Map the retrieved data collections to Request Attributes for JSP expression access
        req.setAttribute("promotions", list);
        req.setAttribute("statTotal", totalPromotions);
        req.setAttribute("statActive", activePromotions);
        req.setAttribute("statUsed", usedThisMonth);
        req.setAttribute("statRevenue", revenueImpact);

        // Retain active filters to populate form inputs after request-response cycle completes (UX preservation)
        req.setAttribute("filterSearch", search);
        req.setAttribute("filterType", type);
        req.setAttribute("filterStatus", status);

        // [PRG Feedback Parser] Set user-facing success or error notifications based on redirect query status codes
        String errorParam = req.getParameter("error");
        if ("1".equals(req.getParameter("created"))) {
            req.setAttribute("successMsg", "Added successfully.");
        } else if ("1".equals(req.getParameter("updated"))) {
            req.setAttribute("successMsg", "Updated successfully.");
        } else if ("1".equals(req.getParameter("toggled"))) {
            req.setAttribute("successMsg", "Promotion status toggled successfully.");
        } else if ("1".equals(req.getParameter("deleted"))) {
            req.setAttribute("successMsg", "Promotion deleted successfully.");
        } else if ("1".equals(errorParam)) {
            req.setAttribute("errorMsg", "An error occurred. Please try again.");
        } else if ("dup_code".equals(errorParam)) {
            req.setAttribute("errorMsg", "Promotion code must be unique.");
        } else if ("in_use".equals(errorParam)) {
            req.setAttribute("errorMsg", "Cannot delete: This promotion has already been applied to booking records.");
        }

        // [Request Dispatcher] Forward internal request control containing populated scopes to the JSP template for HTML rendering
        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
