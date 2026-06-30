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
    <title>Real-time Showtime Monitor - MBCMS Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
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
    <div class="container-fluid px-4 py-4" style="max-width:1240px;">

        <%-- Header --%>
        <div class="text-muted small mb-1">
            Dashboard / Showtimes / <span class="fw-semibold">Real-time Monitor</span>
        </div>
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h4 class="text-navy fw-bold mb-0">
                Real-time Seat &amp; Booking Monitor
            </h4>
            <a class="btn btn-light btn-sm border" href="${pageContext.request.contextPath}/branch/showtimes?date=${fn:substring(showtime.startTime, 0, 10)}">
                <i class="bi bi-arrow-left me-1"></i>Back to showtimes</a>
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
        <div class="row g-3 mb-3">
            <div class="col-md-3 col-6">
                <div class="card lc-elev p-3 text-center">
                    <div class="text-muted small fw-semibold">REAL-TIME OCCUPANCY</div>
                    <div class="text-navy fw-bold fs-3" id="liveOccPct">
                        <fmt:formatNumber value="${showtime.roomCapacity > 0 ? showtime.bookedSeats * 100 / showtime.roomCapacity : 0}" maxFractionDigits="0" />%
                    </div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="card lc-elev p-3 text-center">
                    <div class="text-muted small fw-semibold">SEATS SOLD (HARD LOCK)</div>
                    <div class="text-navy fw-bold fs-3" id="liveSold">${showtime.bookedSeats} / ${showtime.roomCapacity}</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="card lc-elev p-3 text-center">
                    <div class="text-muted small fw-semibold">SELECTING (SOFT LOCK)</div>
                    <div class="text-warning fw-bold fs-3" id="liveSoft">0</div>
                </div>
            </div>
            <div class="col-md-3 col-6">
                <div class="card lc-elev p-3 text-center">
                    <div class="text-muted small fw-semibold">WEBSOCKET STATUS</div>
                    <div class="fw-bold fs-5 mt-2" id="wsStatus">
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
                                    <button type="button" id="seat-${seat.seatId}"
                                            class="sl-seat ${not seat.active ? 'is-off' : (isBooked ? 'is-booked' : (seat.seatType == 'VIP' ? 'is-vip' : 'is-std'))}"
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
                        <span><span class="dot d-soft"></span>Selecting (Soft Lock)</span>
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener("DOMContentLoaded", function() {
        const showtimeId = "${showtime.showtimeId}";
        const totalCapacity = parseInt("${showtime.roomCapacity}");
        let currentSold = parseInt("${showtime.bookedSeats}");
        let currentSoft = 0;

        const logPanel = document.getElementById("logPanel");
        const statusBadge = document.getElementById("wsStatus");
        const soldDisplay = document.getElementById("liveSold");
        const softDisplay = document.getElementById("liveSoft");
        const pctDisplay = document.getElementById("liveOccPct");

        // Set initial log time
        document.getElementById("logInitTime").innerText = formatTime(new Date());

        // Connect to WebSocket
        const protocol = window.location.protocol === "https:" ? "wss:" : "ws:";
        const wsUrl = protocol + "//" + window.location.host + "${pageContext.request.contextPath}/ws/seats/" + showtimeId;
        
        let ws;
        function connect() {
            ws = new WebSocket(wsUrl);

            ws.onopen = function() {
                statusBadge.innerHTML = '<span class="badge bg-success"><i class="bi bi-circle-fill me-1" style="font-size:.55rem; color:#fff;"></i> Live</span>';
                addLog("System", "Live connection established successfully.");
            };

            ws.onmessage = function(event) {
                try {
                    const msg = JSON.parse(event.data);
                    const seatElement = document.getElementById("seat-" + msg.seatId);
                    if (!seatElement) return;

                    const seatLabel = seatElement.getAttribute("data-label");
                    const user = msg.username || "Customer";

                    switch(msg.action) {
                        case "SELECT":
                            if (!seatElement.classList.contains("is-booked") && !seatElement.classList.contains("is-off")) {
                                if (!seatElement.classList.contains("is-soft-locked")) {
                                    seatElement.classList.add("is-soft-locked");
                                    currentSoft++;
                                    addLog(user, "Selected (Soft locked) Seat " + seatLabel);
                                }
                            }
                            break;

                        case "DESELECT":
                            if (seatElement.classList.contains("is-soft-locked")) {
                                seatElement.classList.remove("is-soft-locked");
                                currentSoft = Math.max(0, currentSoft - 1);
                                addLog(user, "Deselected Seat " + seatLabel);
                            }
                            break;

                        case "HARD_LOCK":
                            // Chuyen soft-lock/available thanh booked
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
                            // Giai phong ghe
                            if (seatElement.classList.contains("is-booked")) {
                                seatElement.classList.remove("is-booked");
                                currentSold = Math.max(0, currentSold - 1);
                                addLog("System", "Booking expired / Cancelled. Released Seat " + seatLabel);
                            }
                            break;
                    }

                    // Update UI stats
                    soldDisplay.innerText = currentSold + " / " + totalCapacity;
                    softDisplay.innerText = currentSoft;
                    const pct = totalCapacity > 0 ? Math.round((currentSold * 100) / totalCapacity) : 0;
                    pctDisplay.innerText = pct + "%";

                } catch (e) {
                    console.error("Loi parse message WS:", e);
                }
            };

            ws.onclose = function() {
                statusBadge.innerHTML = '<span class="badge bg-danger">Disconnected</span>';
                addLog("System", "Connection lost. Reconnecting in 5 seconds...");
                setTimeout(connect, 5000);
            };

            ws.onerror = function(err) {
                console.error("Loi WebSocket:", err);
            };
        }

        connect();

        // Helper to format time
        function formatTime(d) {
            const h = String(d.getHours()).padStart(2, '0');
            const m = String(d.getMinutes()).padStart(2, '0');
            const s = String(d.getSeconds()).padStart(2, '0');
            return h + ":" + m + ":" + s;
        }

        // Helper to add log line
        function addLog(actor, message) {
            const timeStr = formatTime(new Date());
            const entry = document.createElement("div");
            entry.className = "log-entry";
            entry.innerHTML = '<span class="log-time">' + timeStr + '</span>' +
                              '<strong>[' + actor + ']</strong> ' +
                              '<span class="log-action">' + message + '</span>';
            
            // Insert at the top
            logPanel.insertBefore(entry, logPanel.firstChild);
            
            // Limit to 50 logs to keep memory clean
            if (logPanel.childNodes.length > 50) {
                logPanel.removeChild(logPanel.lastChild);
            }
        }

        // Clear logs
        document.getElementById("clearLogBtn").addEventListener("click", function() {
            logPanel.innerHTML = '<div class="log-entry"><span class="log-time">' + formatTime(new Date()) + '</span><span class="text-info">Logs cleared. Real-time stream active.</span></div>';
        });
    });
</script>
</body>
</html>
