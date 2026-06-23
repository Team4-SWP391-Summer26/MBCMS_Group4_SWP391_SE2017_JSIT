package com.mbcms.controller.payment;

import com.mbcms.model.Payment;
import com.mbcms.model.PaymentSearchCriteria;
import jakarta.servlet.http.HttpServletRequest;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Set;

/**
 * PaymentQuery - doc + whitelist tham so loc tu request cho Payment history
 * (owner: HungNT). Dung chung cho servlet Customer/Admin/Branch.
 *
 * Whitelist status/method TRUOC khi dua xuong DAO: gia tri la nhung enum cho
 * phep, gia tri la -> bo qua (null) thay vi tin client. Phan trang co dinh.
 */
public final class PaymentQuery {

    public static final int PAGE_SIZE = 20;

    private static final Set<String> STATUSES = Set.of(
            Payment.STATUS_PENDING, Payment.STATUS_SUCCESS, Payment.STATUS_FAILED);
    // MoMo da bo khoi pham vi - chi con VNPay (online) + Cash (quay Staff).
    private static final Set<String> METHODS = Set.of(
            Payment.METHOD_CASH, Payment.METHOD_VNPAY);

    private PaymentQuery() {}

    /** Tao criteria voi cac filter chung (status/method/date/keyword + phan trang). */
    public static PaymentSearchCriteria fromRequest(HttpServletRequest req) {
        PaymentSearchCriteria c = new PaymentSearchCriteria();
        c.setStatus(whitelisted(req.getParameter("status"), STATUSES));
        c.setMethod(whitelisted(req.getParameter("method"), METHODS));
        c.setDateFrom(parseDate(req.getParameter("from")));
        c.setDateTo(parseDate(req.getParameter("to")));

        String kw = req.getParameter("q");
        c.setKeyword(kw != null && !kw.isBlank() ? kw.trim() : null);

        int page = page(req);
        c.setLimit(PAGE_SIZE);
        c.setOffset((page - 1) * PAGE_SIZE);
        return c;
    }

    /** Trang hien tai (1-based, toi thieu 1). */
    public static int page(HttpServletRequest req) {
        try {
            int p = Integer.parseInt(req.getParameter("page"));
            return Math.max(1, p);
        } catch (NumberFormatException e) {
            return 1;
        }
    }

    /** Tong so trang tu tong dong + PAGE_SIZE (toi thieu 1). */
    public static int totalPages(int total) {
        return Math.max(1, (int) Math.ceil(total / (double) PAGE_SIZE));
    }

    private static String whitelisted(String value, Set<String> allowed) {
        if (value == null) return null;
        String v = value.trim().toUpperCase();
        return allowed.contains(v) ? v : null;
    }

    private static LocalDate parseDate(String value) {
        if (value == null || value.isBlank()) return null;
        try {
            return LocalDate.parse(value.trim()); // ISO yyyy-MM-dd tu <input type=date>
        } catch (DateTimeParseException e) {
            return null;
        }
    }
}
