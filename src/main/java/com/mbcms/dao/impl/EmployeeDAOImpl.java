package com.mbcms.dao.impl;

import com.mbcms.dao.EmployeeDAO;
import com.mbcms.model.Employee;

/**
 * EmployeeDAOImpl - TODO khi implement Login (TrangNT) hoac quan ly staff.
 * Tham khao {@link CustomerDAOImpl#findByUsername(String)} cho pattern PreparedStatement.
 */
public class EmployeeDAOImpl extends BaseDAO implements EmployeeDAO {

    @Override
    public Employee findByUsername(String username) {
        // TODO (TrangNT / team): SELECT ... FROM employees WHERE username = ?
        return null;
    }
}
