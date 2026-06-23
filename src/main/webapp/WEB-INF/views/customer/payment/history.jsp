<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Payment History - Customer (owner: HungNT). Transaction-centric view: method,
    status, amount, paid time, transaction ref. Scope = chinh chu (servlet ep tu
    session). Loc/phan trang SERVER-SIDE (status/q/page qua query string).
    Design dong nhat --bk-* nhu My Bookings.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment History – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        :root { --bk-primary:#2563EB; --bk-navy:#0F1E36; --bk-border:#E6EAF2; --bk-muted:#64748B; --bk-bg:#F5F7FA; }
        body.bk-page { background: var(--bk-bg); }
        .pm-wrap { max-width: 920px; }

        .pm-filter { display:flex; gap:6px; flex-wrap:wrap; }
        .pm-tab { padding:5px 14px; border-radius:999px; font-size:.8rem; font-weight:600; text-decoration:none;
            border:1.5px solid var(--bk-border); background:#fff; color:var(--bk-muted); transition:all .15s; }
        .pm-tab:hover { border-color:var(--bk-primary); color:var(--bk-primary); }
        .pm-tab.active { background:var(--bk-primary); border-color:var(--bk-primary); color:#fff; }

        .pm-search { position:relative; }
        .pm-search input { padding-left:34px; border-radius:999px; border:1.5px solid var(--bk-border); font-size:.85rem; min-width:230px; }
        .pm-search i { position:absolute; left:12px; top:50%; transform:translateY(-50%); color:#94a3b8; }

        .pm-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px; padding:16px 18px;
            margin-bottom:14px; box-shadow:0 2px 10px rgba(15,23,42,.04); display:flex; gap:16px; align-items:stretch; }
        .pm-title { font-weight:800; color:var(--bk-navy); font-size:1.02rem; line-height:1.2; }
        .pm-sub { font-size:.82rem; color:var(--bk-muted); }
        .pm-col-label { font-size:.7rem; color:#94a3b8; text-transform:uppercase; letter-spacing:.04em; }
        .pm-col-val { font-weight:700; color:var(--bk-navy); font-size:.9rem; }
        .pm-code { font-family:ui-monospace,Menlo,Consolas,monospace; font-size:.74rem; color:#94a3b8; }
        .pm-divider { width:1px; background:var(--bk-border); align-self:stretch; }

        .sp { padding:3px 11px; border-radius:999px; font-size:.72rem; font-weight:800; white-space:nowrap;
            display:inline-flex; align-items:center; gap:4px; }
        .sp-SUCCESS { background:#dcfce7; color:#15803d; }
        .sp-PENDING { background:#fef3c7; color:#b45309; }
        .sp-FAILED  { background:#fee2e2; color:#b91c1c; }
        .pm-method { display:inline-block; font-size:.72rem; font-weight:700; padding:2px 9px; border-radius:6px;
            background:#eef2ff; color:#3730a3; }

        .pm-empty { text-align:center; padding:3.5rem 1.5rem; color:var(--bk-muted); }
        @media (max-width: 720px) { .pm-card { flex-wrap:wrap; } .pm-divider { display:none; } }
    </style>
</head>
<body class="bk-page">

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container pm-wrap py-4">

    <%-- ===== Heading ===== --%>
    <div class="d-flex align-items-center flex-wrap gap-2 mb-4">
        <div>
            <h3 class="fw-bold mb-0" style="color:var(--bk-navy);">Payment History</h3>
            <div class="pm-sub">${total} transaction(s)</div>
        </div>
        <a href="${pageContext.request.contextPath}/customer/booking/history"
           class="ms-auto btn btn-outline-primary fw-semibold"><i class="bi bi-ticket-detailed"></i> My Bookings</a>
    </div>

    <%-- ===== Filter (server-side) ===== --%>
    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4">
        <div class="pm-filter">
            <a class="pm-tab ${empty fStatus ? 'active' : ''}"
               href="${pageContext.request.contextPath}/customer/payments">All</a>
            <a class="pm-tab ${fStatus == 'SUCCESS' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/customer/payments?status=SUCCESS">Paid</a>
            <a class="pm-tab ${fStatus == 'PENDING' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/customer/payments?status=PENDING">Pending</a>
            <a class="pm-tab ${fStatus == 'FAILED' ? 'active' : ''}"
               href="${pageContext.request.contextPath}/customer/payments?status=FAILED">Failed</a>
        </div>
        <form class="pm-search" method="get"
              action="${pageContext.request.contextPath}/customer/payments">
            <c:if test="${not empty fStatus}"><input type="hidden" name="status" value="${fStatus}"></c:if>
            <i class="bi bi-search"></i>
            <input type="text" name="q" class="form-control" placeholder="Search booking code"
                   value="${fn:escapeXml(fQ)}">
        </form>
    </div>

    <%-- ===== List ===== --%>
    <c:choose>
        <c:when test="${empty payments}">
            <div class="pm-empty">
                <div style="font-size:3rem;"><i class="bi bi-receipt"></i></div>
                <h5 class="fw-bold mt-2" style="color:var(--bk-navy);">No payments found</h5>
                <p>You don't have any transactions matching this filter yet.</p>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach var="p" items="${payments}">
                <div class="pm-card">
                    <div class="flex-grow-1 min-width-0">
                        <div class="d-flex align-items-start gap-2 flex-wrap">
                            <div class="flex-grow-1">
                                <div class="pm-title"><c:out value="${p.movieTitle}"/></div>
                                <div class="pm-sub">
                                    <c:if test="${not empty p.branchName}"><c:out value="${p.branchName}"/></c:if>
                                    <c:if test="${not empty p.startTime}">
                                        · ${fn:substring(p.startTime, 0, 10)} ${fn:substring(p.startTime, 11, 16)}</c:if>
                                </div>
                            </div>
                            <span class="sp sp-${p.status}">
                                <c:choose>
                                    <c:when test="${p.status eq 'SUCCESS'}"><i class="bi bi-check-circle-fill"></i> PAID</c:when>
                                    <c:when test="${p.status eq 'FAILED'}"><i class="bi bi-x-circle"></i> FAILED</c:when>
                                    <c:otherwise><i class="bi bi-hourglass-split"></i> PENDING</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <div class="d-flex gap-3 flex-wrap mt-3 align-items-end">
                            <div>
                                <div class="pm-col-label">Method</div>
                                <div class="pm-col-val"><span class="pm-method"><c:out value="${p.method}"/></span></div>
                            </div>
                            <div class="pm-divider"></div>
                            <div>
                                <div class="pm-col-label">Paid time</div>
                                <div class="pm-col-val">
                                    <c:choose>
                                        <c:when test="${not empty p.paidAt}">
                                            ${fn:substring(p.paidAt, 0, 10)} ${fn:substring(p.paidAt, 11, 16)}</c:when>
                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="pm-divider"></div>
                            <div>
                                <div class="pm-col-label">Transaction ref</div>
                                <div class="pm-col-val mono">
                                    <c:choose>
                                        <c:when test="${not empty p.transactionRef}"><c:out value="${p.transactionRef}"/></c:when>
                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="pm-divider"></div>
                            <div>
                                <div class="pm-col-label">Amount</div>
                                <div class="pm-col-val" style="color:var(--bk-primary); font-size:1rem;">
                                    <fmt:formatNumber value="${p.amount}" pattern="#,###"/>₫</div>
                                <div class="pm-code">${p.bookingCode}</div>
                            </div>

                            <div class="ms-auto d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/customer/payment/receipt?bookingId=${p.bookingId}"
                                   class="btn btn-sm btn-outline-primary"><i class="bi bi-receipt"></i> View receipt</a>
                                <c:if test="${p.status eq 'PENDING' and p.bookingStatus eq 'PENDING'}">
                                    <a href="${pageContext.request.contextPath}/booking/payment?bookingId=${p.bookingId}"
                                       class="btn btn-sm btn-primary">Pay now</a>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <%-- ===== Pagination ===== --%>
            <c:if test="${totalPages > 1}">
                <nav class="d-flex justify-content-center mt-4">
                    <ul class="pagination">
                        <c:url var="prevUrl" value="/customer/payments">
                            <c:if test="${not empty fStatus}"><c:param name="status" value="${fStatus}"/></c:if>
                            <c:if test="${not empty fQ}"><c:param name="q" value="${fQ}"/></c:if>
                            <c:param name="page" value="${page - 1}"/>
                        </c:url>
                        <c:url var="nextUrl" value="/customer/payments">
                            <c:if test="${not empty fStatus}"><c:param name="status" value="${fStatus}"/></c:if>
                            <c:if test="${not empty fQ}"><c:param name="q" value="${fQ}"/></c:if>
                            <c:param name="page" value="${page + 1}"/>
                        </c:url>
                        <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${prevUrl}">Previous</a></li>
                        <li class="page-item disabled"><span class="page-link">Page ${page} / ${totalPages}</span></li>
                        <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${nextUrl}">Next</a></li>
                    </ul>
                </nav>
            </c:if>
        </c:otherwise>
    </c:choose>

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
