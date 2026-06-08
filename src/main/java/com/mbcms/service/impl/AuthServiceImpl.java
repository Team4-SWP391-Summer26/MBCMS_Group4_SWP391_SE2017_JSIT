package com.mbcms.service.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.EmployeeDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.dao.impl.EmployeeDAOImpl;
import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.AuthService;
import org.mindrot.jbcrypt.BCrypt;

/**
 * AuthServiceImpl - xu ly business logic xac thuc. Dung BCrypt (jBCrypt) de
 * verify password, khong bao gio so sanh plaintext.
 */
public class AuthServiceImpl implements AuthService {

    private final CustomerDAO customerDAO;
    private final EmployeeDAO employeeDAO;

    public AuthServiceImpl() {
        this.customerDAO = new CustomerDAOImpl();
        this.employeeDAO = new EmployeeDAOImpl();
    }

    // Constructor de inject (unit test)
    public AuthServiceImpl(CustomerDAO customerDAO, EmployeeDAO employeeDAO) {
        this.customerDAO = customerDAO;
        this.employeeDAO = employeeDAO;
    }

    /**
     * Xac thuc Customer.
     *
     * @return Customer neu hop le, null neu sai loginId/password hoac bi khoa.
     */
    @Override
    public Customer loginCustomer(String loginId, String rawPassword) {
        if (loginId == null || rawPassword == null) {
            return null;
        }

        Customer customer = customerDAO.findByEmail(loginId);
        if (customer == null) {
            return null;
        }

        // Kiem tra tai khoan con active
        if (!customer.isActive()) {
            return null;
        }

        // BCrypt verify
        if (!BCrypt.checkpw(rawPassword, customer.getPasswordHash())) {
            return null;
        }

        return customer;
    }

    /**
     * Xac thuc Employee (staff/admin).
     *
     * @return Employee neu hop le, null neu sai hoac bi khoa.
     */
    @Override
    public Employee loginEmployee(String loginId, String rawPassword) {
        if (loginId == null || rawPassword == null) {
            return null;
        }

        Employee employee = employeeDAO.findByUsername(loginId);
        if (employee == null) {
            return null;
        }

        if (!employee.isActive()) {
            return null;
        }

        if (!BCrypt.checkpw(rawPassword, employee.getPasswordHash())) {
            return null;
        }

        return employee;
    }

    /**
     * Dang ky tai khoan Customer moi. Hash password bang BCrypt work-factor 10
     * truoc khi luu.
     */
    @Override
    public boolean registerCustomer(Customer customer, String rawPassword) {
        if (customer == null || rawPassword == null || rawPassword.trim().isEmpty()) {
            return false;
        }

        // Kiem tra ten dang nhap ton tai
        if (customerDAO.findByUsername(customer.getUsername()) != null) {
            throw new IllegalArgumentException("Tên đăng nhập đã tồn tại trong hệ thống.");
        }

        // Kiem tra email ton tai
        if (customerDAO.existsByEmail(customer.getEmail())) {
            throw new IllegalArgumentException("Email đã được sử dụng bởi tài khoản khác.");
        }

        // Hash password bang BCrypt
        String hashed = BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));
        customer.setPasswordHash(hashed);

        // Sinh token xac thuc ngau nhien
        String token = java.util.UUID.randomUUID().toString();
        customer.setResetToken(token);

        // Cac thiet lap mac dinh
        customer.setActive(true);
        customer.setEmailVerified(false);
        customer.setCreatedAt(java.time.LocalDateTime.now());

        // Luu vao CSDL va gui email xac thuc bat dong bo
        boolean success = customerDAO.insert(customer);
        if (success) {
            final String email = customer.getEmail();
            final String username = customer.getUsername();
            final String verifyToken = token;
            new Thread(() -> {
                String verifyLink = "http://localhost:9999/MBCMS/auth/verify?username=" + username + "&token=" + verifyToken;
                com.mbcms.util.EmailUtil.sendVerificationEmail(email, username, verifyLink);
            }).start();
        }
        return success;
    }

    /**
     * Doi mat khau cho customer/employee dang dang nhap. Luong xu ly: 1. Kiem
     * tra input rong. 2. Tim user theo username va role trong session. 3. Check
     * mat khau cu bang BCrypt. 4. Hash mat khau moi bang BCrypt roi update
     * xuong DB.
     */
    @Override
    public String changePassword(String username, String userRole, String oldPassword, String newPassword) {
        if (username == null || userRole == null || oldPassword == null || newPassword == null) {
            return "INVALID_INPUT";
        }

        username = username.trim();
        userRole = userRole.trim();

        if (username.isEmpty() || userRole.isEmpty() || oldPassword.isEmpty() || newPassword.isEmpty()) {
            return "INVALID_INPUT";
        }

        // Mat khau moi nen co do dai toi thieu de tranh password qua yeu.
        if (newPassword.length() < 6) {
            return "WEAK_PASSWORD";
        }

        // Khong cho doi sang dung lai mat khau cu.
        if (oldPassword.equals(newPassword)) {
            return "SAME_PASSWORD";
        }

        // Neu session role la CUSTOMER thi update bang customers.
        if ("CUSTOMER".equals(userRole)) {
            Customer customer = customerDAO.findByUsername(username);
            if (customer == null || !customer.isActive()) {
                return "USER_NOT_FOUND";
            }

            // So sanh mat khau cu nguoi dung nhap voi password_hash trong DB.
            if (!BCrypt.checkpw(oldPassword, customer.getPasswordHash())) {
                return "WRONG_OLD_PASSWORD";
            }

            String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
            return customerDAO.updatePassword(username, newHash) ? "SUCCESS" : "UPDATE_FAILED";
        }

        // Con lai la Employee: ADMIN, BRANCH_MANAGER, BRANCH_STAFF.
        Employee employee = employeeDAO.findByUsername(username);
        if (employee == null || !employee.isActive()) {
            return "USER_NOT_FOUND";
        }

        if (!BCrypt.checkpw(oldPassword, employee.getPasswordHash())) {
            return "WRONG_OLD_PASSWORD";
        }

        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
        return employeeDAO.updatePassword(username, newHash) ? "SUCCESS" : "UPDATE_FAILED";
    }

    // Retrieve an active customer by their email address
    @Override
    public Customer getActiveCustomerByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return null;
        }
        Customer customer = customerDAO.findByEmail(email.trim());
        if (customer != null && customer.isActive()) {
            return customer;
        }
        return null;
    }

    // Set the reset token hash in the database for a customer
    @Override
    public boolean setResetToken(String username, String resetTokenHash) {
        if (username == null || username.trim().isEmpty()) {
            return false;
        }
        return customerDAO.updateResetToken(username.trim(), resetTokenHash);
    }

    // Update customer's password and clear the reset token hash in the database
    @Override
    public boolean resetPasswordAndClearToken(String username, String newPasswordHash) {
        if (username == null || username.trim().isEmpty() || newPasswordHash == null) {
            return false;
        }
        boolean isPasswordUpdated = customerDAO.updatePassword(username.trim(), newPasswordHash);
        if (isPasswordUpdated) {
            // Clear the reset token after password has been successfully reset
            customerDAO.updateResetToken(username.trim(), null);
            return true;
        }
        return false;
    }

    @Override
    public boolean verifyCustomer(String username, String token) {
        if (username == null || token == null) {
            return false;
        }
        Customer customer = customerDAO.findByUsername(username);
        if (customer == null) {
            return false;
        }
        if (token.equals(customer.getResetToken()) && !customer.isEmailVerified()) {
            return customerDAO.updateEmailVerified(username, true);
        }
        return false;
    }
}
