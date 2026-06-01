package com.mbcms.dao;

import com.mbcms.model.Customer;

/**
 * CustomerDAO - truy cap bang {@code customers}.
 * Them method khi implement feature (Register, Profile, ...).
 */
public interface CustomerDAO {

    Customer findByUsername(String username);
    boolean existsByEmail(String email);

boolean insert(Customer customer);
    boolean updatePassword(String username, String newPasswordHash);

    /** Update personal info (full_name, phone, date_of_birth, address). UC12. */
    boolean updateProfile(Customer customer);

}
