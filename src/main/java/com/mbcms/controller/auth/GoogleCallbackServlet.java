package com.mbcms.controller.auth;

import com.mbcms.model.Customer;
import com.mbcms.service.GoogleOAuthService;
import com.mbcms.service.impl.GoogleOAuthServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

/**
 * GoogleCallbackServlet - Buoc 2 trong OAuth 2.0 Authorization Code Flow.
 *
 * GET /auth/google/callback (Google redirect sau khi nguoi dung dong y) -> Kiem
 * tra state chong CSRF. -> Doi code lay access_token. -> Lay thong tin nguoi
 * dung tu Google. -> Tim hoac tao Customer trong DB. -> Ghi session giong
 * LoginServlet roi redirect /home.
 *
 * Neu co loi -> redirect /auth/login?googleError=true de hien thong bao.
 */
@WebServlet("/auth/google/callback")
public class GoogleCallbackServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ---- 1. Kiem tra loi tu phia Google (nguoi dung tu choi) ----
        String error = req.getParameter("error");
        if (error != null) {
            // Nguoi dung bam "Cancel" tren trang Google -> ve trang login binh thuong
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // ---- 2. Kiem tra CSRF state ----
        String returnedState = req.getParameter("state");
        HttpSession session = req.getSession(false);
        String savedState = (session != null)
                ? (String) session.getAttribute("oauth_state")
                : null;

        if (returnedState == null || !returnedState.equals(savedState)) {
            getServletContext().log("Google OAuth CSRF state mismatch!");
            redirectWithError(req, resp, "invalid_state");
            return;
        }
        // Xoa state da dung (one-time)
        session.removeAttribute("oauth_state");

        // ---- 3. Lay authorization code ----
        String code = req.getParameter("code");
        if (code == null || code.trim().isEmpty()) {
            redirectWithError(req, resp, "no_code");
            return;
        }

        // ---- 4. Goi Google API: code -> token -> user info -> Customer ----
        GoogleOAuthService oauthService = new GoogleOAuthServiceImpl();
        Customer customer;

        try {
            String accessToken = oauthService.exchangeCodeForToken(code);
            customer = oauthService.loginWithGoogle(accessToken);
        } catch (RuntimeException ex) {
            String msg = ex.getMessage();
            getServletContext().log("Google OAuth error: " + msg, ex);
            if ("TAI_KHOAN_BI_KHOA".equals(msg)) {
                redirectWithError(req, resp, "account_locked");
            } else {
                redirectWithError(req, resp, "server_error");
            }
            return;
        }

        // ---- 5. Ghi session (giong het LoginServlet) ----
        HttpSession old = req.getSession(false);
        if (old != null) {
            old.invalidate();
        }
        HttpSession newSession = req.getSession(true);
        newSession.setAttribute("currentUser", customer);
        newSession.setAttribute("userRole", "CUSTOMER");
        newSession.setAttribute("username", customer.getUsername());

        resp.sendRedirect(req.getContextPath() + "/home");
    }

    // ------------------------------------------------------------------
    private void redirectWithError(HttpServletRequest req,
            HttpServletResponse resp,
            String errorCode) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/auth/login?googleError=" + errorCode);
    }
}
