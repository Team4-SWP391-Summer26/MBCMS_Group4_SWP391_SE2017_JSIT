<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Select Showtime – <c:out value="${movie.title}"/> – LuminaCine</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; background: #f8fafc; color: #0f172a; }

        /* ── Booking stepper ── */
        .booking-stepper {
            background: #fff;
            border-bottom: 1px solid #e2e8f0;
            padding: 0;
        }
        .stepper-inner {
            display: flex;
            align-items: center;
            gap: 0;
            max-width: 980px;
            margin: 0 auto;
            padding: 0 1rem;
            overflow-x: auto;
            scrollbar-width: none;
        }
        .stepper-inner::-webkit-scrollbar { display: none; }
        .step-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 1rem 1.25rem;
            font-size: 0.82rem;
            font-weight: 600;
            white-space: nowrap;
            color: #94a3b8;
            border-bottom: 2px solid transparent;
        }
        .step-item.active { color: #2563eb; border-bottom-color: #2563eb; }
        .step-item.done   { color: #64748b; }
        .step-num {
            width: 22px; height: 22px; border-radius: 50%;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 0.72rem; font-weight: 700; flex-shrink: 0;
            background: #e2e8f0; color: #64748b;
        }
        .step-item.active .step-num { background: #2563eb; color: #fff; }
        .step-sep { color: #e2e8f0; padding: 0 0.25rem; }

        /* ── Movie header bar ── */
        .movie-header {
            background: #0f172a;
            color: #fff;
            padding: 1rem 0;
        }
        .movie-header-inner {
            max-width: 980px; margin: 0 auto; padding: 0 1.5rem;
            display: flex; align-items: center; justify-content: space-between; gap: 1rem;
            flex-wrap: wrap;
        }
        .movie-header-left { display: flex; align-items: center; gap: 1rem; }
        .movie-thumb {
            width: 52px; height: 78px; border-radius: 6px;
            object-fit: cover; flex-shrink: 0;
        }
        .movie-thumb-placeholder {
            width: 52px; height: 78px; border-radius: 6px;
            background: #1e293b; display: flex; align-items: center; justify-content: center;
            color: #475569; font-size: 1.4rem; flex-shrink: 0;
        }
        .movie-hdr-title { font-size: 1.2rem; font-weight: 800; margin: 0 0 0.3rem; }
        .movie-hdr-meta  { font-size: 0.82rem; color: rgba(255,255,255,.6); display: flex; gap: 0.75rem; flex-wrap: wrap; }
        .rated-chip {
            font-size: 0.7rem; font-weight: 700; padding: 0.15rem 0.45rem;
            border-radius: 4px; background: #334155; color: #cbd5e1; letter-spacing: .03em;
        }
        .btn-movie-detail {
            font-size: 0.82rem; font-weight: 600;
            color: rgba(255,255,255,.7); border: 1px solid rgba(255,255,255,.2);
            border-radius: 8px; padding: 0.45rem 1rem; text-decoration: none;
            transition: all .15s;
        }
        .btn-movie-detail:hover { color: #fff; border-color: rgba(255,255,255,.5); }

        /* ── Main card ── */
        .showtime-card {
            background: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 1px 3px rgba(0,0,0,.05);
        }

        .card-header-row {
            display: flex; justify-content: space-between; align-items: flex-start;
            flex-wrap: wrap; gap: 1rem; margin-bottom: 1.5rem;
        }
        .card-main-title  { font-size: 1.3rem; font-weight: 700; color: #0f172a; margin: 0; }
        .card-sub-title   { font-size: 0.85rem; color: #64748b; margin: 0.25rem 0 0; }

        .branch-filter-select {
            height: 40px; border-radius: 8px; border: 1px solid #cbd5e1;
            font-size: 0.88rem; font-weight: 500; color: #334155; min-width: 200px;
        }

        /* Date tabs */
        .date-tabs-row {
            display: flex; gap: 0.5rem; overflow-x: auto; padding-bottom: 0.75rem;
            margin-bottom: 1.75rem; border-bottom: 2px solid #f1f5f9;
            scrollbar-width: none;
        }
        .date-tabs-row::-webkit-scrollbar { display: none; }
        .date-tab-btn {
            flex: 0 0 auto; width: 74px; height: 64px;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            border-radius: 10px; border: 1px solid #e2e8f0; background: #fff;
            cursor: pointer; user-select: none; transition: all .15s;
        }
        .date-tab-btn .day-name {
            font-size: 0.68rem; font-weight: 700; letter-spacing: .07em;
            text-transform: uppercase; color: #94a3b8; margin-bottom: 0.2rem;
        }
        .date-tab-btn .date-val { font-size: 0.93rem; font-weight: 700; color: #334155; }
        .date-tab-btn:hover:not(.active) { background: #f8fafc; border-color: #94a3b8; }
        .date-tab-btn.active { background: #2563eb; border-color: #2563eb; }
        .date-tab-btn.active .day-name { color: rgba(255,255,255,.7); }
        .date-tab-btn.active .date-val { color: #fff; }

        /* Branch block */
        .cinema-branch-block {
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 1.75rem; margin-bottom: 1.75rem;
        }
        .cinema-branch-block:last-child { border-bottom: none; padding-bottom: 0; margin-bottom: 0; }

        .cinema-title-row {
            display: flex; justify-content: space-between; align-items: flex-start;
            flex-wrap: wrap; gap: 0.5rem; margin-bottom: 1.25rem;
        }
        .cinema-name {
            font-size: 1.05rem; font-weight: 700; color: #0f172a;
            margin: 0; display: flex; align-items: center; gap: 0.4rem;
        }
        .cinema-name i { color: #2563eb; font-size: 0.95rem; }
        .cinema-address { font-size: 0.8rem; color: #64748b; margin: 0.2rem 0 0 1.55rem; }
        .map-link {
            font-size: 0.8rem; color: #2563eb; font-weight: 600; text-decoration: none;
            display: inline-flex; align-items: center; gap: 0.2rem; white-space: nowrap;
        }
        .map-link:hover { text-decoration: underline; }

        /* Room row */
        .room-row {
            display: grid; grid-template-columns: 220px 1fr;
            gap: 1.25rem; padding: 0.9rem 0; align-items: flex-start;
            border-top: 1px solid #f8fafc;
        }
        .room-row:first-of-type { border-top: none; }

        .room-details { display: flex; flex-direction: column; gap: 0.2rem; }
        .room-name-line { display: flex; align-items: center; gap: 0.5rem; flex-wrap: wrap; }
        .room-name-text { font-size: 0.92rem; font-weight: 700; color: #1e293b; }

        .room-type-badge {
            font-size: 0.63rem; font-weight: 700; padding: 0.12rem 0.48rem;
            border-radius: 999px; text-transform: uppercase; letter-spacing: .04em;
        }
        .badge-standard { background: #f1f5f9; color: #475569; border: 1px solid #e2e8f0; }
        .badge-vip      { background: #fef3c7; color: #92400e; border: 1px solid #fde68a; }
        .badge-imax     { background: #f3e8ff; color: #7c3aed; border: 1px solid #e9d5ff; }

        .room-fmt-sub   { font-size: 0.77rem; color: #94a3b8; font-weight: 500; }
        .room-price-from{ font-size: 0.78rem; color: #64748b; font-weight: 500; }

        /* Slot grid + pagination */
        .slots-outer    { display: flex; flex-direction: column; gap: 0.6rem; }
        .slots-page     { display: flex; flex-wrap: wrap; gap: 0.55rem; }
        .slots-page.hidden { display: none; }

        .slot-btn {
            display: inline-flex; flex-direction: column; align-items: center; justify-content: center;
            width: 78px; height: 50px; border-radius: 8px;
            border: 1.5px solid #2563eb; background: #fff;
            text-decoration: none; transition: all .15s; cursor: pointer;
        }
        .slot-btn .slot-time  { font-size: 0.95rem; font-weight: 700; color: #2563eb; line-height: 1.2; }
        .slot-btn .slot-price { font-size: 0.65rem; color: #3b82f6; font-weight: 500; margin-top: 1px; }
        .slot-btn:hover:not(.slot-full) { background: #2563eb; }
        .slot-btn:hover:not(.slot-full) .slot-time,
        .slot-btn:hover:not(.slot-full) .slot-price { color: #fff; }
        .slot-btn.slot-full {
            border-color: #e2e8f0; background: #f8fafc;
            pointer-events: none; cursor: not-allowed;
        }
        .slot-btn.slot-full .slot-time,
        .slot-btn.slot-full .slot-price { color: #cbd5e1; }

        /* Pager controls */
        .slots-pager {
            display: flex; align-items: center; gap: 0.4rem; margin-top: 0.25rem;
        }
        .pager-btn {
            width: 30px; height: 30px; border-radius: 6px; border: 1px solid #e2e8f0;
            background: #fff; color: #334155; font-size: 0.78rem; font-weight: 700;
            display: inline-flex; align-items: center; justify-content: center;
            cursor: pointer; transition: all .15s;
        }
        .pager-btn:hover   { border-color: #2563eb; color: #2563eb; }
        .pager-btn.active  { background: #2563eb; border-color: #2563eb; color: #fff; }
        .pager-btn.nav-btn { width: auto; padding: 0 0.6rem; font-size: 0.72rem; }

        /* Legend */
        .showtimes-legend {
            display: flex; align-items: center; gap: 1.5rem; flex-wrap: wrap;
            margin-top: 2rem; padding-top: 1.25rem; border-top: 1px solid #f1f5f9;
            font-size: 0.82rem; color: #475569;
        }
        .legend-item  { display: flex; align-items: center; gap: 0.4rem; }
        .legend-swatch { width: 15px; height: 15px; border-radius: 4px; display: inline-block; }
        .sw-standard  { background:#fff; border: 1.5px solid #cbd5e1; }
        .sw-vip       { background:#fef3c7; border: 1.5px solid #fde68a; }
        .sw-imax      { background:#f3e8ff; border: 1.5px solid #e9d5ff; }

        @media (max-width: 768px) {
            .room-row { grid-template-columns: 1fr; }
            .showtime-card { padding: 1.25rem; }
        }
    </style>
</head>
<body>

<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="movies"/>
</jsp:include>

<!-- Booking stepper -->
<div class="booking-stepper">
    <div class="stepper-inner">
        <div class="step-item active">
            <span class="step-num">1</span> Showtime
        </div>
        <span class="step-sep">›</span>
        <div class="step-item">
            <span class="step-num">2</span> Seats
        </div>
        <span class="step-sep">›</span>
        <div class="step-item">
            <span class="step-num">3</span> Food &amp; Drinks
        </div>
        <span class="step-sep">›</span>
        <div class="step-item">
            <span class="step-num">4</span> Review
        </div>
        <span class="step-sep">›</span>
        <div class="step-item">
            <span class="step-num">5</span> Payment
        </div>
        <span class="step-sep">›</span>
        <div class="step-item">
            <span class="step-num">6</span> Confirm
        </div>
    </div>
</div>

<!-- Movie header bar -->
<div class="movie-header">
    <div class="movie-header-inner">
        <div class="movie-header-left">
            <c:choose>
                <c:when test="${not empty movie.posterUrl}">
                    <img src="${movie.posterUrl}" alt="${movie.title}" class="movie-thumb">
                </c:when>
                <c:otherwise>
                    <div class="movie-thumb-placeholder"><i class="bi bi-film"></i></div>
                </c:otherwise>
            </c:choose>
            <div>
                <h2 class="movie-hdr-title"><c:out value="${movie.title}"/></h2>
                <div class="movie-hdr-meta">
                    <c:if test="${not empty movie.rated}">
                        <span class="rated-chip"><c:out value="${movie.rated}"/></span>
                    </c:if>
                    <span>${movie.durationMin} min</span>
                    <c:if test="${not empty movie.genres}">
                        <span><c:forEach var="g" items="${movie.genres}" varStatus="gs">
                            <c:out value="${g}"/><c:if test="${!gs.last}">, </c:if>
                        </c:forEach></span>
                    </c:if>
                </div>
            </div>
        </div>
        <a href="${pageContext.request.contextPath}/movies/detail?id=${movie.movieId}" class="btn-movie-detail">
            <i class="bi bi-info-circle"></i> Movie details
        </a>
    </div>
</div>

<!-- Main content -->
<div class="container py-4" style="max-width: 980px;">
    <div class="showtime-card">

        <!-- Card header -->
        <div class="card-header-row">
            <div>
                <h3 class="card-main-title">Choose a date and showtime</h3>
                <p class="card-sub-title">
                    Pick the cinema, room, and time that works for you.
                    <c:if test="${not empty branchShowtimesList}">
                        <c:set var="totalBranches" value="${fn:length(branchShowtimesList)}"/>
                        ${totalBranches} cinema<c:if test="${totalBranches != 1}">s</c:if> available.
                    </c:if>
                </p>
            </div>
            <!-- Branch filter -->
            <select class="form-select branch-filter-select" onchange="applyBranchFilter(this.value)">
                <option value="all" <c:if test="${selectedBranchId == 'all'}">selected</c:if>>All Cinemas</option>
                <c:forEach var="b" items="${allBranches}">
                    <option value="${b.branchId}"
                        <c:if test="${selectedBranchId != 'all' and b.branchId == selectedBranchId}">selected</c:if>>
                        <c:out value="${b.name}"/>
                    </option>
                </c:forEach>
            </select>
        </div>

        <!-- Date tabs -->
        <div class="date-tabs-row">
            <c:forEach var="tab" items="${dateTabs}">
                <div class="date-tab-btn ${tab.active ? 'active' : ''}"
                     onclick="selectDate('${tab.date}')">
                    <span class="day-name">${tab.day}</span>
                    <span class="date-val">${tab.label}</span>
                </div>
            </c:forEach>
        </div>

        <!-- Branch + room showtime list -->
        <c:choose>
            <c:when test="${empty branchShowtimesList}">
                <div class="text-center py-5">
                    <i class="bi bi-calendar-x" style="font-size:2.5rem; color:#cbd5e1;"></i>
                    <h5 class="mt-3 fw-semibold text-secondary">No showtimes available</h5>
                    <p class="text-muted small mb-0">Try selecting another date or cinema branch.</p>
                </div>
            </c:when>
            <c:otherwise>
                <c:forEach var="bs" items="${branchShowtimesList}" varStatus="bsLoop">
                    <div class="cinema-branch-block">

                        <!-- Branch title row -->
                        <div class="cinema-title-row">
                            <div>
                                <h4 class="cinema-name">
                                    <i class="bi bi-geo-alt-fill"></i>
                                    <c:out value="${bs.branch.name}"/>
                                </h4>
                                <div class="cinema-address">
                                    <c:out value="${bs.branch.address}"/>, <c:out value="${bs.branch.city}"/>
                                </div>
                            </div>
                            <a href="https://maps.google.com/?q=${fn:replace(bs.branch.name,' ','+')}+${fn:replace(bs.branch.address,' ','+')}"
                               target="_blank" class="map-link">
                                View on map <i class="bi bi-arrow-up-right"></i>
                            </a>
                        </div>

                        <!-- Room rows -->
                        <div class="ms-lg-3 ms-1">
                            <c:forEach var="rg" items="${bs.roomGroups}" varStatus="rgLoop">
                                <c:set var="groupId" value="rg-${bsLoop.index}-${rgLoop.index}"/>
                                <c:set var="typeBadge" value="badge-standard"/>
                                <c:if test="${fn:toUpperCase(rg.roomType) == 'VIP'}">
                                    <c:set var="typeBadge" value="badge-vip"/>
                                </c:if>
                                <c:if test="${fn:containsIgnoreCase(rg.format,'IMAX')}">
                                    <c:set var="typeBadge" value="badge-imax"/>
                                </c:if>

                                <div class="room-row">
                                    <!-- Room info -->
                                    <div class="room-details">
                                        <div class="room-name-line">
                                            <span class="room-name-text"><c:out value="${rg.roomName}"/></span>
                                            <span class="room-type-badge ${typeBadge}">
                                                <c:out value="${rg.roomType}"/>
                                            </span>
                                        </div>
                                        <span class="room-fmt-sub">
                                            <c:out value="${rg.format}"/> &bull; <c:out value="${rg.subtitleType}"/>
                                        </span>
                                        <span class="room-price-from">
                                            From <fmt:formatNumber value="${rg.minPrice}" pattern="#,##0"/>đ
                                        </span>
                                    </div>

                                    <!-- Slot pages -->
                                    <div class="slots-outer" id="${groupId}">
                                        <c:forEach var="page" items="${rg.pages}" varStatus="pgLoop">
                                            <div class="slots-page ${pgLoop.first ? '' : 'hidden'}"
                                                 data-page="${pgLoop.index}">
                                                <c:forEach var="slot" items="${page.slots}">
                                                    <c:choose>
                                                        <c:when test="${slot.full}">
                                                            <span class="slot-btn slot-full" title="Sold out">
                                                                <span class="slot-time">${slot.timeLabel}</span>
                                                                <span class="slot-price">Sold out</span>
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="${pageContext.request.contextPath}/booking/seats?showtimeId=${slot.showtimeId}"
                                                               class="slot-btn">
                                                                <span class="slot-time">${slot.timeLabel}</span>
                                                                <span class="slot-price">
                                                                    <fmt:formatNumber value="${slot.price}" pattern="#,##0"/>đ
                                                                </span>
                                                            </a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:forEach>
                                            </div>
                                        </c:forEach>

                                        <!-- Pagination controls (only if more than 1 page) -->
                                        <c:if test="${fn:length(rg.pages) > 1}">
                                            <div class="slots-pager" id="${groupId}-pager">
                                                <button class="pager-btn nav-btn"
                                                        onclick="changePage('${groupId}', -1)"
                                                        id="${groupId}-prev">&#8592;</button>
                                                <c:forEach var="pg" items="${rg.pages}" varStatus="pgS">
                                                    <button class="pager-btn ${pgS.first ? 'active' : ''}"
                                                            onclick="goPage('${groupId}', ${pgS.index})"
                                                            id="${groupId}-pg-${pgS.index}">
                                                        ${pgS.index + 1}
                                                    </button>
                                                </c:forEach>
                                                <button class="pager-btn nav-btn"
                                                        onclick="changePage('${groupId}', 1)"
                                                        id="${groupId}-next">&#8594;</button>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:forEach>
            </c:otherwise>
        </c:choose>

        <!-- Legend -->
        <div class="showtimes-legend">
            <span class="legend-item">
                <span class="legend-swatch sw-standard"></span> Standard
            </span>
            <span class="legend-item">
                <span class="legend-swatch sw-vip"></span> VIP
            </span>
            <span class="legend-item">
                <span class="legend-swatch sw-imax"></span> IMAX
            </span>
            <span class="legend-item ms-auto text-muted" style="font-size:.77rem;">
                Final price may vary based on seat type within room.
            </span>
        </div>

    </div><!-- /.showtime-card -->
</div><!-- /.container -->

<jsp:include page="../common/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    var movieId     = '${movie.movieId}';
    var selectedDate = '${selectedDate}';
    var selectedBranch = '${selectedBranchId}';

    function selectDate(dateStr) {
        window.location.href = '${pageContext.request.contextPath}/booking/showtimes'
            + '?movieId=' + movieId
            + '&date=' + dateStr
            + '&branchId=' + selectedBranch;
    }

    function applyBranchFilter(branchVal) {
        window.location.href = '${pageContext.request.contextPath}/booking/showtimes'
            + '?movieId=' + movieId
            + '&date=' + selectedDate
            + '&branchId=' + branchVal;
    }

    /* ── Slot pagination ── */
    function goPage(groupId, pageIdx) {
        var outer = document.getElementById(groupId);
        if (!outer) return;
        var pages = outer.querySelectorAll('.slots-page');
        pages.forEach(function(p) { p.classList.add('hidden'); });
        pages[pageIdx].classList.remove('hidden');
        // update pager buttons
        var pager = document.getElementById(groupId + '-pager');
        if (pager) {
            pager.querySelectorAll('.pager-btn:not(.nav-btn)').forEach(function(btn, i) {
                btn.classList.toggle('active', i === pageIdx);
            });
        }
        outer._currentPage = pageIdx;
    }

    function changePage(groupId, delta) {
        var outer = document.getElementById(groupId);
        if (!outer) return;
        var pages = outer.querySelectorAll('.slots-page');
        var cur   = outer._currentPage || 0;
        var next  = Math.max(0, Math.min(pages.length - 1, cur + delta));
        goPage(groupId, next);
    }

    // Initialise _currentPage tracker
    document.querySelectorAll('.slots-outer').forEach(function(outer) {
        outer._currentPage = 0;
    });

    // Scroll to card if hash present
    if (window.location.hash === '#showtimes') {
        document.querySelector('.showtime-card').scrollIntoView({ behavior: 'smooth' });
    }
</script>
</body>
</html>
