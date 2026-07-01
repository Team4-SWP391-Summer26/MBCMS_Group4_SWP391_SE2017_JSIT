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
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            .badge-code {
                background-color: var(--navy);
                color: var(--lc-bg);
                font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
                font-weight: 700;
                padding: 0.35em 0.65em;
                border-radius: 6px;
                letter-spacing: 0.05em;
            }
            .filter-tab {
                cursor: pointer;
                padding: 0.4rem 0.8rem;
                font-size: 0.85rem;
                font-weight: 600;
                color: var(--lc-muted);
                border-radius: 6px;
                text-decoration: none;
                transition: all 0.15s ease;
            }
            .filter-tab:hover {
                background: #f1f5f9;
                color: var(--navy);
            }
            .filter-tab.active {
                background: var(--lc-primary);
                color: #fff;
            }
        </style>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="promotions" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1240px;">

                <%-- ===== Page header ===== --%>
                <div class="mb-3">
                    <div class="text-muted small mb-1">Dashboard / Promotions</div>
                    <h4 class="text-navy fw-bold mb-0">Promotion Management</h4>
                </div>

                <%-- ===== Branch scope notice ===== --%>
                <div class="lc-scope mb-4">
                    <i class="bi bi-info-circle-fill" style="color:#cf9a00;"></i>
                    <span>Promotions are <strong>branch-specific</strong> &mdash; they can only be applied at this cinema branch.</span>
                </div>

                <%-- ===== Feedback alerts ===== --%>
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

                <%-- ===== KPI statistics cards ===== --%>
                <div class="row g-3 mb-4">
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#E7F0FF; color:#0D6EFD;">
                                    <i class="bi bi-tag-fill"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Total promotions</div>
                                    <div class="text-navy lc-stat-value" style="font-size:1.6rem;">${statTotal}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#E8F5EE; color:#198754;">
                                    <i class="bi bi-check-circle-fill"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Active</div>
                                    <div class="text-navy lc-stat-value" style="font-size:1.6rem;">${statActive}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#FFF4D6; color:#B58105;">
                                    <i class="bi bi-ticket-perforated-fill"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Used this month</div>
                                    <div class="text-navy lc-stat-value" style="font-size:1.6rem;">${statUsed}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#FBE4E6; color:#B02A37;">
                                    <i class="bi bi-graph-down-arrow"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Revenue impact</div>
                                    <div class="text-navy lc-stat-value" style="font-size:1.6rem; color:#B02A37;">
                                        -<fmt:formatNumber value="${statRevenue}" pattern="#,##0" />₫
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- ===== Filters & Toolbar ===== --%>
                <div class="card lc-elev p-3 mb-4">
                    <form method="get" action="${pageContext.request.contextPath}/branch/promotions" id="filterForm">
                        <div class="row g-3 align-items-center">
                            <%-- Search --%>
                            <div class="col-md-4">
                                <div class="input-group input-group-sm">
                                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-search"></i></span>
                                    <input type="text" class="form-control border-start-0" name="search"
                                           placeholder="Search by code or name..." value="${fn:escapeXml(filterSearch)}">
                                </div>
                            </div>

                            <%-- Discount Type dropdown --%>
                            <div class="col-md-3">
                                <select class="form-select form-select-sm" name="type" onchange="this.form.submit()">
                                    <option value="">All Types</option>
                                    <option value="PERCENT" ${filterType == 'PERCENT' ? 'selected' : ''}>Percentage</option>
                                    <option value="FIXED_AMOUNT" ${filterType == 'FIXED_AMOUNT' ? 'selected' : ''}>Fixed amount</option>
                                </select>
                            </div>

                            <%-- Status tabs --%>
                            <div class="col-md-5 d-flex align-items-center justify-content-md-between flex-wrap gap-2">
                                <div class="d-flex gap-1 bg-light p-1 rounded">
                                    <input type="hidden" name="status" id="statusField" value="${fn:escapeXml(filterStatus)}">
                                    <a class="filter-tab ${empty filterStatus ? 'active' : ''}" onclick="setStatusFilter('')">All</a>
                                    <a class="filter-tab ${filterStatus == 'Active' ? 'active' : ''}" onclick="setStatusFilter('Active')">Active</a>
                                    <a class="filter-tab ${filterStatus == 'Inactive' ? 'active' : ''}" onclick="setStatusFilter('Inactive')">Inactive</a>
                                    <a class="filter-tab ${filterStatus == 'Expired' ? 'active' : ''}" onclick="setStatusFilter('Expired')">Expired</a>
                                </div>
                                <a class="btn btn-primary btn-sm ms-auto" href="${pageContext.request.contextPath}/branch/promotions/create">
                                    <i class="bi bi-plus-lg me-1"></i>Add Promotion</a>
                            </div>
                        </div>
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
                                <c:if test="${empty promotions}">
                                    <tr>
                                        <td colspan="9" class="text-center text-muted py-4">
                                            No promotions found matching the search criteria.
                                        </td>
                                    </tr>
                                </c:if>
                                <c:forEach var="p" items="${promotions}">
                                    <c:set var="pct" value="${p.maxUses != null && p.maxUses > 0 ? (p.usedCount * 100 / p.maxUses) : 0}" />
                                    <tr>
                                        <td class="ps-3">
                                            <span class="badge-code"><c:out value="${p.code}" /></span>
                                        </td>
                                        <td>
                                            <div class="text-navy fw-semibold"><c:out value="${p.name}" /></div>
                                        </td>
                                        <td>
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
                                                <form method="post" action="${pageContext.request.contextPath}/branch/promotions/toggle" class="d-inline"
                                                      onsubmit="return confirm('Toggle status for <c:out value="${p.code}"/>?');">
                                                    <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                                    <input type="hidden" name="id" value="${p.promoId}">
                                                    <button type="submit" class="btn btn-sm ${p.active ? 'btn-outline-warning' : 'btn-outline-success'}" title="${p.active ? 'Pause' : 'Activate'}">
                                                        <i class="bi ${p.active ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                                    </button>
                                                </form>
                                                <form method="post" action="${pageContext.request.contextPath}/branch/promotions/delete" class="d-inline"
                                                      onsubmit="return confirm('Are you sure you want to delete <c:out value="${p.code}"/>? This action cannot be undone and will delete it from the database.');">
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                                          function setStatusFilter(status) {
                                                              document.getElementById('statusField').value = status;
                                                              document.getElementById('filterForm').submit();
                                                          }
        </script>
    </body>
</html>
