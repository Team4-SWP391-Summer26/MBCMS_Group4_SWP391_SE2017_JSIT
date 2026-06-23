<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Manage Halls</title>

```
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
<link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
```

</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
<jsp:param name="active" value="halls"/>
</jsp:include>

<main class="lc-admin-main">

<div class="container-fluid px-4 py-4">

```
<div class="d-flex justify-content-between align-items-center mb-4">
    <div>
        <div class="text-muted small">Branch Management</div>
        <h4 class="fw-bold text-navy mb-0">Cinema Halls</h4>
    </div>

    <button class="btn btn-primary"
            data-bs-toggle="modal"
            data-bs-target="#addRoomModal">
        <i class="bi bi-plus-circle me-1"></i>
        Add Hall
    </button>
</div>

<c:if test="${not empty successMsg}">
    <div class="alert alert-success">${successMsg}</div>
</c:if>

<c:if test="${not empty errorMsg}">
    <div class="alert alert-danger">${errorMsg}</div>
</c:if>

<div class="card lc-elev">

    <div class="card-body">

        <div class="table-responsive">

            <table class="table table-hover align-middle">

                <thead>
                <tr>
                    <th>ID</th>
                    <th>Hall Name</th>
                    <th>Type</th>
                    <th>Capacity</th>
                    <th>Status</th>
                    <th width="260">Actions</th>
                </tr>
                </thead>

                <tbody>

                <c:forEach items="${rooms}" var="room">

                    <tr>

                        <td>${room.roomId}</td>

                        <td>
                            <strong>${room.name}</strong>
                        </td>

                        <td>
                            <span class="badge bg-info">
                                ${room.roomType}
                            </span>
                        </td>

                        <td>${room.capacity}</td>

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

                            <a class="btn btn-sm btn-outline-primary"
                               href="${pageContext.request.contextPath}/branch/seats?roomId=${room.roomId}">
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
                                  action="${pageContext.request.contextPath}/branch/halls"
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
                                  action="${pageContext.request.contextPath}/branch/halls"
                                  style="display:inline;"
                                  onsubmit="return confirm('Delete this hall?');">

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
```

</div>

</main>

<!-- ADD MODAL -->

<div class="modal fade" id="addRoomModal">

```
<div class="modal-dialog">

    <div class="modal-content">

        <form method="post"
              action="${pageContext.request.contextPath}/branch/halls">

            <input type="hidden"
                   name="action"
                   value="add">

            <div class="modal-header">
                <h5 class="modal-title">Add Hall</h5>
            </div>

            <div class="modal-body">

                <div class="mb-3">
                    <label class="form-label">Hall Name</label>
                    <input type="text"
                           class="form-control"
                           name="name"
                           required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Capacity</label>
                    <input type="number"
                           class="form-control"
                           name="capacity"
                           min="1"
                           required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Room Type</label>

                    <select class="form-select"
                            name="roomType">

                        <option value="STANDARD">STANDARD</option>
                        <option value="VIP">VIP</option>
                        <option value="IMAX">IMAX</option>

                    </select>

                </div>

            </div>

            <div class="modal-footer">

                <button class="btn btn-secondary"
                        data-bs-dismiss="modal"
                        type="button">
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
```

</div>

<!-- EDIT MODAL -->

<div class="modal fade" id="editRoomModal">

```
<div class="modal-dialog">

    <div class="modal-content">

        <form method="post"
              action="${pageContext.request.contextPath}/branch/halls">

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
                    <label class="form-label">Hall Name</label>
                    <input type="text"
                           class="form-control"
                           id="editName"
                           name="name"
                           required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Capacity</label>
                    <input type="number"
                           class="form-control"
                           id="editCapacity"
                           name="capacity"
                           min="1"
                           required>
                </div>

                <div class="mb-3">
                    <label class="form-label">Room Type</label>

                    <select class="form-select"
                            id="editType"
                            name="roomType">

                        <option value="STANDARD">STANDARD</option>
                        <option value="VIP">VIP</option>
                        <option value="IMAX">IMAX</option>

                    </select>

                </div>

            </div>

            <div class="modal-footer">

                <button class="btn btn-secondary"
                        data-bs-dismiss="modal"
                        type="button">
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
```

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>

document.querySelectorAll('.edit-btn').forEach(btn => {

    btn.addEventListener('click', function () {

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
