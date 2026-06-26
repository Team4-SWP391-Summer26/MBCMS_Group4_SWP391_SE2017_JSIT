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
    <title>Payment Monitoring – MBCMS ${isAdmin ? 'Admin' : 'Manager'}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
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
    <div class="container-fluid px-4 py-4" style="max-width: 1240px;">

        <%-- ===== Header + segmented tab ===== --%>
        <div class="pay-head">
            <div>
                <div class="pay-eyebrow"><i class="bi bi-activity"></i> Finance &middot; Payments</div>
                <h1 class="pay-title">Payment Status Monitoring</h1>
            </div>
            <div class="pay-seg">
                <a href="${pageContext.request.contextPath}${base}/payments">
                    <i class="bi bi-list-ul"></i> History</a>
                <a class="active" href="${pageContext.request.contextPath}${base}/payments/monitor">
                    <i class="bi bi-activity"></i> Monitoring</a>
            </div>
        </div>

        <c:if test="${not isAdmin}">
            <div class="lc-scope mb-3">
                <i class="bi bi-shield-lock-fill" style="color:#cf9a00;"></i>
                <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}"/></strong>
                    &mdash; transaction status for your assigned branch only.</span>
            </div>
        </c:if>

        <%-- ===== KPI cards ===== --%>
        <div class="row g-3 mb-3">
            <div class="col-6 col-xl-3">
                <div class="pay-kpi k-green">
                    <div class="row1">
                        <div class="ic" style="background:#E8F5EE; color:#146C43;"><i class="bi bi-check-circle-fill"></i></div>
                        <div class="lbl">Success</div>
                    </div>
                    <div class="val">${summary.countSuccess}</div>
                    <div class="sub">Confirmed: <fmt:formatNumber value="${summary.totalSuccessAmount}" pattern="#,###"/>₫</div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="pay-kpi k-amber">
                    <div class="row1">
                        <div class="ic" style="background:#FFF4D6; color:#9a6700;"><i class="bi bi-hourglass-split"></i></div>
                        <div class="lbl">Pending</div>
                    </div>
                    <div class="val">${summary.countPending}</div>
                    <div class="sub">Awaiting payment</div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="pay-kpi k-red">
                    <div class="row1">
                        <div class="ic" style="background:#FBE4E6; color:#b02a37;"><i class="bi bi-x-circle-fill"></i></div>
                        <div class="lbl">Failed</div>
                    </div>
                    <div class="val">${summary.countFailed}</div>
                    <div class="sub">Failed / expired</div>
                </div>
            </div>
            <div class="col-6 col-xl-3">
                <div class="pay-kpi k-blue">
                    <div class="row1">
                        <div class="ic" style="background:var(--lc-light); color:var(--lc-primary);"><i class="bi bi-graph-up-arrow"></i></div>
                        <div class="lbl">Success rate</div>
                    </div>
                    <div class="val">${summary.successRate}%</div>
                    <div class="sub">${summary.total} total transaction(s)</div>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
