<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Hall Management - PentaPlex Admin</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">Admin / Cinemas / <strong>Rooms</strong></div>
                <h1 class="lc-page-title">Room Management</h1>
            </div>
        </div>

        <c:if test="${not empty successMsg}"><div class="alert alert-success py-2 alert-dismissible fade show">${successMsg}<button class="btn-close" data-bs-dismiss="alert"></button></div></c:if>
        <c:if test="${not empty errorMsg}"><div class="alert alert-danger py-2 alert-dismissible fade show">${errorMsg}<button class="btn-close" data-bs-dismiss="alert"></button></div></c:if>

        <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
            <form method="get" action="${pageContext.request.contextPath}/admin/halls" class="st-toolbar-track w-100">
                <label class="fw-semibold small text-muted mb-0 text-nowrap">Cinema:</label>
                <select name="branchId" class="st-toolbar-select" style="max-width:320px;" onchange="this.form.submit()" aria-label="Filter by cinema">
                    <option value="">All cinemas</option>
                    <c:forEach items="${branches}" var="b">
                        <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.name}"/></option>
                    </c:forEach>
                </select>
                <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                <span class="text-muted small text-nowrap">${fn:length(rooms)} room(s)</span>
                <button type="button" class="st-toolbar-add border-0" data-bs-toggle="modal" data-bs-target="#addRoomModal">
                    <i class="bi bi-plus-lg" aria-hidden="true"></i> Add Room</button>
            </form>
        </div>

        <div class="row g-3">
            <c:forEach items="${rooms}" var="room" varStatus="rs">
                <c:set var="tcls" value="${room.roomType == 'VIP' ? 't-vip' : (room.roomType == 'IMAX' ? 't-imax' : 't-standard')}"/>
                <div class="col-sm-6 col-lg-4 col-xl-3">
                    <div class="room-card lc-rise" style="--i:${rs.index};">
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
                <div class="add-room-card lc-rise" style="--i:${fn:length(rooms)};" data-bs-toggle="modal" data-bs-target="#addRoomModal">
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
                <div class="mb-3"><label class="lc-form-label">Cinema</label>
                    <select name="branchId" class="form-select" required>
                        <c:forEach items="${branches}" var="b">
                            <option value="${b.branchId}" ${selectedBranchId == b.branchId ? 'selected' : ''}><c:out value="${b.name}"/></option>
                        </c:forEach>
                    </select></div>
                <div class="mb-3"><label class="lc-form-label">Room name</label>
                    <input class="form-control" name="name" required></div>
                <div class="mb-3"><label class="lc-form-label">Initial capacity</label>
                    <input type="number" min="1" max="260" class="form-control" name="capacity" required>
                    <div class="form-text">Max 260 for new rooms. Change layout later via Seats.</div></div>
                <div class="mb-3"><label class="lc-form-label">Room type</label>
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
                <div class="mb-3"><label class="lc-form-label">Room name</label>
                    <input id="editName" class="form-control" name="name" required></div>
                <div class="mb-3"><label class="lc-form-label">Room type</label>
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

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
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
