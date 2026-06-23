<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Seat Layout Management</title>

```
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

<link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}"
      rel="stylesheet">

<style>

    .screen {
        background: #1e293b;
        color: white;
        text-align: center;
        padding: 12px;
        border-radius: 10px;
        margin-bottom: 30px;
        font-weight: 600;
        letter-spacing: 2px;
    }

    .seat-row {
        display: flex;
        align-items: center;
        margin-bottom: 10px;
        gap: 8px;
    }

    .row-label {
        width: 40px;
        font-weight: bold;
        color: #334155;
    }

    .seat-btn {
        min-width: 55px;
        height: 42px;
        border: none;
        border-radius: 8px;
        color: white;
        font-size: 12px;
        cursor: pointer;
        transition: .2s;
    }

    .seat-btn:hover {
        transform: scale(1.05);
    }

    .seat-standard {
        background: #0d6efd;
    }

    .seat-vip {
        background: #ffc107;
        color: #000;
    }

    .seat-disabled {
        background: #6c757d;
    }

    .legend-box{
        width:20px;
        height:20px;
        border-radius:4px;
        display:inline-block;
        margin-right:6px;
    }

</style>
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
        <div class="text-muted small">Seat Layout</div>

        <h4 class="fw-bold text-navy mb-0">
            ${room.name}
        </h4>

        <small class="text-muted">
            Capacity: ${room.capacity}
            |
            Type: ${room.roomType}
        </small>
    </div>

    <a href="${pageContext.request.contextPath}/branch/halls"
       class="btn btn-outline-secondary">

        <i class="bi bi-arrow-left"></i>
        Back

    </a>

</div>

<c:if test="${not empty successMsg}">
    <div class="alert alert-success">
        ${successMsg}
    </div>
</c:if>

<c:if test="${not empty errorMsg}">
    <div class="alert alert-danger">
        ${errorMsg}
    </div>
</c:if>

<!-- REGENERATE -->

<div class="card lc-elev mb-4">

    <div class="card-header">
        <strong>Regenerate Seat Layout</strong>
    </div>

    <div class="card-body">

        <form method="post"
              action="${pageContext.request.contextPath}/branch/seats">

            <input type="hidden"
                   name="action"
                   value="regenerate">

            <input type="hidden"
                   name="roomId"
                   value="${roomId}">

            <div class="row">

                <div class="col-md-3">

                    <label class="form-label">
                        Rows
                    </label>

                    <input type="number"
                           class="form-control"
                           name="rowsCount"
                           required>

                </div>

                <div class="col-md-3">

                    <label class="form-label">
                        Columns
                    </label>

                    <input type="number"
                           class="form-control"
                           name="colsCount"
                           required>

                </div>

                <div class="col-md-3">

                    <label class="form-label">
                        Default Type
                    </label>

                    <select class="form-select"
                            name="defaultType">

                        <option value="STANDARD">
                            STANDARD
                        </option>

                        <option value="VIP">
                            VIP
                        </option>

                    </select>

                </div>

                <div class="col-md-3 d-flex align-items-end">

                    <button type="submit"
                            class="btn btn-primary w-100"
                            onclick="return confirm('Regenerate layout? Existing seats will be replaced.')">

                        Regenerate

                    </button>

                </div>

            </div>

        </form>

    </div>

</div>

<!-- LEGEND -->

<div class="card lc-elev mb-4">

    <div class="card-body">

        <div class="d-flex gap-4">

            <div>
                <span class="legend-box bg-primary"></span>
                Standard
            </div>

            <div>
                <span class="legend-box bg-warning"></span>
                VIP
            </div>

            <div>
                <span class="legend-box bg-secondary"></span>
                Disabled
            </div>

        </div>

    </div>

</div>

<!-- SEAT MAP -->

<div class="card lc-elev">

    <div class="card-body">

        <div class="screen">
            SCREEN
        </div>

        <c:forEach var="row" items="${seatsByRow}">

            <div class="seat-row">

                <div class="row-label">
                    ${row.key}
                </div>

                <c:forEach var="seat" items="${row.value}">

                    <button type="button"
                            class="seat-btn
                            ${!seat.active ? 'seat-disabled' :
                               (seat.seatType == 'VIP' ? 'seat-vip' : 'seat-standard')}"
                            data-seatid="${seat.seatId}"
                            data-type="${seat.seatType}"
                            data-active="${seat.active}"

                            onclick="showSeatMenu(this)">

                        ${seat.rowLabel}${seat.colNumber}

                    </button>

                </c:forEach>

            </div>

        </c:forEach>

    </div>

</div>
```

</div>

</main>

<!-- MODAL -->

<div class="modal fade" id="seatModal">

```
<div class="modal-dialog">

    <div class="modal-content">

        <div class="modal-header">

            <h5 class="modal-title">
                Seat Configuration
            </h5>

        </div>

        <div class="modal-body">

            <input type="hidden" id="seatId">

            <div class="mb-3">

                <label class="form-label">
                    Seat Type
                </label>

                <select id="seatType"
                        class="form-select">

                    <option value="STANDARD">
                        STANDARD
                    </option>

                    <option value="VIP">
                        VIP
                    </option>

                </select>

            </div>

            <div class="form-check">

                <input class="form-check-input"
                       type="checkbox"
                       id="seatActive">

                <label class="form-check-label">
                    Active
                </label>

            </div>

        </div>

        <div class="modal-footer">

            <button class="btn btn-secondary"
                    data-bs-dismiss="modal">
                Close
            </button>

            <button class="btn btn-primary"
                    onclick="saveSeat()">

                Save

            </button>

        </div>

    </div>

</div>
```

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<script>

let seatModal =
    new bootstrap.Modal(document.getElementById('seatModal'));

function showSeatMenu(btn){

    document.getElementById('seatId').value =
        btn.dataset.seatid;

    document.getElementById('seatType').value =
        btn.dataset.type;

    document.getElementById('seatActive').checked =
        btn.dataset.active === 'true';

    seatModal.show();
}

async function saveSeat(){

    const seatId =
        document.getElementById('seatId').value;

    const seatType =
        document.getElementById('seatType').value;

    const active =
        document.getElementById('seatActive').checked;

    try{

        let response1 =
            await fetch(
                '${pageContext.request.contextPath}/branch/seats',
                {
                    method:'POST',
                    headers:{
                        'Content-Type':
                            'application/x-www-form-urlencoded'
                    },
                    body:
                        'action=updateSeat'
                        +'&roomId=${roomId}'
                        +'&seatId='+seatId
                        +'&seatType='+seatType
                });

        let json1 = await response1.json();

        if(!json1.success){
            alert(json1.message);
            return;
        }

        let response2 =
            await fetch(
                '${pageContext.request.contextPath}/branch/seats',
                {
                    method:'POST',
                    headers:{
                        'Content-Type':
                            'application/x-www-form-urlencoded'
                    },
                    body:
                        'action=updateSeat'
                        +'&roomId=${roomId}'
                        +'&seatId='+seatId
                        +'&active='+active
                });

        let json2 = await response2.json();

        if(!json2.success){
            alert(json2.message);
            return;
        }

        location.reload();

    }catch(e){

        alert('Update failed');

    }
}

</script>

</body>
</html>
