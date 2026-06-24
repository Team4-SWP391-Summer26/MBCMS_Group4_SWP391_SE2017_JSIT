<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>MBCMS - Home</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* ===== Home styles — aligned to app shell (header/footer) tokens ===== */
            body { background: #f4f6fa; color: #0f1e36; }
            .hero-title, .section-title { letter-spacing: -0.02em; }

            /* ===== Hero ===== */
            /* Hero background — exact LuminaCine prototype gradient (blue + warm gold glow) */
            .hero-banner {
                color: #fff;
                padding: clamp(1.75rem, 3vw, 2.75rem) 0;
                position: relative;
                overflow: hidden;
                background:
                    radial-gradient(900px 480px at 20% -10%, rgba(37, 99, 235, .30), transparent 60%),
                    radial-gradient(700px 420px at 90% 10%, rgba(255, 214, 107, .24), transparent 60%),
                    linear-gradient(180deg, #0B1A33 0%, #15294a 60%, #1E3A5F 100%);
            }
            .hero-banner .container { position: relative; z-index: 1; }
            .hero-eyebrow {
                display: inline-flex; align-items: center; gap: .5rem;
                padding: .35rem .8rem; border-radius: 999px;
                font-size: .72rem; font-weight: 700; letter-spacing: .1em; text-transform: uppercase;
                background: rgba(255, 255, 255, .10); color: #fff; border: 1px solid rgba(255, 255, 255, .18);
                margin-bottom: 1.25rem;
            }
            .hero-eyebrow i { color: #FFC107; }
            .hero-title { font-size: clamp(2.4rem, 4.6vw, 3.6rem); font-weight: 800; line-height: 1.06; margin-bottom: 1.1rem; }
            .hero-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; margin-bottom: 1.4rem; font-size: .9rem; color: rgba(255, 255, 255, .78); }
            .hero-meta .dot { opacity: .35; }
            .hero-genre { padding: .22rem .7rem; border-radius: 999px; font-size: .78rem; font-weight: 500; background: rgba(255, 255, 255, .10); border: 1px solid rgba(255, 255, 255, .18); }
            .hero-rating { color: #FFC107; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
            .hero-rating .score { color: #fff; }
            .hero-rating .reviews { color: rgba(255, 255, 255, .55); font-weight: 400; }
            .hero-synopsis {
                font-size: 1rem; line-height: 1.65; color: rgba(255, 255, 255, .8); max-width: 540px; margin-bottom: 2rem;
                display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;
            }

            /* Hero buttons — clean & flat, no coloured glow, same height */
            .btn-hero-primary, .btn-hero-ghost {
                font-size: 1rem; font-weight: 600; border-radius: 8px;
                height: 50px; padding: 0 1.6rem; text-decoration: none;
                display: inline-flex; align-items: center; gap: 8px;
                transition: background .15s ease, border-color .15s ease, transform .15s ease;
            }
            .btn-hero-primary { background: #2563eb; color: #fff; border: 1px solid #2563eb; }
            .btn-hero-primary:hover { background: #1d4ed8; border-color: #1d4ed8; color: #fff; transform: translateY(-1px); }
            .btn-hero-ghost { background: transparent; color: #fff; border: 1px solid rgba(255, 255, 255, .28); }
            .btn-hero-ghost:hover { background: rgba(255, 255, 255, .10); border-color: rgba(255, 255, 255, .5); color: #fff; }

            /* Hero poster with tilted decorative back-card (prototype) */
            .featured-poster-wrap { position: relative; width: 300px; max-width: 100%; margin: 0 auto; }
            .featured-poster-wrap .back-card {
                position: absolute; inset: 0; z-index: 1; transform: rotate(-4deg) translate(-12px, 8px);
                background: linear-gradient(135deg, rgba(255, 214, 107, .22), rgba(37, 99, 235, .18));
                border-radius: 14px; border: 1px solid rgba(255, 255, 255, .12);
            }
            .featured-poster-wrap .poster-art {
                position: relative; z-index: 2;
                transform: rotate(2deg);
                box-shadow: 0 18px 40px rgba(0, 0, 0, .45), 0 6px 14px rgba(0, 0, 0, .3);
                border-radius: 12px;
            }

            /* ===== Section header ===== */
            .section-title { color: #0f1e36; font-weight: 700; font-size: 1.6rem; margin: 0; }
            .section-desc { font-size: .92rem; color: #6b7280; margin: 0; }
            .view-all-link { color: #2563eb; font-weight: 600; text-decoration: none; font-size: .92rem; }
            .view-all-link:hover { color: #1d4ed8; }

            /* Genre tabs */
            .genre-tabs { display: flex; gap: 8px; flex-wrap: wrap; }
            .genre-tab-btn {
                background: #fff; color: #4b5563; border: 1px solid #e5e7eb;
                padding: .4rem 1rem; font-size: .82rem; font-weight: 500; border-radius: 999px;
                cursor: pointer; transition: all .15s ease;
            }
            .genre-tab-btn:hover { border-color: #2563eb; color: #2563eb; background: #eff6ff; }
            .genre-tab-btn.active { background: #2563eb; color: #fff; border-color: #2563eb; }

            /* ===== Movie grid — fixed comfortable card width so posters stay balanced ===== */
            .movie-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
                gap: 1.5rem;
            }
            .movie-grid .empty-state { grid-column: 1 / -1; }

            /* ===== Movie card ===== */
            .movie-card {
                background: #fff; border: 1px solid #e5e7eb; border-radius: 14px; overflow: hidden;
                height: 100%; display: flex; flex-direction: column; padding: 8px;
                box-shadow: 0 1px 2px rgba(15, 23, 42, .04), 0 1px 3px rgba(15, 23, 42, .06);
                transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease;
            }
            .movie-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 30px rgba(37, 99, 235, .15);
                border-color: #bfdbfe;
            }
            .movie-card .poster-art { border-radius: 10px; }
            .movie-card .poster-art img { transition: transform .35s ease; }
            .movie-card:hover .poster-art img { transform: scale(1.05); }
            .movie-card-body { padding: .75rem .4rem .4rem; flex-grow: 1; display: flex; flex-direction: column; }
            .movie-card-title {
                font-size: .98rem; font-weight: 700; color: #0f1e36; line-height: 1.25; margin: 0;
                overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
            }
            .movie-meta { display: flex; justify-content: space-between; align-items: center; font-size: .82rem; color: #6b7280; }
            .movie-meta i { margin-right: 4px; }

            /* ===== Poster art (used by _poster.jsp) ===== */
            .poster-art { position: relative; aspect-ratio: 2 / 3; width: 100%; border-radius: 10px; overflow: hidden; background: #0d1117; }
            .poster-art .poster-bg, .poster-art .poster-rings, .poster-art img { position: absolute; inset: 0; width: 100%; height: 100%; }
            .poster-art img { object-fit: cover; z-index: 2; }
            .poster-art .poster-name {
                position: absolute; left: 10px; right: 10px; bottom: 18px; text-align: center; z-index: 1;
                color: #fff; font-weight: 800; font-size: .95rem; letter-spacing: 1px; text-transform: uppercase;
                line-height: 1.2; text-shadow: 0 2px 8px rgba(0, 0, 0, .5);
            }
            .poster-ribbon {
                position: absolute; top: 10px; left: 10px; z-index: 3;
                background: rgba(0, 0, 0, .6); color: #fff; font-size: .68rem; font-weight: 700;
                padding: .22rem .55rem; border-radius: 999px; letter-spacing: .04em; text-transform: uppercase;
            }
            .poster-rating {
                position: absolute; top: 10px; right: 10px; z-index: 3;
                background: rgba(0, 0, 0, .6); color: #FFC107; padding: .22rem .5rem; border-radius: 999px;
                font-size: .72rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px;
            }
            .poster-rating span { color: #fff; }

            /* ===== Age rating chip ===== */
            .age { font-weight: 700; font-size: .72rem; padding: .15rem .4rem; border-radius: 4px; letter-spacing: .02em; color: #fff; line-height: 1; min-width: 28px; text-align: center; display: inline-block; background: #6b7280; }
            .age-P { background: #2563EB; }
            .age-K { background: #16A34A; }
            .age-T13, .age-C13 { background: #F2B600; color: #1f2937; }
            .age-T16, .age-C16 { background: #FD7E14; }
            .age-T18, .age-C18 { background: #DC3545; }

            /* ===== Genre pill ===== */
            .pill-blue { display: inline-block; background: #DCE9FB; color: #084298; padding: .18rem .55rem; border-radius: 999px; font-size: .68rem; font-weight: 600; }

            /* ===== Promo banner ===== */
            .promo-banner { background: linear-gradient(135deg, #2563EB 0%, #1E3A5F 100%); border-radius: 12px; color: #fff; padding: 2rem 2.25rem; position: relative; overflow: hidden; }
            .promo-icon { position: absolute; right: -20px; top: 50%; transform: translateY(-50%); font-size: 170px; opacity: .12; pointer-events: none; }
            .promo-badge { background: rgba(255, 255, 255, .2); color: #fff; padding: .25rem .7rem; border-radius: 999px; font-size: .72rem; font-weight: 600; letter-spacing: .04em; display: inline-block; margin-bottom: .6rem; }

            /* ===== Buttons aligned to prototype primary ===== */
            .btn-primary { background: #2563EB; border-color: #2563EB; }
            .btn-primary:hover, .btn-primary:focus { background: #1D4ED8; border-color: #1D4ED8; }
            .btn-outline-primary { color: #2563EB; border-color: #2563EB; }
            .btn-outline-primary:hover { background: #2563EB; border-color: #2563EB; }

            .empty-state { text-align: center; padding: 3rem 1rem; color: #94a3b8; }
            .empty-state i { font-size: 2.5rem; display: block; margin-bottom: .75rem; }
        </style>
    </head>
    <body>

        <jsp:include page="common/header.jsp" />

        <%-- ================= HERO FEATURED BANNER ================= --%>
        <c:if test="${not empty featuredMovie}">
            <c:set var="featRating" value="${((featuredMovie.movieId * 7) % 30) / 10 + 7.0}" />
            <c:set var="featReviews" value="${(featuredMovie.movieId * 243) % 1500 + 100}" />
            <c:set var="featRatingStr"><fmt:formatNumber value="${featRating}" pattern="0.0" /></c:set>

            <section class="hero-banner">
                <div class="container">
                    <div class="row align-items-center g-5">
                        <div class="col-lg-7">
                            <span class="hero-eyebrow"><i class="bi bi-stars"></i> Featured This Week</span>
                            <h1 class="hero-title"><c:out value="${featuredMovie.title}" /></h1>

                            <div class="hero-meta">
                                <span class="age age-${featuredMovie.rated}"><c:out value="${featuredMovie.rated}" /></span>
                                <span>${featuredMovie.durationMin} min</span>
                                <span class="dot">&bull;</span>
                                <c:forEach var="g" items="${featuredMovie.genres}">
                                    <span class="hero-genre">${g}</span>
                                </c:forEach>
                                <span class="dot">&bull;</span>
                                <span class="hero-rating">
                                    <i class="bi bi-star-fill"></i>
                                    <span class="score">${featRatingStr}</span>
                                    <span class="reviews">(${featReviews} reviews)</span>
                                </span>
                            </div>

                            <p class="hero-synopsis"><c:out value="${featuredMovie.description}" /></p>

                            <div class="d-flex gap-3 flex-wrap">
                                <a href="${pageContext.request.contextPath}/booking/branches?movieId=${featuredMovie.movieId}" class="btn-hero-primary">
                                    <i class="bi bi-ticket-perforated-fill"></i> Book Now
                                </a>
                                <c:if test="${not empty featuredMovie.trailerUrl}">
                                    <a href="${featuredMovie.trailerUrl}" target="_blank" class="btn-hero-ghost">
                                        <i class="bi bi-play-fill"></i> Watch Trailer
                                    </a>
                                </c:if>
                            </div>
                        </div>

                        <div class="col-lg-5 d-none d-lg-flex justify-content-center">
                            <div class="featured-poster-wrap">
                                <div class="back-card"></div>
                                <jsp:include page="common/_poster.jsp">
                                    <jsp:param name="movieId" value="${featuredMovie.movieId}" />
                                    <jsp:param name="title" value="${featuredMovie.title}" />
                                    <jsp:param name="posterUrl" value="${featuredMovie.posterUrl}" />
                                </jsp:include>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </c:if>

        <main class="container py-5">

            <%-- ================= NOW SHOWING ================= --%>
            <section class="mb-5">
                <div class="d-flex justify-content-between align-items-end flex-wrap gap-3 mb-4">
                    <div>
                        <h2 class="section-title mb-1">Now Showing</h2>
                        <p class="section-desc">Book tickets for movies currently in our cinemas.</p>
                    </div>
                    <div class="genre-tabs">
                        <button type="button" class="genre-tab-btn active" data-genre-btn="All" onclick="filterGenre('All')">All</button>
                        <c:forEach var="gen" items="${genres}">
                            <button type="button" class="genre-tab-btn" data-genre-btn="${gen.name}" onclick="filterGenre('${gen.name}')">${gen.name}</button>
                        </c:forEach>
                    </div>
                </div>

                <div class="movie-grid" id="nowShowingGrid">
                    <c:choose>
                        <c:when test="${empty nowShowing}">
                            <div class="empty-state"><i class="bi bi-camera-reels"></i> No movies currently now showing.</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${nowShowing}">
                                <c:set var="mRating" value="${((m.movieId * 7) % 30) / 10 + 7.0}" />
                                <c:set var="mReviews" value="${(m.movieId * 243) % 1500 + 100}" />
                                <c:set var="mRatingStr"><fmt:formatNumber value="${mRating}" pattern="0.0" /></c:set>
                                <c:set var="genresListStr" value="" />
                                <c:forEach var="g" items="${m.genres}" varStatus="st">
                                    <c:set var="genresListStr" value="${genresListStr}${g}${not st.last ? ',' : ''}" />
                                </c:forEach>

                                <div class="now-showing-card-col" data-genres="${genresListStr}">
                                    <div class="movie-card">
                                        <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none">
                                            <jsp:include page="common/_poster.jsp">
                                                <jsp:param name="movieId" value="${m.movieId}" />
                                                <jsp:param name="title" value="${m.title}" />
                                                <jsp:param name="posterUrl" value="${m.posterUrl}" />
                                                <jsp:param name="rating" value="${mRatingStr}" />
                                            </jsp:include>
                                        </a>
                                        <div class="movie-card-body">
                                            <div class="d-flex justify-content-between align-items-start gap-2 mb-2">
                                                <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none flex-grow-1" style="min-width:0;">
                                                    <h6 class="movie-card-title" title="<c:out value='${m.title}'/>"><c:out value="${m.title}" /></h6>
                                                </a>
                                                <span class="age age-${m.rated}"><c:out value="${m.rated}" /></span>
                                            </div>
                                            <div class="d-flex flex-wrap gap-1 mb-3" style="min-height:22px;">
                                                <c:forEach var="g" items="${m.genres}" varStatus="st">
                                                    <c:if test="${st.index < 2}"><span class="pill-blue">${g}</span></c:if>
                                                </c:forEach>
                                            </div>
                                            <div class="movie-meta mb-3 mt-auto">
                                                <span><i class="bi bi-clock"></i>${m.durationMin} min</span>
                                                <span><i class="bi bi-chat-square-text"></i><fmt:formatNumber value="${mReviews}" pattern="#,##0" /></span>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/booking/branches?movieId=${m.movieId}" class="btn btn-primary btn-sm w-100 fw-semibold">
                                                Book Tickets
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

            <%-- ================= PROMO BANNER ================= --%>
            <section class="mb-5">
                <div class="promo-banner d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <i class="bi bi-ticket-perforated promo-icon"></i>
                    <div style="position:relative;">
                        <span class="promo-badge">SUMMER10</span>
                        <h4 class="fw-bold mb-1">10% off all bookings</h4>
                        <p class="mb-0 small" style="opacity:.85;">Min order 100,000đ. Valid through 31 July 2026.</p>
                    </div>
                    <a href="#" class="btn btn-light fw-bold px-4 py-2" style="border-radius:8px; color:#1E3A5F; position:relative;">Claim Offer</a>
                </div>
            </section>

            <%-- ================= COMING SOON ================= --%>
            <section class="mb-4">
                <div class="d-flex justify-content-between align-items-end flex-wrap gap-3 mb-4">
                    <div>
                        <h2 class="section-title mb-1">Coming Soon</h2>
                        <p class="section-desc">Upcoming releases — set a reminder.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/movies?status=UPCOMING" class="view-all-link">
                        View all <i class="bi bi-arrow-right"></i>
                    </a>
                </div>

                <div class="movie-grid">
                    <c:choose>
                        <c:when test="${empty comingSoon}">
                            <div class="empty-state"><i class="bi bi-calendar-event"></i> No upcoming movies scheduled.</div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${comingSoon}">
                                <div>
                                    <div class="movie-card">
                                        <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none">
                                            <jsp:include page="common/_poster.jsp">
                                                <jsp:param name="movieId" value="${m.movieId}" />
                                                <jsp:param name="title" value="${m.title}" />
                                                <jsp:param name="posterUrl" value="${m.posterUrl}" />
                                                <jsp:param name="ribbon" value="Coming Soon" />
                                            </jsp:include>
                                        </a>
                                        <div class="movie-card-body">
                                            <div class="d-flex justify-content-between align-items-start gap-2 mb-2">
                                                <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none flex-grow-1" style="min-width:0;">
                                                    <h6 class="movie-card-title" title="<c:out value='${m.title}'/>"><c:out value="${m.title}" /></h6>
                                                </a>
                                                <span class="age age-${m.rated}"><c:out value="${m.rated}" /></span>
                                            </div>
                                            <div class="d-flex flex-wrap gap-1 mb-3" style="min-height:22px;">
                                                <c:forEach var="g" items="${m.genres}" varStatus="st">
                                                    <c:if test="${st.index < 2}"><span class="pill-blue">${g}</span></c:if>
                                                </c:forEach>
                                            </div>
                                            <div class="movie-meta mb-3 mt-auto">
                                                <span><i class="bi bi-clock"></i>${m.durationMin} min</span>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="btn btn-outline-primary btn-sm w-100 fw-semibold">
                                                View Details
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                </div>
            </section>

        </main>

        <jsp:include page="common/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script>
            function filterGenre(genreName) {
                $('.genre-tab-btn').removeClass('active');
                $('[data-genre-btn="' + genreName + '"]').addClass('active');
                if (genreName === 'All') {
                    $('.now-showing-card-col').fadeIn(300);
                } else {
                    $('.now-showing-card-col').each(function () {
                        var genresList = ($(this).attr('data-genres') || '').split(',');
                        if (genresList.includes(genreName)) { $(this).fadeIn(300); } else { $(this).fadeOut(300); }
                    });
                }
            }
        </script>
    </body>
</html>
