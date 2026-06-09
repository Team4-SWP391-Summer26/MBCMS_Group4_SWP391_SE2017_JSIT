<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Branch Manager Dashboard (owner: HungNT) - theo man 29_manager-dashboard
    cua Frontend demo prototype, console layout (sidebar + main).
    Chi hien du lieu showtime (cua HungNT); cho Revenue/Chart/Top movies
    thuoc module Reports (AnhND) + Occupancy (AnhPQ) - khong fake so lieu.
--%>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Dashboard - MBCMS Manager</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="dashboard" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1200px;">

                <%-- ===== Page header ===== --%>
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                    <div>
                        <div class="text-muted small mb-1">Dashboard</div>
                        <h4 class="text-navy fw-bold mb-0">
                            Branch Dashboard &middot; <c:out value="${sessionScope.currentBranchName}" /></h4>
                    </div>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/branch/showtimes/create">
                        <i class="bi bi-plus-lg me-1"></i>New Showtime</a>
                </div>

                <%-- ===== Branch scope notice (BranchFilter) ===== --%>
                <div class="lc-scope mb-4">
                    <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
                    <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}" /></strong>
                        &mdash; you only see data for your assigned branch.</span>
                </div>

                <%-- ===== KPI cards ===== --%>
                <div class="row g-3 mb-4">
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-4 h-100">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon"><i class="bi bi-calendar3"></i></div>
                                <div class="text-muted small fw-semibold">TODAY'S SHOWTIMES</div>
                            </div>
                            <div class="text-navy lc-stat-value">${kpiTodayCount}</div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-4 h-100">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon"><i class="bi bi-ticket-perforated"></i></div>
                                <div class="text-muted small fw-semibold">SEATS SOLD TODAY</div>
                            </div>
                            <div class="text-navy lc-stat-value">${kpiSeatsSold}</div>
                        </div>
                    </div>
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-4 h-100">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon"><i class="bi bi-calendar-week"></i></div>
                                <div class="text-muted small fw-semibold">SCHEDULED NEXT 7 DAYS</div>
                            </div>
                            <div class="text-navy lc-stat-value">${kpiWeekCount}</div>
                        </div>
                    </div>
                    <%-- Revenue thuoc module Reports (AnhND) - giu cho theo prototype, khong fake --%>
                    <div class="col-sm-6 col-xl-3">
                        <div class="card lc-elev p-4 h-100" style="opacity:.65;">
                            <div class="d-flex align-items-center gap-3 mb-3">
                                <div class="lc-stat-icon" style="background:#EEF1F4; color:#94a3b8;">
                                    <i class="bi bi-cash-stack"></i></div>
                                <div class="text-muted small fw-semibold">TODAY'S REVENUE</div>
                            </div>
                            <div class="text-muted lc-stat-value">&mdash;</div>
                            <div class="text-muted small mt-1">Reports module &middot; coming soon</div>
                        </div>
                    </div>
                </div>

                <%-- ===== Today's Showtimes (du lieu that tu showtimes) ===== --%>
                <div class="card lc-elev p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h6 class="text-navy fw-bold mb-0">Today's Showtimes</h6>
                        <a class="small text-decoration-none" href="${pageContext.request.contextPath}/branch/showtimes">
                            Manage showtimes <i class="bi bi-arrow-right"></i></a>
                    </div>
                    <div class="table-responsive">
                        <table class="table lc-table mb-0">
                            <thead>
                                <tr>
                                    <th>Movie</th>
                                    <th>Room</th>
                                    <th>Time</th>
                                    <th>Format</th>
                                    <th>Subtitle</th>
                                    <th class="text-center">Seats</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty todayShowtimes}">
                                    <tr><td colspan="7" class="text-center text-muted py-4">
                                        No showtimes scheduled for today.</td></tr>
                                </c:if>
                                <c:forEach var="st" items="${todayShowtimes}">
                                    <tr>
                                        <td class="fw-semibold text-navy"><c:out value="${st.movieTitle}" /></td>
                                        <td><c:out value="${st.roomName}" /></td>
                                        <td>${fn:substring(st.startTime, 11, 16)} &ndash; ${fn:substring(st.endTime, 11, 16)}</td>
                                        <td><span class="pill ${st.format == 'IMAX' ? 'pill-purple' : 'pill-blue'}">${st.format}</span></td>
                                        <td><span class="pill pill-gray">${st.subtitleType}</span></td>
                                        <td class="text-center">${st.bookedSeats}/${st.roomCapacity}</td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${st.status == 'SCHEDULED' && st.bookedSeats >= st.roomCapacity}">
                                                    <span class="pill pill-orange">FULL</span>
                                                </c:when>
                                                <c:when test="${st.status == 'SCHEDULED'}">
                                                    <span class="pill pill-green">SCHEDULED</span>
                                                </c:when>
                                                <c:when test="${st.status == 'CANCELLED'}">
                                                    <span class="pill pill-red">CANCELLED</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pill pill-gray">${st.status}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
