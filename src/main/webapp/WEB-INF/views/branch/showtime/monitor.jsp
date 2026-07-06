<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="en_US" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Real-time Showtime Monitor - PentaPlex Manager</title>
    <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    <%@ include file="/WEB-INF/views/branch/seat-layout-style.jspf" %>
    <style>
        .sl-seat { cursor: default !important; pointer-events: none; }
        .sl-seat.is-booked { background: #fee2e2 !important; border-color: #f87171 !important; color: #991b1b !important; }
        .sl-seat.is-soft-locked { background: #ffedd5 !important; border-color: #fb923c !important; color: #9a3412 !important; }
        .d-booked { background: #fee2e2; border-color: #f87171; }
        .d-soft { background: #ffedd5; border-color: #fb923c; }
        .log-panel {
            height: 380px; overflow-y: auto; background: #0f172a;
            color: #38bdf8; font-family: monospace; font-size: .8rem;
            border-radius: 8px; padding: 12px; line-height: 1.5;
        }
        .log-entry { margin-bottom: 6px; border-bottom: 1px solid #1e293b; padding-bottom: 4px; }
        .log-time { color: #64748b; margin-right: 8px; }
        .log-action { color: #f8fafc; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="showtimes"/>
</jsp:include>

<main class="lc-admin-main">
    <div class="lc-page">

        <div class="lc-page-head">
            <div>
                <div class="lc-page-crumb">
                    Dashboard / <a href="${pageContext.request.contextPath}/branch/showtimes" class="text-decoration-none text-muted">Showtimes</a>
                    / <strong>Real-time Monitor</strong>
                </div>
                <h1 class="lc-page-title">Real-time Seat &amp; Booking Monitor</h1>
            </div>
            <a class="lc-back-link"
               href="${pageContext.request.contextPath}/branch/showtimes?date=${fn:substring(showtime.startTime, 0, 10)}">
                <i class="bi bi-arrow-left" aria-hidden="true"></i> Back to showtimes</a>
        </div>

        <%-- Showtime Header card --%>
        <div class="card lc-elev p-3 mb-3">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <h5 class="text-navy fw-bold mb-1"><c:out value="${showtime.movieTitle}"/></h5>
                    <p class="text-muted small mb-0">
                        <i class="bi bi-door-open me-1"></i>Room: <strong><c:out value="${showtime.roomName}"/></strong> (${showtime.roomType})
                        &middot; Format: <strong>${showtime.format}</strong>
                        &middot; Subtitle: <strong>${showtime.subtitleType}</strong>
                    </p>
                </div>
                <div class="col-md-6 text-md-end mt-2 mt-md-0">
                    <span class="fs-5 fw-bold text-navy mono">
                        ${fn:substring(showtime.startTime, 11, 16)} &rarr; ${fn:substring(showtime.endTime, 11, 16)}
                    </span>
                    <div class="text-muted small">
                        <fmt:parseDate value="${fn:substring(showtime.startTime, 0, 10)}" pattern="yyyy-MM-dd" var="parsedDate"/>
                        <fmt:formatDate value="${parsedDate}" pattern="EEEE, dd MMMM yyyy"/>
                    </div>
                </div>
            </div>
        </div>

        <%-- Live Stats --%>
        <div class="lc-kpi-row">
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-pie-chart-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Real-time occupancy</div>
                    <div class="lc-kpi-value" id="liveOccPct">
                        <fmt:formatNumber value="${showtime.roomCapacity > 0 ? showtime.bookedSeats * 100 / showtime.roomCapacity : 0}" maxFractionDigits="0" />%
                    </div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-ticket-perforated-fill"></i></div>
                <div>
                    <div class="lc-kpi-label">Seats sold (hard lock)</div>
                    <div class="lc-kpi-value" id="liveSold">${showtime.bookedSeats} / ${showtime.roomCapacity}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--amber"><i class="bi bi-hourglass-split"></i></div>
                <div>
                    <div class="lc-kpi-label">Selecting (soft lock)</div>
                    <div class="lc-kpi-value lc-kpi-value--amber" id="liveSoft">${fn:length(heldSeatIds)}</div>
                </div>
            </div>
            <div class="lc-kpi-card">
                <div class="lc-stat-icon lc-kpi-icon--slate"><i class="bi bi-broadcast"></i></div>
                <div>
                    <div class="lc-kpi-label">Live connection</div>
                    <div class="lc-kpi-status" id="wsStatus">
                        <span class="badge bg-secondary">Connecting...</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="row g-3">
            <%-- ===== LEFT: Seat Grid ===== --%>
            <div class="col-lg-8">
                <div class="card lc-elev p-4">
                    <div class="sl-screen-wrap mb-4">
                        <div class="sl-screen-curve"></div>
                        <div class="sl-screen-label">SCREEN</div>
                    </div>

                    <div class="sl-grid">
                        <%-- Col header --%>
                        <c:set var="hdrDone" value="false"/>
                        <c:forEach var="row" items="${seatsByRow}">
                            <c:if test="${not hdrDone}">
                                <c:set var="hLen" value="${fn:length(row.value)}"/>
                                <div class="sl-row">
                                    <span class="sl-rlabel"></span>
                                    <c:forEach var="seat" items="${row.value}" varStatus="st">
                                        <span class="sl-colnum">${seat.colNumber}</span>
                                        <c:if test="${st.count == (hLen / 2) and hLen > 3}"><span class="sl-aisle"></span></c:if>
                                    </c:forEach>
                                    <span class="sl-rlabel"></span>
                                </div>
                                <c:set var="hdrDone" value="true"/>
                            </c:if>
                        </c:forEach>

                        <%-- Rows --%>
                        <c:forEach var="row" items="${seatsByRow}">
                            <c:set var="rowLen" value="${fn:length(row.value)}"/>
                            <div class="sl-row">
                                <span class="sl-rlabel">${row.key}</span>
                                <c:forEach var="seat" items="${row.value}" varStatus="st">
                                    <c:set var="isBooked" value="${bookedSeatIds.contains(seat.getSeatId())}"/>
                                    <c:set var="isHeld" value="${heldSeatIds.contains(seat.getSeatId())}"/>
                                    <button type="button" id="seat-${seat.seatId}"
                                            class="sl-seat ${not seat.active ? 'is-off' : (isBooked ? 'is-booked' : (isHeld ? 'is-soft-locked' : (seat.seatType == 'VIP' ? 'is-vip' : 'is-std')))}"
                                            title="Seat ${seat.rowLabel}${seat.colNumber} (${seat.seatType})"
                                            data-label="${seat.rowLabel}${seat.colNumber}"
                                            data-seatid="${seat.seatId}"></button>
                                    <c:if test="${st.count == (rowLen / 2) and rowLen > 3}">
                                        <span class="sl-aisle"></span>
                                    </c:if>
                                </c:forEach>
                                <span class="sl-rlabel">${row.key}</span>
                            </div>
                        </c:forEach>
                    </div>

                    <%-- Legend --%>
                    <div class="sl-legend">
                        <span><span class="dot d-std"></span>Standard (Available)</span>
                        <span><span class="dot d-vip"></span>VIP (Available)</span>
                        <span><span class="dot d-booked"></span>Booked / Sold</span>
                        <span><span class="dot d-soft"></span>Held / Selecting</span>
                        <span><span class="dot d-off"></span>Off / Maintain</span>
                    </div>
                </div>
            </div>

            <%-- ===== RIGHT: Live Logs ===== --%>
            <div class="col-lg-4">
                <div class="card lc-elev p-3">
                    <h6 class="text-navy fw-bold mb-3 d-flex justify-content-between align-items-center">
                        <span>Real-time Event Log</span>
                        <button type="button" class="btn btn-sm btn-outline-secondary py-0 border-0" id="clearLogBtn" style="font-size:.75rem;">Clear</button>
                    </h6>
                    <div class="log-panel" id="logPanel">
                        <div class="log-entry"><span class="log-time" id="logInitTime"></span><span class="text-info">Initializing real-time connection...</span></div>
                    </div>
                </div>
            </div>
        </div>

    </div>
</main>

<%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Dynamic JSTL parameter bindings
        const showtimeId = "${showtime.showtimeId}";
        const totalCapacity = parseInt("${showtime.roomCapacity}");
        let currentSold = parseInt("${showtime.bookedSeats}");
        let currentSoft = ${fn:length(heldSeatIds)};

        // DOM elements cache references
        const logPanel = document.getElementById("logPanel");
        const statusBadge = document.getElementById("wsStatus");
        const soldDisplay = document.getElementById("liveSold");
        const softDisplay = document.getElementById("liveSoft");
        const pctDisplay = document.getElementById("liveOccPct");

        // Set initial log time
        document.getElementById("logInitTime").innerText = formatTime(new Date());

        // Connect to WebSocket using protocol helper matching secure context (wss / ws)
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const wsUrl = protocol + "//" + window.location.host + "${pageContext.request.contextPath}/ws/seats/" + showtimeId;
        
        let ws;

        /**
         * [Flow Step: WebSocket] Establish real-time connection to SeatWebSocketServer
         */
        function connect() {
            ws = new WebSocket(wsUrl);

            ws.onopen = function() {
                statusBadge.innerHTML = '<span class="badge bg-success"><i class="bi bi-circle-fill me-1" style="font-size:.55rem; color:#fff;"></i> Live</span>';
                addLog("System", "Live connection established successfully.");
            };

            // [Flow Step: WebSocket -> Client] Receive real-time seat lock state broadcasts
            ws.onmessage = function(event) {
                try {
                    const msg = JSON.parse(event.data);
                    const seatElement = document.getElementById("seat-" + msg.seatId);
                    if (!seatElement) return;

                    const seatLabel = seatElement.getAttribute("data-label");
                    const user = msg.username || "Customer";

                    switch(msg.action) {
                        case "SELECT":
                            // Customer chooses a seat: add soft-locked visual style (amber)
                            if (!seatElement.classList.contains("is-booked") && !seatElement.classList.contains("is-off")) {
                                if (!seatElement.classList.contains("is-soft-locked")) {
                                    seatElement.classList.add("is-soft-locked");
                                    currentSoft++;
                                    addLog(user, "Selected (Soft locked) Seat " + seatLabel);
                                }
                            }
                            break;

                        case "DESELECT":
                            // Customer deselects a seat: remove soft-locked visual style
                            if (seatElement.classList.contains("is-soft-locked")) {
                                seatElement.classList.remove("is-soft-locked");
                                currentSoft = Math.max(0, currentSoft - 1);
                                addLog(user, "Deselected Seat " + seatLabel);
                            }
                            break;

                        case "HELD_LOCK":
                            // Converted to temporary payment hold: maintain soft-locked style
                            if (!seatElement.classList.contains("is-booked") && !seatElement.classList.contains("is-off")) {
                                if (!seatElement.classList.contains("is-soft-locked")) {
                                    seatElement.classList.add("is-soft-locked");
                                    currentSoft++;
                                    addLog(user || "Customer", "Held (pending payment) Seat " + seatLabel);
                                }
                            }
                            break;

                        case "HARD_LOCK":
                            // Confirm database reservation: switch to booked status (red)
                            if (seatElement.classList.contains("is-soft-locked")) {
                                seatElement.classList.remove("is-soft-locked");
                                currentSoft = Math.max(0, currentSoft - 1);
                            }
                            if (!seatElement.classList.contains("is-booked") && !seatElement.classList.contains("is-off")) {
                                seatElement.classList.add("is-booked");
                                currentSold = Math.min(totalCapacity, currentSold + 1);
                                addLog(user, "CONFIRMED booking for Seat " + seatLabel);
                            }
                            break;

                        case "HARD_RELEASE":
                            // Release locks (payment timeout or transaction cancel)
                            if (seatElement.classList.contains("is-booked")) {
                                seatElement.classList.remove("is-booked");
                                currentSold = Math.max(0, currentSold - 1);
                                addLog("System", "Booking expired / Cancelled. Released Seat " + seatLabel);
                            } else if (seatElement.classList.contains("is-soft-locked")) {
                                seatElement.classList.remove("is-soft-locked");
                                currentSoft = Math.max(0, currentSoft - 1);
                                addLog("System", "Hold expired / Cancelled. Released Seat " + seatLabel);
                            }
                            break;
                    }

                    // [Flow Step: JavaScript] Update KPI stat card counters and occupancy percentage dynamically
                    soldDisplay.innerText = currentSold + " / " + totalCapacity;
                    softDisplay.innerText = currentSoft;
                    const pct = totalCapacity > 0 ? Math.round((currentSold * 100) / totalCapacity) : 0;
                    pctDisplay.innerText = pct + "%";

                } catch (e) {
                    console.error("Error parsing WS message:", e);
                }
            };

            // Connection lost hook: trigger reconnection loop after 5 seconds
            ws.onclose = function() {
                statusBadge.innerHTML = '<span class="badge bg-danger">Disconnected</span>';
                addLog("System", "Connection lost. Reconnecting in 5 seconds...");
                setTimeout(connect, 5000);
            };

            ws.onerror = function(err) {
                console.error("WebSocket error:", err);
            };
        }

        connect();

        /**
         * [Flow Step: JavaScript] Formats Date instance to local HH:MM:SS format
         */
        function formatTime(d) {
            const h = String(d.getHours()).padStart(2, '0');
            const m = String(d.getMinutes()).padStart(2, '0');
            const s = String(d.getSeconds()).padStart(2, '0');
            return h + ":" + m + ":" + s;
        }

        /**
         * [Flow Step: JavaScript] Appends a log message item to the console board
         */
        function addLog(actor, message) {
            const timeStr = formatTime(new Date());
            const entry = document.createElement("div");
            entry.className = "log-entry";
            entry.innerHTML = '<span class="log-time">' + timeStr + '</span>' +
                              '<strong>[' + actor + ']</strong> ' +
                              '<span class="log-action">' + message + '</span>';
            
            // Insert at the top to keep recent logs visible immediately
            logPanel.insertBefore(entry, logPanel.firstChild);
            
            // Cap entries count to 50 items to keep page memory consumption low
            if (logPanel.childNodes.length > 50) {
                logPanel.removeChild(logPanel.lastChild);
            }
        }

        // Add clear logger click event listener
        document.getElementById("clearLogBtn").addEventListener("click", function() {
            logPanel.innerHTML = '<div class="log-entry"><span class="log-time">' + formatTime(new Date()) + '</span><span class="text-info">Logs cleared. Real-time stream active.</span></div>';
        });
    });
</script>
</body>
</html>
