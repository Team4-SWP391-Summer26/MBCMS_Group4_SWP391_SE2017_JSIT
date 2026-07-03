<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Movie Distribution - PentaPlex Admin</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
    <style>
        .mv-row {
            display: flex; align-items: center; gap: 12px; padding: .6rem .9rem;
            border: 1px solid var(--lc-border); border-radius: 10px; background: #fff;
            transition: border-color .12s, background .12s;
        }
        .mv-row:hover { border-color: var(--lc-primary); background: var(--lc-light); }
        .mv-row.checked { border-color: var(--lc-primary); background: #f5f9ff; }
        .mv-check { width: 18px; height: 18px; flex-shrink: 0; cursor: pointer; }
        .mv-title { font-weight: 600; color: var(--navy); }
        .mv-meta { font-size: .76rem; color: var(--lc-muted); }
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="movie-branches"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / <strong>Movie Assignment</strong></div>
                <h1 class="lc-page-title">Movie Distribution</h1>
            </div>
        </div>

        <div class="lc-scope mb-4">
            <i class="bi bi-info-circle-fill" style="color:#cf9a00;"></i>
            <span>Assign which movies are available at each branch. Branch Managers
                can only schedule showtimes for movies assigned to their branch.</span>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2 alert-dismissible fade show"><i class="bi bi-check-circle me-1"></i>${successMsg}
                <button class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2 alert-dismissible fade show"><i class="bi bi-exclamation-circle me-1"></i>${errorMsg}
                <button class="btn-close" data-bs-dismiss="alert"></button></div>
        </c:if>

        <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
            <form method="get" action="${pageContext.request.contextPath}/admin/movie-branches" class="st-toolbar-track w-100">
                <label class="fw-semibold small text-muted mb-0 text-nowrap">Branch:</label>
                <select name="branchId" class="st-toolbar-select" style="max-width:320px;" onchange="this.form.submit()" aria-label="Select branch">
                    <c:forEach var="b" items="${branches}">
                        <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}>
                            <c:out value="${b.name}" /> &middot; <c:out value="${b.city}" />
                        </option>
                    </c:forEach>
                </select>
            </form>
        </div>

        <c:if test="${not empty selectedBranchId}">
            <form id="distForm" method="post" action="${pageContext.request.contextPath}/admin/movie-branches">
                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                <input type="hidden" name="branchId" value="${selectedBranchId}">

                <div class="card lc-elev p-4">
                    <div class="d-flex flex-wrap align-items-center gap-3 mb-3 pb-3 border-bottom">
                        <span class="fw-semibold">
                            Assigned: <span id="cntAssigned">0</span><span class="text-muted" id="cntTotalWrap"></span>
                        </span>
                        <button type="button" class="btn btn-link btn-sm p-0" onclick="selectAll()">Select all</button>
                        <button type="button" class="btn btn-link btn-sm p-0" onclick="clearAll()">Clear</button>
                        <span class="text-muted small ms-auto">
                            <i class="bi bi-info-circle"></i> Tick a movie to make it available at this branch.
                        </span>
                    </div>

                    <c:choose>
                        <c:when test="${empty movies}">
                            <div class="text-muted text-center py-4">No active movies in the catalog yet.</div>
                        </c:when>
                        <c:otherwise>
                            <div class="d-flex flex-column gap-2">
                                <c:forEach var="m" items="${movies}">
                                    <c:set var="isOn" value="${assignedIds.contains(m.movieId)}" />
                                    <label class="mv-row ${isOn ? 'checked' : ''}">
                                        <input type="checkbox" class="mv-check form-check-input mt-0"
                                               name="movieIds" value="${m.movieId}"
                                               data-initial="${isOn}"
                                               ${isOn ? 'checked' : ''}
                                               onchange="onToggle(this)">
                                        <span class="flex-grow-1">
                                            <span class="mv-title"><c:out value="${m.title}" /></span>
                                            <span class="mv-meta">&nbsp; ${m.durationMin} min</span>
                                        </span>
                                        <c:choose>
                                            <c:when test="${m.status == 'NOW_SHOWING'}"><span class="pill pill-green">Now showing</span></c:when>
                                            <c:when test="${m.status == 'UPCOMING'}"><span class="pill pill-blue">Upcoming</span></c:when>
                                            <c:otherwise><span class="pill pill-gray">${m.status}</span></c:otherwise>
                                        </c:choose>
                                    </label>
                                </c:forEach>
                            </div>
                            <div class="d-flex gap-2 mt-4">
                                <button type="submit" id="btnSave" class="st-toolbar-add border-0" disabled>
                                    <i class="bi bi-save"></i> Save changes <span id="dirtyNote"></span>
                                </button>
                                <a class="lc-btn-ghost" href="${pageContext.request.contextPath}/admin/movie-branches?branchId=${selectedBranchId}">
                                    <i class="bi bi-arrow-counterclockwise"></i> Reset</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </form>
        </c:if>

    </div>
</main>

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
<script>
    function onToggle(cb) {
        cb.closest('.mv-row').classList.toggle('checked', cb.checked);
        recount();
        updateDirty();
    }
    function selectAll() { setAll(true); }
    function clearAll() { setAll(false); }
    function setAll(on) {
        document.querySelectorAll('input[name="movieIds"]').forEach(function (cb) {
            cb.checked = on;
            cb.closest('.mv-row').classList.toggle('checked', on);
        });
        recount();
        updateDirty();
    }
    function recount() {
        const all = document.querySelectorAll('input[name="movieIds"]');
        let on = 0;
        all.forEach(function (cb) { if (cb.checked) on++; });
        document.getElementById('cntAssigned').textContent = on;
        document.getElementById('cntTotalWrap').textContent = ' of ' + all.length;
    }
    function updateDirty() {
        let changed = 0;
        document.querySelectorAll('input[name="movieIds"]').forEach(function (cb) {
            if (String(cb.checked) !== cb.dataset.initial) changed++;
        });
        document.getElementById('btnSave').disabled = changed === 0;
        document.getElementById('dirtyNote').textContent = changed ? ' (' + changed + ')' : '';
    }
    document.addEventListener('DOMContentLoaded', function () {
        recount();
        updateDirty();
    });
</script>
</body>
</html>
