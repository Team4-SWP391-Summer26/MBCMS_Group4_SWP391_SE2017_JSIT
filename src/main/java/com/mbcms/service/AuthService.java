package com.mbcms.service;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.impl.LoginResult;

/**
 * AuthService - hop dong nghiep vu Auth (team tu implement trong impl).
 */
public interface AuthService {

    /**
     * Xac thuc Customer bang email + mat khau.
     *
     * @param email       email nhap tu form (case-insensitive)
     * @param rawPassword mat khau nguyen ban
     * @return LoginResult chua trang thai va Customer neu thanh cong
     */
    LoginResult loginCustomer(String email, String rawPassword);

    /**
     * Xac thuc Employee bang email + mat khau.
     *
     * @param email       email nhap tu form (case-insensitive)
     * @param rawPassword mat khau nguyen ban
     * @return LoginResult chua trang thai va Employee neu thanh cong
     */
    LoginResult loginEmployee(String email, String rawPassword);

    /**
     * Dang ky tai khoan Customer moi.
     * Hash password bang BCrypt truoc khi luu.
     */

    boolean registerCustomer(Customer customer, String rawPassword);

    /**
     * Doi mat khau cho tai khoan dang dang nhap. Tra ve chuoi ket qua de
     * Servlet hien thi thong bao phu hop.
     */
    String changePassword(String username, String userRole, String oldPassword, String newPassword);

    // Retrieve an active customer by their email address
    Customer getActiveCustomerByEmail(String email);

    // Set the reset token hash in the database for a customer
    boolean setResetToken(String username, String resetTokenHash);

    // Update customer's password and clear the reset token hash in the database
    boolean resetPasswordAndClearToken(String username, String newPasswordHash);
}
