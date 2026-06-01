package com.mbcms.service.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Customer;
import com.mbcms.service.ProfileService;

/**
 * ProfileServiceImpl - profile business logic (UC12 View/Update Profile).
 */
public class ProfileServiceImpl implements ProfileService {

    private final CustomerDAO customerDAO;

    public ProfileServiceImpl() {
        this.customerDAO = new CustomerDAOImpl();
    }

    // Constructor for injection (unit test)
    public ProfileServiceImpl(CustomerDAO customerDAO) {
        this.customerDAO = customerDAO;
    }

    @Override
    public boolean updateProfile(Customer customer) {
        return customerDAO.updateProfile(customer);
    }
}
