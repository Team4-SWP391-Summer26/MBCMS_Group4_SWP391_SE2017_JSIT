package com.mbcms.controller.payment;

import com.mbcms.controller.branch.ConsoleSupport;
import com.mbcms.dao.BranchDAO;
import com.mbcms.dao.impl.BranchDAOImpl;
import com.mbcms.model.Employee;
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
 * PaymentConsoleServlet - Payment history cho console (owner: HungNT).
 * Phuc vu CA Admin (/admin/payments) lan Branch Manager (/branch/payments)
 * - RoleFilter da gac dung role theo prefix.
 *
 * Scope du lieu LAY TU SESSION (khong tin request):
 * - Admin (branchId NULL) -> xem toan he thong.
 * - Branch Manager       -> chi branch trong session (currentBranchId).
 */
@WebServlet({"/admin/payments", "/branch/payments"})
public class PaymentConsoleServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/payment/console_list.jsp";
    private final PaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Employee emp = (Employee) session.getAttribute("currentUser");
        boolean isAdmin = emp.isAdmin();

        PaymentSearchCriteria c = PaymentQuery.fromRequest(req);
        Long fBranch = null;
        if (isAdmin) {
            // Admin co the loc theo chi nhanh (optional); rong = tat ca branch.
            fBranch = parseBranch(req.getParameter("branch"));
            c.setBranchId(fBranch);
            req.setAttribute("branches", new BranchDAOImpl().findAll()); // cho dropdown
        } else {
            // Branch Manager: scope cung branch tu session (BranchFilter da set).
            c.setBranchId((Long) session.getAttribute("currentBranchId"));
            ConsoleSupport.ensureBranchName(req); // ten branch cho sidebar + scope notice
        }

        List<PaymentRecord> payments = paymentService.searchPayments(c);
        int total = paymentService.countPayments(c);
        int page = PaymentQuery.page(req);

        req.setAttribute("payments", payments);
        req.setAttribute("total", total);
        req.setAttribute("page", page);
        req.setAttribute("totalPages", PaymentQuery.totalPages(total));
        req.setAttribute("isAdmin", isAdmin);
        // echo lai filter de giu trang thai form + link phan trang
        req.setAttribute("fStatus", c.getStatus());
        req.setAttribute("fMethod", c.getMethod());
        req.setAttribute("fBranch", fBranch);
        req.setAttribute("fFrom", req.getParameter("from"));
        req.setAttribute("fTo", req.getParameter("to"));
        req.setAttribute("fQ", c.getKeyword());

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }

    /** Parse branch param (Admin); null/khong hop le -> khong loc. */
    private Long parseBranch(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
