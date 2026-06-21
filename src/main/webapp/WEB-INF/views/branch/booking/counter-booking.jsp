<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bán vé tại quầy - MBCMS Staff</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Theme CSS (Inherits branch manager's style) -->
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    
    <style>
        /* Modern Web Design Enhancements & Aesthetics */
        .wizard-steps-container {
            background: #ffffff;
            border-radius: 12px;
            padding: 1.5rem 1rem;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05), 0 2px 4px -1px rgba(0, 0, 0, 0.03);
            margin-bottom: 2rem;
        }
        
        .wizard-steps {
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
            left: 5%;
            right: 5%;
            height: 3px;
            background: #e2e8f0;
            z-index: 1;
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
            border: 3px solid #e2e8f0;
            color: #64748b;
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
            color: #64748b;
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

        /* Screen representation */
        .screen {
            width: 70%;
            height: 8px;
            background: #cbd5e1;
            border-radius: 999px;
            margin: 2rem auto 3rem;
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.05);
            text-align: center;
            position: relative;
        }
        
        .screen::after {
            content: 'MÀN HÌNH CHIẾU';
            font-size: 0.65rem;
            color: #94a3b8;
            position: absolute;
            top: 15px;
            left: 50%;
            transform: translateX(-50%);
            letter-spacing: 0.15em;
            font-weight: 700;
        }
        
        /* Seat Layout Map */
        .seat-grid {
            display: flex;
            flex-direction: column;
            gap: 8px;
            align-items: center;
            margin: 0 auto;
            max-width: 100%;
            overflow-x: auto;
            padding: 1.5rem;
            background: #f8fafc;
            border-radius: 12px;
            border: 1px dashed #cbd5e1;
        }
        
        .seat-row {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        
        .row-label {
            width: 30px;
            font-weight: 700;
            color: #64748b;
            text-align: center;
            font-size: 0.9rem;
        }
        
        .seat {
            width: 36px;
            height: 36px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.75rem;
            font-weight: 700;
            cursor: pointer;
            user-select: none;
            transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
            border: 2px solid transparent;
        }
        
        .seat-standard {
            background-color: #dce9fb;
            color: #084298;
            border-color: #b6d4fe;
        }
        
        .seat-standard:hover:not(.booked):not(.disabled) {
            background-color: var(--lc-primary);
            color: #ffffff;
            transform: scale(1.08);
        }
        
        .seat-vip {
            background-color: #fff4d6;
            color: #664d03;
            border-color: #ffecb5;
        }
        
        .seat-vip:hover:not(.booked):not(.disabled) {
            background-color: #ffc107;
            color: #000000;
            transform: scale(1.08);
        }
        
        .seat.selected {
            background-color: #10b981 !important;
            color: #ffffff !important;
            border-color: #059669 !important;
            box-shadow: 0 0 10px rgba(16, 185, 129, 0.4);
            transform: scale(1.08);
        }
        
        .seat.booked {
            background-color: #cbd5e1;
            color: #64748b;
            cursor: not-allowed;
            border-color: #cbd5e1;
            opacity: 0.5;
        }
        
        .seat.disabled {
            background-color: #f1f5f9;
            color: #94a3b8;
            cursor: not-allowed;
            border-color: #e2e8f0;
            opacity: 0.4;
        }

        .seat.soft-locked {
            background-color: #fef3c7 !important;
            border-color: #f59e0b !important;
            color: #92400e !important;
            cursor: not-allowed !important;
            animation: soft-pulse 1.8s ease-in-out infinite;
            opacity: 0.8;
        }

        @keyframes soft-pulse {
            0%, 100% { box-shadow: 0 0 0 2px rgba(245, 158, 11, 0.4); }
            50%      { box-shadow: 0 0 0 5px rgba(245, 158, 11, 0.0); }
        }

        .showtime-card {
            border: 2px solid var(--lc-border);
            border-radius: 12px;
            cursor: pointer;
            transition: all 0.2s ease;
            background: #ffffff;
        }
        
        .showtime-card:hover {
            border-color: var(--lc-primary);
            box-shadow: var(--lc-shadow);
            transform: translateY(-2px);
        }
        
        .showtime-card.selected {
            border-color: var(--lc-primary);
            background: var(--lc-light);
            box-shadow: var(--lc-shadow);
        }

        .wizard-panel {
            display: none;
        }
        
        .wizard-panel.active {
            display: block;
        }
    </style>
</head>
<body class="lc-console">

    <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
        <jsp:param name="active" value="booking" />
    </jsp:include>

    <main class="lc-admin-main">
        <div class="container-fluid px-4 py-4" style="max-width: 1200px;">
            
            <%-- ===== Page Header ===== --%>
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-2 mb-4">
                <div>
                    <div class="text-muted small mb-1">Nghiệp vụ quầy</div>
                    <h4 class="text-navy fw-bold mb-0">Đặt Vé Trực Tiếp Tại Quầy</h4>
                </div>
                <div class="lc-sb-user d-flex align-items-center gap-2 px-3 py-1 text-navy border rounded" style="background:#fff;">
                    <i class="bi bi-geo-alt-fill text-primary"></i>
                    <span>Chi nhánh: <strong><c:out value="${sessionScope.currentBranchName}" /></strong></span>
                </div>
            </div>

            <%-- ===== Step Indicator Wizard ===== --%>
            <div class="wizard-steps-container">
                <div class="wizard-steps">
                    <div class="wizard-step active" id="step-ind-1">
                        <div class="step-num">1</div>
                        <div class="step-label">Suất Chiếu</div>
                    </div>
                    <div class="wizard-step" id="step-ind-2">
                        <div class="step-num">2</div>
                        <div class="step-label">Chọn Ghế</div>
                    </div>
                    <div class="wizard-step" id="step-ind-3">
                        <div class="step-num">3</div>
                        <div class="step-label">Khách & Khuyến Mãi</div>
                    </div>
                    <div class="wizard-step" id="step-ind-4">
                        <div class="step-num">4</div>
                        <div class="step-label">Thanh Toán</div>
                    </div>
                    <div class="wizard-step" id="step-ind-5">
                        <div class="step-num">5</div>
                        <div class="step-label">In Vé</div>
                    </div>
                </div>
            </div>

            <%-- ===== STEP 1: SELECT SHOWTIME ===== --%>
            <div class="wizard-panel active" id="panel-1">
                <div class="card lc-elev p-4">
                    <h5 class="text-navy fw-bold mb-3"><i class="bi bi-1-circle-fill text-primary me-2"></i>Chọn Suất Chiếu</h5>
                    
                    <!-- Search & Filter Controls -->
                    <div class="row g-3 mb-4">
                        <div class="col-md-5">
                            <label class="form-label fw-semibold">Tìm kiếm phim</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-search"></i></span>
                                <input type="text" id="movie-search" class="form-control" placeholder="Nhập tên phim cần tìm...">
                            </div>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-semibold">Lọc theo phòng</label>
                            <select id="room-filter" class="form-select">
                                <option value="">Tất cả các phòng</option>
                                <c:forEach var="r" items="${rooms}">
                                    <option value="${r.roomId}"><c:out value="${r.name}" /> (${r.roomType})</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-semibold">Ngày chiếu</label>
                            <input type="date" id="date-filter" class="form-control">
                        </div>
                    </div>

                    <!-- Showtimes List Container -->
                    <div class="mb-4">
                        <h6 class="text-navy fw-bold mb-3 text-uppercase small" style="letter-spacing: .05em;">Danh sách suất chiếu khả dụng hôm nay</h6>
                        <div class="row g-3" id="showtimes-container">
                            <!-- Showtimes populated dynamically via JS -->
                            <div class="col-12 text-center text-muted py-5" id="showtimes-loading">
                                <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                                Đang tải danh sách suất chiếu...
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-end mt-4">
                        <button class="btn btn-primary-lc px-4" id="btn-to-step2" disabled>Tiếp tục chọn ghế <i class="bi bi-arrow-right ms-1"></i></button>
                    </div>
                </div>
            </div>

            <%-- ===== STEP 2: SELECT SEAT ===== --%>
            <div class="wizard-panel" id="panel-2">
                <div class="card lc-elev p-4">
                    <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                        <div class="d-flex align-items-center gap-2">
                            <h5 class="text-navy fw-bold mb-0"><i class="bi bi-2-circle-fill text-primary me-2"></i>Chọn Ghế</h5>
                            <span id="wsBadge" class="badge bg-secondary">Chưa kết nối</span>
                            <span id="refreshBadge" class="badge bg-success" style="opacity: 0; transition: opacity 0.4s;">&#8635; Đã cập nhật</span>
                        </div>
                        <div class="badge bg-primary px-3 py-2 fs-6" id="showtime-header-info"></div>
                    </div>
                    
                    <!-- Screen Area -->
                    <div class="screen"></div>
                    
                    <!-- Seat Map Grid -->
                    <div class="seat-grid mb-4" id="seat-map-container">
                        <!-- Loaded dynamically -->
                    </div>

                    <!-- Legend & Summary -->
                    <div class="row align-items-center g-3">
                        <div class="col-md-6">
                            <div class="d-flex gap-3 flex-wrap">
                                <div class="d-flex align-items-center gap-1">
                                    <div class="seat seat-standard" style="width:20px;height:20px;cursor:default;"></div>
                                    <span class="small text-muted">Thường</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <div class="seat seat-vip" style="width:20px;height:20px;cursor:default;"></div>
                                    <span class="small text-muted">VIP (+20%)</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <div class="seat selected" style="width:20px;height:20px;cursor:default;"></div>
                                    <span class="small text-muted">Đang chọn</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <div class="seat soft-locked" style="width:20px;height:20px;cursor:default;"></div>
                                    <span class="small text-muted">Người khác chọn</span>
                                </div>
                                <div class="d-flex align-items-center gap-1">
                                    <div class="seat booked" style="width:20px;height:20px;cursor:default;"></div>
                                    <span class="small text-muted">Đã bán</span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6 text-end">
                            <div class="fw-semibold text-navy">Ghế đã chọn: <span id="selected-seats-display" class="text-primary font-monospace">&mdash;</span></div>
                            <div class="fs-5 fw-bold text-navy mt-1">Tổng tạm tính: <span id="subtotal-display" class="text-danger">0</span> VND</div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-4">
                        <button class="btn btn-secondary px-4" onclick="goToStep(1)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                        <button class="btn btn-primary-lc px-4" id="btn-to-step3" disabled>Tiếp tục <i class="bi bi-arrow-right ms-1"></i></button>
                    </div>
                </div>
            </div>

            <%-- ===== STEP 3: CUSTOMER & PROMO ===== --%>
            <div class="wizard-panel" id="panel-3">
                <div class="card lc-elev p-4">
                    <h5 class="text-navy fw-bold mb-3"><i class="bi bi-3-circle-fill text-primary me-2"></i>Thành Viên & Khuyến Mãi</h5>
                    
                    <div class="row g-4">
                        <!-- Left Column: Member Lookup -->
                        <div class="col-md-6 border-end">
                            <h6 class="text-navy fw-bold mb-3 text-uppercase small">Tra cứu tài khoản thành viên</h6>
                            <div class="mb-3">
                                <label class="form-label">Số điện thoại khách hàng</label>
                                <div class="input-group">
                                    <input type="text" id="member-phone" class="form-control" placeholder="Nhập số điện thoại khách hàng...">
                                    <button class="btn btn-outline-primary" type="button" id="btn-lookup"><i class="bi bi-search me-1"></i>Tìm</button>
                                </div>
                            </div>
                            
                            <!-- Member Details Card -->
                            <div class="card bg-light p-3 border-0 rounded-3 mb-3 d-none" id="member-card">
                                <div class="d-flex align-items-center gap-3">
                                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width:40px;height:40px;">
                                        <i class="bi bi-person-fill fs-5"></i>
                                    </div>
                                    <div>
                                        <div class="fw-bold text-navy" id="member-name"></div>
                                        <div class="text-muted small">Username: <span id="member-username"></span></div>
                                        <div class="text-muted small">Email: <span id="member-email-display"></span></div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="text-muted small" id="member-status-text">
                                <i class="bi bi-info-circle me-1"></i> Để trống nếu khách hàng mua vé vãng lai (không đăng ký thành viên).
                            </div>
                        </div>

                        <!-- Right Column: Promotion -->
                        <div class="col-md-6">
                            <h6 class="text-navy fw-bold mb-3 text-uppercase small">Áp dụng mã giảm giá (Promo Code)</h6>
                            <div class="mb-3">
                                <label class="form-label">Mã khuyến mãi</label>
                                <div class="input-group">
                                    <input type="text" id="promo-code" class="form-control text-uppercase" placeholder="Nhập mã giảm giá...">
                                    <button class="btn btn-outline-primary" type="button" id="btn-apply-promo"><i class="bi bi-check-lg me-1"></i>Áp dụng</button>
                                </div>
                            </div>
                            
                            <div class="alert alert-success py-2 d-none" id="promo-success-alert"></div>
                            <div class="alert alert-danger py-2 d-none" id="promo-error-alert"></div>
                            
                            <hr>
                            
                            <div class="d-flex justify-content-between mb-2">
                                <span class="text-muted">Tạm tính vé:</span>
                                <span class="fw-semibold text-navy"><span id="summary-subtotal">0</span> VND</span>
                            </div>
                            <div class="d-flex justify-content-between mb-2 text-success">
                                <span>Giảm giá:</span>
                                <span>-<span id="summary-discount">0</span> VND</span>
                            </div>
                            <div class="d-flex justify-content-between border-top pt-2 fs-5 fw-bold text-navy">
                                <span>Tổng thanh toán:</span>
                                <span><span id="summary-total" class="text-danger">0</span> VND</span>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-5">
                        <button class="btn btn-secondary px-4" onclick="goToStep(2)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                        <button class="btn btn-primary-lc px-4" id="btn-to-step4">Tiếp tục <i class="bi bi-arrow-right ms-1"></i></button>
                    </div>
                </div>
            </div>

            <%-- ===== STEP 4: CASH CONFIRMATION ===== --%>
            <div class="wizard-panel" id="panel-4">
                <div class="card lc-elev p-4">
                    <h5 class="text-navy fw-bold mb-3"><i class="bi bi-4-circle-fill text-primary me-2"></i>Xác Nhận & Thanh Toán Tiền Mặt</h5>
                    
                    <div class="row g-4">
                        <!-- Invoice detail -->
                        <div class="col-md-7 border-end">
                            <h6 class="text-navy fw-bold mb-3 text-uppercase small">Chi tiết đơn hàng</h6>
                            <div class="table-responsive">
                                <table class="table table-bordered">
                                    <tbody>
                                        <tr>
                                            <th class="bg-light text-navy" style="width:35%;">Phim</th>
                                            <td id="invoice-movie" class="fw-bold text-primary"></td>
                                        </tr>
                                        <tr>
                                            <th class="bg-light text-navy">Suất chiếu</th>
                                            <td id="invoice-time"></td>
                                        </tr>
                                        <tr>
                                            <th class="bg-light text-navy">Phòng chiếu</th>
                                            <td id="invoice-room"></td>
                                        </tr>
                                        <tr>
                                            <th class="bg-light text-navy">Ghế đã chọn</th>
                                            <td id="invoice-seats" class="font-monospace fw-bold text-navy"></td>
                                        </tr>
                                        <tr>
                                            <th class="bg-light text-navy">Tài khoản đặt vé</th>
                                            <td id="invoice-customer">Khách vãng lai (guest01)</td>
                                        </tr>
                                        <tr>
                                            <th class="bg-light text-navy">Mã giảm giá</th>
                                            <td id="invoice-promo">&mdash;</td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Cash drawer calculation -->
                        <div class="col-md-5">
                            <div class="bg-light rounded-3 p-4 border text-center">
                                <div class="text-muted small text-uppercase fw-semibold mb-1">Tổng tiền cần thanh toán</div>
                                <div class="fs-2 fw-bold text-danger mb-3"><span id="invoice-total">0</span> VND</div>
                                
                                <div class="mb-3 text-start">
                                    <label class="form-label fw-semibold text-navy">Tiền mặt khách đưa (VND)</label>
                                    <input type="number" id="cash-received" class="form-control form-control-lg text-center fw-bold fs-4 text-primary" placeholder="0" min="0">
                                </div>
                                
                                <div class="d-flex justify-content-between align-items-center border-top pt-3 text-start">
                                    <span class="fw-semibold text-navy">Tiền thừa trả khách:</span>
                                    <span class="fs-4 fw-bold text-success"><span id="cash-change">0</span> VND</span>
                                </div>
                                
                                <div id="cash-error" class="alert alert-warning py-2 mt-3 d-none">
                                    <i class="bi bi-exclamation-triangle-fill"></i> Số tiền khách đưa chưa đủ.
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between mt-5">
                        <button class="btn btn-secondary px-4" onclick="goToStep(3)"><i class="bi bi-arrow-left me-1"></i> Quay lại</button>
                        <button class="btn btn-success px-5 fw-bold fs-6" id="btn-confirm-booking" disabled>
                            <i class="bi bi-cash-stack me-2"></i>XÁC NHẬN THANH TOÁN TIỀN MẶT
                        </button>
                    </div>
                </div>
            </div>

            <%-- ===== STEP 5: GENERATE & PRINT TICKET ===== --%>
            <div class="wizard-panel" id="panel-5">
                <div class="card lc-elev p-4 text-center">
                    <div class="mb-4">
                        <div class="bg-success text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width:70px;height:70px;">
                            <i class="bi bi-check-lg fs-1"></i>
                        </div>
                        <h4 class="text-success fw-bold">GIAO DỊCH HOÀN TẤT THÀNH CÔNG!</h4>
                        <p class="text-muted">Đơn hàng đã được lưu và thanh toán bằng tiền mặt thành công.</p>
                    </div>

                    <div class="row justify-content-center mb-4">
                        <div class="col-md-8 col-lg-6">
                            <div class="card border rounded-3 p-4 bg-white shadow-sm">
                                <div class="small text-muted text-uppercase fw-semibold mb-1">Mã đặt vé của khách</div>
                                <h2 class="text-primary fw-bold font-monospace" id="final-booking-code"></h2>
                                
                                <div class="alert alert-light border my-3 py-2 small text-start">
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>Phim:</span><strong id="final-movie"></strong>
                                    </div>
                                    <div class="d-flex justify-content-between mb-1">
                                        <span>Suất chiếu:</span><strong id="final-time"></strong>
                                    </div>
                                    <div class="d-flex justify-content-between">
                                        <span>Ghế:</span><strong id="final-seats"></strong>
                                    </div>
                                </div>

                                <div class="d-grid gap-2">
                                    <button class="btn btn-primary btn-lg fw-bold" id="btn-print-ticket">
                                        <i class="bi bi-printer-fill me-2"></i>In vé tại quầy (PDF)
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <hr>

                    <div class="d-flex justify-content-center gap-3">
                        <button class="btn btn-primary-lc px-5 fw-bold" onclick="resetWizard()">
                            <i class="bi bi-plus-lg me-2"></i>TẠO GIAO DỊCH MỚI
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
        const contextPath = '${pageContext.request.contextPath}';
        const CURRENT_USER = '${sessionScope.username}';
        
        let ws = null;
        let wsRetryDelay = 2000;
        
        // Wizard State
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
            memberPhone: '',
            memberUsername: 'guest01',
            memberFullName: 'Khách vãng lai',
            memberEmail: '',
            promoCode: '',
            promoDiscount: 0,
            totalAmount: 0,
            subtotalAmount: 0,
            bookingCode: '',
            bookingId: null
        };

        // DOM Elements
        const dateFilter = document.getElementById('date-filter');
        const movieSearch = document.getElementById('movie-search');
        const roomFilter = document.getElementById('room-filter');
        const showtimesContainer = document.getElementById('showtimes-container');
        const btnToStep2 = document.getElementById('btn-to-step2');
        
        // Pre-fill today's date in local YYYY-MM-DD
        const todayStr = new Date().toISOString().split('T')[0];
        dateFilter.value = todayStr;

        // Init Step 1 on Load
        document.addEventListener('DOMContentLoaded', () => {
            loadShowtimes();
            
            // Event Listeners for Filters
            dateFilter.addEventListener('change', loadShowtimes);
            movieSearch.addEventListener('input', loadShowtimes);
            roomFilter.addEventListener('change', loadShowtimes);
        });

        // ==========================================
        // STEP 1: SHOWTIMES LOADING & FILTERING
        // ==========================================
        function loadShowtimes() {
            showtimesContainer.innerHTML = `
                <div class="col-12 text-center text-muted py-5">
                    <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                    Đang tải danh sách suất chiếu...
                </div>
            `;
            
            const movieVal = encodeURIComponent(movieSearch.value.trim());
            const dateVal = dateFilter.value;
            const roomVal = roomFilter.value;
            
            let url = contextPath + '/staff/booking?action=getShowtimes&date=' + dateVal;
            if (roomVal) url += '&roomId=' + roomVal;
            
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
                                Không có suất chiếu nào hoạt động phù hợp bộ lọc của bạn.
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
                            '    <div class="small text-muted mb-2"><i class="bi bi-clock me-1"></i>' + st.startTime + ' &middot; Phòng: ' + st.roomName + ' (' + st.roomType + ')</div>' +
                            '    <div class="d-flex justify-content-between align-items-center mb-1">' +
                            '        <span class="small text-muted">Trống: <strong>' + availableSeats + '/' + st.roomCapacity + '</strong> ghế</span>' +
                            '        <span class="small text-muted">' + percentSold + '% đã bán</span>' +
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
                        '    Lỗi khi tải suất chiếu: ' + err.message +
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
                    '<i class="bi bi-door-closed me-1"></i> Phòng: ' + state.roomName;
                
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
                <div class="text-center text-muted py-5">
                    <div class="spinner-border spinner-border-sm text-primary me-2" role="status"></div>
                    Đang tải sơ đồ ghế...
                </div>
            `;
            
            state.selectedSeats = [];
            document.getElementById('selected-seats-display').innerText = '—';
            document.getElementById('subtotal-display').innerText = '0';
            document.getElementById('btn-to-step3').disabled = true;

            fetch(contextPath + '/staff/booking?action=getSeats&showtimeId=' + state.showtimeId)
                .then(res => res.json())
                .then(data => {
                    container.innerHTML = '';
                    const seatsByRow = data.seatsByRow;
                    const bookedSeatIds = new Set(data.bookedSeatIds);

                    for (const rowLabel in seatsByRow) {
                        const rowDiv = document.createElement('div');
                        rowDiv.className = 'seat-row';
                        
                        // Row Label Left
                        const leftLabel = document.createElement('div');
                        leftLabel.className = 'row-label';
                        leftLabel.innerText = rowLabel;
                        rowDiv.appendChild(leftLabel);

                        // Row Seats
                        seatsByRow[rowLabel].forEach(seat => {
                            const seatDiv = document.createElement('div');
                            const isBooked = bookedSeatIds.has(seat.seatId);
                            const isVip = seat.seatType === 'VIP';
                            
                            seatDiv.className = 'seat ' + (isVip ? 'seat-vip' : 'seat-standard') + ' ' + (isBooked ? 'booked' : '') + ' ' + (!seat.active ? 'disabled' : '');
                            seatDiv.innerText = seat.colNumber;
                            seatDiv.title = 'Ghế ' + seat.rowLabel + seat.colNumber + ' (' + (isVip ? 'VIP' : 'Thường') + ')';
                            
                            seatDiv.setAttribute('data-seat-id', seat.seatId);
                            seatDiv.setAttribute('data-seat-type', seat.seatType);
                            seatDiv.setAttribute('data-seat-label', seat.rowLabel + seat.colNumber);
                            
                            if (!isBooked && seat.active) {
                                seatDiv.addEventListener('click', () => toggleSeat(seatDiv, seat));
                            }
                            rowDiv.appendChild(seatDiv);
                        });

                        // Row Label Right
                        const rightLabel = document.createElement('div');
                        rightLabel.className = 'row-label';
                        rightLabel.innerText = rowLabel;
                        rowDiv.appendChild(rightLabel);

                        container.appendChild(rowDiv);
                    }

                    // Connect WebSocket after seats are drawn in the DOM
                    connectWS(state.showtimeId);
                })
                .catch(err => {
                    console.error(err);
                    container.innerHTML = 
                        '<div class="text-center text-danger py-5">' +
                        '    <i class="bi bi-exclamation-triangle-fill fs-2 d-block mb-2"></i>' +
                        '    Lỗi khi tải sơ đồ ghế: ' + err.message +
                        '</div>';
                });
        }

        function toggleSeat(element, seat) {
            if (element.classList.contains('booked') || element.classList.contains('disabled') || element.classList.contains('soft-locked')) {
                return;
            }
            
            const index = state.selectedSeats.findIndex(s => s.seatId === seat.seatId);
            const id = String(seat.seatId);
            
            if (index > -1) {
                state.selectedSeats.splice(index, 1);
                setSeatStateUI(element, 'available');
                sendWS({ action: 'DESELECT', seatId: Number(id), showtimeId: state.showtimeId });
            } else {
                state.selectedSeats.push(seat);
                setSeatStateUI(element, 'selected');
                sendWS({ action: 'SELECT', seatId: Number(id), showtimeId: state.showtimeId });
            }

            updateSeatsSummary();
        }

        // stateStr: 'available' | 'selected' | 'soft-locked' | 'booked' | 'disabled'
        function setSeatStateUI(seatDiv, stateStr) {
            seatDiv.classList.remove('selected', 'booked', 'disabled', 'soft-locked');
            if (stateStr === 'selected') {
                seatDiv.classList.add('selected');
            } else if (stateStr === 'booked') {
                seatDiv.classList.add('booked');
            } else if (stateStr === 'disabled') {
                seatDiv.classList.add('disabled');
            } else if (stateStr === 'soft-locked') {
                seatDiv.classList.add('soft-locked');
            }
        }

        function connectWS(showtimeId) {
            closeWS();
            const WS_URL = (location.protocol === 'https:' ? 'wss' : 'ws')
                         + '://' + location.host
                         + contextPath + '/ws/seats/' + showtimeId;

            ws = new WebSocket(WS_URL);

            ws.onopen = function () {
                setWsBadge('Realtime Connected', 'bg-success');
                wsRetryDelay = 2000;
            };

            ws.onmessage = function (event) {
                let msg;
                try { msg = JSON.parse(event.data); }
                catch (e) { return; }

                const seatIdStr = String(msg.seatId);
                const seatDiv = document.querySelector('[data-seat-id="' + msg.seatId + '"]');
                if (!seatDiv) return;

                const isMySelection = state.selectedSeats.some(s => String(s.seatId) === seatIdStr);

                switch (msg.action) {
                    case 'SELECT':
                        if (isMySelection) return;
                        setSeatStateUI(seatDiv, 'soft-locked');
                        break;
                    case 'DESELECT':
                        if (isMySelection) return;
                        setSeatStateUI(seatDiv, 'available');
                        flashRefreshBadge();
                        break;
                    case 'HARD_LOCK':
                        if (isMySelection) {
                            if (msg.username !== CURRENT_USER) {
                                const index = state.selectedSeats.findIndex(s => String(s.seatId) === seatIdStr);
                                if (index > -1) {
                                    state.selectedSeats.splice(index, 1);
                                    updateSeatsSummary();
                                }
                                alert('Ghế ' + seatDiv.getAttribute('data-seat-label') + ' vừa được người khác đặt. Vui lòng chọn ghế khác.');
                            }
                        }
                        setSeatStateUI(seatDiv, 'booked');
                        flashRefreshBadge();
                        break;
                    case 'HARD_RELEASE':
                        if (isMySelection) return;
                        setSeatStateUI(seatDiv, 'available');
                        flashRefreshBadge();
                        break;
                }
            };

            ws.onclose = function () {
                setWsBadge('Mất kết nối – thử lại…', 'bg-warning text-dark');
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
            setWsBadge('Chưa kết nối', 'bg-secondary');
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
                setTimeout(() => { b.style.opacity = '0'; }, 2000);
            }
        }

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

            // Calculate total price based on seat multipliers
            let subtotal = 0;
            state.selectedSeats.forEach(s => {
                const multiplier = s.seatType === 'VIP' ? 1.2 : 1.0;
                subtotal += Math.round(state.basePrice * multiplier);
            });

            state.subtotalAmount = subtotal;
            document.getElementById('subtotal-display').innerText = subtotal.toLocaleString();
            document.getElementById('btn-to-step3').disabled = false;
        }

        document.getElementById('btn-to-step3').addEventListener('click', () => {
            if (state.selectedSeats.length > 0) {
                // Initialize step 3 pricing inputs
                document.getElementById('summary-subtotal').innerText = state.subtotalAmount.toLocaleString();
                document.getElementById('summary-discount').innerText = state.promoDiscount.toLocaleString();
                calculateTotalCheckout();
                goToStep(3);
            }
        });

        // ==========================================
        // STEP 3: MEMBER LOOKUP & PROMO APPLICATION
        // ==========================================
        const btnLookup = document.getElementById('btn-lookup');
        const memberPhoneInput = document.getElementById('member-phone');
        const memberCard = document.getElementById('member-card');
        
        btnLookup.addEventListener('click', () => {
            const phone = memberPhoneInput.value.trim();
            if (!phone) {
                alert('Vui lòng nhập số điện thoại');
                return;
            }

            btnLookup.disabled = true;
            btnLookup.innerHTML = `<span class="spinner-border spinner-border-sm" role="status"></span>`;

            fetch(contextPath + '/staff/customer-lookup?phone=' + phone)
                .then(res => res.json())
                .then(data => {
                    btnLookup.disabled = false;
                    btnLookup.innerHTML = `<i class="bi bi-search me-1"></i>Tìm`;

                    if (data.exists) {
                        state.memberPhone = phone;
                        state.memberUsername = data.username;
                        state.memberFullName = data.fullName;
                        state.memberEmail = data.email || '';

                        document.getElementById('member-name').innerText = data.fullName;
                        document.getElementById('member-username').innerText = data.username;
                        document.getElementById('member-email-display').innerText = data.email || 'Chưa cung cấp';
                        
                        memberCard.classList.remove('d-none');
                        document.getElementById('member-status-text').innerHTML = 
                            '<span class="text-success fw-semibold"><i class="bi bi-check-circle-fill me-1"></i>Đã chọn thành viên: ' + data.fullName + '</span>';

                    } else {
                        state.memberPhone = '';
                        state.memberUsername = 'guest01';
                        state.memberFullName = 'Khách vãng lai';
                        state.memberEmail = '';

                        memberCard.classList.add('d-none');
                        document.getElementById('member-status-text').innerHTML = `
                            <span class="text-warning"><i class="bi bi-exclamation-circle me-1"></i>Không tìm thấy thành viên. Đặt dưới dạng Khách vãng lai.</span>
                        `;
                    }
                })
                .catch(err => {
                    console.error(err);
                    btnLookup.disabled = false;
                    btnLookup.innerHTML = `<i class="bi bi-search me-1"></i>Tìm`;
                    alert('Lỗi tra cứu thành viên');
                });
        });

        // Apply Promotion Code
        const btnApplyPromo = document.getElementById('btn-apply-promo');
        const promoCodeInput = document.getElementById('promo-code');
        const promoSuccess = document.getElementById('promo-success-alert');
        const promoError = document.getElementById('promo-error-alert');

        btnApplyPromo.addEventListener('click', () => {
            const code = promoCodeInput.value.trim();
            if (!code) {
                // Clear promo
                state.promoCode = '';
                state.promoDiscount = 0;
                promoSuccess.classList.add('d-none');
                promoError.classList.add('d-none');
                document.getElementById('summary-discount').innerText = '0';
                calculateTotalCheckout();
                return;
            }

            btnApplyPromo.disabled = true;

            fetch(contextPath + '/staff/promo-validate?code=' + encodeURIComponent(code) + '&subtotal=' + state.subtotalAmount)
                .then(res => res.json())
                .then(data => {
                    btnApplyPromo.disabled = false;

                    if (data.valid) {
                        state.promoCode = code;
                        state.promoDiscount = data.discountAmount;
                        
                        promoSuccess.innerText = data.message;
                        promoSuccess.classList.remove('d-none');
                        promoError.classList.add('d-none');

                        document.getElementById('summary-discount').innerText = data.discountAmount.toLocaleString();
                        calculateTotalCheckout();
                    } else {
                        state.promoCode = '';
                        state.promoDiscount = 0;

                        promoError.innerText = data.message;
                        promoError.classList.remove('d-none');
                        promoSuccess.classList.add('d-none');

                        document.getElementById('summary-discount').innerText = '0';
                        calculateTotalCheckout();
                    }
                })
                .catch(err => {
                    console.error(err);
                    btnApplyPromo.disabled = false;
                    alert('Lỗi áp dụng khuyến mãi');
                });
        });

        function calculateTotalCheckout() {
            state.totalAmount = state.subtotalAmount - state.promoDiscount;
            if (state.totalAmount < 0) state.totalAmount = 0;
            document.getElementById('summary-total').innerText = state.totalAmount.toLocaleString();
        }

        document.getElementById('btn-to-step4').addEventListener('click', () => {
            // Fill step 4 invoice summary
            document.getElementById('invoice-movie').innerText = state.movieTitle;
            document.getElementById('invoice-time').innerText = state.startTime + ' ngày ' + state.date;
            document.getElementById('invoice-room').innerText = state.roomName + ' (' + state.roomType + ')';
            
            const seatLabels = state.selectedSeats.map(s => s.rowLabel + s.colNumber);
            document.getElementById('invoice-seats').innerText = seatLabels.join(', ');
            
            document.getElementById('invoice-customer').innerText = state.memberPhone 
                ? state.memberFullName + ' (' + state.memberPhone + ')'
                : 'Khách vãng lai (guest01)';
                
            document.getElementById('invoice-promo').innerText = state.promoCode 
                ? state.promoCode + ' (Giảm ' + state.promoDiscount.toLocaleString() + ' VND)'
                : 'Không có';
                
            document.getElementById('invoice-total').innerText = state.totalAmount.toLocaleString();
            
            // Clear inputs
            document.getElementById('cash-received').value = '';
            document.getElementById('cash-change').innerText = '0';
            document.getElementById('cash-error').classList.add('d-none');
            document.getElementById('btn-confirm-booking').disabled = true;

            goToStep(4);
        });

        // ==========================================
        // STEP 4: CASH PAYMENT FLOW
        // ==========================================
        const cashReceivedInput = document.getElementById('cash-received');
        const cashChangeText = document.getElementById('cash-change');
        const cashErrorAlert = document.getElementById('cash-error');
        const btnConfirmBooking = document.getElementById('btn-confirm-booking');

        cashReceivedInput.addEventListener('input', () => {
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

        btnConfirmBooking.addEventListener('click', () => {
            btnConfirmBooking.disabled = true;
            btnConfirmBooking.innerHTML = `<span class="spinner-border spinner-border-sm me-2" role="status"></span>ĐANG XỬ LÝ THANH TOÁN...`;

            // Prepare payload
            const seatIdsString = state.selectedSeats.map(s => s.seatId).join(',');
            
            const formData = new URLSearchParams();
            formData.append('showtimeId', state.showtimeId);
            formData.append('seatIds', seatIdsString);
            formData.append('customerPhone', state.memberPhone);
            formData.append('promoCode', state.promoCode);
            formData.append('notes', 'Đặt vé trực tiếp tại quầy bằng tiền mặt');

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
                    state.bookingCode = data.bookingCode;
                    state.bookingId = data.bookingId;
                    
                    // Fill Step 5 E-Ticket Details
                    document.getElementById('final-booking-code').innerText = data.bookingCode;
                    document.getElementById('final-movie').innerText = state.movieTitle;
                    document.getElementById('final-time').innerText = state.startTime + ' - ' + state.date;
                    
                    const seatLabels = state.selectedSeats.map(s => s.rowLabel + s.colNumber);
                    document.getElementById('final-seats').innerText = seatLabels.join(', ');

                    goToStep(5);
                } else {
                    btnConfirmBooking.disabled = false;
                    btnConfirmBooking.innerHTML = `<i class="bi bi-cash-stack me-2"></i>XÁC NHẬN THANH TOÁN TIỀN MẶT`;
                    alert('Đặt vé thất bại: ' + data.message);
                }
            })
            .catch(err => {
                console.error(err);
                btnConfirmBooking.disabled = false;
                btnConfirmBooking.innerHTML = `<i class="bi bi-cash-stack me-2"></i>XÁC NHẬN THANH TOÁN TIỀN MẶT`;
                alert('Có lỗi mạng xảy ra khi xử lý đặt vé.');
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
            // Close WebSocket on Step 5 (successful booking completion)
            if (stepNum === 5) {
                closeWS();
            }

            state.currentStep = stepNum;
            
            // Toggle panels
            document.querySelectorAll('.wizard-panel').forEach(p => p.classList.remove('active'));
            document.getElementById('panel-' + stepNum).classList.add('active');
            
            // Toggle indicators
            for (let i = 1; i <= 5; i++) {
                const ind = document.getElementById('step-ind-' + i);
                ind.classList.remove('active', 'completed');
                if (i < stepNum) {
                    ind.classList.add('completed');
                } else if (i === stepNum) {
                    ind.classList.add('active');
                }
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
                memberPhone: '',
                memberUsername: 'guest01',
                memberFullName: 'Khách vãng lai',
                memberEmail: '',
                promoCode: '',
                promoDiscount: 0,
                totalAmount: 0,
                subtotalAmount: 0,
                bookingCode: '',
                bookingId: null
            };

            // Clear inputs
            movieSearch.value = '';
            roomFilter.value = '';
            dateFilter.value = todayStr;
            memberPhoneInput.value = '';
            promoCodeInput.value = '';
            
            // Clear UI elements
            memberCard.classList.add('d-none');
            document.getElementById('member-status-text').innerHTML = `
                <i class="bi bi-info-circle me-1"></i> Để trống nếu khách hàng mua vé vãng lai (không đăng ký thành viên).
            `;
            promoSuccess.classList.add('d-none');
            promoError.classList.add('d-none');
            
            // Ensure WebSocket connection is closed on reset
            closeWS();

            // Refresh first page
            loadShowtimes();
            goToStep(1);
        }
    </script>
</body>
</html>
