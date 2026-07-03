<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Movie Management – PentaPlex</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
    <style>
        .mv-card { background:#fff; border:1px solid var(--lc-border); border-radius:16px; overflow:hidden;
            box-shadow:var(--lc-shadow); display:flex; flex-direction:column; height:100%; transition:box-shadow .15s, transform .15s; }
        .mv-card:hover { box-shadow:0 10px 26px rgba(15,23,42,.10); transform:translateY(-2px); }
        .mv-card.is-inactive { opacity:.62; }
        .poster-art { position:relative; aspect-ratio:2/3; overflow:hidden; background:var(--lc-navy); }
        .poster-art img { width:100%; height:100%; object-fit:cover; }
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
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="movies"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / <strong>Movies</strong></div>
                <h1 class="lc-page-title">Movie Management</h1>
                <p class="text-muted small mb-0 mt-1">Add, edit and delete movies, upload posters/trailers and manage their status.</p>
            </div>
        </div>

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

        <c:set var="nowShowing" value="0"/><c:set var="upcoming" value="0"/>
        <c:set var="ended" value="0"/><c:set var="hidden" value="0"/>
        <c:forEach items="${movies}" var="m">
            <c:if test="${m.status == 'NOW_SHOWING'}"><c:set var="nowShowing" value="${nowShowing + 1}"/></c:if>
            <c:if test="${m.status == 'UPCOMING'}"><c:set var="upcoming" value="${upcoming + 1}"/></c:if>
            <c:if test="${m.status == 'ENDED'}"><c:set var="ended" value="${ended + 1}"/></c:if>
            <c:if test="${not m.active}"><c:set var="hidden" value="${hidden + 1}"/></c:if>
        </c:forEach>

        <div class="lc-kpi-row mb-4">
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-film"></i></div>
                <div><div class="lc-kpi-label">Total movies</div><div class="lc-kpi-value">${movies.size()}</div></div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-play-circle-fill"></i></div>
                <div><div class="lc-kpi-label">Now showing</div><div class="lc-kpi-value">${nowShowing}</div></div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-clock-fill"></i></div>
                <div><div class="lc-kpi-label">Upcoming</div><div class="lc-kpi-value">${upcoming}</div></div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--slate"><i class="bi bi-eye-slash-fill"></i></div>
                <div><div class="lc-kpi-label">Hidden</div><div class="lc-kpi-value">${hidden}</div></div>
            </div>
        </div>

        <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
            <form class="st-toolbar-track w-100" method="get" action="${pageContext.request.contextPath}/admin/movies">
                <div class="lc-toolbar-search">
                    <i class="bi bi-search" aria-hidden="true"></i>
                    <input type="search" name="q" placeholder="Search title, director, cast..."
                           value="${fn:escapeXml(q)}" aria-label="Search movies">
                </div>
                <div class="st-toolbar-vrule" aria-hidden="true"></div>
                <select name="status" class="st-toolbar-select" onchange="this.form.submit()" aria-label="Filter by status">
                    <option value="">All status</option>
                    <option value="NOW_SHOWING" ${statusFilter == 'NOW_SHOWING' ? 'selected' : ''}>Now Showing</option>
                    <option value="UPCOMING" ${statusFilter == 'UPCOMING' ? 'selected' : ''}>Upcoming</option>
                    <option value="ENDED" ${statusFilter == 'ENDED' ? 'selected' : ''}>Ended</option>
                </select>
                <c:if test="${not empty q or not empty statusFilter}">
                    <a href="${pageContext.request.contextPath}/admin/movies" class="btn btn-link btn-sm text-decoration-none">Clear</a>
                </c:if>
                <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                <a href="${pageContext.request.contextPath}/admin/movies?action=add" class="st-toolbar-add">
                    <i class="bi bi-plus-lg" aria-hidden="true"></i> Add Movie</a>
            </form>
        </div>

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
                            <form class="mv-status-form" method="post" action="${pageContext.request.contextPath}/admin/movies">
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
                                <a href="${pageContext.request.contextPath}/admin/movies?action=edit&id=${m.movieId}" class="mv-btn"><i class="bi bi-pencil"></i> Edit</a>
                                <button type="button" class="mv-btn mv-btn-danger delete-btn"
                                        data-id="${m.movieId}" data-title="${fn:escapeXml(m.title)}"
                                        data-bs-toggle="modal" data-bs-target="#deleteModal">
                                    <i class="bi bi-trash"></i> Delete</button>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/admin/movies" class="mv-toggle">
                                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <input type="hidden" name="action" value="toggleActive">
                                <input type="hidden" name="movieId" value="${m.movieId}">
                                <input type="hidden" name="active" value="${m.active ? 'false' : 'true'}">
                                <span><i class="bi ${m.active ? 'bi-eye' : 'bi-eye-slash'} me-1"></i>${m.active ? 'Visible to customers' : 'Hidden'}</span>
                                <button type="submit" class="btn btn-sm btn-link p-0 text-decoration-none" style="font-size:.74rem;">
                                    ${m.active ? 'Hide' : 'Show'}</button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty movies}">
                <div class="col-12">
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-film fs-1 d-block mb-2 opacity-50"></i>
                        No movies found.
                        <a href="${pageContext.request.contextPath}/admin/movies?action=add" class="text-decoration-none">Add one</a>.
                    </div>
                </div>
            </c:if>
        </div>

    </div>
</main>

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

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
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
