<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Showtime Add/Edit (SRS 3.5.2.2) - lam theo man 23_mgr-showtime-edit cua
    Frontend demo prototype: 3 section (Movie & Room / Schedule / Format & Pricing)
    + cot phai Preview Customer view + Estimated revenue. Owner: HungNT.

    Dual mode: Create (UC20, khong co attribute st) / Edit (UC21, servlet set attribute st).
    Gia tri uu tien: param (sau khi POST loi) > st (GET edit) > rong (GET create).
--%>
<c:set var="editing" value="${not empty st}" />
<c:set var="vMovieId"   value="${empty param.movieId ? st.movieId : param.movieId}" />
<c:set var="vRoomId"    value="${empty param.roomId ? st.roomId : param.roomId}" />
<c:set var="vPrice"     value="${empty param.basePrice ? st.basePrice : param.basePrice}" />
<c:set var="vFormat"    value="${empty param.format ? st.format : param.format}" />
<c:set var="vSubtitle"  value="${empty param.subtitleType ? st.subtitleType : param.subtitleType}" />
<%-- LocalDateTime.toString() = "yyyy-MM-ddTHH:mm" -> cat lay date va time --%>
<c:set var="vDate" value="${empty param.date ? (editing ? fn:substring(st.startTime, 0, 10) : '') : param.date}" />
<c:set var="vTime" value="${empty param.startTime ? (editing ? fn:substring(st.startTime, 11, 16) : '') : param.startTime}" />
<c:set var="vEndTime" value="${empty param.endTime ? (editing ? fn:substring(st.endTime, 11, 16) : '') : param.endTime}" />
<c:set var="vEndMode" value="${empty param.endMode ? 'auto' : param.endMode}" />
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>${editing ? 'Edit' : 'New'} Showtime - PentaPlex Manager</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
        <style>
            .st-form .form-label {
                font-size: .82rem;
                font-weight: 600;
                color: var(--navy);
            }
            .st-form .form-control[readonly] {
                background: #f3f4f6;
                color: #374151;
                border-color: var(--lc-border);
                opacity: 1;
            }
            .st-section-title {
                font-size: 1rem;
                font-weight: 700;
                color: var(--navy);
                margin-bottom: 1rem;
            }
            .pv-poster {
                width: 64px;
                height: 96px;
                border-radius: 8px;
                flex-shrink: 0;
                background: linear-gradient(135deg, #2563eb, #1e3a5f);
                color: #fff;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 800;
                font-size: 1.5rem;
            }
            .pv-timebtn {
                border: 1px solid var(--lc-border);
                border-radius: 10px;
                text-align: center;
                padding: .6rem;
                background: #fff;
            }
            .lc-auto {
                font-size: .6rem;
                background: #EEF1F4;
                color: var(--lc-muted);
                padding: .12rem .45rem;
                border-radius: 999px;
                vertical-align: middle;
            }
            /* End-time Auto/Custom segmented toggle */
            .end-toggle {
                display: inline-flex;
                background: #eef1f4;
                border-radius: 999px;
                padding: 2px;
                gap: 2px;
            }
            .end-toggle-opt {
                border: 0;
                background: transparent;
                font-size: .66rem;
                font-weight: 700;
                letter-spacing: .02em;
                color: var(--lc-muted);
                padding: .2rem .62rem;
                border-radius: 999px;
                cursor: pointer;
                line-height: 1;
                transition: background .15s ease, color .15s ease, box-shadow .15s ease;
            }
            .end-toggle-opt:hover {
                color: var(--navy);
            }
            .end-toggle-opt.active {
                background: #fff;
                color: var(--lc-primary, #2563eb);
                box-shadow: 0 1px 2px rgba(15, 30, 54, .14);
            }
            .end-toggle-opt.active:hover {
                color: var(--lc-primary, #2563eb);
            }
        </style>
    </head>

    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="showtimes" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="container-fluid px-4 py-4" style="max-width: 1240px;">

                <%-- ===== Page header ===== --%>
                <div class="mb-3">
                    <div class="text-muted small mb-1">Dashboard / Showtimes / <span class="fw-semibold">${editing ? 'Edit' : 'New'}</span></div>
                    <h4 class="text-navy fw-bold mb-0">${editing ? 'Edit' : 'New'} Showtime</h4>
                </div>

                <%-- ===== Branch scope notice ===== --%>
                <div class="lc-scope mb-3">
                    <i class="bi bi-exclamation-triangle-fill" style="color:#cf9a00;"></i>
                    <span>Scoped to <strong><c:out value="${sessionScope.currentBranchName}" /></strong>
                        &mdash; you only see data for your assigned branch.</span>
                </div>

                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger py-2">${errorMsg}</div>
                </c:if>

                <%-- ===== Back / Cancel / Save (Save submit form qua attribute form="stForm") ===== --%>
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <a class="btn btn-light btn-sm border" href="${pageContext.request.contextPath}/branch/showtimes">
                        <i class="bi bi-arrow-left me-1"></i>Back</a>
                    <div class="d-flex gap-2">
                        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/branch/showtimes">Cancel</a>
                        <button type="submit" form="stForm" class="btn btn-primary">
                            <i class="bi bi-check-lg me-1"></i>${editing ? 'Save Changes' : 'Create Showtime'}</button>
                    </div>
                </div>

                <div class="row g-3">
                    <%-- ==================== FORM (trai) ==================== --%>
                    <div class="col-lg-8">
                        <form method="post" id="stForm"
                              action="${pageContext.request.contextPath}/branch/showtimes/${editing ? 'edit' : 'create'}"
                              class="st-form d-flex flex-column gap-3">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <c:if test="${editing}">
                                <input type="hidden" name="id" value="${st.showtimeId}">
                            </c:if>

                            <%-- ----- Movie & Room (UC19 Assign movies to rooms) ----- --%>
                            <div class="card lc-elev p-4">
                                <div class="st-section-title">Movie &amp; Room</div>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label" for="movieId">Movie <span class="text-danger">*</span></label>
                                        <select class="form-select" id="movieId" name="movieId" required>
                                            <option value="" data-duration="">-- Select movie --</option>
                                            <c:forEach var="m" items="${movies}">
                                                <option value="${m.movieId}" data-duration="${m.durationMin}"
                                                        ${vMovieId == m.movieId ? 'selected' : ''}>
                                                    <c:out value="${m.title}" /> (${m.durationMin} min)</option>
                                                </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label" for="roomId">Room <span class="text-danger">*</span></label>
                                        <select class="form-select" id="roomId" name="roomId" required>
                                            <option value="">-- Select room --</option>
                                            <c:forEach var="r" items="${rooms}">
                                                <option value="${r.roomId}" data-capacity="${r.capacity}" data-type="${r.roomType}"
                                                        ${vRoomId == r.roomId ? 'selected' : ''}>
                                                    <c:out value="${r.name}" /> (${r.roomType} &middot; ${r.capacity} seats)</option>
                                                </c:forEach>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <%-- ----- Schedule (UC20; end time auto = start + duration, SRS 3.5.2.2) ----- --%>
                            <div class="card lc-elev p-4">
                                <div class="st-section-title">Schedule</div>
                                <div class="row g-3">
                                    <div class="col-md-4">
                                        <label class="form-label" for="date">Date <span class="text-danger">*</span></label>
                                        <input type="date" class="form-control" id="date" name="date" value="${vDate}" required>
                                    </div>
                                    <div class="col-md-4">
                                        <label class="form-label" for="startTime">Start Time <span class="text-danger">*</span></label>
                                        <input type="time" class="form-control" id="startTime" name="startTime" value="${vTime}" required>
                                    </div>
                                    <div class="col-md-4">
                                        <%-- Auto: server tu tinh = start + duration. Custom: manager tu nhap (server van validate). --%>
                                        <label class="form-label d-flex align-items-center justify-content-between mb-1">
                                            <span>End Time</span>
                                            <span class="end-toggle" id="endToggle" role="group" aria-label="End time mode">
                                                <button type="button" class="end-toggle-opt active" data-mode="auto">Auto</button>
                                                <button type="button" class="end-toggle-opt" data-mode="custom">Custom</button>
                                            </span>
                                        </label>
                                        <input type="hidden" name="endMode" id="endMode" value="auto">
                                        <%-- Auto mode: readonly preview, KHONG submit --%>
                                        <input type="text" class="form-control mono" id="endTimePreview" readonly
                                               placeholder="--:--" tabindex="-1">
                                        <%-- Custom mode: editable, submit qua name=endTime --%>
                                        <input type="time" class="form-control mono d-none" id="endTimeCustom"
                                               name="endTime" value="${vEndTime}">
                                        <div class="form-text" id="endTimeHint">Calculated: start + movie duration</div>
                                    </div>
                                </div>
                            </div>

                            <%-- ----- Format & Pricing (UC39 Set ticket pricing) ----- --%>
                            <div class="card lc-elev p-4">
                                <div class="st-section-title">Format &amp; Pricing</div>

                                <label class="form-label d-block">Format <span class="text-danger">*</span></label>
                                <div class="row g-2 mb-3">
                                    <c:forEach var="f" items="${['2D','3D','IMAX']}">
                                        <div class="col-4">
                                            <input type="radio" class="btn-check" name="format" id="fmt${f}" value="${f}"
                                                   ${vFormat == f ? 'checked' : ''} required>
                                            <label class="btn lc-radio w-100" for="fmt${f}">${f}</label>
                                        </div>
                                    </c:forEach>
                                </div>

                                <label class="form-label d-block">Subtitle Type <span class="text-danger">*</span></label>
                                <div class="row g-2 mb-3">
                                    <div class="col-4">
                                        <input type="radio" class="btn-check" name="subtitleType" id="subSUB" value="SUB"
                                               ${vSubtitle == 'SUB' ? 'checked' : ''} required>
                                        <label class="btn lc-radio w-100" for="subSUB">Subtitled</label>
                                    </div>
                                    <div class="col-4">
                                        <input type="radio" class="btn-check" name="subtitleType" id="subDUB" value="DUB"
                                               ${vSubtitle == 'DUB' ? 'checked' : ''}>
                                        <label class="btn lc-radio w-100" for="subDUB">Dubbed</label>
                                    </div>
                                    <div class="col-4">
                                        <input type="radio" class="btn-check" name="subtitleType" id="subORIGINAL" value="ORIGINAL"
                                               ${vSubtitle == 'ORIGINAL' ? 'checked' : ''}>
                                        <label class="btn lc-radio w-100" for="subORIGINAL">Original</label>
                                    </div>
                                </div>

                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label" for="basePrice">Base Price (VND) <span class="text-danger">*</span></label>
                                        <input type="number" class="form-control" id="basePrice" name="basePrice"
                                               min="10000" max="500000" step="1000" value="${vPrice}"
                                               placeholder="e.g. 90000" required>
                                        <div class="form-text">Range: 10,000 &ndash; 500,000 VND.
                                            Suggested &mdash; Standard: 80,000 &middot; VIP: 120,000 &middot; IMAX: 100,000</div>
                                    </div>
                                </div>
                            </div>
                        </form>
                    </div>

                    <%-- ==================== PREVIEW (phai) ==================== --%>
                    <div class="col-lg-4">
                        <div class="card lc-elev p-4" style="position:sticky; top:16px;">
                            <h6 class="text-navy fw-bold mb-3">Preview &middot; Customer view</h6>
                            <div class="border rounded-3 p-3 mb-3" style="border-color:var(--lc-border)!important;">
                                <div class="d-flex gap-3 align-items-start mb-2">
                                    <div class="pv-poster" id="pvPoster">?</div>
                                    <div style="min-width:0;">
                                        <div class="text-navy fw-bold" id="pvTitle">Select a movie</div>
                                        <div class="text-muted small" id="pvDuration">&nbsp;</div>
                                    </div>
                                </div>
                                <div class="text-muted small mb-2" id="pvRoomLine">&nbsp;</div>
                                <div class="pv-timebtn">
                                    <div class="fw-bold mono" style="color:var(--lc-primary);" id="pvTime">--:--</div>
                                    <div class="text-muted small" id="pvPrice">&mdash;</div>
                                </div>
                            </div>

                            <h6 class="text-navy fw-bold mb-2">Estimated revenue</h6>
                            <%-- Uoc tinh tu chinh form nay (gia x suc chua), KHONG phai so lieu he thong --%>
                            <div class="d-flex justify-content-between small py-1">
                                <span class="text-muted">If 50% occupancy</span>
                                <span class="fw-bold text-navy" id="rev50">&mdash;</span>
                            </div>
                            <div class="d-flex justify-content-between small py-1">
                                <span class="text-muted">If 80% occupancy</span>
                                <span class="fw-bold text-navy" id="rev80">&mdash;</span>
                            </div>
                            <div class="d-flex justify-content-between small py-1" style="border-top:1px solid var(--lc-border);">
                                <span class="text-muted">If full (100%)</span>
                                <span class="fw-bold text-navy" id="rev100">&mdash;</span>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            // UX only: preview end time / customer view / uoc tinh doanh thu tu input.
            // Validation that su nam o SERVER (ShowtimeFormHelper).
            (function () {
                var movieSel = document.getElementById('movieId');
                var roomSel = document.getElementById('roomId');
                var dateInp = document.getElementById('date');
                var timeInp = document.getElementById('startTime');
                var priceInp = document.getElementById('basePrice');
                var endPrev = document.getElementById('endTimePreview');
                var endHint = document.getElementById('endTimeHint');
                var endMode = document.getElementById('endMode');
                var endCustom = document.getElementById('endTimeCustom');
                var toggleBtns = document.querySelectorAll('.end-toggle-opt');

                var autoEndHHMM = '';   // computed start + duration (pure HH:MM, no +1 day)
                var autoCrossDay = false;

                // Prevent selecting past dates from date picker
                dateInp.min = new Date().toISOString().slice(0, 10);

                function fmtVND(n) {
                    return n.toLocaleString('en-US') + ' VND';
                }

                function selectedFormat() {
                    var el = document.querySelector('input[name="format"]:checked');
                    return el ? el.value : '';
                }
                function selectedSubtitle() {
                    var el = document.querySelector('input[name="subtitleType"]:checked');
                    if (!el)
                        return '';
                    return el.value === 'SUB' ? 'Subtitled' : (el.value === 'DUB' ? 'Dubbed' : 'Original');
                }

                function update() {
                    var mOpt = movieSel.options[movieSel.selectedIndex];
                    var rOpt = roomSel.options[roomSel.selectedIndex];
                    var duration = mOpt ? parseInt(mOpt.getAttribute('data-duration'), 10) : NaN;
                    var capacity = rOpt ? parseInt(rOpt.getAttribute('data-capacity'), 10) : NaN;
                    var price = parseInt(priceInp.value, 10);

                    // --- Auto end time (start + duration) ---
                    if (!isNaN(duration) && timeInp.value) {
                        var p = timeInp.value.split(':');
                        var total = parseInt(p[0], 10) * 60 + parseInt(p[1], 10) + duration;
                        var h = Math.floor(total / 60) % 24, mm = total % 60;
                        autoEndHHMM = String(h).padStart(2, '0') + ':' + String(mm).padStart(2, '0');
                        autoCrossDay = total >= 1440;
                        endPrev.value = autoEndHHMM + (autoCrossDay ? ' (+1 day)' : '');
                    } else {
                        autoEndHHMM = '';
                        autoCrossDay = false;
                        endPrev.value = '';
                    }

                    // Hint depends on the active mode
                    if (endMode.value === 'custom') {
                        endHint.textContent = isNaN(duration)
                                ? 'Custom — set the end time manually'
                                : 'Custom — must be ≥ ' + duration + ' min after start';
                    } else {
                        endHint.textContent = isNaN(duration)
                                ? 'Calculated: start + movie duration'
                                : 'Calculated: start + ' + duration + ' min';
                    }

                    // --- Customer view ---
                    var title = mOpt && mOpt.value ? mOpt.text.replace(/\s*\(\d+ min\)$/, '') : 'Select a movie';
                    document.getElementById('pvTitle').textContent = title;
                    document.getElementById('pvPoster').textContent = title.charAt(0).toUpperCase();
                    document.getElementById('pvDuration').innerHTML =
                            isNaN(duration) ? '&nbsp;' : duration + ' min';
                    var roomName = rOpt && rOpt.value ? rOpt.text.replace(/\s*\(.*\)$/, '') : '';
                    var line = [roomName, [selectedFormat(), selectedSubtitle()].filter(Boolean).join(' ')]
                            .filter(Boolean).join(' · ');
                    document.getElementById('pvRoomLine').innerHTML = line || '&nbsp;';
                    var endShown = endMode.value === 'custom' ? endCustom.value : autoEndHHMM;
                    document.getElementById('pvTime').textContent =
                            timeInp.value ? (timeInp.value + (endShown ? ' – ' + endShown : '')) : '--:--';
                    document.getElementById('pvPrice').innerHTML = isNaN(price) ? '&mdash;' : fmtVND(price);

                    // --- Estimated revenue (price x capacity x %) ---
                    var ok = !isNaN(price) && !isNaN(capacity);
                    document.getElementById('rev50').innerHTML = ok ? fmtVND(Math.round(price * capacity * 0.5)) : '&mdash;';
                    document.getElementById('rev80').innerHTML = ok ? fmtVND(Math.round(price * capacity * 0.8)) : '&mdash;';
                    document.getElementById('rev100').innerHTML = ok ? fmtVND(price * capacity) : '&mdash;';
                }

                // Switch between Auto (readonly preview) and Custom (editable) end time
                function setMode(mode) {
                    endMode.value = mode;
                    toggleBtns.forEach(function (b) {
                        b.classList.toggle('active', b.getAttribute('data-mode') === mode);
                    });
                    if (mode === 'custom') {
                        endPrev.classList.add('d-none');
                        endCustom.classList.remove('d-none');
                        // Seed with the auto value the first time, so manager edits from a sane start
                        if (!endCustom.value && autoEndHHMM) {
                            endCustom.value = autoEndHHMM;
                        }
                    } else {
                        endCustom.classList.add('d-none');
                        endPrev.classList.remove('d-none');
                    }
                    update();
                }
                toggleBtns.forEach(function (b) {
                    b.addEventListener('click', function () {
                        setMode(b.getAttribute('data-mode'));
                    });
                });

                ['change', 'input'].forEach(function (ev) {
                    movieSel.addEventListener(ev, update);
                    roomSel.addEventListener(ev, update);
                    timeInp.addEventListener(ev, update);
                    priceInp.addEventListener(ev, update);
                    endCustom.addEventListener(ev, update);
                });
                document.querySelectorAll('input[name="format"], input[name="subtitleType"]')
                        .forEach(function (el) {
                            el.addEventListener('change', update);
                        });

                // ----- Initial mode -----
                update(); // compute autoEndHHMM first
                var EDITING = ${editing};
                var POST_MODE = "${vEndMode}";          // 'custom' if a failed POST carried it
                var EXISTING_END = "${vEndTime}";       // edit prefill
                var hasPostMode = ${not empty param.endMode};
                if (hasPostMode) {
                    setMode(POST_MODE === 'custom' ? 'custom' : 'auto');
                } else if (EDITING && EXISTING_END && EXISTING_END !== autoEndHHMM) {
                    // Existing end differs from auto → it was set as custom
                    endCustom.value = EXISTING_END;
                    setMode('custom');
                } else {
                    setMode('auto');
                }
            })();
        </script>
    </body>
</html>
