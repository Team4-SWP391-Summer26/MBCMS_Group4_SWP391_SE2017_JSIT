package com.mbcms.controller.branch;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mbcms.dao.CustomerDAO;
import com.mbcms.dao.impl.CustomerDAOImpl;
import com.mbcms.model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

/**
 * CustomerLookupServlet - Tra cứu khách hàng bằng SĐT qua AJAX.
 * Mapped: /staff/customer-lookup
 */
@WebServlet("/staff/customer-lookup")
public class CustomerLookupServlet extends HttpServlet {

    private final CustomerDAO customerDAO = new CustomerDAOImpl();
    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json;charset=UTF-8");
        String phone = req.getParameter("phone");

        Map<String, Object> result = new HashMap<>();

        if (phone == null || phone.trim().isEmpty()) {
            result.put("exists", false);
            result.put("message", "SĐT không được để trống");
            mapper.writeValue(resp.getWriter(), result);
            return;
        }

        try {
            Customer c = customerDAO.findByPhone(phone.trim());
            if (c != null) {
                result.put("exists", true);
                result.put("username", c.getUsername());
                result.put("fullName", c.getFullName());
                result.put("email", c.getEmail());
            } else {
                result.put("exists", false);
            }
        } catch (Exception e) {
            result.put("exists", false);
            result.put("error", e.getMessage());
        }

        mapper.writeValue(resp.getWriter(), result);
    }
}
