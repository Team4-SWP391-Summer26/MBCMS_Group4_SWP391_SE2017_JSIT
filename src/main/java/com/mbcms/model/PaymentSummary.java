package com.mbcms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * PaymentSummary - so lieu THEO DOI TRANG THAI thanh toan (owner: HungNT).
 *
 * Pham vi co tinh: chi ve TRANG THAI giao dich (PENDING/SUCCESS/FAILED),
 * method mix va giao dich treo - KHONG phai bao cao doanh thu (module Reports
 * cua AnhND). totalSuccessAmount chi de doi chieu suc khoe thanh toan.
 */
public class PaymentSummary {

    private int countPending;
    private int countSuccess;
    private int countFailed;
    private BigDecimal totalSuccessAmount = BigDecimal.ZERO;

    /** So luong giao dich theo phuong thuc (CASH/VNPAY) - giu thu tu insert. */
    private Map<String, Integer> methodCounts = new LinkedHashMap<>();

    /** created_at cua booking PENDING cu nhat (null neu khong co PENDING). */
    private LocalDateTime oldestPendingCreatedAt;

    public PaymentSummary() {}

    /** Tong so giao dich (moi trang thai). */
    public int getTotal() {
        return countPending + countSuccess + countFailed;
    }

    /** Ty le thanh cong (%) tren tong giao dich; 0 neu chua co giao dich. */
    public int getSuccessRate() {
        int total = getTotal();
        return total == 0 ? 0 : Math.round(countSuccess * 100f / total);
    }

    public int getCountPending() { return countPending; }
    public void setCountPending(int countPending) { this.countPending = countPending; }

    public int getCountSuccess() { return countSuccess; }
    public void setCountSuccess(int countSuccess) { this.countSuccess = countSuccess; }

    public int getCountFailed() { return countFailed; }
    public void setCountFailed(int countFailed) { this.countFailed = countFailed; }

    public BigDecimal getTotalSuccessAmount() { return totalSuccessAmount; }
    public void setTotalSuccessAmount(BigDecimal totalSuccessAmount) { this.totalSuccessAmount = totalSuccessAmount; }

    public Map<String, Integer> getMethodCounts() { return methodCounts; }
    public void setMethodCounts(Map<String, Integer> methodCounts) { this.methodCounts = methodCounts; }

    public LocalDateTime getOldestPendingCreatedAt() { return oldestPendingCreatedAt; }
    public void setOldestPendingCreatedAt(LocalDateTime oldestPendingCreatedAt) {
        this.oldestPendingCreatedAt = oldestPendingCreatedAt;
    }
}
