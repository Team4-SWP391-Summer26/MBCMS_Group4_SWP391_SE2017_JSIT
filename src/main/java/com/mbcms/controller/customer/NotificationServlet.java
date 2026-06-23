package com.mbcms.controller.customer;

import com.mbcms.model.Customer;
import com.mbcms.model.Notification;
import com.mbcms.service.NotificationService;
import com.mbcms.service.impl.NotificationServiceImpl;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * NotificationServlet - trang /customer/notifications (xem tat ca thong bao).
 *
 * GET  /customer/notifications          → hien thi danh sach co phan trang
 * POST /customer/notifications/mark-all → danh dau tat ca da doc roi redirect
 *
 * Duoc bao ve boi AuthFilter (/customer/* → phai dang nhap).
 */
@WebServlet(urlPatterns = {"/customer/notifications", "/customer/notifications/mark-all"})
public class NotificationServlet extends HttpServlet {

    private static final int PAGE_SIZE = 15;
    private static final String VIEW   = "/WEB-INF/views/customer/notifications.jsp";

    private final NotificationService notificationService = new NotificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Customer customer   = (Customer) session.getAttribute("currentUser");
        String username     = customer.getUsername();

        // Lay so trang tu query param, mac dinh la trang 1
        int page = 1;
        try {
            String p = req.getParameter("page");
            if (p != null) page = Math.max(1, Integer.parseInt(p.trim()));
        } catch (NumberFormatException ignored) {}

        // Lay filter: all | unread (mac dinh: all)
        String filter = req.getParameter("filter");
        if (!"unread".equals(filter)) filter = "all";

        List<Notification> notifications = notificationService.getPagedForUser(
                username, page, PAGE_SIZE);
        int total     = notificationService.countAll(username);
        int totalPages = (int) Math.ceil((double) total / PAGE_SIZE);
        int unread    = notificationService.countUnread(username);

        req.setAttribute("notifications", notifications);
        req.setAttribute("currentPage",   page);
        req.setAttribute("totalPages",    totalPages);
        req.setAttribute("totalCount",    total);
        req.setAttribute("unreadCount",   unread);
        req.setAttribute("filter",        filter);
        req.setAttribute("notifService",  notificationService);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Customer customer   = (Customer) session.getAttribute("currentUser");
        String username     = customer.getUsername();

        notificationService.markAllAsRead(username);
        resp.sendRedirect(req.getContextPath() + "/customer/notifications");
    }
}
