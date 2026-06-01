package com.mbcms.controller.auth;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * LogoutServlet - owner: <b>HungNT</b> (Report 4).
 *
 * Huy session hien tai roi dua nguoi dung ve trang chu.
 * Duoc goi tu link "Logout" tren navbar (header.jsp) nen dung GET.
 */
@WebServlet("/auth/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Huy session: xoa toan bo currentUser, userRole, branchId,
        //    currentBranchId, redirectAfterLogin... (khong can xoa tung attribute).
        HttpSession session = req.getSession(false);
        if (session != null) {
            session.invalidate();
        }

        // 2. Chong cache: tranh nut Back hien lai trang da dang nhap tu cache.
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

        // 3. Ve trang chu (Guest van xem duoc).
        resp.sendRedirect(req.getContextPath() + "/home");
    }
}
