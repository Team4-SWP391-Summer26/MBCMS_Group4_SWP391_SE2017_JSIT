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
        <title>Food &amp; Drinks Fulfillments - PentaPlex Staff</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
        <style>
            .btn-action-custom {
                border-radius: 9px;
                font-weight: 700;
                letter-spacing: .02em;
                transition: transform .15s ease, box-shadow .15s ease;
            }
            .btn-action-custom:hover { transform: translateY(-1px); }
            .btn-action-custom:active { transform: scale(.98); }
        </style>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
            <jsp:param name="active" value="food-orders" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <div class="lc-page-head">
                    <div>
                        <div class="lc-page-section">Counter Operations</div>
                        <h1 class="lc-page-title">Food &amp; Drinks Fulfillments</h1>
                    </div>
                    <div class="lc-branch-chip">
                        <i class="bi bi-geo-alt-fill" aria-hidden="true"></i>
                        <span><c:out value="${sessionScope.currentBranchName}" /></span>
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

                <div class="st-toolbar st-toolbar--single lc-toolbar mb-4">
                    <div class="st-toolbar-track w-100">
                        <div class="lc-seg" id="statusFilters" role="tablist" aria-label="Filter orders by status">
                            <button type="button" class="lc-seg-btn active" onclick="filterStatus('ALL')">
                                <i class="bi bi-grid-3x3-gap-fill"></i> All</button>
                            <button type="button" class="lc-seg-btn" onclick="filterStatus('PENDING')">
                                <i class="bi bi-hourglass-split"></i> Pending</button>
                            <button type="button" class="lc-seg-btn" onclick="filterStatus('PREPARING')">
                                <i class="bi bi-clock-history"></i> Preparing</button>
                            <button type="button" class="lc-seg-btn" onclick="filterStatus('READY')">
                                <i class="bi bi-check2-circle"></i> Ready</button>
                            <button type="button" class="lc-seg-btn" onclick="filterStatus('DELIVERED')">
                                <i class="bi bi-check-all"></i> Delivered</button>
                        </div>
                        <div class="lc-toolbar-spacer" aria-hidden="true"></div>
                        <div class="lc-toolbar-search">
                            <i class="bi bi-search" aria-hidden="true"></i>
                            <input type="search" id="orderSearch" placeholder="Search booking code..."
                                   oninput="searchOrders()" aria-label="Search orders by booking code">
                        </div>
                    </div>
                </div>

                <%-- ===== Orders Table ===== --%>
                <div class="card lc-elev p-0 overflow-hidden">
                    <div class="table-responsive">
                        <table class="table lc-table align-middle mb-0" id="ordersTable">
                            <thead>
                                <tr>
                                    <th class="ps-4" style="width: 15%;">Order &amp; Booking</th>
                                    <th style="width: 15%;">Time</th>
                                    <th style="width: 25%;">Customer &amp; Context</th>
                                    <th style="width: 25%;">Concessions Ordered</th>
                                    <th style="width: 10%;">Status</th>
                                    <th class="text-end pe-4" style="width: 10%;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty orders}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-5">
                                                <div class="my-3">
                                                    <i class="bi bi-inbox text-subtle d-block mb-2" style="font-size: 2.2rem; opacity: 0.5;"></i>
                                                    <span class="fw-semibold text-navy d-block mb-1 fs-6">No Concession Orders Found</span>
                                                    <span class="small text-muted">There are no orders matching the selected status filters.</span>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach var="ord" items="${orders}">
                                            <tr data-status="${ord.status}" data-booking-code="${ord.bookingCode}">
                                                <td class="ps-4">
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
                                                    <div class="small text-muted mt-1" style="line-height: 1.45;">
                                                        <span class="d-block text-truncate" style="max-width: 220px;" title="${ord.movieTitle}"><i class="bi bi-film me-1 text-primary"></i> <c:out value="${ord.movieTitle}" /></span>
                                                        <span class="d-block mt-0.5"><i class="bi bi-door-closed me-1"></i> Room: ${ord.roomName} &middot; Showtime: ${ord.startTime}</span>
                                                    </div>
                                                </td>
                                                <td>
                                                    <div class="d-flex flex-wrap gap-1 mt-1">
                                                        <c:forEach var="item" items="${ord.items}">
                                                            <c:set var="itemKeyLower" value="${fn:toLowerCase(item.key)}" />
                                                            <c:choose>
                                                                <c:when test="${fn:contains(itemKeyLower, 'water') || fn:contains(itemKeyLower, 'coca') || fn:contains(itemKeyLower, 'pepsi') || fn:contains(itemKeyLower, 'soda') || fn:contains(itemKeyLower, 'drink') || fn:contains(itemKeyLower, 'juice') || fn:contains(itemKeyLower, 'fanta') || fn:contains(itemKeyLower, 'sprite')}">
                                                                    <c:set var="itemIcon" value="bi-cup-straw text-info" />
                                                                    <c:set var="badgeClass" value="border-info-subtle" />
                                                                </c:when>
                                                                <c:when test="${fn:contains(itemKeyLower, 'popcorn') || fn:contains(itemKeyLower, 'snack') || fn:contains(itemKeyLower, 'food') || fn:contains(itemKeyLower, 'chip') || fn:contains(itemKeyLower, 'corn')}">
                                                                    <c:set var="itemIcon" value="bi-egg-fried text-warning" />
                                                                    <c:set var="badgeClass" value="border-warning-subtle" />
                                                                </c:when>
                                                                <c:when test="${fn:contains(itemKeyLower, 'combo')}">
                                                                    <c:set var="itemIcon" value="bi-box2-heart text-success" />
                                                                    <c:set var="badgeClass" value="border-success-subtle" />
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <c:set var="itemIcon" value="bi-shop text-primary" />
                                                                    <c:set var="badgeClass" value="border-primary-subtle" />
                                                                </c:otherwise>
                                                            </c:choose>
                                                            <span class="badge bg-light text-navy border ${badgeClass} py-2 px-2.5 rounded-pill d-inline-flex align-items-center gap-1.5 fw-semibold" style="font-size: 0.82rem; box-shadow: 0 1px 2px rgba(15, 23, 42, 0.02); transition: all 0.2s ease;" onmouseover="this.style.transform='scale(1.03)'" onmouseout="this.style.transform='none'">
                                                                <i class="bi ${itemIcon}"></i>
                                                                <span><c:out value="${item.key}"/></span>
                                                                <strong class="text-primary fs-7 px-1.5 py-0.5 rounded bg-primary-subtle bg-opacity-20" style="margin-left: 2px;">x${item.value}</strong>
                                                            </span>
                                                        </c:forEach>
                                                    </div>
                                                </td>
                                                <td id="status-cell-${ord.foodOrderId}">
                                                    <c:choose>
                                                        <c:when test="${ord.status == 'PENDING'}">
                                                            <span class="lc-status-badge lc-status-pending"><i class="bi bi-hourglass-split"></i>Pending Payment</span>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'PREPARING'}">
                                                            <span class="lc-status-badge lc-status-preparing"><i class="bi bi-clock-history"></i>Preparing</span>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'READY'}">
                                                            <span class="lc-status-badge lc-status-ready"><i class="bi bi-check2-circle"></i>Ready for Pickup</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="lc-status-badge lc-status-delivered"><i class="bi bi-check-all"></i>Delivered</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td class="text-end pe-4" id="action-cell-${ord.foodOrderId}">
                                                    <c:choose>
                                                        <c:when test="${ord.status == 'PENDING'}">
                                                            <button type="button" class="btn btn-warning btn-sm btn-action-custom w-100 py-2" onclick="updateStatus(${ord.foodOrderId}, 'PREPARING')"
                                                                    style="box-shadow: 0 2px 6px rgba(217, 119, 6, 0.15);">
                                                                <i class="bi bi-cash me-1"></i>Pay &amp; Prepare
                                                            </button>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'PREPARING'}">
                                                            <button type="button" class="btn btn-primary btn-sm btn-action-custom w-100 py-2" onclick="updateStatus(${ord.foodOrderId}, 'READY')"
                                                                    style="box-shadow: 0 2px 6px rgba(37, 99, 235, 0.15);">
                                                                <i class="bi bi-check2-circle me-1"></i>Mark Ready
                                                            </button>
                                                        </c:when>
                                                        <c:when test="${ord.status == 'READY'}">
                                                            <button type="button" class="btn btn-success btn-sm btn-action-custom w-100 py-2" onclick="updateStatus(${ord.foodOrderId}, 'DELIVERED')"
                                                                    style="box-shadow: 0 2px 6px rgba(22, 163, 74, 0.15);">
                                                                <i class="bi bi-mailbox me-1"></i>Deliver
                                                            </button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="text-success small fw-semibold text-center">
                                                                <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1.5 rounded-pill fs-7 d-inline-flex align-items-center gap-1">
                                                                    <i class="bi bi-check-all fs-6"></i>Delivered
                                                                </span>
                                                                <div class="text-muted mt-1.5" style="font-size: 0.72rem;">${formattedDeliveredDates[ord.foodOrderId]}</div>
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

        <%-- ===== Toast Feedback ===== --%>
        <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1080;">
            <div id="toastFeedback" class="toast align-items-center text-white border-0 shadow-lg" role="alert" aria-live="assertive" aria-atomic="true" style="border-radius: var(--radius-md);">
                <div class="d-flex">
                    <div class="toast-body fw-semibold" id="toastMessage"></div>
                    <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            let currentFilter = 'ALL';

            function filterStatus(status) {
                currentFilter = status;
                
                // Toggle active class on buttons
                document.querySelectorAll('#statusFilters .lc-seg-btn').forEach(btn => {
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
                document.querySelectorAll('#statusFilters .lc-seg-btn')[btnMap[status]].classList.add('active');
                
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

            function showToast(message, type = 'success') {
                const toastEl = document.getElementById('toastFeedback');
                const msgEl = document.getElementById('toastMessage');
                msgEl.textContent = message;
                
                toastEl.className = 'toast align-items-center text-white border-0 shadow-lg ' + 
                    (type === 'success' ? 'bg-success' : (type === 'danger' ? 'bg-danger' : 'bg-warning'));
                
                const bsToast = new bootstrap.Toast(toastEl, { delay: 3500 });
                bsToast.show();
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
                            statusBadge = '<span class="lc-status-badge lc-status-preparing"><i class="bi bi-clock-history"></i>Preparing</span>';
                        } else if (newStatus === 'READY') {
                            statusBadge = '<span class="lc-status-badge lc-status-ready"><i class="bi bi-check2-circle"></i>Ready for Pickup</span>';
                        } else if (newStatus === 'DELIVERED') {
                            statusBadge = '<span class="lc-status-badge lc-status-delivered"><i class="bi bi-check-all"></i>Delivered</span>';
                        }
                        statusCell.innerHTML = statusBadge;

                        // Update Action Cell
                        const actionCell = document.getElementById('action-cell-' + foodOrderId);
                        let actionHtml = '';
                        if (newStatus === 'PREPARING') {
                            actionHtml = 
                                '<button type="button" class="btn btn-primary btn-sm btn-action-custom w-100 py-2" onclick="updateStatus(' + foodOrderId + ', \'READY\')" style="box-shadow: 0 2px 6px rgba(37, 99, 235, 0.15);">' +
                                '    <i class="bi bi-check2-circle me-1"></i>Mark Ready' +
                                '</button>';
                        } else if (newStatus === 'READY') {
                            actionHtml = 
                                '<button type="button" class="btn btn-success btn-sm btn-action-custom w-100 py-2" onclick="updateStatus(' + foodOrderId + ', \'DELIVERED\')" style="box-shadow: 0 2px 6px rgba(22, 163, 74, 0.15);">' +
                                '    <i class="bi bi-mailbox me-1"></i>Deliver' +
                                '</button>';
                        } else if (newStatus === 'DELIVERED') {
                            const nowStr = new Date().toLocaleDateString('en-GB') + ' ' + new Date().toTimeString().substring(0, 5);
                            actionHtml = 
                                '<div class="text-success small fw-semibold text-center">' +
                                '    <span class="badge bg-success-subtle text-success border border-success-subtle px-2.5 py-1.5 rounded-pill fs-7 d-inline-flex align-items-center gap-1">' +
                                '        <i class="bi bi-check-all fs-6"></i>Delivered' +
                                '    </span>' +
                                '    <div class="text-muted mt-1.5" style="font-size: 0.72rem;">' + nowStr + '</div>' +
                                '</div>';
                        }
                        actionCell.innerHTML = actionHtml;

                        // Show success toast
                        showToast('Order #' + foodOrderId + ' status updated to ' + newStatus + '.', 'success');
                        applyFilters();
                    } else {
                        if (button) button.disabled = false;
                        showToast('Error: ' + data.message, 'danger');
                    }
                })
                .catch(err => {
                    console.error(err);
                    if (button) button.disabled = false;
                    showToast('Network error occurred.', 'danger');
                });
            }
        </script>
    </body>
</html>
