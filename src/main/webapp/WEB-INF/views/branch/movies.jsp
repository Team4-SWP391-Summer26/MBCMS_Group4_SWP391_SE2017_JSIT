<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Movies (READ-ONLY) - Branch Manager chi xem phim da duoc Admin cap cho
     chi nhanh minh; khong co nut them/sua/xoa (viec do thuoc Admin). --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Movies - PentaPlex Manager</title>
    <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    <style>
        .mv-card { background:#fff; border:1px solid var(--lc-border); border-radius:16px; overflow:hidden;
            box-shadow:0 1px 2px rgba(15,23,42,.05); display:flex; flex-direction:column; height:100%; transition:box-shadow .15s, transform .15s; }
        .mv-card:hover { box-shadow:0 8px 22px rgba(15,23,42,.09); transform:translateY(-2px); }
        .poster-art { position:relative; aspect-ratio:2/3; overflow:hidden; background:var(--lc-navy); }
        .poster-art img { width:100%; height:100%; object-fit:cover; }
        .mv-status-badge { position:absolute; top:.6rem; left:.6rem; z-index:2; padding:.22rem .6rem;
            border-radius:999px; font-size:.66rem; font-weight:700; text-transform:uppercase; letter-spacing:.04em;
            display:inline-flex; align-items:center; gap:.3rem; color:#fff; }
        .st-NOW_SHOWING { background:rgba(22,163,74,.92); }
        .st-UPCOMING    { background:rgba(37,99,235,.92); }
        .st-ENDED       { background:rgba(100,116,139,.92); }
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
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="movies"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Dashboard / <strong>Movies</strong></div>
                <h1 class="lc-page-title">Movies</h1>
                <p class="text-muted small mb-0 mt-1">Movies assigned to your branch by the Admin (view only).</p>
            </div>
            <c:if test="${not empty sessionScope.currentBranchName}">
                <span class="lc-branch-chip">
                    <i class="bi bi-geo-alt-fill"></i>
                    <c:out value="${sessionScope.currentBranchName}"/>
                </span>
            </c:if>
        </div>

        <div class="lc-scope mb-3">
            <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
            <span>Read-only &mdash; movie assignment is managed by the Admin. Contact Head Office to add or remove a movie for this branch.</span>
        </div>

        <div class="text-muted small mb-3">${fn:length(movies)} movie(s) assigned to this branch</div>

        <div class="row g-3 lc-tile-grid">
            <c:forEach items="${movies}" var="m">
                <div class="col-6 col-sm-4 col-md-3 col-xxl-2">
                    <div class="mv-card">
                        <div class="poster-art">
                            <span class="mv-status-badge st-${m.status}">
                                <i class="bi bi-circle-fill" style="font-size:.36rem;"></i>
                                <c:choose>
                                    <c:when test="${m.status == 'NOW_SHOWING'}">Now Showing</c:when>
                                    <c:when test="${m.status == 'UPCOMING'}">Upcoming</c:when>
                                    <c:otherwise>Ended</c:otherwise>
                                </c:choose>
                            </span>
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
                        </div>
                    </div>
                </div>
            </c:forEach>
            <c:if test="${empty movies}">
                <div class="col-12">
                    <div class="lc-empty">
                        <i class="bi bi-film"></i>
                        <div class="lc-empty-title">No movies assigned yet</div>
                        <div class="lc-empty-hint">The Admin hasn't assigned any movie to this branch yet.</div>
                    </div>
                </div>
            </c:if>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
</body>
</html>
