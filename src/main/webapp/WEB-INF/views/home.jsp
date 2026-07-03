<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>PentaPlex - Home</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css">
        <style>
            /* ===== Hero 2 cột: thông tin trái · coverflow poster phải ===== */
            .hero-cf {
                background:
                    radial-gradient(900px 480px at 15% -10%, rgba(37, 99, 235, .32), transparent 60%),
                    radial-gradient(760px 420px at 95% 20%, rgba(255, 214, 107, .16), transparent 60%),
                    linear-gradient(180deg, var(--navy) 0%, #15294a 70%, #1E3A5F 100%);
                padding: 3rem 0;
                overflow: hidden;
            }
            .hero-cf-info { color: #fff; }
            .hero-cf-info .eyebrow {
                display: inline-flex; align-items: center; gap: .5rem;
                font-size: .72rem; font-weight: 700; letter-spacing: .12em; text-transform: uppercase;
                background: rgba(255,255,255,.10); border: 1px solid rgba(255,255,255,.18);
                padding: .35rem .8rem; border-radius: 999px; margin-bottom: 1.1rem;
            }
            .hero-cf-info .eyebrow i { color: var(--gold); }
            .cf-title {
                font-weight: 800; font-size: clamp(1.9rem, 3.4vw, 2.9rem); line-height: 1.1;
                letter-spacing: -.02em; margin: 0 0 1rem; min-height: 1.1em;
                transition: opacity .35s ease;
            }
            .cf-meta {
                display: flex; flex-wrap: wrap; align-items: center; gap: 10px;
                font-size: .9rem; color: rgba(255,255,255,.78); margin-bottom: 1.1rem;
                transition: opacity .35s ease;
            }
            .cf-meta .cf-rating { color: var(--gold); font-weight: 700; display: inline-flex; align-items: center; gap: 5px; }
            .cf-meta .cf-dot { opacity: .35; }
            .cf-desc {
                font-size: .98rem; line-height: 1.65; color: rgba(255,255,255,.8);
                max-width: 520px; margin-bottom: 1.75rem;
                display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;
                transition: opacity .35s ease;
            }
            .cf-book { border-radius: 10px; padding: .7rem 1.6rem; font-weight: 600; }

            /* Coverflow */
            .movieSwiper { padding: 12px 0; width: 100%; }
            .movieSwiper .swiper-slide {
                width: 210px;
            }
            .movieSwiper .swiper-slide .poster-art {
                border-radius: 14px;
                box-shadow: 0 18px 44px rgba(0,0,0,.5);
                transition: box-shadow .3s ease;
            }
            .movieSwiper .swiper-slide-active .poster-art {
                box-shadow: 0 24px 60px rgba(0,0,0,.6), 0 0 0 3px rgba(255,255,255,.12);
            }
            .movieSwiper .swiper-button-next,
            .movieSwiper .swiper-button-prev {
                color: #fff; width: 40px; height: 40px; border-radius: 50%;
                background: rgba(255,255,255,.10); border: 1px solid rgba(255,255,255,.2);
                backdrop-filter: blur(4px); transition: background .15s ease;
            }
            .movieSwiper .swiper-button-next:hover,
            .movieSwiper .swiper-button-prev:hover { background: rgba(255,255,255,.22); }
            .movieSwiper .swiper-button-next:after,
            .movieSwiper .swiper-button-prev:after { font-size: 1.05rem; font-weight: 700; }
            @media (max-width: 991px) {
                .hero-cf-info { text-align: center; margin-top: 1.5rem; }
                .hero-cf-info .cf-desc { margin-left: auto; margin-right: auto; }
            }

            /* ===== Home styles — aligned to app shell (header/footer) tokens ===== */
            body { background: var(--bg); color: var(--text); }
            .hero-title, .section-title { letter-spacing: -0.02em; }

            /* ===== Hero ===== */
            /* Hero background — exact PentaPlex prototype gradient (blue + warm gold glow) */
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
            .hero-eyebrow i { color: var(--gold); }
            .hero-title { font-size: clamp(2.4rem, 4.6vw, 3.6rem); font-weight: 800; line-height: 1.06; margin-bottom: 1.1rem; }
            .hero-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 10px; margin-bottom: 1.4rem; font-size: .9rem; color: rgba(255, 255, 255, .78); }
            .hero-meta .dot { opacity: .35; }
            .hero-genre { padding: .22rem .7rem; border-radius: 999px; font-size: .78rem; font-weight: 500; background: rgba(255, 255, 255, .10); border: 1px solid rgba(255, 255, 255, .18); }
            .hero-rating { color: var(--gold); font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
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
            .btn-hero-primary { background: var(--primary); color: #fff; border: 1px solid var(--primary); }
            .btn-hero-primary:hover { background: var(--primary-700); border-color: var(--primary-700); color: #fff; transform: translateY(-1px); }
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
            .section-title { color: var(--text); font-weight: 700; font-size: 1.6rem; margin: 0; }
            .section-desc { font-size: .92rem; color: var(--text-muted); margin: 0; }
            .view-all-link { color: var(--primary); font-weight: 600; text-decoration: none; font-size: .92rem; }
            .view-all-link:hover { color: var(--primary-700); }

            /* Genre tabs */
            .genre-tabs { display: flex; gap: 8px; flex-wrap: wrap; }
            .genre-tab-btn {
                background: #fff; color: #4b5563; border: 1px solid var(--border);
                padding: .4rem 1rem; font-size: .82rem; font-weight: 500; border-radius: 999px;
                cursor: pointer; transition: all .15s ease;
            }
            .genre-tab-btn:hover { border-color: var(--primary); color: var(--primary); background: var(--primary-50); }
            .genre-tab-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }

            /* ===== Movie grid — fixed comfortable card width so posters stay balanced ===== */
            .movie-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(210px, 1fr));
                gap: 1.5rem;
            }
            .movie-grid .empty-state { grid-column: 1 / -1; }

            /* ===== Movie card ===== */
            .movie-card {
                background: #fff; border: 1px solid var(--border); border-radius: 14px; overflow: hidden;
                height: 100%; display: flex; flex-direction: column; padding: 8px;
                box-shadow: 0 1px 2px rgba(15, 23, 42, .04), 0 1px 3px rgba(15, 23, 42, .06);
                transition: transform .15s ease, box-shadow .15s ease, border-color .15s ease;
            }
            .movie-card:hover {
                transform: translateY(-3px);
                box-shadow: 0 12px 30px rgba(37, 99, 235, .15);
                border-color: var(--primary-200);
            }
            .movie-card .poster-art { border-radius: 10px; }
            .movie-card .poster-art img { transition: transform .35s ease; }
            .movie-card:hover .poster-art img { transform: scale(1.05); }
            .movie-card-body { padding: .75rem .4rem .4rem; flex-grow: 1; display: flex; flex-direction: column; }
            .movie-card-title {
                font-size: .98rem; font-weight: 700; color: var(--text); line-height: 1.25; margin: 0;
                overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
            }
            .movie-meta { display: flex; justify-content: space-between; align-items: center; font-size: .82rem; color: var(--text-muted); }
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
                background: rgba(0, 0, 0, .6); color: var(--gold); padding: .22rem .5rem; border-radius: 999px;
                font-size: .72rem; font-weight: 700; display: inline-flex; align-items: center; gap: 4px;
            }
            .poster-rating span { color: #fff; }

            /* ===== Age rating chip ===== */
            .age { font-weight: 700; font-size: .72rem; padding: .15rem .4rem; border-radius: 4px; letter-spacing: .02em; color: #fff; line-height: 1; min-width: 28px; text-align: center; display: inline-block; background: #6b7280; }
            .age-P { background: var(--primary); }
            .age-K { background: var(--success); }
            .age-T13, .age-C13 { background: #F2B600; color: #1f2937; }
            .age-T16, .age-C16 { background: #FD7E14; }
            .age-T18, .age-C18 { background: var(--danger); }

            /* ===== Genre pill ===== */
            .pill-blue { display: inline-block; background: #DCE9FB; color: #084298; padding: .18rem .55rem; border-radius: 999px; font-size: .68rem; font-weight: 600; }

            /* ===== Promo banner ===== */
            .promo-banner { background: linear-gradient(135deg, var(--primary) 0%, var(--navy) 100%); border-radius: 12px; color: #fff; padding: 2rem 2.25rem; position: relative; overflow: hidden; }
            .promo-icon { position: absolute; right: -20px; top: 50%; transform: translateY(-50%); font-size: 170px; opacity: .12; pointer-events: none; }
            .promo-badge { background: rgba(255, 255, 255, .2); color: #fff; padding: .25rem .7rem; border-radius: 999px; font-size: .72rem; font-weight: 600; letter-spacing: .04em; display: inline-block; margin-bottom: .6rem; }

            /* ===== Buttons aligned to prototype primary ===== */
            .btn-primary { background: var(--primary); border-color: var(--primary); }
            .btn-primary:hover, .btn-primary:focus { background: var(--primary-700); border-color: var(--primary-700); }
            .btn-outline-primary { color: var(--primary); border-color: var(--primary); }
            .btn-outline-primary:hover { background: var(--primary); border-color: var(--primary); }

            .empty-state { text-align: center; padding: 3rem 1rem; color: var(--text-subtle); }
            .empty-state i { font-size: 2.5rem; display: block; margin-bottom: .75rem; }
        </style>
    </head>
    <body>

        <jsp:include page="common/header.jsp" />

        <%-- ================= HERO (2 cột: thông tin trái · coverflow poster phải) ================= --%>
        <c:if test="${not empty nowShowing}">
            <c:set var="cf0" value="${nowShowing[0]}" />
            <c:set var="cf0RatingVal" value="${((cf0.movieId * 7) % 30) / 10 + 7.0}" />
            <c:set var="cf0Rating"><fmt:formatNumber value="${cf0RatingVal}" pattern="0.0" /></c:set>
            <c:set var="cf0Genres" value="" />
            <c:forEach var="g" items="${cf0.genres}" varStatus="st"><c:set var="cf0Genres" value="${cf0Genres}${g}${not st.last ? ', ' : ''}" /></c:forEach>
            <section class="hero-cf">
                <div class="container">
                    <div class="row align-items-center g-4 g-lg-5">
                        <%-- LEFT: thông tin phim đang ở giữa --%>
                        <div class="col-lg-5 order-2 order-lg-1 hero-cf-info">
                            <span class="eyebrow">Now Showing</span>
                            <h1 class="cf-title" id="cfTitle"><c:out value="${cf0.title}"/></h1>
                            <div class="cf-meta" id="cfMeta">
                                <span class="cf-rating"><i class="bi bi-star-fill"></i> <span id="cfRating">${cf0Rating}</span></span>
                                <span class="cf-dot">&bull;</span>
                                <span id="cfDuration">${cf0.durationMin} min</span>
                                <span class="cf-dot">&bull;</span>
                                <span id="cfGenres">${cf0Genres}</span>
                            </div>
                            <p class="cf-desc" id="cfDesc"><c:out value="${cf0.description}"/></p>
                            <a class="btn btn-primary cf-book" id="cfBook"
                               href="${pageContext.request.contextPath}/booking/showtimes?movieId=${cf0.movieId}">
                                <i class="bi bi-ticket-perforated-fill me-2"></i> Book Now
                            </a>
                        </div>

                        <%-- RIGHT: coverflow posters --%>
                        <div class="col-lg-7 order-1 order-lg-2">
                            <div class="swiper movieSwiper">
                                <div class="swiper-wrapper">
                                    <c:forEach var="m" items="${nowShowing}">
                                        <c:set var="cfRatingVal" value="${((m.movieId * 7) % 30) / 10 + 7.0}" />
                                        <c:set var="cfRatingStr"><fmt:formatNumber value="${cfRatingVal}" pattern="0.0" /></c:set>
                                        <c:set var="cfGenres" value="" />
                                        <c:forEach var="g" items="${m.genres}" varStatus="st"><c:set var="cfGenres" value="${cfGenres}${g}${not st.last ? ', ' : ''}" /></c:forEach>
                                        <div class="swiper-slide"
                                             data-title="<c:out value='${m.title}'/>"
                                             data-desc="<c:out value='${m.description}'/>"
                                             data-genres="${cfGenres}"
                                             data-duration="${m.durationMin} min"
                                             data-rating="${cfRatingStr}"
                                             data-href="${pageContext.request.contextPath}/booking/showtimes?movieId=${m.movieId}">
                                            <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none">
                                                <jsp:include page="common/_poster.jsp">
                                                    <jsp:param name="movieId" value="${m.movieId}" />
                                                    <jsp:param name="title" value="${m.title}" />
                                                    <jsp:param name="posterUrl" value="${m.posterUrl}" />
                                                    <jsp:param name="rating" value="${cfRatingStr}" />
                                                </jsp:include>
                                            </a>
                                        </div>
                                    </c:forEach>
                                </div>
                                <div class="swiper-button-prev"></div>
                                <div class="swiper-button-next"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </c:if>

        <%-- ================= HERO FEATURED BANNER (đã thay bằng coverflow ở trên) ================= --%>
        <c:if test="${false and not empty featuredMovie}">
            <c:set var="featRating" value="${((featuredMovie.movieId * 7) % 30) / 10 + 7.0}" />
            <c:set var="featReviews" value="${(featuredMovie.movieId * 243) % 1500 + 100}" />
            <c:set var="featRatingStr"><fmt:formatNumber value="${featRating}" pattern="0.0" /></c:set>

            <section class="hero-banner">
                <div class="container">
                    <div class="row align-items-center g-5">
                        <div class="col-lg-7">
                            <span class="hero-eyebrow">Featured This Week</span>
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
                                <a href="${pageContext.request.contextPath}/booking/showtimes?movieId=${featuredMovie.movieId}" class="btn-hero-primary">
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
                                            <a href="${pageContext.request.contextPath}/booking/showtimes?movieId=${m.movieId}" class="btn btn-primary btn-sm w-100 fw-semibold">
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
                    <a href="#" class="btn btn-light fw-bold px-4 py-2" style="border-radius:8px; color:var(--navy); position:relative;">Claim Offer</a>
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
        <script src="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.js"></script>
        <script>
            // Hero coverflow — kéo chuột & cảm ứng, auto-loop; panel trái cập nhật theo poster giữa
            (function () {
                var el = document.querySelector('.movieSwiper');
                if (!el) return;

                function setText(id, val) {
                    var n = document.getElementById(id);
                    if (n) n.textContent = val || '';
                }
                function fade(ids) {
                    ids.forEach(function (id) {
                        var n = document.getElementById(id);
                        if (n) { n.style.opacity = 0; }
                    });
                }
                function unfade(ids) {
                    ids.forEach(function (id) {
                        var n = document.getElementById(id);
                        if (n) { n.style.opacity = 1; }
                    });
                }

                function syncInfo(swiper) {
                    var slide = swiper.slides[swiper.activeIndex];
                    if (!slide || !slide.dataset || !slide.dataset.title) return;
                    var fadeIds = ['cfTitle', 'cfMeta', 'cfDesc'];
                    fade(fadeIds);
                    if (syncInfo._t) clearTimeout(syncInfo._t);
                    syncInfo._t = setTimeout(function () {
                        // Doc lai slide DANG o giua tai thoi diem gan text -> khong bao gio
                        // hien nham text cua slide cu khi autoplay/keo nhanh doi slide giua chung.
                        applyCurrent(swiper);
                        unfade(fadeIds);
                        syncInfo._t = null;
                    }, 180);
                }

                // Gan thong tin theo slide active hien tai (khong fade) - dung lam "chot"
                // dong bo sau moi transition, dam bao panel luon khop poster trung tam.
                function applyCurrent(swiper) {
                    var slide = swiper.slides[swiper.activeIndex];
                    if (!slide || !slide.dataset || !slide.dataset.title) return;
                    var d = slide.dataset;
                    setText('cfTitle', d.title);
                    setText('cfRating', d.rating);
                    setText('cfDuration', d.duration);
                    setText('cfGenres', d.genres);
                    setText('cfDesc', d.desc);
                    var book = document.getElementById('cfBook');
                    if (book && d.href) book.setAttribute('href', d.href);
                }

                var swiper = new Swiper(el, {
                    effect: 'coverflow',
                    grabCursor: true,
                    centeredSlides: true,
                    slidesPerView: 'auto',
                    initialSlide: 0,
                    loop: false,
                    rewind: true,
                    watchSlidesProgress: true,
                    speed: 450,
                    slideToClickedSlide: true,
                    coverflowEffect: { rotate: 18, stretch: 0, depth: 110, modifier: 1, slideShadows: false },
                    autoplay: { delay: 4000, disableOnInteraction: false, pauseOnMouseEnter: true },
                    navigation: {
                        nextEl: '.movieSwiper .swiper-button-next',
                        prevEl: '.movieSwiper .swiper-button-prev'
                    },
                    on: {
                        init: function () { syncInfo(this); },
                        slideChange: function () { syncInfo(this); },
                        transitionEnd: function () { applyCurrent(this); unfade(['cfTitle', 'cfMeta', 'cfDesc']); }
                    }
                });

                // Đảm bảo phim đầu nằm giữa sau khi layout xong
                requestAnimationFrame(function () {
                    swiper.update();
                    swiper.slideTo(0, 0, false);
                    syncInfo(swiper);
                });
            })();
        </script>
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
