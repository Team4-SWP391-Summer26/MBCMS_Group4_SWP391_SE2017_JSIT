package com.mbcms.service;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;

/**
 * AuthService - hop dong nghiep vu Auth (team tu implement trong impl).
 */
public interface AuthService {

    Customer loginCustomer(String loginId, String rawPassword);

    Employee loginEmployee(String loginId, String rawPassword);

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
