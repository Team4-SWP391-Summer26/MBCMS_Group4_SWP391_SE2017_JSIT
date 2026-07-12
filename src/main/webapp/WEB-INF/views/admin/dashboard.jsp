<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - PentaPlex Admin</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="dashboard"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Administration</div>
                <h1 class="lc-page-title">System Dashboard</h1>
                <p class="text-muted small mb-0 mt-1">Network overview across all PentaPlex cinemas.</p>
            </div>
        </div>

        <div class="lc-kpi-row">
            <div class="lc-kpi-card lc-rise" style="--i:0;">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-building"></i></div>
                <div>
                    <div class="lc-kpi-label">Total cinemas</div>
                    <div class="lc-kpi-value">${totalBranches}</div>
                    <div class="lc-kpi-hint">Branches in the network</div>
                </div>
            </div>
            <div class="lc-kpi-card lc-rise" style="--i:1;">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-check-circle-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Active cinemas</div>
                    <div class="lc-kpi-value">${activeBranches}</div>
                    <div class="lc-kpi-hint">Currently operating</div>
                </div>
            </div>
            <div class="lc-kpi-card lc-rise" style="--i:2;">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-door-open"></i></div>
                <div>
                    <div class="lc-kpi-label">Total rooms</div>
                    <div class="lc-kpi-value">${totalRooms}</div>
                    <div class="lc-kpi-hint">Across all cinemas</div>
                </div>
            </div>
            <div class="lc-kpi-card lc-rise" style="--i:3;">
                <div class="lc-stat-icon lc-kpi-icon--slate"><i class="bi bi-grid-3x3-gap"></i></div>
                <div>
                    <div class="lc-kpi-label">Total seats</div>
                    <div class="lc-kpi-value">${totalSeats}</div>
                    <div class="lc-kpi-hint">Installed capacity</div>
                </div>
            </div>
        </div>

        <div class="lc-dash-sec">Manage the system</div>
        <div class="row g-3 lc-tile-grid">
            <div class="col-md-6 col-xl-4">
                <a class="lc-dash-tile is-live" href="${pageContext.request.contextPath}/admin/branches">
                    <span class="lc-dash-tile-ic"><i class="bi bi-building"></i></span>
                    <div class="lc-dash-tile-tt">Cinemas</div>
                    <div class="lc-dash-tile-ds">Add, edit and configure cinemas, their rooms and seat layouts.</div>
                    <span class="lc-dash-tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="lc-dash-tile is-live" href="${pageContext.request.contextPath}/admin/users">
                    <span class="lc-dash-tile-ic"><i class="bi bi-people"></i></span>
                    <div class="lc-dash-tile-tt">Users</div>
                    <div class="lc-dash-tile-ds">Manage customers, branch managers, staff and administrators.</div>
                    <span class="lc-dash-tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="lc-dash-tile is-live" href="${pageContext.request.contextPath}/admin/movies">
                    <span class="lc-dash-tile-ic"><i class="bi bi-film"></i></span>
                    <div class="lc-dash-tile-tt">Movies</div>
                    <div class="lc-dash-tile-ds">Catalog, posters, trailers and release status.</div>
                    <span class="lc-dash-tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="lc-dash-tile is-live" href="${pageContext.request.contextPath}/admin/genres">
                    <span class="lc-dash-tile-ic"><i class="bi bi-tags"></i></span>
                    <div class="lc-dash-tile-tt">Genres</div>
                    <div class="lc-dash-tile-ds">Maintain movie genres used across the catalog.</div>
                    <span class="lc-dash-tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="lc-dash-tile is-live" href="${pageContext.request.contextPath}/admin/payments">
                    <span class="lc-dash-tile-ic"><i class="bi bi-credit-card"></i></span>
                    <div class="lc-dash-tile-tt">Payments</div>
                    <div class="lc-dash-tile-ds">Payment history and transaction monitoring network-wide.</div>
                    <span class="lc-dash-tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <div class="lc-dash-tile is-soon">
                    <span class="lc-dash-tile-soon">Soon</span>
                    <span class="lc-dash-tile-ic"><i class="bi bi-bar-chart"></i></span>
                    <div class="lc-dash-tile-tt">System Reports</div>
                    <div class="lc-dash-tile-ds">Revenue, occupancy and performance analytics.</div>
                </div>
            </div>
            <div class="col-md-6 col-xl-4">
                <div class="lc-dash-tile is-soon">
                    <span class="lc-dash-tile-soon">Soon</span>
                    <span class="lc-dash-tile-ic"><i class="bi bi-star"></i></span>
                    <div class="lc-dash-tile-tt">Review Approval</div>
                    <div class="lc-dash-tile-ds">Moderate customer reviews before they go public.</div>
                </div>
            </div>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
</body>
</html>
