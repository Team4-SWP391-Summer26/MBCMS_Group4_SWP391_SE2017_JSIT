<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${movie.title} - PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/movie-detail.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="movie-detail-page">

    <jsp:include page="../common/header.jsp">
        <jsp:param name="activeMenu" value="movies" />
    </jsp:include>

    <%-- ===================== HERO ===================== --%>
    <section class="det-hero">
        <c:if test="${not empty movie.posterUrl}">
            <div class="det-hero__bg" aria-hidden="true">
                <img class="det-hero__bg-img det-hero__bg-img--ambient"
                     src="<c:url value='${movie.posterUrl}'/>" alt="">
                <img class="det-hero__bg-img det-hero__bg-img--texture"
                     src="<c:url value='${movie.posterUrl}'/>" alt="" aria-hidden="true">
            </div>
        </c:if>
        <div class="det-hero__veil"></div>
        <div class="det-hero__grain" aria-hidden="true"></div>

        <div class="det-hero__inner">
            <div class="container public-shell det-wrap">
                <nav class="det-bc md-reveal" style="--i:0" aria-label="Breadcrumb">
                    <a href="${pageContext.request.contextPath}/home">Home</a>
                    <span class="sep" aria-hidden="true">/</span>
                    <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Movies</a>
                    <span class="sep" aria-hidden="true">/</span>
                    <span class="current"><c:out value="${movie.title}"/></span>
                </nav>

                <div class="det-top">
                    <div class="det-poster-col md-reveal" style="--i:1">
                        <div class="det-poster">
                            <jsp:include page="../common/_poster.jsp">
                                <jsp:param name="movieId" value="${movie.movieId}" />
                                <jsp:param name="title" value="${movie.title}" />
                                <jsp:param name="posterUrl" value="${movie.posterUrl}" />
                            </jsp:include>
                        </div>
                        <c:if test="${not empty movie.trailerUrl}">
                            <a href="${movie.trailerUrl}" target="_blank" rel="noopener noreferrer" class="det-trailer">
                                <i class="bi bi-play-fill"></i> Trailer
                            </a>
                        </c:if>
                    </div>

                    <div class="det-info md-reveal" style="--i:2">
                        <h1 class="det-title"><c:out value="${movie.title}"/></h1>

                        <div class="det-badges">
                            <span class="det-age age-${movie.rated}"><c:out value="${movie.rated}"/></span>
                            <span class="b-soft">${fn:substring(movie.releaseDate, 0, 4)}</span>
                            <span class="b-soft">${movie.durationMin} min</span>
                            <c:forEach var="g" items="${movie.genres}">
                                <span class="b-genre">${g}</span>
                            </c:forEach>
                            <span class="b-status ${movie.status == 'NOW_SHOWING' ? '' : 'upcoming'}">
                                <span class="dot"></span>
                                <c:choose>
                                    <c:when test="${movie.status == 'NOW_SHOWING'}">Now Showing</c:when>
                                    <c:when test="${movie.status == 'UPCOMING'}">Upcoming</c:when>
                                    <c:when test="${movie.status == 'ENDED'}">Ended</c:when>
                                    <c:otherwise><c:out value="${movie.status}"/></c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <div class="det-meta-grid">
                            <div class="det-meta-item">
                                <span class="lbl">Director</span>
                                <span class="val"><c:out value="${not empty movie.director ? movie.director : 'N/A'}"/></span>
                            </div>
                            <div class="det-meta-item">
                                <span class="lbl">Language</span>
                                <span class="val"><c:out value="${not empty movie.language ? movie.language : 'English'}"/></span>
                            </div>
                            <c:if test="${not empty availableFormats or not empty availableSubtitleTypes}">
                                <div class="det-meta-item det-meta-item--wide">
                                    <span class="lbl">Screening options</span>
                                    <div class="det-opt-chips">
                                        <c:forEach var="fmt" items="${availableFormats}">
                                            <span class="det-opt-chip det-opt-chip--fmt"><c:out value="${fmt}"/></span>
                                        </c:forEach>
                                        <c:forEach var="sub" items="${availableSubtitleTypes}">
                                            <span class="det-opt-chip det-opt-chip--sub">
                                                <c:choose>
                                                    <c:when test="${sub eq 'SUB'}">Subtitled</c:when>
                                                    <c:when test="${sub eq 'DUB'}">Dubbed</c:when>
                                                    <c:when test="${sub eq 'ORIGINAL'}">Original audio</c:when>
                                                    <c:otherwise><c:out value="${sub}"/></c:otherwise>
                                                </c:choose>
                                            </span>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                            <div class="det-meta-item det-meta-item--wide">
                                <span class="lbl">Cast</span>
                                <span class="val"><c:out value="${not empty movie.castList ? movie.castList : 'N/A'}"/></span>
                            </div>
                        </div>

                        <div class="det-actions">
                            <c:choose>
                                <c:when test="${showtimesAvailable}">
                                    <a href="#showtimes" class="btn btn-primary det-book">
                                        <i class="bi bi-ticket-perforated-fill"></i> Book Tickets
                                    </a>
                                </c:when>
                                <c:when test="${movie.status == 'UPCOMING'}">
                                    <span class="btn btn-secondary det-book disabled" aria-disabled="true">
                                        <i class="bi bi-clock"></i> Coming soon
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="btn btn-secondary det-book disabled" aria-disabled="true">
                                        <i class="bi bi-calendar-x"></i> Not available
                                    </span>
                                </c:otherwise>
                            </c:choose>
                            <button type="button" class="det-save" disabled aria-disabled="true" title="Coming soon">
                                <i class="bi bi-bookmark"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- ===================== Light content ===================== --%>
    <main class="container public-shell det-wrap movie-detail-main">

        <section class="det-syn md-reveal" style="--i:3">
            <span class="det-kicker"><i class="bi bi-card-text"></i> Story</span>
            <h2 class="det-h2">Synopsis</h2>
            <p><c:out value="${movie.description}"/></p>
        </section>

        <c:choose>
            <c:when test="${showtimesAvailable}">
        <section class="det-showtimes md-reveal" style="--i:4" id="showtimes">
            <div class="st-head">
                <div class="st-head__copy">
                    <span class="det-kicker"><i class="bi bi-calendar-week"></i> Schedule</span>
                    <h2 class="det-h2 mb-0">Available Showtimes</h2>
                    <p class="st-sub">Pick a date and cinema branch to start booking.</p>
                </div>
                <select class="form-select st-select" onchange="selectBranch(this.value)">
                    <option value="all">All Cinemas</option>
                    <c:forEach var="b" items="${branches}">
                        <option value="${b.branchId}" <c:if test="${selectedBranchId != 'all' and selectedBranchId == b.branchId}">selected</c:if>>${b.name}</option>
                    </c:forEach>
                </select>
            </div>

            <div class="st-dates">
                <c:forEach var="tab" items="${dateTabs}">
                    <div class="st-date ${tab.active ? 'active' : ''}" onclick="selectDate('${tab.date}')">
                        <span class="d">${tab.day}</span>
                        <span class="n">${tab.label}</span>
                    </div>
                </c:forEach>
            </div>

            <c:choose>
                <c:when test="${empty branchShowtimesList}">
                    <div class="st-empty">
                        <i class="bi bi-calendar-x"></i>
                        <h5 class="fw-bold">No showtimes for this date</h5>
                        <p class="small mb-0">Please pick another date or cinema.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="bs" items="${branchShowtimesList}">
                        <div class="st-branch">
                            <div class="st-branch__top">
                                <div>
                                    <h3 class="st-branch__name"><i class="bi bi-geo-alt-fill"></i> <c:out value="${bs.branch.name}"/></h3>
                                    <div class="st-branch__addr"><c:out value="${bs.branch.address}"/>, <c:out value="${bs.branch.city}"/></div>
                                </div>
                                <a href="https://maps.google.com/?q=${bs.branch.name} ${bs.branch.address}" target="_blank" class="st-map">
                                    View on map <i class="bi bi-arrow-up-right"></i>
                                </a>
                            </div>

                            <c:forEach var="rg" items="${bs.roomGroups}">
                                <div class="st-room">
                                    <div class="st-room__info">
                                        <div class="st-room__name">
                                            <c:out value="${rg.roomName}"/>
                                            <span class="st-room__type"><c:out value="${rg.roomType}"/></span>
                                        </div>
                                        <div class="st-room__opts">
                                            <span class="st-opt st-opt--fmt"><c:out value="${rg.format}"/></span>
                                            <span class="st-opt st-opt--sub">
                                                <c:choose>
                                                    <c:when test="${rg.subtitleType eq 'SUB'}">Subtitled</c:when>
                                                    <c:when test="${rg.subtitleType eq 'DUB'}">Dubbed</c:when>
                                                    <c:when test="${rg.subtitleType eq 'ORIGINAL'}">Original</c:when>
                                                    <c:otherwise><c:out value="${rg.subtitleType}"/></c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="st-room__price">From <fmt:formatNumber value="${rg.minPrice}" pattern="#,##0"/> VND</div>
                                    </div>
                                    <div class="st-slots">
                                        <c:forEach var="slot" items="${rg.slots}">
                                            <c:choose>
                                                <c:when test="${slot.full}">
                                                    <span class="st-slot is-full" title="Sold out">
                                                        <span class="t">${slot.time}</span>
                                                        <span class="p">Full</span>
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <a href="${pageContext.request.contextPath}/booking/seats?showtimeId=${slot.showtimeId}" class="st-slot" data-start="${slot.startIso}">
                                                        <span class="t">${slot.time}</span>
                                                        <span class="p"><fmt:formatNumber value="${slot.price}" pattern="#,##0"/> VND</span>
                                                    </a>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>

            <div class="st-legend">
                <div class="item"><span class="sw"></span> Standard base price</div>
                <div class="item"><span class="sw vip"></span> VIP +${vipSurchargePercent}%</div>
                <div class="item"><span class="sw imax"></span> IMAX format</div>
            </div>
        </section>
            </c:when>
            <c:otherwise>
        <section class="det-showtimes md-reveal" style="--i:4" id="showtimes">
            <div class="st-empty">
                <i class="bi bi-calendar-x"></i>
                <c:choose>
                    <c:when test="${movie.status == 'UPCOMING'}">
                        <h5 class="fw-bold">Coming soon</h5>
                        <p class="small mb-0">Showtimes will be available when this movie is released.</p>
                    </c:when>
                    <c:otherwise>
                        <h5 class="fw-bold">Showtimes unavailable</h5>
                        <p class="small mb-0">This movie is no longer showing in cinemas.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
            </c:otherwise>
        </c:choose>

    </main>

    <jsp:include page="../common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Gray out past slots. data-start is ISO local (yyyy-MM-ddTHH:mm:ss).
        document.querySelectorAll('.st-slot[data-start]').forEach(function (el) {
            var raw = el.getAttribute('data-start');
            if (!raw) return;
            var d = new Date(raw);
            if (isNaN(d.getTime())) {
                // Fallback: treat as local wall time without Z
                d = new Date(raw.replace(' ', 'T'));
            }
            if (!isNaN(d.getTime()) && d.getTime() < Date.now()) {
                el.classList.add('is-full');
                el.removeAttribute('href');
                var p = el.querySelector('.p');
                if (p) p.textContent = 'Ended';
            }
        });

        function selectDate(dateStr) {
            var movieId = '${movie.movieId}';
            var branchId = '${selectedBranchId}';
            window.location.href = '${pageContext.request.contextPath}/movies/detail?id=' + movieId + '&date=' + dateStr + '&branchId=' + branchId + '#showtimes';
        }
        function selectBranch(branchIdVal) {
            var movieId = '${movie.movieId}';
            var dateStr = '${selectedDate}';
            window.location.href = '${pageContext.request.contextPath}/movies/detail?id=' + movieId + '&date=' + dateStr + '&branchId=' + branchIdVal + '#showtimes';
        }
    </script>
</body>
</html>
