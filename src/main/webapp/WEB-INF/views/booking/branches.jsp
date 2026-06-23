<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Choose Cinema – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .branch-card { cursor: pointer; }
        .branch-icon {
            width: 44px; height: 44px; border-radius: 10px;
            background: rgba(37, 99, 235, .1); color: var(--primary);
            display: flex; align-items: center; justify-content: center; flex-shrink: 0;
        }
        .step-pill {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: .8rem; font-weight: 600; color: var(--primary);
            background: rgba(37, 99, 235, .08); padding: 4px 12px; border-radius: 999px;
        }
    </style>
</head>
<body>
<jsp:include page="../common/header.jsp" />

<div class="container my-4" style="max-width: 980px;">

    <span class="step-pill mb-2">Step 1/3 &middot; Choose cinema</span>
    <h3 class="fw-bold mt-2 mb-1">Where would you like to watch?</h3>
    <p class="text-secondary mb-4">Pick a cinema to see movies currently showing there.</p>

    <c:choose>
        <c:when test="${empty branches}">
            <div class="alert alert-error" role="alert">
                No active cinemas are available right now. Please check back later.
            </div>
        </c:when>
        <c:otherwise>
            <div class="row row-cols-1 row-cols-md-2 g-3">
                <c:forEach var="b" items="${branches}">
                    <div class="col">
                        <c:set var="targetHref" value="${pageContext.request.contextPath}/booking/movies?branchId=${b.branchId}" />
                        <c:if test="${not empty param.movieId}">
                            <c:set var="targetHref" value="${pageContext.request.contextPath}/booking/showtimes?branchId=${b.branchId}&movieId=${param.movieId}" />
                        </c:if>
                        <a class="text-decoration-none" href="${targetHref}">
                            <div class="card h-100 movie-card branch-card p-3">
                                <div class="d-flex align-items-start gap-3">
                                    <div class="branch-icon">
                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                             stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                                            <circle cx="12" cy="10" r="3"></circle>
                                        </svg>
                                    </div>
                                    <div class="flex-grow-1">
                                        <h5 class="fw-bold mb-1">${b.name}</h5>
                                        <div class="text-secondary small mb-1">${b.address}<c:if test="${not empty b.city}">, ${b.city}</c:if></div>
                                        <c:if test="${not empty b.phone}">
                                            <div class="text-secondary small">&#9742; ${b.phone}</div>
                                        </c:if>
                                    </div>
                                    <div class="align-self-center text-secondary">&rarr;</div>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<jsp:include page="../common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
