<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="en_US" />
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Promotion Management - PentaPlex Manager</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="promotions" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <div class="lc-page-head">
                    <div>
                        <div class="lc-page-crumb">Dashboard / <strong>Promotions</strong></div>
                        <h1 class="lc-page-title">Promotion Management</h1>
                    </div>
                </div>

                <%-- [Flow Step: JSP View] Branch scope message check --%>
                <div class="lc-scope mb-4">
                    <i class="bi bi-info-circle-fill" style="color:#cf9a00;"></i>
                    <span>Promotions are <strong>branch-specific</strong> &mdash; they can only be applied at this cinema branch.</span>
                </div>

                <%-- [Flow Step: JSP View] Render feedback message bubbles set by PromotionListServlet --%>
                <c:if test="${not empty successMsg}">
                    <div class="alert alert-success py-2 alert-dismissible fade show" role="alert">
                        <i class="bi bi-check-circle-fill me-1"></i> ${successMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="padding: 0.75rem 1rem;"></button>
                    </div>
                </c:if>
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger py-2 alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> ${errorMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="padding: 0.75rem 1rem;"></button>
                    </div>
                </c:if>

                <%-- [Flow Step: JSP View] Output branch performance KPI figures queried from the Database via EL (${...}) --%>
                <div class="lc-kpi-row">
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-tag-fill"></i></div>
                        <div>
                            <div class="lc-kpi-label">Total promotions</div>
                            <div class="lc-kpi-value">${statTotal}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-check-circle-fill"></i></div>
                        <div>
                            <div class="lc-kpi-label">Active</div>
                            <div class="lc-kpi-value">${statActive}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-ticket-perforated-fill"></i></div>
                        <div>
                            <div class="lc-kpi-label">Used this month</div>
                            <div class="lc-kpi-value">${statUsed}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--rose"><i class="bi bi-graph-down-arrow"></i></div>
                        <div>
                            <div class="lc-kpi-label">Revenue impact</div>
                            <div class="lc-kpi-value" style="color:#B02A37;">-<fmt:formatNumber value="${statRevenue}" pattern="#,##0" />₫</div>
                        </div>
                    </div>
                </div>

                <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
                    <form method="get" action="${pageContext.request.contextPath}/branch/promotions" id="filterForm" class="st-toolbar-track w-100">
                        <div class="lc-toolbar-search">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" name="search" placeholder="Search by code or name..."
                                   value="${fn:escapeXml(filterSearch)}" aria-label="Search promotions">
                        </div>
                        <div class="st-toolbar-vrule" aria-hidden="true"></div>
                        <select class="st-toolbar-select" name="type" onchange="this.form.submit()" aria-label="Discount type">
                            <option value="">All types</option>
                            <option value="PERCENT" ${filterType == 'PERCENT' ? 'selected' : ''}>Percentage</option>
                            <option value="FIXED_AMOUNT" ${filterType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed amount</option>
                        </select>
                        <div class="st-toolbar-vrule" aria-hidden="true"></div>
                        <input type="hidden" name="status" id="statusField" value="${fn:escapeXml(filterStatus)}">
                        <div class="lc-seg" role="tablist" aria-label="Filter by status">
                            <button type="button" class="lc-seg-btn ${empty filterStatus ? 'active' : ''}"
                                    onclick="setStatusFilter('')"><i class="bi bi-grid-3x3-gap-fill"></i> All</button>
                            <button type="button" class="lc-seg-btn ${filterStatus == 'Active' ? 'active' : ''}"
                                    onclick="setStatusFilter('Active')"><i class="bi bi-check-circle"></i> Active</button>
                            <button type="button" class="lc-seg-btn ${filterStatus == 'Inactive' ? 'active' : ''}"
                                    onclick="setStatusFilter('Inactive')"><i class="bi bi-pause-circle"></i> Inactive</button>
                            <button type="button" class="lc-seg-btn ${filterStatus == 'Expired' ? 'active' : ''}"
                                    onclick="setStatusFilter('Expired')"><i class="bi bi-clock-history"></i> Expired</button>
                        </div>
                        <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                        <a class="st-toolbar-add" href="${pageContext.request.contextPath}/branch/promotions/create">
                            <i class="bi bi-plus-lg" aria-hidden="true"></i> Add Promotion</a>
                    </form>
                </div>

                <%-- ===== Promotions Table ===== --%>
                <div class="card lc-elev p-0 overflow-hidden">
                    <div class="table-responsive">
                        <table class="table lc-table align-middle mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-3">Code</th>
                                    <th>Name</th>
                                    <th>Type</th>
                                    <th>Value</th>
                                    <th>Min order</th>
                                    <th>Valid period</th>
                                    <th>Usage</th>
                                    <th>Status</th>
                                    <th class="text-end pe-3">Actions</th>
                                </tr>
                            </thead>
                             <tbody>
                                <%-- [Flow Step: JSP View] Guard Check: If promotions list is empty, show feedback row --%>
                                <c:if test="${empty promotions}">
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-4">
                                            No promotions found matching the search criteria.
                                        </td>
                                    </tr>
                                </c:if>
                                <%-- [Flow Step: JSP View] Iterate over Java list via c:forEach. Variable p acts as the current Promotion model --%>
                                <c:forEach var="p" items="${promotions}">
                                    <%-- Calculate percentage of usages for the dynamic progress bar width --%>
                                    <c:set var="pct" value="${p.maxUses != null && p.maxUses > 0 ? (p.usedCount * 100 / p.maxUses) : 0}" />
                                    <tr>
                                        <td class="ps-3">
                                            <%-- c:out escapes XML/HTML characters to prevent Cross-Site Scripting (XSS) attacks --%>
                                            <span class="badge-code"><c:out value="${p.code}" /></span>
                                        </td>
                                        <td>
                                            <div class="text-navy fw-semibold"><c:out value="${p.name}" /></div>
                                        </td>
                                        <td>
                                            <%-- JSTL conditional choose block --%>
                                            <c:choose>
                                                <c:when test="${p.discountType == 'PERCENT'}">
                                                    <span class="pill pill-blue">Percentage</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pill pill-purple">Fixed amount</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="fw-bold text-navy">
                                            <%-- Format values to decimal patterns (e.g. 10,000) using fmt:formatNumber --%>
                                            <c:choose>
                                                <c:when test="${p.discountType == 'PERCENT'}">
                                                    <fmt:formatNumber value="${p.discountValue}" pattern="#,##0" />%
                                                </c:when>
                                                <c:otherwise>
                                                    <fmt:formatNumber value="${p.discountValue}" pattern="#,##0" />₫
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.minOrderAmount != null && p.minOrderAmount > 0}">
                                                    <fmt:formatNumber value="${p.minOrderAmount}" pattern="#,##0" />₫
                                                </c:when>
                                                <c:otherwise>
                                                    &mdash;
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="small text-navy fw-semibold mono">
                                             <%-- [Flow Step: JSP View] Format validFrom and validTo ISO strings to DD/MM/YYYY using fn:substring --%>
                                             ${fn:substring(p.validFrom, 8, 10)}/${fn:substring(p.validFrom, 5, 7)}/${fn:substring(p.validFrom, 0, 4)}
                                             &ndash;
                                             ${fn:substring(p.validTo, 8, 10)}/${fn:substring(p.validTo, 5, 7)}/${fn:substring(p.validTo, 0, 4)}
                                         </td>
                                         <td style="min-width: 140px;">
                                             <div class="d-flex justify-content-between small mb-1">
                                                 <span class="text-navy fw-semibold">${p.usedCount}/${p.maxUses != null ? p.maxUses : 'Unlimited'}</span>
                                                 <c:if test="${p.maxUses != null}">
                                                     <span class="text-muted"><fmt:formatNumber value="${pct}" maxFractionDigits="0" />%</span>
                                                 </c:if>
                                             </div>
                                             <div class="bar-track">
                                                 <div class="bar-fill" style="width: ${p.maxUses != null ? (pct > 100 ? 100 : pct) : 0}%; ${pct >= 100 ? 'background:#DC3545;' : ''}"></div>
                                             </div>
                                         </td>
                                         <td>
                                             <c:choose>
                                                 <c:when test="${p.status == 'Active'}">
                                                     <span class="pill pill-green">Active</span>
                                                 </c:when>
                                                 <c:when test="${p.status == 'Expired'}">
                                                     <span class="pill pill-red">Expired</span>
                                                 </c:when>
                                                 <c:otherwise>
                                                     <span class="pill pill-gray">Inactive</span>
                                                 </c:otherwise>
                                             </c:choose>
                                         </td>
                                         <td class="text-end pe-3">
                                             <div class="d-flex gap-1 justify-content-end">
                                                 <a class="btn btn-sm btn-outline-primary" title="Edit"
                                                    href="${pageContext.request.contextPath}/branch/promotions/edit?id=${p.promoId}">
                                                     <i class="bi bi-pencil"></i>
                                                 </a>
                                                 <%-- Toggle status form action --%>
                                                 <form method="post" action="${pageContext.request.contextPath}/branch/promotions/toggle" class="d-inline"
                                                       onsubmit="return confirm('Toggle status for <c:out value="${p.code}"/>?');">
                                                     <%-- Include CSRF hidden input field for POST request security --%>
                                                     <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                                     <input type="hidden" name="id" value="${p.promoId}">
                                                     <button type="submit" class="btn btn-sm ${p.active ? 'btn-outline-warning' : 'btn-outline-success'}" title="${p.active ? 'Pause' : 'Activate'}">
                                                         <i class="bi ${p.active ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                                     </button>
                                                 </form>
                                                 <%-- Delete promotion form action --%>
                                                 <form method="post" action="${pageContext.request.contextPath}/branch/promotions/delete" class="d-inline"
                                                       onsubmit="return confirm('Are you sure you want to delete <c:out value="${p.code}"/>? This action cannot be undone and will delete it from the database.');">
                                                     <%-- Include CSRF hidden input field for POST request security --%>
                                                     <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                                     <input type="hidden" name="id" value="${p.promoId}">
                                                     <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                                         <i class="bi bi-trash-fill"></i>
                                                     </button>
                                                 </form>
                                             </div>
                                         </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>

        <%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
        <script>
            /**
             * [Flow Step: JavaScript] Update status input field value and submit the form to reload list
             */
            function setStatusFilter(status) {
                document.getElementById('statusField').value = status;
                document.getElementById('filterForm').submit();
            }
        </script>
    </body>
</html>
