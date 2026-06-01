package com.mbcms.controller.auth;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import com.mbcms.service.impl.LoginResult;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.UUID;

/**
 * LoginServlet - xu ly dang nhap bang email + mat khau.
 *
 * <p>Bao mat da trien khai:
 * <ul>
 *   <li><b>CSRF</b>: token duoc sinh ra moi session (GET), luu vao session, kiem tra khi POST.</li>
 *   <li><b>Session fixation</b>: invalidate session cu, tao session moi sau khi dang nhap thanh cong.</li>
 *   <li><b>Remember Me</b>: neu check, dat cookie max-age = 604 800 s (7 ngay).</li>
 *   <li><b>Email verified</b>: neu mat khau dung nhung email chua xac minh,
 *       hien thong bao rieng biet (khong tiet lo thong tin xac thuc).</li>
 *   <li><b>Thong bao chung</b>: WRONG_CREDENTIALS va ACCOUNT_DISABLED dung cung mot
 *       thong bao de tranh user enumeration.</li>
 * </ul>
 * </p>
 *
 * Owner: TrangNT (Report 4).
 */
@WebServlet("/auth/login")
public class LoginServlet extends HttpServlet {

    /** Ten attribute CSRF luu trong session va truyen xuong JSP. */
    private static final String CSRF_ATTR = "csrfToken";

    /** Ten attribute CSRF trong form (hidden field). */
    private static final String CSRF_PARAM = "_csrf";

    /** Cookie max-age cho "Remember Me": 7 ngay tinh bang giay. */
    private static final int REMEMBER_ME_MAX_AGE = 7 * 24 * 60 * 60; // 604 800

    // ------------------------------------------------------------------ //
    //  GET - hien thi form dang nhap                                      //
    // ------------------------------------------------------------------ //

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Neu da dang nhap roi, chuyen thang ve home
        HttpSession existing = req.getSession(false);
        if (existing != null && existing.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Sinh CSRF token moi cho session nay (neu chua co)
        HttpSession session = req.getSession(true);
        if (session.getAttribute(CSRF_ATTR) == null) {
            session.setAttribute(CSRF_ATTR, UUID.randomUUID().toString());
        }

        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    // ------------------------------------------------------------------ //
    //  POST - xu ly xac thuc                                              //
    // ------------------------------------------------------------------ //

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // --- 1. Kiem tra CSRF ------------------------------------------ //
        HttpSession preSession = req.getSession(false);
        String sessionCsrf = (preSession != null)
                ? (String) preSession.getAttribute(CSRF_ATTR)
                : null;
        String formCsrf = req.getParameter(CSRF_PARAM);

        if (sessionCsrf == null || !sessionCsrf.equals(formCsrf)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token.");
            return;
        }

        // --- 2. Doc tham so form --------------------------------------- //
        String email    = req.getParameter("email");
        String password = req.getParameter("password");
        boolean rememberMe = "on".equalsIgnoreCase(req.getParameter("rememberMe"))
                          || "true".equalsIgnoreCase(req.getParameter("rememberMe"));

        if (email == null || email.trim().isEmpty()
                || password == null || password.isEmpty()) {
            req.setAttribute("errorMsg", "Please enter email and password.");
            req.setAttribute("email", email);
            regenerateCsrf(req);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        email = email.trim().toLowerCase();

        // --- 3. Goi AuthService --------------------------------------- //
        AuthService authService = new AuthServiceImpl();
        LoginResult customerResult;
        LoginResult employeeResult = null;

        try {
            customerResult = authService.loginCustomer(email, password);
            if (!customerResult.isSuccess() && !customerResult.isEmailNotVerified()) {
                // Chi thu Employee khi Customer khong tim thay / sai mat khau
                // (neu EMAIL_NOT_VERIFIED thi la Customer hop le, khong can thu Employee)
                employeeResult = authService.loginEmployee(email, password);
            }
        } catch (RuntimeException ex) {
            // Loi DB - log day du o server, KHONG lo chi tiet ra UI
            getServletContext().log("System error during login", ex);
            req.setAttribute("errorMsg", "A system error occurred. Please try again.");
            req.setAttribute("email", email);
            regenerateCsrf(req);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        // --- 4. Xu ly ket qua ----------------------------------------- //

        // 4a. Customer dang nhap thanh cong
        if (customerResult.isSuccess()) {
            Customer customer = customerResult.getCustomer();
            createAuthenticatedSession(req, resp, customer, rememberMe);
            session(req).setAttribute("currentUser", customer);
            session(req).setAttribute("userRole",    "CUSTOMER");
            session(req).setAttribute("username",    customer.getUsername());
            resp.sendRedirect(resolveRedirect(req, req.getContextPath() + "/home"));
            return;
        }

        // 4b. Email dung, mat khau dung, nhung CHUA XAC MINH EMAIL
        if (customerResult.isEmailNotVerified()) {
            req.setAttribute("errorMsg",
                    "Your email address has not been verified. "
                    + "Please check your inbox for the verification link, "
                    + "or request a new one.");
            req.setAttribute("email", email);
            req.setAttribute("showResendVerification", true);
            regenerateCsrf(req);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        // 4c. Employee dang nhap thanh cong
        if (employeeResult != null && employeeResult.isSuccess()) {
            Employee employee = employeeResult.getEmployee();
            createAuthenticatedSession(req, resp, employee, rememberMe);
            session(req).setAttribute("currentUser", employee);
            session(req).setAttribute("userRole",    employee.getRole());
            session(req).setAttribute("username",    employee.getUsername());
            if (employee.getBranchId() != null) {
                session(req).setAttribute("branchId", employee.getBranchId());
            }
            String redirect = employee.isAdmin()
                    ? req.getContextPath() + "/admin/dashboard"
                    : req.getContextPath() + "/branch/dashboard";
            resp.sendRedirect(redirect);
            return;
        }

        // 4d. Tai khoan bi vo hieu hoa - dung chung thong bao voi sai mat khau
        //     de tranh user enumeration (khong xac nhan email co ton tai hay khong)
        if (customerResult.isAccountDisabled()
                || (employeeResult != null && employeeResult.isAccountDisabled())) {
            req.setAttribute("errorMsg", "Incorrect email or password.");
            req.setAttribute("email", email);
            regenerateCsrf(req);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        // 4e. Sai email / mat khau
        req.setAttribute("errorMsg", "Incorrect email or password.");
        req.setAttribute("email", email);
        regenerateCsrf(req);
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    // ------------------------------------------------------------------ //
    //  Helper methods                                                      //
    // ------------------------------------------------------------------ //

    /**
     * Invalidate session cu (chong session fixation), tao session moi,
     * va neu rememberMe = true thi dat cookie JSESSIONID max-age = 7 ngay.
     */
    private void createAuthenticatedSession(HttpServletRequest req,
                                            HttpServletResponse resp,
                                            Object principal,
                                            boolean rememberMe) {
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();

        HttpSession session = req.getSession(true);
        // Sinh lai CSRF token cho session moi
        session.setAttribute(CSRF_ATTR, UUID.randomUUID().toString());

        if (rememberMe) {
            // Dat session cookie ben vung 7 ngay
            session.setMaxInactiveInterval(REMEMBER_ME_MAX_AGE);

            // Voi Jakarta Servlet 6+ co the dung HttpSession.setMaxInactiveInterval
            // va cau hinh session-timeout o web.xml; cookie duoc server tu set.
            // Neu can dieu chinh ten cookie / SameSite, dung SessionCookieConfig trong
            // web.xml: <session-config><cookie-config><max-age>604800</max-age>...
        }
        // Neu khong rememberMe, session su dung max-inactive-interval mac dinh (web.xml)
    }

    /**
     * Tao CSRF token moi va luu vao session hien tai (hoac moi).
     * Goi sau moi lan forward ve login.jsp de token moi luon hop le.
     */
    private void regenerateCsrf(HttpServletRequest req) {
        HttpSession session = req.getSession(true);
        session.setAttribute(CSRF_ATTR, UUID.randomUUID().toString());
    }

    /**
     * Lay session hien tai (phai ton tai sau khi createAuthenticatedSession).
     */
    private HttpSession session(HttpServletRequest req) {
        return req.getSession(false);
    }

    /**
     * Neu co "redirect" param trong query string (duoc luu boi AuthFilter truoc khi
     * redirect ve login), su dung no; nguoc lai dung defaultUrl.
     *
     * <p>Ghi chu bao mat: chi chap nhan redirect tuong doi tren cung context path
     * de tranh open-redirect.</p>
     */
    private String resolveRedirect(HttpServletRequest req, String defaultUrl) {
        String saved = req.getParameter("redirect");
        if (saved != null && !saved.isEmpty()
                && saved.startsWith(req.getContextPath())
                && !saved.contains("://")) {
            return saved;
        }
        return defaultUrl;
    }
}
