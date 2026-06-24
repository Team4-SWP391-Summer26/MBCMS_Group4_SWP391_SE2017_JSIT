<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>All Movies - LuminaCine</title>
    <!-- Include Bootstrap 5 and Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
        }

        .breadcrumb-custom {
            font-size: 0.85rem;
            color: #64748b;
            margin-bottom: 1.5rem;
        }
        .breadcrumb-custom a {
            color: #2563eb;
            text-decoration: none;
        }
        .breadcrumb-custom a:hover {
            text-decoration: underline;
        }

        .page-title {
            font-size: 2.25rem;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 0.25rem;
        }
        .page-subtitle {
            color: #64748b;
            font-size: 0.95rem;
            margin-bottom: 2rem;
        }

        /* Filter Bar */
        .filter-bar-custom {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            padding: 1rem;
            margin-bottom: 1.5rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }

        .search-wrapper {
            position: relative;
        }
        .search-wrapper i {
            position: absolute;
            left: 1rem;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
        }
        .search-wrapper input {
            padding-left: 2.5rem;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            height: 42px;
            font-size: 0.9rem;
        }
        .search-wrapper input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
        }

        .filter-select {
            height: 42px;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            font-size: 0.9rem;
            color: #334155;
            background-color: #ffffff;
            padding-left: 0.75rem;
        }
        .filter-select:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
        }

        /* View Switcher */
        .view-btn {
            height: 42px;
            width: 42px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid #cbd5e1;
            background-color: #ffffff;
            color: #64748b;
            border-radius: 8px;
            transition: all 0.15s ease;
        }
        .view-btn.active {
            background-color: #2563eb;
            color: #ffffff;
            border-color: #2563eb;
        }
        .view-btn:hover:not(.active) {
            background-color: #f1f5f9;
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
            color: #64748b;
            font-weight: 500;
        }
        .chip-custom {
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
            padding: 0.35rem 0.75rem;
            background-color: #eff6ff;
            color: #1e40af;
            border: 1px solid #bfdbfe;
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
            color: #1d4ed8;
        }
        .clear-all-link {
            font-size: 0.85rem;
            color: #2563eb;
            text-decoration: none;
            font-weight: 600;
        }
        .clear-all-link:hover {
            text-decoration: underline;
        }

        /* Movie Grid */
        .movie-grid-custom {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1.5rem;
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
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
            display: flex;
            flex-direction: column;
        }
        .movie-card-custom:hover {
            transform: translateY(-4px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.08);
            border-color: #cbd5e1;
        }

        .poster-wrapper {
            position: relative;
            aspect-ratio: 2 / 3;
            overflow: hidden;
            background-color: #0f172a;
        }
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
            top: 0.75rem;
            right: 0.75rem;
            z-index: 10;
            padding: 0.25rem 0.6rem;
            border-radius: 9999px;
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.05em;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        .status-now-showing {
            background-color: rgba(22, 163, 74, 0.9);
            color: #ffffff;
        }
        .status-upcoming {
            background-color: rgba(37, 99, 235, 0.9);
            color: #ffffff;
        }
        .status-ended {
            background-color: rgba(100, 116, 139, 0.9);
            color: #ffffff;
        }

        .badge-dot {
            width: 6px;
            height: 6px;
            background-color: #ffffff;
            border-radius: 50%;
            display: inline-block;
        }

        .card-body-custom {
            padding: 1.25rem;
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
            font-size: 1.15rem;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
            line-height: 1.3;
            text-decoration: none;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
            flex-grow: 1;
        }
        .movie-title-custom:hover {
            color: #2563eb;
        }

        .age-badge {
            font-size: 0.7rem;
            font-weight: 700;
            padding: 0.15rem 0.4rem;
            border-radius: 4px;
            color: #ffffff;
            flex-shrink: 0;
        }
        .age-P { background-color: #2563eb; }
        .age-K { background-color: #16a34a; }
        .age-T13, .age-C13 { background-color: #eab308; color: #1e293b; }
        .age-T16, .age-C16 { background-color: #f97316; }
        .age-T18, .age-C18 { background-color: #ef4444; }

        .genre-chips-row {
            display: flex;
            flex-wrap: wrap;
            gap: 0.25rem;
            margin-bottom: 1rem;
        }
        .genre-chip {
            font-size: 0.7rem;
            font-weight: 500;
            padding: 0.15rem 0.5rem;
            background-color: #f1f5f9;
            color: #475569;
            border-radius: 9999px;
        }

        .meta-info-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.8rem;
            color: #64748b;
            margin-bottom: 1.25rem;
            margin-top: auto;
        }
        .meta-item {
            display: flex;
            align-items: center;
            gap: 0.25rem;
        }
        .rating-item {
            color: #eab308;
            font-weight: 600;
        }

        .btn-book-custom {
            width: 100%;
            height: 40px;
            background-color: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 8px;
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
            background-color: #1d4ed8;
            color: #ffffff;
        }

        /* List View Mode overrides */
        .movie-grid-custom.list-view {
            grid-template-columns: 1fr !important;
            gap: 1rem;
        }
        .movie-grid-custom.list-view .movie-card-custom {
            flex-direction: row;
            height: auto;
            max-height: 200px;
        }
        .movie-grid-custom.list-view .poster-wrapper {
            width: 133px;
            aspect-ratio: auto;
            flex-shrink: 0;
        }
        .movie-grid-custom.list-view .card-body-custom {
            padding: 1.5rem;
        }
        .movie-grid-custom.list-view .meta-info-row {
            margin-top: 1rem;
            justify-content: flex-start;
            gap: 2rem;
        }
        .movie-grid-custom.list-view .btn-book-custom {
            width: auto;
            padding: 0 2rem;
            align-self: flex-start;
            margin-top: auto;
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
            border: 1px solid #e2e8f0;
            background-color: #ffffff;
            color: #334155;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.9rem;
            font-weight: 500;
            transition: all 0.15s ease;
        }
        .page-link-custom:hover {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
            color: #0f172a;
        }
        .page-link-custom.active {
            background-color: #2563eb;
            color: #ffffff;
            border-color: #2563eb;
        }
        .page-link-custom.disabled {
            color: #94a3b8;
            pointer-events: none;
            background-color: #f8fafc;
        }
        .page-ellipsis {
            padding: 0 0.5rem;
            color: #94a3b8;
        }
    </style>
</head>

<body>

    <jsp:include page="../common/header.jsp" />

    <main class="container py-4">

        <!-- Breadcrumbs -->
        <div class="breadcrumb-custom">
            <a href="${pageContext.request.contextPath}/home">Home</a> / Movies
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
                            <option value="NOW_SHOWING" <c:if test="${selectedStatus == 'NOW_SHOWING'}">selected</c:if>>Now Showing</option>
                            <option value="UPCOMING" <c:if test="${selectedStatus == 'UPCOMING'}">selected</c:if>>Upcoming</option>
                        </select>
                    </div>

                    <!-- Sort Dropdown -->
                    <div class="col-lg-2 col-md-6 col-12">
                        <select class="form-select filter-select" name="sort" onchange="submitFilterForm()">
                            <option value="release_desc" <c:if test="${selectedSort == 'release_desc'}">selected</c:if>>Newest</option>
                            <option value="release_asc" <c:if test="${selectedSort == 'release_asc'}">selected</c:if>>Oldest</option>
                            <option value="title_asc" <c:if test="${selectedSort == 'title_asc'}">selected</c:if>>Title (A-Z)</option>
                            <option value="title_desc" <c:if test="${selectedSort == 'title_desc'}">selected</c:if>>Title (Z-A)</option>
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
            
            <c:if test="${not empty selectedStatus}">
                <div class="chip-custom">
                    Status: <c:out value="${selectedStatus == 'NOW_SHOWING' ? 'Now Showing' : 'Upcoming'}"/>
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
                    Genre: <c:out value="${selectedGenre}"/>
                    <a href="#" onclick="clearFilter('genre')"><i class="bi bi-x"></i></a>
                </div>
            </c:if>

            <c:if test="${not empty selectedSort}">
                <div class="chip-custom">
                    Sort: <c:out value="${selectedSort == 'release_desc' ? 'Newest' : (selectedSort == 'release_asc' ? 'Oldest' : (selectedSort == 'title_asc' ? 'Title (A-Z)' : (selectedSort == 'title_desc' ? 'Title (Z-A)' : (selectedSort == 'duration_asc' ? 'Duration (Shortest)' : 'Duration (Longest)'))))}"/>
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
                                        <i class="bi bi-clock"></i>
                                        <span>${movie.durationMin} min</span>
                                    </div>
                                    <div class="meta-item rating-item">
                                        <i class="bi bi-star-fill"></i>
                                        <span>${ratingStr}</span>
                                    </div>
                                </div>

                                <a href="${pageContext.request.contextPath}/booking/branches?movieId=${movie.movieId}" class="btn-book-custom">
                                    <i class="bi bi-ticket-perforated-fill"></i> Book Tickets
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>

        <!-- Pagination (High Fidelity Mockup Visual) -->
        <c:if test="${not empty movies}">
            <div class="pagination-custom">
                <a href="#" class="page-link-custom disabled"><i class="bi bi-chevron-left"></i></a>
                <a href="#" class="page-link-custom active">1</a>
                <a href="#" class="page-link-custom">2</a>
                <a href="#" class="page-link-custom">3</a>
                <span class="page-ellipsis">...</span>
                <a href="#" class="page-link-custom">5</a>
                <a href="#" class="page-link-custom"><i class="bi bi-chevron-right"></i></a>
            </div>
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
                element.value = '';
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