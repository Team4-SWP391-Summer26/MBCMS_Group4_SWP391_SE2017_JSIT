<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Movie Management – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .lc-kpi-card { background:#fff; border:1px solid var(--lc-border); border-radius:14px;
            padding:1.1rem 1.25rem; box-shadow:var(--lc-shadow); display:flex; align-items:flex-start; gap:1rem; }
        .lc-kpi-icon { width:42px; height:42px; border-radius:10px; display:flex; align-items:center;
            justify-content:center; font-size:1.25rem; flex-shrink:0; }
        .lc-kpi-label { font-size:.75rem; color:var(--lc-muted); font-weight:600; text-transform:uppercase; letter-spacing:.05em; }
        .lc-kpi-value { font-size:1.9rem; font-weight:800; color:var(--navy); line-height:1.1; }

        .lc-toolbar { display:flex; align-items:center; gap:.75rem; flex-wrap:wrap; margin-bottom:1.25rem; }
        .lc-search-wrap { position:relative; flex:1; min-width:200px; max-width:340px; }
        .lc-search-wrap .bi-search { position:absolute; left:.8rem; top:50%; transform:translateY(-50%);
            color:var(--lc-muted); font-size:.9rem; pointer-events:none; }
        .lc-search-input { padding-left:2.2rem; border:1px solid var(--lc-border); border-radius:9px;
            background:#fff; height:38px; font-size:.88rem; width:100%; }
        .lc-search-input:focus { outline:none; border-color:var(--lc-primary); box-shadow:0 0 0 3px rgba(37,99,235,.1); }
        .lc-filter-select { height:38px; border:1px solid var(--lc-border); border-radius:9px;
            background:#fff; padding:0 .8rem; font-size:.88rem; color:var(--navy); }
        .lc-filter-select:focus { outline:none; border-color:var(--lc-primary); }

        .lc-alert { border-radius:10px; font-size:.88rem; padding:.7rem 1rem; display:flex;
            align-items:center; gap:.6rem; border:none; margin-bottom:1.25rem; }
        .lc-alert-success { background:#D1FAE5; color:#065F46; }
        .lc-alert-danger  { background:#FEE2E2; color:#991B1B; }

        /* ── Movie cards ─────────────────────────────────── */
        .mv-card { background:#fff; border:1px solid var(--lc-border); border-radius:16px; overflow:hidden;
            box-shadow:var(--lc-shadow); display:flex; flex-direction:column; height:100%; transition:box-shadow .15s, transform .15s; }
        .mv-card:hover { box-shadow:0 10px 26px rgba(15,23,42,.10); transform:translateY(-2px); }
        .mv-card.is-inactive { opacity:.62; }

        .poster-art { position:relative; aspect-ratio:2/3; overflow:hidden; background:var(--lc-navy); }
        .poster-art img { width:100%; height:100%; object-fit:cover; }
        .poster-bg { position:absolute; inset:0; }
        .poster-rings { position:absolute; inset:0; width:100%; height:100%; }
        .poster-name { position:absolute; inset:0; display:flex; align-items:center; justify-content:center;
            text-align:center; padding:1rem; color:#fff; font-weight:800; letter-spacing:.04em;
            font-size:1rem; line-height:1.2; text-shadow:0 2px 8px rgba(0,0,0,.4); }
        .mv-status-badge { position:absolute; top:.6rem; left:.6rem; z-index:2; padding:.22rem .6rem;
            border-radius:999px; font-size:.66rem; font-weight:700; text-transform:uppercase; letter-spacing:.04em;
            display:inline-flex; align-items:center; gap:.3rem; color:#fff; }
        .st-NOW_SHOWING { background:rgba(22,163,74,.92); }
        .st-UPCOMING    { background:rgba(37,99,235,.92); }
        .st-ENDED       { background:rgba(100,116,139,.92); }
        .mv-hidden-tag { position:absolute; top:.6rem; right:.6rem; z-index:2; background:rgba(15,23,42,.78);
            color:#fff; font-size:.62rem; font-weight:700; padding:.2rem .5rem; border-radius:6px;
            text-transform:uppercase; letter-spacing:.04em; }

        .mv-body { padding:.9rem 1rem 1rem; display:flex; flex-direction:column; gap:.55rem; flex:1; }
        .mv-title-row { display:flex; justify-content:space-between; align-items:flex-start; gap:.4rem; }
        .mv-title { font-size:1rem; font-weight:700; color:var(--navy); margin:0; line-height:1.3; }
        .age-badge { font-size:.66rem; font-weight:700; padding:.12rem .4rem; border-radius:4px; color:#fff; flex-shrink:0; }
        .age-P { background:var(--lc-primary); } .age-C13 { background:#eab308; color:#1e293b; }
        .age-C16 { background:#f97316; } .age-C18 { background:#ef4444; }
        .mv-meta { font-size:.76rem; color:var(--lc-muted); display:flex; flex-wrap:wrap; gap:.1rem .8rem; }
        .mv-genres { display:flex; flex-wrap:wrap; gap:.25rem; }
        .genre-chip { font-size:.68rem; font-weight:500; background:var(--lc-light); color:var(--lc-primary);
            padding:.12rem .5rem; border-radius:999px; }

        .mv-status-form { margin-top:auto; }
        .mv-status-select { width:100%; height:34px; border:1px solid var(--lc-border); border-radius:8px;
            font-size:.8rem; padding:0 .5rem; color:var(--navy); background:#fff; }
        .mv-status-select:focus { outline:none; border-color:var(--lc-primary); }

        .mv-actions { display:flex; gap:.45rem; }
        .mv-btn { flex:1; padding:.45rem; border-radius:8px; font-size:.8rem; font-weight:600; text-align:center;
            cursor:pointer; border:1px solid var(--lc-border); background:#fff; color:var(--navy); text-decoration:none;
            display:inline-flex; align-items:center; justify-content:center; gap:.3rem; transition:.12s; }
        .mv-btn:hover { background:var(--lc-light); border-color:var(--lc-primary); color:var(--lc-primary); }
        .mv-btn-danger:hover { background:#FEE2E2; border-color:#FECACA; color:#991B1B; }
        .mv-toggle { display:flex; align-items:center; justify-content:space-between; font-size:.74rem;
            color:var(--lc-muted); padding-top:.15rem; }

        .modal-content { border:none; border-radius:16px; box-shadow:0 20px 60px rgba(0,0,0,.15); }
        .modal-title { font-weight:700; font-size:1rem; color:var(--navy); }
        .lc-modal-btn { padding:.5rem 1.2rem; border-radius:8px; font-size:.88rem; font-weight:600; cursor:pointer; border:none; }
        .lc-modal-btn-cancel { background:var(--lc-light); color:#374151; border:1px solid var(--lc-border); }
        .lc-modal-btn-danger { background:var(--danger); color:#fff; }
        .lc-modal-btn-danger:hover { background:#B91C1C; }
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="movies"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <div class="text-muted small mb-1">Admin / <span class="fw-semibold">Movies</span></div>
        <h4 class="fw-bold text-navy mb-1">Movie Management</h4>
        <div class="text-muted small mb-4">Add, edit and delete movies, upload posters/trailers and manage their status.</div>

        <c:if test="${not empty successMsg}">
            <div class="lc-alert lc-alert-success alert-dismissible" role="alert">
                <i class="bi bi-check-circle-fill"></i><span>${successMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="lc-alert lc-alert-danger alert-dismissible" role="alert">
                <i class="bi bi-exclamation-circle-fill"></i><span>${errorMsg}</span>
                <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert" style="font-size:.75rem;"></button>
            </div>
        </c:if>

        <%-- ── KPI ──────────────────────────────────────────── --%>
        <c:set var="nowShowing" value="0"/><c:set var="upcoming" value="0"/>
        <c:set var="ended" value="0"/><c:set var="hidden" value="0"/>
        <c:forEach items="${movies}" var="m">
            <c:if test="${m.status == 'NOW_SHOWING'}"><c:set var="nowShowing" value="${nowShowing + 1}"/></c:if>
            <c:if test="${m.status == 'UPCOMING'}"><c:set var="upcoming" value="${upcoming + 1}"/></c:if>
            <c:if test="${m.status == 'ENDED'}"><c:set var="ended" value="${ended + 1}"/></c:if>
            <c:if test="${not m.active}"><c:set var="hidden" value="${hidden + 1}"/></c:if>
        </c:forEach>

        <div class="row g-3 mb-4">
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card"><div class="lc-kpi-icon" style="background:var(--lc-light);color:var(--lc-primary);"><i class="bi bi-film"></i></div>
                    <div><div class="lc-kpi-label">Total Movies</div><div class="lc-kpi-value">${movies.size()}</div></div></div>
            </div>
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card"><div class="lc-kpi-icon" style="background:#F0FDF4;color:var(--success);"><i class="bi bi-play-circle-fill"></i></div>
                    <div><div class="lc-kpi-label">Now Showing</div><div class="lc-kpi-value">${nowShowing}</div></div></div>
            </div>
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card"><div class="lc-kpi-icon" style="background:var(--lc-light);color:var(--lc-primary);"><i class="bi bi-clock-fill"></i></div>
                    <div><div class="lc-kpi-label">Upcoming</div><div class="lc-kpi-value">${upcoming}</div></div></div>
            </div>
            <div class="col-6 col-md-3">
                <div class="lc-kpi-card"><div class="lc-kpi-icon" style="background:var(--lc-bg);color:var(--lc-muted);"><i class="bi bi-eye-slash-fill"></i></div>
                    <div><div class="lc-kpi-label">Hidden</div><div class="lc-kpi-value">${hidden}</div></div></div>
            </div>
        </div>

        <%-- ── Toolbar (server-side search/filter) ──────────── --%>
        <form class="lc-toolbar" method="get" action="${pageContext.request.contextPath}/admin/movies">
            <div class="lc-search-wrap">
                <i class="bi bi-search"></i>
                <input type="text" name="q" class="lc-search-input" placeholder="Search title, director, cast..."
                       value="${fn:escapeXml(q)}">
            </div>
            <select name="status" class="lc-filter-select" onchange="this.form.submit()">
                <option value="">All Status</option>
                <option value="NOW_SHOWING" ${statusFilter == 'NOW_SHOWING' ? 'selected' : ''}>Now Showing</option>
                <option value="UPCOMING" ${statusFilter == 'UPCOMING' ? 'selected' : ''}>Upcoming</option>
                <option value="ENDED" ${statusFilter == 'ENDED' ? 'selected' : ''}>Ended</option>
            </select>
            <button type="submit" class="btn btn-outline-secondary btn-sm">Search</button>
            <a href="${pageContext.request.contextPath}/admin/movies"
               class="btn btn-link btn-sm text-decoration-none ${empty q and empty statusFilter ? 'd-none' : ''}">Clear</a>
            <a href="${pageContext.request.contextPath}/admin/movies?action=add"
               class="btn btn-primary btn-sm ms-auto text-nowrap">
                <i class="bi bi-plus-lg me-1"></i>Add Movie
            </a>
        </form>

        <%-- ── Movie grid ───────────────────────────────────── --%>
        <div class="row g-3">
            <c:forEach items="${movies}" var="m">
                <div class="col-6 col-sm-4 col-md-3 col-xxl-2">
                    <div class="mv-card ${m.active ? '' : 'is-inactive'}">

                        <div class="poster-art">
                            <span class="mv-status-badge st-${m.status}">
                                <i class="bi bi-circle-fill" style="font-size:.36rem;"></i>
                                <c:choose>
                                    <c:when test="${m.status == 'NOW_SHOWING'}">Now Showing</c:when>
                                    <c:when test="${m.status == 'UPCOMING'}">Upcoming</c:when>
                                    <c:otherwise>Ended</c:otherwise>
                                </c:choose>
                            </span>
                            <c:if test="${not m.active}"><span class="mv-hidden-tag">Hidden</span></c:if>
                            <jsp:include page="/WEB-INF/views/common/_poster.jsp">
                                <jsp:param name="movieId" value="${m.movieId}"/>
                                <jsp:param name="title" value="${m.title}"/>
                                <jsp:param name="posterUrl" value="${m.posterUrl}"/>
                            </jsp:include>
                        </div>

                        <div class="mv-body">
                            <div class="mv-title-row">
                                <p class="mv-title">${fn:escapeXml(m.title)}</p>
                                <c:if test="${not empty m.rated}">
                                    <span class="age-badge age-${m.rated}">${m.rated}</span>
                                </c:if>
                            </div>

                            <div class="mv-meta">
                                <span><i class="bi bi-clock me-1"></i>${m.durationMin} min</span>
                                <c:if test="${not empty m.releaseDate}">
                                    <span><i class="bi bi-calendar3 me-1"></i>${m.releaseDate}</span>
                                </c:if>
                            </div>

                            <c:if test="${not empty m.genres}">
                                <div class="mv-genres">
                                    <c:forEach items="${m.genres}" var="g" varStatus="gs">
                                        <c:if test="${gs.index < 3}"><span class="genre-chip">${fn:escapeXml(g)}</span></c:if>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <%-- Manage movie status (inline) --%>
                            <form class="mv-status-form" method="post"
                                  action="${pageContext.request.contextPath}/admin/movies">
                                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <input type="hidden" name="action" value="changeStatus">
                                <input type="hidden" name="movieId" value="${m.movieId}">
                                <select name="status" class="mv-status-select" onchange="this.form.submit()" title="Change status">
                                    <option value="UPCOMING" ${m.status == 'UPCOMING' ? 'selected' : ''}>● Upcoming</option>
                                    <option value="NOW_SHOWING" ${m.status == 'NOW_SHOWING' ? 'selected' : ''}>● Now Showing</option>
                                    <option value="ENDED" ${m.status == 'ENDED' ? 'selected' : ''}>● Ended</option>
                                </select>
                            </form>

                            <div class="mv-actions">
                                <a href="${pageContext.request.contextPath}/admin/movies?action=edit&id=${m.movieId}"
                                   class="mv-btn"><i class="bi bi-pencil"></i> Edit</a>
                                <button type="button" class="mv-btn mv-btn-danger delete-btn"
                                        data-id="${m.movieId}" data-title="${fn:escapeXml(m.title)}"
                                        data-bs-toggle="modal" data-bs-target="#deleteModal">
                                    <i class="bi bi-trash"></i> Delete
                                </button>
                            </div>

                            <%-- Show / hide toggle (active) --%>
                            <form method="post" action="${pageContext.request.contextPath}/admin/movies" class="mv-toggle">
                                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <input type="hidden" name="action" value="toggleActive">
                                <input type="hidden" name="movieId" value="${m.movieId}">
                                <input type="hidden" name="active" value="${m.active ? 'false' : 'true'}">
                                <span><i class="bi ${m.active ? 'bi-eye' : 'bi-eye-slash'} me-1"></i>${m.active ? 'Visible to customers' : 'Hidden'}</span>
                                <button type="submit" class="btn btn-sm btn-link p-0 text-decoration-none" style="font-size:.74rem;">
                                    ${m.active ? 'Hide' : 'Show'}
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <c:if test="${empty movies}">
                <div class="col-12">
                    <div class="text-center py-5" style="color:var(--lc-muted);">
                        <i class="bi bi-film" style="font-size:2.5rem;display:block;margin-bottom:.75rem;"></i>
                        No movies found.
                        <a href="${pageContext.request.contextPath}/admin/movies?action=add" class="text-decoration-none">Add one</a>.
                    </div>
                </div>
            </c:if>
        </div>

    </div>
</main>

<%-- ── Delete confirm modal ─────────────────────────────── --%>
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/movies">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="movieId" id="delId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-exclamation-triangle-fill me-2 text-danger"></i>Delete Movie</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body px-4 py-3">
                    Are you sure you want to permanently delete <strong id="delTitle"></strong>?
                    <div class="text-muted small mt-2">
                        This removes the movie and its genre links. Movies that still have showtimes cannot be deleted —
                        hide them instead.
                    </div>
                </div>
                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-danger"><i class="bi bi-trash me-1"></i>Delete</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.delete-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.getElementById('delId').value = this.dataset.id;
            document.getElementById('delTitle').textContent = this.dataset.title;
        });
    });
</script>
</body>
</html>
