<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="en_US"/>
<fmt:setTimeZone value="Asia/Ho_Chi_Minh"/>
<%--
    Review / Checkout (booking step 4/6) — REDESIGN v2.
    Owner: HungNT.

    Layout: Bootstrap row/col (same as seats + fnb).
    Left col-lg-8:  one card, internally divided (details / concessions / promo / notes).
    Right col-lg-4: sticky summary panel (fnb-summary pattern).

    GIU NGUYEN: form names, actions, hidden inputs, promo logic, cancel modal, countdown JS.
    THEM MOI: optional notes field (name="notes", textarea, form="checkoutForm").
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Review your order – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/booking.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="bk-page">
<jsp:include page="../common/header.jsp" />

<%-- ===== Convert showtimeStartTime → Date for JSTL fmt ===== --%>
<c:if test="${not empty booking.showtimeStartTime}">
    <%
        com.mbcms.model.Booking _bk = (com.mbcms.model.Booking) request.getAttribute("booking");
        if (_bk != null && _bk.getShowtimeStartTime() != null) {
            pageContext.setAttribute("stStart",
                com.mbcms.util.DateTimeUtil.vietnamLocalToDate(_bk.getShowtimeStartTime()));
        }
    %>
</c:if>
<c:set var="seatIdsParam" value=""/>
<c:forEach var="sid" items="${seatIds}" varStatus="ss">
    <c:set var="seatIdsParam" value="${seatIdsParam}${sid}${!ss.last ? ',' : ''}"/>
</c:forEach>

<%-- ===== Context bar ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <a href="${pageContext.request.contextPath}/booking/food-drinks?showtimeId=${showtimeId}&amp;seatIds=${seatIdsParam}"
               class="btn btn-sm btn-outline-secondary" title="Back to Food &amp; Drinks">
                <i class="bi bi-arrow-left"></i>
            </a>
            <c:choose>
                <c:when test="${not empty booking.posterUrl}">
                    <img class="bk-poster" src="<c:url value='${booking.posterUrl}'/>" alt="${booking.movieTitle}">
                </c:when>
                <c:otherwise><div class="bk-poster"><i class="bi bi-film"></i></div></c:otherwise>
            </c:choose>
            <div class="flex-grow-1">
                <div class="fw-bold bk-context-title">
                    <c:choose>
                        <c:when test="${not empty booking.movieTitle}">${booking.movieTitle}</c:when>
                        <c:when test="${not empty booking}">Booking ${booking.bookingCode}</c:when>
                        <c:otherwise>Review your order</c:otherwise>
                    </c:choose>
                </div>
                <div class="text-muted small">
                    <c:choose>
                        <c:when test="${not empty stStart}">
                            <i class="bi bi-calendar-event"></i>
                            <fmt:formatDate value="${stStart}" pattern="EEE, dd MMM · h:mm a"/>
                            <c:if test="${not empty booking.bookingCode}">
                                <span class="mx-1">·</span><span class="bk-mono">${booking.bookingCode}</span>
                            </c:if>
                        </c:when>
                        <c:otherwise>Showtime #${showtimeId}</c:otherwise>
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
                        <c:when test="${not empty seatLabels}">
                            <c:forEach var="lbl" items="${seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
            </div>
            <c:if test="${not empty booking}">
                <span class="bk-reserve" id="reserve-pill">
                    <i class="bi bi-clock-history"></i> Reserved for <span id="countdown">--:--</span>
                </span>
            </c:if>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <%-- ===== Stepper (4/6 Review) ===== --%>
    <div class="bk-steps mb-4">
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Seats</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Food & Drinks</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">4</span>Review</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">5</span>Payment</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">6</span>Confirm</div>
    </div>

    <%-- ===== Global errors ===== --%>
    <c:if test="${not empty checkoutError}">
        <div class="lc-alert is-error rv-alert" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>${checkoutError}</span>
        </div>
    </c:if>
    <c:if test="${not empty pricingError}">
        <div class="lc-alert is-error rv-alert" role="alert">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span>${pricingError}</span>
        </div>
    </c:if>

    <div class="row g-4">

        <%-- ====== Left col: details card ====== --%>
        <div class="col-lg-7">
            <div class="rv-card">

                <%-- Section 1: Booking Details --%>
                <div class="rv-section">
                    <h2 class="rv-section-title"><i class="bi bi-ticket-perforated"></i> Booking Details</h2>

                    <dl class="rv-dl">
                        <c:if test="${not empty booking.movieTitle}">
                            <div class="rv-dl-row">
                                <dt><i class="bi bi-film"></i> Movie</dt>
                                <dd>${booking.movieTitle}</dd>
                            </div>
                        </c:if>
                        <div class="rv-dl-row">
                            <dt><i class="bi bi-clock"></i> Showtime</dt>
                            <dd>
                                <c:choose>
                                    <c:when test="${not empty stStart}">
                                        <fmt:formatDate value="${stStart}" pattern="EEE, dd MMM yyyy · h:mm a"/>
                                    </c:when>
                                    <c:otherwise>#${showtimeId}</c:otherwise>
                                </c:choose>
                            </dd>
                        </div>
                        <c:if test="${not empty booking}">
                            <div class="rv-dl-row">
                                <dt><i class="bi bi-upc-scan"></i> Booking code</dt>
                                <dd><span class="bk-mono">${booking.bookingCode}</span></dd>
                            </div>
                            <div class="rv-dl-row">
                                <dt><i class="bi bi-broadcast"></i> Status</dt>
                                <dd>
                                    <span class="bk-review-status">
                                        <span class="bk-review-status-dot" aria-hidden="true"></span>
                                        Pending · seats held
                                    </span>
                                </dd>
                            </div>
                        </c:if>
                        <div class="rv-dl-row">
                            <dt><i class="bi bi-grid-3x3"></i> Seats</dt>
                            <dd>
                                <div class="bk-review-seats">
                                    <c:choose>
                                        <c:when test="${not empty booking.seatLabels}">
                                            <c:forEach var="lbl" items="${booking.seatLabels}">
                                                <span class="bk-review-seat">${lbl}</span>
                                            </c:forEach>
                                        </c:when>
                                        <c:when test="${not empty seatLabels}">
                                            <c:forEach var="lbl" items="${seatLabels}">
                                                <span class="bk-review-seat">${lbl}</span>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise><span class="text-muted">—</span></c:otherwise>
                                    </c:choose>
                                </div>
                            </dd>
                        </div>
                    </dl>
                </div>

                <%-- Section 2: Concessions (only if present) --%>
                <c:if test="${not empty concessions}">
                    <div class="rv-section">
                        <h2 class="rv-section-title"><i class="bi bi-cup-hot"></i> Concessions</h2>
                        <div class="rv-concessions-list">
                            <c:forEach var="entry" items="${concessions}">
                                <div class="rv-concession-row">
                                    <div class="rv-concession-info">
                                        <span class="rv-concession-name">${entry.key.name}</span>
                                        <span class="rv-concession-qty">x${entry.value}</span>
                                    </div>
                                    <span class="rv-concession-price"><fmt:formatNumber value="${entry.key.price * entry.value}" pattern="#,###"/>₫</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <%-- Section 3: Promotion code --%>
                <div class="rv-section">
                    <h2 class="rv-section-title"><i class="bi bi-tag"></i> Promotion Code</h2>

                    <c:choose>
                        <c:when test="${not empty appliedPromoCode}">
                            <div class="bk-review-promo-applied">
                                <span class="bk-review-promo-code">${appliedPromoCode}</span>
                                <form method="post" action="${pageContext.request.contextPath}/booking/checkout" class="bk-promo-remove-form">
                                    <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                    <input type="hidden" name="showtimeId" value="${showtimeId}">
                                    <input type="hidden" name="removePromo" value="true">
                                    <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                    <c:forEach var="sid" items="${seatIds}">
                                        <input type="hidden" name="seatIds" value="${sid}">
                                    </c:forEach>
                                    <button type="submit" class="bk-review-promo-remove" title="Remove promotion" aria-label="Remove promotion">
                                        <i class="bi bi-x-lg"></i>
                                    </button>
                                </form>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <form method="post" action="${pageContext.request.contextPath}/booking/checkout" class="bk-review-promo-form">
                                <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <input type="hidden" name="showtimeId" value="${showtimeId}">
                                <input type="hidden" name="applyPromo" value="true">
                                <input type="hidden" name="bookingId" value="${booking.bookingId}">
                                <c:forEach var="sid" items="${seatIds}">
                                    <input type="hidden" name="seatIds" value="${sid}">
                                </c:forEach>
                                <div class="bk-review-promo-field">
                                    <input id="promoCode" class="bk-review-promo-input<c:if test='${not empty promoError}'> is-invalid</c:if>"
                                           type="text" name="promoCode" value="${promoInput}"
                                           placeholder="Enter code" autocomplete="off" spellcheck="false"
                                           aria-describedby="${not empty promoError ? 'promoError' : ''}">
                                    <button class="bk-review-promo-btn" type="submit">Apply</button>
                                </div>
                            </form>
                        </c:otherwise>
                    </c:choose>
                    <c:if test="${not empty promoError}">
                        <p id="promoError" class="bk-review-field-error" role="alert">
                            <i class="bi bi-exclamation-circle"></i> ${promoError}
                        </p>
                    </c:if>
                    <c:if test="${empty appliedPromoCode && empty promoError}">
                        <p class="rv-promo-hint">Have a promo code? Enter it above to get a discount.</p>
                    </c:if>
                </div>

            </div><%-- /.rv-card --%>
        </div>

        <%-- ====== Right col: Order summary (sticky, fnb-summary pattern) ====== --%>
        <div class="col-lg-5">
            <div class="fnb-summary">
                <div class="fnb-summary-body">
                    <h2 class="fnb-summary-title"><i class="bi bi-receipt me-2"></i>Order Summary</h2>

                    <c:choose>
                        <c:when test="${not empty booking}">
                            <div class="rv-summary-lines">
                                <div class="fnb-summary-item">
                                    <span class="fnb-summary-item-name">Tickets <span class="fnb-summary-item-qty">x${booking.seatLabels != null ? booking.seatLabels.size() : seatIds.size()}</span></span>
                                    <span class="fnb-summary-item-price"><fmt:formatNumber value="${booking.subtotal - foodSubtotal}" pattern="#,###"/>₫</span>
                                </div>
                                <c:if test="${foodSubtotal > 0}">
                                    <div class="fnb-summary-item">
                                        <span class="fnb-summary-item-name">Concessions</span>
                                        <span class="fnb-summary-item-price"><fmt:formatNumber value="${foodSubtotal}" pattern="#,###"/>₫</span>
                                    </div>
                                </c:if>
                                <c:if test="${booking.discountAmount > 0}">
                                    <div class="fnb-summary-item rv-discount-line">
                                        <span class="fnb-summary-item-name">
                                            Discount
                                            <c:if test="${not empty appliedPromoCode}">
                                                <span class="rv-promo-badge">${appliedPromoCode}</span>
                                            </c:if>
                                        </span>
                                        <span class="fnb-summary-item-price rv-discount-amount">−<fmt:formatNumber value="${booking.discountAmount}" pattern="#,###"/>₫</span>
                                    </div>
                                </c:if>
                            </div>

                            <hr class="fnb-summary-divider">

                            <div class="fnb-summary-total">
                                <span>Total</span>
                                <span class="fnb-summary-total-amount"><fmt:formatNumber value="${booking.totalAmount}" pattern="#,###"/>₫</span>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="fnb-summary-empty">
                                <i class="bi bi-receipt-cutoff"></i>
                                <div>Price will appear once<br>your seats are held.</div>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <%-- Notes (optional) --%>
                    <hr class="fnb-summary-divider">
                    <div class="rv-notes-block">
                        <label class="rv-notes-label" for="bookingNotes">
                            <i class="bi bi-chat-square-text"></i> Notes
                            <span class="rv-optional-tag">optional</span>
                        </label>
                        <textarea
                            id="bookingNotes"
                            class="rv-notes-textarea"
                            name="notes"
                            form="checkoutForm"
                            rows="2"
                            maxlength="500"
                            placeholder="Special requests, accessibility needs..."
                            aria-describedby="notesHint">${not empty booking.notes ? booking.notes : ''}</textarea>
                        <div class="rv-notes-footer">
                            <span id="notesHint" class="rv-notes-hint">
                                <i class="bi bi-info-circle"></i> Shared with staff
                            </span>
                            <span class="rv-notes-counter" id="notesCounter">0 / 500</span>
                        </div>
                    </div>

                    <%-- Proceed to Payment form --%>
                    <form id="checkoutForm" method="post" action="${pageContext.request.contextPath}/booking/checkout">
                        <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                        <input type="hidden" name="showtimeId" value="${showtimeId}">
                        <input type="hidden" name="bookingId"  value="${booking.bookingId}">
                        <c:forEach var="sid" items="${seatIds}">
                            <input type="hidden" name="seatIds" value="${sid}">
                        </c:forEach>
                        <button class="fnb-summary-cta" type="submit">
                            <span>Proceed to Payment</span>
                            <i class="bi bi-arrow-right" aria-hidden="true"></i>
                        </button>
                    </form>
                    <p class="rv-secure-note">
                        <i class="bi bi-shield-lock" aria-hidden="true"></i> Secure checkout · 256-bit encryption
                    </p>

                    <%-- Cancel booking (secondary destructive, below primary CTA) --%>
                    <c:if test="${not empty booking}">
                        <button type="button" class="fnb-summary-cta fnb-summary-cta--cancel" onclick="openCancelModal()">
                            <span>Cancel this booking</span>
                            <i class="bi bi-x-circle" aria-hidden="true"></i>
                        </button>
                    </c:if>
                </div>
            </div>
        </div>

    </div><%-- /.row --%>

    <%-- ===== Cancel modal ===== --%>
    <div id="cancel-modal" class="modal-overlay is-hidden" onclick="closeCancelModal(event)">
        <div class="modal-box" onclick="event.stopPropagation()">
            <div class="text-center mb-2 modal-danger-icon"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <h5 class="text-center fw-bold mb-1">Cancel this booking?</h5>
            <p class="text-center mb-4 modal-copy">
                Booking <strong>${booking.bookingCode}</strong> will be cancelled and your seats released. This cannot be undone.
            </p>
            <div class="d-flex gap-2">
                <button class="btn btn-outline-secondary flex-fill" onclick="closeCancelModal()">Keep booking</button>
                <form action="${pageContext.request.contextPath}/customer/booking/cancel" method="post" class="flex-fill m-0">
                    <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                    <input type="hidden" name="bookingId"  value="${booking.bookingId}"/>
                    <input type="hidden" name="showtimeId" value="${showtimeId}"/>
                    <button type="submit" class="btn btn-danger w-100">Yes, cancel</button>
                </form>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* ── Cancel modal ── */
    function openCancelModal() {
        document.getElementById('cancel-modal').classList.remove('is-hidden');
        document.body.style.overflow = 'hidden';
    }
    function closeCancelModal(e) {
        if (e && e.target !== e.currentTarget) return;
        document.getElementById('cancel-modal').classList.add('is-hidden');
        document.body.style.overflow = '';
    }
    window.addEventListener('pageshow', function (ev) {
        if (ev.persisted) closeCancelModal();
    });

    /* ── Notes character counter ── */
    (function () {
        var ta = document.getElementById('bookingNotes');
        var counter = document.getElementById('notesCounter');
        if (!ta || !counter) return;
        function update() {
            var len = ta.value.length;
            counter.textContent = len + ' / 500';
            counter.classList.toggle('is-near-limit', len > 400);
        }
        ta.addEventListener('input', update);
        update();
    })();
</script>

<c:if test="${not empty booking}">
<script>
    // Countdown seat hold (Admin Settings: pending_hold_minutes; client-side from page load).
    (function () {
        var HOLD_MIN = ${empty pendingHoldMinutes ? 10 : pendingHoldMinutes};
        var LIMIT_MS = HOLD_MIN * 60 * 1000;
        var start = Date.now();
        var cd   = document.getElementById('countdown');
        var pill = document.getElementById('reserve-pill');
        if (!cd) return;
        function tick() {
            var remaining = Math.max(0, LIMIT_MS - (Date.now() - start));
            var m = Math.floor(remaining / 60000);
            var s = Math.floor((remaining % 60000) / 1000);
            cd.textContent = m + ':' + String(s).padStart(2, '0');
            if (remaining <= 60000 && pill) pill.classList.add('danger');
            if (remaining === 0) {
                clearInterval(timer);
                cd.textContent = 'Expired';
                lcAlert('Your seat hold has expired. Please pick seats again.');
                window.location.href = '${pageContext.request.contextPath}/booking/seats?showtimeId=${showtimeId}';
            }
        }
        tick();
        var timer = setInterval(tick, 1000);
    })();
</script>
</c:if>
</body>
</html>
