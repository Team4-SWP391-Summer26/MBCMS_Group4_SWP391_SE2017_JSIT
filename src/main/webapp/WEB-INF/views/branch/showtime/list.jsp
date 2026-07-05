<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%-- Co dinh locale de gia luon hien "###,### VND" (SRS) du browser gui Accept-Language gi --%>
<fmt:setLocale value="en_US" />
<%--
    Showtime Management (SRS 3.5.2.1) - lam theo man 22_mgr-showtimes cua
    Frontend demo prototype: date pills + KPI + schedule timeline + table.
    Owner: HungNT.
--%>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Showtime Management - PentaPlex Manager</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="showtimes" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <div class="lc-page-head mb-2">
                    <div>
                        <div class="lc-page-crumb">Dashboard / <strong>Showtimes</strong></div>
                        <h1 class="lc-page-title">Showtime Management</h1>
                    </div>
                </div>

                <%-- ===== Branch scope notice ===== --%>
                <div class="lc-scope mb-3">
                    <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
                    <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}" /></strong>
                        &mdash; you only see data for your assigned branch.</span>
                </div>

                <c:if test="${not empty successMsg}">
                    <div class="alert alert-success py-2">${successMsg}</div>
                </c:if>
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger py-2">${errorMsg}</div>
                </c:if>

                <%-- ===== Toolbar: 1 hang — pills | date | filters | Add ===== --%>
                <div class="st-toolbar st-toolbar--single mb-3">
                    <div class="st-toolbar-track">
                        <div class="st-toolbar-pills" role="group" aria-label="Quick date">
                            <c:forEach var="d" items="${datePills}">
                                <a class="date-pill ${selectedDate == d.iso ? 'active' : ''}"
                                   href="${pageContext.request.contextPath}/branch/showtimes?date=${d.iso}${empty filterMovieId ? '' : '&movieId='}${filterMovieId}${empty filterRoomId ? '' : '&roomId='}${filterRoomId}">
                                    <span class="d-day">${d.day}</span>
                                    <span class="d-num">${d.dm}</span>
                                </a>
                            </c:forEach>
                        </div>
                        <span class="st-toolbar-vrule" aria-hidden="true"></span>
                        <form method="get" action="${pageContext.request.contextPath}/branch/showtimes" class="st-toolbar-date-form">
                            <input type="hidden" name="movieId" value="${filterMovieId}">
                            <input type="hidden" name="roomId" value="${filterRoomId}">
                            <input type="date" class="form-control st-toolbar-date-input" name="date"
                                   value="${selectedDate}" onchange="this.form.submit()"
                                   title="Pick another date" aria-label="Pick another date">
                        </form>
                        <span class="st-toolbar-vrule" aria-hidden="true"></span>
                        <form method="get" action="${pageContext.request.contextPath}/branch/showtimes"
                              class="st-toolbar-filter-form">
                            <input type="hidden" name="date" value="${selectedDate}" class="st-toolbar-hidden">
                            <select class="form-select st-toolbar-select" name="movieId"
                                    onchange="this.form.submit()" aria-label="Filter by movie">
                                <option value="">All Movies</option>
                                <c:forEach var="m" items="${movies}">
                                    <option value="${m.movieId}" ${filterMovieId == m.movieId ? 'selected' : ''}>
                                        <c:out value="${m.title}" /></option>
                                </c:forEach>
                            </select>
                            <select class="form-select st-toolbar-select" name="roomId"
                                    onchange="this.form.submit()" aria-label="Filter by room">
                                <option value="">All Rooms</option>
                                <c:forEach var="r" items="${rooms}">
                                    <option value="${r.roomId}" ${filterRoomId == r.roomId ? 'selected' : ''}>
                                        <c:out value="${r.name}" /> &middot; ${r.roomType}</option>
                                </c:forEach>
                            </select>
                        </form>
                        <a class="st-toolbar-add"
                           href="${pageContext.request.contextPath}/branch/showtimes/create?date=${selectedDate}&returnDate=${selectedDate}#showtime-form">
                            <i class="bi bi-plus-lg" aria-hidden="true"></i>Create showtime</a>
                    </div>
                </div>

                <%-- ===== KPI cards (tinh tu du lieu showtime cua ngay dang chon) ===== --%>
                <div class="lc-kpi-row">
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-collection-play"></i></div>
                        <div>
                            <div class="lc-kpi-label">Showtimes</div>
                            <div class="lc-kpi-value">${kpiCount}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-people"></i></div>
                        <div>
                            <div class="lc-kpi-label">Seats sold</div>
                            <div class="lc-kpi-value">${kpiSeatsSold}</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card">
                        <div class="lc-stat-icon lc-kpi-icon--violet"><i class="bi bi-pie-chart"></i></div>
                        <div>
                            <div class="lc-kpi-label">Avg occupancy</div>
                            <div class="lc-kpi-value">${kpiOccupancy}%</div>
                        </div>
                    </div>
                    <div class="lc-kpi-card is-muted">
                        <div class="lc-stat-icon lc-kpi-icon--slate"><i class="bi bi-cash-stack"></i></div>
                        <div>
                            <div class="lc-kpi-label">Revenue</div>
                            <div class="lc-kpi-value">&mdash;</div>
                            <div class="lc-kpi-hint">Reports module &middot; coming soon</div>
                        </div>
                    </div>
                </div>

                <%-- ===== Schedule timeline theo phong (09:00 - 24:00) ===== --%>
                <div class="card lc-elev p-4 mb-3" id="showtime-timeline">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                        <div>
                            <h6 class="text-navy fw-bold mb-1">Schedule timeline &mdash; ${selectedDateLong}</h6>
                            <p class="text-muted small mb-0">Each block is a scheduled showtime. Click a block to edit.</p>
                        </div>
                        <div class="d-flex gap-3 small text-muted align-items-center st-legend-row">
                            <span class="d-inline-flex align-items-center gap-1"><span class="st-legend" style="background:#2563eb;"></span> Standard</span>
                            <span class="d-inline-flex align-items-center gap-1"><span class="st-legend" style="background:#b8860b;"></span> VIP</span>
                            <span class="d-inline-flex align-items-center gap-1"><span class="st-legend" style="background:#5b3d8f;"></span> IMAX</span>
                            <span class="d-inline-flex align-items-center gap-1"><span class="st-legend" style="background:#dc3545;"></span> Full</span>
                        </div>
                    </div>

                    <div class="st-scroll">
                        <div class="st-grid" role="grid" aria-label="Schedule timeline for ${selectedDateLong}">
                            <div class="st-grid-corner" role="presentation"></div>
                            <c:forEach var="h" begin="9" end="23">
                                <div class="st-grid-hour" role="columnheader">
                                    <span class="st-hour-label"><fmt:formatNumber value="${h}" pattern="00" />:00</span>
                                </div>
                            </c:forEach>
                            <c:forEach var="r" items="${rooms}">
                                <div class="st-grid-room" role="rowheader">
                                    <div class="st-grid-room-name"><c:out value="${r.name}" /></div>
                                    <div class="st-grid-room-meta">${r.roomType} &middot; ${r.capacity} seats</div>
                                </div>
                                <div class="st-grid-lane" role="gridcell">
                                    <c:forEach var="st" items="${dayShowtimes}">
                                        <c:if test="${st.roomId == r.roomId && st.status == 'SCHEDULED'}">
                                            <c:set var="sMin" value="${st.startTime.hour * 60 + st.startTime.minute}" />
                                            <c:set var="eMin" value="${st.endTime.hour * 60 + st.endTime.minute}" />
                                            <c:set var="eMin" value="${eMin <= sMin ? 1440 : eMin}" />
                                            <c:set var="sMin" value="${sMin < 540 ? 540 : sMin}" />
                                            <c:set var="isFull" value="${st.bookedSeats >= st.roomCapacity}" />
                                            <a class="st-block ${isFull ? 'st-full' : (st.roomType == 'IMAX' ? 'st-imax' : (st.roomType == 'VIP' ? 'st-vip' : 'st-std'))}"
                                               style="left:${(sMin - 540) * 100 / 900}%; width:${(eMin - sMin) * 100 / 900}%;"
                                               href="${pageContext.request.contextPath}/branch/showtimes/edit?id=${st.showtimeId}&returnDate=${selectedDate}#showtime-form"
                                               title="${st.movieTitle} — ${fn:substring(st.startTime, 11, 16)}–${fn:substring(st.endTime, 11, 16)}">
                                                <div class="st-block-title"><c:out value="${st.movieTitle}" /></div>
                                                <div class="st-block-meta">
                                                    <span class="mono">${fn:substring(st.startTime, 11, 16)}</span>
                                                    <span><fmt:formatNumber value="${st.roomCapacity > 0 ? st.bookedSeats * 100 / st.roomCapacity : 0}" maxFractionDigits="0" />%</span>
                                                </div>
                                            </a>
                                        </c:if>
                                    </c:forEach>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <%-- ===== Showtime table ===== --%>
                <div class="card lc-elev p-0 overflow-hidden" id="showtime-list">
                    <div class="table-responsive">
                        <table class="table lc-table align-middle mb-0">
                            <thead>
                                <tr>
                                    <th class="ps-3">Movie</th>
                                    <th>Room</th>
                                    <th>Start &rarr; End</th>
                                    <th>Format</th>
                                    <th>Subtitle</th>
                                    <th class="text-end">Base price</th>
                                    <th>Occupancy</th>
                                    <th>Status</th>
                                    <th class="text-end pe-3">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:if test="${empty showtimes}">
                                    <tr><td colspan="9" class="text-center text-muted py-4">
                                        No showtimes for this day. Click <strong>Add Showtime</strong> to schedule one.</td></tr>
                                </c:if>
                                <c:forEach var="st" items="${showtimes}">
                                    <c:set var="sMin" value="${st.startTime.hour * 60 + st.startTime.minute}" />
                                    <c:set var="eMin" value="${st.endTime.hour * 60 + st.endTime.minute}" />
                                    <c:set var="durMin" value="${(eMin <= sMin ? eMin + 1440 : eMin) - sMin}" />
                                    <c:set var="pct" value="${st.roomCapacity > 0 ? st.bookedSeats * 100 / st.roomCapacity : 0}" />
                                    <%-- Status dong theo thoi gian thuc (khong dua vao job set ENDED) --%>
                                    <c:set var="started" value="${not st.startTime.isAfter(nowLdt)}" />
                                    <c:set var="finished" value="${not st.endTime.isAfter(nowLdt)}" />
                                    <c:set var="manageable" value="${st.status == 'SCHEDULED' and not started}" />
                                    <tr id="showtime-${st.showtimeId}">
                                        <td class="ps-3">
                                            <div class="st-table-movie">
                                                <div class="st-table-poster">
                                                    <c:choose>
                                                        <c:when test="${not empty st.posterUrl}">
                                                            <img src="<c:url value='${st.posterUrl}'/>" alt="" loading="lazy" decoding="async">
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="st-table-poster-fallback" aria-hidden="true"><i class="bi bi-film"></i></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="st-table-movie-text">
                                                    <div class="text-navy fw-semibold small"><c:out value="${st.movieTitle}" /></div>
                                                    <div class="st-table-meta">
                                                        <fmt:formatNumber value="${durMin}" maxFractionDigits="0" /> min</div>
                                                </div>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="text-navy small fw-semibold"><c:out value="${st.roomName}" /></div>
                                            <div class="text-muted" style="font-size:.72rem;">${st.roomType}</div>
                                        </td>
                                        <td class="small text-navy fw-semibold mono">
                                            ${fn:substring(st.startTime, 11, 16)} &rarr; ${fn:substring(st.endTime, 11, 16)}</td>
                                        <td><span class="pill ${st.format == 'IMAX' ? 'pill-purple' : 'pill-blue'}">${st.format}</span></td>
                                        <td><span class="pill pill-gray">${st.subtitleType == 'SUB' ? 'Subtitled' : (st.subtitleType == 'DUB' ? 'Dubbed' : 'Original')}</span></td>
                                        <td class="text-end small fw-semibold text-navy">
                                            <fmt:formatNumber value="${st.basePrice}" pattern="#,##0" /> VND</td>
                                        <td style="min-width:130px;">
                                            <div class="d-flex justify-content-between small mb-1">
                                                <span class="text-navy fw-semibold">${st.bookedSeats}/${st.roomCapacity}</span>
                                                <span class="text-muted"><fmt:formatNumber value="${pct}" maxFractionDigits="0" />%</span>
                                            </div>
                                            <div class="bar-track">
                                                <div class="bar-fill"
                                                     style="width:${pct > 100 ? 100 : pct}%; ${pct >= 100 ? 'background:#DC3545;' : (pct > 80 ? 'background:#FD7E14;' : '')}"></div>
                                            </div>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${st.status == 'CANCELLED'}">
                                                    <span class="pill pill-red">Cancelled</span>
                                                </c:when>
                                                <%-- SCHEDULED nhung da qua gio ket thuc, hoac status ENDED --%>
                                                <c:when test="${st.status == 'ENDED' or finished}">
                                                    <span class="pill pill-gray">Ended</span>
                                                </c:when>
                                                <%-- Dang chieu: da bat dau nhung chua ket thuc --%>
                                                <c:when test="${started}">
                                                    <span class="pill pill-blue">Now showing</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="pill pill-green">Active</span>
                                                    <c:if test="${st.bookedSeats >= st.roomCapacity}">
                                                        <span class="pill pill-red ms-1">Full</span>
                                                    </c:if>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td class="text-end pe-3">
                                            <div class="d-flex gap-1 justify-content-end">
                                                <c:if test="${st.status != 'CANCELLED'}">
                                                    <a class="btn btn-sm btn-outline-info" title="Monitor occupancy"
                                                       href="${pageContext.request.contextPath}/branch/showtimes/monitor?id=${st.showtimeId}">
                                                        <i class="bi bi-eye"></i></a>
                                                </c:if>
                                                <%-- Chi suat SCHEDULED & CHUA bat dau moi sua/huy (server van verify lai) --%>
                                                <c:if test="${manageable}">
                                                    <a class="btn btn-sm btn-outline-primary" title="Edit"
                                                       href="${pageContext.request.contextPath}/branch/showtimes/edit?id=${st.showtimeId}&returnDate=${selectedDate}#showtime-form">
                                                        <i class="bi bi-pencil"></i></a>
                                                    <form method="post" class="d-inline"
                                                          action="${pageContext.request.contextPath}/branch/showtimes/cancel"
                                                          onsubmit="return confirm('Cancel this showtime?');">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                                        <input type="hidden" name="id" value="${st.showtimeId}">
                                                        <input type="hidden" name="returnDate" value="${selectedDate}">
                                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Cancel">
                                                            <i class="bi bi-x-lg"></i></button>
                                                    </form>
                                                </c:if>
                                            </div>
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
