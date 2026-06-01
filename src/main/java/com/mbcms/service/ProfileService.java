package com.mbcms.service;

import com.mbcms.model.Customer;

/**
 * ProfileService - business logic for viewing/updating a Customer profile (UC12).
 * (Change password is a separate feature - see AuthService.changePassword.)
 */
public interface ProfileService {

    /** Persist personal-info changes. @return true if the update succeeded. */
    boolean updateProfile(Customer customer);
}
