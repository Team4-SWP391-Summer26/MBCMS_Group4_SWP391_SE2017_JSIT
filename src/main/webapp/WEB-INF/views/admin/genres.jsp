<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Genre Management – PentaPlex</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="genres"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / <strong>Genres</strong></div>
                <h1 class="lc-page-title">Genre Management</h1>
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

        <%-- KPI --%>
        <c:set var="genreTotal" value="${fn:length(genres)}"/>
        <c:set var="genreInUse" value="0"/>
        <c:set var="genreUnused" value="0"/>
        <c:forEach items="${genres}" var="g">
            <c:choose>
                <c:when test="${g.movieCount > 0}">
                    <c:set var="genreInUse" value="${genreInUse + 1}"/>
                </c:when>
                <c:otherwise>
                    <c:set var="genreUnused" value="${genreUnused + 1}"/>
                </c:otherwise>
            </c:choose>
        </c:forEach>

        <div class="lc-kpi-row lc-kpi-row--3">
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-tags-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Total genres</div>
                    <div class="lc-kpi-value">${genreTotal}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-film"></i></div>
                <div>
                    <div class="lc-kpi-label">In use</div>
                    <div class="lc-kpi-value">${genreInUse}</div>
                    <div class="lc-kpi-hint">Linked to movies</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--slate"><i class="bi bi-dash-circle"></i></div>
                <div>
                    <div class="lc-kpi-label">Unused</div>
                    <div class="lc-kpi-value">${genreUnused}</div>
                    <div class="lc-kpi-hint">Safe to remove</div>
                </div>
            </div>
        </div>

        <%-- Toolbar --%>
        <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
            <div class="st-toolbar-track w-100">
                <div class="lc-toolbar-search">
                    <i class="bi bi-search" aria-hidden="true"></i>
                    <input type="search" id="genreSearch" class="fnb-search-input"
                           placeholder="Search genres..." autocomplete="off"
                           aria-label="Search genres">
                </div>
                <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                <button type="button" class="st-toolbar-add border-0" data-bs-toggle="modal" data-bs-target="#addModal">
                    <i class="bi bi-plus-lg" aria-hidden="true"></i> Add Genre
                </button>
            </div>
        </div>

        <%-- Genre list --%>
        <div class="genre-panel">
            <div class="genre-panel-head">
                <span>Catalog genres</span>
                <span id="genreVisibleCount">${genreTotal} shown</span>
            </div>

            <c:choose>
                <c:when test="${empty genres}">
                    <div class="genre-empty">
                        <div class="genre-empty-ic"><i class="bi bi-tags" aria-hidden="true"></i></div>
                        <h3>No genres yet</h3>
                        <p>Create genres to classify movies in the catalog.</p>
                        <button type="button" class="st-toolbar-add border-0" data-bs-toggle="modal" data-bs-target="#addModal">
                            <i class="bi bi-plus-lg" aria-hidden="true"></i> Add first genre
                        </button>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="genre-list" id="genreList">
                        <c:forEach items="${genres}" var="g" varStatus="st">
                            <c:set var="toneIdx" value="${st.index % 6}"/>
                            <c:set var="tone" value="blue"/>
                            <c:if test="${toneIdx == 1}"><c:set var="tone" value="green"/></c:if>
                            <c:if test="${toneIdx == 2}"><c:set var="tone" value="amber"/></c:if>
                            <c:if test="${toneIdx == 3}"><c:set var="tone" value="rose"/></c:if>
                            <c:if test="${toneIdx == 4}"><c:set var="tone" value="slate"/></c:if>
                            <c:if test="${toneIdx == 5}"><c:set var="tone" value="violet"/></c:if>
                            <article class="genre-item" data-tone="${tone}" data-name="${fn:toLowerCase(g.name)}"
                                     style="--i:${st.index};">
                                <div class="genre-swatch" aria-hidden="true">
                                    <i class="bi bi-tag-fill"></i>
                                </div>
                                <div>
                                    <p class="genre-name">${fn:escapeXml(g.name)}</p>
                                    <div class="genre-slug">genre-${g.genreId}</div>
                                </div>
                                <span class="genre-count ${g.movieCount == 0 ? 'is-zero' : ''}">
                                    <i class="bi bi-film" aria-hidden="true"></i>
                                    ${g.movieCount} movie${g.movieCount == 1 ? '' : 's'}
                                </span>
                                <div class="genre-actions">
                                    <button type="button" class="genre-act edit-btn"
                                            data-id="${g.genreId}" data-name="${fn:escapeXml(g.name)}"
                                            data-bs-toggle="modal" data-bs-target="#editModal"
                                            title="Rename" aria-label="Rename ${fn:escapeXml(g.name)}">
                                        <i class="bi bi-pencil"></i>
                                    </button>
                                    <button type="button" class="genre-act is-danger delete-btn"
                                            data-id="${g.genreId}" data-name="${fn:escapeXml(g.name)}"
                                            ${g.movieCount > 0 ? 'disabled' : ''}
                                            data-bs-toggle="modal" data-bs-target="#deleteModal"
                                            title="${g.movieCount > 0 ? 'In use — cannot delete' : 'Delete'}"
                                            aria-label="Delete ${fn:escapeXml(g.name)}">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                    <div class="genre-no-match" id="genreNoMatch">
                        <i class="bi bi-search me-1"></i> No genres match your search.
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

    </div>
</main>

<%-- Add modal --%>
<div class="modal fade" id="addModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/genres">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="add">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-tag me-2 text-primary"></i>Add Genre</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body px-4 py-3">
                    <label class="lc-form-label" for="addName">Genre name <span class="text-danger">*</span></label>
                    <input type="text" name="name" id="addName" class="lc-form-control" maxlength="50" required
                           placeholder="e.g. Action" autocomplete="off">
                    <div class="form-text text-muted small mt-1">Shown on movie detail and browse filters.</div>
                </div>
                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save"><i class="bi bi-plus-lg me-1"></i>Add</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Edit modal --%>
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/genres">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="genreId" id="editId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-pencil-square me-2 text-primary"></i>Rename Genre</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body px-4 py-3">
                    <label class="lc-form-label" for="editName">Genre name <span class="text-danger">*</span></label>
                    <input type="text" name="name" id="editName" class="lc-form-control" maxlength="50" required autocomplete="off">
                </div>
                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save"><i class="bi bi-check-lg me-1"></i>Save</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- Delete modal --%>
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin/genres">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="action" value="delete">
                <input type="hidden" name="genreId" id="delId">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-exclamation-triangle-fill me-2 text-danger"></i>Delete Genre</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body px-4 py-3">
                    Delete genre <strong id="delName"></strong>? This action cannot be undone.
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
    document.querySelectorAll('.edit-btn').forEach(function (b) {
        b.addEventListener('click', function () {
            document.getElementById('editId').value = this.dataset.id;
            document.getElementById('editName').value = this.dataset.name;
        });
    });
    document.querySelectorAll('.delete-btn').forEach(function (b) {
        b.addEventListener('click', function () {
            document.getElementById('delId').value = this.dataset.id;
            document.getElementById('delName').textContent = this.dataset.name;
        });
    });

    (function () {
        var input = document.getElementById('genreSearch');
        var list = document.getElementById('genreList');
        var noMatch = document.getElementById('genreNoMatch');
        var counter = document.getElementById('genreVisibleCount');
        if (!input || !list) return;

        function filterGenres() {
            var q = input.value.trim().toLowerCase();
            var items = list.querySelectorAll('.genre-item');
            var visible = 0;
            items.forEach(function (el) {
                var name = el.getAttribute('data-name') || '';
                var show = !q || name.indexOf(q) !== -1;
                el.classList.toggle('is-hidden', !show);
                if (show) visible++;
            });
            if (counter) counter.textContent = visible + ' shown';
            if (noMatch) noMatch.classList.toggle('is-visible', visible === 0 && items.length > 0);
        }

        input.addEventListener('input', filterGenres);
    })();
</script>
</body>
</html>
