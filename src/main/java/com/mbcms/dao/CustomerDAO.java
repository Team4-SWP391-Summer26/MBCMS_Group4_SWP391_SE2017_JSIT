package com.mbcms.dao;

import com.mbcms.model.Customer;

/**
 * CustomerDAO - truy cap bang {@code customers}. Them method khi implement
 * feature (Register, Profile, ...).
 */
public interface CustomerDAO {

    Customer findByUsername(String username);

    boolean existsByEmail(String email);

    // Find customer details by email address
    Customer findByEmail(String email);

    // Update customer's reset token hash in the database
    boolean updateResetToken(String username, String resetTokenHash);

    boolean insert(Customer customer);

    boolean updatePassword(String username, String newPasswordHash);

    /**
     * Update personal info (full_name, phone, date_of_birth, address). UC12.
     */
    boolean updateProfile(Customer customer);

    boolean updateEmailVerified(String username, boolean verified);
}
