<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>MBCMS - LuminaCine Homepage</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* Premium Dark Hero Banner */
            .hero-banner {
                background: linear-gradient(135deg, #0b1528 0%, #060b13 100%);
                color: #ffffff;
                padding: 4.5rem 0;
                position: relative;
                overflow: hidden;
            }
            .hero-banner::before {
                content: '';
                position: absolute;
                bottom: 0;
                right: 0;
                width: 100%;
                height: 100%;
                background: radial-gradient(circle at bottom right, rgba(37, 99, 235, 0.15) 0%, transparent 60%);
                pointer-events: none;
            }
            .hero-banner-label {
                font-size: 0.75rem;
                font-weight: 700;
                letter-spacing: 2px;
                color: #3b82f6;
                text-transform: uppercase;
                margin-bottom: 1rem;
                display: flex;
                align-items: center;
                gap: 8px;
            }
            .hero-banner-label::after {
                content: '';
                display: block;
                width: 40px;
                height: 2px;
                background-color: #3b82f6;
            }
            .hero-title {
                font-size: 3rem;
                font-weight: 800;
                line-height: 1.15;
                margin-bottom: 1.25rem;
                letter-spacing: -1px;
            }
            .hero-meta {
                display: flex;
                flex-wrap: wrap;
                align-items: center;
                gap: 12px;
                margin-bottom: 1.5rem;
                font-size: 0.9rem;
                color: rgba(255, 255, 255, 0.7);
            }
            .hero-synopsis {
                font-size: 1rem;
                line-height: 1.6;
                color: rgba(255, 255, 255, 0.6);
                max-width: 580px;
                margin-bottom: 2.25rem;
            }

            /* Angled 3D Poster Card */
            .featured-poster-container {
                position: relative;
                perspective: 1000px;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            .featured-poster-card {
                width: 280px;
                height: 410px;
                border-radius: 16px;
                box-shadow: 0 20px 40px rgba(0, 0, 0, 0.5);
                transform: rotateY(-10deg) rotateX(5deg);
                transition: transform 0.5s ease, box-shadow 0.5s ease;
                overflow: hidden;
                border: 1px solid rgba(255, 255, 255, 0.1);
                background: #0f172a;
                z-index: 1;
            }
            .featured-poster-card img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }
            .featured-poster-card:hover {
                transform: rotateY(0deg) rotateX(0deg) scale(1.03);
                box-shadow: 0 30px 60px rgba(37, 99, 235, 0.35);
            }
            .featured-poster-glow {
                position: absolute;
                width: 340px;
                height: 470px;
                background: radial-gradient(circle, rgba(37, 99, 235, 0.28) 0%, transparent 70%);
                z-index: 0;
                pointer-events: none;
                filter: blur(10px);
            }

            /* General Rated Badges */
            .badge-rated {
                padding: 0.3em 0.6em;
                font-weight: 700;
                font-size: 0.72rem;
                border-radius: 4px;
                text-transform: uppercase;
                display: inline-block;
            }
            .badge-rated-p { background-color: #2563eb; color: #fff; } /* Blue for P */
            .badge-rated-k { background-color: #10b981; color: #fff; } /* Green for K */
            .badge-rated-c13, .badge-rated-t13 { background-color: #f59e0b; color: #fff; } /* Yellow for C13/T13 */
            .badge-rated-c16, .badge-rated-t16 { background-color: #ea580c; color: #fff; } /* Orange for C16/T16 */
            .badge-rated-c18, .badge-rated-t18 { background-color: #ef4444; color: #fff; } /* Red for C18/T18 */

            /* Now Showing & Coming Soon Section styling */
            .section-title {
                color: #0f1e36;
                font-weight: 800;
                font-size: 1.75rem;
                letter-spacing: -0.5px;
            }
            .section-desc {
                font-size: 0.9rem;
                color: #6b7280;
                margin-top: -8px;
            }

            /* Custom Rounded Genre Pills */
            .genre-tabs {
                display: flex;
                gap: 8px;
                flex-wrap: wrap;
            }
            .genre-tab-btn {
                background-color: #ffffff;
                color: #4b5563;
                border: 1px solid #e5e7eb;
                padding: 0.45rem 1.15rem;
                font-size: 0.82rem;
                font-weight: 600;
                border-radius: 9999px;
                transition: all 0.2s ease;
                cursor: pointer;
            }
            .genre-tab-btn:hover {
                background-color: #f3f4f6;
                color: #111827;
                border-color: #d1d5db;
            }
            .genre-tab-btn.active {
                background-color: #2563eb;
                color: #ffffff;
                border-color: #2563eb;
            }

            /* Premium Movie Cards Grid */
            .movie-grid-card {
                background: #ffffff;
                border: 1px solid #e5e7eb;
                border-radius: 12px;
                overflow: hidden;
                transition: transform 0.3s ease, box-shadow 0.3s ease;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                position: relative;
            }
            .movie-grid-card:hover {
                transform: translateY(-6px);
                box-shadow: 0 12px 30px rgba(37, 99, 235, 0.15);
            }
            .movie-poster-wrap {
                position: relative;
                height: 380px;
                overflow: hidden;
                background-color: #0f172a;
            }
            .movie-poster-img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.4s ease;
            }
            .movie-grid-card:hover .movie-poster-img {
                transform: scale(1.05);
            }
            .movie-rating-badge {
                position: absolute;
                top: 12px;
                right: 12px;
                background: rgba(15, 23, 42, 0.75);
                backdrop-filter: blur(4px);
                color: #ffffff;
                padding: 4px 8px;
                border-radius: 20px;
                font-size: 0.78rem;
                font-weight: 700;
                display: flex;
                align-items: center;
                gap: 4px;
                border: 1px solid rgba(255, 255, 255, 0.15);
                z-index: 2;
            }
            .movie-rating-badge i {
                color: #fbbf24;
            }

            /* Poster Abstract CSS Placeholder */
            .poster-placeholder {
                width: 100%;
                height: 100%;
                min-height: 380px;
                background: linear-gradient(135deg, #0c1524 0%, #1e293b 100%);
                position: relative;
                overflow: hidden;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                color: #ffffff;
                text-align: center;
                padding: 20px;
            }
            .poster-placeholder::before {
                content: '';
                position: absolute;
                width: 170px;
                height: 170px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(37, 99, 235, 0.25) 0%, transparent 70%);
                z-index: 1;
            }
            .placeholder-icon {
                font-size: 2.75rem;
                color: rgba(255, 255, 255, 0.25);
                margin-bottom: 12px;
                z-index: 2;
            }
            .placeholder-title {
                font-size: 1.1rem;
                font-weight: 800;
                color: rgba(255, 255, 255, 0.95);
                letter-spacing: -0.5px;
                z-index: 2;
                text-transform: uppercase;
                margin-top: 10px;
            }

            .movie-card-info {
                padding: 1rem;
                flex-grow: 1;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
            }
            .movie-card-title {
                font-size: 1rem;
                font-weight: 700;
                color: #0f1e36;
                margin-bottom: 0.5rem;
                line-height: 1.3;
            }

            /* Mid Section Promo Banner */
            .promo-banner {
                background: linear-gradient(135deg, #1e3a8a 0%, #0f172a 100%);
                border-radius: 12px;
                color: #ffffff;
                padding: 2.25rem;
                position: relative;
                overflow: hidden;
                border: 1px solid rgba(255, 255, 255, 0.05);
            }
            .promo-banner::after {
                content: '';
                position: absolute;
                top: 0;
                right: 0;
                width: 300px;
                height: 100%;
                background: radial-gradient(circle at right, rgba(255, 255, 255, 0.06) 0%, transparent 70%);
                pointer-events: none;
            }
            .promo-badge {
                background-color: rgba(255, 255, 255, 0.12);
                border: 1px solid rgba(255, 255, 255, 0.15);
                padding: 4px 10px;
                border-radius: 4px;
                font-family: monospace;
                font-weight: 700;
                font-size: 0.8rem;
                letter-spacing: 1px;
                display: inline-block;
                margin-bottom: 0.75rem;
            }

            .btn-book-now-lc {
                background-color: #2563eb;
                color: #fff;
                font-weight: 600;
                border-radius: 8px;
                padding: 0.5rem 1.5rem;
                border: none;
                transition: background-color 0.2s ease;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }
            .btn-book-now-lc:hover {
                background-color: #1d4ed8;
                color: #fff;
            }
            .btn-trailer-lc {
                background-color: rgba(255, 255, 255, 0.1);
                color: #fff;
                font-weight: 600;
                border-radius: 8px;
                padding: 0.5rem 1.5rem;
                border: 1px solid rgba(255, 255, 255, 0.2);
                transition: all 0.2s ease;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                gap: 8px;
            }
            .btn-trailer-lc:hover {
                background-color: rgba(255, 255, 255, 0.2);
                color: #fff;
                border-color: rgba(255, 255, 255, 0.3);
            }
        </style>
    </head>
    <body class="bg-light">

        <jsp:include page="common/header.jsp" />

        <%-- ================= HERO FEATURED BANNER ================= --%>
        <c:if test="${not empty featuredMovie}">
            <%-- Dynamic Mock calculations for consistently themed homepage display --%>
            <c:set var="featRating" value="${((featuredMovie.movieId * 7) % 30) / 10 + 7.0}" />
            <c:set var="featReviews" value="${(featuredMovie.movieId * 243) % 1500 + 100}" />

            <section class="hero-banner">
                <div class="container">
                    <div class="row align-items-center g-5">
                        <div class="col-lg-7">
                            <div class="hero-banner-label">Featured This Week</div>
                            <h1 class="hero-title"><c:out value="${featuredMovie.title}"/></h1>
                            
                            <div class="hero-meta">
                                <c:choose>
                                    <c:when test="${featuredMovie.rated == 'P'}">
                                        <span class="badge-rated badge-rated-p">P</span>
                                    </c:when>
                                    <c:when test="${featuredMovie.rated == 'K'}">
                                        <span class="badge-rated badge-rated-k">K</span>
                                    </c:when>
                                    <c:when test="${featuredMovie.rated == 'C13' || featuredMovie.rated == 'T13'}">
                                        <span class="badge-rated badge-rated-c13"><c:out value="${featuredMovie.rated}"/></span>
                                    </c:when>
                                    <c:when test="${featuredMovie.rated == 'C16' || featuredMovie.rated == 'T16'}">
                                        <span class="badge-rated badge-rated-c16"><c:out value="${featuredMovie.rated}"/></span>
                                    </c:when>
                                    <c:when test="${featuredMovie.rated == 'C18' || featuredMovie.rated == 'T18'}">
                                        <span class="badge-rated badge-rated-c18"><c:out value="${featuredMovie.rated}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge bg-secondary"><c:out value="${featuredMovie.rated}"/></span>
                                    </c:otherwise>
                                </c:choose>
                                
                                <span>&bull;</span>
                                <span>${featuredMovie.durationMin} min</span>
                                
                                <span>&bull;</span>
                                <span class="d-flex align-items-center gap-1">
                                    <c:forEach var="g" items="${featuredMovie.genres}" varStatus="st">
                                        ${g}${not st.last ? ', ' : ''}
                                    </c:forEach>
                                </span>
                                
                                <span>&bull;</span>
                                <span style="color: #fbbf24; font-weight: 700;">
                                    <i class="bi bi-star-fill"></i> 
                                    <fmt:formatNumber value="${featRating}" pattern="0.0" />
                                </span>
                                <span class="text-white-50">(${featReviews} reviews)</span>
                            </div>

                            <p class="hero-synopsis">
                                <c:out value="${featuredMovie.description}"/>
                            </p>

                            <div class="d-flex gap-3 flex-wrap">
                                <a href="${pageContext.request.contextPath}/booking/branches?movieId=${featuredMovie.movieId}" class="btn-book-now-lc">
                                    <i class="bi bi-ticket-perforated-fill"></i> Book Now
                                </a>
                                <c:if test="${not empty featuredMovie.trailerUrl}">
                                    <a href="${featuredMovie.trailerUrl}" target="_blank" class="btn-trailer-lc">
                                        <i class="bi bi-play-fill"></i> Watch Trailer
                                    </a>
                                </c:if>
                            </div>
                        </div>
                        
                        <div class="col-lg-5 d-none d-lg-flex justify-content-center">
                            <div class="featured-poster-container">
                                <div class="featured-poster-glow"></div>
                                <c:choose>
                                    <c:when test="${not empty featuredMovie.posterUrl}">
                                        <div class="featured-poster-card">
                                            <img src="${featuredMovie.posterUrl}" alt="${featuredMovie.title} Poster" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                            <div class="poster-placeholder" style="display:none; height: 100%;">
                                                <div class="placeholder-icon"><i class="bi bi-film"></i></div>
                                                <div class="placeholder-title">${featuredMovie.title}</div>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="featured-poster-card poster-placeholder">
                                            <div class="placeholder-icon"><i class="bi bi-film"></i></div>
                                            <div class="placeholder-title">${featuredMovie.title}</div>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </c:if>

        <main class="container py-5">

            <%-- ================= NOW SHOWING SECTION ================= --%>
            <section class="mb-5">
                <div class="d-flex justify-content-between align-items-end flex-wrap gap-3 mb-4">
                    <div>
                        <h2 class="section-title mb-1">Now Showing</h2>
                        <p class="section-desc">Book tickets for movies currently in our cinemas.</p>
                    </div>

                    <%-- Client-side Filter Genre Tabs --%>
                    <div class="genre-tabs">
                        <button type="button" class="genre-tab-btn active" data-genre-btn="All" onclick="filterGenre('All')">All</button>
                        <c:forEach var="gen" items="${genres}">
                            <button type="button" class="genre-tab-btn" data-genre-btn="${gen.name}" onclick="filterGenre('${gen.name}')">${gen.name}</button>
                        </c:forEach>
                    </div>
                </div>

                <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4" id="nowShowingGrid">
                    <c:choose>
                        <c:when test="${empty nowShowing}">
                            <div class="col-12 text-center py-5 text-muted">
                                <i class="bi bi-camera-reels fs-1 d-block mb-3"></i>
                                No movies currently now showing.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${nowShowing}">
                                <c:set var="mRating" value="${((m.movieId * 7) % 30) / 10 + 7.0}" />
                                <c:set var="mReviews" value="${(m.movieId * 243) % 1500 + 100}" />
                                
                                <%-- Construct string of genres for easy client filtering --%>
                                <c:set var="genresListStr" value="" />
                                <c:forEach var="g" items="${m.genres}" varStatus="st">
                                    <c:set var="genresListStr" value="${genresListStr}${g}${not st.last ? ',' : ''}" />
                                </c:forEach>

                                <div class="col now-showing-card-col" data-genres="${genresListStr}">
                                    <div class="movie-grid-card">
                                        <div class="movie-poster-wrap">
                                            <div class="movie-rating-badge">
                                                <i class="bi bi-star-fill"></i>
                                                <fmt:formatNumber value="${mRating}" pattern="0.0" />
                                            </div>
                                            <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}">
                                                <c:choose>
                                                    <c:when test="${not empty m.posterUrl}">
                                                        <img src="${m.posterUrl}" class="movie-poster-img" alt="${m.title} Poster" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                        <div class="poster-placeholder" style="display:none;">
                                                            <div class="placeholder-icon"><i class="bi bi-film"></i></div>
                                                            <div class="placeholder-title">${m.title}</div>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="poster-placeholder">
                                                            <div class="placeholder-icon"><i class="bi bi-film"></i></div>
                                                            <div class="placeholder-title">${m.title}</div>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                        </div>

                                        <div class="movie-card-info">
                                            <div>
                                                <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none">
                                                    <h5 class="movie-card-title text-truncate" title="<c:out value="${m.title}"/>">
                                                        <c:out value="${m.title}"/>
                                                    </h5>
                                                </a>
                                                <div class="d-flex align-items-center gap-2 mb-2">
                                                    <c:choose>
                                                        <c:when test="${m.rated == 'P'}">
                                                            <span class="badge-rated badge-rated-p">P</span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'K'}">
                                                            <span class="badge-rated badge-rated-k">K</span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'C13' || m.rated == 'T13'}">
                                                            <span class="badge-rated badge-rated-c13"><c:out value="${m.rated}"/></span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'C16' || m.rated == 'T16'}">
                                                            <span class="badge-rated badge-rated-c16"><c:out value="${m.rated}"/></span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'C18' || m.rated == 'T18'}">
                                                            <span class="badge-rated badge-rated-c18"><c:out value="${m.rated}"/></span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary"><c:out value="${m.rated}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <span class="text-muted small">&bull; ${m.durationMin} min</span>
                                                </div>
                                                
                                                <div class="text-truncate text-muted small mb-3">
                                                    <c:forEach var="g" items="${m.genres}" varStatus="st">
                                                        ${g}${not st.last ? ', ' : ''}
                                                    </c:forEach>
                                                </div>
                                            </div>
                                            
                                            <a href="${pageContext.request.contextPath}/booking/branches?movieId=${m.movieId}" class="btn btn-primary w-100 fw-semibold" style="border-radius: 8px;">
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

            <%-- ================= PROMOTION MIDDLE AD BANNER ================= --%>
            <section class="mb-5">
                <div class="promo-banner d-flex align-items-center justify-content-between flex-wrap gap-3">
                    <div>
                        <div class="promo-badge">SUMMER10</div>
                        <h4 class="fw-bold mb-1">10% off all bookings</h4>
                        <p class="mb-0 text-white-50 small">Min order 100,000đ. Valid through 31 July 2026.</p>
                    </div>
                    <div>
                        <a href="#" class="btn btn-light fw-bold text-navy px-4 py-2" style="border-radius: 8px;">Claim Offer</a>
                    </div>
                </div>
            </section>

            <%-- ================= COMING SOON SECTION ================= --%>
            <section class="mb-4">
                <div class="d-flex justify-content-between align-items-end flex-wrap gap-3 mb-4">
                    <div>
                        <h2 class="section-title mb-1">Coming Soon</h2>
                        <p class="section-desc">Upcoming releases — set a reminder.</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/movies?status=UPCOMING" class="text-primary fw-bold text-decoration-none">
                        View all <i class="bi bi-arrow-right"></i>
                    </a>
                </div>

                <div class="row row-cols-1 row-cols-sm-2 row-cols-md-3 row-cols-lg-4 g-4">
                    <c:choose>
                        <c:when test="${empty comingSoon}">
                            <div class="col-12 text-center py-5 text-muted">
                                <i class="bi bi-calendar-event fs-1 d-block mb-3"></i>
                                No upcoming movies scheduled.
                            </div>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="m" items="${comingSoon}">
                                <c:set var="mRating" value="${((m.movieId * 7) % 30) / 10 + 7.0}" />
                                <c:set var="mReviews" value="${(m.movieId * 243) % 1500 + 100}" />

                                <div class="col">
                                    <div class="movie-grid-card">
                                        <div class="movie-poster-wrap">
                                            <%-- Coming Soon Label --%>
                                            <div class="position-absolute px-2.5 py-1 text-white bg-dark fw-bold small" style="top: 12px; left: 12px; border-radius: 4px; z-index: 2; font-size: 0.72rem; letter-spacing: 0.5px; opacity: 0.85;">
                                                COMING SOON
                                            </div>
                                            <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}">
                                                <c:choose>
                                                    <c:when test="${not empty m.posterUrl}">
                                                        <img src="${m.posterUrl}" class="movie-poster-img" alt="${m.title} Poster" onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                                        <div class="poster-placeholder" style="display:none;">
                                                            <div class="placeholder-icon"><i class="bi bi-film"></i></div>
                                                            <div class="placeholder-title">${m.title}</div>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="poster-placeholder">
                                                            <div class="placeholder-icon"><i class="bi bi-film"></i></div>
                                                            <div class="placeholder-title">${m.title}</div>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </a>
                                        </div>

                                        <div class="movie-card-info">
                                            <div>
                                                <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="text-decoration-none">
                                                    <h5 class="movie-card-title text-truncate" title="<c:out value="${m.title}"/>">
                                                        <c:out value="${m.title}"/>
                                                    </h5>
                                                </a>
                                                
                                                <div class="d-flex align-items-center gap-2 mb-2">
                                                    <c:choose>
                                                        <c:when test="${m.rated == 'P'}">
                                                            <span class="badge-rated badge-rated-p">P</span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'K'}">
                                                            <span class="badge-rated badge-rated-k">K</span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'C13' || m.rated == 'T13'}">
                                                            <span class="badge-rated badge-rated-c13"><c:out value="${m.rated}"/></span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'C16' || m.rated == 'T16'}">
                                                            <span class="badge-rated badge-rated-c16"><c:out value="${m.rated}"/></span>
                                                        </c:when>
                                                        <c:when test="${m.rated == 'C18' || m.rated == 'T18'}">
                                                            <span class="badge-rated badge-rated-c18"><c:out value="${m.rated}"/></span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge bg-secondary"><c:out value="${m.rated}"/></span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <span class="text-muted small">&bull; ${m.durationMin} min</span>
                                                </div>
                                                
                                                <div class="text-truncate text-muted small mb-3">
                                                    <c:forEach var="g" items="${m.genres}" varStatus="st">
                                                        ${g}${not st.last ? ', ' : ''}
                                                    </c:forEach>
                                                </div>
                                            </div>
                                            
                                            <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}" class="btn btn-outline-primary w-100 fw-semibold" style="border-radius: 8px;">
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
                // Toggle active tab style
                $('.genre-tab-btn').removeClass('active');
                $('[data-genre-btn="' + genreName + '"]').addClass('active');

                // Filter movie cards
                if (genreName === 'All') {
                    $('.now-showing-card-col').fadeIn(300);
                } else {
                    $('.now-showing-card-col').each(function() {
                        var genresStr = $(this).attr('data-genres') || '';
                        var genresList = genresStr.split(',');
                        if (genresList.includes(genreName)) {
                            $(this).fadeIn(300);
                        } else {
                            $(this).fadeOut(300);
                        }
                    });
                }
            }
        </script>
    </body>
</html>