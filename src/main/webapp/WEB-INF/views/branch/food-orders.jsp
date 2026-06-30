<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ page import="java.util.List, java.util.Map" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Food & Drinks Fulfillments - MBCMS Staff</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            .status-badge {
                padding: 0.35em 0.65em;
                font-weight: 600;
                font-size: 0.78rem;
                border-radius: 9999px;
            }
            .status-pending { background-color: #fef3c7; color: #d97706; }
            .status-preparing { background-color: var(--primary-100); color: var(--primary); }
            .status-ready { background-color: #d1fae5; color: #059669; }
            .status-delivered { background-color: #f3f4f6; color: #4b5563; }

            .order-item-list {
                margin: 0;
                padding-left: 1rem;
            }
            .order-item-list li {
                font-size: 0.9rem;
            }
            .search-box {
                max-width: 350px;
            }
            .filter-btn.active {
                background-color: var(--lc-primary) !important;
                color: #fff !important;
                border-color: var(--lc-primary) !important;
            }
        </style>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
            <jsp:param name="active" value="food-orders" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1200px;">

                <%-- ===== Page Header ===== --%>
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
                    <div>
                        <div class="text-muted small mb-1">Counter Operations</div>
                        <h4 class="text-navy fw-bold mb-0">Food &amp; Drinks Fulfillments</h4>
                    </div>
                    <div class="lc-sb-user d-flex align-items-center gap-2 px-3 py-1 text-navy border rounded" style="background:#fff;">
                        <i class="bi bi-geo-alt-fill text-primary"></i>
                        <span>Branch: <strong><c:out value="${sessionScope.currentBranchName}" /></strong></span>
                    </div>
                </div>

                <%-- ===== Toast Notification ===== --%>
                <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
                    <div id="statusToast" class="toast align-items-center text-white bg-success border-0" role="alert" aria-live="assertive" aria-atomic="true">
                        <div class="d-flex">
                            <div class="toast-body" id="toastMessage">
                                Status updated successfully.
                            </div>
                            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                        </div>
                    </div>
                </div>

                <%-- ===== Helper Scriptlet to Format Dates ===== --%>
                <%
                    List<com.mbcms.model.FoodOrderDetail> ordersList = (List<com.mbcms.model.FoodOrderDetail>) request.getAttribute("orders");
                    Map<Long, String> formattedCreatedDates = new java.util.HashMap<>();
                    Map<Long, String> formattedReadyDates = new java.util.HashMap<>();
                    Map<Long, String> formattedDeliveredDates = new java.util.HashMap<>();
                    
                    java.time.format.DateTimeFormatter dtf = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
                    
                    if (ordersList != null) {
                        for (com.mbcms.model.FoodOrderDetail ord : ordersList) {
                            if (ord.getCreatedAt() != null) {
                                formattedCreatedDates.put(ord.getFoodOrderId(), ord.getCreatedAt().format(dtf));
                            }
                            if (ord.getReadyAt() != null) {
                                formattedReadyDates.put(ord.getFoodOrderId(), ord.getReadyAt().format(dtf));
                            }
                            if (ord.getDeliveredAt() != null) {
                                formattedDeliveredDates.put(ord.getFoodOrderId(), ord.getDeliveredAt().format(dtf));
                            }
                        }
                    }
                    pageContext.setAttribute("formattedCreatedDates", formattedCreatedDates);
                    pageContext.setAttribute("formattedReadyDates", formattedReadyDates);
                    pageContext.setAttribute("formattedDeliveredDates", formattedDeliveredDates);
                %>

                <%-- ===== Filters and Search ===== --%>
                <div class="card lc-elev p-3 mb-4">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                        <div class="d-flex gap-2 flex-wrap" id="statusFilters">
                            <button type="button" class="btn btn-outline-secondary btn-sm filter-btn active" onclick="filterStatus('ALL')">All</button>
                            <button type="button" class="btn btn-outline-warning btn-sm filter-btn" onclick="filterStatus('PENDING')">Pending Payment</button>
                            <button type="button" class="btn btn-outline-primary btn-sm filter-btn" onclick="filterStatus('PREPARING')">Preparing</button>
                            <button type="button" class="btn btn-outline-success btn-sm filter-btn" onclick="filterStatus('READY')">Ready for Pickup</button>
                            <button type="button" class="btn btn-outline-dark btn-sm filter-btn" onclick="filterStatus('DELIVERED')">Delivered</button>
                        </div>
                        <div class="search-box input-group">
                            <span class="input-group-text"><i class="bi bi-search"></i></span>
                            <input type="text" id="orderSearch" class="form-control form-control-sm" placeholder="Search by Booking Code..." onkeyup="searchOrders()">
                        </div>
                    </div>
                </div>

                <%-- ===== Orders Table ===== --%>
                <div class="card lc-elev p-0 overflow-hidden">
                    <div class="table-responsive">
                        <table class="table lc-table align-middle mb-0" id="ordersTable">
                            <thead>
                                <tr>
                                    <th class="ps-3" style="width: 15%;">Order &amp; Booking</th>
                                    <th style="width: 15%;">Time</th>
                                    <th style="width: 25%;">Customer &amp; Showtime context</th>
                                    <th style="width: 20%;">Concessions Ordered</th>
                                    <th style="width: 10%;">Status</th>
                                    <th class="text-end pe-3" style="width: 15%;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty orders}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-5">
                                                <i class="bi bi-inbox fs-2 d-block mb-2"></i>
                                                No concession orders found.
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="ord" items="${orders}">
                                            <tr data-status="${ord.status}" data-booking-code="${ord.bookingCode}">
                                                <td class="ps-3">
                                                    <div class="fw-bold text-navy">Order #${ord.foodOrderId}</div>
                                                    <div class="small text-muted mt-1">
                                                        Booking: <span class="font-monospace fw-bold text-primary">${ord.bookingCode}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="small text-navy fw-semibold">${formattedCreatedDates[ord.foodOrderId]}</div>
                                                </td>
                                                <td>
                                                    <div class="fw-semibold text-navy small">${ord.customerName}</div>
                                                    <div class="small text-muted mt-1">
                                                        <i class="bi bi-film me-1"></i> <c:out value="${ord.movieTitle}" /><br>
                                                        <i class="bi bi-door-closed me-1"></i> Room: ${ord.roomName} &middot; Showtime: ${ord.startTime}
                                                    </div>
                                                </td>
                                                <td>
                                                    <ul class="order-item-list">
                                                        <c:forEach var="item" items="${ord.items}">
                                                            <li>
                                                                <c:out value="${item.key}"/> <strong class="text-primary">x${item.value}</strong>
                                                            </li>
                                                        </c:forEach>
                                                    </ul>
                                                </td>
                                                <td id="status-cell-${ord.foodOrderId}">
                                                    <c:choose>
                                                        <c:when test="${ord.status == 'PENDING'}">
                                                            <span class="status-badge status-pending">Pending Payment</span>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'PREPARING'}">
                                                            <span class="status-badge status-preparing">Preparing</span>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'READY'}">
                                                            <span class="status-badge status-ready">Ready for Pickup</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="status-badge status-delivered">Delivered</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end pe-3" id="action-cell-${ord.foodOrderId}">
                                                    <c:choose>
                                                        <c:when test="${ord.status == 'PENDING'}">
                                                            <button type="button" class="btn btn-warning btn-sm fw-semibold w-100" onclick="updateStatus(${ord.foodOrderId}, 'PREPARING')">
                                                                <i class="bi bi-cash me-1"></i>Pay &amp; Prepare
                                                            </button>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'PREPARING'}">
                                                            <button type="button" class="btn btn-primary btn-sm fw-semibold w-100" onclick="updateStatus(${ord.foodOrderId}, 'READY')">
                                                                <i class="bi bi-check2-circle me-1"></i>Mark Ready
                                                            </button>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'READY'}">
                                                            <button type="button" class="btn btn-success btn-sm fw-semibold w-100" onclick="updateStatus(${ord.foodOrderId}, 'DELIVERED')">
                                                                <i class="bi bi-mailbox me-1"></i>Deliver
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="text-success small fw-semibold text-center">
                                                                <i class="bi bi-check-all me-1"></i>Delivered<br>
                                                                <span class="text-muted" style="font-size: 0.72rem;">${formattedDeliveredDates[ord.foodOrderId]}</span>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let currentFilter = 'ALL';

            function filterStatus(status) {
                currentFilter = status;
                
                // Toggle active class on buttons
                document.querySelectorAll('#statusFilters .filter-btn').forEach(btn => {
                    btn.classList.remove('active');
                });
                
                // Find correct active button
                const btnMap = {
                    'ALL': 0,
                    'PENDING': 1,
                    'PREPARING': 2,
                    'READY': 3,
                    'DELIVERED': 4
                };
                document.querySelectorAll('#statusFilters .filter-btn')[btnMap[status]].classList.add('active');
                
                applyFilters();
            }

            function searchOrders() {
                applyFilters();
            }

            function applyFilters() {
                const searchQuery = document.getElementById('orderSearch').value.toUpperCase().trim();
                const rows = document.querySelectorAll('#ordersTable tbody tr');
                
                rows.forEach(row => {
                    const rowStatus = row.getAttribute('data-status');
                    const rowBookingCode = row.getAttribute('data-booking-code') || '';
                    
                    const matchesStatus = (currentFilter === 'ALL' || rowStatus === currentFilter);
                    const matchesSearch = (searchQuery === '' || rowBookingCode.toUpperCase().includes(searchQuery));
                    
                    if (matchesStatus && matchesSearch) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                });
            }

            function updateStatus(foodOrderId, newStatus) {
                const button = document.querySelector('#action-cell-' + foodOrderId + ' button');
                if (button) button.disabled = true;

                const formData = new URLSearchParams();
                formData.append('action', 'updateStatus');
                formData.append('foodOrderId', foodOrderId);
                formData.append('status', newStatus);
                formData.append('_csrf', '${sessionScope.csrfToken}');

                fetch('${pageContext.request.contextPath}/staff/food-orders', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                    },
                    body: formData.toString()
                })
                .then(res => res.json())
                .then(data => {
                    if (data.success) {
                        // Dynamically update UI
                        const rows = document.querySelectorAll('#ordersTable tbody tr');
                        let targetRow = null;
                        rows.forEach(r => {
                            if (r.innerHTML.includes('Order #' + foodOrderId)) {
                                targetRow = r;
                            }
                        });

                        if (targetRow) {
                            targetRow.setAttribute('data-status', newStatus);
                        }

                        // Update Status Cell
                        const statusCell = document.getElementById('status-cell-' + foodOrderId);
                        let statusBadge = '';
                        if (newStatus === 'PREPARING') {
                            statusBadge = '<span class="status-badge status-preparing">Preparing</span>';
                        } else if (newStatus === 'READY') {
                            statusBadge = '<span class="status-badge status-ready">Ready for Pickup</span>';
                        } else if (newStatus === 'DELIVERED') {
                            statusBadge = '<span class="status-badge status-delivered">Delivered</span>';
                        }
                        statusCell.innerHTML = statusBadge;

                        // Update Action Cell
                        const actionCell = document.getElementById('action-cell-' + foodOrderId);
                        let actionHtml = '';
                        if (newStatus === 'PREPARING') {
                            actionHtml = 
                                '<button type="button" class="btn btn-primary btn-sm fw-semibold w-100" onclick="updateStatus(' + foodOrderId + ', \'READY\')">' +
                                '    <i class="bi bi-check2-circle me-1"></i>Mark Ready' +
                                '</button>';
                        } else if (newStatus === 'READY') {
                            actionHtml = 
                                '<button type="button" class="btn btn-success btn-sm fw-semibold w-100" onclick="updateStatus(' + foodOrderId + ', \'DELIVERED\')">' +
                                '    <i class="bi bi-mailbox me-1"></i>Deliver' +
                                '</button>';
                        } else if (newStatus === 'DELIVERED') {
                            const nowStr = new Date().toLocaleDateString('en-GB') + ' ' + new Date().toTimeString().substring(0, 5);
                            actionHtml = 
                                '<div class="text-success small fw-semibold text-center">' +
                                '    <i class="bi bi-check-all me-1"></i>Delivered<br>' +
                                '    <span class="text-muted" style="font-size: 0.72rem;">' + nowStr + '</span>' +
                                '</div>';
                        }
                        actionCell.innerHTML = actionHtml;

                        // Show success toast
                        showToast('Order #' + foodOrderId + ' status updated to ' + newStatus + '.', 'bg-success');
                        applyFilters();
                    } else {
                        if (button) button.disabled = false;
                        showToast('Error: ' + data.message, 'bg-danger');
                    }
                })
                .catch(err => {
                    console.error(err);
                    if (button) button.disabled = false;
                    showToast('Network error occurred.', 'bg-danger');
                });
            }

            function showToast(message, bgClass) {
                const toastEl = document.getElementById('statusToast');
                const toastMessage = document.getElementById('toastMessage');
                
                toastEl.classList.remove('bg-success', 'bg-danger', 'bg-warning', 'bg-info');
                toastEl.classList.add(bgClass);
                
                toastMessage.textContent = message;
                
                const toast = new bootstrap.Toast(toastEl);
                toast.show();
            }
        </script>
    </body>
</html>
