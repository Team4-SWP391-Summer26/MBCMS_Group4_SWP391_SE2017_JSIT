package com.mbcms.service.impl;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;

/**
 * LoginResult - ket qua tra ve tu AuthService sau khi xac thuc.
 *
 * <p>Dung value-object thay vi null / Exception cho flow binh thuong de:
 * <ul>
 *   <li>Truyen duoc ly do that bai cu the (NOT_VERIFIED vs WRONG_CREDENTIALS)</li>
 *   <li>Khong bi pha vo API cua AuthService (khong can throws checked exception)</li>
 *   <li>De unit-test hon</li>
 * </ul>
 * </p>
 */
public final class LoginResult {

    public enum Status {
        /** Xac thuc thanh cong. */
        SUCCESS,
        /** Khong tim thay email hoac sai mat khau. */
        WRONG_CREDENTIALS,
        /** Dung email + mat khau nhung email chua duoc xac minh. */
        EMAIL_NOT_VERIFIED,
        /** Tai khoan bi khoa (active = false). */
        ACCOUNT_DISABLED
    }

    private final Status   status;
    private final Customer customer;   // non-null khi SUCCESS va la Customer
    private final Employee employee;   // non-null khi SUCCESS va la Employee

    // ----- factory methods ---------------------------------------------- //

    public static LoginResult success(Customer c) {
        return new LoginResult(Status.SUCCESS, c, null);
    }

    public static LoginResult success(Employee e) {
        return new LoginResult(Status.SUCCESS, null, e);
    }

    public static LoginResult wrongCredentials() {
        return new LoginResult(Status.WRONG_CREDENTIALS, null, null);
    }

    public static LoginResult emailNotVerified() {
        return new LoginResult(Status.EMAIL_NOT_VERIFIED, null, null);
    }

    public static LoginResult accountDisabled() {
        return new LoginResult(Status.ACCOUNT_DISABLED, null, null);
    }

    // ----- constructor -------------------------------------------------- //

    private LoginResult(Status status, Customer customer, Employee employee) {
        this.status   = status;
        this.customer = customer;
        this.employee = employee;
    }

    // ----- accessors ---------------------------------------------------- //

    public Status   getStatus()   { return status; }
    public Customer getCustomer() { return customer; }
    public Employee getEmployee() { return employee; }

    public boolean isSuccess()          { return status == Status.SUCCESS; }
    public boolean isWrongCredentials() { return status == Status.WRONG_CREDENTIALS; }
    public boolean isEmailNotVerified() { return status == Status.EMAIL_NOT_VERIFIED; }
    public boolean isAccountDisabled()  { return status == Status.ACCOUNT_DISABLED; }
}
