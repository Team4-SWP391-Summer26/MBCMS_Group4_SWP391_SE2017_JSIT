<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Genre Management – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .lc-alert { border-radius:10px; font-size:.88rem; padding:.7rem 1rem; display:flex;
            align-items:center; gap:.6rem; border:none; margin-bottom:1.25rem; }
        .lc-alert-success { background:#D1FAE5; color:#065F46; }
        .lc-alert-danger  { background:#FEE2E2; color:#991B1B; }

        .lc-card { background:#fff; border:1px solid var(--lc-border); border-radius:16px;
            box-shadow:var(--lc-shadow); overflow:hidden; }
        .genre-table { width:100%; margin:0; }
        .genre-table th { font-size:.72rem; text-transform:uppercase; letter-spacing:.05em; color:var(--lc-muted);
            font-weight:700; padding:.85rem 1.25rem; border-bottom:1px solid var(--lc-border); text-align:left; background:#fafbfd; }
        .genre-table td { padding:.85rem 1.25rem; border-bottom:1px solid var(--lc-border); font-size:.9rem; vertical-align:middle; }
        .genre-table tr:last-child td { border-bottom:none; }
        .genre-name { font-weight:600; color:#0f1e36; }
        .count-pill { font-size:.72rem; font-weight:600; padding:.18rem .6rem; border-radius:999px;
            background:var(--lc-light); color:var(--lc-primary); }
        .count-pill.zero { background:#F1F5F9; color:#64748B; }
        .icon-btn { width:32px; height:32px; border-radius:8px; border:1px solid var(--lc-border); background:#fff;
            color:#475569; display:inline-flex; align-items:center; justify-content:center; cursor:pointer; transition:.12s; }
        .icon-btn:hover { border-color:var(--lc-primary); color:var(--lc-primary); background:var(--lc-light); }
        .icon-btn.danger:hover { border-color:#FECACA; color:#991B1B; background:#FEE2E2; }
        .icon-btn:disabled { opacity:.4; cursor:not-allowed; }

        .modal-content { border:none; border-radius:16px; box-shadow:0 20px 60px rgba(0,0,0,.15); }
        .modal-title { font-weight:700; font-size:1rem; color:#0f1e36; }
        .lc-form-label { font-size:.8rem; font-weight:600; color:#374151; margin-bottom:.3rem; }
        .lc-form-control { border:1px solid var(--lc-border); border-radius:8px; padding:.5rem .75rem; font-size:.88rem; width:100%; }
        .lc-form-control:focus { outline:none; border-color:var(--lc-primary); box-shadow:0 0 0 3px rgba(37,99,235,.1); }
        .lc-modal-btn { padding:.5rem 1.2rem; border-radius:8px; font-size:.88rem; font-weight:600; cursor:pointer; border:none; }
        .lc-modal-btn-cancel { background:var(--lc-light); color:#374151; border:1px solid var(--lc-border); }
        .lc-modal-btn-save { background:var(--lc-primary); color:#fff; }
        .lc-modal-btn-save:hover { background:var(--lc-primary-700); }
        .lc-modal-btn-danger { background:#DC2626; color:#fff; }
        .lc-modal-btn-danger:hover { background:#B91C1C; }
    </style>
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="genres"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:880px;">

        <div class="text-muted small mb-1">Admin / <span class="fw-semibold">Genres</span></div>
        <div class="d-flex justify-content-between align-items-start mb-4">
            <div>
                <h4 class="fw-bold text-navy mb-1">Genre Management</h4>
                <div class="text-muted small">Maintain the list of movie genres used across the catalog.</div>
            </div>
            <button class="btn btn-primary btn-sm text-nowrap" data-bs-toggle="modal" data-bs-target="#addModal">
                <i class="bi bi-plus-lg me-1"></i>Add Genre
            </button>
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

        <div class="lc-card">
            <table class="genre-table">
                <thead>
                    <tr>
                        <th style="width:55%;">Genre</th>
                        <th>Movies using it</th>
                        <th style="width:90px;text-align:right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${genres}" var="g">
                        <tr>
                            <td><span class="genre-name"><i class="bi bi-tag-fill me-2 text-primary opacity-50"></i>${fn:escapeXml(g.name)}</span></td>
                            <td><span class="count-pill ${g.movieCount == 0 ? 'zero' : ''}">${g.movieCount} movie${g.movieCount == 1 ? '' : 's'}</span></td>
                            <td style="text-align:right;">
                                <button type="button" class="icon-btn edit-btn"
                                        data-id="${g.genreId}" data-name="${fn:escapeXml(g.name)}"
                                        data-bs-toggle="modal" data-bs-target="#editModal" title="Rename">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <button type="button" class="icon-btn danger delete-btn"
                                        data-id="${g.genreId}" data-name="${fn:escapeXml(g.name)}"
                                        ${g.movieCount > 0 ? 'disabled' : ''}
                                        data-bs-toggle="modal" data-bs-target="#deleteModal"
                                        title="${g.movieCount > 0 ? 'In use - cannot delete' : 'Delete'}">
                                    <i class="bi bi-trash"></i>
                                </button>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty genres}">
                        <tr><td colspan="3" class="text-center py-5" style="color:var(--lc-muted);">
                            <i class="bi bi-tags" style="font-size:2rem;display:block;margin-bottom:.5rem;"></i>
                            No genres yet. Click “Add Genre” to create one.
                        </td></tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</main>

<%-- ── Add modal ─────────────────────────────────────────── --%>
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
                    <label class="lc-form-label">Genre name <span class="text-danger">*</span></label>
                    <input type="text" name="name" class="lc-form-control" maxlength="50" required
                           placeholder="e.g. Action" autocomplete="off">
                </div>
                <div class="modal-footer gap-2">
                    <button type="button" class="lc-modal-btn lc-modal-btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="lc-modal-btn lc-modal-btn-save"><i class="bi bi-plus-lg me-1"></i>Add</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- ── Edit modal ────────────────────────────────────────── --%>
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
                    <label class="lc-form-label">Genre name <span class="text-danger">*</span></label>
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

<%-- ── Delete modal ──────────────────────────────────────── --%>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.edit-btn').forEach(b => b.addEventListener('click', function () {
        document.getElementById('editId').value = this.dataset.id;
        document.getElementById('editName').value = this.dataset.name;
    }));
    document.querySelectorAll('.delete-btn').forEach(b => b.addEventListener('click', function () {
        document.getElementById('delId').value = this.dataset.id;
        document.getElementById('delName').textContent = this.dataset.name;
    }));
</script>
</body>
</html>
