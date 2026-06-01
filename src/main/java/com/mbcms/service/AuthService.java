package com.mbcms.service;

import com.mbcms.model.Customer;
import com.mbcms.model.Employee;
import com.mbcms.service.impl.LoginResult;

/**
 * AuthService - hop dong nghiep vu xac thuc.
 *
 * <p>Phuong thuc login tra ve {@link LoginResult} thay vi null/object de
 * truyen duoc ly do that bai cu the (sai mat khau vs chua xac minh email)
 * len tang Servlet ma KHONG can nem Exception qua flow binh thuong.</p>
 */
public interface AuthService {

    /**
     * Xac thuc Customer bang email + mat khau.
     *
     * @param email       email nhap tu form (case-insensitive)
     * @param rawPassword mat khau nguyen ban
     * @return LoginResult chua trang thai va Customer neu thanh cong
     */
    LoginResult loginCustomer(String email, String rawPassword);

    /**
     * Xac thuc Employee bang email + mat khau.
     *
     * @param email       email nhap tu form (case-insensitive)
     * @param rawPassword mat khau nguyen ban
     * @return LoginResult chua trang thai va Employee neu thanh cong
     */
    LoginResult loginEmployee(String email, String rawPassword);

    /**
     * Dang ky tai khoan Customer moi.
     * Hash password bang BCrypt truoc khi luu.
     */
    boolean registerCustomer(Customer customer, String rawPassword);
}
