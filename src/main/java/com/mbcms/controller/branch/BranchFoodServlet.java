package com.mbcms.controller.branch;

import com.mbcms.model.FoodItem;
import com.mbcms.service.FoodService;
import com.mbcms.service.impl.FoodServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * BranchFoodServlet - Quan ly menu F&B cho Branch Manager.
 * Map: /branch/food
 *
 * GET  /branch/food              -> danh sach menu
 * GET  /branch/food?action=add   -> form them mon
 * GET  /branch/food?action=edit&foodId=X -> form sua mon
 *
 * POST /branch/food action=add         -> luu mon moi
 * POST /branch/food action=edit        -> cap nhat mon
 * POST /branch/food action=delete      -> xoa mon
 * POST /branch/food action=toggleStatus -> bat/tat active
 * POST /branch/food action=updateStock  -> cap nhat ton kho (AJAX JSON)
 */
@WebServlet("/branch/food")
public class BranchFoodServlet extends HttpServlet {

    private static final String LIST_VIEW = "/WEB-INF/views/branch/food_menu.jsp";
    private static final String FORM_VIEW = "/WEB-INF/views/branch/food_form.jsp";

    private final FoodService foodService = new FoodServiceImpl();

    // ── GET ──────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        ConsoleSupport.ensureBranchName(req);

        long branchId = currentBranchId(req, resp);
        if (branchId < 0) return;

        String action = req.getParameter("action");

        if ("add".equals(action)) {
            // Empty item for form
            req.setAttribute("item", new FoodItem());
            req.setAttribute("isAdd", true);
            forward(req, resp, FORM_VIEW);
            return;
        }

        if ("edit".equals(action)) {
            long foodId = parseLong(req.getParameter("foodId"), -1);
            if (foodId < 0) { redirect(req, resp, "/branch/food?error=invalid"); return; }

            FoodItem item = foodService.getFoodItemById(foodId);
            if (item == null || !Long.valueOf(branchId).equals(item.getBranchId())) {
                redirect(req, resp, "/branch/food?error=notfound");
                return;
            }
            req.setAttribute("item", item);
            req.setAttribute("isAdd", false);
            forward(req, resp, FORM_VIEW);
            return;
        }

        // Default: list view
        showList(req, resp, branchId);
    }

    // ── POST ─────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        long branchId = currentBranchId(req, resp);
        if (branchId < 0) return;

        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            case "add":
                handleAdd(req, resp, branchId);
                break;
            case "edit":
                handleEdit(req, resp, branchId);
                break;
            case "delete":
                handleDelete(req, resp, branchId);
                break;
            case "toggleStatus":
                handleToggleStatus(req, resp, branchId);
                break;
            case "updateStock":
                handleUpdateStock(req, resp, branchId);
                break;
            default:
                resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown action: " + action);
        }
    }

    // ── Handlers ─────────────────────────────────────────────────────

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws IOException {
        try {
            FoodItem item = buildItemFromRequest(req);
            foodService.addItem(item, branchId);
            redirect(req, resp, "/branch/food?added=1");
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "/branch/food?action=add&error=" +
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("handleAdd food error", e);
            redirect(req, resp, "/branch/food?error=server");
        }
    }

    private void handleEdit(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws IOException {
        long foodId = parseLong(req.getParameter("foodId"), -1);
        if (foodId < 0) { redirect(req, resp, "/branch/food?error=invalid"); return; }

        try {
            FoodItem item = buildItemFromRequest(req);
            item.setFoodId(foodId);
            foodService.editItem(item, branchId);
            redirect(req, resp, "/branch/food?updated=1");
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "/branch/food?action=edit&foodId=" + foodId + "&error=" +
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("handleEdit food error", e);
            redirect(req, resp, "/branch/food?error=server");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws IOException {
        long foodId = parseLong(req.getParameter("foodId"), -1);
        if (foodId < 0) { redirect(req, resp, "/branch/food?error=invalid"); return; }

        try {
            foodService.removeItem(foodId, branchId);
            redirect(req, resp, "/branch/food?deleted=1");
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "/branch/food?error=" +
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("handleDelete food error", e);
            redirect(req, resp, "/branch/food?error=server");
        }
    }

    private void handleToggleStatus(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws IOException {
        long foodId  = parseLong(req.getParameter("foodId"), -1);
        boolean active = "true".equalsIgnoreCase(req.getParameter("active"));

        if (foodId < 0) { redirect(req, resp, "/branch/food?error=invalid"); return; }

        try {
            foodService.toggleStatus(foodId, active, branchId);
            redirect(req, resp, "/branch/food?toggled=1");
        } catch (IllegalArgumentException e) {
            redirect(req, resp, "/branch/food?error=" +
                    java.net.URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            getServletContext().log("handleToggleStatus food error", e);
            redirect(req, resp, "/branch/food?error=server");
        }
    }

    /**
     * AJAX handler — returns JSON {"success":true} or {"success":false,"message":"..."}
     */
    private void handleUpdateStock(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws IOException {
        resp.setContentType("application/json;charset=UTF-8");

        long foodId = parseLong(req.getParameter("foodId"), -1);
        int  stock  = (int) parseLong(req.getParameter("stock"), -1);

        if (foodId < 0 || stock < 0) {
            resp.getWriter().write("{\"success\":false,\"message\":\"Tham so khong hop le.\"}");
            return;
        }

        try {
            boolean ok = foodService.updateStock(foodId, stock, branchId);
            if (ok) {
                resp.getWriter().write("{\"success\":true}");
            } else {
                resp.getWriter().write("{\"success\":false,\"message\":\"Cap nhat that bai.\"}");
            }
        } catch (IllegalArgumentException e) {
            resp.getWriter().write("{\"success\":false,\"message\":\""
                    + e.getMessage().replace("\"", "'") + "\"}");
        } catch (Exception e) {
            getServletContext().log("handleUpdateStock error", e);
            resp.getWriter().write("{\"success\":false,\"message\":\"Loi he thong.\"}");
        }
    }

    // ── List view ────────────────────────────────────────────────────

    private void showList(HttpServletRequest req, HttpServletResponse resp, long branchId)
            throws ServletException, IOException {

        List<FoodItem> items = foodService.getMenuByBranch(branchId);

        // KPI stats
        long totalItems  = items.size();
        long activeItems = items.stream().filter(FoodItem::isActive).count();
        long outOfStock  = items.stream().filter(i -> i.getStock() == 0).count();

        req.setAttribute("menuItems",   items);
        req.setAttribute("totalItems",  totalItems);
        req.setAttribute("activeItems", activeItems);
        req.setAttribute("outOfStock",  outOfStock);

        // PRG feedback messages
        String added   = req.getParameter("added");
        String updated = req.getParameter("updated");
        String deleted = req.getParameter("deleted");
        String toggled = req.getParameter("toggled");
        String error   = req.getParameter("error");

        if ("1".equals(added))   req.setAttribute("successMsg", "Mon moi da duoc them thanh cong.");
        else if ("1".equals(updated)) req.setAttribute("successMsg", "Cap nhat mon thanh cong.");
        else if ("1".equals(deleted)) req.setAttribute("successMsg", "Da xoa mon khoi menu.");
        else if ("1".equals(toggled)) req.setAttribute("successMsg", "Da cap nhat trang thai mon.");
        else if (error != null && !error.isEmpty()) {
            if ("server".equals(error)) {
                req.setAttribute("errorMsg", "Loi he thong. Vui long thu lai.");
            } else if ("notfound".equals(error)) {
                req.setAttribute("errorMsg", "Khong tim thay mon hoac khong co quyen.");
            } else {
                req.setAttribute("errorMsg", error);
            }
        }

        forward(req, resp, LIST_VIEW);
    }

    // ── Helpers ──────────────────────────────────────────────────────

    /**
     * Build a FoodItem from request parameters.
     * Does NOT set foodId or branchId — caller handles those.
     */
    private FoodItem buildItemFromRequest(HttpServletRequest req) {
        FoodItem item = new FoodItem();
        item.setName(trim(req.getParameter("name")));
        item.setDescription(trim(req.getParameter("description")));

        String priceStr = trim(req.getParameter("price"));
        if (priceStr != null && !priceStr.isEmpty()) {
            try { item.setPrice(new BigDecimal(priceStr)); }
            catch (NumberFormatException e) {
                throw new IllegalArgumentException("Gia khong hop le.");
            }
        }

        String category = trim(req.getParameter("category"));
        if (category == null || (!FoodItem.CATEGORY_SNACK.equals(category)
                && !FoodItem.CATEGORY_DRINK.equals(category)
                && !FoodItem.CATEGORY_COMBO.equals(category))) {
            throw new IllegalArgumentException("Loai mon khong hop le.");
        }
        item.setCategory(category);
        item.setImageUrl(trim(req.getParameter("imageUrl")));

        String stockStr = trim(req.getParameter("stock"));
        if (stockStr != null && !stockStr.isEmpty()) {
            try { item.setStock(Integer.parseInt(stockStr)); }
            catch (NumberFormatException e) {
                throw new IllegalArgumentException("So luong ton kho khong hop le.");
            }
        }

        String activeStr = req.getParameter("active");
        item.setActive(activeStr != null
                && ("true".equalsIgnoreCase(activeStr) || "on".equalsIgnoreCase(activeStr)));

        return item;
    }

    /** Get branchId from session. Returns -1 and sends 403 if not found. */
    private long currentBranchId(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        Object bid = (session != null) ? session.getAttribute("currentBranchId") : null;
        if (bid == null) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Branch context not found.");
            return -1;
        }
        return ((Number) bid).longValue();
    }

    private void forward(HttpServletRequest req, HttpServletResponse resp, String view)
            throws ServletException, IOException {
        req.getRequestDispatcher(view).forward(req, resp);
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp, String path)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }

    private long parseLong(String s, long def) {
        if (s == null || s.isBlank()) return def;
        try { return Long.parseLong(s.trim()); }
        catch (NumberFormatException e) { return def; }
    }

    private String trim(String s) {
        return (s == null) ? null : s.trim();
    }
}