<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Booking History – MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* ── Page layout ── */
            .page-hero {
                background: linear-gradient(135deg, #0f1e36 0%, #182c54 100%);
                padding: 2.5rem 0 2rem;
                margin-bottom: 2rem;
            }
            .page-hero h1 {
                color: #fff;
                font-weight: 700;
                font-size: 1.6rem;
                margin: 0;
            }
            .page-hero .subtitle {
                color: #90b4d8;
                font-size: 0.9rem;
                margin-top: 0.25rem;
            }

            /* ── Filter tabs ── */
            .filter-tabs {
                display: flex;
                gap: 6px;
                flex-wrap: wrap;
            }
            .filter-tab {
                padding: 5px 16px;
                border-radius: 99px;
                font-size: 0.8rem;
                font-weight: 600;
                border: 1.5px solid #e5e7eb;
                background: #fff;
                color: #6b7280;
                cursor: pointer;
                transition: all 0.15s;
                text-decoration: none;
            }
            .filter-tab:hover {
                border-color: #2563eb;
                color: #2563eb;
            }
            .filter-tab.active {
                background: #2563eb;
                border-color: #2563eb;
                color: #fff;
            }

            /* ── Booking card ── */
            .booking-card {
                background: #fff;
                border-radius: 12px;
                box-shadow: 0 1px 6px rgba(0,0,0,.07);
                padding: 18px 20px;
                margin-bottom: 12px;
                transition: box-shadow 0.15s, transform 0.15s;
                border: 1px solid #f1f5f9;
                text-decoration: none;
                color: inherit;
                display: block;
            }
            .booking-card:hover {
                box-shadow: 0 4px 18px rgba(37,99,235,.12);
                transform: translateY(-1px);
                color: inherit;
            }
            .booking-code {
                font-family: monospace;
                font-weight: 800;
                font-size: 1rem;
                color: #1d4ed8;
                letter-spacing: 0.06em;
            }
            .booking-meta {
                font-size: 0.82rem;
                color: #6b7280;
                margin-top: 2px;
            }
            .booking-amount {
                font-weight: 700;
                font-size: 1rem;
                color: #0f1e36;
            }
            .booking-seats {
                font-size: 0.82rem;
                color: #4b5563;
                margin-top: 3px;
            }

            /* ── Status pills ── */
            .status-pill {
                padding: 3px 12px;
                border-radius: 99px;
                font-size: 0.75rem;
                font-weight: 700;
                display: inline-block;
                white-space: nowrap;
            }
            .sp-CONFIRMED {
                background: #dcfce7;
                color: #16a34a;
            }
            .sp-PENDING   {
                background: #fef3c7;
                color: #b45309;
            }
            .sp-CANCELLED {
                background: #f1f5f9;
                color: #64748b;
            }
            .sp-USED      {
                background: #ede9fe;
                color: #6d28d9;
            }

            /* ── Empty state ── */
            .empty-state {
                text-align: center;
                padding: 4rem 2rem;
            }
            .empty-icon {
                font-size: 3.5rem;
                margin-bottom: 1rem;
                display: block;
            }
            .empty-state h5 {
                color: #374151;
                font-weight: 700;
                margin-bottom: 0.5rem;
            }
            .empty-state p {
                color: #6b7280;
                font-size: 0.92rem;
                margin-bottom: 1.5rem;
            }

            /* ── Chevron arrow ── */
            .card-arrow {
                color: #d1d5db;
                font-size: 1.1rem;
                flex-shrink: 0;
            }
            .booking-card:hover .card-arrow {
                color: #2563eb;
            }
        </style>
    </head>
    <body>

        <jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <!-- Page hero -->
        <div class="page-hero">
            <div class="container" style="max-width: 780px;">
                <div class="d-flex align-items-center gap-3 flex-wrap">
                    <div>
                        <h1>
                            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                 stroke-linecap="round" stroke-linejoin="round" class="me-2" style="vertical-align:-3px">
                            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                            <line x1="16" y1="2" x2="16" y2="6"></line>
                            <line x1="8" y1="2" x2="8" y2="6"></line>
                            <line x1="3" y1="10" x2="21" y2="10"></line>
                            </svg>
                            My Bookings
                        </h1>
                        <div class="subtitle">All your ticket reservations in one place</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING"
                       class="ms-auto btn btn-warning btn-sm fw-semibold text-dark text-nowrap">
                        + Book Tickets
                    </a>
                </div>
            </div>
        </div>

        <div class="container pb-5" style="max-width: 780px;">

            <!-- Filter tabs -->
            <div class="d-flex align-items-center justify-content-between mb-4 flex-wrap gap-2">
                <div class="filter-tabs">
                    <a href="?filter=ALL"       class="filter-tab ${empty param.filter || param.filter == 'ALL'       ? 'active' : ''}">All</a>
                    <a href="?filter=CONFIRMED" class="filter-tab ${param.filter == 'CONFIRMED' ? 'active' : ''}">Confirmed</a>
                    <a href="?filter=PENDING"   class="filter-tab ${param.filter == 'PENDING'   ? 'active' : ''}">Pending</a>
                    <a href="?filter=USED"      class="filter-tab ${param.filter == 'USED'      ? 'active' : ''}">Used</a>
                    <a href="?filter=CANCELLED" class="filter-tab ${param.filter == 'CANCELLED' ? 'active' : ''}">Cancelled</a>
                </div>
                <span class="text-muted" style="font-size: 0.82rem;">
                    <c:choose>
                        <c:when test="${not empty bookings}">${bookings.size()} booking(s)</c:when>
                        <c:otherwise>0 bookings</c:otherwise>
                    </c:choose>
                </span>
            </div>

            <!-- Booking list -->
            <c:choose>
                <c:when test="${empty bookings}">
                    <div class="empty-state">
                        <span class="empty-icon">🎫</span>
                        <h5>No bookings yet</h5>
                        <p>You haven't made any reservations.<br>Find a movie you love and grab your seats!</p>
                        <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING"
                           class="btn btn-primary px-4 fw-semibold">Browse Movies</a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="b" items="${bookings}">
                        <%
                            com.mbcms.model.Booking loopBooking =
                                (com.mbcms.model.Booking) pageContext.getAttribute("b");
                            java.util.Date loopCreatedAt = null;
                            if (loopBooking != null && loopBooking.getCreatedAt() != null) {
                                loopCreatedAt = java.util.Date.from(
                                    loopBooking.getCreatedAt()
                                               .atZone(java.time.ZoneId.systemDefault())
                                               .toInstant());
                            }
                            pageContext.setAttribute("loopCreatedAt", loopCreatedAt);
                        %>
                        <a class="booking-card"
                           href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${b.bookingId}">
                            <div class="d-flex align-items-center gap-3">
                                <!-- Left: code + meta -->
                                <div class="flex-grow-1 min-width-0">
                                    <div class="d-flex align-items-center gap-2 flex-wrap">
                                        <span class="booking-code">${b.bookingCode}</span>
                                        <span class="status-pill sp-${b.status}">${b.status}</span>
                                    </div>
                                    <div class="booking-meta mt-1">
                                        Showtime #${b.showtimeId}
                                        &bull;
                                        ${b.seatIds != null ? b.seatIds.size() : 0} seat(s)
                                        &bull;
                                        <fmt:formatDate value="${loopCreatedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </div>
                                </div>

                                <!-- Right: amount + arrow -->
                                <div class="text-end flex-shrink-0">
                                    <div class="booking-amount">
                                        <fmt:formatNumber value="${b.totalAmount}" pattern="#,###"/> ₫
                                    </div>
                                    <div class="booking-seats">
                                        <c:forEach var="sid" items="${b.seatIds}" varStatus="st">
                                            Seat #${sid}<c:if test="${!st.last}">, </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                                <div class="card-arrow">›</div>
                            </div>

                            <!-- PENDING: countdown hint -->
                            <c:if test="${b.status == 'PENDING'}">
                                <div class="mt-2 pt-2" style="border-top: 1px solid #fef3c7;">
                                    <span style="font-size: 0.78rem; color: #b45309; font-weight: 600;">
                                        ⏳ Payment pending — complete payment to confirm your seats
                                    </span>
                                </div>
                            </c:if>
                        </a>
                    </c:forEach>
                </c:otherwise>
            </c:choose>

        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
