package com.mbcms.controller.auth;

import com.mbcms.model.Customer;
import com.mbcms.service.AuthService;
import com.mbcms.service.impl.AuthServiceImpl;
import com.mbcms.util.EmailUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.security.SecureRandom;
import org.mindrot.jbcrypt.BCrypt;

/**
 * ForgotPasswordServlet - Handles the 3-step password recovery wizard (UC11).
 * URL mapping: /auth/forgot-password
 */
@WebServlet("/auth/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final AuthService authService = new AuthServiceImpl();
    private final SecureRandom random = new SecureRandom();

    /**
     * Display the forgot password wizard.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // If a user is already logged in, redirect them to the home page
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        // Forward request to the JSP view
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    /**
     * Process submissions from all 3 steps of the wizard.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        // Action dispatcher depending on wizard step
        switch (action) {
            case "send-code":
                handleSendCode(req, resp);
                break;
            case "verify-code":
                handleVerifyCode(req, resp);
                break;
            case "reset-password":
                handleResetPassword(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
                break;
        }
    }

    /**
     * Step 1: Validate email exists and is active -> Generate OTP -> Hash and
     * store it -> Send OTP via email.
     */
    private void handleSendCode(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        if (email != null) {
            email = email.trim();
        }

        // Check if the input is empty
        if (email == null || email.isEmpty()) {
            req.setAttribute("errorMsg", "Please enter your email address.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Retrieve active customer by email address
        Customer customer = authService.getActiveCustomerByEmail(email);
        if (customer == null) {
            // Precondition: User account with the submitted email exists and is active.
            req.setAttribute("errorMsg", "This email address is not registered or the account is inactive.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        HttpSession session = req.getSession(true);

        // Limit maximum resend requests to 3
        Integer resendCount = (Integer) session.getAttribute("forgot_resend_count");
        String lastResendEmail = (String) session.getAttribute("forgot_email");

        if (resendCount == null || !email.equalsIgnoreCase(lastResendEmail)) {
            resendCount = 0;
        }

        if (resendCount >= 3) {
            req.setAttribute("errorMsg", "You have exceeded the maximum of 3 resends. Please try again later.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Generate 6-digit numeric OTP (100000 - 999999)
        String otpCode = String.valueOf(100000 + random.nextInt(900000));

        // Hash the plaintext OTP code using BCrypt before storing it in DB
        String hashedOtp = BCrypt.hashpw(otpCode, BCrypt.gensalt(10));

        // Store the OTP hash in customers.reset_token in database
        boolean updated = authService.setResetToken(customer.getUsername(), hashedOtp);
        if (!updated) {
            req.setAttribute("errorMsg", "An error occurred while preparing your request. Please try again.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Send the plaintext OTP via email (Plaintext OTP is only sent via email and never stored)
        boolean emailSent = EmailUtil.sendOTPEmail(email, otpCode);
        if (!emailSent) {
            // If email fails to send, rollback reset token database field for security
            authService.setResetToken(customer.getUsername(), null);
            req.setAttribute("errorMsg", "Failed to send email verification code. Please check your email configuration.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Store state details in session for Step 2 validation
        session.setAttribute("forgot_email", email);
        session.setAttribute("forgot_username", customer.getUsername());
        session.setAttribute("forgot_otp_expiry", System.currentTimeMillis() + (15 * 60 * 1000)); // Expiry: 15 minutes
        session.setAttribute("forgot_failed_attempts", 0); // Initialize failed attempts counter
        session.setAttribute("forgot_resend_count", resendCount + 1); // Increment resend counter

        req.setAttribute("successMsg", "A 6-digit verification code has been sent to your email.");
        req.setAttribute("email", email);
        req.setAttribute("step", "verify"); // Set current wizard step to 2
        req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
    }

    /**
     * Step 2: Verify the user-entered OTP against the stored hash in
     * customers.reset_token.
     */
    private void handleVerifyCode(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String code = req.getParameter("code");

        if (email != null) {
            email = email.trim();
        }
        if (code != null) {
            code = code.trim();
        }

        HttpSession session = req.getSession(false);

        // Security check: Verify email matches session context
        if (session == null || email == null || !email.equalsIgnoreCase((String) session.getAttribute("forgot_email"))) {
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        // Check if OTP has expired (Expiry: 15 minutes)
        Long expiryTime = (Long) session.getAttribute("forgot_otp_expiry");
        if (expiryTime == null || System.currentTimeMillis() > expiryTime) {
            // Clear database token on expiry for security
            String username = (String) session.getAttribute("forgot_username");
            if (username != null) {
                authService.setResetToken(username, null);
            }
            req.setAttribute("errorMsg", "Your verification code has expired (15 minutes). Please request a new one.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Retrieve attempts count
        Integer failedAttempts = (Integer) session.getAttribute("forgot_failed_attempts");
        if (failedAttempts == null) {
            failedAttempts = 0;
        }

        // Pre-check for lockout condition (Max 3 failed attempts before lockout)
        if (failedAttempts >= 3) {
            lockoutUser(session);
            req.setAttribute("errorMsg", "This verification session has been locked due to too many failed attempts. Please start over.");
            req.setAttribute("step", "email");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Retrieve customer details from database to compare OTP
        Customer customer = authService.getActiveCustomerByEmail(email);
        if (customer == null || customer.getResetToken() == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        // Compare the plaintext OTP entered by user against the stored BCrypt hash value
        if (BCrypt.checkpw(code, customer.getResetToken())) {
            // OTP is valid
            session.setAttribute("forgot_otp_verified", true);
            session.setAttribute("forgot_verified_code", code); // Save verified code to match in Step 3

            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.setAttribute("step", "reset"); // Move wizard to Step 3
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
        } else {
            // Increment failed attempt counter
            failedAttempts++;
            session.setAttribute("forgot_failed_attempts", failedAttempts);

            // Check if user has hit the maximum of 3 failed attempts (lockout threshold)
            if (failedAttempts >= 3) {
                lockoutUser(session);
                req.setAttribute("errorMsg", "You have entered an incorrect code 3 times. This verification session has been locked. Please start over.");
                req.setAttribute("step", "email");
            } else {
                req.setAttribute("errorMsg", "Incorrect verification code. You have " + (3 - failedAttempts) + " attempts remaining.");
                req.setAttribute("email", email);
                req.setAttribute("step", "verify");
            }
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
        }
    }

    /**
     * Lockout helper: Clears the reset token in the database and cleans up
     * temporary session attributes.
     */
    private void lockoutUser(HttpSession session) {
        String username = (String) session.getAttribute("forgot_username");
        if (username != null) {
            authService.setResetToken(username, null);
        }
        // Remove temporary recovery verification attributes
        session.removeAttribute("forgot_email");
        session.removeAttribute("forgot_username");
        session.removeAttribute("forgot_otp_expiry");
        session.removeAttribute("forgot_failed_attempts");
        session.removeAttribute("forgot_otp_verified");
        session.removeAttribute("forgot_verified_code");
    }

    /**
     * Step 3: Validate the new password -> Hash it via BCrypt -> Store it ->
     * Clear the reset token.
     */
    private void handleResetPassword(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String email = req.getParameter("email");
        String code = req.getParameter("code");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        if (email != null) {
            email = email.trim();
        }
        if (code != null) {
            code = code.trim();
        }

        HttpSession session = req.getSession(false);

        // Security check: Ensure that the session has completed Step 2 verification successfully
        if (session == null
                || email == null
                || !email.equalsIgnoreCase((String) session.getAttribute("forgot_email"))
                || session.getAttribute("forgot_otp_verified") == null
                || !((Boolean) session.getAttribute("forgot_otp_verified"))
                || code == null
                || !code.equals(session.getAttribute("forgot_verified_code"))) {

            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        // Validate that new password and confirm password fields match
        if (password == null || confirmPassword == null || !password.equals(confirmPassword)) {
            req.setAttribute("errorMsg", "Passwords do not match.");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.setAttribute("step", "reset");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Validate password strength: Min 8 – max 64 chars. Must have ≥1 uppercase and ≥1 digit.
        if (!isValidPassword(password)) {
            req.setAttribute("errorMsg", "Password must be 8-64 characters and contain at least one uppercase letter and one digit.");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.setAttribute("step", "reset");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
            return;
        }

        String username = (String) session.getAttribute("forgot_username");
        if (username == null) {
            resp.sendRedirect(req.getContextPath() + "/auth/forgot-password");
            return;
        }

        // Hash the new password using BCrypt (work factor 10)
        String newPasswordHash = BCrypt.hashpw(password, BCrypt.gensalt(10));

        // Update database with the new password hash and clear the reset token in a combined process
        boolean success = authService.resetPasswordAndClearToken(username, newPasswordHash);
        if (success) {
            // Clean up all password recovery session variables
            session.removeAttribute("forgot_email");
            session.removeAttribute("forgot_username");
            session.removeAttribute("forgot_otp_expiry");
            session.removeAttribute("forgot_failed_attempts");
            session.removeAttribute("forgot_resend_count");
            session.removeAttribute("forgot_otp_verified");
            session.removeAttribute("forgot_verified_code");

            // Redirect user to the login screen with a success flag parameter
            resp.sendRedirect(req.getContextPath() + "/auth/login?resetSuccess=true");
        } else {
            req.setAttribute("errorMsg", "Failed to update your password. Please try again.");
            req.setAttribute("email", email);
            req.setAttribute("code", code);
            req.setAttribute("step", "reset");
            req.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(req, resp);
        }
    }

    /**
     * Password validation logic: Min 8 – max 64 chars. Must contain at least 1
     * uppercase letter and 1 digit.
     */
    private boolean isValidPassword(String password) {
        if (password == null || password.length() < 8 || password.length() > 64) {
            return false;
        }
        boolean hasUppercase = false;
        boolean hasDigit = false;
        for (char c : password.toCharArray()) {
            if (Character.isUpperCase(c)) {
                hasUppercase = true;
            } else if (Character.isDigit(c)) {
                hasDigit = true;
            }
        }
        return hasUppercase && hasDigit;
    }
}
