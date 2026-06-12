<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>MBCMS - Book movie tickets online</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>

    <body>

        <jsp:include page="common/header.jsp" />

        <!-- Hero -->
        <section class="hero-banner">
            <div class="container position-relative">
                <div class="row align-items-center" style="min-height: 320px;">
                    <div class="col-lg-7 py-5">
                        <span class="hero-eyebrow">Multi-Branch Cinema</span>
                        <h1 class="hero-title">Great movies,<br>your nearest branch.</h1>
                        <p class="hero-subtitle">
                            Browse showtimes across every branch, pick your seat and pay online &mdash; all in one place.
                        </p>
                        <div class="d-flex flex-wrap gap-3 mt-4">
                            <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING"
                               class="btn btn-primary-lc btn-lg px-4 fw-semibold" style="border-radius: 10px;">
                                Book ticket
                            </a>
                            <a href="${pageContext.request.contextPath}/movies?status=UPCOMING"
                               class="btn btn-hero-outline btn-lg px-4 fw-semibold">
                                Coming soon
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <!-- Now Showing -->
        <div class="container mt-5">
            <div class="d-flex justify-content-between align-items-end mb-4">
                <div>
                    <h2 class="fw-bold mb-1" style="color: var(--text-dark);">Now Showing</h2>
                    <p class="text-secondary mb-0" style="font-size: 0.9rem;">Movies currently screening across our branches</p>
                </div>
                <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING"
                   class="text-decoration-none fw-semibold" style="color: var(--primary); font-size: 0.9rem;">
                    View all &rarr;
                </a>
            </div>

            <c:choose>
                <c:when test="${not empty movieList}">
                    <div class="row row-cols-2 row-cols-md-4 g-3">
                        <c:forEach var="m" items="${movieList}">
                            <div class="col">
                                <div class="card h-100 movie-card">
                                    <c:choose>
                                        <c:when test="${not empty m.posterUrl}">
                                            <img src="${m.posterUrl}" class="movie-poster" alt="<c:out value='${m.title}'/> poster">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="movie-poster movie-poster-placeholder">
                                                <c:out value="${fn:toUpperCase(fn:substring(m.title, 0, 1))}" default="?" />
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <div class="card-body pb-2">
                                        <h6 class="card-title fw-bold mb-1 text-truncate" title="<c:out value='${m.title}'/>">
                                            <c:out value="${m.title}" />
                                        </h6>
                                        <small class="text-secondary">
                                            <span class="rated-badge"><c:out value="${m.rated}" /></span>
                                            ${m.durationMin} mins
                                        </small>
                                    </div>
                                    <div class="card-footer border-0 bg-transparent pt-0">
                                        <a href="${pageContext.request.contextPath}/movies/detail?id=${m.movieId}"
                                           class="btn btn-sm w-100 btn-primary-lc">Book ticket</a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <%-- Empty state: movieList chua duoc nap (HomeServlet TODO - owner AnhND) --%>
                    <div class="empty-state">
                        <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"
                             stroke-linecap="round" stroke-linejoin="round">
                            <rect x="2" y="2" width="20" height="20" rx="2.18" ry="2.18"></rect>
                            <line x1="7" y1="2" x2="7" y2="22"></line>
                            <line x1="17" y1="2" x2="17" y2="22"></line>
                            <line x1="2" y1="12" x2="22" y2="12"></line>
                            <line x1="2" y1="7" x2="7" y2="7"></line>
                            <line x1="2" y1="17" x2="7" y2="17"></line>
                            <line x1="17" y1="17" x2="22" y2="17"></line>
                            <line x1="17" y1="7" x2="22" y2="7"></line>
                        </svg>
                        <h5 class="fw-bold mt-3 mb-1">No movies to show yet</h5>
                        <p class="text-secondary mb-0" style="font-size: 0.9rem;">
                            Check back soon &mdash; new showtimes are added every week.
                        </p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>

        <jsp:include page="common/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    </body>

</html>
