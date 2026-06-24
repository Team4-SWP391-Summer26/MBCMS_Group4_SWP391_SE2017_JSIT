<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Admin dashboard - fresh design: hero + payment-style KPI + cinema cards + quick actions. --%>
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
            border-radius: 16px; color: #fff; padding: 1.6rem 1.8rem;
            display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;
            box-shadow: var(--lc-shadow); margin-bottom: 1.25rem;
        }
        .dash-hero h3 { color: #fff; margin: 0; font-weight: 800; }
        .dash-hero .sub { color: rgba(255,255,255,.75); font-size: .9rem; margin-top: .25rem; }
        .dash-hero .badge-soft { background: rgba(255,255,255,.14); border: 1px solid rgba(255,255,255,.22);
            color: #fff; font-size: .72rem; font-weight: 700; letter-spacing: .04em; padding: .35rem .8rem; border-radius: 999px; }
        .cin-card { background:#fff; border:1px solid var(--lc-border); border-radius:14px; box-shadow:var(--lc-shadow);
            padding:1rem 1.1rem; display:flex; align-items:center; gap:.9rem; transition:box-shadow .15s, transform .15s; height:100%; }
        .cin-card:hover { box-shadow:0 8px 24px rgba(15,23,42,.1); transform:translateY(-2px); }
        .cin-pin { width:44px; height:44px; border-radius:12px; flex-shrink:0; display:flex; align-items:center; justify-content:center;
            background:var(--lc-light); color:var(--lc-primary); font-size:1.3rem; }
        .qa-row { display:flex; align-items:center; gap:.8rem; padding:.85rem .9rem; border:1px solid var(--lc-border);
            border-radius:11px; text-decoration:none; color:var(--lc-navy); font-weight:600; transition:all .12s ease; margin-bottom:.6rem; }
        .qa-row:hover { border-color:var(--lc-primary); background:var(--lc-light); transform:translateX(2px); }
        .qa-ic { width:38px; height:38px; border-radius:10px; display:flex; align-items:center; justify-content:center;
            background:var(--lc-light); color:var(--lc-primary); font-size:1.1rem; flex-shrink:0; }
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

        <%-- KPI (payment-style accent cards) --%>
        <div class="row g-3 mb-4">
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

        <div class="row g-3">
            <%-- Cinemas --%>
            <div class="col-lg-8">
                <div class="d-flex justify-content-between align-items-center mb-2">
                    <h6 class="text-navy fw-bold mb-0">Cinemas across the network</h6>
                    <a href="${pageContext.request.contextPath}/admin/branches" class="btn btn-light border btn-sm">
                        Manage all <i class="bi bi-arrow-right ms-1"></i></a>
                </div>
                <div class="row g-3">
                    <c:forEach items="${branches}" var="b">
                        <div class="col-md-6">
                            <div class="cin-card">
                                <div class="cin-pin"><i class="bi bi-geo-alt-fill"></i></div>
                                <div class="flex-grow-1" style="min-width:0;">
                                    <div class="d-flex justify-content-between align-items-start gap-2">
                                        <div class="fw-bold text-navy text-truncate"><c:out value="${b.name}"/></div>
                                        <c:choose>
                                            <c:when test="${b.active}"><span class="pay-st s-success"><span class="dot"></span>Active</span></c:when>
                                            <c:otherwise><span class="pay-st s-off"><span class="dot"></span>Inactive</span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="text-muted small text-truncate"><i class="bi bi-pin-map me-1"></i><c:out value="${b.city}"/></div>
                                    <div class="text-muted small"><i class="bi bi-telephone me-1"></i><c:out value="${b.phone}"/></div>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty branches}">
                        <div class="col-12 text-center text-muted py-4">No cinemas yet.</div>
                    </c:if>
                </div>
            </div>

            <%-- Quick actions --%>
            <div class="col-lg-4">
                <h6 class="text-navy fw-bold mb-2">Quick actions</h6>
                <div class="card lc-elev p-3">
                    <a href="${pageContext.request.contextPath}/admin/branches" class="qa-row">
                        <span class="qa-ic"><i class="bi bi-building"></i></span>Manage Cinemas
                        <i class="bi bi-chevron-right ms-auto text-muted"></i></a>
                    <a href="${pageContext.request.contextPath}/admin/users" class="qa-row">
                        <span class="qa-ic"><i class="bi bi-people"></i></span>Manage Users
                        <i class="bi bi-chevron-right ms-auto text-muted"></i></a>
                    <a href="${pageContext.request.contextPath}/admin/movie-branches" class="qa-row">
                        <span class="qa-ic"><i class="bi bi-film"></i></span>Movie Assignment
                        <i class="bi bi-chevron-right ms-auto text-muted"></i></a>
                    <a href="${pageContext.request.contextPath}/admin/payments" class="qa-row mb-0">
                        <span class="qa-ic"><i class="bi bi-credit-card"></i></span>Payments
                        <i class="bi bi-chevron-right ms-auto text-muted"></i></a>
                </div>
            </div>
        </div>
    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
