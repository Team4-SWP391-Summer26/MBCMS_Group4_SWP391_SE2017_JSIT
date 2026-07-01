package com.mbcms.controller.payment;

import com.mbcms.controller.branch.ConsoleSupport;
import com.mbcms.model.Employee;
import com.mbcms.model.PaymentRecord;
import com.mbcms.model.PaymentSearchCriteria;
import com.mbcms.model.PaymentSummary;
import com.mbcms.service.PaymentService;
import com.mbcms.service.impl.PaymentServiceImpl;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.time.Duration;
import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.io.IOException;
import java.util.List;

/**
 * PaymentMonitorServlet - Payment status monitoring (owner: HungNT).
 * Admin (/admin/payments/monitor) + Branch Manager (/branch/payments/monitor).
 *
 * PHAM VI: chi theo doi TRANG THAI giao dich (PENDING/SUCCESS/FAILED), method
 * mix va giao dich PENDING treo (>10 phut = booking da het han). KHONG lam bao
 * cao doanh thu - phan do thuoc module Reports (AnhND).
 */
@WebServlet({"/admin/payments/monitor", "/branch/payments/monitor"})
public class PaymentMonitorServlet extends HttpServlet {

    private static final String VIEW = "/WEB-INF/views/payment/monitor.jsp";
    private final PaymentService paymentService = new PaymentServiceImpl();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        Employee emp = (Employee) session.getAttribute("currentUser");
        boolean isAdmin = emp.isAdmin();
        // SCOPE theo role: Admin -> branchId=null (toan he thong); Branch Manager ->
        // branchId cua minh (chi thay giao dich cua branch minh). 1 servlet dung cho 2 URL.
        Long branchId = isAdmin ? null : (Long) session.getAttribute("currentBranchId");
        if (!isAdmin) {
            ConsoleSupport.ensureBranchName(req); // ten branch cho sidebar + scope notice
        }

        // Tong hop trang thai: dem PENDING/SUCCESS/FAILED + method mix (theo scope tren).
        PaymentSummary summary = paymentService.getPaymentSummary(branchId);

        // Tuoi (phut) cua PENDING cu nhat - moc 10 phut = booking auto-expire.
        Long oldestPendingMin = null;
        if (summary.getOldestPendingCreatedAt() != null) {
            oldestPendingMin = Duration.between(
                    summary.getOldestPendingCreatedAt(),
                    LocalDateTime.now(ZoneOffset.UTC)).toMinutes();
        }

        // Giao dich gan day (scope theo branch) de doi chieu nhanh.
        PaymentSearchCriteria recent = new PaymentSearchCriteria();
        recent.setBranchId(branchId);
        recent.setLimit(8);
        List<PaymentRecord> recentPayments = paymentService.searchPayments(recent);

        req.setAttribute("summary", summary);
        req.setAttribute("oldestPendingMin", oldestPendingMin);
        req.setAttribute("recentPayments", recentPayments);
        req.setAttribute("isAdmin", isAdmin);

        req.getRequestDispatcher(VIEW).forward(req, resp);
    }
}
