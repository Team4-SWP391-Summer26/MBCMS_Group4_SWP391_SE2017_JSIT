<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>All Movies - PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/movie-list.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>

<body>

    <jsp:include page="../common/header.jsp">
        <jsp:param name="activeMenu" value="movies" />
    </jsp:include>

    <section class="movies-page-hero">
        <div class="container public-shell">
            <nav class="movies-breadcrumb" aria-label="Breadcrumb">
                <a href="${pageContext.request.contextPath}/home">Home</a>
                <span class="sep" aria-hidden="true">/</span>
                <span>Movies</span>
            </nav>
            <span class="movies-page-kicker ml-reveal" style="--i:0"><i class="bi bi-collection-play"></i> Browse catalog</span>
            <h1 class="movies-page-title ml-reveal" style="--i:1">All Movies</h1>
            <p class="movies-page-subtitle ml-reveal" style="--i:2">
                Showing <strong>${fn:length(movies)}</strong> titles across PentaPlex cinema locations.
            </p>
        </div>
    </section>

    <main class="container public-shell movie-list-main">

        <form method="GET" action="${pageContext.request.contextPath}/movies" id="filterForm" class="ml-reveal" style="--i:3">
            <div class="filter-bar-custom">
                <div class="row g-3 align-items-center">

                    <div class="col-lg-4 col-md-6 col-12">
                        <div class="search-wrapper">
                            <i class="bi bi-search"></i>
                            <input type="text" class="form-control" name="q" placeholder="Search movies, directors, cast..." value="<c:out value='${keyword}'/>" aria-label="Search movies">
                        </div>
                    </div>

                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="genre" onchange="submitFilterForm()" aria-label="Filter by genre">
                            <option value="">All Genres</option>
                            <c:forEach var="g" items="${genres}">
                                <option value="${g.name}" <c:if test="${selectedGenre == g.name}">selected</c:if>>${g.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="status" onchange="submitFilterForm()" aria-label="Filter by status">
                            <option value="ALL" <c:if test="${selectedStatus == 'ALL'}">selected</c:if>>All Status</option>
                            <option value="NOW_SHOWING" <c:if test="${selectedStatus == 'NOW_SHOWING' || empty selectedStatus}">selected</c:if>>Now Showing</option>
                            <option value="UPCOMING" <c:if test="${selectedStatus == 'UPCOMING'}">selected</c:if>>Upcoming</option>
                        </select>
                    </div>

                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="sort" onchange="submitFilterForm()" aria-label="Sort movies">
                            <option value="release_desc" <c:if test="${selectedSort == 'release_desc'}">selected</c:if>>Release Date &darr;</option>
                            <option value="release_asc" <c:if test="${selectedSort == 'release_asc'}">selected</c:if>>Release Date &uarr;</option>
                            <option value="title_asc" <c:if test="${selectedSort == 'title_asc'}">selected</c:if>>Title (A-Z) &uarr;</option>
                            <option value="title_desc" <c:if test="${selectedSort == 'title_desc'}">selected</c:if>>Title (Z-A) &darr;</option>
                            <option value="duration_asc" <c:if test="${selectedSort == 'duration_asc'}">selected</c:if>>Duration (Shortest)</option>
                            <option value="duration_desc" <c:if test="${selectedSort == 'duration_desc'}">selected</c:if>>Duration (Longest)</option>
                        </select>
                    </div>

                    <div class="col-lg-2 col-md-6 col-12 d-flex justify-content-lg-end gap-2">
                        <button type="button" class="view-btn active" id="gridViewBtn" onclick="setViewMode('grid')" title="Grid view" aria-label="Grid view">
                            <i class="bi bi-grid-3x3-gap-fill"></i>
                        </button>
                        <button type="button" class="view-btn" id="listViewBtn" onclick="setViewMode('list')" title="List view" aria-label="List view">
                            <i class="bi bi-list-task"></i>
                        </button>
                    </div>

                </div>
            </div>
        </form>

        <div class="filter-chips ml-reveal" style="--i:4" id="filterChips">
            <span class="filter-chips-label">Active filters:</span>

            <c:if test="${not empty selectedStatus && selectedStatus != 'ALL'}">
                <div class="chip-custom">
                    <c:out value="${selectedStatus == 'NOW_SHOWING' ? 'Now Showing' : 'Upcoming'}"/>
                    <button type="button" class="chip-close" onclick="clearFilter('status')" aria-label="Remove status filter">
                        <i class="bi bi-x"></i>
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty keyword}">
                <div class="chip-custom">
                    Search: "<c:out value="${keyword}"/>"
                    <button type="button" class="chip-close" onclick="clearFilter('q')" aria-label="Remove search filter">
                        <i class="bi bi-x"></i>
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty selectedGenre}">
                <div class="chip-custom">
                    <c:out value="${selectedGenre}"/>
                    <button type="button" class="chip-close" onclick="clearFilter('genre')" aria-label="Remove genre filter">
                        <i class="bi bi-x"></i>
                    </button>
                </div>
            </c:if>

            <c:if test="${not empty selectedSort}">
                <div class="chip-custom">
                    Sort: <c:out value="${selectedSort == 'release_desc' ? 'Release Date ↓' : (selectedSort == 'release_asc' ? 'Release Date ↑' : (selectedSort == 'title_asc' ? 'Title (A-Z) ↑' : (selectedSort == 'title_desc' ? 'Title (Z-A) ↓' : (selectedSort == 'duration_asc' ? 'Duration (Shortest) ↑' : 'Duration (Longest) ↓'))))}"/>
                    <button type="button" class="chip-close" onclick="clearFilter('sort')" aria-label="Remove sort filter">
                        <i class="bi bi-x"></i>
                    </button>
                </div>
            </c:if>

            <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING" class="clear-all-link" id="clearAllLink">Clear all</a>
        </div>

        <c:choose>
            <c:when test="${empty movies}">
                <div class="movie-list-empty ml-reveal" style="--i:5">
                    <i class="bi bi-camera-reels"></i>
                    <h3>No movies found</h3>
                    <p>Try adjusting your filters or search query.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="movie-grid-custom ml-reveal" id="movieGrid" style="--i:5">
                    <c:forEach var="movie" items="${movies}" varStatus="st">
                        <c:set var="ratingVal" value="${7.8 + (movie.movieId % 17) / 10.0}" />
                        <c:set var="ratingStr"><fmt:formatNumber value="${ratingVal}" pattern="0.0" /></c:set>

                        <div class="movie-card-custom" style="--i:${st.index}">
                            <div class="poster-wrapper">
                                <a href="${pageContext.request.contextPath}/movies/detail?id=${movie.movieId}">
                                    <jsp:include page="../common/_poster.jsp">
                                        <jsp:param name="movieId" value="${movie.movieId}" />
                                        <jsp:param name="title" value="${movie.title}" />
                                        <jsp:param name="posterUrl" value="${movie.posterUrl}" />
                                    </jsp:include>
                                </a>
                                <span class="status-badge ${movie.status == 'NOW_SHOWING' ? 'status-now-showing' : (movie.status == 'UPCOMING' ? 'status-upcoming' : 'status-ended')}">
                                    <span class="badge-dot"></span>
                                    <c:out value="${movie.status == 'NOW_SHOWING' ? 'Now Showing' : (movie.status == 'UPCOMING' ? 'Upcoming' : 'Ended')}"/>
                                </span>
                            </div>

                            <div class="card-body-custom">
                                <div class="movie-title-row">
                                    <a class="movie-title-custom" href="${pageContext.request.contextPath}/movies/detail?id=${movie.movieId}" title="<c:out value='${movie.title}'/>">
                                        <c:out value="${movie.title}" />
                                    </a>
                                    <span class="age-badge age-${movie.rated}"><c:out value="${movie.rated}" /></span>
                                </div>

                                <div class="genre-chips-row">
                                    <c:forEach var="g" items="${movie.genres}">
                                        <span class="genre-chip">${g}</span>
                                    </c:forEach>
                                </div>

                                <div class="meta-info-row">
                                    <div class="meta-item">
                                        <i class="bi bi-clock me-1"></i>
                                        <span>${movie.durationMin} min</span>
                                    </div>
                                    <div class="meta-item">
                                        <i class="bi bi-star-fill me-1"></i>
                                        <span class="fw-semibold text-dark">${ratingStr}</span>
                                    </div>
                                </div>

                                <a href="${pageContext.request.contextPath}/booking/showtimes?movieId=${movie.movieId}" class="btn-book-custom">
                                    <i class="bi bi-ticket-perforated-fill"></i> Book Tickets
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <c:if test="${not empty movies}">
            <p class="movie-list-footnote mb-0">
                Showing all <strong>${fn:length(movies)}</strong> result<c:if test="${fn:length(movies) != 1}">s</c:if>.
            </p>
        </c:if>

    </main>

    <jsp:include page="../common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function submitFilterForm() {
            document.getElementById('filterForm').submit();
        }

        function clearFilter(paramName) {
            const form = document.getElementById('filterForm');
            const element = form.querySelector('[name="' + paramName + '"]');
            if (element) {
                if (paramName === 'status') {
                    element.value = 'ALL';
                } else {
                    element.value = '';
                }
            }
            form.submit();
        }

        function setViewMode(mode) {
            const grid = document.getElementById('movieGrid');
            const gridBtn = document.getElementById('gridViewBtn');
            const listBtn = document.getElementById('listViewBtn');
            if (!grid) return;

            if (mode === 'list') {
                grid.classList.add('list-view');
                listBtn.classList.add('active');
                gridBtn.classList.remove('active');
                localStorage.setItem('movieViewMode', 'list');
            } else {
                grid.classList.remove('list-view');
                gridBtn.classList.add('active');
                listBtn.classList.remove('active');
                localStorage.setItem('movieViewMode', 'grid');
            }
        }

        document.addEventListener('DOMContentLoaded', () => {
            const savedMode = localStorage.getItem('movieViewMode') || 'grid';
            setViewMode(savedMode);

            const chips = document.getElementById('filterChips');
            const clearLink = document.getElementById('clearAllLink');
            if (chips) {
                const activeChips = chips.querySelectorAll('.chip-custom');
                const hasFilters = activeChips.length > 0;
                chips.classList.toggle('is-empty', !hasFilters);
                if (clearLink) clearLink.hidden = !hasFilters;
            }

            let searchTimeout;
            const searchInput = document.querySelector('.search-wrapper input');
            if (searchInput) {
                searchInput.addEventListener('input', () => {
                    clearTimeout(searchTimeout);
                    searchTimeout = setTimeout(() => {
                        submitFilterForm();
                    }, 800);
                });
            }
        });
    </script>
</body>
</html>
