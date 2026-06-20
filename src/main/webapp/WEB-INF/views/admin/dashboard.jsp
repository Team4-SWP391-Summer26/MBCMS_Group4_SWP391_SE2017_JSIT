<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    Admin Dashboard (owner: HungNT) - trang chinh cua Admin console.
    Console layout dung chung manager.css + _sidebar.jsp (admin).
    Chi hien du lieu that (so phim/chi nhanh/phan phoi). Cac module cua nguoi
    khac (Movies catalog, Branches, Users, Reports) de "Soon".
--%>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Admin Dashboard - MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            .feat-card { display: flex; flex-direction: column; transition: transform .12s ease, box-shadow .12s ease; }
            a.feat-card:hover { transform: translateY(-3px); box-shadow: 0 10px 24px rgba(15,23,42,.10); }
            .feat-card .feat-desc { font-size: .82rem; color: var(--lc-muted); flex-grow: 1; }
            .feat-soon { opacity: .72; }
            .feat-title { font-weight: 700; color: #0f1e36; }
        </style>
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
            <jsp:param name="active" value="dashboard" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1200px;">

                <%-- ===== Page header ===== --%>
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
                    <div>
                        <div class="text-muted small mb-1">Dashboard</div>
                        <h4 class="text-navy fw-bold mb-0">Admin Dashboard</h4>
                        <div class="text-muted small mt-1">Welcome back,
                            <c:out value="${sessionScope.currentUser.fullName}" />.</div>
                    </div>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/movie-branches">
                        <i class="bi bi-diagram-3 me-1"></i>Movie Distribution</a>
                </div>

                <%-- ===== KPI cards (du lieu that) ===== --%>
                <div class="row g-3 mb-4">
                    <div class="col-sm-6 col-xl-4">
                        <div class="card lc-elev p-4 h-100">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon"><i class="bi bi-film"></i></div>
                                <div class="text-muted small fw-semibold">ACTIVE MOVIES</div>
                            </div>
                            <div class="text-navy lc-stat-value">${movieCount}</div>
                            <div class="text-muted small mt-1">In shared catalog</div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-4">
                        <div class="card lc-elev p-4 h-100">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon" style="background:#E8F5EE; color:#198754;">
                                    <i class="bi bi-building"></i></div>
                                <div class="text-muted small fw-semibold">BRANCHES</div>
                            </div>
                            <div class="text-navy lc-stat-value">${branchCount}</div>
                            <div class="text-muted small mt-1">Across the system</div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-4">
                        <div class="card lc-elev p-4 h-100">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon" style="background:#ECE3F8; color:#6F42C1;">
                                    <i class="bi bi-diagram-3"></i></div>
                                <div class="text-muted small fw-semibold">MOVIE ASSIGNMENTS</div>
                            </div>
                            <div class="text-navy lc-stat-value">${distributionCount}</div>
                            <div class="text-muted small mt-1">Movie&ndash;branch pairs</div>
                        </div>
                    </div>
                </div>

                <%-- ===== Management modules ===== --%>
                <h6 class="text-navy fw-bold mb-3">Management</h6>
                <div class="row g-3">

                    <%-- Movie Distribution - feature that (HungNT) --%>
                    <div class="col-md-6 col-xl-4">
                        <a class="card lc-elev feat-card h-100 p-4 text-decoration-none"
                           href="${pageContext.request.contextPath}/admin/movie-branches">
                            <div class="lc-stat-icon mb-3"><i class="bi bi-diagram-3"></i></div>
                            <div class="feat-title mb-1">Movie Distribution</div>
                            <div class="feat-desc mb-3">Assign which movies are available at each branch.</div>
                            <span class="text-primary small fw-semibold">Open <i class="bi bi-arrow-right"></i></span>
                        </a>
                    </div>

                    <%-- Cac module cua nguoi khac - Soon --%>
                    <div class="col-md-6 col-xl-4">
                        <div class="card lc-elev feat-card feat-soon h-100 p-4">
                            <div class="lc-stat-icon mb-3" style="background:#EEF1F4; color:#94a3b8;">
                                <i class="bi bi-film"></i></div>
                            <div class="feat-title mb-1">Movies <span class="lc-sb-soon" style="background:#EEF1F4;color:#94a3b8;">Soon</span></div>
                            <div class="feat-desc mb-3">Manage the movie catalog (add, edit, posters, status).</div>
                            <span class="pill pill-gray">Coming soon</span>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-4">
                        <div class="card lc-elev feat-card feat-soon h-100 p-4">
                            <div class="lc-stat-icon mb-3" style="background:#EEF1F4; color:#94a3b8;">
                                <i class="bi bi-building"></i></div>
                            <div class="feat-title mb-1">Branches <span class="lc-sb-soon" style="background:#EEF1F4;color:#94a3b8;">Soon</span></div>
                            <div class="feat-desc mb-3">Manage cinema branches and halls.</div>
                            <span class="pill pill-gray">Coming soon</span>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-4">
                        <div class="card lc-elev feat-card feat-soon h-100 p-4">
                            <div class="lc-stat-icon mb-3" style="background:#EEF1F4; color:#94a3b8;">
                                <i class="bi bi-people"></i></div>
                            <div class="feat-title mb-1">Users <span class="lc-sb-soon" style="background:#EEF1F4;color:#94a3b8;">Soon</span></div>
                            <div class="feat-desc mb-3">Manage staff and manager accounts.</div>
                            <span class="pill pill-gray">Coming soon</span>
                        </div>
                    </div>
                    <div class="col-md-6 col-xl-4">
                        <div class="card lc-elev feat-card feat-soon h-100 p-4">
                            <div class="lc-stat-icon mb-3" style="background:#EEF1F4; color:#94a3b8;">
                                <i class="bi bi-bar-chart"></i></div>
                            <div class="feat-title mb-1">Reports <span class="lc-sb-soon" style="background:#EEF1F4;color:#94a3b8;">Soon</span></div>
                            <div class="feat-desc mb-3">System-wide revenue and analytics.</div>
                            <span class="pill pill-gray">Coming soon</span>
                        </div>
                    </div>
                </div>

            </div>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
