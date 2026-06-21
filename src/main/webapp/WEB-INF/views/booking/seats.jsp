<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Chọn ghế – MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* ===== Màn chiếu ===== */
            .screen-bar {
                height: 14px;
                background: linear-gradient(to bottom, #d4d4d4, #9ca3af);
                border-radius: 4px 4px 0 0;
                margin-bottom: 6px;
            }
            .screen-label {
                text-align: center;
                font-size: .75rem;
                color: #6b7280;
                letter-spacing: .1em;
                margin-bottom: 24px;
            }

            /* ===== Ghế ===== */
            .seat-btn {
                width: 38px;
                height: 34px;
                font-size: .7rem;
                font-weight: 600;
                border-radius: 6px 6px 4px 4px;
                border: 1.5px solid transparent;
                cursor: pointer;
                transition: transform .1s, box-shadow .1s;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 0;
            }
            .seat-btn:active {
                transform: scale(.93);
            }
            .seat-btn:focus  {
                outline: none;
            }

            /* Trống – Thường */
            .seat-available {
                background: #e0f2fe;
                border-color: #38bdf8;
                color: #0369a1;
            }
            .seat-available:hover {
                background: #bae6fd;
                box-shadow: 0 0 0 3px rgba(56,189,248,.35);
            }

            /* Bạn đang chọn */
            .seat-selected {
                background: #16a34a !important;
                border-color: #15803d !important;
                color: #fff !important;
                box-shadow: 0 0 0 3px rgba(22,163,74,.35);
            }

            /* Người khác đang chọn (soft-lock) — amber, pulsing border */
            .seat-soft-locked {
                background: #fef3c7;
                border-color: #f59e0b;
                color: #92400e;
                cursor: not-allowed;
                animation: soft-pulse 1.8s ease-in-out infinite;
            }
            @keyframes soft-pulse {
                0%,100% {
                    box-shadow: 0 0 0 2px rgba(245,158,11,.4);
                }
                50%      {
                    box-shadow: 0 0 0 5px rgba(245,158,11,.0);
                }
            }

            /* Đã đặt */
            .seat-booked {
                background: #fee2e2;
                border-color: #fca5a5;
                color: #b91c1c;
                cursor: not-allowed;
                opacity: .8;
            }

            /* Bảo trì */
            .seat-maintenance {
                background: #f3f4f6;
                border-color: #d1d5db;
                color: #9ca3af;
                cursor: not-allowed;
                text-decoration: line-through;
            }

            /* VIP overrides */
            .seat-VIP.seat-available       {
                background:#fef3c7;
                border-color:#f59e0b;
                color:#92400e;
            }
            .seat-VIP.seat-available:hover {
                background:#fde68a;
            }
            .seat-VIP.seat-booked          {
                background:#fde8d8;
                border-color:#fb923c;
                color:#9a3412;
            }

            /* ===== Row label ===== */
            .row-label {
                width: 24px;
                font-size: .75rem;
                font-weight: 700;
                color: #6b7280;
                text-align: center;
                flex-shrink: 0;
            }

            /* ===== Chú thích ===== */
            .legend-item {
                display:flex;
                align-items:center;
                gap:8px;
                font-size:.82rem;
            }
            .legend-box  {
                width:22px;
                height:20px;
                border-radius:4px;
                border:1.5px solid;
            }

            /* ===== Tóm tắt đặt chỗ ===== */
            #bookingSummary {
                min-height: 56px;
            }

            /* ===== Badge trạng thái WebSocket ===== */
            #wsBadge {
                font-size: .72rem;
            }

            /* ===== Flash badge ===== */
            #refreshBadge {
                font-size: .72rem;
                opacity: 0;
                transition: opacity .4s;
            }
            #refreshBadge.show {
                opacity: 1;
            }
        </style>
    </head>

    <body>
        <jsp:include page="../common/header.jsp" />

        <div class="container my-4" style="max-width: 860px;">

            <!-- Tiêu đề -->
            <div class="d-flex align-items-center gap-2 mb-1 flex-wrap">
                <a href="javascript:history.back()" class="btn btn-sm btn-outline-secondary">&#8592; Quay lại</a>
                <h5 class="mb-0 fw-bold">Chọn ghế ngồi</h5>
                <span id="wsBadge"      class="badge bg-secondary ms-auto">Đang kết nối…</span>
                <span id="refreshBadge" class="badge bg-success">&#8635; Đã cập nhật</span>
            </div>

            <!-- Thông tin suất chiếu -->
            <div class="card mb-3 border-0 shadow-sm">
                <div class="card-body py-2 px-3">
                    <div class="row g-2 align-items-center">
                        <div class="col-auto">
                            <span class="fw-semibold">Suất:</span>
                            <span class="text-primary fw-bold ms-1">${startTimeStr}</span>
                        </div>
                        <div class="col-auto">
                            <span class="badge bg-secondary">${showtime.format}</span>
                            <span class="badge bg-info text-dark ms-1">${showtime.subtitleType}</span>
                        </div>
                        <div class="col-auto ms-auto">
                            <span class="fw-semibold">Còn trống:</span>
                            <span id="availableCountBadge"
                                  class="badge ms-1 ${availableCount > 0 ? 'bg-success' : 'bg-danger'}">
                                ${availableCount} ghế
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Màn chiếu -->
            <div class="screen-bar"></div>
            <div class="screen-label">MÀN CHIẾU</div>

            <!-- Sơ đồ ghế -->
            <div id="seatMap">
                <c:forEach var="rowEntry" items="${seatsByRow}">
                    <div class="d-flex align-items-center gap-1 mb-1 flex-wrap">
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
                                data-status="${statusStr}"
                                title="${rowEntry.key}${seat.colNumber} (${seat.seatType}) – ${statusStr}"
                                <c:if test="${!isAvail}">disabled</c:if>
                                    onclick="toggleSeat(this)">
                                ${rowEntry.key}${seat.colNumber}
                            </button>
                        </c:forEach>
                    </div>
                </c:forEach>
            </div>

            <!-- Chú thích -->
            <div class="d-flex flex-wrap gap-3 mt-3 mb-4">
                <div class="legend-item">
                    <div class="legend-box" style="background:#e0f2fe;border-color:#38bdf8;"></div>
                    <span>Còn trống (Thường)</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background:#fef3c7;border-color:#f59e0b;"></div>
                    <span>Còn trống (VIP)</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background:#16a34a;border-color:#15803d;"></div>
                    <span>Bạn đang chọn</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box"
                         style="background:#fef3c7;border-color:#f59e0b;animation:soft-pulse 1.8s ease-in-out infinite;"></div>
                    <span>Người khác đang chọn</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background:#fee2e2;border-color:#fca5a5;"></div>
                    <span>Đã đặt</span>
                </div>
                <div class="legend-item">
                    <div class="legend-box" style="background:#f3f4f6;border-color:#d1d5db;"></div>
                    <span>Bảo trì</span>
                </div>
            </div>

            <!-- Tóm tắt lựa chọn -->
            <div id="bookingSummary" class="card border-0 shadow-sm p-3 mb-3 d-none">
                <div class="d-flex justify-content-between align-items-center flex-wrap gap-2">
                    <div>
                        <span class="fw-semibold">Ghế đã chọn: </span>
                        <span id="selectedLabels" class="text-primary fw-bold"></span>
                    </div>
                    <button class="btn btn-primary px-4" id="proceedBtn" onclick="proceedToCheckout()">
                        Tiếp tục →
                    </button>
                </div>
            </div>

        </div><!-- /container -->

        <jsp:include page="../common/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                        /* ── Constants injected from servlet ─────────────────────────────────── */
                        const SHOWTIME_ID = ${showtimeId};
                        const CTX = '${pageContext.request.contextPath}';

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
                                try {
                                    msg = JSON.parse(event.data);
                                } catch (e) {
                                    return;
                                }

                                const btn = document.querySelector('[data-seat-id="' + msg.seatId + '"]');
                                if (!btn)
                                    return;

                                const myId = String(msg.seatId);

                                switch (msg.action) {

                                    /* Người khác vừa chọn ghế này → soft-lock */
                                    case 'SELECT':
                                        if (selectedSeats.has(myId))
                                            return;   // echo của chính mình
                                        setSeatState(btn, 'soft-locked');
                                        break;

                                        /* Người khác bỏ chọn → trả về available */
                                    case 'DESELECT':
                                        if (selectedSeats.has(myId))
                                            return;
                                        setSeatState(btn, 'available');
                                        flashRefreshBadge();
                                        break;

                                        /* Booking đã INSERT vào DB → hard-lock */
                                    case 'HARD_LOCK':
                                        if (selectedSeats.has(myId)) {
                                            selectedSeats.delete(myId);
                                            renderSummary();
                                            alert('Ghế ' + btn.dataset.seatLabel
                                                    + ' vừa được người khác đặt. Vui lòng chọn ghế khác.');
                                        }
                                        setSeatState(btn, 'booked');
                                        updateAvailableCount(-1);
                                        flashRefreshBadge();
                                        break;

                                        /* Booking bị huỷ / hết hạn → ghế trống lại */
                                    case 'HARD_RELEASE':
                                        if (selectedSeats.has(myId))
                                            return;
                                        setSeatState(btn, 'available');
                                        updateAvailableCount(+1);
                                        flashRefreshBadge();
                                        break;
                                }
                            };

                            ws.onclose = function () {
                                setWsBadge('Mất kết nối – thử lại…', 'bg-warning text-dark');
                                setTimeout(connectWS, Math.min(wsRetryDelay, 30000));
                                wsRetryDelay *= 2;
                            };

                            ws.onerror = function () {
                                ws.close();    // onclose sẽ lo retry
                            };
                        }

                        connectWS();

                        /* ── Seat toggle ──────────────────────────────────────────────────────── */
                        function toggleSeat(btn) {
                            const id = String(btn.dataset.seatId);
                            const label = btn.dataset.seatLabel;
                            const type = btn.dataset.seatType;

                            if (selectedSeats.has(id)) {
                                selectedSeats.delete(id);
                                setSeatState(btn, 'available');
                                sendWS({action: 'DESELECT', seatId: Number(id), showtimeId: SHOWTIME_ID});
                            } else {
                                selectedSeats.set(id, {label, type});
                                setSeatState(btn, 'selected');
                                sendWS({action: 'SELECT', seatId: Number(id), showtimeId: SHOWTIME_ID});
                            }
                            renderSummary();
                        }

                        /* ── Checkout ─────────────────────────────────────────────────────────── */
                        function proceedToCheckout() {
                            if (selectedSeats.size === 0)
                                return;
                            const ids = [...selectedSeats.keys()].join(',');
                            window.location.href = CTX + '/booking/checkout'
                                    + '?showtimeId=' + SHOWTIME_ID
                                    + '&seatIds=' + encodeURIComponent(ids);
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
                                case 'available':
                                    btn.classList.add('seat-available');
                                    btn.disabled = false;
                                    break;
                                case 'selected':
                                    btn.classList.add('seat-selected');
                                    btn.disabled = false;
                                    break;
                                case 'soft-locked':
                                    btn.classList.add('seat-soft-locked');
                                    btn.disabled = true;
                                    break;
                                case 'booked':
                                    btn.classList.add('seat-booked');
                                    btn.disabled = true;
                                    break;
                                case 'maintenance':
                                    btn.classList.add('seat-maintenance');
                                    btn.disabled = true;
                                    break;
                            }
                        }

                        function renderSummary() {
                            const summary = document.getElementById('bookingSummary');
                            const labels = document.getElementById('selectedLabels');
                            if (selectedSeats.size === 0) {
                                summary.classList.add('d-none');
                            } else {
                                summary.classList.remove('d-none');
                                labels.textContent = [...selectedSeats.values()].map(s => s.label).join(', ');
                            }
                        }

                        function updateAvailableCount(delta) {
                            const badge = document.getElementById('availableCountBadge');
                            const next = Math.max(0, (parseInt(badge.textContent) || 0) + delta);
                            badge.textContent = next + ' ghế';
                            badge.className = 'badge ms-1 ' + (next > 0 ? 'bg-success' : 'bg-danger');
                        }

                        function setWsBadge(text, cls) {
                            const b = document.getElementById('wsBadge');
                            b.textContent = text;
                            b.className = 'badge ms-auto ' + cls;
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
        </script>
    </body>
</html>
