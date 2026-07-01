<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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
    <style>
        :root {
            /* --bk-* tokens come from tokens.css */
            --seat-w:34px; --seat-h:32px; --seat-gap:7px; --aisle-w:30px; --rl-w:24px;
        }
        body { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }
        .bk-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px;
            box-shadow:0 4px 12px rgba(15,23,42,.05); }

        /* ===== Context bar ===== */
        .bk-ctx { background:#fff; border-bottom:1px solid var(--bk-border); }
        .bk-reserve { background:#FFF8E1; border:1px solid #FFE082; color:#7a5a00; border-radius:999px;
            padding:.3rem .8rem; font-size:.82rem; font-weight:600; display:inline-flex; align-items:center; gap:.4rem; }

        /* ===== Stepper ===== */
        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:var(--text-subtle); white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:var(--border); color:var(--text-muted); flex-shrink:0; }
        .bk-step.done { color:var(--success); } .bk-step.done .bk-dot { background:var(--success); color:#fff; }
        .bk-step.active { color:var(--bk-primary); } .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:var(--border); margin:0 .5rem; min-width:10px; }
        .bk-line.done { background:var(--success); }

        /* ===== Man chieu (curved screen) ===== */
        .screen-wrap { margin: 4px 0 24px; }
        .screen-curve { height:26px; margin:0 auto; max-width:80%; border-top:3px solid #93b4f6;
            border-radius:50% / 26px 26px 0 0; background:linear-gradient(to bottom, rgba(37,99,235,.14), rgba(37,99,235,0)); }
        .screen-label { text-align:center; font-size:.68rem; color:var(--bk-muted); letter-spacing:.35em; margin-top:6px; font-weight:600; }

        /* ===== So do ghe ===== */
        #seatMap { display:inline-block; text-align:left; }
        .seat-header, .seat-row { display:flex; align-items:center; gap:var(--seat-gap); }
        .seat-row { margin-bottom:var(--seat-gap); }
        .row-label { width:var(--rl-w); font-size:.72rem; font-weight:700; color:var(--bk-muted); text-align:center; flex-shrink:0; }
        .col-num { width:var(--seat-w); font-size:.68rem; font-weight:600; color:var(--text-subtle); text-align:center; flex-shrink:0; }
        .aisle { width:var(--aisle-w); flex-shrink:0; }

        .seat-btn {
            width:var(--seat-w); height:var(--seat-h); font-size:.62rem; font-weight:700;
            border-radius:8px 8px 5px 5px; border:1.6px solid transparent; cursor:pointer; padding:0; flex-shrink:0;
            display:inline-flex; align-items:center; justify-content:center;
            transition:transform .08s, box-shadow .12s; background:#fff;
        }
        .seat-btn:active { transform:scale(.93); }
        .seat-btn:focus { outline:none; }

        /* Trong - Thuong */
        .seat-available { background:#f0f7ff; border-color:#7cb0f5; color:var(--primary-700); }
        .seat-available:hover { background:var(--primary-100); box-shadow:0 0 0 3px rgba(37,99,235,.25); transform:translateY(-2px); }
        /* Bạn đang chọn */
        .seat-selected { background:var(--success) !important; border-color:#15803d !important; color:#fff !important;
            box-shadow:0 0 0 3px rgba(22,163,74,.30); }
        /* Người khác đang chọn (soft-lock) */
        .seat-soft-locked { background:#fef3c7; border-color:#f59e0b; color:#92400e; cursor:not-allowed;
            animation:soft-pulse 1.8s ease-in-out infinite; }
        @keyframes soft-pulse { 0%,100%{box-shadow:0 0 0 2px rgba(245,158,11,.4);} 50%{box-shadow:0 0 0 5px rgba(245,158,11,0);} }
        /* Đã đặt */
        .seat-booked { background:#fee2e2; border-color:#fca5a5; color:#b91c1c; cursor:not-allowed; opacity:.85; }
        /* Bảo trì - dau X */
        .seat-maintenance { background:#f3f4f6; border-color:var(--border-strong); color:#9ca3af; cursor:not-allowed; }
        .seat-maintenance i { font-size:.85rem; }
        /* VIP (con trong) - vang */
        .seat-VIP.seat-available { background:#fef3c7; border-color:#f59e0b; color:#92400e; }
        .seat-VIP.seat-available:hover { background:#fde68a; }
        .seat-VIP.seat-booked { background:#fde8d8; border-color:#fb923c; color:#9a3412; }

        /* ===== Legend ===== */
        .legend-item { display:flex; align-items:center; gap:7px; font-size:.8rem; color:#475569; }
        .legend-box { width:20px; height:18px; border-radius:5px; border:1.6px solid; flex-shrink:0; }

        /* ===== Your selection panel ===== */
        .sel-panel { position:sticky; top:18px; }
        .sel-empty { color:var(--bk-muted); font-size:.88rem; }
        /* Khi co ghe chon (#bookingSummary bo .d-none) -> an placeholder rong (khong dung JS) */
        #bookingSummary:not(.d-none) ~ .sel-empty { display:none; }
        #selectedLabels { font-weight:700; color:var(--bk-primary); }
        #wsBadge, #refreshBadge { font-size:.72rem; }
        #refreshBadge { opacity:0; transition:opacity .4s; }
        #refreshBadge.show { opacity:1; }
    </style>
</head>

<body class="bk-page">
<jsp:include page="../common/header.jsp" />

<%-- ===== Context bar ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <a href="javascript:history.back()" class="btn btn-sm btn-outline-secondary"><i class="bi bi-arrow-left"></i></a>
            <div class="flex-grow-1">
                <div class="fw-bold" style="color:var(--bk-navy);">Showtime
                    <span class="text-primary">${startTimeStr}</span></div>
                <div class="small">
                    <span class="badge bg-secondary">${showtime.format}</span>
                    <span class="badge bg-info text-dark ms-1">${showtime.subtitleType}</span>
                </div>
            </div>
            <span id="wsBadge" class="badge bg-secondary">Connecting…</span>
            <span id="refreshBadge" class="badge bg-success">&#8635; Updated</span>
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

    <h3 class="fw-bold mb-1" style="color:var(--bk-navy);">Choose your seats</h3>
    <p class="text-muted mb-4">Tap a seat to select. Maximum 8 seats per booking.</p>

    <div class="row g-4">

        <%-- ===== Left: seat map ===== --%>
        <div class="col-lg-8">
            <div class="bk-card p-4">
                <div class="screen-wrap">
                    <div class="screen-curve"></div>
                    <div class="screen-label">SCREEN</div>
                </div>

                <div class="text-center" style="overflow-x:auto;">
                    <%-- #seatMap + cac button GIU NGUYEN cau truc/class/data-* (TrangNT) --%>
                    <div id="seatMap">
                        <div class="seat-header"></div>
                        <c:forEach var="rowEntry" items="${seatsByRow}">
                            <div class="seat-row" data-row="${rowEntry.key}">
                                <span class="row-label">${rowEntry.key}</span>
                                <c:forEach var="seat" items="${rowEntry.value}">
                                    <c:set var="isBooked" value="${bookedSeatIds.contains(seat.seatId)}" />
                                    <c:set var="isAvail"  value="${seat.active and not isBooked}" />
                                    <c:choose>
                                        <c:when test="${isAvail}">  <c:set var="statusStr" value="AVAILABLE"   /></c:when>
                                        <c:when test="${isBooked}"> <c:set var="statusStr" value="BOOKED"      /></c:when>
                                        <c:otherwise>              <c:set var="statusStr" value="MAINTENANCE" /></c:otherwise>
                                    </c:choose>
                                    <button
                                        class="seat-btn seat-${seat.seatType}
                                               <c:choose>
                                                   <c:when test="${isAvail}">seat-available</c:when>
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
                                        onclick="toggleSeat(this)"><%-- ghe trong: rong; bao tri: dau X --%><c:if test="${not isAvail and not isBooked}"><i class="bi bi-x-lg"></i></c:if></button>
                                </c:forEach>
                                <span class="row-label">${rowEntry.key}</span>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <%-- Chú thích --%>
                <div class="d-flex flex-wrap gap-3 mt-4 pt-3" style="border-top:1px solid var(--bk-border);">
                    <div class="legend-item"><div class="legend-box" style="background:#f0f7ff;border-color:#7cb0f5;"></div>Available</div>
                    <div class="legend-item"><div class="legend-box" style="background:#fef3c7;border-color:#f59e0b;"></div>VIP</div>
                    <div class="legend-item"><div class="legend-box" style="background:var(--success);border-color:#15803d;"></div>Selected</div>
                    <div class="legend-item"><div class="legend-box" style="background:#fef3c7;border-color:#f59e0b;animation:soft-pulse 1.8s ease-in-out infinite;"></div>Held by others</div>
                    <div class="legend-item"><div class="legend-box" style="background:#fee2e2;border-color:#fca5a5;"></div>Booked</div>
                    <div class="legend-item"><div class="legend-box" style="background:#f3f4f6;border-color:var(--border-strong);"></div>Maintenance</div>
                </div>
            </div>
        </div>

        <%-- ===== Right: your selection ===== --%>
        <div class="col-lg-4">
            <div class="bk-card p-4 sel-panel">
                <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Your Selection</h6>

                <%-- #bookingSummary + #selectedLabels + #proceedBtn GIU NGUYEN id (JS dung) --%>
                <div id="bookingSummary" class="d-none">
                    <div class="mb-3">
                        <div class="text-muted small mb-1">Selected seats</div>
                        <div id="selectedLabels"></div>
                    </div>
                    <button class="btn btn-primary w-100 py-2 fw-semibold" id="proceedBtn" onclick="proceedToCheckout()">
                        Continue <i class="bi bi-arrow-right"></i>
                    </button>
                </div>
                <div class="sel-empty text-center py-4">
                    <i class="bi bi-grid-3x3-gap" style="font-size:1.8rem;color:var(--border-strong);"></i>
                    <div class="mt-2">No seats selected yet.<br>Tap an available seat to choose.</div>
                </div>

                <div class="bk-card mt-3 p-3" style="background:var(--bk-light);border-color:#cfe0fb;">
                    <div class="small" style="color:#1e40af;">
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

                /* Booking INSERTed into DB → hard-lock */
                case 'HARD_LOCK':
                    if (selectedSeats.has(myId)) {
                        selectedSeats.delete(myId);
                        renderSummary();
                        alert('Seat ' + btn.dataset.seatLabel
                            + ' was just booked by someone else. Please choose another seat.');
                    }
                    setSeatState(btn, 'booked');
                    updateAvailableCount(-1);
                    flashRefreshBadge();
                    break;

                /* Booking cancelled / expired → release seat */
                case 'HARD_RELEASE':
                    if (selectedSeats.has(myId)) return;
                    setSeatState(btn, 'available');
                    updateAvailableCount(+1);
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
                alert('You can select a maximum of 8 seats per booking.');
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
            case 'soft-locked':  btn.classList.add('seat-soft-locked');  btn.disabled = true;  break;
            case 'booked':       btn.classList.add('seat-booked');       btn.disabled = true;  break;
            case 'maintenance':  btn.classList.add('seat-maintenance');  btn.disabled = true;  break;
        }
    }

    function renderSummary() {
        const summary = document.getElementById('bookingSummary');
        const labels  = document.getElementById('selectedLabels');
        if (selectedSeats.size === 0) {
            summary.classList.add('d-none');
        } else {
            summary.classList.remove('d-none');
            labels.textContent = [...selectedSeats.values()].map(s => s.label).join(', ');
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
