<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="isEdit" value="${movie != null}"/>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${isEdit ? 'Edit' : 'Add'} Movie – PentaPlex</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
    <style>
        .req { color:var(--danger); }
        .poster-preview { aspect-ratio:2/3; border-radius:12px; overflow:hidden; background:var(--lc-navy);
            border:1px solid var(--lc-border); display:flex; align-items:center; justify-content:center;
            color:rgba(255,255,255,.5); position:relative; }
        .poster-preview img { width:100%; height:100%; object-fit:cover; }
        .poster-placeholder { text-align:center; font-size:.82rem; padding:1rem; }
        .poster-placeholder i { font-size:2rem; display:block; margin-bottom:.4rem; }
        .genre-grid { display:flex; flex-wrap:wrap; gap:.5rem; }
        .genre-pill { position:relative; }
        .genre-pill input { position:absolute; opacity:0; pointer-events:none; }
        .genre-pill label { display:inline-block; padding:.35rem .8rem; border:1px solid var(--lc-border);
            border-radius:999px; font-size:.82rem; cursor:pointer; color:#374151; background:#fff; transition:.12s; user-select:none; }
        .genre-pill input:checked + label { background:var(--lc-primary); border-color:var(--lc-primary); color:#fff; }
        .genre-pill label:hover { border-color:var(--lc-primary); }
        .form-switch-wrap { display:flex; align-items:center; justify-content:space-between;
            background:var(--lc-light); border:1px solid var(--lc-border); border-radius:10px; padding:.75rem 1rem; }
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="movies"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-form-actions">
            <div>
                <div class="lc-page-crumb">
                    <a href="${pageContext.request.contextPath}/admin/movies" class="text-decoration-none text-muted">Admin / Movies</a>
                    / <strong>${isEdit ? 'Edit' : 'Add new'}</strong>
                </div>
                <h1 class="lc-page-title mb-0">${isEdit ? 'Edit Movie' : 'Add New Movie'}</h1>
            </div>
            <div class="lc-form-actions-end">
                <a href="${pageContext.request.contextPath}/admin/movies" class="lc-btn-ghost">Cancel</a>
                <button type="submit" form="movieForm" class="st-toolbar-add border-0">
                    <i class="bi bi-check-lg" aria-hidden="true"></i>${isEdit ? 'Save Changes' : 'Add Movie'}
                </button>
            </div>
        </div>

        <%-- multipart: _csrf di qua query string de CsrfFilter doc duoc truoc khi parse body --%>
        <form method="post" enctype="multipart/form-data"
              action="${pageContext.request.contextPath}/admin/movies?_csrf=${sessionScope.csrfToken}"
              id="movieForm">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="${isEdit ? 'edit' : 'add'}">
            <c:if test="${isEdit}">
                <input type="hidden" name="movieId" value="${movie.movieId}">
                <input type="hidden" name="currentPoster" value="${fn:escapeXml(movie.posterUrl)}">
            </c:if>

            <div class="row g-4">

                <%-- ── Left: poster + status ──────────────────── --%>
                <div class="col-md-4">
                    <div class="lc-card lc-card-pad mb-4 lc-rise" style="--i:0;">
                        <div class="lc-card-title">Poster</div>
                        <div class="poster-preview mb-3" id="posterPreview">
                            <c:choose>
                                <c:when test="${isEdit and not empty movie.posterUrl}">
                                    <img id="posterImg" src="<c:url value='${movie.posterUrl}'/>" alt="poster">
                                </c:when>
                                <c:otherwise>
                                    <div class="poster-placeholder" id="posterPlaceholder">
                                        <i class="bi bi-image"></i>No poster selected
                                    </div>
                                    <img id="posterImg" src="" alt="poster" style="display:none;">
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <label class="lc-form-label">Upload poster image</label>
                        <input type="file" name="poster" id="posterInput" accept="image/*" class="lc-form-control">
                        <div class="text-muted mt-1" style="font-size:.74rem;">JPG, PNG, WEBP or GIF — max 5 MB.</div>
                    </div>

                    <div class="lc-card lc-card-pad lc-rise" style="--i:1;">
                        <div class="lc-card-title">Status & Visibility</div>
                        <div class="mb-3">
                            <label class="lc-form-label">Movie status <span class="req">*</span></label>
                            <select name="status" class="lc-form-control" required>
                                <option value="UPCOMING"    ${isEdit and movie.status == 'UPCOMING' ? 'selected' : ''}>Upcoming</option>
                                <option value="NOW_SHOWING" ${isEdit and movie.status == 'NOW_SHOWING' ? 'selected' : ''}>Now Showing</option>
                                <option value="ENDED"       ${isEdit and movie.status == 'ENDED' ? 'selected' : ''}>Ended</option>
                            </select>
                        </div>
                        <input type="hidden" name="active" id="activeHidden" value="${isEdit ? movie.active : 'true'}">
                        <div class="form-switch-wrap">
                            <div>
                                <div style="font-size:.85rem;font-weight:600;color:var(--navy);">Visible to customers</div>
                                <div style="font-size:.74rem;color:var(--lc-muted);">Hidden movies are not shown publicly</div>
                            </div>
                            <div class="form-check form-switch mb-0">
                                <input class="form-check-input" type="checkbox" role="switch" id="activeToggle"
                                       style="width:2.5rem;height:1.3rem;" ${(!isEdit or movie.active) ? 'checked' : ''}>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- ── Right: details ─────────────────────────── --%>
                <div class="col-md-8">
                    <div class="lc-card lc-card-pad mb-4 lc-rise" style="--i:1;">
                        <div class="lc-card-title">Movie Details</div>

                        <div class="mb-3">
                            <label class="lc-form-label">Title <span class="req">*</span></label>
                            <input type="text" name="title" class="lc-form-control" maxlength="200" required
                                   value="${fn:escapeXml(movie.title)}" placeholder="e.g. Avengers: Endgame">
                        </div>

                        <div class="mb-3">
                            <label class="lc-form-label">Synopsis</label>
                            <textarea name="description" class="lc-form-control" maxlength="2000"
                                      placeholder="Short description of the movie...">${fn:escapeXml(movie.description)}</textarea>
                        </div>

                        <div class="row g-3">
                            <div class="col-sm-4">
                                <label class="lc-form-label">Duration (min) <span class="req">*</span></label>
                                <input type="number" name="durationMin" class="lc-form-control" min="1" required
                                       value="${isEdit ? movie.durationMin : ''}" placeholder="120">
                            </div>
                            <div class="col-sm-4">
                                <label class="lc-form-label">Age rating</label>
                                <select name="rated" class="lc-form-control">
                                    <option value="">— None —</option>
                                    <option value="P"   ${movie.rated == 'P' ? 'selected' : ''}>P — All ages</option>
                                    <option value="C13" ${movie.rated == 'C13' ? 'selected' : ''}>C13 — 13+</option>
                                    <option value="C16" ${movie.rated == 'C16' ? 'selected' : ''}>C16 — 16+</option>
                                    <option value="C18" ${movie.rated == 'C18' ? 'selected' : ''}>C18 — 18+</option>
                                </select>
                            </div>
                            <div class="col-sm-4">
                                <label class="lc-form-label">Release date</label>
                                <input type="date" name="releaseDate" class="lc-form-control" value="${movie.releaseDate}">
                            </div>
                        </div>

                        <div class="row g-3 mt-0">
                            <div class="col-sm-6">
                                <label class="lc-form-label">Director</label>
                                <input type="text" name="director" class="lc-form-control" maxlength="100"
                                       value="${fn:escapeXml(movie.director)}" placeholder="e.g. Anthony &amp; Joe Russo">
                            </div>
                            <div class="col-sm-6">
                                <label class="lc-form-label">Language</label>
                                <input type="text" name="language" class="lc-form-control" list="langList" maxlength="50"
                                       value="${fn:escapeXml(movie.language)}" placeholder="e.g. English">
                                <datalist id="langList">
                                    <c:forEach items="${allLanguages}" var="lang">
                                        <option value="${fn:escapeXml(lang)}"></option>
                                    </c:forEach>
                                </datalist>
                            </div>
                            <div class="col-sm-6">
                                <label class="lc-form-label">Country</label>
                                <input type="text" name="country" class="lc-form-control" maxlength="50"
                                       value="${fn:escapeXml(movie.country)}" placeholder="e.g. USA">
                            </div>
                            <div class="col-sm-6">
                                <label class="lc-form-label">Trailer URL</label>
                                <input type="url" name="trailerUrl" class="lc-form-control" maxlength="500"
                                       value="${fn:escapeXml(movie.trailerUrl)}" placeholder="https://youtube.com/watch?v=...">
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="lc-form-label">Cast</label>
                            <input type="text" name="castList" class="lc-form-control" maxlength="500"
                                   value="${fn:escapeXml(movie.castList)}" placeholder="Comma-separated actor names">
                        </div>
                    </div>

                    <div class="lc-card lc-card-pad lc-rise" style="--i:2;">
                        <div class="lc-card-title">Genres</div>
                        <c:choose>
                            <c:when test="${empty allGenres}">
                                <div class="text-muted small">
                                    No genres yet.
                                    <a href="${pageContext.request.contextPath}/admin/genres" class="text-decoration-none">Create genres first</a>.
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="genre-grid">
                                    <c:forEach items="${allGenres}" var="g">
                                        <div class="genre-pill">
                                            <input type="checkbox" name="genreIds" id="g${g.genreId}" value="${g.genreId}"
                                                   ${selectedGenreIds.contains(g.genreId) ? 'checked' : ''}>
                                            <label for="g${g.genreId}">${fn:escapeXml(g.name)}</label>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </form>

    </div>
</main>

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
<script>
    // active toggle -> hidden field
    const toggle = document.getElementById('activeToggle');
    const hidden = document.getElementById('activeHidden');
    function syncActive() { hidden.value = toggle.checked ? 'true' : 'false'; }
    toggle.addEventListener('change', syncActive);
    syncActive();

    // live poster preview
    const input = document.getElementById('posterInput');
    const img = document.getElementById('posterImg');
    const placeholder = document.getElementById('posterPlaceholder');
    input.addEventListener('change', function () {
        const file = this.files && this.files[0];
        if (!file) return;
        const url = URL.createObjectURL(file);
        img.src = url;
        img.style.display = 'block';
        if (placeholder) placeholder.style.display = 'none';
    });
</script>
</body>
</html>
