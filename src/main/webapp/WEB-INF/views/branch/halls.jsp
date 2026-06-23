<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Room management (Branch Manager) - card layout theo mockup 24_mgr-rooms. --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Rooms &amp; Seats - MBCMS Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .room-card { background:#fff; border:1px solid var(--lc-border); border-radius:14px; box-shadow:var(--lc-shadow); overflow:hidden; height:100%; display:flex; flex-direction:column; }
        .room-top { padding:1rem 1.1rem; color:#fff; display:flex; justify-content:space-between; align-items:flex-start; }
        .room-top.t-standard { background:linear-gradient(135deg,#2563eb,#1e3a8a); }
        .room-top.t-vip { background:linear-gradient(135deg,#d99a1c,#b8770a); }
        .room-top.t-imax { background:linear-gradient(135deg,#7c3aed,#5b21b6); }
        .room-top .rt-name { font-weight:800; font-size:1.05rem; line-height:1.1; }
        .room-top .rt-type { font-size:.72rem; opacity:.85; letter-spacing:.04em; text-transform:uppercase; }
        .room-pill { font-size:.66rem; font-weight:700; padding:.18rem .5rem; border-radius:999px; background:rgba(255,255,255,.22); }
        .room-pill.off { background:rgba(0,0,0,.18); }
        .room-body { padding:1.1rem; flex:1; }
        .room-cap { font-size:1.9rem; font-weight:800; color:var(--lc-navy); line-height:1; }
        .room-cap small { font-size:.8rem; font-weight:600; color:var(--lc-muted); }
        .room-foot { padding:.85rem 1.1rem; border-top:1px solid var(--lc-border); display:flex; gap:.5rem; }
        .add-room-card { border:2px dashed #cdd6e6; border-radius:14px; background:var(--lc-light); display:flex; flex-direction:column; align-items:center; justify-content:center; min-height:220px; color:var(--lc-primary); cursor:pointer; transition:all .15s ease; height:100%; }
        .add-room-card:hover { border-color:var(--lc-primary); background:#e7efff; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="halls"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <div class="text-muted small mb-1">Dashboard / <span class="fw-semibold">Rooms &amp; Seats</span></div>
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="text-navy fw-bold mb-0">Room Management
                <c:if test="${not empty sessionScope.currentBranchName}">
                    &middot; <c:out value="${sessionScope.currentBranchName}"/></c:if></h4>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                <i class="bi bi-plus-circle me-1"></i>Add Room</button>
        </div>

        <div class="lc-scope mb-3">
            <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
            <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}"/></strong>
                &mdash; you only see data for your assigned branch.</span>
        </div>

        <div class="text-muted small mb-3">Total ${fn:length(rooms)} room(s) in this branch</div>

        <c:if test="${not empty successMsg}"><div class="alert alert-success py-2">${successMsg}</div></c:if>
        <c:if test="${not empty errorMsg}"><div class="alert alert-danger py-2">${errorMsg}</div></c:if>

        <div class="row g-3">
            <c:forEach items="${rooms}" var="room">
                <div class="col-md-6 col-xl-4">
                    <div class="room-card">
                        <div class="room-top ${room.roomType == 'VIP' ? 't-vip' : (room.roomType == 'IMAX' ? 't-imax' : 't-standard')}">
                            <div>
                                <div class="rt-name"><c:out value="${room.name}"/></div>
                                <div class="rt-type">${room.roomType}</div>
                            </div>
                            <span class="room-pill ${room.active ? '' : 'off'}">
                                <i class="bi ${room.active ? 'bi-check-circle' : 'bi-slash-circle'} me-1"></i>${room.active ? 'Active' : 'Inactive'}</span>
                        </div>
                        <div class="room-body">
                            <div class="room-cap">${room.capacity} <small>seats</small></div>
                            <div class="text-muted small mt-2">
                                <i class="bi bi-info-circle me-1"></i>Capacity is auto-calculated from the seat layout.</div>
                        </div>
                        <div class="room-foot">
                            <button class="btn btn-light border btn-sm flex-fill edit-btn"
                                    data-id="${room.roomId}" data-name="${room.name}"
                                    data-capacity="${room.capacity}" data-type="${room.roomType}"
                                    data-bs-toggle="modal" data-bs-target="#editRoomModal">
                                <i class="bi bi-pencil me-1"></i>Edit</button>
                            <a class="btn btn-primary btn-sm flex-fill"
                               href="${pageContext.request.contextPath}/branch/seats?roomId=${room.roomId}">
                                <i class="bi bi-grid-3x3-gap me-1"></i>Seats</a>
                            <form method="post" action="${pageContext.request.contextPath}/branch/halls" class="d-inline">
                                <input type="hidden" name="action" value="toggleStatus">
                                <input type="hidden" name="roomId" value="${room.roomId}">
                                <input type="hidden" name="active" value="${!room.active}">
                                <button type="submit" class="btn btn-light border btn-sm" title="${room.active ? 'Disable' : 'Enable'}">
                                    <i class="bi ${room.active ? 'bi-toggle-on text-success' : 'bi-toggle-off text-muted'}"></i></button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <%-- Add new room card --%>
            <div class="col-md-6 col-xl-4">
                <div class="add-room-card" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                    <i class="bi bi-plus-circle fs-1 mb-2"></i>
                    <div class="fw-semibold">Add new room</div>
                    <div class="small text-muted">Configure seats afterwards</div>
                </div>
            </div>
        </div>

        <div class="alert alert-light border mt-3 small text-muted">
            <i class="bi bi-info-circle me-1 text-primary"></i>
            <strong>Capacity is auto-calculated.</strong> The seat count on each room is derived from the seats
            configured in the Seat Layout editor. To change capacity, edit the seat grid.
        </div>
    </div>
</main>

<%-- ADD MODAL --%>
<div class="modal fade" id="addRoomModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="${pageContext.request.contextPath}/branch/halls">
            <input type="hidden" name="action" value="add">
            <div class="modal-header"><h5 class="modal-title">Add Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold small">Room Name</label>
                    <input type="text" class="form-control" name="name" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Capacity</label>
                    <input type="number" class="form-control" name="capacity" min="1" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Room Type</label>
                    <select class="form-select" name="roomType">
                        <option value="STANDARD">STANDARD</option>
                        <option value="VIP">VIP</option>
                        <option value="IMAX">IMAX</option></select></div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline-secondary" data-bs-dismiss="modal" type="button">Cancel</button>
                <button class="btn btn-primary" type="submit">Save</button>
            </div>
        </form>
    </div>
</div>

<%-- EDIT MODAL --%>
<div class="modal fade" id="editRoomModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="${pageContext.request.contextPath}/branch/halls">
            <input type="hidden" name="action" value="edit">
            <input type="hidden" id="editRoomId" name="roomId">
            <div class="modal-header"><h5 class="modal-title">Edit Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold small">Room Name</label>
                    <input type="text" class="form-control" id="editName" name="name" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Capacity</label>
                    <input type="number" class="form-control" id="editCapacity" name="capacity" min="1" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Room Type</label>
                    <select class="form-select" id="editType" name="roomType">
                        <option value="STANDARD">STANDARD</option>
                        <option value="VIP">VIP</option>
                        <option value="IMAX">IMAX</option></select></div>
            </div>
            <div class="modal-footer">
                <button class="btn btn-outline-secondary" data-bs-dismiss="modal" type="button">Cancel</button>
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
            document.getElementById('editCapacity').value = this.dataset.capacity;
            document.getElementById('editType').value = this.dataset.type;
        });
    });
</script>
</body>
</html>
