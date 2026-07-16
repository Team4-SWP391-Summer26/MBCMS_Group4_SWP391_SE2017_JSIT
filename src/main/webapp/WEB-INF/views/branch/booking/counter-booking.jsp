<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Counter Booking - PentaPlex Staff</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>

        <style>
            /* Counter booking wizard — page-specific */
            .lc-wizard .wizard-steps {
                display: flex;
                justify-content: space-between;
                position: relative;
                max-width: 900px;
                margin: 0 auto;
            }

            .wizard-steps::before {
                content: '';
                position: absolute;
                top: 20px;
                left: 8.33%;
                right: 8.33%;
                height: 3px;
                background: var(--lc-border);
                z-index: 1;
                border-radius: 999px;
            }

            /* Progress fill chạy theo bước hiện tại (H2) */
            .wizard-steps::after {
                content: '';
                position: absolute;
                top: 20px;
                left: 8.33%;
                width: var(--wizard-progress, 0%);
                height: 3px;
                background: #10b981;
                z-index: 1;
                border-radius: 999px;
                transition: width .3s ease;
            }

            .wizard-step {
                position: relative;
                z-index: 2;
                text-align: center;
                flex: 1;
            }

            .step-num {
                width: 40px;
                height: 40px;
                border-radius: 50%;
                background: #ffffff;
                border: 3px solid var(--lc-border);
                color: var(--lc-muted);
                font-weight: 700;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 8px;
                transition: all 0.25s ease;
            }

            .step-label {
                font-size: 0.8rem;
                font-weight: 600;
                color: var(--lc-muted);
                transition: color 0.25s ease;
            }

            .wizard-step.active .step-num {
                border-color: var(--lc-primary);
                background: var(--lc-primary);
                color: #ffffff;
                box-shadow: 0 0 12px rgba(37, 99, 235, 0.35);
            }

            .wizard-step.active .step-label {
                color: var(--lc-navy);
                font-weight: 700;
            }

            .wizard-step.completed .step-num {
                border-color: #10b981;
                background: #10b981;
                color: #ffffff;
            }

            .wizard-step.completed .step-label {
                color: #10b981;
            }

            :root {
                /* --bk-* / --lc-* color tokens come from tokens.css */
                --seat-w:34px; --seat-h:32px; --seat-gap:7px; --aisle-w:30px; --rl-w:24px;
            }

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
            .seat-available { background:#f0f7ff; border-color:#7cb0f5; color:#1d4ed8; }
            .seat-available:hover { background:#dbeafe; box-shadow:0 0 0 3px rgba(37,99,235,.25); transform:translateY(-2px); }
            /* Bạn đang chọn */
            .seat-selected { background:#16a34a !important; border-color:#15803d !important; color:#fff !important;
                box-shadow:0 0 0 3px rgba(22,163,74,.30); }
            /* Người khác đang chọn (soft-lock) */
            .seat-soft-locked { background:#fef3c7; border-color:#f59e0b; color:#92400e; cursor:not-allowed;
                animation:soft-pulse 1.8s ease-in-out infinite; }
            @keyframes soft-pulse { 0%,100%{box-shadow:0 0 0 2px rgba(245,158,11,.4);} 50%{box-shadow:0 0 0 5px rgba(245,158,11,0);} }
            /* Đã đặt */
            .seat-booked { background:#fee2e2; border-color:#fca5a5; color:#b91c1c; cursor:not-allowed; opacity:.85; }
            /* Bảo trì - dau X */
            .seat-maintenance { background:#f3f4f6; border-color:#d1d5db; color:#9ca3af; cursor:not-allowed; }
            .seat-maintenance i { font-size:.85rem; }
            /* VIP (con trong) - vang */
            .seat-VIP.seat-available { background:#fef3c7; border-color:#f59e0b; color:#92400e; }
            .seat-VIP.seat-available:hover { background:#fde68a; }
            .seat-VIP.seat-booked { background:#fde8d8; border-color:#fb923c; color:#9a3412; }

            /* ── Global Styles & Overrides ──────────────────────── */
            body {
                background-color: #F8FAFC !important;
            }
            .lc-elev {
                background: rgba(255, 255, 255, 0.9) !important;
                backdrop-filter: blur(12px);
                border: 1px solid rgba(226, 232, 240, 0.8) !important;
                border-radius: 16px !important;
                box-shadow: 0 8px 30px rgba(15, 23, 42, 0.03), 0 1px 3px rgba(15, 23, 42, 0.01) !important;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .showtime-card {
                border: 2px solid var(--lc-border);
                border-radius: var(--radius-lg);
                cursor: pointer;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                background: #ffffff;
            }
            .showtime-card:hover {
                border-color: var(--lc-primary);
                box-shadow: 0 10px 25px -5px rgba(15, 23, 42, 0.08);
                transform: translateY(-2px);
            }
            .showtime-card.selected {
                border-color: var(--lc-primary);
                background: var(--primary-50) !important;
                box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.15);
                transform: translateY(-2px);
            }

            /* F&B Custom Card Styles */
            .food-card {
                display: flex;
                flex-direction: column;
                border: 1px solid var(--lc-border);
                border-radius: var(--radius-lg);
                overflow: hidden;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                background: #fff;
                position: relative;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02);
                height: 100%;
            }
            .food-card:hover {
                border-color: rgba(37, 99, 235, 0.2) !important;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05);
                transform: translateY(-6px);
            }
            .food-card.added {
                border-color: var(--lc-primary) !important;
                border-width: 2px !important;
                box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.15);
            }

            .drink-red { --item-theme: #dc2626; --item-bg: rgba(220, 38, 38, 0.08); --item-gradient: linear-gradient(135deg, rgba(220, 38, 38, 0.1) 0%, rgba(220, 38, 38, 0.01) 100%); }
            .drink-cyan { --item-theme: #0284c7; --item-bg: rgba(2, 132, 199, 0.08); --item-gradient: linear-gradient(135deg, rgba(2, 132, 199, 0.1) 0%, rgba(2, 132, 199, 0.01) 100%); }
            .snack-orange { --item-theme: #ea580c; --item-bg: rgba(234, 88, 12, 0.08); --item-gradient: linear-gradient(135deg, rgba(234, 88, 12, 0.1) 0%, rgba(234, 88, 12, 0.01) 100%); }
            .snack-yellow { --item-theme: #ca8a04; --item-bg: rgba(202, 138, 4, 0.08); --item-gradient: linear-gradient(135deg, rgba(202, 138, 4, 0.1) 0%, rgba(202, 138, 4, 0.01) 100%); }
            .combo-green { --item-theme: #059669; --item-bg: rgba(5, 150, 105, 0.08); --item-gradient: linear-gradient(135deg, rgba(5, 150, 105, 0.1) 0%, rgba(5, 150, 105, 0.01) 100%); }
            .combo-red { --item-theme: #db2777; --item-bg: rgba(219, 39, 119, 0.08); --item-gradient: linear-gradient(135deg, rgba(219, 39, 119, 0.1) 0%, rgba(219, 39, 119, 0.01) 100%); }

            .food-img-wrapper.themed {
                height: 130px;
                background: var(--item-gradient, radial-gradient(circle at 50% 50%, #ffffff 0%, #f8fafc 100%));
                color: var(--item-theme);
                display: flex;
                align-items: center;
                justify-content: center;
                border-bottom: 1px solid #f1f5f9;
                position: relative;
                overflow: hidden;
            }
            .food-card .glow-circle {
                position: absolute;
                width: 75px;
                height: 75px;
                border-radius: 50%;
                background: var(--item-bg);
                z-index: 1;
                filter: blur(14px);
                transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
            }
            .food-card:hover .glow-circle {
                transform: scale(1.3) rotate(15deg);
                filter: blur(10px);
                opacity: 0.85;
            }
            .food-img-wrapper.themed i {
                font-size: 2.4rem;
                z-index: 2;
                color: var(--item-theme);
                filter: drop-shadow(0 4px 6px rgba(0,0,0,0.04));
                transition: all 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
            }
            .food-card:hover .themed i {
                transform: scale(1.18) translateY(-4px) rotate(4deg);
                filter: drop-shadow(0 8px 16px rgba(0,0,0,0.08));
            }
            .food-info {
                padding: 1.2rem;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                flex-grow: 1;
            }
            .category-tab {
                font-weight: 700;
                font-size: 1.05rem;
                color: var(--navy);
                border-bottom: 2px solid var(--lc-border);
                padding-bottom: 0.4rem;
                margin-top: 1rem;
                margin-bottom: 1rem;
            }

            .wizard-panel {
                display: none;
            }

            .wizard-panel.active {
                display: block;
            }

            /* Custom Select & Date styling */
            .form-select, .form-control {
                border-color: var(--lc-border);
                border-radius: var(--radius-md);
            }
            .form-select:focus, .form-control:focus {
                border-color: var(--lc-primary);
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
            }

            /* Overriding btn-primary-lc with premium styles */
            .btn-primary-lc {
                background-color: var(--lc-primary) !important;
                border-color: var(--lc-primary) !important;
                color: #fff !important;
                border-radius: var(--radius-lg);
                font-family: var(--font-display);
                font-weight: 700;
                letter-spacing: 0.02em;
                box-shadow: 0 4px 12px rgba(37,99,235,0.18);
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            }
            .btn-primary-lc:hover:not(:disabled) {
                transform: translateY(-1px);
                box-shadow: 0 6px 16px rgba(37,99,235,0.28);
            }
            .btn-primary-lc:active:not(:disabled) {
                transform: translateY(0);
            }
            .btn-primary-lc:disabled {
                opacity: 0.65;
                cursor: not-allowed;
            }

            /* Payment Method Card Selectors */
            .payment-method-card {
                cursor: pointer;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                border: 2px solid var(--lc-border) !important;
                border-radius: var(--radius-lg) !important;
            }
            .payment-method-card:hover {
                border-color: var(--lc-primary) !important;
                background-color: var(--lc-light) !important;
            }
            .payment-method-card.active {
                border-color: var(--lc-primary) !important;
                background-color: var(--primary-50) !important;
                box-shadow: 0 6px 15px rgba(37, 99, 235, 0.08);
            }

            /* ===== Legend ===== */
            .legend-item { display:flex; align-items:center; gap:7px; font-size:.8rem; color:#475569; }
            .legend-box { width:20px; height:18px; border-radius:5px; border:1.6px solid; flex-shrink:0; }


        </style>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
            <jsp:param name="active" value="booking" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <c:if test="${not empty err}">
                    <div class="alert alert-danger alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i>
                        <c:choose>
                            <c:when test="${err eq 'vnpay_failed'}">Payment via VNPay gateway failed or was cancelled. Seats have been released.</c:when>
                            <c:otherwise>An error occurred during processing.</c:otherwise>
                        </c:choose>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <div class="lc-page-head">
                    <div>
                        <div class="lc-page-section">Counter Operations</div>
                        <h1 class="lc-page-title">Counter Ticket Booking</h1>
                    </div>
                    <div class="lc-branch-chip">
                        <i class="bi bi-geo-alt-fill" aria-hidden="true"></i>
                        <span><c:out value="${sessionScope.currentBranchName}" /></span>
                    </div>
                </div>

                <%-- ===== Step Indicator Wizard ===== --%>
                <div class="lc-wizard wizard-steps-container">
                    <div class="wizard-steps">
                        <div class="wizard-step active" id="step-ind-1">
                            <div class="step-num">1</div>
                            <div class="step-label">Showtime</div>
                        </div>
                        <div class="wizard-step" id="step-ind-2">
                            <div class="step-num">2</div>
                            <div class="step-label">Choose Seats</div>
                        </div>
                        <div class="wizard-step" id="step-ind-3">
                            <div class="step-num">3</div>
                            <div class="step-label">Food & Drinks</div>
                        </div>
                        <div class="wizard-step" id="step-ind-4">
                            <div class="step-num">4</div>
                            <div class="step-label">Promotion</div>
                        </div>
                        <div class="wizard-step" id="step-ind-5">
                            <div class="step-num">5</div>
                            <div class="step-label">Payment</div>
                        </div>
                        <div class="wizard-step" id="step-ind-6">
                            <div class="step-num">6</div>
                            <div class="step-label">Print Ticket</div>
                        </div>
                    </div>
                </div>

                <%-- ===== STEP 1: SELECT SHOWTIME ===== --%>
                <div class="wizard-panel active" id="panel-1">
                    <div class="card lc-elev p-4">
                        <h5 class="text-navy fw-bold mb-3"><i class="bi bi-1-circle-fill text-primary me-2"></i>Select Showtime</h5>

                        <!-- Search & Filter Controls -->
                        <div class="row g-3 mb-4">
                            <div class="col-md-5">
                                <label class="form-label fw-semibold">Search Movie</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-search"></i></span>
                                    <input type="text" id="movie-search" class="form-control" placeholder="Enter movie name...">
                                </div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-semibold">Filter by Room</label>
                                <select id="room-filter" class="form-select">
                                    <option value="">All Rooms</option>
                                    <c:forEach var="r" items="${rooms}">
                                        <option value="${r.roomId}"><c:out value="${r.name}" /> (${r.roomType})</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <label class="form-label fw-semibold">Show Date</label>
                                <input type="date" id="date-filter" class="form-control">
                            </div>
                        </div>

                        <!-- Showtimes List Container -->
                        <div class="mb-4">
                            <h6 class="text-navy fw-bold mb-3 text-uppercase small" style="letter-spacing: .05em;">Available Showtimes Today</h6>
                            <div class="row g-3" id="showtimes-container">
                                <!-- Showtimes populated dynamically via JS -->
                                <div class="col-12 text-center text-muted py-5" id="showtimes-loading">
                                    <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                                    Loading showtimes...
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-end mt-4">
                            <button class="btn btn-primary-lc px-4" id="btn-to-step2" disabled>Continue to select seats <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>
                </div>

                <%-- ===== STEP 2: SELECT SEAT ===== --%>
                <div class="wizard-panel" id="panel-2">
                    <div class="card lc-elev p-4">
                        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                            <div class="d-flex align-items-center gap-2">
                                <h5 class="text-navy fw-bold mb-0"><i class="bi bi-2-circle-fill text-primary me-2"></i>Choose Seats</h5>
                                <span id="wsBadge" class="badge bg-secondary">Disconnected</span>
                                <span id="refreshBadge" class="badge bg-success" style="opacity: 0; transition: opacity 0.4s;">&#8635; Updated</span>
                            </div>
                            <div class="badge bg-primary px-3 py-2 fs-6" id="showtime-header-info"></div>
                        </div>

                        <!-- Curved Screen -->
                        <div class="screen-wrap">
                            <div class="screen-curve"></div>
                            <div class="screen-label">SCREEN</div>
                        </div>

                        <!-- Seat Map Grid -->
                        <div class="seat-grid mb-4" id="seat-map-container" style="overflow-x: auto; text-align: center;">
                            <!-- Loaded dynamically -->
                        </div>

                        <!-- Legend & Summary -->
                        <div class="row align-items-center g-3">
                            <div class="col-md-6">
                                <div class="d-flex flex-wrap gap-3 mt-2">
                                    <div class="legend-item"><div class="legend-box" style="background:#f0f7ff;border-color:#7cb0f5;"></div>Regular</div>
                                    <div class="legend-item"><div class="legend-box" style="background:#fef3c7;border-color:#f59e0b;"></div>VIP</div>
                                    <div class="legend-item"><div class="legend-box" style="background:#16a34a;border-color:#15803d;"></div>Selected</div>
                                    <div class="legend-item"><div class="legend-box" style="background:#fef3c7;border-color:#f59e0b;animation:soft-pulse 1.8s ease-in-out infinite;"></div>Held by others</div>
                                    <div class="legend-item"><div class="legend-box" style="background:#fee2e2;border-color:#fca5a5;"></div>Booked</div>
                                    <div class="legend-item"><div class="legend-box" style="background:#f3f4f6;border-color:#d1d5db;"></div>Maintenance</div>
                                </div>
                            </div>
                            <div class="col-md-6 text-end">
                                <div class="fw-semibold text-navy">Selected seats: <span id="selected-seats-display" class="text-primary font-monospace">&mdash;</span></div>
                                <div class="fs-5 fw-bold text-navy mt-1">Subtotal: <span id="subtotal-display" class="text-danger">0</span> VND</div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between mt-4">
                            <button class="btn btn-secondary px-4" onclick="goToStep(1)"><i class="bi bi-arrow-left me-1"></i> Back</button>
                            <button class="btn btn-primary-lc px-4" id="btn-to-step3" disabled>Continue <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>
                </div>

                <%-- ===== STEP 3: FOOD & DRINKS CONCESSIONS ===== --%>
                <div class="wizard-panel" id="panel-3">
                    <div class="card lc-elev p-4">
                        <h5 class="text-navy fw-bold mb-3"><i class="bi bi-3-circle-fill text-primary me-2"></i>Select Food &amp; Drinks</h5>
                        
                        <div class="row g-3 mb-4" id="staff-food-items-container" style="max-height: 450px; overflow-y: auto;">
                            <!-- Concessions will be loaded dynamically via JS -->
                            <div class="text-center py-4">
                                <div class="spinner-border text-primary" role="status"></div>
                                <div class="text-muted mt-2">Loading catalog...</div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between align-items-center mt-3 pt-3 border-top">
                            <div class="text-muted">Tickets Subtotal: <span id="staff-tickets-subtotal-display" class="fw-bold text-navy">0</span> VND</div>
                            <div class="fs-5 fw-bold text-navy">Concessions Subtotal: <span id="staff-food-subtotal-display" class="text-danger">0</span> VND</div>
                        </div>

                        <div class="d-flex justify-content-between mt-4">
                            <button class="btn btn-secondary px-4" onclick="goToStep(2)"><i class="bi bi-arrow-left me-1"></i> Back</button>
                            <button class="btn btn-primary-lc px-4" id="btn-to-step4">Continue <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>
                </div>

                <%-- ===== STEP 4: PROMOTION ===== --%>
                <div class="wizard-panel" id="panel-4">
                    <div class="card lc-elev p-4">
                        <h5 class="text-navy fw-bold mb-3"><i class="bi bi-4-circle-fill text-primary me-2"></i>Promotion &amp; Payment Details</h5>

                        <div class="row justify-content-center">
                            <!-- Promotion Details -->
                            <div class="col-md-8 col-lg-6">
                                <!-- Input container (visible when NO promo code is applied) -->
                                <div class="mb-4" id="promo-input-container">
                                    <h6 class="text-navy fw-bold mb-3 text-uppercase small">Apply Promo Code</h6>
                                    <label class="form-label fw-semibold text-muted small">Promo Code</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light border-end-0 text-muted"><i class="bi bi-tag-fill"></i></span>
                                        <input type="text" id="promo-code" class="form-control border-start-0 text-uppercase fw-bold text-primary" placeholder="Enter promo code..." style="letter-spacing: 1px;">
                                        <button class="btn btn-primary px-4 fw-semibold" type="button" id="btn-apply-promo"><i class="bi bi-check-lg me-1"></i>Apply</button>
                                    </div>
                                </div>

                                <!-- Applied container (visible when promo code IS applied) -->
                                <div class="mb-4 d-none" id="promo-applied-container">
                                    <h6 class="text-navy fw-bold mb-3 text-uppercase small"><i class="bi bi-tag text-primary me-2"></i>Promotion Code</h6>
                                    <div class="d-inline-flex align-items-center bg-success bg-opacity-10 text-success border border-success border-opacity-25 rounded px-3 py-1.5 fw-bold" style="gap: 12px; font-size: 0.95rem;">
                                        <span id="promo-badge-code" class="text-uppercase" style="letter-spacing: 0.5px;"></span>
                                        <span id="btn-remove-promo" style="cursor: pointer; line-height: 1;"><i class="bi bi-x-lg text-muted hover-danger" style="font-size: 14px;"></i></span>
                                    </div>
                                </div>

                                <div class="alert alert-success py-2 d-none" id="promo-success-alert"></div>
                                <div class="alert alert-danger py-2 d-none" id="promo-error-alert"></div>

                                <hr>

                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Ticket Subtotal:</span>
                                    <span class="fw-semibold text-navy"><span id="summary-subtotal">0</span> VND</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="text-muted">Concessions Subtotal:</span>
                                    <span class="fw-semibold text-navy"><span id="summary-food-subtotal">0</span> VND</span>
                                </div>
                                <div class="d-flex justify-content-between mb-2 text-success">
                                    <span>Discount (Tickets only):</span>
                                    <span>-<span id="summary-discount">0</span> VND</span>
                                </div>
                                <div class="d-flex justify-content-between border-top pt-2 fs-5 fw-bold text-navy">
                                    <span>Total Payment:</span>
                                    <span><span id="summary-total" class="text-danger">0</span> VND</span>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between mt-5">
                            <button class="btn btn-secondary px-4" onclick="goToStep(3)"><i class="bi bi-arrow-left me-1"></i> Back</button>
                            <button class="btn btn-primary-lc px-4" id="btn-to-step5">Continue <i class="bi bi-arrow-right ms-1"></i></button>
                        </div>
                    </div>
                </div>

                <%-- ===== STEP 5: CONFIRMATION & PAYMENT ===== --%>
                <div class="wizard-panel" id="panel-5">
                    <div class="card lc-elev p-4">
                        <h5 class="text-navy fw-bold mb-3"><i class="bi bi-5-circle-fill text-primary me-2"></i>Confirmation &amp; Payment</h5>

                        <div class="row g-4">
                            <!-- Invoice detail -->
                            <div class="col-md-7 border-end">
                                <h6 class="text-navy fw-bold mb-3 text-uppercase small">Order Details</h6>
                                <div class="table-responsive">
                                    <table class="table table-bordered">
                                        <tbody>
                                            <tr>
                                                <th class="bg-light text-navy" style="width:35%;">Movie</th>
                                                <td id="invoice-movie" class="fw-bold text-primary"></td>
                                            </tr>
                                            <tr>
                                                <th class="bg-light text-navy">Showtime</th>
                                                <td id="invoice-time"></td>
                                            </tr>
                                            <tr>
                                                <th class="bg-light text-navy">Room</th>
                                                <td id="invoice-room"></td>
                                            </tr>
                                            <tr>
                                                <th class="bg-light text-navy">Selected Seats</th>
                                                <td id="invoice-seats" class="font-monospace fw-bold text-navy"></td>
                                            </tr>
                                            <tr id="invoice-concessions-row" class="d-none">
                                                <th class="bg-light text-navy">Concessions</th>
                                                <td id="invoice-concessions" class="small text-navy"></td>
                                            </tr>
                                            <tr>
                                                <th class="bg-light text-navy">Booking Account</th>
                                                <td id="invoice-customer">Walk-in Guest (guest01)</td>
                                            </tr>
                                            <tr>
                                                <th class="bg-light text-navy">Promo Code</th>
                                                <td id="invoice-promo">&mdash;</td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <!-- Payment details calculation -->
                            <div class="col-md-5">
                                <div class="bg-light rounded-3 p-4 border text-center">
                                    <div class="text-muted small text-uppercase fw-semibold mb-1">Total Amount Due</div>
                                    <div class="fs-2 fw-bold text-danger mb-3"><span id="invoice-total">0</span> VND</div>

                                    <!-- Payment Method Selection -->
                                    <div class="mb-4 text-start">
                                        <label class="form-label fw-semibold text-navy">Payment Method</label>
                                        <div class="d-flex gap-3">
                                            <div class="form-check flex-fill p-3 payment-method-card active" style="cursor: pointer;" onclick="document.getElementById('pay-cash').click();">
                                                <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethodRadio" id="pay-cash" value="CASH" checked style="cursor: pointer;">
                                                <label class="form-check-label fw-bold text-navy" for="pay-cash" style="cursor: pointer;">
                                                    <i class="bi bi-cash-stack text-success me-1"></i> Cash
                                                </label>
                                            </div>
                                            <div class="form-check flex-fill p-3 payment-method-card" style="cursor: pointer;" onclick="document.getElementById('pay-vnpay').click();">
                                                <input class="form-check-input ms-0 me-2" type="radio" name="paymentMethodRadio" id="pay-vnpay" value="VNPAY" style="cursor: pointer;">
                                                <label class="form-check-label fw-bold text-navy" for="pay-vnpay" style="cursor: pointer;">
                                                    <img src="${pageContext.request.contextPath}/assets/img/vnpay-logo.png" alt="VNPAY" height="32" style="object-fit: contain; vertical-align: middle; margin-top: -3px;">
                                                </label>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Cash Payment Section -->
                                    <div id="cash-payment-section">
                                        <div class="mb-3 text-start">
                                            <label class="form-label fw-semibold text-navy">Cash Received (VND)</label>
                                            <input type="number" id="cash-received" class="form-control form-control-lg text-center fw-bold fs-4 text-primary" placeholder="0" min="0">
                                        </div>

                                        <div class="d-flex justify-content-between align-items-center border-top pt-3 text-start">
                                            <span class="fw-semibold text-navy">Change Due:</span>
                                            <span class="fs-4 fw-bold text-success"><span id="cash-change">0</span> VND</span>
                                        </div>

                                        <div id="cash-error" class="alert alert-warning py-2 mt-3 d-none">
                                            <i class="bi bi-exclamation-triangle-fill"></i> Insufficient cash received.
                                        </div>
                                    </div>

                                    <!-- VNPay Payment Section -->
                                    <div id="vnpay-payment-section" class="d-none text-start">
                                        <div class="alert alert-info py-3 mb-0">
                                            <i class="bi bi-info-circle-fill me-2"></i> The system will generate a VNPay payment link and redirect. Please guide the customer to scan the QR code on the payment screen.
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between mt-5">
                            <button class="btn btn-secondary px-4" onclick="goToStep(4)"><i class="bi bi-arrow-left me-1"></i> Back</button>
                            <button class="btn btn-success px-5 fw-bold fs-6" id="btn-confirm-booking" disabled>
                                <i class="bi bi-cash-stack me-2"></i>CONFIRM CASH PAYMENT
                            </button>
                        </div>
                    </div>
                </div>

                <%-- ===== STEP 6: GENERATE & PRINT TICKET ===== --%>
                <div class="wizard-panel" id="panel-6">
                    <div class="card lc-elev p-4 text-center">
                        <div class="mb-4">
                            <div class="bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width:70px;height:70px;">
                                <i class="bi bi-check-lg fs-1"></i>
                            </div>
                            <h4 class="text-success fw-bold">TRANSACTION COMPLETED SUCCESSFULLY!</h4>
                            <p class="text-muted">The order has been saved and paid successfully.</p>
                        </div>

                        <div class="row justify-content-center mb-4">
                            <div class="col-md-8 col-lg-6">
                                <div class="card border rounded-3 p-4 bg-white shadow-sm">
                                    <div class="small text-muted text-uppercase fw-semibold mb-1">Customer Booking Code</div>
                                    <h2 class="text-primary fw-bold font-monospace" id="final-booking-code"></h2>

                                    <div class="alert alert-light border my-3 py-2 small text-start">
                                        <div class="d-flex justify-content-between mb-1">
                                            <span>Movie:</span><strong id="final-movie"></strong>
                                        </div>
                                        <div class="d-flex justify-content-between mb-1">
                                            <span>Showtime:</span><strong id="final-time"></strong>
                                        </div>
                                        <div class="d-flex justify-content-between mb-1">
                                            <span>Seats:</span><strong id="final-seats"></strong>
                                        </div>
                                        <div class="d-flex justify-content-between border-top mt-1 pt-1 d-none" id="final-concessions-row">
                                            <span>Concessions:</span><strong id="final-concessions"></strong>
                                        </div>
                                    </div>

                                    <div class="d-grid gap-2">
                                        <button class="btn btn-primary btn-lg fw-bold" id="btn-print-ticket">
                                            <i class="bi bi-printer-fill me-2"></i>Print Ticket (PDF)
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <hr>

                        <div class="d-flex justify-content-center gap-3">
                            <button class="btn btn-primary-lc px-5 fw-bold" onclick="resetWizard()">
                                <i class="bi bi-plus-lg me-2"></i>NEW TRANSACTION
                            </button>
                        </div>
                    </div>
                </div>

            </div>
        </main>

        <!-- Bootstrap Bundle JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

        <!-- Wizard Core Logic -->
        <script>
                                // [Flow Step: JavaScript] Context path helper to match servlet mapping URLs dynamically
                                const contextPath = '${pageContext.request.contextPath}';
                                const CURRENT_USER = '${sessionScope.username}';

                                let ws = null;
                                let wsRetryDelay = 2000;

                                // [Flow Step: JavaScript] Client-side state machine tracker to maintain selections across wizard steps
                                let state = {
                                    currentStep: 1,
                                    showtimeId: null,
                                    basePrice: 0,
                                    movieTitle: '',
                                    startTime: '',
                                    date: '',
                                    roomName: '',
                                    roomType: '',
                                    selectedSeats: [], // Array of seat objects {seatId, rowLabel, colNumber, seatType}
                                    memberUsername: 'guest01',
                                    memberFullName: 'Walk-in Guest',
                                    memberEmail: '',
                                    promoCode: '',
                                    promoDiscount: 0,
                                    totalAmount: 0,
                                    subtotalAmount: 0,
                                    bookingCode: '',
                                    bookingId: null,
                                    foodItems: {}, // Map of foodId -> qty
                                    foodSubtotalAmount: 0
                                };

                                // DOM Input elements bindings for filtering & event actions
                                const dateFilter = document.getElementById('date-filter');
                                const movieSearch = document.getElementById('movie-search');
                                const roomFilter = document.getElementById('room-filter');
                                const showtimesContainer = document.getElementById('showtimes-container');
                                const btnToStep2 = document.getElementById('btn-to-step2');

                                // Pre-fill today's date in local YYYY-MM-DD format as a baseline filter
                                const todayStr = new Date().toISOString().split('T')[0];
                                dateFilter.value = todayStr;

                                function formatCustomerLabel() {
                                    if (state.memberUsername === 'guest01') {
                                        return 'Walk-in Guest (guest01)';
                                    }
                                    return state.memberFullName + ' (' + state.memberUsername + ')';
                                }

                                // (Customer account UI removed — counter bookings are always walk-in guest01)

                                // Init Step 1 on Load
                                document.addEventListener('DOMContentLoaded', () => {
                                    // Register Event Listeners for Filters to reload showtimes asynchronously
                                    dateFilter.addEventListener('change', loadShowtimes);
                                    movieSearch.addEventListener('input', loadShowtimes);
                                    roomFilter.addEventListener('change', loadShowtimes);

                                    // [Flow Step: JSP -> JS] Check if user was redirected from VNPay gateway return mapping
                                    const successParam = '${success}';
                                    if (successParam === '1') {
                                        state.bookingCode = '${successBookingCode}';
                                        state.bookingId = '${successBookingId}';

                                        // [Flow Step: JS -> Servlet] Fetch details of the newly paid ticket using AJAX
                                        fetch(contextPath + '/staff/booking?action=getBookingDetail&bookingId=' + state.bookingId)
                                                .then(res => res.json())
                                                .then(ticket => {
                                                    // Populate final receipt elements
                                                    document.getElementById('final-booking-code').innerText = ticket.bookingCode;
                                                    document.getElementById('final-movie').innerText = ticket.movieTitle;

                                                    // Format startTime (Jackson LocalDateTime can be serialized as array or string)
                                                    let showtimeDateStr = '';
                                                    if (ticket.startTime) {
                                                        if (Array.isArray(ticket.startTime)) {
                                                            const parts = ticket.startTime;
                                                            const year = parts[0];
                                                            const month = String(parts[1]).padStart(2, '0');
                                                            const day = String(parts[2]).padStart(2, '0');
                                                            const hour = String(parts[3]).padStart(2, '0');
                                                            const minute = String(parts[4]).padStart(2, '0');
                                                            showtimeDateStr = hour + ':' + minute + ' - ' + day + '/' + month + '/' + year;
                                                        } else {
                                                            const dt = new Date(ticket.startTime);
                                                            const pad = (n) => n.toString().padStart(2, '0');
                                                            showtimeDateStr = pad(dt.getHours()) + ':' + pad(dt.getMinutes()) + ' - ' + pad(dt.getDate()) + '/' + pad(dt.getMonth() + 1) + '/' + dt.getFullYear();
                                                        }
                                                    }
                                                    document.getElementById('final-time').innerText = showtimeDateStr;
                                                    document.getElementById('final-seats').innerText = (ticket.seatLabels || []).join(', ');

                                                    // Fetch concessions for this booking to show on the receipt screen
                                                    fetch(contextPath + '/staff/booking?action=getBookingFoodItems&bookingId=' + state.bookingId)
                                                            .then(r => r.json())
                                                            .then(foodItems => {
                                                                const concessionsList = [];
                                                                (foodItems || []).forEach(f => {
                                                                    concessionsList.push(f.name + ' x' + f.quantity);
                                                                });
                                                                const finalConRow = document.getElementById('final-concessions-row');
                                                                const finalConText = document.getElementById('final-concessions');
                                                                if (concessionsList.length > 0) {
                                                                    finalConText.innerText = concessionsList.join(', ');
                                                                    finalConRow.classList.remove('d-none');
                                                                } else {
                                                                    finalConRow.classList.add('d-none');
                                                                }
                                                                // Automatically fast-forward to Step 6 showing success details
                                                                goToStep(6);
                                                            })
                                                            .catch(e => {
                                                                console.error('Error fetching concessions:', e);
                                                                goToStep(6);
                                                            });
                                                })
                                                .catch(err => {
                                                    console.error('Error loading ticket details: ', err);
                                                    loadShowtimes();
                                                });
                                    } else {
                                        loadShowtimes();
                                    }

                                    // Register radio toggle change listeners
                                    document.querySelectorAll('input[name="paymentMethodRadio"]').forEach(r => {
                                        r.addEventListener('change', updatePaymentMethodUI);
                                    });
                                });

                                // ==========================================
                                // STEP 1: SHOWTIMES LOADING & FILTERING
                                // ==========================================
                                function loadShowtimes() {
                                    showtimesContainer.innerHTML = `
                <div class="col-12 text-center text-muted py-5">
                    <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                    Loading showtimes...
                </div>
            `;

                                    const movieVal = encodeURIComponent(movieSearch.value.trim());
                                    const dateVal = dateFilter.value;
                                    const roomVal = roomFilter.value;

                                    let url = contextPath + '/staff/booking?action=getShowtimes&date=' + dateVal;
                                    if (roomVal)
                                        url += '&roomId=' + roomVal;

                                    fetch(url)
                                            .then(res => res.json())
                                            .then(showtimes => {
                                                // Filter in JS by movie search title
                                                const query = movieSearch.value.toLowerCase().trim();
                                                const filtered = showtimes.filter(st => {
                                                    const titleMatch = st.movieTitle.toLowerCase().includes(query);
                                                    const roomMatch = !roomVal || st.roomId == roomVal;
                                                    return titleMatch && roomMatch;
                                                });

                                                if (filtered.length === 0) {
                                                    showtimesContainer.innerHTML = `
                            <div class="col-12 text-center text-muted py-5">
                                <i class="bi bi-calendar-x fs-2 d-block mb-2"></i>
                                No active showtimes match your filters.
                            </div>
                        `;
                                                    btnToStep2.disabled = true;
                                                    return;
                                                }

                                                showtimesContainer.innerHTML = '';
                                                filtered.forEach(st => {
                                                    const availableSeats = st.roomCapacity - st.bookedSeats;
                                                    const percentSold = Math.round((st.bookedSeats / st.roomCapacity) * 100);

                                                    const col = document.createElement('div');
                                                    col.className = 'col-sm-6 col-lg-4';
                                                    col.innerHTML =
                                                            '<div class="card showtime-card p-3 h-100 ' + (state.showtimeId == st.showtimeId ? 'selected' : '') + '" ' +
                                                            '     onclick="selectShowtime(this, ' + st.showtimeId + ', ' + st.basePrice + ', \'' + st.movieTitle.replace(/'/g, "\\'") + '\', \'' + st.startTime + '\', \'' + st.date + '\', \'' + st.roomName + '\', \'' + st.roomType + '\')">' +
                                                            '    <div class="d-flex justify-content-between align-items-start mb-2">' +
                                                            '        <span class="pill pill-blue">' + st.format + ' &middot; ' + st.subtitleType + '</span>' +
                                                            '        <span class="fw-bold text-danger">' + st.basePrice.toLocaleString() + ' VND</span>' +
                                                            '    </div>' +
                                                            '    <h6 class="text-navy fw-bold mb-1">' + st.movieTitle + '</h6>' +
                                                            '    <div class="small text-muted mb-2"><i class="bi bi-clock me-1"></i>' + st.startTime + ' &middot; Room: ' + st.roomName + ' (' + st.roomType + ')</div>' +
                                                            '    <div class="d-flex justify-content-between align-items-center mb-1">' +
                                                            '        <span class="small text-muted">Available: <strong>' + availableSeats + '/' + st.roomCapacity + '</strong> seats</span>' +
                                                            '        <span class="small text-muted">' + percentSold + '% sold</span>' +
                                                            '    </div>' +
                                                            '    <div class="bar-track">' +
                                                            '        <div class="bar-fill" style="width: ' + percentSold + '%; background-color: ' + (percentSold >= 90 ? '#ef4444' : 'var(--lc-primary)') + '"></div>' +
                                                            '    </div>' +
                                                            '</div>';
                                                    showtimesContainer.appendChild(col);
                                                });
                                            })
                                            .catch(err => {
                                                console.error(err);
                                                showtimesContainer.innerHTML =
                                                        '<div class="col-12 text-center text-danger py-5">' +
                                                        '    <i class="bi bi-exclamation-triangle-fill fs-2 d-block mb-2"></i>' +
                                                        '    Error loading showtimes: ' + err.message +
                                                        '</div>';
                                            });
                                }

                                function selectShowtime(element, id, basePrice, movieTitle, startTime, date, roomName, roomType) {
                                    document.querySelectorAll('.showtime-card').forEach(el => el.classList.remove('selected'));
                                    element.classList.add('selected');

                                    state.showtimeId = id;
                                    state.basePrice = basePrice;
                                    state.movieTitle = movieTitle;
                                    state.startTime = startTime;
                                    state.date = date;
                                    state.roomName = roomName;
                                    state.roomType = roomType;

                                    btnToStep2.disabled = false;
                                }

                                btnToStep2.addEventListener('click', () => {
                                    if (state.showtimeId) {
                                        // Populate Step 2 Showtime Banner
                                        document.getElementById('showtime-header-info').innerHTML =
                                                '<i class="bi bi-film me-1"></i> ' + state.movieTitle + ' &middot; ' +
                                                '<i class="bi bi-clock me-1"></i> ' + state.startTime + ' &middot; ' +
                                                '<i class="bi bi-door-closed me-1"></i> Room: ' + state.roomName;

                                        loadSeats();
                                        goToStep(2);
                                    }
                                });

                                // ==========================================
                                // STEP 2: SEATS MAP DISPLAY & SELECTION
                                // ==========================================
                                function loadSeats() {
                                    const container = document.getElementById('seat-map-container');
                                    container.innerHTML = `
                                        <div id="seatMap">
                                            <div class="seat-header"></div>
                                        </div>
                                    `;

                                    state.selectedSeats = [];
                                    document.getElementById('selected-seats-display').innerText = '—';
                                    document.getElementById('subtotal-display').innerText = '0';
                                    document.getElementById('btn-to-step3').disabled = true;

                                    const seatMapDiv = document.getElementById('seatMap');

                                    fetch(contextPath + '/staff/booking?action=getSeats&showtimeId=' + state.showtimeId)
                                            .then(res => res.json())
                                            .then(data => {
                                                // Remove existing rows (elements with class .seat-row)
                                                seatMapDiv.querySelectorAll('.seat-row').forEach(r => r.remove());

                                                const seatsByRow = data.seatsByRow;
                                                const bookedSeatIds = new Set(data.bookedSeatIds);
                                                const heldSeatIds = new Set(data.heldSeatIds || []);

                                                for (const rowLabel in seatsByRow) {
                                                    const rowDiv = document.createElement('div');
                                                    rowDiv.className = 'seat-row';
                                                    rowDiv.setAttribute('data-row', rowLabel);

                                                    // Row Label Left
                                                    const leftLabel = document.createElement('span');
                                                    leftLabel.className = 'row-label';
                                                    leftLabel.innerText = rowLabel;
                                                    rowDiv.appendChild(leftLabel);

                                                    // Row Seats
                                                    seatsByRow[rowLabel].forEach(seat => {
                                                        const seatDiv = document.createElement('button');
                                                        const isBooked = bookedSeatIds.has(seat.seatId);
                                                        const isHeld = heldSeatIds.has(seat.seatId);
                                                        const isVip = seat.seatType === 'VIP';

                                                        seatDiv.className = 'seat-btn seat-' + seat.seatType;
                                                        if (isBooked) {
                                                            seatDiv.classList.add('seat-booked');
                                                            seatDiv.disabled = true;
                                                        } else if (isHeld) {
                                                            seatDiv.classList.add('seat-soft-locked');
                                                            seatDiv.disabled = true;
                                                        } else if (!seat.active) {
                                                            seatDiv.classList.add('seat-maintenance');
                                                            seatDiv.disabled = true;
                                                        } else {
                                                            seatDiv.classList.add('seat-available');
                                                        }

                                                        if (!seat.active && !isBooked && !isHeld) {
                                                            seatDiv.innerHTML = '<i class="bi bi-x-lg"></i>';
                                                        }

                                                        seatDiv.title = seat.rowLabel + seat.colNumber + ' (' + seat.seatType + ') – '
                                                            + (isBooked ? 'BOOKED' : (isHeld ? 'HELD' : (!seat.active ? 'MAINTENANCE' : 'AVAILABLE')));

                                                        seatDiv.setAttribute('data-seat-id', seat.seatId);
                                                        seatDiv.setAttribute('data-seat-type', seat.seatType);
                                                        seatDiv.setAttribute('data-seat-label', seat.rowLabel + seat.colNumber);
                                                        seatDiv.setAttribute('data-col', seat.colNumber);

                                                        if (!isBooked && !isHeld && seat.active) {
                                                            seatDiv.addEventListener('click', () => toggleSeat(seatDiv, seat));
                                                        }
                                                        rowDiv.appendChild(seatDiv);
                                                    });

                                                    // Row Label Right
                                                    const rightLabel = document.createElement('span');
                                                    rightLabel.className = 'row-label';
                                                    rightLabel.innerText = rowLabel;
                                                    rowDiv.appendChild(rightLabel);

                                                    seatMapDiv.appendChild(rowDiv);
                                                }

                                                // Dynamic aisle and column header generation
                                                buildLayout();

                                                // Connect WebSocket after seats are drawn in the DOM
                                                connectWS(state.showtimeId);
                                            })
                                            .catch(err => {
                                                console.error(err);
                                                container.innerHTML =
                                                        '<div class="text-center text-danger py-5">' +
                                                        '    <i class="bi bi-exclamation-triangle-fill fs-2 d-block mb-2"></i>' +
                                                        '    Error loading seat map: ' + err.message +
                                                        '</div>';
                                            });
                                }

                                function buildLayout() {
                                    const rows = Array.from(document.querySelectorAll('.seat-row'));
                                    if (!rows.length) return;

                                    const header = document.querySelector('#seatMap .seat-header');
                                    header.innerHTML = '';

                                    document.querySelectorAll('.seat-row .aisle').forEach(el => el.remove());

                                    const colSet = new Set();
                                    rows.forEach(r => r.querySelectorAll('.seat-btn').forEach(b => colSet.add(+b.dataset.col)));
                                    const cols = Array.from(colSet).sort((a, b) => a - b);
                                    if (!cols.length) return;
                                    const aisleAfter = cols[Math.ceil(cols.length / 2) - 1];

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
                                }

                                function toggleSeat(btn, seat) {
                                    if (btn.classList.contains('seat-booked') || btn.classList.contains('seat-maintenance') || btn.classList.contains('seat-soft-locked')) {
                                        return;
                                    }

                                    const index = state.selectedSeats.findIndex(s => s.seatId === seat.seatId);
                                    const id = String(seat.seatId);

                                    if (index > -1) {
                                        state.selectedSeats.splice(index, 1);
                                        setSeatState(btn, 'available');
                                        sendWS({action: 'DESELECT', seatId: Number(id), showtimeId: state.showtimeId});
                                    } else {
                                        if (state.selectedSeats.length >= Number('${empty maxSeatsPerBooking ? 8 : maxSeatsPerBooking}')) {
                                            lcAlert('You can select a maximum of ${empty maxSeatsPerBooking ? 8 : maxSeatsPerBooking} seats per booking.');
                                            return;
                                        }
                                        state.selectedSeats.push(seat);
                                        setSeatState(btn, 'selected');
                                        sendWS({action: 'SELECT', seatId: Number(id), showtimeId: state.showtimeId});
                                    }

                                    updateSeatsSummary();
                                }

                                function setSeatState(btn, stateStr) {
                                    btn.classList.remove(
                                        'seat-available', 'seat-selected',
                                        'seat-soft-locked', 'seat-booked', 'seat-maintenance'
                                    );

                                    switch (stateStr) {
                                        case 'available':    btn.classList.add('seat-available');    btn.disabled = false; break;
                                        case 'selected':     btn.classList.add('seat-selected');     btn.disabled = false; break;
                                        case 'soft-locked':  btn.classList.add('seat-soft-locked');  btn.disabled = true;  break;
                                        case 'booked':       btn.classList.add('seat-booked');       btn.disabled = true;  break;
                                        case 'maintenance':  btn.classList.add('seat-maintenance');  btn.disabled = true;  break;
                                    }
                                }

                                /**
                                 * [Flow Step: WebSocket] Connects to the seat mapping websocket channel to receive real-time state broadcast updates
                                 */
                                 function connectWS(showtimeId) {
                                     closeWS(); // Ensure no multiple WebSocket instances are active concurrently
                                     
                                     // Build localized WS / WSS protocol URL relative to context path
                                     const WS_URL = (location.protocol === 'https:' ? 'wss' : 'ws')
                                             + '://' + location.host
                                             + contextPath + '/ws/seats/' + showtimeId;

                                     ws = new WebSocket(WS_URL);

                                     // Connection success hook
                                     ws.onopen = function () {
                                         setWsBadge('Realtime Connected', 'bg-success');
                                         wsRetryDelay = 2000; // Reset exponential retry delay on successful link establishment
                                     };

                                     // [Flow Step: WebSocket -> Client] Receive real-time seat lock state broadcasts
                                     ws.onmessage = function (event) {
                                         let msg;
                                         try {
                                             msg = JSON.parse(event.data);
                                         } catch (e) {
                                             return;
                                         }

                                         const seatIdStr = String(msg.seatId);
                                         const seatDiv = document.querySelector('[data-seat-id="' + msg.seatId + '"]');
                                         if (!seatDiv)
                                             return;

                                         // Enforce client-side check if the broadcasted seat ID matches staff's current selections
                                         const isMySelection = state.selectedSeats.some(s => String(s.seatId) === seatIdStr);

                                         switch (msg.action) {
                                             case 'SELECT':
                                                 if (isMySelection)
                                                     return;
                                                 setSeatState(seatDiv, 'soft-locked'); // Mark seat as soft-locked (amber) in DOM
                                                 break;
                                             case 'DESELECT':
                                                 if (isMySelection)
                                                     return;
                                                 setSeatState(seatDiv, 'available'); // Mark seat as free (blue)
                                                 flashRefreshBadge();
                                                 break;
                                             case 'HELD_LOCK':
                                                 // Another transaction has locked this seat for payment processing (temporary lock)
                                                 if (isMySelection) {
                                                     const index = state.selectedSeats.findIndex(s => String(s.seatId) === seatIdStr);
                                                     if (index > -1) {
                                                         state.selectedSeats.splice(index, 1);
                                                         updateSeatsSummary();
                                                     }
                                                     lcAlert('Seat ' + seatDiv.getAttribute('data-seat-label')
                                                         + ' is being held for payment. Please choose another seat.');
                                                 }
                                                 setSeatState(seatDiv, 'soft-locked');
                                                 flashRefreshBadge();
                                                 break;
                                             case 'HARD_LOCK':
                                                 // Seat purchased and finalized in database (hard lock)
                                                 if (isMySelection) {
                                                     if (msg.username !== CURRENT_USER) {
                                                         const index = state.selectedSeats.findIndex(s => String(s.seatId) === seatIdStr);
                                                         if (index > -1) {
                                                             state.selectedSeats.splice(index, 1);
                                                             updateSeatsSummary();
                                                         }
                                                         lcAlert('Seat ' + seatDiv.getAttribute('data-seat-label') + ' was just selected by someone else. Please choose another seat.');
                                                     }
                                                 }
                                                 setSeatState(seatDiv, 'booked'); // Red booked seat style in DOM
                                                 flashRefreshBadge();
                                                 break;
                                             case 'HARD_RELEASE':
                                                 if (isMySelection)
                                                     return;
                                                 setSeatState(seatDiv, 'available');
                                                 flashRefreshBadge();
                                                 break;
                                         }
                                     };

                                     // Connection lost hook
                                     ws.onclose = function () {
                                         setWsBadge('Disconnected – retrying…', 'bg-warning text-dark');
                                         // Exponential backoff logic for auto-reconnection
                                         setTimeout(() => {
                                             if (state.currentStep >= 2 && state.showtimeId === showtimeId) {
                                                 connectWS(showtimeId);
                                             }
                                         }, Math.min(wsRetryDelay, 30000));
                                         wsRetryDelay *= 2;
                                     };

                                     ws.onerror = function () {
                                         ws.close();
                                     };
                                 }

                                 function closeWS() {
                                     if (ws) {
                                         ws.onclose = null;
                                         ws.close();
                                         ws = null;
                                     }
                                     setWsBadge('Disconnected', 'bg-secondary');
                                 }

                                 function setWsBadge(text, cls) {
                                     const b = document.getElementById('wsBadge');
                                     if (b) {
                                         b.textContent = text;
                                         b.className = 'badge ' + cls;
                                     }
                                 }

                                 function flashRefreshBadge() {
                                     const b = document.getElementById('refreshBadge');
                                     if (b) {
                                         b.style.opacity = '1';
                                         setTimeout(() => {
                                             b.style.opacity = '0';
                                         }, 2000);
                                     }
                                 }

                                 /**
                                  * [Flow Step: WebSocket -> Server] Emit current staff actions (SELECT / DESELECT) to keep all clients synced
                                  */
                                 function sendWS(payload) {
                                     if (ws && ws.readyState === WebSocket.OPEN) {
                                         ws.send(JSON.stringify(payload));
                                     }
                                 }

                                function updateSeatsSummary() {
                                    if (state.selectedSeats.length === 0) {
                                        document.getElementById('selected-seats-display').innerText = '—';
                                        document.getElementById('subtotal-display').innerText = '0';
                                        document.getElementById('btn-to-step3').disabled = true;
                                        state.subtotalAmount = 0;
                                        return;
                                    }

                                    const seatLabels = state.selectedSeats.map(s => s.rowLabel + s.colNumber);
                                    document.getElementById('selected-seats-display').innerText = seatLabels.join(', ');

                                    // Calculate total price based on seat multipliers (VIP % from AppConfig)
                                    const vipMult = 1 + (Number('${vipSurchargePercent}') || 30) / 100;
                                    let subtotal = 0;
                                    state.selectedSeats.forEach(s => {
                                        const multiplier = s.seatType === 'VIP' ? vipMult : 1.0;
                                        subtotal += Math.round(state.basePrice * multiplier);
                                    });

                                    state.subtotalAmount = subtotal;
                                    document.getElementById('subtotal-display').innerText = subtotal.toLocaleString();
                                    document.getElementById('btn-to-step3').disabled = false;
                                }

                                document.getElementById('btn-to-step3').addEventListener('click', () => {
                                    if (state.selectedSeats.length > 0) {
                                        loadFoodCatalog();
                                        recalculateFoodTotals();
                                        goToStep(3);
                                    }
                                });

                                // ==========================================
                                // STEP 3: FOOD & DRINKS UTILITIES
                                // ==========================================
                                let foodCatalog = [];

                                function loadFoodCatalog() {
                                    const container = document.getElementById('staff-food-items-container');
                                    if (foodCatalog.length > 0) {
                                        renderFoodCatalog();
                                        return;
                                    }

                                    container.innerHTML = 
                                        '<div class="col-12 text-center py-4">' +
                                        '    <div class="spinner-border text-primary" role="status"></div>' +
                                        '    <div class="text-muted mt-2">Loading catalog...</div>' +
                                        '</div>';

                                    fetch(contextPath + '/staff/booking?action=getFoodItems')
                                        .then(res => res.json())
                                        .then(data => {
                                            foodCatalog = data;
                                            renderFoodCatalog();
                                        })
                                        .catch(err => {
                                            console.error('Error loading concessions catalog:', err);
                                            container.innerHTML = 
                                                '<div class="col-12 text-center text-danger py-4">' +
                                                '    <i class="bi bi-exclamation-triangle-fill fs-2"></i>' +
                                                '    <p class="mt-2">Failed to load Food & Drinks catalog.</p>' +
                                                '</div>';
                                        });
                                }

                                function getThemeClasses(name) {
                                    let icon = 'bi-cookie';
                                    let color = 'snack-yellow';
                                    if (name === 'Coca-Cola') { icon = 'bi-cup-straw'; color = 'drink-red'; }
                                    else if (name === 'Mineral Water') { icon = 'bi-droplet-fill'; color = 'drink-cyan'; }
                                    else if (name === 'Popcorn (Medium)') { icon = 'bi-cookie'; color = 'snack-yellow'; }
                                    else if (name === 'Popcorn (Large)') { icon = 'bi-cookie'; color = 'snack-orange'; }
                                    else if (name === 'Combo Solo') { icon = 'bi-gift'; color = 'combo-green'; }
                                    else if (name === 'Combo for 2') { icon = 'bi-gift-fill'; color = 'combo-red'; }
                                    return { icon, color };
                                }

                                function renderFoodCatalog() {
                                    const container = document.getElementById('staff-food-items-container');
                                    container.innerHTML = '';

                                    const categories = {
                                        'COMBO': { title: '<i class="bi bi-gift text-primary me-2"></i>Combos & Deals' },
                                        'SNACK': { title: '<i class="bi bi-egg-fried text-primary me-2"></i>Popcorn & Snacks' },
                                        'DRINK': { title: '<i class="bi bi-cup-straw text-primary me-2"></i>Drinks' }
                                    };

                                    for (const catKey in categories) {
                                        const cat = categories[catKey];
                                        const items = foodCatalog.filter(item => item.category === catKey && item.active);
                                        if (items.length === 0) continue;

                                        // Render Category Header
                                        const headerCol = document.createElement('div');
                                        headerCol.className = 'col-12 mt-3';
                                        headerCol.innerHTML = '<h6 class="category-tab">' + cat.title + '</h6>';
                                        container.appendChild(headerCol);

                                        // Render Items
                                        items.forEach(item => {
                                            const qty = state.foodItems[item.foodId] || 0;
                                            const theme = getThemeClasses(item.name);
                                            const isAdded = qty > 0;
                                            const col = document.createElement('div');
                                            col.className = 'col-lg-4 col-sm-6 mb-3';
                                            col.innerHTML = 
                                                '<div class="food-card ' + (isAdded ? 'added' : '') + '" id="staff_food_card_' + item.foodId + '">' +
                                                '    <div id="staff_added_badge_' + item.foodId + '" class="added-badge position-absolute ' + (isAdded ? '' : 'd-none') + '" style="top: 12px; left: 12px; z-index: 10;">' +
                                                '        <span class="badge bg-primary text-white border border-light" style="padding: 6px 12px; border-radius: 20px; font-size: 0.72rem; font-weight: 700;">' +
                                                '            <i class="bi bi-check-circle-fill me-1"></i> Added' +
                                                '        </span>' +
                                                '    </div>' +
                                                '    <div class="food-img-wrapper themed ' + theme.color + '">' +
                                                '        <div class="glow-circle"></div>' +
                                                '        <i class="bi ' + theme.icon + '"></i>' +
                                                '    </div>' +
                                                '    <div class="food-info p-3 d-flex flex-column justify-content-between" style="min-height: 140px;">' +
                                                '        <div>' +
                                                '            <div class="fw-bold text-dark" style="font-size:0.95rem;">' + item.name + '</div>' +
                                                '            <div class="text-muted small mt-1">' + (item.description || '') + '</div>' +
                                                '        </div>' +
                                                '        <div class="d-flex justify-content-between align-items-center mt-3">' +
                                                '            <div class="fw-bold text-primary" style="font-size:1.05rem;">' +
                                                                formatNumber(item.price) + ' VND' +
                                                '            </div>' +
                                                '            <div>' +
                                                '                <button type="button" id="staff_add_btn_' + item.foodId + '" class="btn btn-outline-primary btn-sm px-3 fw-bold ' + (isAdded ? 'd-none' : '') + '" onclick="updateFoodQty(' + item.foodId + ', 1)" style="border-radius: 20px;">' +
                                                '                    + Add' +
                                                '                </button>' +
                                                '                <div id="staff_stepper_' + item.foodId + '" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 ' + (isAdded ? '' : 'd-none') + '" style="border-radius: 20px; width: 90px; font-size: 0.85rem;">' +
                                                '                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateFoodQty(' + item.foodId + ', -1)" style="line-height:1; border:none; background:transparent;">-</button>' +
                                                '                    <strong id="staff_food_qty_' + item.foodId + '">' + qty + '</strong>' +
                                                '                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateFoodQty(' + item.foodId + ', 1)" style="line-height:1; border:none; background:transparent;">+</button>' +
                                                '                </div>' +
                                                '            </div>' +
                                                '        </div>' +
                                                '    </div>' +
                                                '</div>';
                                            container.appendChild(col);
                                        });
                                    }
                                }

                                function updateFoodQty(foodId, change) {
                                    let qty = (state.foodItems[foodId] || 0) + change;
                                    if (qty < 0) qty = 0;
                                    if (qty > 10) qty = 10;

                                    if (qty > 0) {
                                        state.foodItems[foodId] = qty;
                                    } else {
                                        delete state.foodItems[foodId];
                                    }

                                    const card = document.getElementById("staff_food_card_" + foodId);
                                    const badge = document.getElementById("staff_added_badge_" + foodId);
                                    const addBtn = document.getElementById("staff_add_btn_" + foodId);
                                    const stepper = document.getElementById("staff_stepper_" + foodId);
                                    const qtyText = document.getElementById("staff_food_qty_" + foodId);

                                    if (qty > 0) {
                                        if (card) card.classList.add("added");
                                        if (badge) badge.classList.remove("d-none");
                                        if (addBtn) addBtn.classList.add("d-none");
                                        if (stepper) stepper.classList.remove("d-none");
                                        if (qtyText) qtyText.textContent = qty;
                                    } else {
                                        if (card) card.classList.remove("added");
                                        if (badge) badge.classList.add("d-none");
                                        if (addBtn) addBtn.classList.remove("d-none");
                                        if (stepper) stepper.classList.add("d-none");
                                    }

                                    recalculateFoodTotals();
                                }

                                function recalculateFoodTotals() {
                                    let foodSubtotal = 0;
                                    for (const foodId in state.foodItems) {
                                        const qty = state.foodItems[foodId];
                                        const item = foodCatalog.find(f => f.foodId == foodId);
                                        if (item) {
                                            foodSubtotal += item.price * qty;
                                        }
                                    }
                                    state.foodSubtotalAmount = foodSubtotal;
                                    document.getElementById('staff-food-subtotal-display').innerText = foodSubtotal.toLocaleString();
                                    document.getElementById('staff-tickets-subtotal-display').innerText = state.subtotalAmount.toLocaleString();
                                }

                                function formatNumber(val) {
                                    return (val || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
                                }

                                // ==========================================
                                // STEP 4: PROMO                                // Apply Promotion Code
                                const btnApplyPromo = document.getElementById('btn-apply-promo');
                                const promoCodeInput = document.getElementById('promo-code');
                                const promoSuccess = document.getElementById('promo-success-alert');
                                const promoError = document.getElementById('promo-error-alert');

                                const promoInputContainer = document.getElementById('promo-input-container');
                                const promoAppliedContainer = document.getElementById('promo-applied-container');
                                const promoBadgeCode = document.getElementById('promo-badge-code');
                                const btnRemovePromo = document.getElementById('btn-remove-promo');

                                function syncPromoUI() {
                                    if (state.promoCode) {
                                        promoInputContainer.classList.add('d-none');
                                        promoAppliedContainer.classList.remove('d-none');
                                        promoBadgeCode.innerText = state.promoCode;
                                    } else {
                                        promoInputContainer.classList.remove('d-none');
                                        promoAppliedContainer.classList.add('d-none');
                                        promoBadgeCode.innerText = '';
                                        promoCodeInput.value = '';
                                    }
                                }

                                // Remove Promotion Code click listener
                                btnRemovePromo.addEventListener('click', () => {
                                    state.promoCode = '';
                                    state.promoDiscount = 0;
                                    promoSuccess.classList.add('d-none');
                                    promoError.classList.add('d-none');
                                    document.getElementById('summary-discount').innerText = '0';
                                    syncPromoUI();
                                    calculateTotalCheckout();
                                });

                                btnApplyPromo.addEventListener('click', () => {
                                    const code = promoCodeInput.value.trim();
                                    if (!code) {
                                        // Clear promo
                                        state.promoCode = '';
                                        state.promoDiscount = 0;
                                        promoSuccess.classList.add('d-none');
                                        promoError.classList.add('d-none');
                                        document.getElementById('summary-discount').innerText = '0';
                                        syncPromoUI();
                                        calculateTotalCheckout();
                                        return;
                                    }

                                    btnApplyPromo.disabled = true;

                                    fetch(contextPath + '/staff/promo-validate?code=' + encodeURIComponent(code) + '&subtotal=' + state.subtotalAmount)
                                            .then(res => res.json())
                                            .then(data => {
                                                btnApplyPromo.disabled = false;

                                                if (data.valid) {
                                                    state.promoCode = code.toUpperCase();
                                                    state.promoDiscount = data.discountAmount;

                                                    promoSuccess.innerText = data.message;
                                                    promoSuccess.classList.remove('d-none');
                                                    promoError.classList.add('d-none');

                                                    document.getElementById('summary-discount').innerText = data.discountAmount.toLocaleString();
                                                    syncPromoUI();
                                                    calculateTotalCheckout();
                                                } else {
                                                    state.promoCode = '';
                                                    state.promoDiscount = 0;

                                                    promoError.innerText = data.message;
                                                    promoError.classList.remove('d-none');
                                                    promoSuccess.classList.add('d-none');

                                                    document.getElementById('summary-discount').innerText = '0';
                                                    syncPromoUI();
                                                    calculateTotalCheckout();
                                                }
                                            })
                                            .catch(err => {
                                                console.error(err);
                                                btnApplyPromo.disabled = false;
                                                lcAlert('Error applying promotion');
                                            });
                                });

                                function calculateTotalCheckout() {
                                    state.totalAmount = state.subtotalAmount + (state.foodSubtotalAmount || 0) - state.promoDiscount;
                                    if (state.totalAmount < 0)
                                        state.totalAmount = 0;
                                    document.getElementById('summary-total').innerText = state.totalAmount.toLocaleString();
                                }

                                document.getElementById('btn-to-step4').addEventListener('click', () => {
                                    document.getElementById('summary-subtotal').innerText = state.subtotalAmount.toLocaleString();
                                    document.getElementById('summary-food-subtotal').innerText = state.foodSubtotalAmount.toLocaleString();
                                    document.getElementById('summary-discount').innerText = state.promoDiscount.toLocaleString();
                                    syncPromoUI();
                                    calculateTotalCheckout();
                                    goToStep(4);
                                });

                                document.getElementById('btn-to-step5').addEventListener('click', () => {
                                    // Fill step 5 invoice summary
                                    document.getElementById('invoice-movie').innerText = state.movieTitle;
                                    document.getElementById('invoice-time').innerText = state.startTime + ' on ' + state.date;
                                    document.getElementById('invoice-room').innerText = state.roomName + ' (' + state.roomType + ')';

                                    const seatLabels = state.selectedSeats.map(s => s.rowLabel + s.colNumber);
                                    document.getElementById('invoice-seats').innerText = seatLabels.join(', ');

                                    // Concessions
                                    const concessionsList = [];
                                    for (const foodId in state.foodItems) {
                                        const qty = state.foodItems[foodId];
                                        const item = foodCatalog.find(f => f.foodId == foodId);
                                        if (item) {
                                            concessionsList.push(item.name + ' x' + qty);
                                        }
                                    }

                                    const concessionsRow = document.getElementById('invoice-concessions-row');
                                    const concessionsText = document.getElementById('invoice-concessions');
                                    if (concessionsList.length > 0) {
                                        concessionsText.innerText = concessionsList.join(', ');
                                        concessionsRow.classList.remove('d-none');
                                    } else {
                                        concessionsRow.classList.add('d-none');
                                    }

                                    document.getElementById('invoice-customer').innerText = formatCustomerLabel();

                                    document.getElementById('invoice-promo').innerText = state.promoCode
                                            ? state.promoCode + ' (Discount ' + state.promoDiscount.toLocaleString() + ' VND)'
                                            : 'None';

                                    document.getElementById('invoice-total').innerText = state.totalAmount.toLocaleString();

                                    // Reset payment method selection to CASH
                                    const payCashRadio = document.getElementById('pay-cash');
                                    if (payCashRadio) payCashRadio.checked = true;

                                    // Clear inputs
                                    document.getElementById('cash-received').value = '';
                                    document.getElementById('cash-change').innerText = '0';
                                    document.getElementById('cash-error').classList.add('d-none');
                                    document.getElementById('btn-confirm-booking').disabled = true;

                                    updatePaymentMethodUI();

                                    goToStep(5);
                                });

                                // ==========================================
                                // STEP 4: CASH PAYMENT FLOW
                                // ==========================================
                                const cashReceivedInput = document.getElementById('cash-received');
                                const cashChangeText = document.getElementById('cash-change');
                                const cashErrorAlert = document.getElementById('cash-error');
                                const btnConfirmBooking = document.getElementById('btn-confirm-booking');

                                cashReceivedInput.addEventListener('input', () => {
                                    const selectedMethod = document.querySelector('input[name="paymentMethodRadio"]:checked').value;
                                    if (selectedMethod === 'VNPAY') {
                                        return;
                                    }
                                    const received = parseFloat(cashReceivedInput.value) || 0;
                                    const due = state.totalAmount;

                                    if (received < due) {
                                        cashChangeText.innerText = '0';
                                        cashErrorAlert.classList.remove('d-none');
                                        btnConfirmBooking.disabled = true;
                                    } else {
                                        const change = received - due;
                                        cashChangeText.innerText = change.toLocaleString();
                                        cashErrorAlert.classList.add('d-none');
                                        btnConfirmBooking.disabled = false;
                                    }
                                });

                                function updatePaymentMethodUI() {
                                     const selectedMethod = document.querySelector('input[name="paymentMethodRadio"]:checked').value;
                                     const cashSection = document.getElementById('cash-payment-section');
                                     const vnpaySection = document.getElementById('vnpay-payment-section');
                                     const btnConfirm = document.getElementById('btn-confirm-booking');

                                     // Dynamic visual feedback for payment selector cards
                                     const payCashCard = document.getElementById('pay-cash').closest('.payment-method-card');
                                     const payVnpayCard = document.getElementById('pay-vnpay').closest('.payment-method-card');
                                     if (payCashCard) payCashCard.classList.toggle('active', selectedMethod === 'CASH');
                                     if (payVnpayCard) payVnpayCard.classList.toggle('active', selectedMethod === 'VNPAY');

                                     if (selectedMethod === 'VNPAY') {
                                         cashSection.classList.add('d-none');
                                         vnpaySection.classList.remove('d-none');

                                         // Update button
                                         btnConfirm.disabled = false;
                                         btnConfirm.className = "btn btn-primary-lc px-5 fw-bold fs-6";
                                         btnConfirm.innerHTML = `<i class="bi bi-qr-code-scan me-2"></i>GENERATE VNPAY PAYMENT REQUEST`;
                                     } else {
                                         cashSection.classList.remove('d-none');
                                         vnpaySection.classList.add('d-none');

                                         // Trigger cash received input event validation to set correct enabled state
                                         const received = parseFloat(cashReceivedInput.value) || 0;
                                         const due = state.totalAmount;
                                         if (received < due) {
                                             btnConfirm.disabled = true;
                                         } else {
                                             btnConfirm.disabled = false;
                                         }
                                         btnConfirm.className = "btn btn-success px-5 fw-bold fs-6";
                                         btnConfirm.innerHTML = `<i class="bi bi-cash-stack me-2"></i>CONFIRM CASH PAYMENT`;
                                     }
                                 }

                                btnConfirmBooking.addEventListener('click', () => {
                                    btnConfirmBooking.disabled = true;
                                    const selectedMethod = document.querySelector('input[name="paymentMethodRadio"]:checked').value;
                                    if (selectedMethod === 'VNPAY') {
                                        btnConfirmBooking.innerHTML = `<span class="spinner-border spinner-border-sm me-2" role="status"></span>CREATING VNPAY REQUEST...`;
                                    } else {
                                        btnConfirmBooking.innerHTML = `<span class="spinner-border spinner-border-sm me-2" role="status"></span>PROCESSING PAYMENT...`;
                                    }

                                    // Prepare payload
                                    const seatIdsString = state.selectedSeats.map(s => s.seatId).join(',');

                                    const foodItemsArr = [];
                                    for (const foodId in state.foodItems) {
                                        foodItemsArr.push({
                                            foodId: Number(foodId),
                                            quantity: state.foodItems[foodId]
                                        });
                                    }
                                    const foodItemsJson = JSON.stringify(foodItemsArr);

                                    const formData = new URLSearchParams();
                                    formData.append('showtimeId', state.showtimeId);
                                    formData.append('seatIds', seatIdsString);
                                    formData.append('promoCode', state.promoCode);
                                    formData.append('paymentMethod', selectedMethod);
                                    formData.append('notes', selectedMethod === 'VNPAY' ? 'Counter booking via VNPay' : 'Counter booking via Cash');
                                    formData.append('foodItems', foodItemsJson);
                                    formData.append('customerUsername', state.memberUsername);
                                    formData.append('_csrf', '${sessionScope.csrfToken}');

                                    fetch(contextPath + '/staff/booking', {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
                                        },
                                        body: formData.toString()
                                    })
                                            .then(res => res.json())
                                            .then(data => {
                                                if (data.success) {
                                                    if (data.redirectUrl) {
                                                        window.location.href = data.redirectUrl;
                                                        return;
                                                    }
                                                    state.bookingCode = data.bookingCode;
                                                    state.bookingId = data.bookingId;

                                                    // Fill Step 6 E-Ticket Details
                                                    document.getElementById('final-booking-code').innerText = data.bookingCode;
                                                    document.getElementById('final-movie').innerText = state.movieTitle;
                                                    document.getElementById('final-time').innerText = state.startTime + ' - ' + state.date;

                                                    const seatLabels = state.selectedSeats.map(s => s.rowLabel + s.colNumber);
                                                    document.getElementById('final-seats').innerText = seatLabels.join(', ');

                                                    // Concessions
                                                    const concessionsList = [];
                                                    for (const foodId in state.foodItems) {
                                                        const qty = state.foodItems[foodId];
                                                        const item = foodCatalog.find(f => f.foodId == foodId);
                                                        if (item) {
                                                            concessionsList.push(item.name + ' x' + qty);
                                                        }
                                                    }
                                                    const finalConRow = document.getElementById('final-concessions-row');
                                                    const finalConText = document.getElementById('final-concessions');
                                                    if (concessionsList.length > 0) {
                                                        finalConText.innerText = concessionsList.join(', ');
                                                        finalConRow.classList.remove('d-none');
                                                    } else {
                                                        finalConRow.classList.add('d-none');
                                                    }

                                                    goToStep(6);
                                                } else {
                                                    btnConfirmBooking.disabled = false;
                                                    if (selectedMethod === 'VNPAY') {
                                                        btnConfirmBooking.className = "btn btn-primary px-5 fw-bold fs-6";
                                                        btnConfirmBooking.innerHTML = `<i class="bi bi-qr-code-scan me-2"></i>GENERATE VNPAY PAYMENT REQUEST`;
                                                    } else {
                                                        btnConfirmBooking.className = "btn btn-success px-5 fw-bold fs-6";
                                                        btnConfirmBooking.innerHTML = `<i class="bi bi-cash-stack me-2"></i>CONFIRM CASH PAYMENT`;
                                                    }
                                                    lcAlert('Booking failed: ' + data.message);
                                                }
                                            })
                                            .catch(err => {
                                                console.error(err);
                                                btnConfirmBooking.disabled = false;
                                                if (selectedMethod === 'VNPAY') {
                                                    btnConfirmBooking.className = "btn btn-primary px-5 fw-bold fs-6";
                                                    btnConfirmBooking.innerHTML = `<i class="bi bi-qr-code-scan me-2"></i>GENERATE VNPAY PAYMENT REQUEST`;
                                                } else {
                                                    btnConfirmBooking.className = "btn btn-success px-5 fw-bold fs-6";
                                                    btnConfirmBooking.innerHTML = `<i class="bi bi-cash-stack me-2"></i>CONFIRM CASH PAYMENT`;
                                                }
                                                lcAlert('A network error occurred while processing booking.');
                                            });
                                });

                                // ==========================================
                                // STEP 5: TICKET UTILITIES
                                // ==========================================
                                const btnPrintTicket = document.getElementById('btn-print-ticket');
                                btnPrintTicket.addEventListener('click', () => {
                                    // Open generated PDF in new tab to trigger print
                                    window.open(contextPath + '/staff/ticket-pdf?bookingCode=' + state.bookingCode, '_blank');
                                });

                                // ==========================================
                                // HELPERS: NAVIGATOR & SYSTEM RESET
                                // ==========================================
                                function goToStep(stepNum) {
                                    // Close WebSocket if leaving Step 2 to go back to Step 1
                                    if (state.currentStep >= 2 && stepNum === 1) {
                                        closeWS();
                                    }
                                    // Close WebSocket on Step 6 (successful booking completion)
                                    if (stepNum === 6) {
                                        closeWS();
                                    }

                                    state.currentStep = stepNum;

                                    // Toggle panels
                                    document.querySelectorAll('.wizard-panel').forEach(p => p.classList.remove('active'));
                                    document.getElementById('panel-' + stepNum).classList.add('active');

                                    // Toggle indicators (now 6 steps)
                                    for (let i = 1; i <= 6; i++) {
                                        const ind = document.getElementById('step-ind-' + i);
                                        if (ind) {
                                            ind.classList.remove('active', 'completed');
                                            if (i < stepNum) {
                                                ind.classList.add('completed');
                                            } else if (i === stepNum) {
                                                ind.classList.add('active');
                                            }
                                        }
                                    }

                                    // Progress fill chạy theo bước hiện tại (5 khoảng giữa 6 mốc)
                                    var wz = document.querySelector('.wizard-steps');
                                    if (wz) {
                                        wz.style.setProperty('--wizard-progress',
                                            (((stepNum - 1) / 5) * 83.33) + '%');
                                    }
                                }

                                function resetWizard() {
                                    state = {
                                        currentStep: 1,
                                        showtimeId: null,
                                        basePrice: 0,
                                        movieTitle: '',
                                        startTime: '',
                                        date: '',
                                        roomName: '',
                                        roomType: '',
                                        selectedSeats: [],
                                        memberUsername: 'guest01',
                                        memberFullName: 'Walk-in Guest',
                                        memberEmail: '',
                                        promoCode: '',
                                        promoDiscount: 0,
                                        totalAmount: 0,
                                        subtotalAmount: 0,
                                        bookingCode: '',
                                        bookingId: null,
                                        foodItems: {},
                                        foodSubtotalAmount: 0
                                    };

                                    // Clear inputs
                                    movieSearch.value = '';
                                    roomFilter.value = '';
                                    dateFilter.value = todayStr;
                                    promoCodeInput.value = '';

                                    // Clear UI elements
                                    promoSuccess.classList.add('d-none');
                                    promoError.classList.add('d-none');
                                    syncPromoUI();

                                    // Ensure WebSocket connection is closed on reset
                                    closeWS();

                                    // Refresh first page
                                    loadShowtimes();
                                    goToStep(1);
                                }
        </script>
    </body>
</html>
