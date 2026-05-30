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
}
