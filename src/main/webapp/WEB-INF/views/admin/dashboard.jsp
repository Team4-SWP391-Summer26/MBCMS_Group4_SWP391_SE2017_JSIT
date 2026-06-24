<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Admin System Dashboard - consistent console style (lc-kpi / lc-elev / lc-table). --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - MBCMS Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="dashboard"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <div class="text-muted small mb-1">Administration</div>
        <h4 class="text-navy fw-bold mb-4">System Dashboard</h4>

        <%-- KPI ROW --%>
        <div class="row g-3 mb-4">
            <div class="col-md-3 col-6">
                <div class="lc-kpi">
                    <div class="lc-kpi-icon"><i class="bi bi-building"></i></div>
                    <div>
                        <div class="lc-kpi-label">Total Cinemas</div>
                        <div class="lc-kpi-value">${totalBranches}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="lc-kpi">
                    <div class="lc-kpi-icon i-green"><i class="bi bi-check-circle"></i></div>
                    <div>
                        <div class="lc-kpi-label">Active Cinemas</div>
                        <div class="lc-kpi-value">${activeBranches}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="lc-kpi">
                    <div class="lc-kpi-icon i-purple"><i class="bi bi-door-open"></i></div>
                    <div>
                        <div class="lc-kpi-label">Total Rooms</div>
                        <div class="lc-kpi-value">${totalRooms}</div>
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="lc-kpi">
                    <div class="lc-kpi-icon i-amber"><i class="bi bi-grid-3x3-gap"></i></div>
                    <div>
                        <div class="lc-kpi-label">Total Seats</div>
                        <div class="lc-kpi-value">${totalSeats}</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- QUICK ACTIONS --%>
        <div class="card lc-elev mb-4">
            <div class="card-body">
                <h6 class="text-navy fw-bold mb-3">Quick Actions</h6>
                <div class="row g-2">
                    <div class="col-md-3 col-6">
                        <a href="${pageContext.request.contextPath}/admin/branches" class="btn btn-primary w-100">
                            <i class="bi bi-building me-2"></i>Cinemas</a>
                    </div>
                    <div class="col-md-3 col-6">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn btn-outline-primary w-100">
                            <i class="bi bi-people me-2"></i>Users</a>
                    </div>
                    <div class="col-md-3 col-6">
                        <a href="${pageContext.request.contextPath}/admin/movie-branches" class="btn btn-outline-primary w-100">
                            <i class="bi bi-film me-2"></i>Movies</a>
                    </div>
                    <div class="col-md-3 col-6">
                        <a href="${pageContext.request.contextPath}/admin/payments" class="btn btn-outline-primary w-100">
                            <i class="bi bi-credit-card me-2"></i>Payments</a>
                    </div>
                </div>
            </div>
        </div>

        <%-- CINEMA OVERVIEW --%>
        <div class="card lc-elev">
            <div class="card-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 class="text-navy fw-bold mb-0">Cinema Overview</h6>
                    <a href="${pageContext.request.contextPath}/admin/branches" class="btn btn-light border btn-sm">
                        View all <i class="bi bi-arrow-right ms-1"></i></a>
                </div>
                <div class="table-responsive">
                    <table class="table lc-table align-middle mb-0">
                        <thead>
                        <tr><th>ID</th><th>Name</th><th>City</th><th>Phone</th><th>Status</th></tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${branches}" var="b">
                            <tr>
                                <td class="text-muted">#${b.branchId}</td>
                                <td><span class="fw-semibold text-navy"><c:out value="${b.name}"/></span></td>
                                <td>${b.city}</td>
                                <td>${b.phone}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.active}"><span class="pill pill-green">Active</span></c:when>
                                        <c:otherwise><span class="pill pill-gray">Inactive</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty branches}">
                            <tr><td colspan="5" class="text-center text-muted py-4">No cinemas yet.</td></tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
