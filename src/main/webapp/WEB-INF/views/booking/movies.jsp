<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chọn phim – ${branch.name} – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .step-pill {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: .8rem; font-weight: 600; color: var(--primary);
            background: rgba(37, 99, 235, .08); padding: 4px 12px; border-radius: 999px;
        }
        .poster-wrap {
            aspect-ratio: 2 / 3; overflow: hidden; border-radius: 8px 8px 0 0;
            background: #e5e7eb; display: flex; align-items: center; justify-content: center;
        }
        .poster-wrap img { width: 100%; height: 100%; object-fit: cover; display: block; }
        .rated-badge { position: absolute; top: 8px; right: 8px; }
    </style>
</head>
<body>
<jsp:include page="../common/header.jsp" />

<div class="container my-4" style="max-width: 980px;">

    <a href="${pageContext.request.contextPath}/booking/branches" class="btn btn-sm btn-outline-secondary mb-3">&#8592; Đổi chi nhánh</a>

    <span class="step-pill mb-2">Bước 2/3 &middot; Chọn phim</span>
    <h3 class="fw-bold mt-2 mb-1">${branch.name}</h3>
    <p class="text-secondary mb-4">${branch.address}<c:if test="${not empty branch.city}">, ${branch.city}</c:if></p>

    <c:choose>
        <c:when test="${empty movies}">
            <div class="alert alert-error" role="alert">
                Chi nhánh này hiện chưa có suất chiếu nào sắp tới. Vui lòng chọn chi nhánh khác.
            </div>
        </c:when>
        <c:otherwise>
            <div class="row row-cols-2 row-cols-md-4 g-3">
                <c:forEach var="m" items="${movies}">
                    <div class="col">
                        <a class="text-decoration-none"
                           href="${pageContext.request.contextPath}/booking/showtimes?branchId=${branch.branchId}&movieId=${m.movieId}">
                            <div class="card h-100 movie-card">
                                <div class="poster-wrap position-relative">
                                    <c:choose>
                                        <c:when test="${not empty m.posterUrl}">
                                            <img src="${m.posterUrl}" alt="${m.title}">
                                        </c:when>
                                        <c:otherwise>
                                            <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="#9ca3af"
                                                 stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                                                <rect x="2" y="3" width="20" height="14" rx="2"></rect>
                                                <line x1="8" y1="21" x2="16" y2="21"></line>
                                                <line x1="12" y1="17" x2="12" y2="21"></line>
                                            </svg>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${not empty m.rated}">
                                        <span class="badge bg-dark rated-badge">${m.rated}</span>
                                    </c:if>
                                </div>
                                <div class="card-body py-2 px-2">
                                    <h6 class="card-title fw-bold mb-1" style="font-size:.92rem;">${m.title}</h6>
                                    <small class="text-secondary">${m.durationMin} phút</small>
                                </div>
                                <div class="card-footer border-0 px-2 pb-2" style="background:transparent;">
                                    <span class="btn btn-sm w-100 btn-primary-lc">Chọn suất chiếu</span>
                                </div>
                            </div>
                        </a>
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>

</div><!-- /container -->

<jsp:include page="../common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
