<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    Manage Seat Types (Feature 3) - owner: HungNT.
    Branch Manager phan loai ghe STANDARD / VIP theo phong.

    Pham vi feature nay = CHI seat_type (STANDARD | VIP).
    Ghe bao tri (active=false) hien READ-ONLY mau xam - viec bat/tat thuoc
    feature "Seat maintenance status" (HoangHM), KHONG sua o man nay.

    Console layout dung chung _sidebar.jsp + manager.css voi Showtime Management.
--%>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Seat Types - MBCMS Manager</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            /* ===== Kich thuoc ghe dung chung header + cac hang (de cot thang cot) ===== */
            :root {
                --seat-w: 34px; --seat-h: 32px; --seat-gap: 7px;
                --aisle-w: 30px; --rl-w: 24px;
            }

            /* ===== Man chieu (curved screen + glow) ===== */
            .screen-wrap { margin: 6px 0 26px; }
            .screen-curve {
                height: 26px; margin: 0 auto; max-width: 80%;
                border-top: 3px solid #93b4f6;
                border-radius: 50% / 26px 26px 0 0;
                background: linear-gradient(to bottom, rgba(37, 99, 235, .14), rgba(37, 99, 235, 0));
            }
            .screen-label {
                text-align: center; font-size: .68rem; color: var(--lc-muted);
                letter-spacing: .35em; margin-top: 6px; font-weight: 600;
            }

            /* ===== So do ghe ===== */
            .seat-map { display: inline-block; text-align: left; }
            .seat-header, .seat-row { display: flex; align-items: center; gap: var(--seat-gap); }
            .seat-row { margin-bottom: var(--seat-gap); }
            .row-label {
                width: var(--rl-w); font-size: .72rem; font-weight: 700; color: var(--lc-muted);
                text-align: center; flex-shrink: 0;
            }
            .col-num {
                width: var(--seat-w); font-size: .68rem; font-weight: 600; color: #94a3b8;
                text-align: center; flex-shrink: 0;
            }
            .aisle { width: var(--aisle-w); flex-shrink: 0; }

            .seat-cell {
                width: var(--seat-w); height: var(--seat-h); font-size: .66rem; font-weight: 700;
                border-radius: 8px 8px 5px 5px; border: 1.6px solid transparent;
                cursor: pointer; padding: 0; flex-shrink: 0; background: #fff; color: #0369a1;
                transition: transform .08s ease, box-shadow .12s ease, background .12s ease;
                position: relative;
            }
            .seat-cell:hover:not(.type-OFF) { transform: translateY(-2px); }
            /* STANDARD = xanh nhat, VIP = vang (dong bo legend man dat ve) */
            .type-STANDARD { background: #f0f7ff; border-color: #7cb0f5; color: #1d4ed8; }
            .type-VIP      { background: #fef3c7; border-color: #f59e0b; color: #92400e; }
            /* Ghe bao tri (active=false): xam, read-only - KHONG chon duoc */
            .type-OFF {
                background: #f1f3f5; border-color: #d1d5db; color: #adb5bd;
                cursor: not-allowed;
            }
            /* Dang duoc chon (multi-select) */
            .seat-cell.selected {
                box-shadow: 0 0 0 3px rgba(37, 99, 235, .35);
                transform: translateY(-2px);
            }

            /* ===== Toolbar trong card ===== */
            .seg { display: inline-flex; border: 1px solid var(--lc-border); border-radius: 9px; overflow: hidden; }
            .seg input { position: absolute; opacity: 0; pointer-events: none; }
            .seg label {
                padding: .32rem .85rem; font-size: .82rem; font-weight: 600; cursor: pointer;
                color: #0f1e36; margin: 0; display: inline-flex; align-items: center; gap: .35rem;
                background: #fff; transition: background .12s, color .12s;
            }
            .seg label .dot { width: 11px; height: 11px; border-radius: 3px; border: 1.5px solid; }
            .seg input:checked + label { background: var(--lc-primary); color: #fff; }
            .seg input:checked + label .dot { border-color: #fff !important; }

            .link-btn { background: none; border: none; color: var(--lc-primary); font-size: .82rem; font-weight: 600; padding: 0; }
            .link-btn:hover { text-decoration: underline; }

            /* ===== Legend ===== */
            .legend-item { display: flex; align-items: center; gap: 7px; font-size: .8rem; color: #475569; }
            .legend-box  { width: 20px; height: 18px; border-radius: 4px; border: 1.6px solid; }

            /* ===== Summary panel ===== */
            .sum-panel { position: sticky; top: 18px; }
            .sum-row { display: flex; align-items: center; justify-content: space-between; padding: .5rem 0; }
            .sum-row + .sum-row { border-top: 1px solid var(--lc-border); }
            .sum-label { display: flex; align-items: center; gap: 8px; font-size: .9rem; color: #334155; }
            .sum-dot { width: 12px; height: 12px; border-radius: 4px; border: 1.6px solid; flex-shrink: 0; }
            .sum-val { font-weight: 700; font-size: 1rem; color: #0f1e36; }
            .info-box {
                background: var(--lc-light); border: 1px solid #cfe0fb; color: #1e40af;
                border-radius: 10px; padding: .6rem .75rem; font-size: .78rem; line-height: 1.4;
                display: flex; gap: .5rem;
            }
        </style>
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="rooms" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1180px;">

                <%-- ===== Page header ===== --%>
                <div class="mb-3">
                    <div class="text-muted small mb-1">Dashboard / Rooms &amp; Seats / Seat Types</div>
                    <h4 class="text-navy fw-bold mb-0">Manage Seat Types</h4>
                </div>

                <%-- ===== Branch scope notice ===== --%>
                <div class="lc-scope mb-3">
                    <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
                    <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}" /></strong>
                        &mdash; you only see data for your assigned branch.</span>
                </div>

                <c:if test="${not empty successMsg}">
                    <div class="alert alert-success py-2"><i class="bi bi-check-circle"></i> ${successMsg}</div>
                </c:if>
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger py-2"><i class="bi bi-exclamation-circle"></i> ${errorMsg}</div>
                </c:if>

                <%-- ===== Room picker ===== --%>
                <form method="get" action="${pageContext.request.contextPath}/branch/seats"
                      class="d-flex align-items-center gap-2 mb-3">
                    <label class="fw-semibold mb-0">Room:</label>
                    <select name="roomId" class="form-select form-select-sm" style="max-width:280px;"
                            onchange="this.form.submit()">
                        <option value="">-- Select a room --</option>
                        <c:forEach var="r" items="${rooms}">
                            <option value="${r.roomId}" ${selectedRoomId == r.roomId ? 'selected' : ''}>
                                <c:out value="${r.name}" /> (<c:out value="${r.roomType}" />)
                            </option>
                        </c:forEach>
                    </select>
                </form>

                <c:choose>
                    <%-- ===== Da chon phong hop le: hien so do ghe + summary ===== --%>
                    <c:when test="${not empty seatsByRow}">
                        <form id="seatForm" method="post"
                              action="${pageContext.request.contextPath}/branch/seats">
                            <input type="hidden" name="roomId" value="${selectedRoomId}">

                            <div class="row g-3">

                                <%-- ===== Cot trai: so do ghe ===== --%>
                                <div class="col-lg-8">
                                    <div class="lc-elev">
                                        <div class="card-body p-4">

                                            <%-- Toolbar: chon tool + apply + select all/clear --%>
                                            <div class="d-flex flex-wrap align-items-center gap-3 mb-3 pb-3"
                                                 style="border-bottom:1px solid var(--lc-border);">
                                                <span class="fw-semibold small text-muted">Apply to selected:</span>
                                                <div class="seg">
                                                    <input type="radio" name="tool" id="toolStd" value="STANDARD" checked>
                                                    <label for="toolStd"><span class="dot" style="background:#f0f7ff;border-color:#7cb0f5;"></span>Standard</label>
                                                    <input type="radio" name="tool" id="toolVip" value="VIP">
                                                    <label for="toolVip"><span class="dot" style="background:#fef3c7;border-color:#f59e0b;"></span>VIP</label>
                                                </div>
                                                <button type="button" id="btnApply" class="btn btn-primary btn-sm px-3"
                                                        onclick="applyTool()" disabled>
                                                    <i class="bi bi-check2"></i> Apply (<span id="selCount">0</span>)
                                                </button>
                                                <button type="button" class="link-btn ms-1" onclick="selectAll()">Select all</button>
                                                <button type="button" class="link-btn" onclick="clearSel()">Clear</button>
                                                <span class="text-muted small ms-auto">
                                                    <i class="bi bi-info-circle"></i> Click seats to multi-select, then apply.
                                                </span>
                                            </div>

                                            <%-- Man chieu --%>
                                            <div class="screen-wrap">
                                                <div class="screen-curve"></div>
                                                <div class="screen-label">SCREEN</div>
                                            </div>

                                            <%-- So do ghe (header cot + cac hang do JS dung) --%>
                                            <div class="text-center" style="overflow-x:auto;">
                                                <div class="seat-map" id="seatMap">
                                                    <div class="seat-header" id="seatHeader"></div>
                                                    <c:forEach var="rowEntry" items="${seatsByRow}">
                                                        <div class="seat-row" data-row="${rowEntry.key}">
                                                            <span class="row-label">${rowEntry.key}</span>
                                                            <c:forEach var="seat" items="${rowEntry.value}">
                                                                <button type="button"
                                                                        class="seat-cell type-${seat.active ? seat.seatType : 'OFF'}"
                                                                        data-seat-id="${seat.seatId}"
                                                                        data-col="${seat.colNumber}"
                                                                        data-active="${seat.active}"
                                                                        title="${rowEntry.key}${seat.colNumber}${seat.active ? '' : ' (maintenance)'}"
                                                                        onclick="toggleSeat(this)">
                                                                    ${seat.colNumber}
                                                                </button>
                                                                <input type="hidden" id="ht_${seat.seatId}"
                                                                       name="type_${seat.seatId}"
                                                                       value="${seat.seatType}"
                                                                       data-initial="${seat.seatType}">
                                                            </c:forEach>
                                                            <span class="row-label">${rowEntry.key}</span>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </div>

                                            <%-- Chu thich --%>
                                            <div class="d-flex flex-wrap gap-4 mt-4 pt-3"
                                                 style="border-top:1px solid var(--lc-border);">
                                                <div class="legend-item">
                                                    <div class="legend-box" style="background:#f0f7ff;border-color:#7cb0f5;"></div>Standard
                                                </div>
                                                <div class="legend-item">
                                                    <div class="legend-box" style="background:#fef3c7;border-color:#f59e0b;"></div>VIP
                                                </div>
                                                <div class="legend-item">
                                                    <div class="legend-box" style="background:#f1f3f5;border-color:#d1d5db;"></div>Maintenance (read-only)
                                                </div>
                                            </div>

                                        </div>
                                    </div>
                                </div>

                                <%-- ===== Cot phai: Summary ===== --%>
                                <div class="col-lg-4">
                                    <div class="lc-elev sum-panel">
                                        <div class="card-body p-4">
                                            <h6 class="fw-bold text-navy mb-3">Summary</h6>

                                            <div class="sum-row">
                                                <span class="sum-label">Total seats</span>
                                                <span class="sum-val">${totalSeats}</span>
                                            </div>
                                            <div class="sum-row">
                                                <span class="sum-label">
                                                    <span class="sum-dot" style="background:#f0f7ff;border-color:#7cb0f5;"></span>Standard
                                                </span>
                                                <span class="sum-val" id="cntStandard">0</span>
                                            </div>
                                            <div class="sum-row">
                                                <span class="sum-label">
                                                    <span class="sum-dot" style="background:#fef3c7;border-color:#f59e0b;"></span>VIP
                                                </span>
                                                <span class="sum-val" id="cntVip">0</span>
                                            </div>
                                            <div class="sum-row">
                                                <span class="sum-label">
                                                    <span class="sum-dot" style="background:#f1f3f5;border-color:#d1d5db;"></span>Maintenance
                                                </span>
                                                <span class="sum-val text-muted" id="cntOff">0</span>
                                            </div>

                                            <div class="info-box mt-3">
                                                <i class="bi bi-info-circle-fill"></i>
                                                <span>Selecting seats applies the current tool (Standard / VIP).
                                                    Maintenance seats are managed separately and can't be changed here.</span>
                                            </div>

                                            <div class="d-grid gap-2 mt-3">
                                                <button type="submit" id="btnSave" class="btn btn-primary" disabled>
                                                    <i class="bi bi-save"></i> Save changes
                                                    <span id="dirtyNote"></span>
                                                </button>
                                                <a class="btn btn-outline-secondary"
                                                   href="${pageContext.request.contextPath}/branch/seats?roomId=${selectedRoomId}">
                                                    <i class="bi bi-arrow-counterclockwise"></i> Reset</a>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                            </div>
                        </form>
                    </c:when>

                    <%-- ===== Chua chon phong ===== --%>
                    <c:when test="${empty selectedRoomId}">
                        <div class="lc-elev">
                            <div class="card-body text-muted text-center py-5">
                                <i class="bi bi-grid-3x3-gap" style="font-size:2.4rem;color:#cbd5e1;"></i>
                                <div class="mt-2">Select a room to classify its seats.</div>
                            </div>
                        </div>
                    </c:when>
                </c:choose>

            </div>
        </main>

        <script>
            // ====== State ======
            const selected = new Set(); // seatId dang chon

            // ====== Build column header + aisle (lay tu hang rong nhat) ======
            function buildLayout() {
                const rows = Array.from(document.querySelectorAll('.seat-row'));
                if (!rows.length) return;

                // Tap hop tat ca so cot, sap tang dan.
                const colSet = new Set();
                rows.forEach(r => r.querySelectorAll('.seat-cell').forEach(b => colSet.add(+b.dataset.col)));
                const cols = Array.from(colSet).sort((a, b) => a - b);
                if (!cols.length) return;

                // Loi di o giua: cot cuoi cua nua trai.
                const aisleAfter = cols[Math.ceil(cols.length / 2) - 1];

                // Header so cot.
                const header = document.getElementById('seatHeader');
                header.innerHTML = '<span class="row-label"></span>';
                cols.forEach(c => {
                    if (c === aisleAfter + 1) header.insertAdjacentHTML('beforeend', '<span class="aisle"></span>');
                    header.insertAdjacentHTML('beforeend', '<span class="col-num">' + c + '</span>');
                });
                header.insertAdjacentHTML('beforeend', '<span class="row-label"></span>');

                // Chen loi di vao moi hang truoc ghe dau tien cua nua phai.
                rows.forEach(r => {
                    const seats = r.querySelectorAll('.seat-cell');
                    for (const b of seats) {
                        if (+b.dataset.col === aisleAfter + 1) {
                            const sp = document.createElement('span');
                            sp.className = 'aisle';
                            r.insertBefore(sp, b);
                            break;
                        }
                    }
                });
            }

            // ====== Chon / bo chon 1 ghe (bo qua ghe bao tri) ======
            function toggleSeat(btn) {
                if (btn.dataset.active !== 'true') return; // ghe bao tri: read-only
                const id = btn.dataset.seatId;
                if (selected.has(id)) { selected.delete(id); btn.classList.remove('selected'); }
                else { selected.add(id); btn.classList.add('selected'); }
                refreshApply();
            }

            function selectAll() {
                document.querySelectorAll('.seat-cell').forEach(b => {
                    if (b.dataset.active === 'true') { selected.add(b.dataset.seatId); b.classList.add('selected'); }
                });
                refreshApply();
            }

            function clearSel() {
                document.querySelectorAll('.seat-cell.selected').forEach(b => b.classList.remove('selected'));
                selected.clear();
                refreshApply();
            }

            // ====== Ap loai ghe (tool) cho cac ghe dang chon ======
            function applyTool() {
                if (!selected.size) return;
                const tool = document.querySelector('input[name="tool"]:checked').value;
                selected.forEach(id => {
                    const input = document.getElementById('ht_' + id);
                    input.value = tool;
                    const btn = document.querySelector('.seat-cell[data-seat-id="' + id + '"]');
                    btn.classList.remove('type-STANDARD', 'type-VIP');
                    btn.classList.add('type-' + tool);
                });
                clearSel();
                recount();
                updateDirty();
            }

            // ====== Cap nhat nut Apply (so ghe dang chon) ======
            function refreshApply() {
                document.getElementById('selCount').textContent = selected.size;
                document.getElementById('btnApply').disabled = selected.size === 0;
            }

            // ====== Dem lai Standard / VIP / Maintenance tu hidden input + trang thai ghe ======
            function recount() {
                let std = 0, vip = 0, off = 0;
                document.querySelectorAll('.seat-cell').forEach(b => {
                    if (b.dataset.active !== 'true') { off++; return; }
                    const v = document.getElementById('ht_' + b.dataset.seatId).value;
                    if (v === 'VIP') vip++; else std++;
                });
                document.getElementById('cntStandard').textContent = std;
                document.getElementById('cntVip').textContent = vip;
                document.getElementById('cntOff').textContent = off;
            }

            // ====== Bat/tat nut Save theo so ghe thuc su doi loai (dirty) ======
            function updateDirty() {
                let changed = 0;
                document.querySelectorAll('input[id^="ht_"]').forEach(i => {
                    if (i.value !== i.dataset.initial) changed++;
                });
                const save = document.getElementById('btnSave');
                save.disabled = changed === 0;
                document.getElementById('dirtyNote').textContent = changed ? ' (' + changed + ')' : '';
            }

            document.addEventListener('DOMContentLoaded', function () {
                buildLayout();
                recount();
                updateDirty();
            });
        </script>
    </body>
</html>
