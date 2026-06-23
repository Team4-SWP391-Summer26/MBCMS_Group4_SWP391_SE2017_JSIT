<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
          rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}"
          rel="stylesheet">
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="dashboard"/>
</jsp:include>

<main class="lc-admin-main">

<div class="container-fluid px-4 py-4">

    <!-- PAGE HEADER -->

    <div class="d-flex justify-content-between align-items-center mb-4">

        <div>
            <div class="text-muted small">
                Administration
            </div>

            <h3 class="fw-bold text-navy mb-0">
                System Dashboard
            </h3>
        </div>

    </div>

    <!-- KPI CARDS -->

    <div class="row g-3 mb-4">

        <div class="col-md-3">

            <div class="card shadow-sm h-100">

                <div class="card-body">

                    <div class="d-flex justify-content-between">

                        <div>

                            <div class="text-muted small">
                                TOTAL BRANCHES
                            </div>

                            <h2 class="fw-bold">
                                ${totalBranches}
                            </h2>

                        </div>

                        <i class="bi bi-building fs-1 text-primary"></i>

                    </div>

                </div>

            </div>

        </div>

        <div class="col-md-3">

            <div class="card shadow-sm h-100">

                <div class="card-body">

                    <div class="d-flex justify-content-between">

                        <div>

                            <div class="text-muted small">
                                TOTAL HALLS
                            </div>

                            <h2 class="fw-bold">
                                ${totalRooms}
                            </h2>

                        </div>

                        <i class="bi bi-door-open fs-1 text-success"></i>

                    </div>

                </div>

            </div>

        </div>

        <div class="col-md-3">

            <div class="card shadow-sm h-100">

                <div class="card-body">

                    <div class="d-flex justify-content-between">

                        <div>

                            <div class="text-muted small">
                                TOTAL SEATS
                            </div>

                            <h2 class="fw-bold">
                                ${totalSeats}
                            </h2>

                        </div>

                        <i class="bi bi-grid-3x3-gap fs-1 text-warning"></i>

                    </div>

                </div>

            </div>

        </div>

        <div class="col-md-3">

            <div class="card shadow-sm h-100">

                <div class="card-body">

                    <div class="d-flex justify-content-between">

                        <div>

                            <div class="text-muted small">
                                ACTIVE BRANCHES
                            </div>

                            <h2 class="fw-bold">
                                ${activeBranches}
                            </h2>

                        </div>

                        <i class="bi bi-check-circle fs-1 text-info"></i>

                    </div>

                </div>

            </div>

        </div>

    </div>

    <!-- QUICK ACTIONS -->

    <div class="card shadow-sm mb-4">

        <div class="card-header">

            <strong>
                Quick Actions
            </strong>

        </div>

        <div class="card-body">

            <div class="row g-3">

                <div class="col-md-3">

                    <a href="${pageContext.request.contextPath}/admin/branches"
                       class="btn btn-primary w-100">

                        <i class="bi bi-building me-2"></i>

                        Manage Branches

                    </a>

                </div>

                <div class="col-md-3">

                    <a href="${pageContext.request.contextPath}/admin/halls"
                       class="btn btn-success w-100">

                        <i class="bi bi-door-open me-2"></i>

                        Manage Halls

                    </a>

                </div>

                <div class="col-md-3">

                    <a href="${pageContext.request.contextPath}/admin/movies"
                       class="btn btn-warning w-100">

                        <i class="bi bi-film me-2"></i>

                        Manage Movies

                    </a>

                </div>

                <div class="col-md-3">

                    <a href="${pageContext.request.contextPath}/admin/users"
                       class="btn btn-dark w-100">

                        <i class="bi bi-people me-2"></i>

                        Manage Users

                    </a>

                </div>

            </div>

        </div>

    </div>

    <!-- RECENT BRANCHES -->

    <div class="card shadow-sm">

        <div class="card-header">

            <strong>
                Branch Overview
            </strong>

        </div>

        <div class="card-body">

            <div class="table-responsive">

                <table class="table table-hover align-middle">

                    <thead>

                    <tr>

                        <th>ID</th>
                        <th>Name</th>
                        <th>City</th>
                        <th>Phone</th>
                        <th>Status</th>

                    </tr>

                    </thead>

                    <tbody>

                    <c:forEach items="${branches}" var="b">

                        <tr>

                            <td>${b.branchId}</td>

                            <td>
                                <strong>${b.name}</strong>
                            </td>

                            <td>${b.city}</td>

                            <td>${b.phone}</td>

                            <td>

                                <c:choose>

                                    <c:when test="${b.active}">

                                        <span class="badge bg-success">
                                            Active
                                        </span>

                                    </c:when>

                                    <c:otherwise>

                                        <span class="badge bg-secondary">
                                            Inactive
                                        </span>

                                    </c:otherwise>

                                </c:choose>

                            </td>

                        </tr>

                    </c:forEach>

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
