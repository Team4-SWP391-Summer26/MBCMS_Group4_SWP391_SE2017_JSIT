<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>All Movies - MBCMS</title>
    <!-- Include Bootstrap 5 and Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Main Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    
    <style>
        body {
            font-family: var(--font-sans);
            background-color: var(--bg);
            color: var(--text);
        }

        .breadcrumb-custom {
            font-size: 0.85rem;
            color: var(--text-muted);
            margin-bottom: 1.5rem;
        }
        .breadcrumb-custom a {
            color: var(--primary);
            text-decoration: none;
        }
        .breadcrumb-custom a:hover {
            text-decoration: underline;
        }

        .page-title {
            font-size: 2.25rem;
            font-weight: 800;
            color: var(--text);
            margin-bottom: 0.25rem;
        }
        .page-subtitle {
            color: var(--text-muted);
            font-size: 0.95rem;
            margin-bottom: 2rem;
        }

        /* Filter Bar */
        .filter-bar-custom {
            background-color: #ffffff;
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 1rem;
            margin-bottom: 1.5rem;
            box-shadow: var(--shadow-sm);
        }

        .search-wrapper {
            position: relative;
        }
        .search-wrapper i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-subtle);
        }
        .search-wrapper input {
            padding-left: 2.6rem;
            border-radius: 10px;
            border: 1px solid var(--border-strong);
            height: 44px;
            font-size: 0.9rem;
            color: var(--text);
        }
        .search-wrapper input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        .filter-select {
            height: 44px;
            border-radius: 10px;
            border: 1px solid var(--border-strong);
            font-size: 0.9rem;
            color: var(--text);
            background-color: #ffffff;
            padding-left: 0.85rem;
        }
        .filter-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
        }

        /* View Switcher */
        .view-btn {
            height: 44px;
            width: 44px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border-strong);
            background-color: #ffffff;
            color: var(--text-muted);
            border-radius: 10px;
            transition: all 0.15s ease;
        }
        .view-btn.active {
            background-color: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
        }
        .view-btn:hover:not(.active) {
            background-color: var(--surface-2);
        }

        /* Active Filter Chips */
        .filter-chips {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            flex-wrap: wrap;
            margin-bottom: 2rem;
        }
        .filter-chips-label {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 500;
        }
        .chip-custom {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.35rem 0.75rem;
            background-color: var(--primary-50);
            color: #1e40af;
            border: 1px solid var(--primary-200);
            border-radius: 9999px;
            font-size: 0.8rem;
            font-weight: 500;
        }
        .chip-custom a {
            color: #1e40af;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }
        .chip-custom a:hover {
            color: var(--primary-700);
        }
        .clear-all-link {
            font-size: 0.85rem;
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
        }
        .clear-all-link:hover {
            text-decoration: underline;
        }

        /* Movie Grid — đồng bộ kích thước thẻ với trang chủ */
        .movie-grid-custom {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 1.25rem;
            margin-bottom: 3rem;
            transition: all 0.25s ease;
        }

        @media (max-width: 1200px) {
            .movie-grid-custom {
                grid-template-columns: repeat(3, 1fr);
            }
        }
        @media (max-width: 768px) {
            .movie-grid-custom {
                grid-template-columns: repeat(2, 1fr);
            }
        }
        @media (max-width: 480px) {
            .movie-grid-custom {
                grid-template-columns: 1fr;
            }
        }

        /* Movie Card */
        .movie-card-custom {
            background-color: #ffffff;
            border: 1px solid var(--border);
            border-radius: 14px;
            overflow: hidden;
            box-shadow: var(--shadow-sm);
            transition: transform 0.2s ease, box-shadow 0.2s ease, border-color 0.2s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
            padding: 8px;
        }
        .movie-card-custom:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-lg);
            border-color: var(--primary-200);
        }

        .poster-wrapper {
            position: relative;
            aspect-ratio: 2 / 3;
            overflow: hidden;
            background-color: var(--navy);
            border-radius: 12px;
        }
        .poster-wrapper .poster-art { position: absolute; inset: 0; width: 100%; height: 100%; }
        .poster-wrapper img {
            width: 100%;
            height: 100%;
            object-fit: cover;
            transition: transform 0.3s ease;
        }
        .movie-card-custom:hover .poster-wrapper img {
            transform: scale(1.05);
        }

        .status-badge {
            position: absolute;
            top: 0.6rem;
            left: 0.6rem;
            z-index: 3;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.26rem 0.6rem;
            border-radius: 999px;
            font-size: 0.68rem;
            font-weight: 600;
            letter-spacing: 0.01em;
            color: #fff;
            background: rgba(15, 23, 42, 0.58);
            -webkit-backdrop-filter: blur(6px);
            backdrop-filter: blur(6px);
            border: 1px solid rgba(255, 255, 255, 0.16);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.22);
        }
        .badge-dot {
            width: 6px;
            height: 6px;
            border-radius: 50%;
            display: inline-block;
            background: #34d399;
            flex-shrink: 0;
        }
        .status-now-showing .badge-dot { background: #34d399; }
        .status-upcoming .badge-dot { background: #60a5fa; }
        .status-ended .badge-dot { background: #cbd5e1; }

        .card-body-custom {
            padding: 0.8rem 0.5rem 0.45rem;
            flex-grow: 1;
            display: flex;
            flex-direction: column;
        }

        .movie-title-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 0.5rem;
            margin-bottom: 0.5rem;
        }

        .movie-title-custom {
            font-size: 1rem;
            font-weight: 700;
            color: var(--text);
            margin: 0;
            line-height: 1.3;
            text-decoration: none;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            flex-grow: 1;
        }
        .movie-title-custom:hover {
            color: var(--primary);
        }

        .age-badge {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 0.15rem 0.4rem;
            border-radius: 4px;
            color: #ffffff;
            flex-shrink: 0;
        }
        .age-P { background-color: var(--primary); }
        .age-K { background-color: var(--success); }
        .age-T13, .age-C13 { background-color: #eab308; color: #ffffff; }
        .age-T16, .age-C16 { background-color: #f97316; }
        .age-T18, .age-C18 { background-color: var(--danger); }

        .genre-chips-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.25rem;
            margin-bottom: 1rem;
        }
        .genre-chip {
            font-size: 0.7rem;
            font-weight: 600;
            padding: 0.15rem 0.5rem;
            background-color: var(--primary-50);
            color: var(--primary-700);
            border: 1px solid var(--primary-100);
            border-radius: 9999px;
        }

        .meta-info-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.8rem;
            color: var(--text-muted);
            margin-bottom: 0.9rem;
            margin-top: auto;
        }
        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }
        .rating-item {
            color: var(--gold);
            font-weight: 600;
        }

        .btn-book-custom {
            width: 100%;
            height: 42px;
            background-color: var(--primary);
            color: #ffffff;
            border: none;
            border-radius: 10px;
            font-size: 0.875rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            transition: background-color 0.15s ease;
            text-decoration: none;
        }
        .btn-book-custom:hover {
            background-color: var(--primary-700);
            color: #ffffff;
        }

        /* List View Mode — horizontal card gọn, đồng bộ với grid */
        .movie-grid-custom.list-view {
            grid-template-columns: 1fr !important;
            gap: 1rem;
        }
        .movie-grid-custom.list-view .movie-card-custom {
            flex-direction: row;
            height: auto;
        }
        .movie-grid-custom.list-view .poster-wrapper {
            width: 116px;
            aspect-ratio: 2 / 3;
            flex-shrink: 0;
        }
        .movie-grid-custom.list-view .status-badge {
            display: none;
        }
        .movie-grid-custom.list-view .card-body-custom {
            padding: 1.1rem 1.4rem;
            justify-content: center;
        }
        .movie-grid-custom.list-view .movie-title-row {
            justify-content: flex-start;
            gap: .5rem;
            margin-bottom: .45rem;
        }
        .movie-grid-custom.list-view .movie-title-custom {
            flex-grow: 0;
        }
        .movie-grid-custom.list-view .genre-chips-row {
            margin-bottom: .55rem;
        }
        .movie-grid-custom.list-view .meta-info-row {
            margin: 0 0 .9rem;
            justify-content: flex-start;
            gap: 1.75rem;
        }
        .movie-grid-custom.list-view .btn-book-custom {
            width: auto;
            align-self: flex-start;
            padding: 0 1.75rem;
        }

        /* Pagination */
        .pagination-custom {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.25rem;
            margin-top: 2rem;
        }
        .page-link-custom {
            height: 38px;
            width: 38px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid var(--border);
            background-color: #ffffff;
            color: #334155;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.15s ease;
        }
        .page-link-custom:hover {
            background-color: var(--surface-2);
            border-color: var(--border-strong);
            color: var(--text);
        }
        .page-link-custom.active {
            background-color: var(--primary);
            color: #ffffff;
            border-color: var(--primary);
        }
        .page-link-custom.disabled {
            color: var(--text-subtle);
            pointer-events: none;
            background-color: var(--surface-2);
        }
        .page-ellipsis {
            padding: 0 0.5rem;
            color: var(--text-subtle);
        }
    </style>
</head>

<body>

    <jsp:include page="../common/header.jsp">
        <jsp:param name="activeMenu" value="movies" />
    </jsp:include>

    <main class="container py-4" style="max-width:1200px;">

        <div class="breadcrumb-custom">
            <a href="${pageContext.request.contextPath}/home">Home</a> / <span>Movies</span>
        </div>
        <h1 class="page-title">All Movies</h1>
        <p class="page-subtitle">Showing <strong>${fn:length(movies)}</strong> movies across all LuminaCine locations.</p>

        <!-- Filters Form -->
        <form method="GET" action="${pageContext.request.contextPath}/movies" id="filterForm">
            <div class="filter-bar-custom">
                <div class="row g-3 align-items-center">
                    
                    <!-- Search Input -->
                    <div class="col-lg-4 col-md-6 col-12">
                        <div class="search-wrapper">
                            <i class="bi bi-search"></i>
                            <input type="text" class="form-control" name="q" placeholder="Search movies, directors, cast..." value="<c:out value='${keyword}'/>">
                        </div>
                    </div>

                    <!-- Genre Dropdown -->
                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="genre" onchange="submitFilterForm()">
                            <option value="">All Genres</option>
                            <c:forEach var="g" items="${genres}">
                                <option value="${g.name}" <c:if test="${selectedGenre == g.name}">selected</c:if>>${g.name}</option>
                            </c:forEach>
                        </select>
                    </div>

                    <!-- Status Dropdown -->
                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="status" onchange="submitFilterForm()">
                            <option value="ALL" <c:if test="${selectedStatus == 'ALL'}">selected</c:if>>All Status</option>
                            <option value="NOW_SHOWING" <c:if test="${selectedStatus == 'NOW_SHOWING' || empty selectedStatus}">selected</c:if>>Now Showing</option>
                            <option value="UPCOMING" <c:if test="${selectedStatus == 'UPCOMING'}">selected</c:if>>Upcoming</option>
                        </select>
                    </div>

                    <!-- Sort Dropdown -->
                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="sort" onchange="submitFilterForm()">
                            <option value="release_desc" <c:if test="${selectedSort == 'release_desc'}">selected</c:if>>Release Date &darr;</option>
                            <option value="release_asc" <c:if test="${selectedSort == 'release_asc'}">selected</c:if>>Release Date &uarr;</option>
                            <option value="title_asc" <c:if test="${selectedSort == 'title_asc'}">selected</c:if>>Title (A-Z) &uarr;</option>
                            <option value="title_desc" <c:if test="${selectedSort == 'title_desc'}">selected</c:if>>Title (Z-A) &darr;</option>
                            <option value="duration_asc" <c:if test="${selectedSort == 'duration_asc'}">selected</c:if>>Duration (Shortest)</option>
                            <option value="duration_desc" <c:if test="${selectedSort == 'duration_desc'}">selected</c:if>>Duration (Longest)</option>
                        </select>
                    </div>

                    <!-- Layout Switchers -->
                    <div class="col-lg-2 col-md-6 col-12 d-flex justify-content-lg-end gap-2">
                        <button type="button" class="view-btn active" id="gridViewBtn" onclick="setViewMode('grid')" title="Grid View">
                            <i class="bi bi-grid-3x3-gap-fill"></i>
                        </button>
                        <button type="button" class="view-btn" id="listViewBtn" onclick="setViewMode('list')" title="List View">
                            <i class="bi bi-list-task"></i>
                        </button>
                    </div>

                </div>
            </div>
        </form>

        <!-- Active Filter Chips -->
        <div class="filter-chips">
            <span class="filter-chips-label">Active filters:</span>
            
            <c:if test="${not empty selectedStatus && selectedStatus != 'ALL'}">
                <div class="chip-custom">
                    <c:out value="${selectedStatus == 'NOW_SHOWING' ? 'Now Showing' : 'Upcoming'}"/>
                    <a href="#" onclick="clearFilter('status')"><i class="bi bi-x"></i></a>
                </div>
            </c:if>

            <c:if test="${not empty keyword}">
                <div class="chip-custom">
                    Search: "<c:out value="${keyword}"/>"
                    <a href="#" onclick="clearFilter('q')"><i class="bi bi-x"></i></a>
                </div>
            </c:if>

            <c:if test="${not empty selectedGenre}">
                <div class="chip-custom">
                    <c:out value="${selectedGenre}"/>
                    <a href="#" onclick="clearFilter('genre')"><i class="bi bi-x"></i></a>
                </div>
            </c:if>

            <c:if test="${not empty selectedSort}">
                <div class="chip-custom">
                    Sort: <c:out value="${selectedSort == 'release_desc' ? 'Release Date ↓' : (selectedSort == 'release_asc' ? 'Release Date ↑' : (selectedSort == 'title_asc' ? 'Title (A-Z) ↑' : (selectedSort == 'title_desc' ? 'Title (Z-A) ↓' : (selectedSort == 'duration_asc' ? 'Duration (Shortest) ↑' : 'Duration (Longest) ↓'))))}"/>
                    <a href="#" onclick="clearFilter('sort')"><i class="bi bi-x"></i></a>
                </div>
            </c:if>

            <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING" class="clear-all-link">Clear all</a>
        </div>

        <!-- Movie List Container -->
        <c:choose>
            <c:when test="${empty movies}">
                <div class="text-center py-5">
                    <i class="bi bi-camera-reels text-muted" style="font-size: 3rem;"></i>
                    <h3 class="mt-3 text-muted">No movies found</h3>
                    <p class="text-muted">Try adjusting your filters or search query.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="movie-grid-custom" id="movieGrid">
                    <c:forEach var="movie" items="${movies}">
                        <c:set var="ratingVal" value="${7.8 + (movie.movieId % 17) / 10.0}" />
                        <c:set var="votesVal" value="${350 + (movie.movieId * 149) % 1500}" />
                        <c:set var="ratingStr"><fmt:formatNumber value="${ratingVal}" pattern="0.0" /></c:set>
                        <c:set var="votesStr"><fmt:formatNumber value="${votesVal}" pattern="#,##0" /></c:set>

                        <div class="movie-card-custom">
                            <!-- Poster & Ribbon Tag -->
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

                            <!-- Body -->
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
                                        <i class="bi bi-star-fill text-warning me-1"></i>
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
            <p class="text-center text-muted small mb-0 mt-2">
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

        // Restore View Mode
        document.addEventListener('DOMContentLoaded', () => {
            const savedMode = localStorage.getItem('movieViewMode') || 'grid';
            setViewMode(savedMode);
            
            // Auto submit search on delay
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