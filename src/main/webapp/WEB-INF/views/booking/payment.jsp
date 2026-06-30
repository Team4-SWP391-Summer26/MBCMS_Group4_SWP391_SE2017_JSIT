<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    Payment screen (owner: HungNT). Booking step 5/6.
    Thanh toan online: VNPay Sandbox -> POST /booking/payment/gateway.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* --bk-* tokens come from tokens.css */
        body { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }
        .bk-ctx { background:#fff; border-bottom:1px solid var(--bk-border); }
        .bk-poster { width:46px; height:60px; border-radius:8px; object-fit:cover;
            background:linear-gradient(135deg,#1e293b,var(--navy)); display:flex;
            align-items:center; justify-content:center; color:var(--gold); font-weight:800; }
        .bk-reserve { background:#FFF8E1; border:1px solid #FFE082; color:#7a5a00;
            border-radius:999px; padding:.3rem .8rem; font-size:.82rem; font-weight:600;
            display:inline-flex; align-items:center; gap:.4rem; }
        .bk-reserve.danger { background:#fee2e2; border-color:#fca5a5; color:#b91c1c; }

        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:var(--text-subtle); white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:var(--border); color:var(--text-muted); flex-shrink:0; }
        .bk-step.done  { color:var(--success); }
        .bk-step.done  .bk-dot { background:var(--success); color:#fff; }
        .bk-step.active { color:var(--bk-primary); }
        .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:var(--border); margin:0 .5rem; min-width:14px; }
        .bk-line.done { background:var(--success); }

        .bk-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px;
            box-shadow:0 4px 12px rgba(15,23,42,.05); }
        .bk-summary { position:sticky; top:18px; }

        .pm { border:1.6px solid var(--bk-border); border-radius:12px; padding:.9rem 1rem; cursor:pointer;
            display:flex; align-items:center; gap:.9rem; transition:border-color .12s, background .12s; background:#fff; }
        .pm:hover { border-color:#9bbcf7; }
        .pm.active { border-color:var(--bk-primary); background:var(--bk-light); }
        .pm input { width:18px; height:18px; flex-shrink:0; }
        .pm-logo { width:46px; height:30px; border-radius:6px; display:flex; align-items:center;
            justify-content:center; font-weight:800; font-size:.7rem; color:#fff; flex-shrink:0; }
        .pm-vnpay { background:#0d4a9c; }
        .pm-title { font-weight:700; color:var(--bk-navy); }
        .pm-desc { font-size:.8rem; color:var(--bk-muted); }

        .bk-info { background:var(--bk-light); border:1px solid #cfe0fb; color:#1e40af;
            border-radius:10px; padding:.6rem .85rem; font-size:.82rem; display:flex; gap:.5rem; align-items:flex-start; }
        .mono { font-family:ui-monospace,Menlo,Consolas,monospace; }
        .sum-line { display:flex; justify-content:space-between; align-items:center; padding:.35rem 0; font-size:.92rem; }
    </style>
</head>
<body class="bk-page">

<jsp:include page="../common/header.jsp" />

<%-- ===== Showtime context bar ===== --%>
<%-- Convert showtimeStartTime (LocalDateTime) -> Date de format bang JSTL --%>
<c:if test="${not empty booking.showtimeStartTime}">
    <%
        com.mbcms.model.Booking _bk = (com.mbcms.model.Booking) request.getAttribute("booking");
        if (_bk != null && _bk.getShowtimeStartTime() != null) {
            pageContext.setAttribute("stStart",
                java.util.Date.from(_bk.getShowtimeStartTime()
                    .atZone(java.time.ZoneId.systemDefault()).toInstant()));
        }
    %>
</c:if>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <c:choose>
                <c:when test="${not empty booking.posterUrl}">
                    <img class="bk-poster" src="<c:url value='${booking.posterUrl}'/>" alt="${booking.movieTitle}">
                </c:when>
                <c:otherwise><div class="bk-poster"><i class="bi bi-film"></i></div></c:otherwise>
            </c:choose>
            <div class="flex-grow-1">
                <div class="fw-bold" style="color:var(--bk-navy);">
                    ${not empty booking.movieTitle ? booking.movieTitle : 'Booking '.concat(booking.bookingCode)}
                </div>
                <div class="text-muted small">
                    <c:choose>
                        <c:when test="${not empty stStart}">
                            <i class="bi bi-calendar-event"></i>
                            <fmt:formatDate value="${stStart}" pattern="EEE, dd MMM · HH:mm"/>
                            <span class="mx-1">·</span><span class="mono">${booking.bookingCode}</span>
                        </c:when>
                        <c:otherwise>Showtime #${booking.showtimeId}</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="text-end">
                <div class="text-muted small">Seats</div>
                <div class="fw-bold mono" style="color:var(--bk-navy);">
                    <c:choose>
                        <c:when test="${not empty booking.seatLabels}">
                            <c:forEach var="lbl" items="${booking.seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <span class="bk-reserve" id="reserve-pill">
                <i class="bi bi-clock-history"></i> Reserved for <span id="countdown">--:--</span>
            </span>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <%-- ===== Stepper (4/5 Payment) ===== --%>
    <div class="bk-steps mb-4">
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Seats</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Food &amp; Drinks</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Review</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">5</span>Payment</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">6</span>Confirm</div>
    </div>

    <h3 class="fw-bold mb-1" style="color:var(--bk-navy);">
        <i class="bi bi-shield-lock-fill text-success"></i> Complete Your Payment</h3>
    <p class="text-muted mb-4">Your booking is reserved while you complete the payment.</p>

    <%-- ===== Error from gateway callback ===== --%>
    <c:if test="${not empty payError}">
        <div class="alert alert-danger d-flex align-items-center gap-2" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>
                <c:choose>
                    <c:when test="${payError eq 'signature'}">Payment verification failed (invalid signature). Your booking is still reserved — please try again.</c:when>
                    <c:when test="${payError eq 'failed'}">Payment was cancelled or failed. Your booking is still reserved — please try again.</c:when>
                    <c:when test="${payError eq 'expired'}">Your seat reservation has expired. Please book again.</c:when>
                    <c:when test="${payError eq 'method'}">Invalid payment request. Please try again.</c:when>
                    <c:when test="${payError eq 'vnpay_config'}">VNPay is not configured. Add payment.vnpay.tmnCode and payment.vnpay.hashSecret to database.properties (register at sandbox.vnpayment.vn).</c:when>
                    <c:otherwise>Payment could not be completed. Please try again.</c:otherwise>
                </c:choose>
            </span>
        </div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/booking/payment/gateway" id="pay-form">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
        <input type="hidden" name="bookingId" value="${booking.bookingId}">
        <input type="hidden" name="method" value="VNPAY">

        <div class="row g-4">
            <div class="col-lg-7">
                <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Payment Method</h6>

                <div class="pm active mb-3" style="cursor:default;">
                    <span class="pm-logo pm-vnpay">VNPAY</span>
                    <span>
                        <span class="pm-title">VNPay</span>
                        <div class="pm-desc">Redirect to VNPay Sandbox — QR code / internet banking</div>
                    </span>
                    <i class="bi bi-shield-check ms-auto text-success"></i>
                </div>

                <div class="bk-info mb-3">
                    <i class="bi bi-info-circle-fill"></i>
                    <span>Transaction Reference: <strong class="mono">${booking.bookingCode}</strong>
                        — keep this code for your records.</span>
                </div>
            </div>

            <%-- ===== Right: order summary ===== --%>
            <div class="col-lg-5">
                <div class="bk-card p-4 bk-summary">
                    <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Order Summary</h6>
                    <div class="d-flex gap-3 mb-3 pb-3" style="border-bottom:1px solid var(--bk-border);">
                        <c:choose>
                            <c:when test="${not empty booking.posterUrl}">
                                <img class="bk-poster" src="<c:url value='${booking.posterUrl}'/>" alt="${booking.movieTitle}">
                            </c:when>
                            <c:otherwise><div class="bk-poster"><i class="bi bi-film"></i></div></c:otherwise>
                        </c:choose>
                        <div>
                            <div class="fw-bold" style="color:var(--bk-navy);">
                                ${not empty booking.movieTitle ? booking.movieTitle : 'Booking '.concat(booking.bookingCode)}
                            </div>
                            <div class="text-muted small">
                                <c:choose>
                                    <c:when test="${not empty stStart}"><fmt:formatDate value="${stStart}" pattern="EEE, dd MMM · HH:mm"/></c:when>
                                    <c:otherwise>Showtime #${booking.showtimeId}</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="small mt-1">Seats:
                                <strong class="mono">
                                    <c:choose>
                                        <c:when test="${not empty booking.seatLabels}">
                                            <c:forEach var="lbl" items="${booking.seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                                        </c:when>
                                        <c:otherwise>—</c:otherwise>
                                    </c:choose>
                                </strong>
                            </div>
                        </div>
                    </div>

                    <div class="sum-line"><span class="text-muted">Subtotal</span>
                        <span><fmt:formatNumber value="${booking.subtotal}" pattern="#,###"/>₫</span></div>
                    <c:if test="${booking.discountAmount > 0}">
                        <div class="sum-line"><span class="text-muted">Discount</span>
                            <span class="text-success">−<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/>₫</span></div>
                    </c:if>
                    <div class="sum-line pt-2" style="border-top:1px solid var(--bk-border);">
                        <span class="fw-bold" style="color:var(--bk-navy);">Total</span>
                        <span class="fw-bold fs-5" style="color:var(--bk-primary);">
                            <fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/>₫</span>
                    </div>

                    <button class="btn btn-primary w-100 mt-3 py-2 fw-semibold" type="submit">
                        <i class="bi bi-lock-fill"></i> Pay with VNPay
                    </button>
                    <div class="text-center text-muted small mt-2">
                        <i class="bi bi-shield-lock"></i> Secure VNPay Sandbox
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<jsp:include page="../common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Countdown dua tren so giay con lai do server tinh tu created_at (UTC).
    (function () {
        var remaining = parseInt('${remainingSeconds}', 10);
        if (isNaN(remaining)) remaining = 600;
        var cd = document.getElementById('countdown');
        var pill = document.getElementById('reserve-pill');
        function tick() {
            if (remaining <= 0) {
                cd.textContent = 'Expired';
                pill.classList.add('danger');
                clearInterval(timer);
                alert('Your seat reservation has expired. Please book again.');
                window.location.href = '${pageContext.request.contextPath}/customer/booking/history?expired=1';
                return;
            }
            var m = Math.floor(remaining / 60);
            var s = remaining % 60;
            cd.textContent = m + ':' + String(s).padStart(2, '0');
            if (remaining <= 60) pill.classList.add('danger');
            remaining--;
        }
        tick();
        var timer = setInterval(tick, 1000);
    })();
</script>
</body>
</html>
