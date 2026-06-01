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
 *
 * <p>Quy trinh xac thuc Customer (theo spec):
 * <ol>
 *   <li>Tim Customer theo email (case-insensitive).</li>
 *   <li>Neu khong tim thay → WRONG_CREDENTIALS (khong tiet lo email co ton tai hay khong).</li>
 *   <li>BCrypt verify mat khau; neu sai → WRONG_CREDENTIALS.</li>
 *   <li>Kiem tra {@code email_verified}: neu false → EMAIL_NOT_VERIFIED (tra thong bao rieng).</li>
 *   <li>Kiem tra {@code active}: neu false → ACCOUNT_DISABLED.</li>
 *   <li>Thanh cong → SUCCESS.</li>
 * </ol>
 *
 * <p>Ghi chu thu tu buoc 3 va 4: BCrypt verify TRUOC khi kiem tra email_verified.
 * Dieu nay dam bao ke tan cong khong the dung thong bao "chua xac minh email"
 * de xac nhan rang mot dia chi email nhat dinh ton tai trong he thong voi mat
 * khau dung. Chi nguoi biet mat khau chinh xac moi nhan duoc thong bao do.</p>
 */
public class AuthServiceImpl implements AuthService {

    private final CustomerDAO customerDAO;
    private final EmployeeDAO employeeDAO;

    /** Constructor mac dinh - dung trong production. */
    public AuthServiceImpl() {
        this.customerDAO = new CustomerDAOImpl();
        this.employeeDAO = new EmployeeDAOImpl();
    }

    /** Constructor de inject - dung trong unit test. */
    public AuthServiceImpl(CustomerDAO customerDAO, EmployeeDAO employeeDAO) {
        this.customerDAO = customerDAO;
        this.employeeDAO = employeeDAO;
    }

    // ------------------------------------------------------------------ //
    //  loginCustomer                                                       //
    // ------------------------------------------------------------------ //

    /**
     * Xac thuc Customer bang email + mat khau.
     *
     * @param email       email nhap tu form
     * @param rawPassword mat khau nguyen ban
     * @return LoginResult - khong bao gio null
     */
    @Override
    public LoginResult loginCustomer(String email, String rawPassword) {
        if (email == null || rawPassword == null) {
            return LoginResult.wrongCredentials();
        }

        // 1. Tim theo email (case-insensitive - xu ly o DAO)
        Customer customer = customerDAO.findByEmail(email);
        if (customer == null) {
            return LoginResult.wrongCredentials();
        }

        // 2. BCrypt verify - TRUOC khi kiem tra email_verified (xem Javadoc class)
        if (!BCrypt.checkpw(rawPassword, customer.getPasswordHash())) {
            return LoginResult.wrongCredentials();
        }

        // 3. Kiem tra email da xac minh chua
        if (!customer.isEmailVerified()) {
            return LoginResult.emailNotVerified();
        }

        // 4. Kiem tra tai khoan con active
        if (!customer.isActive()) {
            return LoginResult.accountDisabled();
        }

        return LoginResult.success(customer);
    }

    // ------------------------------------------------------------------ //
    //  loginEmployee                                                       //
    // ------------------------------------------------------------------ //

    /**
     * Xac thuc Employee bang email + mat khau.
     * Employee khong co email_verified (tai khoan do admin tao thu cong).
     *
     * @param email       email nhap tu form
     * @param rawPassword mat khau nguyen ban
     * @return LoginResult - khong bao gio null
     */
    @Override
    public LoginResult loginEmployee(String email, String rawPassword) {
        if (email == null || rawPassword == null) {
            return LoginResult.wrongCredentials();
        }

        Employee employee = employeeDAO.findByEmail(email);
        if (employee == null) {
            return LoginResult.wrongCredentials();
        }

        if (!BCrypt.checkpw(rawPassword, employee.getPasswordHash())) {
            return LoginResult.wrongCredentials();
        }

        if (!employee.isActive()) {
            return LoginResult.accountDisabled();
        }

        return LoginResult.success(employee);
    }

    // ------------------------------------------------------------------ //
    //  registerCustomer                                                    //
    // ------------------------------------------------------------------ //

    /**
     * Dang ky tai khoan Customer moi.
     * Hash password bang BCrypt work-factor 12 truoc khi luu.
     */
    @Override
    public boolean registerCustomer(Customer customer, String rawPassword) {
        // TODO HoangHM: Register account
        // 1. Goi customerDAO.existsByUsername / existsByEmail truoc
        // 2. customer.setPasswordHash(BCrypt.hashpw(rawPassword, BCrypt.gensalt(12)));
        // 3. customer.setEmailVerified(false);  // phai xac minh qua email
        // 4. Goi customerDAO.insert(customer)
        return false;
    }
}
