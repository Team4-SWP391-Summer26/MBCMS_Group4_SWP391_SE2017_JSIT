<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%-- Room management (Branch Manager) - card layout theo mockup 24_mgr-rooms. --%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Rooms &amp; Seats - PentaPlex Manager</title>
    <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="rooms"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Dashboard / <strong>Rooms &amp; Seats</strong></div>
                <h1 class="lc-page-title">Room Management
                    <c:if test="${not empty sessionScope.currentBranchName}">
                        &middot; <c:out value="${sessionScope.currentBranchName}"/></c:if></h1>
            </div>
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
                <c:set var="tcls" value="${room.roomType == 'VIP' ? 't-vip' : (room.roomType == 'IMAX' ? 't-imax' : 't-standard')}"/>
                <c:set var="tbcls" value="${room.roomType == 'VIP' ? 'tb-vip' : (room.roomType == 'IMAX' ? 'tb-imax' : 'tb-standard')}"/>
                <div class="col-sm-6 col-lg-4 col-xl-3">
                    <div class="room-card">
                        <div class="room-head ${room.active ? tcls : 't-off'}">
                            <div>
                                <div class="nm"><i class="bi bi-easel2-fill"></i><c:out value="${room.name}"/></div>
                                <div class="ty">${room.roomType}</div>
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
                                <i class="bi bi-info-circle me-1"></i>Auto-calculated from the seat layout</div>
                        </div>
                        <div class="room-actrow">
                            <span class="fw-semibold small text-navy">Active</span>
                            <form method="post" action="${pageContext.request.contextPath}/branch/halls">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <input type="hidden" name="action" value="toggleStatus">
                                <input type="hidden" name="roomId" value="${room.roomId}">
                                <input type="hidden" name="active" value="${!room.active}">
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
                            <a class="btn btn-primary btn-sm flex-fill"
                               href="${pageContext.request.contextPath}/branch/seats?roomId=${room.roomId}">
                                <i class="bi bi-grid-3x3-gap me-1"></i>Seats</a>
                        </div>
                    </div>
                </div>
            </c:forEach>

            <%-- Add new room card --%>
            <div class="col-sm-6 col-lg-4 col-xl-3">
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
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="add">
            <div class="modal-header"><h5 class="modal-title">Add Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold small">Room Name</label>
                    <input type="text" class="form-control" name="name" required></div>
                <div class="mb-3"><label class="form-label fw-semibold small">Initial capacity</label>
                    <input type="number" class="form-control" name="capacity" min="1" max="260" required></div>
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
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="edit">
            <input type="hidden" id="editRoomId" name="roomId">
            <div class="modal-header"><h5 class="modal-title">Edit Room</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button></div>
            <div class="modal-body">
                <div class="mb-3"><label class="form-label fw-semibold small">Room Name</label>
                    <input type="text" class="form-control" id="editName" name="name" required></div>
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

<%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
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
