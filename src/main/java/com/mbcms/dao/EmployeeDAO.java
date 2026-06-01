package com.mbcms.dao;

import com.mbcms.model.Employee;

/**
 * EmployeeDAO - truy cap bang {@code employees}.
 * Them method khi can (Login staff, quan ly nhan vien, ...).
 */
public interface EmployeeDAO {

    Employee findByUsername(String username);
    
    Employee findByEmail(String email);
}
