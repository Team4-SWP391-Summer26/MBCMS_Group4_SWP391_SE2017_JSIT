package com.mbcms.filter;

import jakarta.servlet.*;
import java.io.IOException;

/**
 * EncodingFilter - ep UTF-8 cho request/response.
 * Dang ky + thu tu trong web.xml (phai chay TRUOC moi filter khac),
 * nen KHONG dung @WebFilter o day de tranh dang ky trung.
 */
public class EncodingFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        chain.doFilter(request, response);
    }
}
