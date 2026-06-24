<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hall Management</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}"
          rel="stylesheet">
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="halls"/>
</jsp:include>

<main class="lc-admin-main">

<div class="container-fluid px-4 py-4">
    

    <div class="d-flex justify-content-between align-items-center mb-4">

    <div class="d-flex align-items-center gap-3">

        <c:if test="${not empty selectedBranchId}">

            <a href="${pageContext.request.contextPath}/admin/branches"
               class="btn btn-outline-secondary">

                <i class="bi bi-arrow-left"></i>
                Back to Cinemas

            </a>

        </c:if>

        <div>

            <div class="text-muted small">
                Administration
            </div>

            <h4 class="fw-bold text-navy mb-0">
                Hall Management
            </h4>

        </div>

    </div>

    <button class="btn btn-primary"
            data-bs-toggle="modal"
            data-bs-target="#addRoomModal">

        <i class="bi bi-plus-circle me-1"></i>
        Add Hall

    </button>

</div>
    

    <!-- Alerts -->

    <c:if test="${not empty successMsg}">
        <div class="alert alert-success alert-dismissible fade show">
            ${successMsg}
            <button class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger alert-dismissible fade show">
            ${errorMsg}
            <button class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <!-- Branch Filter -->

    <div class="card lc-elev mb-4">
        <div class="card-body">

            <form method="get"
                  action="${pageContext.request.contextPath}/admin/halls">

                <div class="row">

                    <div class="col-md-4">

                        <select name="branchId"
                                class="form-select">

                            <option value="">
                                All Branches
                            </option>

                            <c:forEach items="${branches}" var="b">

                                <option value="${b.branchId}"
                                    ${selectedBranchId == b.branchId ? 'selected' : ''}>

                                    ${b.name}

                                </option>

                            </c:forEach>

                        </select>

                    </div>

                    <div class="col-md-2">

                        <button class="btn btn-primary">
                            Filter
                        </button>

                    </div>

                </div>

            </form>

        </div>
    </div>

    <!-- Room Table -->

    <div class="card lc-elev">

        <div class="card-body">

            <div class="table-responsive">

                <table class="table table-hover align-middle">

                    <thead>

                    <tr>

                        <th>ID</th>
                        <th>Name</th>
                        <th>Branch ID</th>
                        <th>Capacity</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th width="320">Actions</th>

                    </tr>

                    </thead>

                    <tbody>

                    <c:forEach items="${rooms}" var="room">

                        <tr>

                            <td>${room.roomId}</td>

                            <td>
                                <strong>${room.name}</strong>
                            </td>

                            <td>${room.branchId}</td>

                            <td>${room.capacity}</td>

                            <td>

                                <c:choose>

                                    <c:when test="${room.roomType=='VIP'}">
                                        <span class="badge bg-warning text-dark">
                                            VIP
                                        </span>
                                    </c:when>

                                    <c:when test="${room.roomType=='IMAX'}">
                                        <span class="badge bg-info">
                                            IMAX
                                        </span>
                                    </c:when>

                                    <c:otherwise>
                                        <span class="badge bg-secondary">
                                            STANDARD
                                        </span>
                                    </c:otherwise>

                                </c:choose>

                            </td>

                            <td>

                                <c:choose>

                                    <c:when test="${room.active}">
                                        <span class="badge bg-success">
                                            Active
                                        </span>
                                    </c:when>

                                    <c:otherwise>
                                        <span class="badge bg-secondary">
                                            Inactive
                                        </span>
                                    </c:otherwise>

                                </c:choose>

                            </td>

                            <td>

                                <a href="${pageContext.request.contextPath}/admin/seats?roomId=${room.roomId}"
                                   class="btn btn-sm btn-primary">

                                    <i class="bi bi-grid-3x3-gap"></i>
                                    Seats

                                </a>

                                <button
                                        class="btn btn-sm btn-warning edit-btn"

                                        data-id="${room.roomId}"
                                        data-name="${room.name}"
                                        data-capacity="${room.capacity}"
                                        data-type="${room.roomType}"

                                        data-bs-toggle="modal"
                                        data-bs-target="#editRoomModal">

                                    <i class="bi bi-pencil"></i>

                                </button>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/admin/halls"
                                      style="display:inline;">

                                    <input type="hidden"
                                           name="action"
                                           value="toggleStatus">

                                    <input type="hidden"
                                           name="roomId"
                                           value="${room.roomId}">

                                    <input type="hidden"
                                           name="active"
                                           value="${!room.active}">

                                    <button type="submit"
                                            class="btn btn-sm btn-secondary">

                                        <c:choose>

                                            <c:when test="${room.active}">
                                                Disable
                                            </c:when>

                                            <c:otherwise>
                                                Enable
                                            </c:otherwise>

                                        </c:choose>

                                    </button>

                                </form>

                                <form method="post"
                                      action="${pageContext.request.contextPath}/admin/halls"
                                      style="display:inline;"
                                      onsubmit="return confirm('Delete this room?');">

                                    <input type="hidden"
                                           name="action"
                                           value="delete">

                                    <input type="hidden"
                                           name="roomId"
                                           value="${room.roomId}">

                                    <button type="submit"
                                            class="btn btn-sm btn-danger">

                                        <i class="bi bi-trash"></i>

                                    </button>

                                </form>

                            </td>

                        </tr>

                    </c:forEach>

                    </tbody>

                </table>

            </div>

        </div>

    </div>

</div>

</main>

<!-- ADD ROOM MODAL -->

<div class="modal fade" id="addRoomModal">
    <div class="modal-dialog">
        <div class="modal-content">

            <form method="post"
                  action="${pageContext.request.contextPath}/admin/halls">

                <input type="hidden" name="action" value="add">

                <div class="modal-header">
                    <h5 class="modal-title">
                        Add Hall
                    </h5>
                </div>

                <div class="modal-body">

                    <div class="mb-3">

                        <label>Branch</label>

                        <select name="branchId"
                                class="form-select"
                                required>

                            <c:forEach items="${branches}" var="b">

                                <option value="${b.branchId}">
                                    ${b.name}
                                </option>

                            </c:forEach>

                        </select>

                    </div>

                    <div class="mb-3">
                        <label>Name</label>
                        <input class="form-control"
                               name="name"
                               required>
                    </div>

                    <div class="mb-3">
                        <label>Capacity</label>
                        <input type="number"
                               min="1"
                               class="form-control"
                               name="capacity"
                               required>
                    </div>

                    <div class="mb-3">

                        <label>Room Type</label>

                        <select class="form-select"
                                name="roomType">

                            <option value="STANDARD">
                                STANDARD
                            </option>

                            <option value="VIP">
                                VIP
                            </option>

                            <option value="IMAX">
                                IMAX
                            </option>

                        </select>

                    </div>

                </div>

                <div class="modal-footer">

                    <button type="button"
                            class="btn btn-secondary"
                            data-bs-dismiss="modal">

                        Cancel

                    </button>

                    <button class="btn btn-primary"
                            type="submit">

                        Save

                    </button>

                </div>

            </form>

        </div>
    </div>
</div>

<!-- EDIT ROOM MODAL -->

<div class="modal fade" id="editRoomModal">

    <div class="modal-dialog">

        <div class="modal-content">

            <form method="post"
                  action="${pageContext.request.contextPath}/admin/halls">

                <input type="hidden"
                       name="action"
                       value="edit">

                <input type="hidden"
                       id="editRoomId"
                       name="roomId">

                <div class="modal-header">
                    <h5 class="modal-title">
                        Edit Hall
                    </h5>
                </div>

                <div class="modal-body">

                    <div class="mb-3">
                        <label>Name</label>
                        <input id="editName"
                               class="form-control"
                               name="name"
                               required>
                    </div>

                    <div class="mb-3">
                        <label>Capacity</label>
                        <input id="editCapacity"
                               type="number"
                               min="1"
                               class="form-control"
                               name="capacity"
                               required>
                    </div>

                    <div class="mb-3">

                        <label>Room Type</label>

                        <select id="editType"
                                class="form-select"
                                name="roomType">

                            <option value="STANDARD">STANDARD</option>
                            <option value="VIP">VIP</option>
                            <option value="IMAX">IMAX</option>

                        </select>

                    </div>

                </div>

                <div class="modal-footer">

                    <button class="btn btn-secondary"
                            type="button"
                            data-bs-dismiss="modal">

                        Cancel

                    </button>

                    <button class="btn btn-primary"
                            type="submit">

                        Update

                    </button>

                </div>

            </form>

        </div>

    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>

document.querySelectorAll('.edit-btn')
.forEach(btn => {

    btn.addEventListener('click', function(){

        document.getElementById('editRoomId').value =
            this.dataset.id;

        document.getElementById('editName').value =
            this.dataset.name;

        document.getElementById('editCapacity').value =
            this.dataset.capacity;

        document.getElementById('editType').value =
            this.dataset.type;

    });

});

</script>

</body>
</html>