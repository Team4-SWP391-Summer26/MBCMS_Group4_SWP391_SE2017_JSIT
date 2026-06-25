<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${movie.title} - LuminaCine</title>
    <!-- Include Bootstrap 5 and Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Google Fonts: Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- Main Custom CSS -->
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f8fafc;
            color: #0f172a;
        }

        .breadcrumb-custom {
            font-size: 0.85rem;
            color: #64748b;
            margin-bottom: 2rem;
        }
        .breadcrumb-custom a {
            color: #2563eb;
            text-decoration: none;
        }
        .breadcrumb-custom a:hover {
            text-decoration: underline;
        }

        /* Split Layout */
        .movie-poster-card {
            border-radius: 16px;
            overflow: hidden;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
            margin-bottom: 1.5rem;
        }

        .btn-trailer-custom {
            height: 46px;
            border-radius: 8px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            width: 100%;
        }

        /* Movie Details Block */
        .detail-info-block {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 2rem;
            margin-bottom: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }

        .movie-detail-title {
            font-size: 2.5rem;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 1rem;
            line-height: 1.15;
        }

        .metadata-row {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            flex-wrap: wrap;
            margin-bottom: 1.25rem;
        }

        .age-badge {
            font-size: 0.75rem;
            font-weight: 700;
            padding: 0.2rem 0.6rem;
            border-radius: 6px;
            color: #ffffff;
        }
        .age-P { background-color: #2563eb; }
        .age-K { background-color: #16a34a; }
        .age-T13, .age-C13 { background-color: #eab308; color: #ffffff; }
        .age-T16, .age-C16 { background-color: #f97316; }
        .age-T18, .age-C18 { background-color: #ef4444; }

        .meta-text {
            font-size: 0.9rem;
            color: #64748b;
            font-weight: 500;
        }

        .genre-badge {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.2rem 0.75rem;
            background-color: #eff6ff;
            color: #1d4ed8;
            border-radius: 9999px;
            border: 1px solid #dbeafe;
        }

        .status-badge-inline {
            font-size: 0.75rem;
            font-weight: 600;
            padding: 0.2rem 0.75rem;
            background-color: #f0fdf4;
            color: #16a34a;
            border-radius: 9999px;
            border: 1px solid #dcfce7;
            display: inline-flex;
            align-items: center;
            gap: 0.35rem;
        }
        .status-badge-inline.upcoming {
            background-color: #eff6ff;
            color: #2563eb;
            border-color: #dbeafe;
        }
        .status-dot {
            width: 6px;
            height: 6px;
            background-color: currentColor;
            border-radius: 50%;
        }

        /* Rating Row */
        .rating-row {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 2rem;
            font-size: 1.1rem;
        }
        .stars-wrapper {
            color: #eab308;
            display: flex;
            gap: 0.15rem;
        }
        .rating-score {
            font-weight: 700;
            color: #0f172a;
            margin-left: 0.25rem;
        }
        .vote-count {
            color: #64748b;
            font-size: 0.9rem;
        }

        /* Movie Details Info */
        .movie-details-info {
            font-size: 0.95rem;
            line-height: 1.5;
            margin-bottom: 2rem;
        }
        .info-item-label {
            font-weight: 700;
            color: #1e293b;
        }
        .info-item-value {
            color: #475569;
        }

        /* Action Buttons */
        .action-buttons-row {
            display: flex;
            gap: 1rem;
        }
        .btn-book-primary {
            height: 48px;
            background-color: #2563eb;
            color: #ffffff;
            border: none;
            border-radius: 8px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0 2rem;
            text-decoration: none;
            transition: background-color 0.15s ease;
        }
        .btn-book-primary:hover {
            background-color: #1d4ed8;
            color: #ffffff;
        }

        .btn-save-outline {
            height: 48px;
            background-color: #ffffff;
            color: #475569;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
            padding: 0 1.5rem;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .btn-save-outline:hover {
            background-color: #f8fafc;
            border-color: #94a3b8;
            color: #0f172a;
        }

        /* Synopsis Section */
        .section-header {
            font-size: 1.5rem;
            font-weight: 700;
            color: #0f172a;
            margin-bottom: 1rem;
            margin-top: 2rem;
        }
        .synopsis-text {
            color: #475569;
            line-height: 1.7;
            font-size: 0.95rem;
        }

        /* Available Showtimes Card */
        .showtimes-card {
            background-color: #ffffff;
            border: 1px solid #e2e8f0;
            border-radius: 16px;
            padding: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
            margin-bottom: 3rem;
        }

        .showtimes-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1.5rem;
            flex-wrap: wrap;
            gap: 1rem;
        }
        .showtimes-title {
            font-size: 1.35rem;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
        }
        .cinema-filter-select {
            width: 220px;
            height: 40px;
            border-radius: 8px;
            border: 1px solid #cbd5e1;
            font-size: 0.9rem;
            font-weight: 500;
            color: #334155;
        }

        /* Date Tabs Row */
        .date-tabs-row {
            display: flex;
            gap: 0.5rem;
            overflow-x: auto;
            padding-bottom: 0.75rem;
            margin-bottom: 2rem;
            border-bottom: 1px solid #f1f5f9;
        }
        .date-tab-btn {
            flex: 0 0 auto;
            width: 72px;
            height: 64px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            border-radius: 10px;
            border: 1px solid #cbd5e1;
            background-color: #ffffff;
            color: #475569;
            transition: all 0.15s ease;
            cursor: pointer;
        }
        .date-tab-btn .day-name {
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            margin-bottom: 0.25rem;
            color: #94a3b8;
        }
        .date-tab-btn .date-val {
            font-size: 0.95rem;
            font-weight: 700;
        }
        .date-tab-btn:hover:not(.active) {
            background-color: #f8fafc;
            border-color: #94a3b8;
            color: #0f172a;
        }
        .date-tab-btn.active {
            background-color: #2563eb;
            border-color: #2563eb;
            color: #ffffff;
        }
        .date-tab-btn.active .day-name {
            color: rgba(255, 255, 255, 0.75);
        }

        /* Cinema Branches list */
        .cinema-branch-block {
            border-bottom: 1px solid #f1f5f9;
            padding-bottom: 1.5rem;
            margin-bottom: 1.5rem;
        }
        .cinema-branch-block:last-child {
            border-bottom: none;
            padding-bottom: 0;
            margin-bottom: 0;
        }

        .cinema-title-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 1.25rem;
            flex-wrap: wrap;
            gap: 0.5rem;
        }
        .cinema-name {
            font-size: 1.15rem;
            font-weight: 700;
            color: #0f172a;
            margin: 0;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .cinema-name i {
            color: #2563eb;
        }
        .cinema-address {
            font-size: 0.85rem;
            color: #64748b;
            font-weight: 400;
            margin-left: 1.65rem;
            margin-top: -0.25rem;
        }
        .map-link {
            font-size: 0.85rem;
            color: #2563eb;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
        }
        .map-link:hover {
            text-decoration: underline;
        }

        /* Room group layouts */
        .room-row {
            display: grid;
            grid-template-columns: 240px 1fr;
            gap: 1.5rem;
            padding: 1rem 0;
            align-items: center;
            border-top: 1px solid #f8fafc;
        }
        .room-row:first-of-type {
            border-top: none;
        }

        .room-details {
            display: flex;
            flex-direction: column;
        }
        .room-name-type {
            font-size: 0.95rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 0.25rem;
        }
        .room-price-from {
            font-size: 0.8rem;
            color: #64748b;
        }

        .showtime-slots-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 0.75rem;
        }

        /* Showtime button styling */
        .showtime-slot-btn {
            display: inline-flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            width: 78px;
            height: 48px;
            border-radius: 8px;
            border: 1px solid #2563eb;
            background-color: #ffffff;
            color: #2563eb;
            text-decoration: none;
            transition: all 0.15s ease;
        }
        .showtime-slot-btn .slot-time {
            font-size: 0.95rem;
            font-weight: 700;
            color: #2563eb;
        }
        .showtime-slot-btn .slot-price-label {
            font-size: 0.68rem;
            color: #2563eb;
            font-weight: 500;
            margin-top: -0.1rem;
        }
        .showtime-slot-btn:hover:not(.disabled) {
            border-color: #1d4ed8;
            color: #1d4ed8;
            background-color: #eff6ff;
        }
        .showtime-slot-btn:hover:not(.disabled) .slot-time,
        .showtime-slot-btn:hover:not(.disabled) .slot-price-label {
            color: #1d4ed8;
        }
        .showtime-slot-btn.disabled {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
            color: #94a3b8;
            cursor: not-allowed;
            pointer-events: none;
        }
        .showtime-slot-btn.disabled .slot-time {
            color: #94a3b8;
        }
        .showtime-slot-btn.disabled .slot-price-label {
            color: #94a3b8;
        }

        /* Legend styling with custom checkbox design */
        .showtimes-legend {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            margin-top: 2rem;
            padding-top: 1.5rem;
            border-top: 1px solid #f1f5f9;
            flex-wrap: wrap;
            font-size: 0.85rem;
            color: #475569;
        }
        .legend-item {
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        .legend-checkbox {
            width: 16px;
            height: 16px;
            border-radius: 4px;
            border: 1px solid #cbd5e1;
            background-color: #ffffff;
            display: inline-block;
            vertical-align: middle;
        }
        .legend-checkbox.standard {
            border-color: #cbd5e1;
        }
        .legend-checkbox.vip {
            border-color: #f59e0b;
        }
        .legend-checkbox.imax {
            border-color: #c084fc;
        }
    </style>
</head>

<body>

    <jsp:include page="../common/header.jsp">
        <jsp:param name="activeMenu" value="movies" />
    </jsp:include>

    <main class="container py-4">

        <!-- Breadcrumbs -->
        <div class="breadcrumb-custom">
            <a href="${pageContext.request.contextPath}/home">Home</a> / 
            <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Movies</a> / 
            <c:out value="${movie.title}"/>
        </div>

        <div class="row g-4">
            
            <!-- LEFT COLUMN: Poster & Trailer -->
            <div class="col-lg-4 col-md-5 col-12">
                <div class="movie-poster-card">
                    <jsp:include page="../common/_poster.jsp">
                        <jsp:param name="movieId" value="${movie.movieId}" />
                        <jsp:param name="title" value="${movie.title}" />
                        <jsp:param name="posterUrl" value="${movie.posterUrl}" />
                    </jsp:include>
                </div>
                
                <c:if test="${not empty movie.trailerUrl}">
                    <a href="${movie.trailerUrl}" target="_blank" class="btn btn-outline-primary btn-trailer-custom">
                        <i class="bi bi-play-fill"></i> Watch Trailer
                    </a>
                </c:if>
            </div>

            <!-- RIGHT COLUMN: Detail Info -->
            <div class="col-lg-8 col-md-7 col-12">
                <div class="detail-info-block">
                    <h1 class="movie-detail-title"><c:out value="${movie.title}"/></h1>
                    
                    <!-- Metadata row -->
                    <div class="metadata-row">
                        <span class="age-badge age-${movie.rated}"><c:out value="${movie.rated}"/></span>
                        <span class="meta-text">${fn:substring(movie.releaseDate, 0, 4)}</span>
                        <span class="meta-text">${movie.durationMin} min</span>
                        <c:forEach var="g" items="${movie.genres}">
                            <span class="genre-badge">${g}</span>
                        </c:forEach>
                        <span class="status-badge-inline ${movie.status == 'NOW_SHOWING' ? '' : 'upcoming'}">
                            <span class="status-dot"></span>
                            <span><c:out value="${movie.status == 'NOW_SHOWING' ? 'Now Showing' : 'Upcoming'}"/></span>
                        </span>
                    </div>

                    <!-- Rating row -->
                    <c:set var="ratingVal" value="${7.8 + (movie.movieId % 17) / 10.0}" />
                    <c:set var="votesVal" value="${350 + (movie.movieId * 149) % 1500}" />
                    <c:set var="ratingStr"><fmt:formatNumber value="${ratingVal}" pattern="0.0" /></c:set>
                    <c:set var="votesStr"><fmt:formatNumber value="${votesVal}" pattern="#,##0" /></c:set>

                    <div class="rating-row">
                        <div class="stars-wrapper">
                            <c:forEach var="i" begin="1" end="5">
                                <c:choose>
                                    <c:when test="${ratingVal >= (i * 2)}">
                                        <i class="bi bi-star-fill"></i>
                                    </c:when>
                                    <c:when test="${ratingVal >= (i * 2 - 1)}">
                                        <i class="bi bi-star-half"></i>
                                    </c:when>
                                    <c:otherwise>
                                        <i class="bi bi-star"></i>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                        <span class="rating-score">${ratingStr}/10</span>
                        <span class="vote-count">(${votesStr})</span>
                    </div>

                    <!-- Details Layout (2-column Director/Language, full Cast below) -->
                    <div class="movie-details-info">
                        <div class="row g-3">
                            <div class="col-md-6 col-12">
                                <span class="info-item-label">Director:</span>
                                <span class="info-item-value"><c:out value="${not empty movie.director ? movie.director : 'N/A'}"/></span>
                            </div>
                            <div class="col-md-6 col-12">
                                <span class="info-item-label">Language:</span>
                                <span class="info-item-value"><c:out value="${not empty movie.language ? movie.language : 'English'}"/></span>
                            </div>
                            <div class="col-12 mt-2">
                                <span class="info-item-label">Cast:</span>
                                <span class="info-item-value"><c:out value="${not empty movie.castList ? movie.castList : 'N/A'}"/></span>
                            </div>
                        </div>
                    </div>

                    <!-- Action buttons -->
                    <div class="action-buttons-row">
                        <a href="#showtimes-section" class="btn-book-primary">
                            <i class="bi bi-ticket-perforated-fill"></i> Book Tickets
                        </a>
                        <button class="btn-save-outline">
                            <i class="bi bi-bookmark"></i> Save
                        </button>
                    </div>
                </div>

                <!-- Synopsis Section -->
                <h3 class="section-header">Synopsis</h3>
                <p class="synopsis-text"><c:out value="${movie.description}"/></p>
            </div>

        </div> <!-- /row -->

        <!-- SHOWTIMES SECTION -->
        <div class="showtimes-card" id="showtimes-section">
            
            <div class="showtimes-header-row">
                <h3 class="showtimes-title">Available Showtimes</h3>
                
                <!-- Cinema branch filter dropdown -->
                <select class="form-select cinema-filter-select" onchange="selectBranch(this.value)">
                    <option value="all">All Cinemas</option>
                    <c:forEach var="b" items="${branches}">
                        <option value="${b.branchId}" <c:if test="${selectedBranchId == b.branchId}">selected</c:if>>${b.name}</option>
                    </c:forEach>
                </select>
            </div>

            <!-- Date Selectors Tabs -->
            <div class="date-tabs-row">
                <c:forEach var="tab" items="${dateTabs}">
                    <div class="date-tab-btn ${tab.active ? 'active' : ''}" onclick="selectDate('${tab.date}')">
                        <span class="day-name">${tab.day}</span>
                        <span class="date-val">${tab.label}</span>
                    </div>
                </c:forEach>
            </div>

            <!-- Showtimes List Grouped by Cinema -->
            <c:choose>
                <c:when test="${empty branchShowtimesList}">
                    <div class="text-center py-5 text-muted">
                        <i class="bi bi-calendar-x" style="font-size: 2.5rem;"></i>
                        <h5 class="mt-3">No showtimes found for the selected date and branch</h5>
                        <p class="small">Please choose another date or cinema.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="bs" items="${branchShowtimesList}">
                        <div class="cinema-branch-block">
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
                                <a href="https://maps.google.com/?q=${bs.branch.name} ${bs.branch.address}" target="_blank" class="map-link">
                                    View on map <i class="bi bi-arrow-up-right"></i>
                                </a>
                            </div>

                            <!-- Room lists within this cinema -->
                            <div class="ms-lg-4 ms-2">
                                <c:forEach var="rg" items="${bs.roomGroups}">
                                    <div class="room-row">
                                        <div class="room-details">
                                            <span class="room-name-type">
                                                ${rg.roomName} &bull; ${rg.roomType} &bull; ${rg.format} ${rg.subtitleType}
                                            </span>
                                            <span class="room-price-from">
                                                From <fmt:formatNumber value="${rg.minPrice}" pattern="#,##0"/>đ
                                            </span>
                                        </div>
                                        <div class="showtime-slots-grid">
                                            <c:forEach var="slot" items="${rg.slots}">
                                                <c:choose>
                                                    <c:when test="${slot.full}">
                                                        <a href="#" class="showtime-slot-btn disabled" title="Full Seats">
                                                            <span class="slot-time">${slot.time}</span>
                                                            <span class="slot-price-label">Full</span>
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/booking/seats?showtimeId=${slot.showtimeId}" class="showtime-slot-btn">
                                                            <span class="slot-time">${slot.time}</span>
                                                            <span class="slot-price-label">
                                                                <fmt:formatNumber value="${slot.price}" pattern="#,##0"/>đ
                                                            </span>
                                                        </a>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:forEach>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>

            <!-- Showtime pricing category legend -->
            <div class="showtimes-legend">
                <div class="legend-item">
                    <span class="legend-checkbox standard"></span>
                    <span>Standard 80,000đ</span>
                </div>
                <div class="legend-item">
                    <span class="legend-checkbox vip"></span>
                    <span>VIP 140,000đ</span>
                </div>
                <div class="legend-item">
                    <span class="legend-checkbox imax"></span>
                    <span>IMAX 100,000đ</span>
                </div>
            </div>

        </div>

    </main>

    <jsp:include page="../common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function selectDate(dateStr) {
            const movieId = '${movie.movieId}';
            const branchId = '${selectedBranchId}';
            window.location.href = '${pageContext.request.contextPath}/movies/detail?id=' + movieId + '&date=' + dateStr + '&branchId=' + branchId;
        }

        function selectBranch(branchIdVal) {
            const movieId = '${movie.movieId}';
            const dateStr = '${selectedDate}';
            window.location.href = '${pageContext.request.contextPath}/movies/detail?id=' + movieId + '&date=' + dateStr + '&branchId=' + branchIdVal;
        }
    </script>
</body>
</html>