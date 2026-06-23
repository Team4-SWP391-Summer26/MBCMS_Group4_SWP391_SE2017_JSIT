package com.mbcms.controller.customer;

import com.mbcms.model.Customer;
import com.mbcms.model.Notification;
import com.mbcms.service.NotificationService;
import com.mbcms.service.impl.NotificationServiceImpl;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * NotificationApiServlet - AJAX endpoint tra ve JSON.
 *
 * Endpoints:
 *   GET  /api/notifications           → list + unread count (cho dropdown bell)
 *   POST /api/notifications?id=X      → danh dau 1 thong bao da doc
 *   POST /api/notifications/mark-all-read → danh dau tat ca da doc
 *
 * Khong qua AuthFilter (/api/* khong nam trong danh sach bao ve),
 * nen tu kiem tra session o day va tra ve 401 JSON thay vi redirect.
 */
@WebServlet("/api/notifications/*")
public class NotificationApiServlet extends HttpServlet {

    private final NotificationService notificationService = new NotificationServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = currentUsername(req);
        if (username == null) {
            sendJson(resp, HttpServletResponse.SC_UNAUTHORIZED, "{\"error\":\"Not logged in\"}");
            return;
        }

        // Optional ?limit= param: page uses 100 for client-side filtering; default 10 for bell
        int limit = 10;
        try {
            String lp = req.getParameter("limit");
            if (lp != null) limit = Math.min(100, Integer.parseInt(lp.trim()));
        } catch (NumberFormatException ignored) {}

        List<Notification> list = notificationService.getRecentForUser(username, limit);
        int unread = notificationService.countUnread(username);

        StringBuilder json = new StringBuilder();
        json.append("{\"unreadCount\":").append(unread).append(",\"items\":[");
        for (int i = 0; i < list.size(); i++) {
            if (i > 0) json.append(",");
            json.append(toJson(list.get(i), req.getContextPath()));
        }
        json.append("]}");

        sendJson(resp, HttpServletResponse.SC_OK, json.toString());
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String username = currentUsername(req);
        if (username == null) {
            sendJson(resp, HttpServletResponse.SC_UNAUTHORIZED, "{\"error\":\"Not logged in\"}");
            return;
        }

        String pathInfo = req.getPathInfo(); // null | "/" | "/mark-all-read"

        // POST /api/notifications/mark-all-read
        if ("/mark-all-read".equals(pathInfo)) {
            boolean ok = notificationService.markAllAsRead(username);
            sendJson(resp, HttpServletResponse.SC_OK, "{\"success\":" + ok + "}");
            return;
        }

        // POST /api/notifications?id=X
        String idParam = req.getParameter("id");
        if (idParam == null) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST, "{\"error\":\"Missing id\"}");
            return;
        }
        try {
            long notiId = Long.parseLong(idParam.trim());
            boolean ok  = notificationService.markAsRead(notiId, username);
            sendJson(resp, HttpServletResponse.SC_OK, "{\"success\":" + ok + "}");
        } catch (NumberFormatException e) {
            sendJson(resp, HttpServletResponse.SC_BAD_REQUEST, "{\"error\":\"Invalid id\"}");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private String toJson(Notification n, String contextPath) {
        return "{"
                + "\"id\":"         + n.getNotiId()                                       + ","
                + "\"title\":\""    + esc(n.getTitle())                                   + "\","
                + "\"content\":\"" + esc(n.getContent())                                  + "\","
                + "\"type\":\""     + esc(n.getType())                                    + "\","
                + "\"iconClass\":\"" + esc(notificationService.iconClassFor(n.getType())) + "\","
                + "\"linkUrl\":\""  + esc(notificationService.linkFor(n, contextPath))    + "\","
                + "\"read\":"       + n.isRead()                                          + ","
                + "\"createdAt\":\"" + (n.getCreatedAt() != null
                        ? n.getCreatedAt().toString() : "")                               + "\""
                + "}";
    }

    /**
     * Lay username tu session.
     * currentUser la Customer (set boi LoginServlet sau khi xac thuc thanh cong).
     * Tra ve null neu guest hoac employee (employee khong co notification).
     */
    private String currentUsername(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        Object user = session.getAttribute("currentUser");
        if (user instanceof Customer) {
            return ((Customer) user).getUsername();
        }
        return null;
    }

    private void sendJson(HttpServletResponse resp, int status, String json) throws IOException {
        resp.setStatus(status);
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(json);
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", " ")
                .replace("\r", "");
    }
}