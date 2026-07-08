<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Payment History - Console (owner: HungNT). Admin + Branch Manager dung chung
    (${isAdmin} chon sidebar + URL prefix). Loc + phan trang SERVER-SIDE; dropdown
    auto-submit, o text bam Search. Style: he thong .pay-* trong manager.css.
--%>
<c:set var="base" value="${isAdmin ? '/admin' : '/branch'}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment History – PentaPlex ${isAdmin ? 'Admin' : 'Manager'}</title>
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
                        <div class="lc-page-section"><i class="bi bi-credit-card-2-front me-1"></i> Finance / Payments</div>
                    </c:otherwise>
                </c:choose>
                <h1 class="lc-page-title">Payment History</h1>
            </div>
            <nav class="lc-page-nav" aria-label="Payment views">
                <a class="active" href="${pageContext.request.contextPath}${base}/payments">
                    <i class="bi bi-list-ul" aria-hidden="true"></i> History</a>
                <a href="${pageContext.request.contextPath}${base}/payments/monitor">
                    <i class="bi bi-activity" aria-hidden="true"></i> Monitoring</a>
            </nav>
        </div>

        <c:if test="${not isAdmin}">
            <div class="lc-scope mb-3">
                <i class="bi bi-shield-lock-fill" style="color:#cf9a00;"></i>
                <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}"/></strong>
                    &mdash; you only see transactions for your assigned branch.</span>
            </div>
        </c:if>

        <%-- ===== Filter toolbar (dropdown/date auto-submit; text: Search) ===== --%>
        <div class="pay-toolbar lc-rise" style="--i:0;">
            <form class="pay-filter-grid ${isAdmin ? 'has-branch' : ''}" method="get"
                  action="${pageContext.request.contextPath}${base}/payments">
                <div class="pay-filter-field">
                    <label>Status</label>
                    <select name="status" class="form-select" onchange="this.form.submit()">
                        <option value="">All statuses</option>
                        <option value="SUCCESS" ${fStatus == 'SUCCESS' ? 'selected' : ''}>Success</option>
                        <option value="PENDING" ${fStatus == 'PENDING' ? 'selected' : ''}>Pending</option>
                        <option value="FAILED"  ${fStatus == 'FAILED'  ? 'selected' : ''}>Failed</option>
                    </select>
                </div>
                <div class="pay-filter-field">
                    <label>Method</label>
                    <select name="method" class="form-select" onchange="this.form.submit()">
                        <option value="">All methods</option>
                        <option value="VNPAY" ${fMethod == 'VNPAY' ? 'selected' : ''}>VNPay</option>
                        <option value="CASH"  ${fMethod == 'CASH'  ? 'selected' : ''}>Cash</option>
                    </select>
                </div>
                <c:if test="${isAdmin}">
                    <div class="pay-filter-field">
                        <label>Branch</label>
                        <select name="branch" class="form-select" onchange="this.form.submit()">
                            <option value="">All branches</option>
                            <c:forEach var="br" items="${branches}">
                                <option value="${br.branchId}" ${fBranch == br.branchId ? 'selected' : ''}>
                                    <c:out value="${br.name}"/></option>
                            </c:forEach>
                        </select>
                    </div>
                </c:if>
                <div class="pay-filter-field">
                    <label>From</label>
                    <input type="date" name="from" class="form-control"
                           value="${fFrom}" onchange="this.form.submit()">
                </div>
                <div class="pay-filter-field">
                    <label>To</label>
                    <input type="date" name="to" class="form-control"
                           value="${fTo}" onchange="this.form.submit()">
                </div>
                <div class="pay-filter-field pay-filter-field--search">
                    <label>Search</label>
                    <div class="pay-search-box">
                        <i class="bi bi-search" aria-hidden="true"></i>
                        <input type="search" name="q" placeholder="Code / ref / customer"
                               value="${fn:escapeXml(fQ)}" aria-label="Search transactions">
                        <button class="pay-search-btn" type="submit" title="Search">
                            <i class="bi bi-arrow-right" aria-hidden="true"></i></button>
                        <a class="pay-search-reset"
                           href="${pageContext.request.contextPath}${base}/payments" title="Reset filters">
                            <i class="bi bi-arrow-counterclockwise" aria-hidden="true"></i></a>
                    </div>
                </div>
            </form>
        </div>

        <%-- ===== Table ===== --%>
        <div class="pay-card lc-rise" style="--i:1;">
            <div class="table-responsive">
                <table class="pay-table">
                    <thead>
                        <tr>
                            <th>Paid time</th>
                            <th>Booking</th>
                            <th>Customer</th>
                            <th>Movie</th>
                            <c:if test="${isAdmin}"><th>Branch</th></c:if>
                            <th>Method</th>
                            <th class="r">Amount</th>
                            <th>Status</th>
                            <th class="r">Invoice</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:if test="${empty payments}">
                            <tr><td colspan="${isAdmin ? 9 : 8}">
                                <div class="pay-empty">
                                    <i class="bi bi-inbox"></i>
                                    <div class="fw-semibold text-navy">No transactions found</div>
                                    <div class="small">Try adjusting the filters above.</div>
                                </div>
                            </td></tr>
                        </c:if>
                        <c:forEach var="p" items="${payments}">
                            <tr>
                                <td class="pay-time">
                                    <c:choose>
                                        <c:when test="${not empty p.paidAt}">
                                            ${fn:substring(p.paidAt, 0, 10)}<span class="text-muted"> ${fn:substring(p.paidAt, 11, 16)}</span></c:when>
                                        <c:otherwise><span class="dash">— not paid —</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td><span class="pay-code">${p.bookingCode}</span></td>
                                <td>
                                    <div class="pay-cust">
                                        <div class="pay-avatar">${fn:toUpperCase(fn:substring(p.customerFullName, 0, 1))}</div>
                                        <div>
                                            <div class="nm"><c:out value="${p.customerFullName}"/></div>
                                            <div class="em"><c:out value="${p.customerEmail}"/></div>
                                        </div>
                                    </div>
                                </td>
                                <td class="text-navy"><c:out value="${p.movieTitle}"/></td>
                                <c:if test="${isAdmin}"><td><c:out value="${p.branchName}"/></td></c:if>
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
                                <td class="r">
                                    <c:choose>
                                        <c:when test="${p.status eq 'SUCCESS'}">
                                            <a class="btn btn-sm btn-outline-secondary"
                                               href="${pageContext.request.contextPath}${base}/payments/receipt/pdf?bookingId=${p.bookingId}"
                                               title="Download invoice (PDF)"><i class="bi bi-file-earmark-pdf"></i></a>
                                        </c:when>
                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <%-- ===== Footer: count + pagination ===== --%>
            <div class="pay-foot">
                <div class="cnt"><strong>${total}</strong> transaction(s) &middot; page ${page} of ${totalPages}</div>
                <c:if test="${totalPages > 1}">
                    <c:url var="prevUrl" value="${base}/payments">
                        <c:if test="${not empty fStatus}"><c:param name="status" value="${fStatus}"/></c:if>
                        <c:if test="${not empty fMethod}"><c:param name="method" value="${fMethod}"/></c:if>
                        <c:if test="${not empty fBranch}"><c:param name="branch" value="${fBranch}"/></c:if>
                        <c:if test="${not empty fFrom}"><c:param name="from" value="${fFrom}"/></c:if>
                        <c:if test="${not empty fTo}"><c:param name="to" value="${fTo}"/></c:if>
                        <c:if test="${not empty fQ}"><c:param name="q" value="${fQ}"/></c:if>
                        <c:param name="page" value="${page - 1}"/>
                    </c:url>
                    <c:url var="nextUrl" value="${base}/payments">
                        <c:if test="${not empty fStatus}"><c:param name="status" value="${fStatus}"/></c:if>
                        <c:if test="${not empty fMethod}"><c:param name="method" value="${fMethod}"/></c:if>
                        <c:if test="${not empty fBranch}"><c:param name="branch" value="${fBranch}"/></c:if>
                        <c:if test="${not empty fFrom}"><c:param name="from" value="${fFrom}"/></c:if>
                        <c:if test="${not empty fTo}"><c:param name="to" value="${fTo}"/></c:if>
                        <c:if test="${not empty fQ}"><c:param name="q" value="${fQ}"/></c:if>
                        <c:param name="page" value="${page + 1}"/>
                    </c:url>
                    <ul class="pagination pagination-sm mb-0">
                        <li class="page-item ${page <= 1 ? 'disabled' : ''}">
                            <a class="page-link" href="${prevUrl}"><i class="bi bi-chevron-left"></i></a></li>
                        <li class="page-item disabled"><span class="page-link">${page} / ${totalPages}</span></li>
                        <li class="page-item ${page >= totalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${nextUrl}"><i class="bi bi-chevron-right"></i></a></li>
                    </ul>
                </c:if>
            </div>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
</body>
</html>
