<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<fmt:setLocale value="en_US"/>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
<%--
    My Bookings (owner: HungNT). Dung view-model `tickets` (List<BookingTicket>)
    + so lieu (upcoming / pastVisits / spentThisYear / dem theo status).
    Filter tab + search: client-side (data-status / data-search). Design dong nhat --bk-*.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>My Bookings – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* --bk-* tokens come from tokens.css */
        body.bk-page { background: var(--bk-bg); }
        .mb-wrap { max-width: 1000px; }

        .mb-stat { background:#fff; border:1px solid var(--bk-border); border-radius:14px; padding:16px 18px;
            display:flex; align-items:center; gap:14px; box-shadow:0 2px 10px rgba(15,23,42,.04); }
        .mb-stat .ic { width:42px; height:42px; border-radius:11px; display:flex; align-items:center;
            justify-content:center; font-size:1.2rem; flex-shrink:0; }
        .mb-stat .v { font-weight:800; font-size:1.25rem; color:var(--bk-navy); line-height:1.1; }
        .mb-stat .l { font-size:.8rem; color:var(--bk-muted); }

        .mb-filter { display:flex; gap:6px; flex-wrap:wrap; }
        .mb-tab { padding:5px 14px; border-radius:999px; font-size:.8rem; font-weight:600;
            border:1.5px solid var(--bk-border); background:#fff; color:var(--bk-muted); cursor:pointer; transition:all .15s; }
        .mb-tab:hover { border-color:var(--bk-primary); color:var(--bk-primary); }
        .mb-tab.active { background:var(--bk-primary); border-color:var(--bk-primary); color:#fff; }

        .mb-search { position:relative; }
        .mb-search input { padding-left:34px; border-radius:999px; border:1.5px solid var(--bk-border); font-size:.85rem; min-width:230px; }
        .mb-search i { position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--text-subtle); }

        .mb-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px; padding:16px 18px;
            margin-bottom:14px; box-shadow:0 2px 10px rgba(15,23,42,.04); transition:box-shadow .15s, transform .15s;
            display:flex; gap:16px; align-items:stretch; }
        .mb-card:hover { box-shadow:0 8px 22px rgba(37,99,235,.10); transform:translateY(-1px); }
        .mb-poster { width:74px; height:100px; border-radius:10px; object-fit:cover; flex-shrink:0;
            background:linear-gradient(135deg,#1e293b,var(--navy)); color:var(--gold); display:flex; align-items:center;
            justify-content:center; font-size:1.4rem; }
        .mb-title { font-weight:800; color:var(--bk-navy); font-size:1.05rem; line-height:1.2; }
        .mb-sub { font-size:.82rem; color:var(--bk-muted); }
        .mb-badge { display:inline-block; font-size:.68rem; font-weight:800; padding:1px 7px; border-radius:5px;
            background:var(--gold); color:var(--text); margin-right:4px; }
        .mb-col-label { font-size:.7rem; color:var(--text-subtle); text-transform:uppercase; letter-spacing:.04em; }
        .mb-col-val { font-weight:700; color:var(--bk-navy); font-size:.9rem; }
        .mb-seat { display:inline-block; background:var(--primary-50); color:var(--bk-primary); border:1px solid var(--primary-200);
            border-radius:6px; padding:1px 7px; font-weight:700; font-size:.78rem; margin:1px 3px 1px 0;
            font-family:ui-monospace,Menlo,Consolas,monospace; }
        .mb-code { font-family:ui-monospace,Menlo,Consolas,monospace; font-size:.74rem; color:var(--text-subtle); }

        .sp { padding:3px 11px; border-radius:999px; font-size:.72rem; font-weight:800; white-space:nowrap;
            display:inline-flex; align-items:center; gap:4px; }
        .sp-CONFIRMED { background:#dcfce7; color:#15803d; }
        .sp-PENDING   { background:#fef3c7; color:#b45309; }
        .sp-CANCELLED { background:#fee2e2; color:#b91c1c; }
        .sp-USED      { background:#ede9fe; color:#6d28d9; }
        .sp-NO_SHOW   { background:#f1f5f9; color:#475569; }

        .mb-empty { text-align:center; padding:3.5rem 1.5rem; color:var(--bk-muted); }
        .mb-divider { width:1px; background:var(--bk-border); align-self:stretch; }
        @media (max-width: 720px) { .mb-card { flex-wrap:wrap; } .mb-divider { display:none; } }
    </style>
</head>
<body class="bk-page">

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container mb-wrap py-4">

    <%-- ===== Heading ===== --%>
    <div class="d-flex align-items-center flex-wrap gap-2 mb-4">
        <div>
            <h3 class="fw-bold mb-0" style="color:var(--bk-navy);">My Bookings</h3>
            <div class="mb-sub">${countAll} booking(s) · ${upcoming} upcoming</div>
        </div>
        <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING"
           class="ms-auto btn btn-primary fw-semibold"><i class="bi bi-plus-lg"></i> Book a Ticket</a>
    </div>

    <c:if test="${param.cancelled == '1'}">
        <div class="alert alert-success border-0 mb-3" style="border-radius: 10px;">
            <i class="bi bi-check-circle-fill"></i>
            Booking cancelled. Your seats have been released.
        </div>
    </c:if>
    <c:if test="${param.expired == '1'}">
        <div class="alert alert-warning border-0 mb-3" style="border-radius: 10px;">
            <i class="bi bi-clock-history"></i>
            Your seat reservation expired. Please make a new booking.
        </div>
    </c:if>
    <c:if test="${param.cancelErr == 'NOT_CANCELLABLE'}">
        <div class="alert alert-warning border-0 mb-3" style="border-radius: 10px;">
            <i class="bi bi-exclamation-triangle-fill"></i>
            This booking could not be cancelled because it is no longer pending.
        </div>
    </c:if>
    <c:if test="${param.cancelErr == 'SYSTEM'}">
        <div class="alert alert-danger border-0 mb-3" style="border-radius: 10px;">
            <i class="bi bi-exclamation-triangle-fill"></i>
            Could not cancel the booking due to a system error. Please try again.
        </div>
    </c:if>

    <%-- ===== Stats ===== --%>
    <div class="row g-3 mb-4">
        <div class="col-sm-4">
            <div class="mb-stat">
                <div class="ic" style="background:#dcfce7; color:var(--success);"><i class="bi bi-calendar-check"></i></div>
                <div><div class="v">${upcoming}</div><div class="l">Upcoming</div></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="mb-stat">
                <div class="ic" style="background:#ede9fe; color:#6d28d9;"><i class="bi bi-clock-history"></i></div>
                <div><div class="v">${pastVisits}</div><div class="l">Past visits</div></div>
            </div>
        </div>
        <div class="col-sm-4">
            <div class="mb-stat">
                <div class="ic" style="background:var(--primary-100); color:var(--primary);"><i class="bi bi-cash-coin"></i></div>
                <div><div class="v"><fmt:formatNumber value="${spentThisYear}" pattern="#,###"/>₫</div>
                    <div class="l">Spent this year</div></div>
            </div>
        </div>
    </div>

    <%-- ===== Filter + search ===== --%>
    <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-4">
        <div class="mb-filter" id="filterTabs">
            <button class="mb-tab active" data-filter="ALL">All</button>
            <button class="mb-tab" data-filter="PENDING">Pending (${countPending})</button>
            <button class="mb-tab" data-filter="CONFIRMED">Confirmed (${countConfirmed})</button>
            <button class="mb-tab" data-filter="USED">Used (${countUsed})</button>
            <button class="mb-tab" data-filter="NO_SHOW">No-show (${countNoShow})</button>
            <button class="mb-tab" data-filter="CANCELLED">Cancelled (${countCancelled})</button>
        </div>
        <div class="mb-search">
            <i class="bi bi-search"></i>
            <input type="text" id="searchBox" class="form-control" placeholder="Search by movie or code">
        </div>
    </div>

    <%-- ===== List ===== --%>
    <c:choose>
        <c:when test="${empty tickets}">
            <div class="mb-empty">
                <div style="font-size:3rem;"><i class="bi bi-ticket-perforated"></i></div>
                <h5 class="fw-bold mt-2" style="color:var(--bk-navy);">No bookings yet</h5>
                <p>You haven't made any reservations.<br>Find a movie you love and grab your seats!</p>
                <a href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING" class="btn btn-primary px-4 fw-semibold">Browse Movies</a>
            </div>
        </c:when>
        <c:otherwise>
            <div id="cardList">
            <c:forEach var="t" items="${tickets}">
                <%
                    com.mbcms.model.BookingTicket _t =
                        (com.mbcms.model.BookingTicket) pageContext.getAttribute("t");
                    if (_t != null && _t.getStartTime() != null) {
                        pageContext.setAttribute("tStart",
                            com.mbcms.util.DateTimeUtil.vietnamLocalToDate(_t.getStartTime()));
                    } else {
                        pageContext.setAttribute("tStart", null);
                    }
                %>
                <div class="mb-card" data-status="${t.status}"
                     data-search="${fn:escapeXml(t.movieTitle)} ${fn:escapeXml(t.bookingCode)}">
                    <c:choose>
                        <c:when test="${not empty t.posterUrl}">
                            <img class="mb-poster" src="<c:url value='${t.posterUrl}'/>" alt="">
                        </c:when>
                        <c:otherwise><div class="mb-poster"><i class="bi bi-film"></i></div></c:otherwise>
                    </c:choose>

                    <div class="flex-grow-1 min-width-0">
                        <div class="d-flex align-items-start gap-2 flex-wrap">
                            <div class="flex-grow-1">
                                <div class="mb-title">
                                    <c:choose>
                                        <c:when test="${not empty t.movieTitle}"><c:out value="${t.movieTitle}"/></c:when>
                                        <c:otherwise>Movie ticket</c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="mb-sub">
                                    <c:if test="${not empty t.branchName}"><c:out value="${t.branchName}"/></c:if>
                                    <c:if test="${not empty t.roomName}"> · <c:out value="${t.roomName}"/></c:if>
                                </div>
                                <div class="mt-1">
                                    <c:if test="${not empty t.movieRated}"><span class="mb-badge"><c:out value="${t.movieRated}"/></span></c:if>
                                    <c:if test="${t.durationMin > 0}"><span class="mb-sub">${t.durationMin} min</span></c:if>
                                </div>
                            </div>
                            <span class="sp sp-${t.status}">
                                <c:choose>
                                    <c:when test="${t.status eq 'CONFIRMED'}"><i class="bi bi-check-circle-fill"></i> CONFIRMED</c:when>
                                    <c:when test="${t.status eq 'USED'}"><i class="bi bi-check2-all"></i> USED</c:when>
                                    <c:when test="${t.status eq 'NO_SHOW'}"><i class="bi bi-person-x"></i> NO SHOW</c:when>
                                    <c:when test="${t.status eq 'CANCELLED'}"><i class="bi bi-x-circle"></i> CANCELLED</c:when>
                                    <c:otherwise><i class="bi bi-hourglass-split"></i> PENDING</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <div class="d-flex gap-3 flex-wrap mt-3 align-items-end">
                            <div>
                                <div class="mb-col-label">Date &amp; Time</div>
                                <div class="mb-col-val">
                                    <c:choose>
                                        <c:when test="${not empty tStart}"><fmt:formatDate value="${tStart}" pattern="EEE, dd MMM yyyy"/> · <fmt:formatDate value="${tStart}" pattern="h:mm a"/></c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="mb-divider"></div>
                            <div>
                                <div class="mb-col-label">Seats</div>
                                <div class="mb-col-val">
                                    <c:choose>
                                        <c:when test="${not empty t.seatLabels}">
                                            <c:forEach var="lbl" items="${t.seatLabels}"><span class="mb-seat"><c:out value="${lbl}"/></span></c:forEach>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                            <div class="mb-divider"></div>
                            <div>
                                <div class="mb-col-label">Total Paid</div>
                                <div class="mb-col-val" style="color:var(--bk-primary); font-size:1rem;">
                                    <fmt:formatNumber value="${t.totalAmount}" pattern="#,###"/>₫</div>
                                <div class="mb-code">${t.bookingCode}</div>
                            </div>

                            <div class="ms-auto d-flex gap-2">
                                <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${t.bookingId}"
                                   class="btn btn-sm btn-primary"><i class="bi bi-ticket-detailed"></i> View Ticket</a>
                                <c:if test="${t.status eq 'PENDING'}">
                                    <a href="${pageContext.request.contextPath}/booking/payment?bookingId=${t.bookingId}"
                                       class="btn btn-sm btn-outline-primary">Pay now</a>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:forEach>
            </div>
            <div id="noMatch" class="mb-empty d-none">
                <div style="font-size:2.4rem;"><i class="bi bi-search"></i></div>
                <p class="mb-0 mt-2">No bookings match your filter.</p>
            </div>
        </c:otherwise>
    </c:choose>

</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        var tabs   = document.querySelectorAll('#filterTabs .mb-tab');
        var cards  = Array.prototype.slice.call(document.querySelectorAll('#cardList .mb-card'));
        var search = document.getElementById('searchBox');
        var noMatch = document.getElementById('noMatch');
        var current = 'ALL';
        if (!cards.length) return;

        function apply() {
            var q = (search.value || '').trim().toLowerCase();
            var visible = 0;
            cards.forEach(function (c) {
                var okStatus = current === 'ALL' || c.getAttribute('data-status') === current;
                var okSearch = !q || (c.getAttribute('data-search') || '').toLowerCase().indexOf(q) !== -1;
                var show = okStatus && okSearch;
                c.style.display = show ? '' : 'none';
                if (show) visible++;
            });
            if (noMatch) noMatch.classList.toggle('d-none', visible !== 0);
        }
        tabs.forEach(function (t) {
            t.addEventListener('click', function () {
                tabs.forEach(function (x) { x.classList.remove('active'); });
                t.classList.add('active');
                current = t.getAttribute('data-filter');
                apply();
            });
        });
        search.addEventListener('input', apply);
    })();
</script>
</body>
</html>
