<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Admin dashboard - hero + payment-style KPI + uniform navigation tile grid. --%>
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
        .dash-hero {
            background: linear-gradient(120deg, #0F2247 0%, #1e3a5f 60%, #2563EB 130%);
            border-radius: 16px; color: #fff; padding: 1.7rem 1.9rem;
            display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;
            box-shadow: var(--lc-shadow); margin-bottom: 1.5rem;
        }
        .dash-hero h3 { color: #fff; margin: 0; font-weight: 800; }
        .dash-hero .sub { color: rgba(255,255,255,.75); font-size: .9rem; margin-top: .3rem; }
        .dash-hero .badge-soft { background: rgba(255,255,255,.14); border: 1px solid rgba(255,255,255,.22);
            color: #fff; font-size: .72rem; font-weight: 700; letter-spacing: .04em; padding: .4rem .85rem; border-radius: 999px; }

        .sec-title { font-size: .8rem; font-weight: 700; text-transform: uppercase; letter-spacing: .08em;
            color: var(--lc-muted); margin: 1.75rem 0 .9rem; }

        /* Navigation tiles - uniform grid */
        .nav-tile {
            position: relative; display: flex; flex-direction: column; gap: .75rem;
            background: #fff; border: 1px solid var(--lc-border); border-radius: 14px;
            box-shadow: var(--lc-shadow); padding: 1.25rem 1.3rem; height: 100%;
            text-decoration: none; color: inherit; transition: box-shadow .15s ease, transform .15s ease, border-color .15s ease;
        }
        .nav-tile.is-live:hover { transform: translateY(-3px); box-shadow: 0 12px 28px rgba(15,23,42,.12); border-color: #cdd9ee; }
        .nav-tile .ic { width: 48px; height: 48px; border-radius: 13px; display: flex; align-items: center;
            justify-content: center; font-size: 1.45rem; }
        .nav-tile .tt { font-family: 'Sora','Inter',sans-serif; font-weight: 700; color: var(--lc-navy); font-size: 1.05rem; letter-spacing: -.01em; }
        .nav-tile .ds { font-size: .82rem; color: var(--lc-muted); line-height: 1.4; }
        .nav-tile .go { font-size: .8rem; font-weight: 600; color: var(--lc-primary); display: inline-flex; align-items: center; gap: .35rem; margin-top: auto; }
        .nav-tile.is-soon { opacity: .72; }
        .nav-tile.is-soon .ic { filter: grayscale(.35); }
        .nav-tile .soon-tag { position: absolute; top: 1rem; right: 1rem; font-size: .64rem; font-weight: 700;
            text-transform: uppercase; letter-spacing: .05em; background: #EEF1F4; color: #64748b; padding: .2rem .55rem; border-radius: 999px; }
        .ic-blue   { background: #e7efff; color: #2563eb; }
        .ic-purple { background: #ece3f8; color: #6d28d9; }
        .ic-amber  { background: #fff4d6; color: #b8770a; }
        .ic-green  { background: #e7f6ee; color: #15803d; }
        .ic-slate  { background: #eef1f4; color: #475569; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="dashboard"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <%-- HERO --%>
        <div class="dash-hero">
            <div>
                <h3>Welcome back, System Admin</h3>
                <div class="sub">Here's how the MBCMS network looks across all cinemas today.</div>
            </div>
            <span class="badge-soft"><i class="bi bi-shield-lock-fill me-1"></i>SYSTEM-WIDE ACCESS</span>
        </div>

        <%-- KPI --%>
        <div class="row g-3">
            <div class="col-md-3 col-6">
                <div class="pay-kpi k-blue">
                    <div class="row1"><span class="ic" style="background:#e7efff;color:#2563eb;"><i class="bi bi-building"></i></span>
                        <span class="lbl">Total Cinemas</span></div>
                    <div class="val">${totalBranches}</div>
                    <div class="sub">Branches in the network</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="pay-kpi k-green">
                    <div class="row1"><span class="ic" style="background:#e7f6ee;color:#15803d;"><i class="bi bi-check-circle"></i></span>
                        <span class="lbl">Active Cinemas</span></div>
                    <div class="val">${activeBranches}</div>
                    <div class="sub">Currently operating</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="pay-kpi k-blue">
                    <div class="row1"><span class="ic" style="background:#ece3f8;color:#6d28d9;"><i class="bi bi-door-open"></i></span>
                        <span class="lbl">Total Rooms</span></div>
                    <div class="val">${totalRooms}</div>
                    <div class="sub">Across all cinemas</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="pay-kpi k-amber">
                    <div class="row1"><span class="ic" style="background:#fff4d6;color:#b8770a;"><i class="bi bi-grid-3x3-gap"></i></span>
                        <span class="lbl">Total Seats</span></div>
                    <div class="val">${totalSeats}</div>
                    <div class="sub">Installed capacity</div>
                </div>
            </div>
        </div>

        <%-- NAVIGATION TILES --%>
        <div class="sec-title">Manage the system</div>
        <div class="row g-3">
            <div class="col-md-6 col-xl-4">
                <a class="nav-tile is-live" href="${pageContext.request.contextPath}/admin/branches">
                    <span class="ic ic-blue"><i class="bi bi-building"></i></span>
                    <div class="tt">Cinemas</div>
                    <div class="ds">Add, edit and configure cinemas, their rooms and seat layouts.</div>
                    <span class="go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="nav-tile is-live" href="${pageContext.request.contextPath}/admin/users">
                    <span class="ic ic-purple"><i class="bi bi-people"></i></span>
                    <div class="tt">Users</div>
                    <div class="ds">Manage customers, branch managers, staff and administrators.</div>
                    <span class="go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="nav-tile is-live" href="${pageContext.request.contextPath}/admin/movie-branches">
                    <span class="ic ic-amber"><i class="bi bi-film"></i></span>
                    <div class="tt">Movie Assignment</div>
                    <div class="ds">Assign movies to the cinemas that are allowed to schedule them.</div>
                    <span class="go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <a class="nav-tile is-live" href="${pageContext.request.contextPath}/admin/payments">
                    <span class="ic ic-green"><i class="bi bi-credit-card"></i></span>
                    <div class="tt">Payments</div>
                    <div class="ds">Review payment history and monitor transaction status network-wide.</div>
                    <span class="go">Open <i class="bi bi-arrow-right"></i></span>
                </a>
            </div>
            <div class="col-md-6 col-xl-4">
                <div class="nav-tile is-soon">
                    <span class="soon-tag">Soon</span>
                    <span class="ic ic-slate"><i class="bi bi-bar-chart"></i></span>
                    <div class="tt">System Reports</div>
                    <div class="ds">Revenue, occupancy and performance analytics across the network.</div>
                </div>
            </div>
            <div class="col-md-6 col-xl-4">
                <div class="nav-tile is-soon">
                    <span class="soon-tag">Soon</span>
                    <span class="ic ic-slate"><i class="bi bi-star"></i></span>
                    <div class="tt">Review Approval</div>
                    <div class="ds">Moderate and approve customer reviews before they go public.</div>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
