package com.mbcms.service.impl;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.AuthService;

/**
 * AuthServiceImpl - stub. Business logic do owner feature implement (theo Report 4).
 */
public class AuthServiceImpl implements AuthService {

    @Override
    public Customer loginCustomer(String loginId, String rawPassword) {
        // TODO TrangNT: Login
        return null;
    }

    @Override
    public Employee loginEmployee(String loginId, String rawPassword) {
        // TODO TrangNT: Login (staff/admin)
        return null;
    }

    @Override
    public boolean registerCustomer(Customer customer, String rawPassword) {
        // TODO HoangHM: Register account
        return false;
    }
}
