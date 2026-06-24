<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cinema Management – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* ── Topbar ─────────────────────────────────────────── */
        .lc-topbar {
            display: flex; align-items: center; justify-content: space-between;
            padding: .75rem 1.75rem; background: #fff;
            border-bottom: 1px solid var(--lc-border);
            position: sticky; top: 0; z-index: 100;
        }
        .lc-topbar-breadcrumb { font-size: .82rem; color: var(--lc-muted); }
        .lc-topbar-breadcrumb a { color: var(--lc-muted); text-decoration: none; }
        .lc-topbar-breadcrumb a:hover { color: var(--lc-primary); }
        .lc-topbar-title { font-size: 1.45rem; font-weight: 800; color: #0f1e36; margin-top: 1px; }
        .lc-admin-badge {
            background: #FEE2E2; color: #B91C1C;
            font-size: .68rem; font-weight: 700; letter-spacing: .06em;
            padding: .28rem .7rem; border-radius: 6px; border: 1px solid #FECACA;
        }
        .lc-avatar-circle {
            width: 36px; height: 36px; border-radius: 999px;
            background: var(--lc-primary); color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: .9rem; flex-shrink: 0;
        }

        /* ── KPI cards ──────────────────────────────────────── */
        .lc-kpi-card {
            background: #fff; border: 1px solid var(--lc-border);
            border-radius: 14px; padding: 1.1rem 1.25rem;
            box-shadow: var(--lc-shadow);
            display: flex; align-items: flex-start; gap: 1rem;
        }
        .lc-kpi-icon {
            width: 42px; height: 42px; border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.25rem; flex-shrink: 0;
        }
        .lc-kpi-label { font-size: .75rem; color: var(--lc-muted); font-weight: 600;
                        text-transform: uppercase; letter-spacing: .05em; }
        .lc-kpi-value { font-size: 1.9rem; font-weight: 800; color: #0f1e36; line-height: 1.1; }

        /* ── Toolbar (search / filter / add) ────────────────── */
        .lc-toolbar {
            display: flex; align-items: center; gap: .75rem; flex-wrap: wrap;
            margin-bottom: 1.25rem;
        }
        .lc-search-wrap { position: relative; flex: 1; min-width: 200px; max-width: 320px; }
        .lc-search-wrap .bi-search {
            position: absolute; left: .8rem; top: 50%; transform: translateY(-50%);
            color: var(--lc-muted); font-size: .9rem; pointer-events: none;
        }
        .lc-search-input {
            padding-left: 2.2rem; border: 1px solid var(--lc-border);
            border-radius: 9px; background: #fff; height: 38px;
            font-size: .88rem; width: 100%;
        }
        .lc-search-input:focus { outline: none; border-color: var(--lc-primary); box-shadow: 0 0 0 3px rgba(37,99,235,.1); }
        .lc-filter-select {
            height: 38px; border: 1px solid var(--lc-border); border-radius: 9px;
            background: #fff; padding: 0 .8rem; font-size: .88rem; color: #0f1e36;
        }
        .lc-filter-select:focus { outline: none; border-color: var(--lc-primary); }
        .lc-btn-add {
            margin-left: auto; height: 38px; padding: 0 1.1rem;
            background: var(--lc-primary); color: #fff; border: none;
            border-radius: 9px; font-size: .88rem; font-weight: 600;
            display: flex; align-items: center; gap: .4rem; white-space: nowrap;
            cursor: pointer; transition: background .12s;
        }
        .lc-btn-add:hover { background: var(--lc-primary-700); }

        /* ── Cinema cards ───────────────────────────────────── */
        .lc-cinema-card {
            background: #fff; border: 1px solid var(--lc-border);
            border-radius: 16px; overflow: hidden;
            box-shadow: var(--lc-shadow);
            display: flex; flex-direction: column;
            transition: box-shadow .15s;
        }
        .lc-cinema-card:hover { box-shadow: 0 8px 24px rgba(15,23,42,.1); }
        .lc-cinema-banner {
            height: 96px; position: relative; overflow: hidden;
            display: flex; align-items: center; justify-content: center;
        }
        /* graph-paper grid overlay (like mockup) */
        .lc-cinema-banner::before {
            content: ""; position: absolute; inset: 0;
            background-image:
                linear-gradient(rgba(15,23,42,.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(15,23,42,.07) 1px, transparent 1px);
            background-size: 22px 22px;
            -webkit-mask-image: linear-gradient(to bottom, rgba(0,0,0,.9), rgba(0,0,0,.25));
            mask-image: linear-gradient(to bottom, rgba(0,0,0,.9), rgba(0,0,0,.25));
            pointer-events: none;
        }
        .lc-cinema-banner-pin {
            position: relative; z-index: 1;
            width: 40px; height: 40px; border-radius: 999px;
            background: rgba(255,255,255,.95);
            display: flex; align-items: center; justify-content: center;
            color: var(--lc-primary); font-size: 1.2rem;
            box-shadow: 0 3px 10px rgba(0,0,0,.15);
        }
        .lc-cinema-status {
            position: absolute; top: 10px; right: 10px; z-index: 1;
            font-size: .68rem; font-weight: 700;
            padding: .24rem .7rem; border-radius: 999px;
            display: flex; align-items: center; gap: .3rem;
        }
        .lc-cinema-body {
            padding: 1rem 1.2rem 1.2rem;
            flex: 1; display: flex; flex-direction: column; gap: .7rem;
        }
        .lc-cinema-name { font-size: 1.05rem; font-weight: 800; color: #0f1e36; margin: 0; }
        .lc-cinema-addr { font-size: .78rem; color: var(--lc-muted); margin: 0; }
        .lc-cinema-meta { display: flex; justify-content: space-between; font-size: .78rem; color: var(--lc-muted); }
        .lc-cinema-hours { font-size: .78rem; color: var(--lc-muted); }
        .lc-cinema-actions { display: flex; gap: .6rem; margin-top: auto; }
        .lc-btn-outline {
            flex: 1; padding: .5rem; border-radius: 8px; font-size: .82rem; font-weight: 600;
            border: 1px solid var(--lc-border); background: #fff; color: #0f1e36;
            text-align: center; cursor: pointer;
            transition: background .12s, border-color .12s;
        }
        .lc-btn-outline:hover { background: var(--lc-light); border-color: var(--lc-primary); color: var(--lc-primary); }
        .lc-btn-fill {
            flex: 1.6; padding: .5rem; border-radius: 8px; font-size: .82rem; font-weight: 600;
            background: var(--lc-primary); color: #fff; border: none;
            text-align: center; text-decoration: none; cursor: pointer;
            transition: background .12s;
        }
        .lc-btn-fill:hover { background: var(--lc-primary-700); color: #fff; }

        /* banner colour variants */
        .banner-blue  { background: linear-gradient(135deg,#EFF6FF,#DBEAFE); }
        .banner-green { background: linear-gradient(135deg,#F0FDF4,#DCFCE7); }
        .banner-purple{ background: linear-gradient(135deg,#F5F3FF,#EDE9FE); }
        .banner-gray  { background: linear-gradient(135deg,#F8FAFC,#F1F5F9); }

        /* status pills */
        .status-active   { background:#D1FAE5; color:#065F46; }
        .status-inactive { background:#F1F5F9; color:#475569; }

        /* ── Alert toast strip ──────────────────────────────── */
        .lc-alert {
            border-radius: 10px; font-size: .88rem; padding: .7rem 1rem;
            display: flex; align-items: center; gap: .6rem;
            border: none; margin-bottom: 1.25rem;
        }
        .lc-alert-success { background: #D1FAE5; color: #065F46; }
        .lc-alert-danger  { background: #FEE2E2; color: #991B1B; }

        /* ── Modal overrides ────────────────────────────────── */
        .modal-content { border: none; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,.15); }
        .modal-header { border-bottom: 1px solid var(--lc-border); padding: 1.1rem 1.4rem; }
        .modal-footer { border-top: 1px solid var(--lc-border); padding: .9rem 1.4rem; }
        .modal-title  { font-weight: 700; font-size: 1rem; color: #0f1e36; }
        .lc-form-label { font-size: .8rem; font-weight: 600; color: #374151; margin-bottom: .3rem; }
        .lc-form-control {
            border: 1px solid var(--lc-border); border-radius: 8px;
            padding: .5rem .75rem; font-size: .88rem; width: 100%;
        }
        .lc-form-control:focus { outline: none; border-color: var(--lc-primary); box-shadow: 0 0 0 3px rgba(37,99,235,.1); }
        .lc-form-row { display: grid; grid-template-columns: 1fr 1fr; gap: .75rem; }
        .lc-modal-btn {
            padding: .5rem 1.2rem; border-radius: 8px; font-size: .88rem;
            font-weight: 600; cursor: pointer; border: none;
        }
        .lc-modal-btn-cancel { background: var(--lc-light); color: #374151; border: 1px solid var(--lc-border); }
        .lc-modal-btn-save   { background: var(--lc-primary); color: #fff; }
        .lc-modal-btn-save:hover { background: var(--lc-primary-700); }
        .lc-modal-btn-danger { background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; }
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">

    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <div class="text-muted small mb-1">Admin / <span class="fw-semibold">Cinemas</span></div>
        <h4 class="fw-bold text-navy mb-1">Cinema Management</h4>
        <div class="text-muted small mb-4">Manage cinemas, their rooms and operating hours across the network.</div>

        <%-- ── Alerts ─────────────────────────────────────────── --%>
        <c:if test="${not empty successMsg}">
            <div class="lc-alert lc-alert-success alert-dismissible" role="alert">
                <i class="bi bi-check-circle-fill"></i>
                <span>${successMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="lc-alert lc-alert-danger alert-dismissible" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i>
                <span>${errorMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>

        <%-- ── KPI Cards ──────────────────────────────────────── --%>
        <c:set var="totalCount"    value="${branches.size()}"/>
        <c:set var="activeCount"   value="0"/>
        <c:forEach items="${branches}" var="b">
            <c:if test="${b.active}"><c:set var="activeCount" value="${activeCount + 1}"/></c:if>
        </c:forEach>

        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card">
                    <div class="lc-kpi-icon" style="background:#EFF6FF;color:#2563EB;">
                        <i class="bi bi-building-fill"></i>
                    </div>
                    <div>
                        <div class="lc-kpi-label">Total Cinemas</div>
                        <div class="lc-kpi-value">${totalCount}</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card">
                    <div class="lc-kpi-icon" style="background:#F0FDF4;color:#16A34A;">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <div>
                        <div class="lc-kpi-label">Active</div>
                        <div class="lc-kpi-value">${activeCount}</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card">
                    <div class="lc-kpi-icon" style="background:#FFF7ED;color:#EA580C;">
                        <i class="bi bi-x-circle-fill"></i>
                    </div>
                    <div>
                        <div class="lc-kpi-label">Inactive</div>
                        <div class="lc-kpi-value">${totalCount - activeCount}</div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card">
                    <div class="lc-kpi-icon" style="background:#F5F3FF;color:#7C3AED;">
                        <i class="bi bi-clock-fill"></i>
                    </div>
                    <div>
                        <div class="lc-kpi-label">Avg. Hours</div>
                        <div class="lc-kpi-value" style="font-size:1.3rem;">08:00–23:00</div>
                    </div>
                </div>
            </div>
        </div>

        <%-- ── Toolbar ────────────────────────────────────────── --%>
        <div class="lc-toolbar">
            <div class="lc-search-wrap">
                <i class="bi bi-search"></i>
                <input type="text" id="searchInput" class="lc-search-input" placeholder="Search cinemas...">
            </div>
            <select id="cityFilter" class="lc-filter-select">
                <option value="">All Cities</option>
                <c:set var="cities" value=""/>
                <c:forEach items="${branches}" var="b">
                    <c:if test="${not empty b.city and not cities.contains(b.city)}">
                        <option value="${b.city}">${b.city}</option>
                        <c:set var="cities" value="${cities},${b.city}"/>
                    </c:if>
                </c:forEach>
            </select>
            <select id="statusFilter" class="lc-filter-select">
                <option value="">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
            </select>
            <button class="btn btn-primary btn-sm ms-auto text-nowrap" data-bs-toggle="modal" data-bs-target="#addModal">
                <i class="bi bi-plus-lg me-1"></i>Add Cinema
            </button>
        </div>

        <%-- ── Cinema Card Grid ──────────────────────────────── --%>
        <div class="row g-3" id="cardGrid">

            <c:set var="bannerClasses" value="banner-blue,banner-green,banner-purple,banner-gray"/>
            <c:forEach items="${branches}" var="b" varStatus="loop">
                <c:set var="bannerIdx" value="${loop.index % 4}"/>
                <c:choose>
                    <c:when test="${bannerIdx == 0}"><c:set var="bannerCls" value="banner-blue"/></c:when>
                    <c:when test="${bannerIdx == 1}"><c:set var="bannerCls" value="banner-green"/></c:when>
                    <c:when test="${bannerIdx == 2}"><c:set var="bannerCls" value="banner-purple"/></c:when>
                    <c:otherwise><c:set var="bannerCls" value="banner-gray"/></c:otherwise>
                </c:choose>
                <c:if test="${not b.active}"><c:set var="bannerCls" value="banner-gray"/></c:if>

                <div class="col-md-6 cinema-card-col"
                     data-name="${b.name}"
                     data-city="${b.city}"
                     data-status="${b.active ? 'active' : 'inactive'}">
                    <div class="lc-cinema-card h-100">

                        <%-- Banner --%>
                        <div class="lc-cinema-banner ${bannerCls}">
                            <div class="lc-cinema-banner-pin">
                                <i class="bi bi-geo-alt-fill"></i>
                            </div>
                            <c:choose>
                                <c:when test="${b.active}">
                                    <span class="lc-cinema-status status-active">
                                        <i class="bi bi-circle-fill" style="font-size:.4rem;"></i> Active
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="lc-cinema-status status-inactive">
                                        <i class="bi bi-circle" style="font-size:.4rem;"></i> Inactive
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Body --%>
                        <div class="lc-cinema-body">
                            <div>
                                <p class="lc-cinema-name">${b.name}</p>
                                <p class="lc-cinema-addr">
                                    <i class="bi bi-geo-alt me-1"></i>${b.address}<c:if test="${not empty b.city}">, ${b.city}</c:if>
                                </p>
                            </div>

                            <div class="lc-cinema-meta">
                                <span>
                                    <i class="bi bi-telephone me-1"></i>
                                    <c:choose>
                                        <c:when test="${not empty b.phone}">${b.phone}</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </span>
                                <span>
                                    <i class="bi bi-envelope me-1"></i>
                                    <c:choose>
                                        <c:when test="${not empty b.email}">${b.email}</c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>

                            <div class="lc-cinema-hours">
                                <i class="bi bi-clock me-1"></i>
                                <c:choose>
                                    <c:when test="${b.openingTime != null}">
                                        ${b.openingTime} – ${b.closingTime}
                                    </c:when>
                                    <c:otherwise>Hours not set</c:otherwise>
                                </c:choose>
                            </div>

                            <div class="lc-cinema-actions">
                                <%-- Edit Details button --%>
                                <button type="button" class="lc-btn-outline edit-btn"
                                        data-id="${b.branchId}"
                                        data-name="${b.name}"
                                        data-address="${b.address}"
                                        data-city="${b.city}"
                                        data-phone="${b.phone}"
                                        data-email="${b.email}"
                                        data-open="<c:choose><c:when test="${b.openingTime != null}">${fn:substring(b.openingTime, 0, 5)}</c:when><c:otherwise>08:00</c:otherwise></c:choose>"
                                        data-close="<c:choose><c:when test="${b.closingTime != null}">${fn:substring(b.closingTime, 0, 5)}</c:when><c:otherwise>23:00</c:otherwise></c:choose>"
                                        data-active="${b.active}"
                                        data-bs-toggle="modal"
                                        data-bs-target="#editModal">
                                    <i class="bi bi-pencil me-1"></i> Edit Details
                                </button>
                                <%-- Manage Rooms button --%>
                                <a href="${pageContext.request.contextPath}/admin/halls?branchId=${b.branchId}"
                                   class="lc-btn-fill">
                                    <i class="bi bi-grid me-1"></i> Manage Rooms
                                </a>
                            </div>
                        </div>

                    </div>
                </div>
            </c:forEach>

            <%-- Empty state --%>
            <c:if test="${empty branches}">
                <div class="col-12">
                    <div class="text-center py-5" style="color:var(--lc-muted);">
                        <i class="bi bi-building" style="font-size:2.5rem;display:block;margin-bottom:.75rem;"></i>
                        No cinemas found.
                        <button class="btn btn-link p-0" data-bs-toggle="modal" data-bs-target="#addModal">Add one</button>.
                    </div>
                </div>
            </c:if>

        </div><%-- /cardGrid --%>

        <%-- No-results message (hidden by default) --%>
        <div id="noResults" class="text-center py-5 d-none" style="color:var(--lc-muted);">
            <i class="bi bi-search" style="font-size:2rem;display:block;margin-bottom:.5rem;"></i>
            No cinemas match your search.
        </div>

    </div><%-- /container --%>
</main>

<%-- ═══════════════════════════════════════════════════════════
     MODAL: ADD CINEMA
════════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/branches">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="add">

                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-building-add me-2 text-primary"></i>Add New Cinema</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body px-4 py-3 d-flex flex-column gap-3">
                    <div>
                        <label class="lc-form-label">Cinema Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" class="lc-form-control" placeholder="e.g. Cinema Alpha" required>
                    </div>
                    <div>
                        <label class="lc-form-label">Address <span class="text-danger">*</span></label>
                        <input type="text" name="address" class="lc-form-control" placeholder="Street address" required>
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">City <span class="text-danger">*</span></label>
                            <input type="text" name="city" class="lc-form-control" placeholder="e.g. HCMC" required>
                        </div>
                        <div>
                            <label class="lc-form-label">Phone</label>
                            <input type="text" name="phone" class="lc-form-control" placeholder="028 xxxx xxxx">
                        </div>
                    </div>
                    <div>
                        <label class="lc-form-label">Email</label>
                        <input type="email" name="email" class="lc-form-control" placeholder="branch@example.com">
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">Opening Time</label>
                            <input type="time" name="openingTime" class="lc-form-control" value="08:00">
                        </div>
                        <div>
                            <label class="lc-form-label">Closing Time</label>
                            <input type="time" name="closingTime" class="lc-form-control" value="23:00">
                        </div>
                    </div>
                </div>

                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save">
                        <i class="bi bi-plus-lg me-1"></i> Add Cinema
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ═══════════════════════════════════════════════════════════
     MODAL: EDIT CINEMA
════════════════════════════════════════════════════════════ --%>
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/branches">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="branchId" id="editId">

                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-pencil-square me-2 text-primary"></i>Edit Cinema</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body px-4 py-3 d-flex flex-column gap-3">
                    <div>
                        <label class="lc-form-label">Cinema Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" id="editName" class="lc-form-control" required>
                    </div>
                    <div>
                        <label class="lc-form-label">Address <span class="text-danger">*</span></label>
                        <input type="text" name="address" id="editAddress" class="lc-form-control" required>
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">City <span class="text-danger">*</span></label>
                            <input type="text" name="city" id="editCity" class="lc-form-control" required>
                        </div>
                        <div>
                            <label class="lc-form-label">Phone</label>
                            <input type="text" name="phone" id="editPhone" class="lc-form-control">
                        </div>
                    </div>
                    <div>
                        <label class="lc-form-label">Email</label>
                        <input type="email" name="email" id="editEmail" class="lc-form-control">
                    </div>
                    <div class="lc-form-row">
                        <div>
                            <label class="lc-form-label">Opening Time</label>
                            <input type="time" name="openingTime" id="editOpen" class="lc-form-control">
                        </div>
                        <div>
                            <label class="lc-form-label">Closing Time</label>
                            <input type="time" name="closingTime" id="editClose" class="lc-form-control">
                        </div>
                    </div>

                    <%-- Active status (submitted with Save) --%>
                    <input type="hidden" name="active" id="editActiveHidden" value="false">
                    <div class="d-flex align-items-center justify-content-between p-3"
                         style="background:var(--lc-light);border-radius:10px;border:1px solid var(--lc-border);">
                        <div>
                            <div style="font-size:.85rem;font-weight:600;color:#0f1e36;">Cinema Status</div>
                            <div style="font-size:.75rem;color:var(--lc-muted);">Inactive cinemas are hidden from customer booking</div>
                        </div>
                        <div class="form-check form-switch mb-0">
                            <input class="form-check-input" type="checkbox" role="switch"
                                   id="editActiveToggle" style="width:2.5rem;height:1.3rem;">
                        </div>
                    </div>
                </div>

                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save" id="editSaveBtn">
                        <i class="bi bi-check-lg me-1"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<form id="toggleForm" method="post" action="${pageContext.request.contextPath}/admin/branches" class="d-none">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
    <input type="hidden" name="action" value="toggleStatus">
    <input type="hidden" name="branchId" id="toggleBranchId">
    <input type="hidden" name="active" id="toggleActive">
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* ── Edit modal: populate fields ──────────────────────── */
    document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.getElementById('editId').value      = this.dataset.id;
            document.getElementById('editName').value    = this.dataset.name;
            document.getElementById('editAddress').value = this.dataset.address;
            document.getElementById('editCity').value    = this.dataset.city;
            document.getElementById('editPhone').value   = this.dataset.phone || '';
            document.getElementById('editEmail').value   = this.dataset.email || '';
            document.getElementById('editOpen').value    = this.dataset.open  || '08:00';
            document.getElementById('editClose').value   = this.dataset.close || '23:00';

            const isActive = this.dataset.active === 'true';
            const toggle   = document.getElementById('editActiveToggle');
            const hidden   = document.getElementById('editActiveHidden');
            toggle.checked = isActive;
            hidden.value = isActive ? 'true' : 'false';
            toggle.onchange = function () {
                hidden.value = this.checked ? 'true' : 'false';
            };
        });
    });

    document.getElementById('editSaveBtn').closest('form').addEventListener('submit', function () {
        const toggle = document.getElementById('editActiveToggle');
        document.getElementById('editActiveHidden').value = toggle.checked ? 'true' : 'false';
    });

    /* ── Client-side search + filter ─────────────────────── */
    function filterCards() {
        const q      = document.getElementById('searchInput').value.toLowerCase();
        const city   = document.getElementById('cityFilter').value.toLowerCase();
        const status = document.getElementById('statusFilter').value;
        const cols   = document.querySelectorAll('.cinema-card-col');
        let   shown  = 0;

        cols.forEach(col => {
            const name   = (col.dataset.name   || '').toLowerCase();
            const cCity  = (col.dataset.city   || '').toLowerCase();
            const cStat  = (col.dataset.status || '');

            const matchQ      = !q      || name.includes(q) || cCity.includes(q);
            const matchCity   = !city   || cCity === city;
            const matchStatus = !status || cStat === status;

            const show = matchQ && matchCity && matchStatus;
            col.classList.toggle('d-none', !show);
            if (show) shown++;
        });

        document.getElementById('noResults').classList.toggle('d-none', shown > 0);
    }

    document.getElementById('searchInput').addEventListener('input',  filterCards);
    document.getElementById('cityFilter').addEventListener('change',  filterCards);
    document.getElementById('statusFilter').addEventListener('change', filterCards);
</script>
</body>
</html>
