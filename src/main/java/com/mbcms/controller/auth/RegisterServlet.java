package com.mbcms.controller.auth;

import com.mbcms.model.Customer;
import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import com.mbcms.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * RegisterServlet - owner: <b>HoangHM</b> (Report 4).
 */
@WebServlet("/auth/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        String username        = req.getParameter("username");
        String fullName        = req.getParameter("fullName");
        String email           = req.getParameter("email");
        String phone           = req.getParameter("phone");
        String password        = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // 1. Kiem tra cac truong bat buoc
        if (ValidationUtil.isNullOrEmpty(username)
                || ValidationUtil.isNullOrEmpty(fullName)
                || ValidationUtil.isNullOrEmpty(email)
                || ValidationUtil.isNullOrEmpty(password)
                || ValidationUtil.isNullOrEmpty(confirmPassword)) {
            
            req.setAttribute("errorMsg", "Vui lòng nhập đầy đủ các thông tin bắt buộc.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        username = username.trim();
        fullName = fullName.trim();
        email    = email.trim();
        if (phone != null) {
            phone = phone.trim();
        }

        // 2. Validate dinh dang email
        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("errorMsg", "Email không đúng định dạng hợp lệ.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 3. Validate dinh dang so dien thoai (neu nhap)
        if (!ValidationUtil.isNullOrEmpty(phone) && !ValidationUtil.isValidPhone(phone)) {
            req.setAttribute("errorMsg", "Số điện thoại không đúng định dạng Việt Nam.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 4. Validate do manh mat khau (toi thieu 8 ky tu, chu hoa, thuong, so)
        if (!ValidationUtil.isValidPassword(password)) {
            req.setAttribute("errorMsg", "Mật khẩu tối thiểu 8 ký tự, chứa chữ hoa, chữ thường và chữ số.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // 5. Kiem tra mat khau xac nhan trung khop
        if (!password.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "Mật khẩu xác nhận không khớp.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        // Khoi tao Customer
        Customer customer = new Customer();
        customer.setUsername(username);
        customer.setFullName(fullName);
        customer.setEmail(email);
        customer.setPhone(ValidationUtil.isNullOrEmpty(phone) ? null : phone);

        AuthService authService = new AuthServiceImpl();

        try {
            boolean success = authService.registerCustomer(customer, password);
            if (success) {
                // Dang ky thanh cong -> chuyen huong toi trang dang nhap
                resp.sendRedirect(req.getContextPath() + "/auth/login?registered=true");
            } else {
                req.setAttribute("errorMsg", "Đăng ký không thành công. Vui lòng thử lại.");
                req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            }
        } catch (IllegalArgumentException ex) {
            // Loi nghiep vu (username/email da ton tai)
            req.setAttribute("errorMsg", ex.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        } catch (RuntimeException ex) {
            // Loi he thong, ghi log va thong bao chung chung
            getServletContext().log("Loi he thong khi dang ky tai khoan cho: " + username, ex);
            req.setAttribute("errorMsg", "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}
