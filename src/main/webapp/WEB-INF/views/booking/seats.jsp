<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    Chon ghe (booking step 2) - logic real-time/websocket: owner TrangNT.
    Giao dien redesign (stepper + 2 cot + seat-map dong bo manage seat type): HungNT.
    LUU Y: toan bo <script> websocket + cac class/id/data-* GIU NGUYEN -
    chi doi CSS/layout + them script trang tri (buildLayout) khong dung vao logic.
--%>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Choose seats – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/booking.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>

<body class="bk-page">
<jsp:include page="../common/header.jsp" />

<%-- ===== Context bar ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <a href="${pageContext.request.contextPath}/booking/showtimes?movieId=${showtime.movieId}&amp;date=${showtimeDate}"
               class="btn btn-sm btn-outline-secondary" title="Back to Showtime"><i class="bi bi-arrow-left"></i></a>
            <c:choose>
                <c:when test="${not empty showtime.posterUrl}">
                    <img class="bk-poster" src="<c:url value='${showtime.posterUrl}'/>" alt="<c:out value='${showtime.movieTitle}'/>">
                </c:when>
                <c:otherwise><div class="bk-poster"><i class="bi bi-film"></i></div></c:otherwise>
            </c:choose>
            <div class="flex-grow-1">
                <div class="fw-bold bk-context-title"><c:out value="${showtime.movieTitle}"/></div>
                <div class="text-muted small">
                    <i class="bi bi-calendar-event"></i> ${startTimeStr}
                    <span class="badge bg-light text-dark border ms-1">${showtime.format}</span>
                    <span class="badge bg-light text-dark border ms-1">${showtime.subtitleType}</span>
                </div>
            </div>
            <div class="d-flex align-items-center gap-2 bk-live-meta">
                <span id="wsBadge" class="badge bg-secondary" aria-live="polite">Connecting…</span>
                <span id="refreshBadge" class="badge bg-success">&#8635; Updated</span>
            </div>
            <div class="text-end">
                <div class="text-muted small">Available</div>
                <span id="availableCountBadge" class="badge ${availableCount > 0 ? 'bg-success' : 'bg-danger'}">${availableCount} seats</span>
            </div>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <%-- ===== Stepper (2/5 Seats) ===== --%>
    <div class="bk-steps mb-4">
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">2</span>Seats</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">3</span>Food & Drinks</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">4</span>Review</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">5</span>Payment</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">6</span>Confirm</div>
    </div>

    <h3 class="fw-bold mb-1 bk-title">Choose your seats</h3>
    <p class="text-muted mb-4">Tap a seat to select. Maximum 8 seats per booking.</p>

    <c:if test="${param.cancelled == '1'}">
        <div class="lc-alert is-success mb-3"><i class="bi bi-check-circle-fill"></i>
            <span>Booking cancelled. Your seats have been released — you can pick new seats below.</span>
        </div>
    </c:if>
    <c:if test="${param.cancelErr == 'NOT_CANCELLABLE'}">
        <div class="lc-alert is-error mb-3"><i class="bi bi-exclamation-triangle-fill"></i>
            <span>This booking could not be cancelled (it may have already expired or been confirmed).</span>
        </div>
    </c:if>
    <c:if test="${param.cancelErr == 'SYSTEM'}">
        <div class="lc-alert is-error mb-3"><i class="bi bi-exclamation-triangle-fill"></i>
            <span>Could not cancel the booking due to a system error. Please try again or contact support.</span>
        </div>
    </c:if>

    <div class="row g-4">

        <%-- ===== Left: seat map ===== --%>
        <div class="col-lg-8">
            <div class="bk-card p-4">
                <div class="screen-wrap">
                    <div class="screen-curve"></div>
                    <div class="screen-label">SCREEN</div>
                </div>

                <div class="text-center seat-map-scroll">
                    <%-- #seatMap + cac button GIU NGUYEN cau truc/class/data-* (TrangNT) --%>
                    <div id="seatMap">
                        <div class="seat-header"></div>
                        <c:forEach var="rowEntry" items="${seatsByRow}">
                            <div class="seat-row" data-row="${rowEntry.key}">
                                <span class="row-label">${rowEntry.key}</span>
                                <c:forEach var="seat" items="${rowEntry.value}">
                                    <c:set var="isBooked" value="${bookedSeatIds.contains(seat.seatId)}" />
                                    <c:set var="isHeld"   value="${heldSeatIds.contains(seat.seatId)}" />
                                    <c:set var="isAvail"  value="${seat.active and not isBooked and not isHeld}" />
                                    <c:choose>
                                        <c:when test="${isAvail}">  <c:set var="statusStr" value="AVAILABLE"   /></c:when>
                                        <c:when test="${isHeld}">   <c:set var="statusStr" value="HELD"        /></c:when>
                                        <c:when test="${isBooked}"> <c:set var="statusStr" value="BOOKED"      /></c:when>
                                        <c:otherwise>              <c:set var="statusStr" value="MAINTENANCE" /></c:otherwise>
                                    </c:choose>
                                    <button
                                        class="seat-btn seat-${seat.seatType}
                                               <c:choose>
                                                   <c:when test="${isAvail}">seat-available</c:when>
                                                   <c:when test="${isHeld}">seat-soft-locked</c:when>
                                                   <c:when test="${isBooked}">seat-booked</c:when>
                                                   <c:otherwise>seat-maintenance</c:otherwise>
                                               </c:choose>"
                                        data-seat-id="${seat.seatId}"
                                        data-seat-type="${seat.seatType}"
                                        data-seat-label="${rowEntry.key}${seat.colNumber}"
                                        data-col="${seat.colNumber}"
                                        data-status="${statusStr}"
                                        title="${rowEntry.key}${seat.colNumber} (${seat.seatType}) – ${statusStr}"
                                        <c:if test="${!isAvail}">disabled</c:if>
                                        onclick="toggleSeat(this)"><%-- ghe trong: rong; bao tri: dau X --%><c:if test="${not isAvail and not isBooked and not isHeld}"><i class="bi bi-x-lg"></i></c:if></button>
                                </c:forEach>
                                <span class="row-label">${rowEntry.key}</span>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <%-- Chú thích --%>
                <div class="d-flex flex-wrap gap-3 mt-4 pt-3 seat-legend">
                    <div class="legend-item"><div class="legend-box is-available"></div>Standard <fmt:formatNumber value="${standardPrice}" pattern="#,##0"/> VND</div>
                    <div class="legend-item"><div class="legend-box is-vip"></div>VIP <fmt:formatNumber value="${vipPrice}" pattern="#,##0"/> VND</div>
                    <div class="legend-item"><div class="legend-box is-selected"></div>Selected</div>
                    <div class="legend-item"><div class="legend-box is-held"></div>Held by others</div>
                    <div class="legend-item"><div class="legend-box is-booked"></div>Booked</div>
                    <div class="legend-item"><div class="legend-box is-maintenance"></div>Maintenance</div>
                </div>
            </div>
        </div>

        <%-- ===== Right: your selection ===== --%>
        <div class="col-lg-4">
            <div class="bk-card p-4 sel-panel">
                <h6 class="fw-bold mb-3 bk-panel-title">Your Selection</h6>

                <%-- #bookingSummary + #selectedLabels + #proceedBtn GIU NGUYEN id (JS dung) --%>
                <div id="bookingSummary" class="d-none">
                    <div class="mb-3">
                        <div class="text-muted small mb-1">Selected seats</div>
                        <div id="selectedLabels"></div>
                    </div>
                    <div id="priceBreakdown" class="mb-3"></div>
                    <div class="bk-sum-line bk-sum-total mb-3">
                        <span class="fw-bold bk-total-label">Tickets subtotal</span>
                        <span class="fw-bold bk-total-price" id="selectedTotal">0 VND</span>
                    </div>
                    <button class="btn btn-primary w-100 py-2 fw-semibold" id="proceedBtn" onclick="proceedToCheckout()">
                        Continue <i class="bi bi-arrow-right"></i>
                    </button>
                </div>
                <div class="sel-empty text-center py-4">
                    <i class="bi bi-grid-3x3-gap fs-2 text-muted"></i>
                    <div class="mt-2">No seats selected yet.<br>Tap an available seat to choose.</div>
                </div>

                <div class="bk-card mt-3 p-3 bk-info-note">
                    <div class="small">
                        <i class="bi bi-info-circle-fill"></i> Seats are held while you're on this page.</div>
                </div>
            </div>
        </div>
    </div>
</div><!-- /container -->

<jsp:include page="../common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    /* ── Constants injected from servlet ─────────────────────────────────── */
    const SHOWTIME_ID = ${showtimeId};
    const CTX         = '${pageContext.request.contextPath}';
    const STANDARD_PRICE = ${standardPrice};
    const VIP_PRICE      = ${vipPrice};

    /* ── Client-side selection state ──────────────────────────────────────
       Map<seatId(string), { label, type }>                                */
    const selectedSeats = new Map();

    /* ── WebSocket ────────────────────────────────────────────────────────
       Endpoint: /ws/seats/{showtimeId}  → SeatWebSocketServer            */
    const WS_URL = (location.protocol === 'https:' ? 'wss' : 'ws')
                 + '://' + location.host
                 + CTX + '/ws/seats/' + SHOWTIME_ID;

    let ws = null;
    let wsRetryDelay = 2000;   // exponential back-off seed (ms)

    function connectWS() {
        ws = new WebSocket(WS_URL);

        ws.onopen = function () {
            setWsBadge('Realtime', 'bg-success');
            wsRetryDelay = 2000;
        };

        ws.onmessage = function (event) {
            let msg;
            try { msg = JSON.parse(event.data); }
            catch (e) { return; }

            const btn = document.querySelector('[data-seat-id="' + msg.seatId + '"]');
            if (!btn) return;

            const myId = String(msg.seatId);

            switch (msg.action) {

                /* Someone else just selected this seat → soft-lock */
                case 'SELECT':
                    if (selectedSeats.has(myId)) return;   // own echo
                    setSeatState(btn, 'soft-locked');
                    break;

                /* Someone else deselected → return to available */
                case 'DESELECT':
                    if (selectedSeats.has(myId)) return;
                    setSeatState(btn, 'available');
                    flashRefreshBadge();
                    break;

                /* Booking PENDING created → held until payment */
                case 'HELD_LOCK':
                    if (selectedSeats.has(myId)) {
                        selectedSeats.delete(myId);
                        renderSummary();
                        lcAlert('Seat ' + btn.dataset.seatLabel
                            + ' is being held for payment by someone else. Please choose another seat.');
                    }
                    if (!btn.classList.contains('seat-booked')
                            && !btn.classList.contains('seat-soft-locked')) {
                        setSeatState(btn, 'soft-locked');
                        updateAvailableCount(-1);
                    }
                    flashRefreshBadge();
                    break;

                /* Payment confirmed → booked */
                case 'HARD_LOCK':
                    if (selectedSeats.has(myId)) {
                        selectedSeats.delete(myId);
                        renderSummary();
                        lcAlert('Seat ' + btn.dataset.seatLabel
                            + ' was just booked by someone else. Please choose another seat.');
                    }
                    const wasOccupied = btn.classList.contains('seat-booked')
                        || btn.classList.contains('seat-soft-locked');
                    setSeatState(btn, 'booked');
                    if (!wasOccupied) {
                        updateAvailableCount(-1);
                    }
                    flashRefreshBadge();
                    break;

                /* Booking cancelled / expired → release seat */
                case 'HARD_RELEASE':
                    if (selectedSeats.has(myId)) return;
                    if (btn.dataset.status === 'BOOKED' || btn.classList.contains('seat-booked')) {
                        setSeatState(btn, 'available');
                        updateAvailableCount(+1);
                    } else if (btn.dataset.status === 'HELD' || btn.classList.contains('seat-soft-locked')) {
                        setSeatState(btn, 'available');
                        updateAvailableCount(+1);
                    }
                    flashRefreshBadge();
                    break;
            }
        };

        ws.onclose = function () {
            setWsBadge('Disconnected – retrying…', 'bg-warning text-dark');
            setTimeout(connectWS, Math.min(wsRetryDelay, 30000));
            wsRetryDelay *= 2;
        };

        ws.onerror = function () {
            ws.close();    // onclose will handle retry
        };
    }

    connectWS();

    /* ── Seat toggle ──────────────────────────────────────────────────────── */
    function toggleSeat(btn) {
        const id    = String(btn.dataset.seatId);
        const label = btn.dataset.seatLabel;
        const type  = btn.dataset.seatType;

        if (selectedSeats.has(id)) {
            selectedSeats.delete(id);
            setSeatState(btn, 'available');
            sendWS({ action: 'DESELECT', seatId: Number(id), showtimeId: SHOWTIME_ID });
        } else {
            if (selectedSeats.size >= 8) {
                lcAlert('You can select a maximum of 8 seats per booking.');
                return;
            }
            selectedSeats.set(id, { label, type });
            setSeatState(btn, 'selected');
            sendWS({ action: 'SELECT', seatId: Number(id), showtimeId: SHOWTIME_ID });
        }
        renderSummary();
    }

    /* ── Checkout ─────────────────────────────────────────────────────────── */
    function proceedToCheckout() {
        if (selectedSeats.size === 0) return;
        const ids = [...selectedSeats.keys()].join(',');
        window.location.href = CTX + '/booking/food-drinks'
            + '?showtimeId=' + SHOWTIME_ID
            + '&seatIds='    + encodeURIComponent(ids);
    }

    /* ── UI helpers ───────────────────────────────────────────────────────── */

    // state: 'available' | 'selected' | 'soft-locked' | 'booked' | 'maintenance'
    function setSeatState(btn, state) {
        btn.classList.remove(
            'seat-available', 'seat-selected',
            'seat-soft-locked', 'seat-booked', 'seat-maintenance'
        );
        btn.dataset.status = state.toUpperCase().replace(/-/g, '_');

        switch (state) {
            case 'available':    btn.classList.add('seat-available');    btn.disabled = false; break;
            case 'selected':     btn.classList.add('seat-selected');     btn.disabled = false; break;
            case 'soft-locked':  btn.classList.add('seat-soft-locked');  btn.disabled = true;  btn.dataset.status = 'HELD'; break;
            case 'booked':       btn.classList.add('seat-booked');       btn.disabled = true;  break;
            case 'maintenance':  btn.classList.add('seat-maintenance');  btn.disabled = true;  break;
        }
    }

    function seatUnitPrice(type) {
        return type === 'VIP' ? VIP_PRICE : STANDARD_PRICE;
    }

    function formatCurrency(amount) {
        return Math.round(amount).toLocaleString('en-US');
    }

    function renderSummary() {
        const summary = document.getElementById('bookingSummary');
        const labels  = document.getElementById('selectedLabels');
        const breakdown = document.getElementById('priceBreakdown');
        const totalEl = document.getElementById('selectedTotal');
        if (selectedSeats.size === 0) {
            summary.classList.add('d-none');
        } else {
            summary.classList.remove('d-none');
            labels.textContent = [...selectedSeats.values()].map(s => s.label).join(', ');

            const counts = { STANDARD: 0, VIP: 0 };
            let total = 0;
            for (const seat of selectedSeats.values()) {
                counts[seat.type] = (counts[seat.type] || 0) + 1;
                total += seatUnitPrice(seat.type);
            }

            let html = '';
            if (counts.STANDARD > 0) {
                html += '<div class="bk-sum-line"><span class="text-muted">Standard x' + counts.STANDARD + '</span>'
                      + '<span>' + formatCurrency(counts.STANDARD * STANDARD_PRICE) + ' VND</span></div>';
            }
            if (counts.VIP > 0) {
                html += '<div class="bk-sum-line"><span class="text-muted">VIP x' + counts.VIP + '</span>'
                      + '<span>' + formatCurrency(counts.VIP * VIP_PRICE) + ' VND</span></div>';
            }
            breakdown.innerHTML = html;
            totalEl.textContent = formatCurrency(total) + ' VND';
        }
    }

    function updateAvailableCount(delta) {
        const badge   = document.getElementById('availableCountBadge');
        const next    = Math.max(0, (parseInt(badge.textContent) || 0) + delta);
        badge.textContent = next + ' seats';
        badge.className   = 'badge ' + (next > 0 ? 'bg-success' : 'bg-danger');
    }

    function setWsBadge(text, cls) {
        const b = document.getElementById('wsBadge');
        b.textContent = text;
        b.className   = 'badge ' + cls;
    }

    function flashRefreshBadge() {
        const b = document.getElementById('refreshBadge');
        b.classList.add('show');
        setTimeout(() => b.classList.remove('show'), 2000);
    }

    function sendWS(payload) {
        if (ws && ws.readyState === WebSocket.OPEN) {
            ws.send(JSON.stringify(payload));
        }
    }

    /* ── Trang tri so do (HungNT): them so cot + loi di. KHONG dung vao logic/websocket.
       Chi chen element decorative; cac button data-seat-id giu nguyen.            ── */
    (function buildLayout() {
        const rows = Array.from(document.querySelectorAll('.seat-row'));
        if (!rows.length) return;
        const colSet = new Set();
        rows.forEach(r => r.querySelectorAll('.seat-btn').forEach(b => colSet.add(+b.dataset.col)));
        const cols = Array.from(colSet).sort((a, b) => a - b);
        if (!cols.length) return;
        const aisleAfter = cols[Math.ceil(cols.length / 2) - 1];

        const header = document.querySelector('#seatMap .seat-header');
        header.innerHTML = '<span class="row-label"></span>';
        cols.forEach(c => {
            if (c === aisleAfter + 1) header.insertAdjacentHTML('beforeend', '<span class="aisle"></span>');
            header.insertAdjacentHTML('beforeend', '<span class="col-num">' + c + '</span>');
        });
        header.insertAdjacentHTML('beforeend', '<span class="row-label"></span>');

        rows.forEach(r => {
            const seats = r.querySelectorAll('.seat-btn');
            for (const b of seats) {
                if (+b.dataset.col === aisleAfter + 1) {
                    const sp = document.createElement('span');
                    sp.className = 'aisle';
                    r.insertBefore(sp, b);
                    break;
                }
            }
        });
    })();
</script>
</body>
</html>
