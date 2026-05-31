package com.mbcms.dao;

import com.mbcms.model.Customer;

/**
 * CustomerDAO - truy cap bang {@code customers}.
 * Them method khi implement feature (Register, Profile, ...).
 */
public interface CustomerDAO {

    Customer findByUsername(String username);

    Customer findByEmail(String email);

    boolean updateResetToken(String username, String resetToken);

    boolean updatePasswordHash(String username, String passwordHash);
}
