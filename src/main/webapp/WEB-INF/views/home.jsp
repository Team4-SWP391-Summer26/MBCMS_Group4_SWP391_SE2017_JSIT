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
        <link href="${pageContext.request.contextPath}/assets/css/home.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@11/swiper-bundle.min.css">
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
                <div class="container public-shell">
                    <div class="row align-items-center g-4 g-lg-5">
                        <%-- LEFT: thông tin phim đang ở giữa --%>
                        <div class="col-lg-5 order-2 order-lg-1 hero-cf-info home-reveal" style="--i:0">
                            <span class="eyebrow"><i class="bi bi-stars"></i> Spotlight</span>
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
                        <div class="col-lg-7 order-1 order-lg-2 home-reveal" style="--i:1">
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
                <div class="container public-shell">
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

        <main class="container public-shell pt-4 pb-5 home-main">

            <%-- ================= NOW SHOWING ================= --%>
            <section class="mb-5 home-reveal" style="--i:2">
                <div class="home-section-head mb-4">
                    <div class="home-section-intro">
                        <span class="section-kicker"><i class="bi bi-camera-reels"></i> In cinemas</span>
                        <h2 class="section-title mb-1">Now Showing</h2>
                        <p class="section-desc mb-0">Book tickets for movies currently in our cinemas.</p>
                    </div>
                    <div class="genre-tabs home-genre-tabs">
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
                                                <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none flex-grow-1 movie-title-link">
                                                    <h6 class="movie-card-title" title="<c:out value='${m.title}'/>"><c:out value="${m.title}" /></h6>
                                                </a>
                                                <span class="age age-${m.rated}"><c:out value="${m.rated}" /></span>
                                            </div>
                                            <div class="d-flex flex-wrap gap-1 mb-3 movie-genre-row">
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
            <section class="mb-5 home-reveal" style="--i:3">
                <div class="promo-banner d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div class="d-flex align-items-center gap-3">
                        <i class="bi bi-ticket-perforated promo-icon"></i>
                        <div class="promo-copy">
                            <span class="promo-badge">SUMMER10</span>
                            <h4 class="fw-bold mb-1">10% off all bookings</h4>
                            <p class="mb-0 small promo-note">Min order 100,000 VND. Valid through 31 July 2026.</p>
                        </div>
                    </div>
                    <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING" class="btn fw-bold px-4 py-2 promo-cta">Claim Offer</a>
                </div>
            </section>

            <%-- ================= COMING SOON ================= --%>
            <section class="mb-5 home-reveal" style="--i:4">
                <div class="home-section-head home-section-head--split mb-4">
                    <div class="home-section-intro">
                        <span class="section-kicker"><i class="bi bi-calendar-event"></i> On the horizon</span>
                        <h2 class="section-title mb-1">Coming Soon</h2>
                        <p class="section-desc mb-0">Upcoming releases — set a reminder.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/movies?status=UPCOMING" class="view-all-link text-nowrap">
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
                                                <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none flex-grow-1 movie-title-link">
                                                    <h6 class="movie-card-title" title="<c:out value='${m.title}'/>"><c:out value="${m.title}" /></h6>
                                                </a>
                                                <span class="age age-${m.rated}"><c:out value="${m.rated}" /></span>
                                            </div>
                                            <div class="d-flex flex-wrap gap-1 mb-3 movie-genre-row">
                                                <c:forEach var="g" items="${m.genres}" varStatus="st">
                                                    <c:if test="${st.index < 2}"><span class="pill-blue">${g}</span></c:if>
                                                </c:forEach>
                                            </div>
                                            <div class="movie-meta mb-3 mt-auto">
                                                <span><i class="bi bi-clock"></i>${m.durationMin} min</span>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="btn btn-pp-secondary btn-sm w-100 fw-semibold">
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
            window.PentaPlexPoster = window.PentaPlexPoster || {
                onImgError: function (img) {
                    if (!img || img.classList.contains('is-broken')) return;
                    img.classList.add('is-broken');
                    var art = img.closest('.poster-art');
                    if (!art) return;
                    art.classList.add('poster-art--fallback');
                    var name = art.querySelector('.poster-name-fallback');
                    if (name) name.hidden = false;
                    art.dispatchEvent(new CustomEvent('poster:ready', { bubbles: true }));
                },
                markLoaded: function (img) {
                    var art = img && img.closest('.poster-art');
                    if (art) art.dispatchEvent(new CustomEvent('poster:ready', { bubbles: true }));
                }
            };
        </script>
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
                        applyCurrent(swiper);
                        unfade(fadeIds);
                        syncInfo._t = null;
                    }, 180);
                }

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

                function scheduleSwiperUpdate(swiper) {
                    if (scheduleSwiperUpdate._t) clearTimeout(scheduleSwiperUpdate._t);
                    scheduleSwiperUpdate._t = setTimeout(function () {
                        swiper.update();
                        scheduleSwiperUpdate._t = null;
                    }, 50);
                }

                el.querySelectorAll('.poster-img').forEach(function (img) {
                    if (img.complete) {
                        if (img.naturalWidth === 0) window.PentaPlexPoster.onImgError(img);
                        else window.PentaPlexPoster.markLoaded(img);
                    } else {
                        img.addEventListener('load', function () { window.PentaPlexPoster.markLoaded(img); }, { once: true });
                        img.addEventListener('error', function () { window.PentaPlexPoster.onImgError(img); }, { once: true });
                    }
                });

                var swiper = new Swiper(el, {
                    effect: 'coverflow',
                    grabCursor: true,
                    centeredSlides: true,
                    slidesPerView: 'auto',
                    initialSlide: 0,
                    loop: false,
                    rewind: true,
                    watchSlidesProgress: true,
                    observer: true,
                    observeParents: true,
                    observeSlideChildren: true,
                    resizeObserver: true,
                    speed: 450,
                    slideToClickedSlide: true,
                    coverflowEffect: { rotate: 14, stretch: -12, depth: 90, modifier: 1.15, slideShadows: false },
                    autoplay: { delay: 4500, disableOnInteraction: false, pauseOnMouseEnter: true, waitForTransition: true },
                    navigation: {
                        nextEl: '.movieSwiper .swiper-button-next',
                        prevEl: '.movieSwiper .swiper-button-prev'
                    },
                    on: {
                        init: function () {
                            scheduleSwiperUpdate(this);
                            syncInfo(this);
                        },
                        slideChange: function () { syncInfo(this); },
                        transitionEnd: function () {
                            applyCurrent(this);
                            unfade(['cfTitle', 'cfMeta', 'cfDesc']);
                            scheduleSwiperUpdate(this);
                        },
                        resize: function () { scheduleSwiperUpdate(this); }
                    }
                });

                el.addEventListener('poster:ready', function () { scheduleSwiperUpdate(swiper); });

                requestAnimationFrame(function () {
                    scheduleSwiperUpdate(swiper);
                    swiper.slideTo(0, 0, false);
                    syncInfo(swiper);
                });

                window.addEventListener('load', function () { scheduleSwiperUpdate(swiper); });
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
