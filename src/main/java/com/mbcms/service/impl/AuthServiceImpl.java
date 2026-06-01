package com.mbcms.service.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.EmployeeDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.dao.impl.EmployeeDAOImpl;
import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.AuthService;
import org.mindrot.jbcrypt.BCrypt;

/**
 * AuthServiceImpl - xu ly business logic xac thuc.
 * Dung BCrypt (jBCrypt) de verify password, khong bao gio so sanh plaintext.
 */
public class AuthServiceImpl implements AuthService {

    private final CustomerDAO customerDAO;
    private final EmployeeDAO employeeDAO;

    public AuthServiceImpl() {
        this.customerDAO = new CustomerDAOImpl();
        this.employeeDAO = new EmployeeDAOImpl();
    }

    // Constructor de inject (unit test)
    public AuthServiceImpl(CustomerDAO customerDAO, EmployeeDAO employeeDAO) {
        this.customerDAO = customerDAO;
        this.employeeDAO = employeeDAO;
    }

    /**
     * Xac thuc Customer.
     * @return Customer neu hop le, null neu sai loginId/password hoac bi khoa.
     */
    @Override
    public Customer loginCustomer(String loginId, String rawPassword) {
        if (loginId == null || rawPassword == null) return null;

        Customer customer = customerDAO.findByUsername(loginId);
        if (customer == null) return null;

        // Kiem tra tai khoan con active
        if (!customer.isActive()) return null;

        // BCrypt verify
        if (!BCrypt.checkpw(rawPassword, customer.getPasswordHash())) return null;

        return customer;
    }

    /**
     * Xac thuc Employee (staff/admin).
     * @return Employee neu hop le, null neu sai hoac bi khoa.
     */
    @Override
    public Employee loginEmployee(String loginId, String rawPassword) {
        if (loginId == null || rawPassword == null) return null;

        Employee employee = employeeDAO.findByUsername(loginId);
        if (employee == null) return null;

        if (!employee.isActive()) return null;

        if (!BCrypt.checkpw(rawPassword, employee.getPasswordHash())) return null;

        return employee;
    }

    /**
     * Dang ky tai khoan Customer moi.
     * Hash password bang BCrypt work-factor 10 truoc khi luu.
     */
    @Override
    public boolean registerCustomer(Customer customer, String rawPassword) {
        if (customer == null || rawPassword == null || rawPassword.trim().isEmpty()) {
            return false;
        }

        // Kiem tra ten dang nhap ton tai
        if (customerDAO.findByUsername(customer.getUsername()) != null) {
            throw new IllegalArgumentException("Tên đăng nhập đã tồn tại trong hệ thống.");
        }

        // Kiem tra email ton tai
        if (customerDAO.existsByEmail(customer.getEmail())) {
            throw new IllegalArgumentException("Email đã được sử dụng bởi tài khoản khác.");
        }

        // Hash password bang BCrypt
        String hashed = BCrypt.hashpw(rawPassword, BCrypt.gensalt(10));
        customer.setPasswordHash(hashed);
        
        // Cac thiet lap mac dinh
        customer.setActive(true);
        customer.setEmailVerified(false);
        customer.setCreatedAt(java.time.LocalDateTime.now());

        // Luu vao CSDL
        return customerDAO.insert(customer);
    }
}