package com.mbcms.controller.auth;

import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * ChangePasswordServlet - xu ly doi mat khau cho user da dang nhap.
 * URL: /auth/change-password
 */
@WebServlet("/auth/change-password")
public class ChangePasswordServlet extends HttpServlet {

    private final AuthService authService = new AuthServiceImpl();

    /**
     * Hien thi form doi mat khau.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(req, resp);
    }

    /**
     * Nhan form, validate input, goi Service de doi mat khau.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        String username = (String) session.getAttribute("username");
        String userRole = (String) session.getAttribute("userRole");

        String oldPassword = req.getParameter("oldPassword");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        // Kiem tra mat khau moi va confirm co giong nhau khong.
        if (newPassword == null || confirmPassword == null || !newPassword.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "Mat khau moi va xac nhan mat khau khong khop.");
            req.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(req, resp);
            return;
        }

        try {
            String result = authService.changePassword(username, userRole, oldPassword, newPassword);

            switch (result) {
                case "SUCCESS":
                    req.setAttribute("successMsg", "Doi mat khau thanh cong.");
                    break;

                case "WRONG_OLD_PASSWORD":
                    req.setAttribute("errorMsg", "Mat khau cu khong chinh xac.");
                    break;

                case "WEAK_PASSWORD":
                    req.setAttribute("errorMsg", "Mat khau moi phai co it nhat 6 ky tu.");
                    break;

                case "SAME_PASSWORD":
                    req.setAttribute("errorMsg", "Mat khau moi khong duoc trung voi mat khau cu.");
                    break;

                case "USER_NOT_FOUND":
                    req.setAttribute("errorMsg", "Khong tim thay tai khoan hoac tai khoan da bi khoa.");
                    break;

                default:
                    req.setAttribute("errorMsg", "Doi mat khau that bai. Vui long thu lai.");
                    break;
            }
        } catch (RuntimeException ex) {
            // Log loi that tren server, khong hien chi tiet loi DB ra giao dien.
            getServletContext().log("Loi he thong khi doi mat khau", ex);
            req.setAttribute("errorMsg", "He thong dang gap su co, vui long thu lai sau.");
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/change-password.jsp").forward(req, resp);
    }
}