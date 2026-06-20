<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
    Payment screen - FRONTEND SCAFFOLD (owner: HungNT).
    Booking step 5/6. UI khung de team wire BACKEND vao:
    - Du lieu (movie, seats, gia, ref, QR) dang la SAMPLE, danh dau TODO(backend).
    - Servlet /booking/payment se forward vao day va do du lieu that qua request attr.
    Layout public (header.jsp + main.css). Ngon ngu: English (dong bo toan he thong).
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        :root {
            --bk-primary:#2563EB; --bk-navy:#0F1E36; --bk-border:#E6EAF2;
            --bk-muted:#64748B; --bk-light:#EFF4FF; --bk-bg:#F5F7FA;
        }
        body { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }

        /* ===== Showtime context bar ===== */
        .bk-ctx { background:#fff; border-bottom:1px solid var(--bk-border); }
        .bk-poster { width:46px; height:60px; border-radius:8px; object-fit:cover;
            background:linear-gradient(135deg,#1e293b,#0f172a); display:flex;
            align-items:center; justify-content:center; color:#FFC107; font-weight:800; }
        .bk-reserve { background:#FFF8E1; border:1px solid #FFE082; color:#7a5a00;
            border-radius:999px; padding:.3rem .8rem; font-size:.82rem; font-weight:600;
            display:inline-flex; align-items:center; gap:.4rem; }

        /* ===== Stepper ===== */
        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:#94a3b8; white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:#E2E8F0; color:#64748b; flex-shrink:0; }
        .bk-step.done  { color:#16a34a; }
        .bk-step.done  .bk-dot { background:#16a34a; color:#fff; }
        .bk-step.active { color:var(--bk-primary); }
        .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:#E2E8F0; margin:0 .5rem; min-width:14px; }
        .bk-line.done { background:#16a34a; }

        /* ===== Card / panel ===== */
        .bk-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px;
            box-shadow:0 4px 12px rgba(15,23,42,.05); }
        .bk-summary { position:sticky; top:18px; }

        /* ===== Payment method cards ===== */
        .pm { border:1.6px solid var(--bk-border); border-radius:12px; padding:.9rem 1rem; cursor:pointer;
            display:flex; align-items:center; gap:.9rem; transition:border-color .12s, background .12s; background:#fff; }
        .pm:hover { border-color:#9bbcf7; }
        .pm.active { border-color:var(--bk-primary); background:var(--bk-light); }
        .pm input { width:18px; height:18px; flex-shrink:0; }
        .pm-logo { width:46px; height:30px; border-radius:6px; display:flex; align-items:center;
            justify-content:center; font-weight:800; font-size:.7rem; color:#fff; flex-shrink:0; }
        .pm-vnpay { background:#0d4a9c; } .pm-momo { background:#a50064; } .pm-bank { background:#334155; }
        .pm-title { font-weight:700; color:var(--bk-navy); }
        .pm-desc { font-size:.8rem; color:var(--bk-muted); }

        /* ===== QR ===== */
        .bk-qr { width:200px; height:200px; border:2px dashed #cbd5e1; border-radius:12px;
            display:flex; flex-direction:column; align-items:center; justify-content:center;
            color:#94a3b8; margin:0 auto; background:#fafbfc; }
        .bk-info { background:var(--bk-light); border:1px solid #cfe0fb; color:#1e40af;
            border-radius:10px; padding:.6rem .85rem; font-size:.82rem; display:flex; gap:.5rem; align-items:flex-start; }
        .bk-warn { background:#FFF8E1; border:1px solid #FFE082; color:#7a5a00;
            border-radius:10px; padding:.6rem .85rem; font-size:.82rem; }
        .mono { font-family:ui-monospace,Menlo,Consolas,monospace; }
        .sum-line { display:flex; justify-content:space-between; align-items:center; padding:.35rem 0; font-size:.92rem; }
        .scaffold-tag { background:#fff7ed; border:1px solid #fed7aa; color:#9a3412;
            border-radius:8px; padding:.4rem .7rem; font-size:.78rem; }
    </style>
</head>
<body>

<jsp:include page="../common/header.jsp" />

<%-- TODO(backend): remove this banner once real data is wired in --%>
<div class="container bk-wrap pt-3">
    <div class="scaffold-tag"><i class="bi bi-tools"></i>
        Frontend scaffold — sample data. Backend supplies real values (movie, seats, prices, ref, QR) via request attributes.</div>
</div>

<%-- ===== Showtime context bar ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <div class="bk-poster">A</div>
            <div class="flex-grow-1">
                <div class="fw-bold" style="color:var(--bk-navy);">Avengers: Endgame</div>
                <div class="text-muted small">Cinema Alpha · Room A · Sat 17 May 2026 · 18:30</div>
            </div>
            <div class="text-end">
                <div class="text-muted small">Seats</div>
                <div class="fw-bold mono" style="color:var(--bk-navy);">C5, C6</div>
            </div>
            <span class="bk-reserve"><i class="bi bi-clock-history"></i> Reserved for 09:46</span>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <%-- ===== Stepper (5/6 Payment) ===== --%>
    <div class="bk-steps mb-4">
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Seats</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Food &amp; Drinks</div>
        <div class="bk-line done"></div>
        <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Review</div>
        <div class="bk-line done"></div>
        <div class="bk-step active"><span class="bk-dot">5</span>Payment</div>
        <div class="bk-line"></div>
        <div class="bk-step"><span class="bk-dot">6</span>Confirm</div>
    </div>

    <h3 class="fw-bold mb-1" style="color:var(--bk-navy);">
        <i class="bi bi-shield-lock-fill text-success"></i> Complete Your Payment</h3>
    <p class="text-muted mb-4">Your booking is reserved while you complete the payment.</p>

    <div class="row g-4">

        <%-- ===== Left: payment methods ===== --%>
        <div class="col-lg-7">
            <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Select Payment Method</h6>

            <div class="d-flex flex-column gap-2 mb-3">
                <label class="pm active" data-method="vnpay">
                    <input type="radio" name="method" value="VNPAY" checked onchange="selectMethod(this)">
                    <span class="pm-logo pm-vnpay">VNPAY</span>
                    <span><span class="pm-title">VNPay</span>
                        <div class="pm-desc">Scan QR code or pay via VNPay app — all major banks supported</div></span>
                    <i class="bi bi-shield-check ms-auto text-muted"></i>
                </label>
                <label class="pm" data-method="momo">
                    <input type="radio" name="method" value="MOMO" onchange="selectMethod(this)">
                    <span class="pm-logo pm-momo">MoMo</span>
                    <span><span class="pm-title">MoMo Wallet</span>
                        <div class="pm-desc">Pay with your MoMo balance</div></span>
                    <i class="bi bi-shield-check ms-auto text-muted"></i>
                </label>
                <label class="pm" data-method="bank">
                    <input type="radio" name="method" value="BANK" onchange="selectMethod(this)">
                    <span class="pm-logo pm-bank"><i class="bi bi-bank"></i></span>
                    <span><span class="pm-title">Bank Transfer</span>
                        <div class="pm-desc">Manual bank transfer with reference code</div></span>
                    <i class="bi bi-shield-check ms-auto text-muted"></i>
                </label>
            </div>

            <%-- TODO(backend): reference = real booking_code --%>
            <div class="bk-info mb-3">
                <i class="bi bi-info-circle-fill"></i>
                <span>Transaction Reference: <strong class="mono">BK20260517-00245</strong>
                    — include this in your payment description.</span>
            </div>

            <%-- Method-specific panel --%>
            <div class="bk-card p-4" id="panel-vnpay">
                <div class="text-center fw-bold mb-1" style="color:var(--bk-navy);">Scan to pay with VNPay</div>
                <div class="text-center text-muted small mb-3">Open your banking app and scan this QR code</div>
                <%-- TODO(backend): replace placeholder with real QR (e.g. ZXing) --%>
                <div class="bk-qr">
                    <i class="bi bi-qr-code" style="font-size:4rem;"></i>
                    <div class="small mt-2">QR generated by backend</div>
                </div>
                <div class="bk-warn mt-3"><i class="bi bi-exclamation-triangle"></i>
                    Do not close this page until your payment is confirmed.</div>
            </div>

            <div class="bk-card p-4 d-none" id="panel-momo">
                <div class="text-center text-muted py-3">
                    <i class="bi bi-phone" style="font-size:2rem;"></i>
                    <div class="mt-2">You will be redirected to the MoMo app to confirm your payment.</div>
                </div>
            </div>

            <div class="bk-card p-4 d-none" id="panel-bank">
                <div class="fw-bold mb-2" style="color:var(--bk-navy);">Bank transfer details</div>
                <div class="sum-line"><span class="text-muted">Bank</span><span class="fw-semibold">Vietcombank</span></div>
                <div class="sum-line"><span class="text-muted">Account number</span><span class="fw-semibold mono">0123456789</span></div>
                <div class="sum-line"><span class="text-muted">Account name</span><span class="fw-semibold">MBCMS JSC</span></div>
                <div class="sum-line"><span class="text-muted">Description</span><span class="fw-semibold mono">BK20260517-00245</span></div>
            </div>
        </div>

        <%-- ===== Right: order summary ===== --%>
        <div class="col-lg-5">
            <div class="bk-card p-4 bk-summary">
                <h6 class="fw-bold mb-3" style="color:var(--bk-navy);">Order Summary</h6>
                <div class="d-flex gap-3 mb-3 pb-3" style="border-bottom:1px solid var(--bk-border);">
                    <div class="bk-poster">A</div>
                    <div>
                        <div class="fw-bold" style="color:var(--bk-navy);">Avengers: Endgame</div>
                        <div class="text-muted small">Sat 17 May 2026 · 18:30</div>
                        <div class="text-muted small">Cinema Alpha · Room A</div>
                        <div class="small mt-1">Seats: <strong class="mono">C5, C6</strong></div>
                    </div>
                </div>
                <%-- TODO(backend): amounts from the real booking --%>
                <div class="sum-line"><span class="text-muted">Subtotal</span><span>265,000₫</span></div>
                <div class="sum-line"><span class="text-muted">Discount (SUMMER10)</span><span class="text-success">−26,500₫</span></div>
                <div class="sum-line pt-2" style="border-top:1px solid var(--bk-border);">
                    <span class="fw-bold" style="color:var(--bk-navy);">Total</span>
                    <span class="fw-bold fs-5" style="color:var(--bk-primary);">238,500₫</span>
                </div>

                <%-- TODO(backend): submit -> servlet confirms payment (POST) --%>
                <button class="btn btn-primary w-100 mt-3 py-2 fw-semibold" type="button" onclick="alert('Frontend scaffold — backend handles this.');">
                    I have completed the payment
                </button>
                <div class="text-center text-muted small mt-2">
                    <i class="bi bi-shield-lock"></i> SSL Secured · <i class="bi bi-patch-check"></i> VNPay Certified
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="../common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Switch the method-specific panel (frontend only).
    function selectMethod(radio) {
        document.querySelectorAll('.pm').forEach(function (el) { el.classList.remove('active'); });
        radio.closest('.pm').classList.add('active');
        ['vnpay', 'momo', 'bank'].forEach(function (m) {
            document.getElementById('panel-' + m).classList.toggle('d-none', m !== radio.closest('.pm').dataset.method);
        });
    }
</script>
</body>
</html>
