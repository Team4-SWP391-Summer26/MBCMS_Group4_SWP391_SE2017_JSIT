package com.mbcms.model;

import java.time.LocalDate;

/**
 * PaymentSearchCriteria - bo loc cho Payment history (owner: HungNT).
 *
 * Cac truong deu OPTIONAL (null = khong loc). QUAN TRONG ve bao mat:
 * - branchId / customerUsername duoc Servlet SET tu SESSION (khong tu request)
 *   de scope du lieu theo role (Customer = chinh minh, Branch Manager = branch
 *   cua minh, Admin = toan he thong).
 * - status / method da duoc whitelist o Servlet truoc khi gan vao day.
 *
 * Phan trang: offset/limit dung cho OFFSET..FETCH cua SQL Server.
 */
public class PaymentSearchCriteria {

    private Long branchId;            // null = tat ca branch (Admin)
    private String customerUsername;  // null = tat ca customer (Admin/Manager)
    private String status;            // PENDING | SUCCESS | FAILED | null
    private String method;            // CASH | VNPAY | null
    private LocalDate dateFrom;       // loc theo ngay giao dich (null = khong gioi han)
    private LocalDate dateTo;
    private String keyword;           // tim theo booking_code / transaction_ref / ten KH
    private int offset = 0;
    private int limit = 20;

    public PaymentSearchCriteria() {}

    public Long getBranchId() { return branchId; }
    public void setBranchId(Long branchId) { this.branchId = branchId; }

    public String getCustomerUsername() { return customerUsername; }
    public void setCustomerUsername(String customerUsername) { this.customerUsername = customerUsername; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getMethod() { return method; }
    public void setMethod(String method) { this.method = method; }

    public LocalDate getDateFrom() { return dateFrom; }
    public void setDateFrom(LocalDate dateFrom) { this.dateFrom = dateFrom; }

    public LocalDate getDateTo() { return dateTo; }
    public void setDateTo(LocalDate dateTo) { this.dateTo = dateTo; }

    public String getKeyword() { return keyword; }
    public void setKeyword(String keyword) { this.keyword = keyword; }

    public int getOffset() { return offset; }
    public void setOffset(int offset) { this.offset = offset; }

    public int getLimit() { return limit; }
    public void setLimit(int limit) { this.limit = limit; }
}
