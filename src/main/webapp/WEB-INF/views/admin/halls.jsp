<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Admin Hall/Room management - card layout consistent with /branch/halls (mockup 24). --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hall Management - PentaPlex Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .room-card { background:#fff; border:1px solid var(--lc-border); border-radius:14px; box-shadow:var(--lc-shadow); overflow:hidden; height:100%; display:flex; flex-direction:column; transition:box-shadow .15s, transform .15s; }
        .room-card:hover { box-shadow:0 10px 26px rgba(15,23,42,.10); transform:translateY(-2px); }
        .room-head { padding:.85rem 1rem; color:#fff; display:flex; justify-content:space-between; align-items:flex-start; gap:.5rem; }
        .room-head.t-standard { background:linear-gradient(135deg,#3b82f6,#1d4ed8); }
        .room-head.t-vip { background:linear-gradient(135deg,#eab308,#ca8a04); }
        .room-head.t-imax { background:linear-gradient(135deg,#8b5cf6,#6d28d9); }
        .room-head.t-off { background:linear-gradient(135deg,#94a3b8,#64748b); }
        .room-head .nm { display:flex; align-items:center; gap:.4rem; font-weight:800; font-size:1rem; line-height:1.1; }
        .room-head .ty { font-size:.66rem; opacity:.9; letter-spacing:.05em; text-transform:uppercase; margin-top:.2rem; }
        .room-chip { font-size:.62rem; font-weight:700; padding:.18rem .5rem; border-radius:999px; background:rgba(255,255,255,.22); display:inline-flex; align-items:center; gap:.25rem; white-space:nowrap; }
        .room-body { padding:.9rem 1rem; flex:1; }
        .room-seats { display:flex; align-items:center; gap:.55rem; margin-bottom:.75rem; }
        .room-seats .ic { width:30px; height:30px; border-radius:8px; background:#f1f5f9; color:var(--lc-muted); display:flex; align-items:center; justify-content:center; font-size:.95rem; }
        .room-seats .n { font-size:1.45rem; font-weight:800; color:var(--lc-navy); line-height:1; }
        .room-seats .u { font-size:.78rem; color:var(--lc-muted); }
        .room-typebar { display:flex; justify-content:space-between; align-items:center; padding:.45rem .7rem; border-radius:8px; font-size:.8rem; font-weight:600; }
        .room-typebar.tb-standard { background:var(--lc-light); color:var(--primary-700); }
        .room-typebar.tb-vip { background:#fffbeb; color:#b45309; }
        .room-typebar.tb-imax { background:#f5f3ff; color:#6d28d9; }
        .room-actrow { display:flex; justify-content:space-between; align-items:center; padding:.6rem 1rem; border-top:1px solid var(--lc-border); }
        .room-actrow .form-check-input { width:2.4em; height:1.3em; cursor:pointer; margin:0; }
        .room-foot { padding:.75rem 1rem; border-top:1px solid var(--lc-border); display:flex; gap:.5rem; }
        .add-room-card { border:2px dashed #cdd6e6; border-radius:14px; background:var(--lc-light); display:flex; flex-direction:column; align-items:center; justify-content:center; min-height:200px; color:var(--lc-primary); cursor:pointer; transition:all .15s ease; height:100%; }
        .add-room-card:hover { border-color:var(--lc-primary); background:#e7efff; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:1320px;">

        <div class="text-muted small mb-1">Admin / Cinemas / <span class="fw-semibold">Rooms</span></div>
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="text-navy fw-bold mb-0">Room Management</h4>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                <i class="bi bi-plus-circle me-1"></i>Add Room</button>
        </div>

        <c:if test="${not empty successMsg}"><div class="alert alert-success py-2 alert-dismissible fade show">${successMsg}<button class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
        <c:if test="${not empty errorMsg}"><div class="alert alert-danger py-2 alert-dismissible fade show">${errorMsg}<button class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

        <%-- Branch filter --%>
        <div class="card lc-elev mb-3">
            <div class="card-body py-3">
                <form method="get" action="${pageContext.request.contextPath}/admin/halls" class="d-flex gap-2 align-items-center flex-wrap">
                    <label class="fw-semibold small text-muted me-1">Cinema:</label>
                    <select name="branchId" class="form-select" style="max-width:320px;" onchange="this.form.submit()">
                        <option value="">All cinemas</option>
                        <c:forEach items="${branches}" var="b">
                            <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.name}"/></option>
                        </c:forEach>
                    </select>
                    <button class="btn btn-light border btn-sm"><i class="bi bi-funnel me-1"></i>Filter</button>
                    <span class="text-muted small ms-auto">${fn:length(rooms)} room(s)</span>
                </form>
            </div>
        </div>

        <div class="row g-3">
            <c:forEach items="${rooms}" var="room">
                <c:set var="tcls" value="${room.roomType == 'VIP' ? 't-vip' : (room.roomType == 'IMAX' ? 't-imax' : 't-standard')}"/>
                <c:set var="tbcls" value="${room.roomType == 'VIP' ? 'tb-vip' : (room.roomType == 'IMAX' ? 'tb-imax' : 'tb-standard')}"/>
                <div class="col-sm-6 col-lg-4 col-xl-3">
                    <div class="room-card">
                        <div class="room-head ${room.active ? tcls : 't-off'}">
                            <div>
                                <div class="nm"><i class="bi bi-easel2-fill"></i><c:out value="${room.name}"/></div>
                                <div class="ty">${room.roomType} &middot;
                                    <c:forEach items="${branches}" var="b">
                                        <c:if test="${b.branchId == room.branchId}"><c:out value="${b.name}"/></c:if>
                                    </c:forEach>
                                </div>
                            </div>
                            <span class="room-chip">
                                <i class="bi ${room.active ? 'bi-check-circle-fill' : 'bi-slash-circle-fill'}"></i>${room.active ? 'Active' : 'Inactive'}</span>
                        </div>
                        <div class="room-body">
                            <div class="room-seats">
                                <span class="ic"><i class="bi bi-grid-3x3-gap"></i></span>
                                <span class="n">${room.displaySeatCount}</span><span class="u">seats</span>
                            </div>
                            <div class="text-muted" style="font-size:.78rem;">
                                <i class="bi bi-info-circle me-1"></i>Active bookable seats (edit layout via Seats)</div>
                        </div>
                        <div class="room-actrow">
                            <span class="fw-semibold small text-navy">Active</span>
                            <form method="post" action="${pageContext.request.contextPath}/admin/halls">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <input type="hidden" name="action" value="toggleStatus">
                                <input type="hidden" name="roomId" value="${room.roomId}">
                                <input type="hidden" name="active" value="${!room.active}">
                                <c:if test="${not empty selectedBranchId}">
                                    <input type="hidden" name="filterBranchId" value="${selectedBranchId}">
                                </c:if>
                                <input class="form-check-input" type="checkbox" role="switch"
                                       ${room.active ? 'checked' : ''} onchange="this.form.submit()">
                            </form>
                        </div>
                        <div class="room-foot">
                            <button class="btn btn-light border btn-sm flex-fill edit-btn"
                                    data-id="${room.roomId}" data-name="${room.name}"
                                    data-type="${room.roomType}"
                                    data-bs-toggle="modal" data-bs-target="#editRoomModal">
                                <i class="bi bi-pencil me-1"></i>Edit</button>
                            <a class="btn btn-primary btn-sm flex-fill" href="${pageContext.request.contextPath}/admin/seats?roomId=${room.roomId}">
                                <i class="bi bi-grid-3x3-gap me-1"></i>Seats</a>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <div class="col-sm-6 col-lg-4 col-xl-3">
                <div class="add-room-card" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                    <i class="bi bi-plus-circle fs-1 mb-2"></i>
                    <div class="fw-semibold">Add new room</div>
                    <div class="small text-muted">Configure seats afterwards</div>
                </div>
            </div>
        </div>

        <c:if test="${empty rooms}">
            <div class="text-center text-muted py-4">No rooms for this cinema yet.</div>
        </c:if>
    </div>
</main>

<%-- ADD MODAL --%>
<div class="modal fade" id="addRoomModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="${pageContext.request.contextPath}/admin/halls">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="add">
            <c:if test="${not empty selectedBranchId}">
                <input type="hidden" name="filterBranchId" value="${selectedBranchId}">
            </c:if>
            <div class="modal-header"><h5 class="modal-title">Add Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold small">Cinema</label>
                    <select name="branchId" class="form-select" required>
                        <c:forEach items="${branches}" var="b">
                            <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.name}"/></option>
                        </c:forEach>
                    </select></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Room Name</label>
                    <input class="form-control" name="name" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Initial capacity</label>
                    <input type="number" min="1" max="260" class="form-control" name="capacity" required>
                    <div class="form-text">Max 260 for new rooms. Change layout later via Seats.</div></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Room Type</label>
                    <select class="form-select" name="roomType">
                        <option value="STANDARD">STANDARD</option>
                        <option value="VIP">VIP</option>
                        <option value="IMAX">IMAX</option></select></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-primary" type="submit">Save</button>
            </div>
        </form>
    </div>
</div>

<%-- EDIT MODAL --%>
<div class="modal fade" id="editRoomModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="${pageContext.request.contextPath}/admin/halls">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="edit">
            <input type="hidden" id="editRoomId" name="roomId">
            <c:if test="${not empty selectedBranchId}">
                <input type="hidden" name="filterBranchId" value="${selectedBranchId}">
            </c:if>
            <div class="modal-header"><h5 class="modal-title">Edit Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold small">Room Name</label>
                    <input id="editName" class="form-control" name="name" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Room Type</label>
                    <select id="editType" class="form-select" name="roomType">
                        <option value="STANDARD">STANDARD</option>
                        <option value="VIP">VIP</option>
                        <option value="IMAX">IMAX</option></select></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                <button class="btn btn-primary" type="submit">Update</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', function () {
            document.getElementById('editRoomId').value = this.dataset.id;
            document.getElementById('editName').value = this.dataset.name;
            document.getElementById('editType').value = this.dataset.type;
        });
    });
</script>
</body>
</html>
