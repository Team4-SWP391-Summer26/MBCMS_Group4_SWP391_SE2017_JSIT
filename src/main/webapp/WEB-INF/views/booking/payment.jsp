<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
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
    <link href="${pageContext.request.contextPath}/assets/css/booking.css?v=${applicationScope.assetVersion}" rel="stylesheet">
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
                com.mbcms.util.DateTimeUtil.vietnamLocalToDate(_bk.getShowtimeStartTime()));
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
                <div class="fw-bold bk-context-title">
                    ${not empty booking.movieTitle ? booking.movieTitle : 'Booking '.concat(booking.bookingCode)}
                </div>
                <div class="text-muted small">
                    <c:choose>
                        <c:when test="${not empty stStart}">
                            <i class="bi bi-calendar-event"></i>
                            <fmt:formatDate value="${stStart}" pattern="EEE, dd MMM · HH:mm"/>
                            <span class="mx-1">·</span><span class="bk-mono">${booking.bookingCode}</span>
                        </c:when>
                        <c:otherwise>Showtime #${booking.showtimeId}</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <div class="text-end">
                <div class="text-muted small">Seats</div>
                <div class="fw-bold bk-mono bk-context-title">
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

    <h3 class="fw-bold mb-1 bk-title">
        <i class="bi bi-shield-lock-fill text-success"></i> Complete Your Payment</h3>
    <p class="text-muted mb-4">Your booking is reserved while you complete the payment.</p>

    <%-- ===== Error from gateway callback ===== --%>
    <c:if test="${not empty payError}">
        <div class="lc-alert is-error mb-3" role="alert">
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
                <h6 class="fw-bold mb-3 bk-panel-title">Payment Method</h6>

                <div class="pm active is-static mb-3">
                    <span class="pm-logo pm-vnpay">VNPAY</span>
                    <span>
                        <span class="pm-title">VNPay</span>
                        <div class="pm-desc">Redirect to VNPay Sandbox — QR code / internet banking</div>
                    </span>
                    <i class="bi bi-shield-check ms-auto text-success"></i>
                </div>

                <div class="bk-info mb-3">
                    <i class="bi bi-info-circle-fill"></i>
                    <span>Transaction Reference: <strong class="bk-mono">${booking.bookingCode}</strong>
                        — keep this code for your records.</span>
                </div>
            </div>

            <%-- ===== Right: order summary ===== --%>
            <div class="col-lg-5">
                <div class="bk-card p-4 bk-summary">
                    <h6 class="fw-bold mb-3 bk-panel-title">Order Summary</h6>
                    <div class="d-flex gap-3 mb-3 pb-3 bk-summary-divider">
                        <c:choose>
                            <c:when test="${not empty booking.posterUrl}">
                                <img class="bk-poster" src="<c:url value='${booking.posterUrl}'/>" alt="${booking.movieTitle}">
                            </c:when>
                            <c:otherwise><div class="bk-poster"><i class="bi bi-film"></i></div></c:otherwise>
                        </c:choose>
                        <div>
                            <div class="fw-bold bk-context-title">
                                ${not empty booking.movieTitle ? booking.movieTitle : 'Booking '.concat(booking.bookingCode)}
                            </div>
                            <div class="text-muted small">
                                <c:choose>
                                    <c:when test="${not empty stStart}"><fmt:formatDate value="${stStart}" pattern="EEE, dd MMM · HH:mm"/></c:when>
                                    <c:otherwise>Showtime #${booking.showtimeId}</c:otherwise>
                                </c:choose>
                            </div>
                            <div class="small mt-1">Seats:
                                <strong class="bk-mono">
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
                    <div class="sum-line bk-sum-total">
                        <span class="fw-bold bk-total-label">Total</span>
                        <span class="fw-bold fs-5 bk-total-price">
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
                lcAlert('Your seat reservation has expired. Please book again.');
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
