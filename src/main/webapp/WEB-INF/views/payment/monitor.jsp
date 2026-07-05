<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Payment Status Monitoring (owner: HungNT). Admin + Branch Manager.
    PHAM VI: theo doi TRANG THAI giao dich (PENDING/SUCCESS/FAILED), method mix,
    giao dich PENDING treo. KHONG phai bao cao doanh thu (module Reports - AnhND).
    Style: he thong .pay-* trong manager.css.
--%>
<c:set var="base" value="${isAdmin ? '/admin' : '/branch'}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment Monitoring – PentaPlex ${isAdmin ? 'Admin' : 'Manager'}</title>
    <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
</head>
<body class="lc-console">

<c:choose>
    <c:when test="${isAdmin}">
        <jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
            <jsp:param name="active" value="payments"/>
        </jsp:include>
    </c:when>
    <c:otherwise>
        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="payments"/>
        </jsp:include>
    </c:otherwise>
</c:choose>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <c:choose>
                    <c:when test="${isAdmin}">
                        <div class="lc-page-crumb">Admin / <strong>Payments</strong></div>
                    </c:when>
                    <c:otherwise>
                        <div class="lc-page-section"><i class="bi bi-activity me-1"></i> Finance / Payments</div>
                    </c:otherwise>
                </c:choose>
                <h1 class="lc-page-title">Payment Status Monitoring</h1>
            </div>
            <nav class="lc-page-nav" aria-label="Payment views">
                <a href="${pageContext.request.contextPath}${base}/payments">
                    <i class="bi bi-list-ul" aria-hidden="true"></i> History</a>
                <a class="active" href="${pageContext.request.contextPath}${base}/payments/monitor">
                    <i class="bi bi-activity" aria-hidden="true"></i> Monitoring</a>
            </nav>
        </div>

        <c:if test="${not isAdmin}">
            <div class="lc-scope mb-3">
                <i class="bi bi-shield-lock-fill" style="color:#cf9a00;"></i>
                <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}"/></strong>
                    &mdash; transaction status for your assigned branch only.</span>
            </div>
        </c:if>

        <%-- ===== KPI cards ===== --%>
        <div class="lc-kpi-row">
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-check-circle-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Success</div>
                    <div class="lc-kpi-value">${summary.countSuccess}</div>
                    <div class="lc-kpi-hint">Confirmed: <fmt:formatNumber value="${summary.totalSuccessAmount}" pattern="#,###"/>₫</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-hourglass-split"></i></div>
                <div>
                    <div class="lc-kpi-label">Pending</div>
                    <div class="lc-kpi-value">${summary.countPending}</div>
                    <div class="lc-kpi-hint">Awaiting payment</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--rose"><i class="bi bi-x-circle-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Failed</div>
                    <div class="lc-kpi-value">${summary.countFailed}</div>
                    <div class="lc-kpi-hint">Failed / expired</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-graph-up-arrow"></i></div>
                <div>
                    <div class="lc-kpi-label">Success rate</div>
                    <div class="lc-kpi-value">${summary.successRate}%</div>
                    <div class="lc-kpi-hint">${summary.total} total transaction(s)</div>
                </div>
            </div>
        </div>

        <div class="row g-3 mb-3">
            <%-- ===== Payment health ===== --%>
            <div class="col-lg-6">
                <div class="pay-card h-100">
                    <div class="pay-card-head"><h6>Payment health</h6></div>
                    <div class="p-4">
                        <div class="d-flex justify-content-between align-items-center mb-1">
                            <span class="text-muted small">Success rate</span>
                            <span class="fw-bold text-navy">${summary.successRate}%</span>
                        </div>
                        <div class="pay-prog mb-2"><span style="width:${summary.successRate}%;"></span></div>
                        <div class="d-flex gap-3 small text-muted mb-2">
                            <span><span class="pay-st s-success"><span class="dot"></span>${summary.countSuccess}</span></span>
                            <span><span class="pay-st s-pending"><span class="dot"></span>${summary.countPending}</span></span>
                            <span><span class="pay-st s-failed"><span class="dot"></span>${summary.countFailed}</span></span>
                        </div>

                        <div class="pay-health-row">
                            <span class="text-muted small">Confirmed amount (SUCCESS)</span>
                            <span class="pay-amount"><fmt:formatNumber value="${summary.totalSuccessAmount}" pattern="#,###"/>₫</span>
                        </div>
                        <div class="pay-health-row">
                            <span class="text-muted small">Oldest pending transaction</span>
                            <c:choose>
                                <c:when test="${empty oldestPendingMin}">
                                    <span class="pay-st s-success"><span class="dot"></span>None</span>
                                </c:when>
                                <c:when test="${oldestPendingMin >= 10}">
                                    <span class="pay-st s-failed"><i class="bi bi-exclamation-triangle-fill"></i>
                                        ${oldestPendingMin} min &mdash; expired</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="pay-st s-pending"><span class="dot"></span>${oldestPendingMin} min ago</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <c:if test="${not empty oldestPendingMin and oldestPendingMin >= 10}">
                            <div class="small text-muted mt-3 d-flex gap-2">
                                <i class="bi bi-info-circle-fill" style="color:var(--warning);"></i>
                                <span>A pending payment older than 10 minutes means the booking auto-expired;
                                    the seat hold was released and the payment was never completed.</span>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- ===== Payment mix by method ===== --%>
            <div class="col-lg-6">
                <div class="pay-card h-100">
                    <div class="pay-card-head"><h6>Payment mix by method</h6></div>
                    <div class="p-4 pay-mix">
                        <c:choose>
                            <c:when test="${summary.total == 0}">
                                <div class="pay-empty py-4"><i class="bi bi-pie-chart"></i>
                                    <div class="small">No transactions yet.</div></div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="m" items="${summary.methodCounts}">
                                    <div class="row-mix">
                                        <div class="top">
                                            <span class="k"><i class="bi bi-${m.key == 'CASH' ? 'cash-coin' : 'phone'} me-1"></i>${m.key}</span>
                                            <span class="v">${m.value} txn &middot;
                                                <strong><fmt:formatNumber value="${m.value * 100 / summary.total}" maxFractionDigits="0"/>%</strong></span>
                                        </div>
                                        <div class="pay-prog">
                                            <span class="b-${fn:toLowerCase(m.key)}"
                                                  style="width:<fmt:formatNumber value="${m.value * 100 / summary.total}" maxFractionDigits="0"/>%;"></span>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

        <%-- ===== Latest transactions ===== --%>
        <div class="pay-card">
            <div class="pay-card-head">
                <h6>Latest transactions</h6>
                <a class="small text-decoration-none fw-semibold" href="${pageContext.request.contextPath}${base}/payments">
                    View all <i class="bi bi-arrow-right"></i></a>
            </div>
            <div class="table-responsive">
                <table class="pay-table">
                    <thead>
                        <tr>
                            <th>Time</th><th>Booking</th><th>Customer</th>
                            <th>Method</th><th class="r">Amount</th><th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty recentPayments}">
                            <tr><td colspan="6"><div class="pay-empty"><i class="bi bi-inbox"></i>
                                <div class="small">No transactions yet.</div></div></td></tr>
                        </c:if>
                        <c:forEach var="p" items="${recentPayments}">
                            <tr>
                                <td class="pay-time">
                                    <c:choose>
                                        <c:when test="${not empty p.paidAt}">${fn:substring(p.paidAt, 0, 10)}<span class="text-muted"> ${fn:substring(p.paidAt, 11, 16)}</span></c:when>
                                        <c:otherwise>${fn:substring(p.createdAt, 0, 10)}<span class="text-muted"> ${fn:substring(p.createdAt, 11, 16)}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="pay-code">${p.bookingCode}</span></td>
                                <td>
                                    <div class="pay-cust">
                                        <div class="pay-avatar">${fn:toUpperCase(fn:substring(p.customerFullName, 0, 1))}</div>
                                        <div class="nm"><c:out value="${p.customerFullName}"/></div>
                                    </div>
                                </td>
                                <td><span class="pay-method m-${fn:toLowerCase(p.method)}">
                                    <i class="bi bi-${p.method == 'CASH' ? 'cash-coin' : 'phone'}"></i>${p.method}</span></td>
                                <td class="r"><span class="pay-amount"><fmt:formatNumber value="${p.amount}" pattern="#,###"/>₫</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${p.status eq 'SUCCESS'}"><span class="pay-st s-success"><span class="dot"></span>Success</span></c:when>
                                        <c:when test="${p.status eq 'FAILED'}"><span class="pay-st s-failed"><span class="dot"></span>Failed</span></c:when>
                                        <c:otherwise><span class="pay-st s-pending"><span class="dot"></span>Pending</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="small text-muted mt-3 d-flex gap-2">
            <i class="bi bi-info-circle"></i>
            <span>This page tracks transaction <strong>status</strong> only. Revenue analytics and charts
                are part of the Reports module.</span>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
</body>
</html>
