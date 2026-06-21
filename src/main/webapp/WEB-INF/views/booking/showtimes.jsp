<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Choose Showtime – ${movie.title} – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        .step-pill {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: .8rem; font-weight: 600; color: var(--primary);
            background: rgba(37, 99, 235, .08); padding: 4px 12px; border-radius: 999px;
        }
        .day-tab {
            border: 1px solid #e5e7eb; background: #fff; border-radius: 999px;
            padding: 6px 16px; font-size: .85rem; font-weight: 600; color: var(--text-dark);
            cursor: pointer; white-space: nowrap;
        }
        .day-tab.active { background: var(--primary); border-color: var(--primary); color: #fff; }
        .day-panel { display: none; }
        .day-panel.active { display: block; }
        .slot-btn {
            border: 1.5px solid var(--primary); color: var(--primary); background: #fff;
            border-radius: 8px; padding: 8px 14px; font-weight: 600; text-decoration: none;
            display: inline-flex; flex-direction: column; align-items: center; min-width: 84px;
        }
        .slot-btn:hover { background: var(--primary); color: #fff; }
        .slot-btn .slot-time { font-size: .95rem; }
        .slot-btn .slot-sub { font-size: .68rem; font-weight: 400; opacity: .85; }
        .slot-btn.slot-full { border-color: #d1d5db; color: #9ca3af; pointer-events: none; }
    </style>
</head>
<body>
<jsp:include page="../common/header.jsp" />

<div class="container my-4" style="max-width: 980px;">

    <a href="${pageContext.request.contextPath}/booking/movies?branchId=${branch.branchId}"
       class="btn btn-sm btn-outline-secondary mb-3">&#8592; Change movie</a>

    <span class="step-pill mb-2">Step 3/3 &middot; Choose showtime</span>

    <div class="d-flex flex-wrap align-items-start gap-3 mt-2 mb-4">
        <c:if test="${not empty movie.posterUrl}">
            <img src="${movie.posterUrl}" alt="${movie.title}"
                 style="width:84px; height:126px; object-fit:cover; border-radius:8px;">
        </c:if>
        <div>
            <h3 class="fw-bold mb-1">${movie.title}</h3>
            <div class="text-secondary mb-1">
                <c:if test="${not empty movie.rated}"><span class="badge bg-dark me-1">${movie.rated}</span></c:if>
                ${movie.durationMin} min
            </div>
            <div class="text-secondary small">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                     stroke-linecap="round" stroke-linejoin="round" style="vertical-align:-2px;">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path>
                    <circle cx="12" cy="10" r="3"></circle>
                </svg>
                ${branch.name}
            </div>
        </div>
    </div>

    <c:choose>
        <c:when test="${empty dayGroups}">
            <div class="alert alert-error" role="alert">
                No upcoming showtimes for this movie at ${branch.name}. Please choose another movie.
            </div>
        </c:when>
        <c:otherwise>
            <div class="d-flex gap-2 mb-3 flex-wrap" id="dayTabs">
                <c:forEach var="day" items="${dayGroups}" varStatus="loop">
                    <div class="day-tab ${loop.first ? 'active' : ''}" data-day-index="${loop.index}">
                        ${day.dateLabel}<c:if test="${day.today}"> &middot; Today</c:if>
                    </div>
                </c:forEach>
            </div>

            <c:forEach var="day" items="${dayGroups}" varStatus="loop">
                <div class="day-panel ${loop.first ? 'active' : ''}" data-day-panel="${loop.index}">
                    <div class="card border-0 shadow-sm p-3">
                        <div class="d-flex flex-wrap gap-2">
                            <c:forEach var="slot" items="${day.showtimes}">
                                <c:choose>
                                    <c:when test="${slot.availableSeats > 0}">
                                        <a class="slot-btn"
                                           href="${pageContext.request.contextPath}/booking/seats?showtimeId=${slot.showtimeId}">
                                            <span class="slot-time">${slot.timeLabel}</span>
                                            <span class="slot-sub">${slot.format} &middot; ${slot.subtitleType}</span>
                                            <span class="slot-sub">${slot.availableSeats} seats left</span>
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="slot-btn slot-full" title="Sold out">
                                            <span class="slot-time">${slot.timeLabel}</span>
                                            <span class="slot-sub">${slot.format} &middot; ${slot.subtitleType}</span>
                                            <span class="slot-sub">Sold out</span>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>

</div>

<jsp:include page="../common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.querySelectorAll('.day-tab').forEach(function (tab) {
        tab.addEventListener('click', function () {
            var idx = tab.getAttribute('data-day-index');
            document.querySelectorAll('.day-tab').forEach(function (t) { t.classList.remove('active'); });
            document.querySelectorAll('.day-panel').forEach(function (p) { p.classList.remove('active'); });
            tab.classList.add('active');
            document.querySelector('[data-day-panel="' + idx + '"]').classList.add('active');
        });
    });
</script>
</body>
</html>
