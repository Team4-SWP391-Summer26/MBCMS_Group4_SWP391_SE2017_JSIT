package com.mbcms.controller.auth;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Customer;
import com.mbcms.util.EmailUtil;
import com.mbcms.util.ValidationUtil;
import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Random;

@WebServlet("/auth/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAOImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Mac dinh vao Step 1: Nhap email
        req.setAttribute("step", "email");
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String email = req.getParameter("email");

        if (email != null) {
            email = email.trim();
        }

        try {
            if ("send-code".equals(action)) {
                handleSendCode(req, resp, email);
            } else if ("verify-code".equals(action)) {
                handleVerifyCode(req, resp, email);
            } else if ("reset-password".equals(action)) {
                handleResetPassword(req, resp, email);
            } else {
                resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            }
        } catch (Exception ex) {
            getServletContext().log("Loi trong ForgotPasswordServlet", ex);
            req.setAttribute("errorMsg", "Hệ thống đang gặp sự cố. Vui lòng thử lại sau.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
        }
    }

    /**
     * Step 1: Validate email -> Generate OTP -> Hash OTP -> Store in reset_token -> Send email.
     */
    private void handleSendCode(HttpServletRequest req, HttpServletResponse resp, String email)
            throws ServletException, IOException {

        if (ValidationUtil.isNullOrEmpty(email) || !ValidationUtil.isValidEmail(email)) {
            req.setAttribute("errorMsg", "Email không hợp lệ.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        Customer customer = customerDAO.findByEmail(email);
        if (customer == null || !customer.isActive()) {
            req.setAttribute("errorMsg", "Email không tồn tại hoặc tài khoản đã bị khóa.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Kiem tra so lan resend (Max 3 resends)
        String currentToken = customer.getResetToken();
        int resendCount = 0;
        if (currentToken != null && currentToken.contains(";")) {
            String[] parts = currentToken.split(";");
            if (parts.length >= 4) {
                try {
                    resendCount = Integer.parseInt(parts[3]);
                } catch (NumberFormatException ignored) {}
            }
        }

        if (resendCount >= 3) {
            req.setAttribute("errorMsg", "Bạn đã yêu cầu gửi mã OTP quá giới hạn (tối đa 3 lần). Vui lòng thử lại sau.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Tao OTP 6 chu so ngau nhien
        String otp = String.format("%06d", new Random().nextInt(1000000));
        String otpHash = hashSHA256(otp);
        long expiryTime = System.currentTimeMillis() + 15 * 60 * 1000; // 15 phut hieu luc

        // Dinh dang reset_token: otp_hash;expiry_timestamp;failed_attempts;resend_count
        String resetTokenVal = otpHash + ";" + expiryTime + ";0;" + (resendCount + 1);

        // Cap nhat vao DB
        customerDAO.updateResetToken(customer.getUsername(), resetTokenVal);

        // Gui email chua OTP plaintext
        String emailBody = "<div style=\"font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 8px;\">"
                + "<div style=\"background-color: #0c1a30; padding: 15px; text-align: center; border-radius: 8px 8px 0 0; color: white;\">"
                + "<h2 style=\"margin: 0; font-size: 24px;\">MBCMS Cinema</h2>"
                + "</div>"
                + "<div style=\"padding: 20px; color: #333333; line-height: 1.6;\">"
                + "<p>Xin chào,</p>"
                + "<p>Bạn đã yêu cầu khôi phục mật khẩu cho tài khoản tại hệ thống quản lý rạp phim <strong>MBCMS</strong>.</p>"
                + "<p>Mã xác thực OTP của bạn là:</p>"
                + "<div style=\"text-align: center; margin: 30px 0;\">"
                + "<span style=\"font-size: 32px; font-weight: bold; letter-spacing: 5px; color: #2563eb; background-color: #f3f4f6; padding: 10px 20px; border-radius: 6px; border: 1px dashed #2563eb;\">" + otp + "</span>"
                + "</div>"
                + "<p style=\"color: #ef4444; font-weight: bold;\">Mã xác thực có hiệu lực trong vòng 15 phút và chỉ sử dụng được 1 lần.</p>"
                + "<p>Nếu bạn không gửi yêu cầu này, vui lòng bỏ qua email hoặc liên hệ với bộ phận hỗ trợ của chúng tôi.</p>"
                + "</div>"
                + "<div style=\"background-color: #f9fafb; padding: 15px; text-align: center; border-radius: 0 0 8px 8px; font-size: 12px; color: #6b7280; border-top: 1px solid #e0e0e0;\">"
                + "Đây là email tự động từ hệ thống MBCMS. Vui lòng không trả lời email này."
                + "</div>"
                + "</div>";

        try {
            EmailUtil.sendEmail(email, "[MBCMS] Mã xác thực khôi phục mật khẩu", emailBody);
        } catch (Exception ex) {
            getServletContext().log("Loi khi gui email OTP", ex);
        }

        req.setAttribute("step", "verify");
        req.setAttribute("email", email);
        req.setAttribute("successMsg", "Mã xác thực đã được gửi tới email của bạn. Vui lòng kiểm tra hộp thư.");
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    /**
     * Step 2: Verify OTP against stored hash. Expiry: 15 minutes. Max 3 failed attempts lockout.
     */
    private void handleVerifyCode(HttpServletRequest req, HttpServletResponse resp, String email)
            throws ServletException, IOException {
        String code = req.getParameter("code");

        if (ValidationUtil.isNullOrEmpty(email) || ValidationUtil.isNullOrEmpty(code) || code.length() != 6) {
            req.setAttribute("errorMsg", "Mã xác thực không hợp lệ.");
            req.setAttribute("step", "verify");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        Customer customer = customerDAO.findByEmail(email);
        if (customer == null || !customer.isActive() || customer.getResetToken() == null) {
            req.setAttribute("errorMsg", "Yêu cầu khôi phục không hợp lệ hoặc đã hết hiệu lực.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Parse reset_token: otp_hash;expiry_timestamp;failed_attempts;resend_count
        String[] parts = customer.getResetToken().split(";");
        if (parts.length < 4) {
            req.setAttribute("errorMsg", "Yêu cầu không hợp lệ. Vui lòng gửi lại yêu cầu.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        String storedHash = parts[0];
        long expiryTime = Long.parseLong(parts[1]);
        int failedAttempts = Integer.parseInt(parts[2]);
        int resendCount = Integer.parseInt(parts[3]);

        // Kiem tra thoi gian het han (15 phut)
        if (System.currentTimeMillis() > expiryTime) {
            req.setAttribute("errorMsg", "Mã xác thực đã hết hạn (hiệu lực 15 phút). Vui lòng yêu cầu mã mới.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Kiem tra khoa do nhap sai qua 3 lan
        if (failedAttempts >= 3) {
            req.setAttribute("errorMsg", "Yêu cầu khôi phục này đã bị khóa do nhập sai mã quá 3 lần. Vui lòng yêu cầu gửi lại mã mới.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // So sanh hash cua code nguoi dung nhap vao
        String inputHash = hashSHA256(code.trim());
        if (!storedHash.equals(inputHash)) {
            int newFailedAttempts = failedAttempts + 1;
            // Cap nhat so lan thu sai vao DB
            String updatedToken = storedHash + ";" + expiryTime + ";" + newFailedAttempts + ";" + resendCount;
            customerDAO.updateResetToken(customer.getUsername(), updatedToken);

            if (newFailedAttempts >= 3) {
                req.setAttribute("errorMsg", "Bạn đã nhập sai mã xác thực 3 lần. Yêu cầu khôi phục này đã bị khóa. Vui lòng gửi lại mã mới.");
                req.setAttribute("step", "email");
            } else {
                req.setAttribute("errorMsg", "Mã xác thực không chính xác. Bạn còn " + (3 - newFailedAttempts) + " lần thử.");
                req.setAttribute("step", "verify");
                req.setAttribute("email", email);
            }
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Xac thuc thanh cong -> Chuyen sang Step 3
        req.setAttribute("step", "reset");
        req.setAttribute("email", email);
        req.setAttribute("code", code); // Truyen ma de Step 3 tai xac thuc tranh bypass
        req.setAttribute("successMsg", "Xác thực mã OTP thành công! Vui lòng đặt mật khẩu mới.");
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    /**
     * Step 3: New password validation -> Hash -> Update to DB -> Clear reset_token.
     */
    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp, String email)
            throws ServletException, IOException {
        String code = req.getParameter("code");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (ValidationUtil.isNullOrEmpty(email) || ValidationUtil.isNullOrEmpty(code)
                || ValidationUtil.isNullOrEmpty(password) || ValidationUtil.isNullOrEmpty(confirmPassword)) {
            req.setAttribute("errorMsg", "Vui lòng nhập đầy đủ thông tin mật khẩu.");
            req.setAttribute("step", "reset");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Validate mat khau khớp nhau
        if (!password.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "Mật khẩu xác nhận không trùng khớp.");
            req.setAttribute("step", "reset");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Validate password do phuc tap: 8-64 chars, >=1 chu hoa, >=1 chu so
        if (password.length() < 8 || password.length() > 64) {
            req.setAttribute("errorMsg", "Mật khẩu phải từ 8 đến 64 ký tự.");
            req.setAttribute("step", "reset");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        boolean hasUpper = false;
        boolean hasDigit = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) hasUpper = true;
            else if (Character.isDigit(c)) hasDigit = true;
        }
        if (!hasUpper || !hasDigit) {
            req.setAttribute("errorMsg", "Mật khẩu phải chứa ít nhất 1 chữ hoa và ít nhất 1 chữ số.");
            req.setAttribute("step", "reset");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        Customer customer = customerDAO.findByEmail(email);
        if (customer == null || !customer.isActive() || customer.getResetToken() == null) {
            req.setAttribute("errorMsg", "Yêu cầu khôi phục không hợp lệ hoặc đã hết hiệu lực.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Tai xac thuc de bao mat, ngan chan viec goi truc tiep API reset
        String[] parts = customer.getResetToken().split(";");
        if (parts.length < 4) {
            req.setAttribute("errorMsg", "Yêu cầu khôi phục không hợp lệ.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        String storedHash = parts[0];
        long expiryTime = Long.parseLong(parts[1]);
        int failedAttempts = Integer.parseInt(parts[2]);

        if (System.currentTimeMillis() > expiryTime || failedAttempts >= 3 || !storedHash.equals(hashSHA256(code.trim()))) {
            req.setAttribute("errorMsg", "Mã xác thực đã hết hạn hoặc không khớp. Vui lòng yêu cầu mã mới.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Hash mat khau moi bang BCrypt work-factor 10
        String hashedPw = BCrypt.hashpw(password, BCrypt.gensalt(10));

        // Luu vao DB va xoa reset_token (dat reset_token = NULL)
        boolean success = customerDAO.updatePasswordHash(customer.getUsername(), hashedPw);
        if (success) {
            req.getSession().setAttribute("successMsg", "Mật khẩu của bạn đã được đặt lại thành công! Vui lòng đăng nhập.");
            resp.sendRedirect(req.getContextPath() + "/auth/login");
        } else {
            req.setAttribute("errorMsg", "Không thể cập nhật mật khẩu. Vui lòng thử lại.");
            req.setAttribute("step", "reset");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
        }
    }

    /**
     * Helper hash SHA-256
     */
    private String hashSHA256(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes(StandardCharsets.UTF_8));
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Loi hash SHA-256: " + e.getMessage(), e);
        }
    }
}
