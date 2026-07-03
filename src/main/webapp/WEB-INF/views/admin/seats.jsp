<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Seat Layout editor (Admin) - theo mockup 25_mgr-seat-layout.
    Backend: AdminSeatServlet (/admin/seats): action=regenerate | action=updateSeat (AJAX).
    Dung chung style (.jspf) + JS (seat-layout.js) voi ban /branch/seats.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Seat Layout - PentaPlex Admin</title>
    <%@ include file="/WEB-INF/views/admin/_admin-assets.jspf" %>
    <%@ include file="/WEB-INF/views/branch/seat-layout-style.jspf" %>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-form-actions">
            <div>
                <div class="lc-page-crumb">
                    Admin / Cinemas / <strong><c:out value="${room.name}"/> &middot; Seat Layout</strong>
                </div>
                <h1 class="lc-page-title mb-0">Seat Layout &middot; <c:out value="${room.name}"/> (${room.roomType})</h1>
            </div>
            <div class="lc-form-actions-end">
                <a class="lc-back-link" href="${pageContext.request.contextPath}/admin/halls?branchId=${room.branchId}">
                    <i class="bi bi-arrow-left"></i> Back to rooms</a>
                <button type="button" class="st-toolbar-add border-0" data-bs-toggle="modal" data-bs-target="#genModal">
                    <i class="bi bi-arrow-clockwise" aria-hidden="true"></i> Reset / Generate grid</button>
            </div>
        </div>

        <c:if test="${not empty successMsg}">
            <div class="alert alert-success py-2">${successMsg}</div>
        </c:if>
        <c:if test="${not empty errorMsg}">
            <div class="alert alert-danger py-2">${errorMsg}</div>
        </c:if>

        <div class="row g-3">
            <%-- ===== LEFT: toolbar + seat map ===== --%>
            <div class="col-lg-8">
                <%-- Toolbar --%>
                <div class="card lc-elev p-3 mb-3 sl-toolbar">
                    <div class="d-flex flex-wrap align-items-center gap-2">
                        <span class="fw-semibold me-1" style="font-size:.9rem;">Apply to selected:</span>
                        <div class="sl-tools" id="slTools">
                            <button type="button" class="sl-tool active" data-tool="STANDARD"><span class="dot d-std"></span>Standard</button>
                            <button type="button" class="sl-tool" data-tool="VIP"><span class="dot d-vip"></span>VIP</button>
                            <button type="button" class="sl-tool" data-tool="OFF"><span class="dot d-off"></span>Off</button>
                        </div>
                        <button type="button" class="st-toolbar-add border-0" id="applyBtn" disabled>Apply (<span id="selCount">0</span>)</button>
                        <span class="vr mx-1"></span>
                        <button type="button" class="btn btn-light btn-sm border" id="selectAllBtn">Select all</button>
                        <button type="button" class="btn btn-light btn-sm border" id="clearBtn">Clear</button>
                        <span class="text-muted ms-auto" style="font-size:.78rem;">
                            <i class="bi bi-info-circle me-1"></i>Click to multi-select, then Apply</span>
                    </div>
                </div>

                <%-- Seat map --%>
                <div class="card lc-elev p-4">
                    <div class="sl-screen-wrap mb-4">
                        <div class="sl-screen-curve"></div>
                        <div class="sl-screen-label">SCREEN</div>
                    </div>

                    <c:if test="${empty seatsByRow}">
                        <div class="text-center text-muted py-5">
                            <i class="bi bi-grid-3x3-gap fs-1 d-block mb-2 opacity-50"></i>
                            No seats yet. Use <strong>Reset / Generate grid</strong> to create the layout.
                        </div>
                    </c:if>

                    <c:if test="${not empty seatsByRow}">
                        <div class="sl-grid">
                            <%-- Column-number header (built from the first row) --%>
                            <c:set var="hdrDone" value="false"/>
                            <c:forEach var="row" items="${seatsByRow}">
                                <c:if test="${not hdrDone}">
                                    <c:set var="hLen" value="${fn:length(row.value)}"/>
                                    <div class="sl-row">
                                        <span class="sl-rlabel"></span>
                                        <c:forEach var="seat" items="${row.value}" varStatus="st">
                                            <span class="sl-colnum">${seat.colNumber}</span>
                                            <c:if test="${st.count == (hLen / 2) and hLen > 3}"><span class="sl-aisle"></span></c:if>
                                        </c:forEach>
                                        <span class="sl-rlabel"></span>
                                    </div>
                                    <c:set var="hdrDone" value="true"/>
                                </c:if>
                            </c:forEach>
                            <%-- Seat rows --%>
                            <c:forEach var="row" items="${seatsByRow}">
                                <c:set var="rowLen" value="${fn:length(row.value)}"/>
                                <div class="sl-row">
                                    <span class="sl-rlabel">${row.key}</span>
                                    <c:forEach var="seat" items="${row.value}" varStatus="st">
                                        <button type="button"
                                                class="sl-seat ${!seat.active ? 'is-off' : (seat.seatType == 'VIP' ? 'is-vip' : 'is-std')}"
                                                data-seatid="${seat.seatId}"
                                                title="${seat.rowLabel}${seat.colNumber}"></button>
                                        <c:if test="${st.count == (rowLen / 2) and rowLen > 3}">
                                            <span class="sl-aisle"></span>
                                        </c:if>
                                    </c:forEach>
                                    <span class="sl-rlabel">${row.key}</span>
                                </div>
                            </c:forEach>
                        </div>

                        <%-- Legend (like booking) --%>
                        <div class="sl-legend">
                            <span><span class="dot d-std"></span>Standard</span>
                            <span><span class="dot d-vip"></span>VIP</span>
                            <span><span class="dot d-off"></span>Off / removed</span>
                            <span><span class="dot d-sel"></span>Selected</span>
                        </div>
                    </c:if>
                </div>
            </div>

            <%-- ===== RIGHT: summary ===== --%>
            <div class="col-lg-4">
                <div class="card lc-elev p-4" style="position:sticky; top:16px;">
                    <h6 class="text-navy fw-bold mb-3">Summary</h6>
                    <div class="sl-sum-row sl-sum-total">
                        <span>Total seats</span><span class="fw-bold fs-5" id="sumTotal">0</span>
                    </div>
                    <div class="sl-sum-row"><span><span class="dot d-std"></span>Standard</span><span class="fw-semibold" id="sumStd">0</span></div>
                    <div class="sl-sum-row"><span><span class="dot d-vip"></span>VIP</span><span class="fw-semibold" id="sumVip">0</span></div>
                    <div class="sl-sum-row"><span><span class="dot d-off"></span>Off / removed</span><span class="fw-semibold" id="sumOff">0</span></div>

                    <h6 class="text-navy fw-bold mt-4 mb-2">Pricing</h6>
                    <div class="sl-note">
                        <i class="bi bi-info-circle me-1"></i>
                        VIP seats are charged at <strong>+30%</strong> of each showtime's base price.
                        Saving updates capacity for all future showtimes.
                    </div>
                </div>
            </div>
        </div>
    </div>
</main>

<%-- Generate / reset modal --%>
<div class="modal fade" id="genModal" tabindex="-1">
    <div class="modal-dialog">
        <form class="modal-content" method="post" action="${pageContext.request.contextPath}/admin/seats"
              onsubmit="return confirm('Regenerate layout? All existing seats in this room will be replaced.');">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
            <input type="hidden" name="action" value="regenerate">
            <input type="hidden" name="roomId" value="${roomId}">
            <div class="modal-header">
                <h5 class="modal-title">Generate seat grid</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-warning py-2 small">
                    <i class="bi bi-exclamation-triangle me-1"></i>This replaces the entire current layout.
                </div>
                <div class="row g-3">
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Rows</label>
                        <input type="number" class="form-control" name="rowsCount" min="1" max="26" value="8" required>
                    </div>
                    <div class="col-6">
                        <label class="form-label small fw-semibold">Columns</label>
                        <input type="number" class="form-control" name="colsCount" min="1" max="30" value="10" required>
                    </div>
                    <div class="col-12">
                        <label class="form-label small fw-semibold">Default type</label>
                        <select class="form-select" name="defaultType">
                            <option value="STANDARD">STANDARD</option>
                            <option value="VIP">VIP</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancel</button>
                <button type="submit" class="btn btn-primary"><i class="bi bi-grid-3x3-gap me-1"></i>Generate</button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/views/admin/_admin-scripts.jspf" %>
<script>
    const CTX = '${pageContext.request.contextPath}';
    const ROOM_ID = '${roomId}';
    const ENDPOINT = CTX + '/admin/seats';
    const CSRF_TOKEN = '${sessionScope.csrfToken}';
</script>
<script src="${pageContext.request.contextPath}/assets/js/seat-layout.js?v=${applicationScope.assetVersion}"></script>
</body>
</html>
