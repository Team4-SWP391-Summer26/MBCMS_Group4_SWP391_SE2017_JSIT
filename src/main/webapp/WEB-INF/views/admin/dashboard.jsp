<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Admin dashboard - restrained, single-accent design (no hero banner). --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - MBCMS Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* KPI - quiet, uniform */
        .kpi { background:#fff; border:1px solid var(--lc-border); border-radius:14px; box-shadow:var(--lc-shadow);
            padding:1.25rem 1.3rem; height:100%; }
        .kpi-head { display:flex; align-items:center; justify-content:space-between; margin-bottom:.85rem; }
        .kpi-lbl { font-size:.72rem; text-transform:uppercase; letter-spacing:.06em; color:var(--lc-muted); font-weight:700; }
        .kpi-ic { width:34px; height:34px; border-radius:9px; background:#f1f5f9; color:#64748b;
            display:flex; align-items:center; justify-content:center; font-size:1.05rem; }
        .kpi-val { font-size:2.1rem; font-weight:800; color:var(--lc-navy); line-height:1; letter-spacing:-.02em; }
        .kpi-sub { font-size:.77rem; color:var(--lc-muted); margin-top:.45rem; }

        .sec-title { font-size:.78rem; font-weight:700; text-transform:uppercase; letter-spacing:.08em;
            color:var(--lc-muted); margin:1.9rem 0 .9rem; }

        /* Navigation tiles - single blue accent, generous whitespace */
        .tile { position:relative; display:flex; flex-direction:column; gap:.7rem;
            background:#fff; border:1px solid var(--lc-border); border-radius:14px; box-shadow:var(--lc-shadow);
            padding:1.4rem 1.45rem; height:100%; text-decoration:none; color:inherit;
            transition:box-shadow .15s ease, transform .15s ease, border-color .15s ease; }
        .tile.is-live:hover { transform:translateY(-3px); box-shadow:0 12px 28px rgba(15,23,42,.10); border-color:#cdd9ee; }
        .tile-ic { width:46px; height:46px; border-radius:12px; background:var(--lc-light); color:var(--lc-primary);
            display:flex; align-items:center; justify-content:center; font-size:1.35rem; }
        .tile-tt { font-family:'Sora','Inter',sans-serif; font-weight:700; color:var(--lc-navy); font-size:1.02rem; letter-spacing:-.01em; }
        .tile-ds { font-size:.82rem; color:var(--lc-muted); line-height:1.45; }
        .tile-go { font-size:.8rem; font-weight:600; color:var(--lc-primary); display:inline-flex; align-items:center; gap:.35rem; margin-top:auto; }
        .tile.is-soon { opacity:.7; }
        .tile.is-soon .tile-ic { background:#f1f5f9; color:#94a3b8; }
        .tile-soon { position:absolute; top:1.1rem; right:1.2rem; font-size:.64rem; font-weight:700; text-transform:uppercase;
            letter-spacing:.05em; background:#eef1f4; color:#64748b; padding:.2rem .55rem; border-radius:999px; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="dashboard"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <%-- Header --%>
        <div class="text-muted small mb-1">Administration</div>
        <h4 class="text-navy fw-bold mb-1">Dashboard</h4>
        <div class="text-muted small mb-4">An overview of the MBCMS network across all cinemas.</div>

        <%-- KPI --%>
        <div class="row g-3">
            <div class="col-md-3 col-6">
                <div class="kpi">
                    <div class="kpi-head"><span class="kpi-lbl">Total Cinemas</span><span class="kpi-ic"><i class="bi bi-building"></i></span></div>
                    <div class="kpi-val">${totalBranches}</div>
                    <div class="kpi-sub">Branches in the network</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="kpi">
                    <div class="kpi-head"><span class="kpi-lbl">Active Cinemas</span><span class="kpi-ic"><i class="bi bi-check-circle"></i></span></div>
                    <div class="kpi-val">${activeBranches}</div>
                    <div class="kpi-sub">Currently operating</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="kpi">
                    <div class="kpi-head"><span class="kpi-lbl">Total Rooms</span><span class="kpi-ic"><i class="bi bi-door-open"></i></span></div>
                    <div class="kpi-val">${totalRooms}</div>
                    <div class="kpi-sub">Across all cinemas</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="kpi">
                    <div class="kpi-head"><span class="kpi-lbl">Total Seats</span><span class="kpi-ic"><i class="bi bi-grid-3x3-gap"></i></span></div>
                    <div class="kpi-val">${totalSeats}</div>
                    <div class="kpi-sub">Installed capacity</div>
                </div>
            </div>
        </div>

        <%-- Navigation tiles --%>
        <div class="sec-title">Manage the system</div>
        <div class="row g-3">
            <div class="col-md-6 col-xl-4">
                <a class="tile is-live" href="${pageContext.request.contextPath}/admin/branches">
                    <span class="tile-ic"><i class="bi bi-building"></i></span>
                    <div class="tile-tt">Cinemas</div>
                    <div class="tile-ds">Add, edit and configure cinemas, their rooms and seat layouts.</div>
                    <span class="tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="tile is-live" href="${pageContext.request.contextPath}/admin/users">
                    <span class="tile-ic"><i class="bi bi-people"></i></span>
                    <div class="tile-tt">Users</div>
                    <div class="tile-ds">Manage customers, branch managers, staff and administrators.</div>
                    <span class="tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="tile is-live" href="${pageContext.request.contextPath}/admin/movies">
                    <span class="tile-ic"><i class="bi bi-film"></i></span>
                    <div class="tile-tt">Movies</div>
                    <div class="tile-ds">Add, edit and delete movies, upload posters/trailers and set their status.</div>
                    <span class="tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="tile is-live" href="${pageContext.request.contextPath}/admin/genres">
                    <span class="tile-ic"><i class="bi bi-tags"></i></span>
                    <div class="tile-tt">Genres</div>
                    <div class="tile-ds">Maintain the list of movie genres used across the catalog.</div>
                    <span class="tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="tile is-live" href="${pageContext.request.contextPath}/admin/movie-branches">
                    <span class="tile-ic"><i class="bi bi-diagram-3"></i></span>
                    <div class="tile-tt">Movie Assignment</div>
                    <div class="tile-ds">Assign movies to the cinemas allowed to schedule them.</div>
                    <span class="tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="tile is-live" href="${pageContext.request.contextPath}/admin/payments">
                    <span class="tile-ic"><i class="bi bi-credit-card"></i></span>
                    <div class="tile-tt">Payments</div>
                    <div class="tile-ds">Review payment history and monitor transactions network-wide.</div>
                    <span class="tile-go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <div class="tile is-soon">
                    <span class="tile-soon">Soon</span>
                    <span class="tile-ic"><i class="bi bi-bar-chart"></i></span>
                    <div class="tile-tt">System Reports</div>
                    <div class="tile-ds">Revenue, occupancy and performance analytics across the network.</div>
                </div>
            </div>
            <div class="col-md-6 col-xl-4">
                <div class="tile is-soon">
                    <span class="tile-soon">Soon</span>
                    <span class="tile-ic"><i class="bi bi-star"></i></span>
                    <div class="tile-tt">Review Approval</div>
                    <div class="tile-ds">Moderate and approve customer reviews before they go public.</div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
