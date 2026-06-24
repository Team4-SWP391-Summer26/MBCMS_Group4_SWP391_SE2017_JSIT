package com.mbcms.service.impl;

import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.EmployeeDAO;
import com.mbcms.model.Customer;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.mindrot.jbcrypt.BCrypt;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {

    @Mock private CustomerDAO customerDAO;
    @Mock private EmployeeDAO employeeDAO;

    private AuthServiceImpl authService;

    @BeforeEach
    void setUp() {
        authService = new AuthServiceImpl(customerDAO, employeeDAO);
    }

    @Test
    void verifyCustomer_acceptsBcryptHashedToken() {
        String plainToken = "abc-123-verify-token";
        String hash = BCrypt.hashpw(plainToken, BCrypt.gensalt(10));

        Customer customer = new Customer();
        customer.setUsername("testuser");
        customer.setResetToken(hash);
        customer.setEmailVerified(false);

        when(customerDAO.findByUsername("testuser")).thenReturn(customer);
        when(customerDAO.updateEmailVerified("testuser", true)).thenReturn(true);

        assertTrue(authService.verifyCustomer("testuser", plainToken));
    }

    @Test
    void verifyCustomer_rejectsWrongToken() {
        String hash = BCrypt.hashpw("correct-token", BCrypt.gensalt(10));
        Customer customer = new Customer();
        customer.setUsername("testuser");
        customer.setResetToken(hash);
        customer.setEmailVerified(false);

        when(customerDAO.findByUsername("testuser")).thenReturn(customer);

        assertFalse(authService.verifyCustomer("testuser", "wrong-token"));
    }
}
