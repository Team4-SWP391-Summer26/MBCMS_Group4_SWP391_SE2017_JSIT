package com.mbcms.controller.customer;

import com.mbcms.controller.payment.PaymentQuery;
import com.mbcms.model.Customer;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.service.PaymentService;
import com.mbcms.service.impl.PaymentServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

/**
 * PaymentHistoryServlet - Payment history phia Customer (owner: HungNT).
 *
 * Scope BAT BUOC ve chinh chu tai khoan: customerUsername lay tu SESSION,
 * khong bao gio tu request -> khach khong the xem giao dich nguoi khac.
 */
@WebServlet("/customer/payments")
public class PaymentHistoryServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/customer/payment/history.jsp";
    private final PaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || !(session.getAttribute("currentUser") instanceof Customer customer)) {
            resp.sendRedirect(req.getContextPath() + "/auth/login");
            return;
        }

        // Filter (status/keyword) + phan trang doc tu request.
        PaymentSearchCriteria c = PaymentQuery.fromRequest(req);
        // SCOPE BAT BUOC: username lay tu SESSION, KHONG tu request -> khach khong the
        // doi tham so de xem giao dich cua nguoi khac.
        c.setCustomerUsername(customer.getUsername());

        List<PaymentRecord> payments = paymentService.searchPayments(c);
        int total = paymentService.countPayments(c);
        int page = PaymentQuery.page(req);

        req.setAttribute("payments", payments);
        req.setAttribute("total", total);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", PaymentQuery.totalPages(total));
        req.setAttribute("fStatus", c.getStatus());
        req.setAttribute("fQ", c.getKeyword());

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
