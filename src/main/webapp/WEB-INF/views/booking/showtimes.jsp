<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Select Showtime – <c:out value="${movie.title}"/> – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/booking.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body>

<jsp:include page="../common/header.jsp">
    <jsp:param name="activeMenu" value="movies"/>
</jsp:include>

<!-- Movie header bar -->
<div class="movie-header">
    <div class="movie-header-inner">
        <div class="movie-header-left">
            <c:choose>
                <c:when test="${not empty movie.posterUrl}">
                    <img src="<c:url value='${movie.posterUrl}'/>" alt="<c:out value='${movie.title}'/>" class="movie-thumb"
                         onerror="this.onerror=null; this.classList.add('d-none'); this.insertAdjacentHTML('afterend', '<div class=\'movie-thumb-placeholder\'><i class=\'bi bi-film\'></i></div>');">
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

<!-- Booking stepper -->
<div class="container bk-wrap-sm pt-4">
    <div class="bk-steps is-card">
        <div class="bk-step active"><span class="bk-dot">1</span><span>Showtime</span></div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">2</span><span>Seats</span></div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">3</span><span>Food &amp; Drinks</span></div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">4</span><span>Review</span></div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">5</span><span>Payment</span></div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">6</span><span>Confirm</span></div>
    </div>
</div>

<!-- Main content -->
<div class="container bk-wrap-sm py-4">
    <div class="showtime-card" id="showtimes">

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
                    <i class="bi bi-calendar-x lc-empty-icon"></i>
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
                                            <c:out value="${rg.format}"/> &bull;
                                            <c:choose>
                                                <c:when test="${rg.subtitleType eq 'SUB'}">Subtitled</c:when>
                                                <c:when test="${rg.subtitleType eq 'DUB'}">Dubbed</c:when>
                                                <c:when test="${rg.subtitleType eq 'ORIGINAL'}">Original</c:when>
                                                <c:otherwise><c:out value="${rg.subtitleType}"/></c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span class="room-price-from">
                                            From <fmt:formatNumber value="${rg.minPrice}" pattern="#,##0"/> VND
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
                                                                    <fmt:formatNumber value="${slot.price}" pattern="#,##0"/> VND
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
            <span class="legend-item ms-auto text-muted showtimes-legend-note">
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
            + '&branchId=' + selectedBranch
            + '#showtimes';
    }

    function applyBranchFilter(branchVal) {
        window.location.href = '${pageContext.request.contextPath}/booking/showtimes'
            + '?movieId=' + movieId
            + '&date=' + selectedDate
            + '&branchId=' + branchVal
            + '#showtimes';
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
        document.getElementById('showtimes').scrollIntoView({ behavior: 'smooth' });
    }
</script>
</body>
</html>
