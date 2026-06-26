<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${movie.title} - MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        html { scroll-behavior: smooth; }
        body { background: var(--bg); }
        .det-wrap { max-width: 1100px; }

        /* ===================== HERO (mảng nền bao quanh phía trên) ===================== */
        .det-hero { position: relative; overflow: hidden; background: var(--navy); color: #fff; }
        .det-hero__bg {
            position: absolute; inset: 0; background-size: cover; background-position: center;
            filter: blur(26px); transform: scale(1.2); opacity: .4;
        }
        .det-hero__veil {
            position: absolute; inset: 0;
            background:
                linear-gradient(180deg, rgba(15,30,54,.66) 0%, rgba(15,30,54,.92) 75%, var(--navy) 100%),
                radial-gradient(820px 420px at 12% -10%, rgba(37,99,235,.32), transparent 60%);
        }
        .det-hero__inner { position: relative; z-index: 2; padding: 1.5rem 0 2.75rem; }

        .det-bc { font-size: .85rem; color: rgba(255,255,255,.6); margin-bottom: 1.6rem; }
        .det-bc a { color: rgba(255,255,255,.82); text-decoration: none; }
        .det-bc a:hover { color: #fff; text-decoration: underline; }

        .det-top { display: flex; gap: 2rem; flex-wrap: wrap; align-items: flex-start; }
        .det-poster-col { width: 240px; flex-shrink: 0; }
        .det-poster { border-radius: 14px; overflow: hidden; box-shadow: 0 24px 60px rgba(0,0,0,.55); border: 1px solid rgba(255,255,255,.12); }
        /* Khoá kích thước poster: rộng 240, cao theo tỉ lệ 2/3 -> hết bị kéo dài */
        .det-poster .poster-art { position: relative; aspect-ratio: 2 / 3; width: 100%; border-radius: 14px; overflow: hidden; }
        .det-poster .poster-art img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .det-trailer {
            margin-top: .85rem; width: 100%; display: inline-flex; align-items: center; justify-content: center; gap: .5rem;
            border: 1px solid rgba(255,255,255,.3); color: #fff; background: rgba(255,255,255,.08); border-radius: 10px;
            padding: .55rem; font-weight: 600; font-size: .9rem; text-decoration: none; transition: .15s;
        }
        .det-trailer:hover { background: rgba(255,255,255,.18); }

        .det-info { flex: 1; min-width: 300px; }
        .det-title { font-size: clamp(1.9rem, 3.6vw, 2.8rem); font-weight: 800; color: #fff; letter-spacing: -.02em; margin: 0 0 1rem; text-shadow: 0 2px 16px rgba(0,0,0,.4); }

        .det-badges { display: flex; flex-wrap: wrap; align-items: center; gap: .45rem; margin-bottom: 1rem; }
        .det-age { font-size: .72rem; font-weight: 800; padding: .24rem .55rem; border-radius: 6px; color: #fff; }
        .age-P { background: var(--primary); }
        .age-K { background: var(--success); }
        .age-T13, .age-C13 { background: #eab308; color: #1e293b; }
        .age-T16, .age-C16 { background: #f97316; }
        .age-T18, .age-C18 { background: var(--danger); }
        .b-soft { font-size: .74rem; font-weight: 600; color: rgba(255,255,255,.85); background: rgba(255,255,255,.12); border: 1px solid rgba(255,255,255,.16); padding: .22rem .6rem; border-radius: 6px; }
        .b-genre { font-size: .74rem; font-weight: 600; color: #fff; background: rgba(37,99,235,.4); border: 1px solid rgba(255,255,255,.18); padding: .22rem .6rem; border-radius: 6px; }
        .b-status { font-size: .78rem; font-weight: 600; color: #4ade80; display: inline-flex; align-items: center; gap: .35rem; margin-left: .15rem; }
        .b-status .dot { width: 7px; height: 7px; border-radius: 50%; background: #4ade80; }
        .b-status.upcoming { color: #60a5fa; }
        .b-status.upcoming .dot { background: #60a5fa; }

        .det-rating { display: flex; align-items: center; gap: .5rem; margin-bottom: 1.15rem; }
        .det-rating .stars { color: var(--gold); font-size: 1rem; display: inline-flex; gap: 1px; }
        .det-rating .score { font-weight: 800; color: #fff; }
        .det-rating .votes { color: rgba(255,255,255,.6); font-size: .85rem; }

        .det-credits { font-size: .9rem; color: rgba(255,255,255,.82); margin-bottom: 1.5rem; line-height: 1.8; }
        .det-credits .lbl { font-weight: 700; color: #fff; }

        .det-actions { display: flex; flex-wrap: wrap; gap: .6rem; }
        .det-book { border-radius: 10px; padding: .65rem 1.6rem; font-weight: 600; display: inline-flex; align-items: center; gap: .5rem; }
        .det-save {
            border-radius: 10px; padding: .65rem 1.3rem; font-weight: 600; background: rgba(255,255,255,.1); color: #fff;
            border: 1px solid rgba(255,255,255,.3); display: inline-flex; align-items: center; gap: .5rem; cursor: pointer; transition: .15s;
        }
        .det-save:hover { background: rgba(255,255,255,.2); }

        /* ===================== Light sections ===================== */
        .det-h2 { font-size: 1.3rem; font-weight: 800; color: var(--text); margin: 0 0 .9rem; }
        .det-syn p { color: var(--text-muted); line-height: 1.8; max-width: 780px; margin: 0; }

        #showtimes { scroll-margin-top: 1rem; }
        .det-showtimes { margin-top: 2.75rem; }
        .st-head { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem; margin-bottom: 1.25rem; }
        .st-select { width: 210px; max-width: 100%; height: 40px; border-radius: 8px; border: 1px solid var(--border-strong); font-size: .88rem; color: var(--text); }

        .st-dates { display: flex; gap: .5rem; overflow-x: auto; padding-bottom: .4rem; margin-bottom: 1.5rem; }
        .st-date {
            flex: 0 0 auto; min-width: 62px; padding: .45rem .65rem; border-radius: 10px;
            border: 1px solid var(--border); background: #fff; text-align: center; cursor: pointer; line-height: 1.25; transition: .15s;
        }
        .st-date .d { display: block; font-size: .64rem; font-weight: 700; text-transform: uppercase; color: var(--text-subtle); }
        .st-date .n { display: block; font-size: .84rem; font-weight: 800; color: var(--text); }
        .st-date:hover:not(.active) { border-color: var(--primary); }
        .st-date.active { background: var(--navy); border-color: var(--navy); }
        .st-date.active .d, .st-date.active .n { color: #fff; }

        .st-branch { background: #fff; border: 1px solid var(--border); border-radius: 14px; box-shadow: var(--shadow-sm); padding: 1.25rem 1.4rem; margin-bottom: 1rem; }
        .st-branch:last-of-type { margin-bottom: 0; }
        .st-branch__top { display: flex; justify-content: space-between; align-items: flex-start; gap: .5rem; margin-bottom: 1rem; }
        .st-branch__name { font-size: 1rem; font-weight: 700; color: var(--text); margin: 0; display: flex; align-items: center; gap: .45rem; }
        .st-branch__name i { color: var(--primary); }
        .st-branch__addr { font-size: .8rem; color: var(--text-muted); margin: .15rem 0 0 1.45rem; }
        .st-map { font-size: .8rem; color: var(--primary); font-weight: 600; text-decoration: none; white-space: nowrap; display: inline-flex; align-items: center; gap: .25rem; }
        .st-map:hover { text-decoration: underline; }

        .st-room { display: flex; align-items: center; gap: 1.25rem; padding: .85rem 0; border-top: 1px solid var(--surface-2); flex-wrap: wrap; }
        .st-room:first-of-type { border-top: none; padding-top: .15rem; }
        .st-room__info { width: 215px; flex-shrink: 0; }
        .st-room__name { font-size: .88rem; font-weight: 700; color: var(--text); }
        .st-room__price { font-size: .76rem; color: var(--text-muted); margin-top: .1rem; }
        .st-slots { display: flex; flex-wrap: wrap; gap: .55rem; }
        .st-slot {
            display: inline-flex; flex-direction: column; align-items: center; justify-content: center;
            min-width: 78px; padding: .4rem .65rem; border-radius: 9px; border: 1px solid var(--primary);
            background: #fff; color: var(--primary); text-decoration: none; transition: .15s;
        }
        .st-slot .t { font-size: .92rem; font-weight: 800; line-height: 1; }
        .st-slot .p { font-size: .64rem; font-weight: 500; margin-top: .2rem; color: var(--text-muted); }
        .st-slot:hover:not(.is-full) { background: var(--primary); color: #fff; transform: translateY(-1px); }
        .st-slot:hover:not(.is-full) .p { color: rgba(255, 255, 255, .85); }
        .st-slot.is-full { border-color: var(--border-strong); color: var(--text-subtle); background: var(--surface-2); cursor: not-allowed; pointer-events: none; }
        .st-slot.is-full .p { color: var(--text-subtle); }

        .st-empty { text-align: center; padding: 3rem 1rem; color: var(--text-muted); background: #fff; border: 1px solid var(--border); border-radius: 14px; }
        .st-empty i { font-size: 2.5rem; color: var(--border-strong); display: block; margin-bottom: .6rem; }

        .st-legend { display: flex; flex-wrap: wrap; gap: 1.25rem; margin-top: 1.35rem; font-size: .8rem; color: var(--text-muted); }
        .st-legend .item { display: flex; align-items: center; gap: .4rem; }
        .st-legend .sw { width: 14px; height: 14px; border-radius: 4px; border: 1.5px solid var(--border-strong); background: #fff; }
        .st-legend .sw.vip { border-color: #f59e0b; }
        .st-legend .sw.imax { border-color: #c084fc; }

        @media (max-width: 575px) {
            .det-poster-col { width: 100%; max-width: 240px; margin: 0 auto; }
            .st-room__info { width: 100%; }
        }
    </style>
</head>
<body>

    <jsp:include page="../common/header.jsp">
        <jsp:param name="activeMenu" value="movies" />
    </jsp:include>

    <%-- Deterministic demo rating/votes --%>
    <c:set var="ratingVal" value="${7.8 + (movie.movieId % 17) / 10.0}" />
    <c:set var="votesVal" value="${350 + (movie.movieId * 149) % 1500}" />
    <c:set var="ratingStr"><fmt:formatNumber value="${ratingVal}" pattern="0.0" /></c:set>
    <c:set var="votesStr"><fmt:formatNumber value="${votesVal}" pattern="#,##0" /></c:set>

    <%-- ===================== HERO ===================== --%>
    <section class="det-hero">
        <c:if test="${not empty movie.posterUrl}">
            <div class="det-hero__bg" style="background-image:url('<c:url value="${movie.posterUrl}"/>');"></div>
        </c:if>
        <div class="det-hero__veil"></div>

        <div class="det-hero__inner">
            <div class="container det-wrap">
                <div class="det-bc">
                    <a href="${pageContext.request.contextPath}/home">Home</a> /
                    <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Movies</a> /
                    <span><c:out value="${movie.title}"/></span>
                </div>

                <div class="det-top">
                    <div class="det-poster-col">
                        <div class="det-poster">
                            <jsp:include page="../common/_poster.jsp">
                                <jsp:param name="movieId" value="${movie.movieId}" />
                                <jsp:param name="title" value="${movie.title}" />
                                <jsp:param name="posterUrl" value="${movie.posterUrl}" />
                            </jsp:include>
                        </div>
                        <c:if test="${not empty movie.trailerUrl}">
                            <a href="${movie.trailerUrl}" target="_blank" class="det-trailer">
                                <i class="bi bi-play-fill"></i> Watch Trailer
                            </a>
                        </c:if>
                    </div>

                    <div class="det-info">
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
                                <c:out value="${movie.status == 'NOW_SHOWING' ? 'Now Showing' : 'Upcoming'}"/>
                            </span>
                        </div>

                        <div class="det-rating">
                            <span class="stars">
                                <c:forEach var="i" begin="1" end="5">
                                    <c:choose>
                                        <c:when test="${ratingVal >= (i * 2)}"><i class="bi bi-star-fill"></i></c:when>
                                        <c:when test="${ratingVal >= (i * 2 - 1)}"><i class="bi bi-star-half"></i></c:when>
                                        <c:otherwise><i class="bi bi-star"></i></c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </span>
                            <span class="score">${ratingStr}/10</span>
                            <span class="votes">(${votesStr})</span>
                        </div>

                        <div class="det-credits">
                            <div class="row g-1">
                                <div class="col-md-7"><span class="lbl">Director:</span> <c:out value="${not empty movie.director ? movie.director : 'N/A'}"/></div>
                                <div class="col-md-5"><span class="lbl">Language:</span> <c:out value="${not empty movie.language ? movie.language : 'English'}"/></div>
                                <div class="col-12"><span class="lbl">Cast:</span> <c:out value="${not empty movie.castList ? movie.castList : 'N/A'}"/></div>
                            </div>
                        </div>

                        <div class="det-actions">
                            <a href="#showtimes" class="btn btn-primary det-book">
                                <i class="bi bi-ticket-perforated-fill"></i> Book Tickets
                            </a>
                            <button type="button" class="det-save">
                                <i class="bi bi-bookmark"></i> Save
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <%-- ===================== Light content ===================== --%>
    <main class="container det-wrap py-4 py-lg-5">

        <section class="det-syn">
            <h2 class="det-h2">Synopsis</h2>
            <p><c:out value="${movie.description}"/></p>
        </section>

        <section class="det-showtimes" id="showtimes">
            <div class="st-head">
                <h2 class="det-h2 mb-0">Available Showtimes</h2>
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
                                        <div class="st-room__name">${rg.roomName} &bull; ${rg.roomType} &bull; ${rg.format} ${rg.subtitleType}</div>
                                        <div class="st-room__price">From <fmt:formatNumber value="${rg.minPrice}" pattern="#,##0"/>đ</div>
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
                                                    <a href="${pageContext.request.contextPath}/booking/seats?showtimeId=${slot.showtimeId}" class="st-slot" data-start="${selectedDate}T${slot.time}">
                                                        <span class="t">${slot.time}</span>
                                                        <span class="p"><fmt:formatNumber value="${slot.price}" pattern="#,##0"/>đ</span>
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
                <div class="item"><span class="sw"></span> Standard 80,000đ</div>
                <div class="item"><span class="sw vip"></span> VIP 140,000đ</div>
                <div class="item"><span class="sw imax"></span> IMAX 100,000đ</div>
            </div>
        </section>

    </main>

    <jsp:include page="../common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Tô xám + khoá các suất đã qua giờ chiếu (so với giờ hiện tại của máy)
        document.querySelectorAll('.st-slot[data-start]').forEach(function (el) {
            var d = new Date(el.getAttribute('data-start'));
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
