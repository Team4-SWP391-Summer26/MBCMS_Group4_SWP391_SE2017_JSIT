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
        <title>Dashboard - PentaPlex Manager</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="dashboard" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <div class="lc-page-head">
                    <div>
                        <div class="lc-page-crumb">Dashboard</div>
                        <h1 class="lc-page-title">Branch Dashboard &middot; <c:out value="${sessionScope.currentBranchName}" /></h1>
                    </div>
                </div>

                <%-- ===== Branch scope notice (BranchFilter) ===== --%>
                <div class="lc-scope mb-4">
                    <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
                    <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}" /></strong>
                        &mdash; you only see data for your assigned branch.</span>
                </div>

                <%-- ===== KPI cards ===== --%>
                <div class="lc-kpi-row">
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-calendar3"></i></div>
                        <div>
                            <div class="lc-kpi-label">Today's showtimes</div>
                            <div class="lc-kpi-value">${kpiTodayCount}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-ticket-perforated"></i></div>
                        <div>
                            <div class="lc-kpi-label">Seats sold today</div>
                            <div class="lc-kpi-value">${kpiSeatsSold}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-calendar-week"></i></div>
                        <div>
                            <div class="lc-kpi-label">Scheduled next 7 days</div>
                            <div class="lc-kpi-value">${kpiWeekCount}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card is-muted">
                        <div class="lc-stat-icon lc-kpi-icon--slate"><i class="bi bi-cash-stack"></i></div>
                        <div>
                            <div class="lc-kpi-label">Today's revenue</div>
                            <div class="lc-kpi-value">&mdash;</div>
                            <div class="lc-kpi-hint">Reports module &middot; coming soon</div>
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
                                    <th class="text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty todayShowtimes}">
                                    <tr><td colspan="8" class="text-center text-muted py-4">
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
                                        <td class="text-end">
                                            <c:if test="${st.status != 'CANCELLED'}">
                                                <a class="btn btn-sm btn-outline-info py-0 px-2" style="font-size: .75rem;" title="Monitor occupancy"
                                                   href="${pageContext.request.contextPath}/branch/showtimes/monitor?id=${st.showtimeId}">
                                                    <i class="bi bi-eye"></i> Monitor</a>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>

            </div>
        </main>

        <%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
    </body>
</html>
