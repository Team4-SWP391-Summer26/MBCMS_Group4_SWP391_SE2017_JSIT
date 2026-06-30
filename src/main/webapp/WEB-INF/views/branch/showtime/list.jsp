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
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="showtimes" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1240px;">

                <%-- ===== Page header ===== --%>
                <div class="mb-3">
                    <div class="text-muted small mb-1">Dashboard / Showtimes</div>
                    <h4 class="text-navy fw-bold mb-0">Showtime Management</h4>
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

                <%-- ===== Toolbar: date pills + filters + Add ===== --%>
                <div class="d-flex align-items-center flex-wrap gap-2 mb-3">
                    <div class="d-flex gap-2 flex-wrap">
                        <c:forEach var="d" items="${datePills}">
                            <a class="date-pill ${selectedDate == d.iso ? 'active' : ''}"
                               href="${pageContext.request.contextPath}/branch/showtimes?date=${d.iso}${empty filterMovieId ? '' : '&movieId='}${filterMovieId}${empty filterRoomId ? '' : '&roomId='}${filterRoomId}">
                                <div class="d-day">${d.day}</div>
                                <div class="d-num">${d.dm}</div>
                            </a>
                        </c:forEach>
                    </div>
                    <%-- Chon ngay xa hon 7 ngay --%>
                    <form method="get" action="${pageContext.request.contextPath}/branch/showtimes" class="d-flex">
                        <input type="date" class="form-control form-control-sm" name="date"
                               value="${selectedDate}" onchange="this.form.submit()"
                               style="min-width:140px;" title="Pick another date">
                    </form>
                    <div class="ms-auto d-flex gap-2">
                        <form method="get" action="${pageContext.request.contextPath}/branch/showtimes"
                              class="d-flex gap-2">
                            <input type="hidden" name="date" value="${selectedDate}">
                            <select class="form-select form-select-sm" name="movieId" style="min-width:160px;"
                                    onchange="this.form.submit()">
                                <option value="">All Movies</option>
                                <c:forEach var="m" items="${movies}">
                                    <option value="${m.movieId}" ${filterMovieId == m.movieId ? 'selected' : ''}>
                                        <c:out value="${m.title}" /></option>
                                    </c:forEach>
                            </select>
                            <select class="form-select form-select-sm" name="roomId" style="min-width:150px;"
                                    onchange="this.form.submit()">
                                <option value="">All Rooms</option>
                                <c:forEach var="r" items="${rooms}">
                                    <option value="${r.roomId}" ${filterRoomId == r.roomId ? 'selected' : ''}>
                                        <c:out value="${r.name}" /> &middot; ${r.roomType}</option>
                                    </c:forEach>
                            </select>
                        </form>
                        <a class="btn btn-primary btn-sm d-flex align-items-center" href="${pageContext.request.contextPath}/branch/showtimes/create">
                            <i class="bi bi-plus-lg me-1"></i>Add Showtime</a>
                    </div>
                </div>

                <%-- ===== KPI cards (tinh tu du lieu showtime cua ngay dang chon) ===== --%>
                <div class="row g-3 mb-3">
                    <div class="col-md-3 col-6">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#E7F0FF; color:#0D6EFD;">
                                    <i class="bi bi-collection-play"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Showtimes</div>
                                    <div class="text-navy fw-bold" style="font-size:1.4rem;">${kpiCount}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#E8F5EE; color:#198754;">
                                    <i class="bi bi-people"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Seats sold</div>
                                    <div class="text-navy fw-bold" style="font-size:1.4rem;">${kpiSeatsSold}</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-6">
                        <div class="card lc-elev p-3 h-100">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#ECE3F8; color:#6F42C1;">
                                    <i class="bi bi-pie-chart"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Avg occupancy</div>
                                    <div class="text-navy fw-bold" style="font-size:1.4rem;">${kpiOccupancy}%</div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <%-- Revenue thuoc module Reports (AnhND) - giu cho, khong fake so lieu --%>
                    <div class="col-md-3 col-6">
                        <div class="card lc-elev p-3 h-100" style="opacity:.6;">
                            <div class="d-flex align-items-center gap-3">
                                <div class="lc-stat-icon" style="background:#EEF1F4; color:var(--text-subtle);">
                                    <i class="bi bi-cash-stack"></i></div>
                                <div>
                                    <div class="text-muted small fw-semibold">Revenue</div>
                                    <div class="text-muted fw-bold" style="font-size:1.4rem;">&mdash;</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <%-- ===== Schedule timeline theo phong (09:00 - 24:00) ===== --%>
                <div class="card lc-elev p-4 mb-3">
                    <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-3">
                        <div>
                            <h6 class="text-navy fw-bold mb-1">Schedule timeline &mdash; ${selectedDateLong}</h6>
                            <p class="text-muted small mb-0">Each block is a scheduled showtime. Click a block to edit.</p>
                        </div>
                        <div class="d-flex gap-3 small text-muted align-items-center">
                            <span class="d-inline-flex align-items-center gap-1"><span class="tl-legend" style="background:#0D6EFD;"></span> Standard</span>
                            <span class="d-inline-flex align-items-center gap-1"><span class="tl-legend" style="background:#C9A227;"></span> VIP</span>
                            <span class="d-inline-flex align-items-center gap-1"><span class="tl-legend" style="background:#6F42C1;"></span> IMAX</span>
                            <span class="d-inline-flex align-items-center gap-1"><span class="tl-legend" style="background:#DC3545;"></span> Full</span>
                        </div>
                    </div>

                    <div class="tl-wrap">
                        <div class="tl-inner">
                            <%-- Thuoc do gio 09:00 -> 23:00 --%>
                            <div class="tl-scale">
                                <c:forEach var="h" begin="9" end="23">
                                    <span><fmt:formatNumber value="${h}" pattern="00" />:00</span>
                                </c:forEach>
                            </div>
                            <c:forEach var="r" items="${rooms}">
                                <div class="tl-row">
                                    <div class="tl-roomcol">
                                        <div class="text-navy fw-bold small"><c:out value="${r.name}" /></div>
                                        <div class="text-muted" style="font-size:.72rem;">${r.roomType} &middot; ${r.capacity} seats</div>
                                    </div>
                                    <div class="tl-canvas">
                                        <c:forEach var="h" begin="9" end="23">
                                            <div class="tl-gridline" style="left:${(h - 9) * 100 / 15}%;"></div>
                                        </c:forEach>
                                        <c:forEach var="st" items="${dayShowtimes}">
                                            <c:if test="${st.roomId == r.roomId && st.status == 'SCHEDULED'}">
                                                <%-- Cua so timeline: 09:00 (540') -> 24:00 (1440'), span 900' --%>
                                                <c:set var="sMin" value="${st.startTime.hour * 60 + st.startTime.minute}" />
                                                <c:set var="eMin" value="${st.endTime.hour * 60 + st.endTime.minute}" />
                                                <c:set var="eMin" value="${eMin <= sMin ? 1440 : eMin}" />
                                                <c:set var="sMin" value="${sMin < 540 ? 540 : sMin}" />
                                                <c:set var="isFull" value="${st.bookedSeats >= st.roomCapacity}" />
                                                <a class="tl-block ${isFull ? 'tl-full' : (st.roomType == 'IMAX' ? 'tl-imax' : (st.roomType == 'VIP' ? 'tl-vip' : 'tl-std'))}"
                                                   style="left:${(sMin - 540) * 100 / 900}%; width:${(eMin - sMin) * 100 / 900}%;"
                                                   href="${pageContext.request.contextPath}/branch/showtimes/edit?id=${st.showtimeId}"
                                                   title="${st.movieTitle} — ${fn:substring(st.startTime, 11, 16)}–${fn:substring(st.endTime, 11, 16)}">
                                                    <div class="tl-title"><c:out value="${st.movieTitle}" /></div>
                                                    <div class="d-flex justify-content-between" style="opacity:.85;">
                                                        <span class="mono">${fn:substring(st.startTime, 11, 16)}</span>
                                                        <span><fmt:formatNumber value="${st.roomCapacity > 0 ? st.bookedSeats * 100 / st.roomCapacity : 0}" maxFractionDigits="0" />%</span>
                                                    </div>
                                                </a>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </div>

                <%-- ===== Showtime table ===== --%>
                <div class="card lc-elev p-0 overflow-hidden">
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
                                    <tr>
                                        <td class="ps-3">
                                            <div class="text-navy fw-semibold small"><c:out value="${st.movieTitle}" /></div>
                                            <div class="text-muted" style="font-size:.72rem;">
                                                <fmt:formatNumber value="${durMin}" maxFractionDigits="0" /> min</div>
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
                                                        href="${pageContext.request.contextPath}/branch/showtimes/edit?id=${st.showtimeId}">
                                                         <i class="bi bi-pencil"></i></a>
                                                         <%-- Cancel = POST (hanh dong doi du lieu) + confirm --%>
                                                     <form method="post" class="d-inline"
                                                           action="${pageContext.request.contextPath}/branch/showtimes/cancel"
                                                           onsubmit="return confirm('Cancel this showtime?');">
                                                         <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                                         <input type="hidden" name="id" value="${st.showtimeId}">
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

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
