<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    Payment Receipt - Customer (owner: HungNT). Theo SRS 3.3.2.3 + prototype
    15_receipt: hoa don tu Bookings + Payments. KHAC e-ticket (QR) o booking detail.
    Itemize dung phan da thanh toan (ve - giam gia = total). F&B la order rieng.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Payment Receipt · ${ticket.bookingCode} – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* --bk-* tokens come from tokens.css */
        body.rc-page { background: var(--bk-bg); }
        .rc-wrap { max-width: 720px; }
        .rc-crumb { font-size:.82rem; color:var(--bk-muted); }
        .rc-crumb a { color:var(--bk-muted); text-decoration:none; }
        .rc-crumb a:hover { color:var(--bk-primary); }

        .rc-badge { display:inline-flex; align-items:center; gap:.4rem; font-size:.74rem; font-weight:800;
            padding:.3rem .7rem; border-radius:999px; text-transform:uppercase; letter-spacing:.03em; }
        .rc-badge .dot { width:7px; height:7px; border-radius:50%; }
        .b-done { background:#dcfce7; color:#15803d; } .b-done .dot { background:var(--success); }
        .b-pend { background:#fef3c7; color:#b45309; } .b-pend .dot { background:var(--warning); }
        .b-fail { background:#fee2e2; color:#b91c1c; } .b-fail .dot { background:var(--danger); }
        .b-unpaid { background:#eef1f4; color:var(--text-muted); } .b-unpaid .dot { background:var(--text-subtle); }

        .rc-card { background:#fff; border:1px solid var(--bk-border); border-radius:16px; overflow:hidden;
            box-shadow:0 12px 32px rgba(15,23,42,.10); }
        .rc-head { background:linear-gradient(135deg,#13294f,var(--navy)); color:#fff; padding:24px 28px;
            display:flex; justify-content:space-between; align-items:flex-start; gap:16px; }
        .rc-brand { font-weight:800; font-size:1.15rem; display:flex; align-items:center; gap:.5rem; }
        .rc-brand i { color:var(--gold); }
        .rc-official { text-align:right; font-size:.68rem; letter-spacing:.1em; color:rgba(255,255,255,.6); }
        .rc-official .num { font-family:ui-monospace,Menlo,Consolas,monospace; font-size:.95rem; color:#fff; letter-spacing:0; }
        .rc-issued .lbl { font-size:.66rem; letter-spacing:.08em; color:rgba(255,255,255,.55); text-transform:uppercase; }
        .rc-issued .nm { font-weight:700; font-size:1.05rem; margin-top:2px; }
        .rc-issued .em { font-size:.84rem; color:rgba(255,255,255,.7); }

        .rc-body { padding:24px 28px; }
        .rc-grid { display:grid; grid-template-columns:repeat(3,1fr); gap:18px 16px; }
        .rc-grid .lbl { font-size:.68rem; text-transform:uppercase; letter-spacing:.05em; color:var(--text-subtle); font-weight:700; }
        .rc-grid .val { font-weight:700; color:var(--bk-navy); margin-top:3px; }
        .rc-grid .val.mono { font-family:ui-monospace,Menlo,Consolas,monospace; font-weight:600; font-size:.9rem; }
        .rc-hr { border:none; border-top:1px dashed var(--bk-border); margin:22px 0; }

        .rc-items { width:100%; }
        .rc-items th { font-size:.68rem; text-transform:uppercase; letter-spacing:.05em; color:var(--text-subtle); font-weight:700;
            padding-bottom:8px; border-bottom:1px solid var(--bk-border); }
        .rc-items td { padding:12px 0; border-bottom:1px solid #f1f5f9; vertical-align:top; }
        .rc-items .desc { font-weight:700; color:var(--bk-navy); }
        .rc-items .sub { font-size:.78rem; color:var(--bk-muted); }
        .rc-items .num { font-variant-numeric:tabular-nums; }

        .rc-tot { margin-left:auto; max-width:320px; margin-top:18px; }
        .rc-tot .row { display:flex; justify-content:space-between; padding:5px 0; font-size:.92rem; }
        .rc-tot .row .k { color:var(--bk-muted); }
        .rc-tot .row.disc .v { color:var(--success); }
        .rc-tot .grand { border-top:2px solid var(--bk-navy); margin-top:8px; padding-top:12px;
            font-weight:800; font-size:1.05rem; color:var(--bk-navy); }
        .rc-tot .grand .v { color:var(--bk-primary); font-size:1.3rem; }

        .rc-note { background:var(--bg); border-top:1px solid var(--bk-border); padding:16px 28px;
            text-align:center; font-size:.82rem; color:var(--bk-muted); }
        .seat-chip { display:inline-block; background:var(--primary-50); color:var(--bk-primary); border:1px solid var(--primary-200);
            border-radius:6px; padding:0 7px; font-weight:700; font-size:.76rem; margin:1px 3px 1px 0;
            font-family:ui-monospace,Menlo,Consolas,monospace; }

        @media print {
            body.rc-page { background:#fff; }
            .no-print { display:none !important; }
            .rc-card { box-shadow:none; border:1px solid #ccc; }
        }
    </style>
</head>
<body class="rc-page">

<div class="no-print"><jsp:include page="/WEB-INF/views/common/header.jsp"/></div>

<div class="container rc-wrap py-4">

    <%-- ===== Breadcrumb + title ===== --%>
    <div class="rc-crumb mb-2 no-print">
        <a href="${pageContext.request.contextPath}/home">Home</a> /
        <a href="${pageContext.request.contextPath}/customer/payments">Payments</a> /
        Receipt · ${ticket.bookingCode}
    </div>
    <div class="d-flex align-items-center gap-3 mb-4">
        <h3 class="fw-bold mb-0" style="color:var(--bk-navy);">Payment Receipt</h3>
        <c:choose>
            <c:when test="${empty payment}"><span class="rc-badge b-unpaid"><span class="dot"></span>Unpaid</span></c:when>
            <c:when test="${payment.status eq 'SUCCESS'}"><span class="rc-badge b-done"><i class="bi bi-check-circle-fill"></i>Completed</span></c:when>
            <c:when test="${payment.status eq 'FAILED'}"><span class="rc-badge b-fail"><i class="bi bi-x-circle-fill"></i>Failed</span></c:when>
            <c:otherwise><span class="rc-badge b-pend"><span class="dot"></span>Pending</span></c:otherwise>
        </c:choose>
    </div>

    <%-- ===== Receipt card ===== --%>
    <div class="rc-card">
        <div class="rc-head">
            <div>
                <div class="rc-brand"><i class="bi bi-camera-reels-fill"></i> MBCMS</div>
                <div class="rc-issued mt-4">
                    <div class="lbl">Issued to</div>
                    <div class="nm"><c:out value="${ticket.customerFullName}"/></div>
                    <div class="em"><c:out value="${ticket.customerEmail}"/></div>
                </div>
            </div>
            <div class="rc-official">
                OFFICIAL RECEIPT
                <div class="num">#${ticket.bookingCode}</div>
            </div>
        </div>

        <div class="rc-body">
            <%-- Payment meta --%>
            <div class="rc-grid">
                <div>
                    <div class="lbl">Payment status</div>
                    <div class="val">
                        <c:choose>
                            <c:when test="${empty payment}">Unpaid</c:when>
                            <c:when test="${payment.status eq 'SUCCESS'}">Completed</c:when>
                            <c:otherwise>${payment.status}</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div>
                    <div class="lbl">Payment method</div>
                    <div class="val"><c:out value="${empty payment ? '—' : payment.method}"/></div>
                </div>
                <div>
                    <div class="lbl">Paid time</div>
                    <div class="val">
                        <c:choose>
                            <c:when test="${not empty paidAt}">${fn:substring(paidAt,0,10)} ${fn:substring(paidAt,11,16)}</c:when>
                            <c:otherwise>—</c:otherwise>
                        </c:choose>
                    </div>
                </div>
                <div>
                    <div class="lbl">Transaction reference</div>
                    <div class="val mono"><c:out value="${empty payment.transactionRef ? '—' : payment.transactionRef}"/></div>
                </div>
                <div>
                    <div class="lbl">Booking code</div>
                    <div class="val mono">${ticket.bookingCode}</div>
                </div>
                <div>
                    <div class="lbl">Cinema</div>
                    <div class="val"><c:out value="${ticket.branchName}"/>
                        <c:if test="${not empty ticket.roomName}"> · <c:out value="${ticket.roomName}"/></c:if></div>
                </div>
                <div style="grid-column:1 / -1;">
                    <div class="lbl">Movie · Showtime</div>
                    <div class="val"><c:out value="${ticket.movieTitle}"/>
                        <c:if test="${not empty ticket.startTime}">
                            · ${fn:substring(ticket.startTime,0,10)} ${fn:substring(ticket.startTime,11,16)}</c:if></div>
                </div>
            </div>

            <hr class="rc-hr">

            <%-- Itemized --%>
            <table class="rc-items">
                <thead>
                    <tr>
                        <th class="text-start">Description</th>
                        <th class="text-center">Qty</th>
                        <th class="text-end">Unit price</th>
                        <th class="text-end">Amount</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <div class="desc">Movie ticket<c:if test="${not empty ticket.format}"> — ${ticket.format}</c:if></div>
                            <div class="sub">Seats:
                                <c:forEach var="s" items="${ticket.seatLabels}"><span class="seat-chip">${s}</span></c:forEach>
                            </div>
                        </td>
                        <td class="text-center num">${seatCount}</td>
                        <td class="text-end num"><fmt:formatNumber value="${unitPrice}" pattern="#,###"/>₫</td>
                        <td class="text-end num fw-bold"><fmt:formatNumber value="${ticket.subtotal}" pattern="#,###"/>₫</td>
                    </tr>
                </tbody>
            </table>

            <%-- Totals --%>
            <div class="rc-tot">
                <div class="row"><span class="k">Subtotal</span>
                    <span class="v num"><fmt:formatNumber value="${ticket.subtotal}" pattern="#,###"/>₫</span></div>
                <c:if test="${ticket.discountAmount > 0}">
                    <div class="row disc"><span class="k">Discount</span>
                        <span class="v num">−<fmt:formatNumber value="${ticket.discountAmount}" pattern="#,###"/>₫</span></div>
                </c:if>
                <div class="row grand"><span class="k">Total Paid</span>
                    <span class="v num"><fmt:formatNumber value="${ticket.totalAmount}" pattern="#,###"/>₫</span></div>
            </div>
        </div>

        <div class="rc-note">
            Thank you for choosing <strong>MBCMS</strong>. This receipt is your proof of payment.
        </div>
    </div>

    <%-- ===== Actions ===== --%>
    <div class="d-flex justify-content-center gap-2 mt-4 no-print">
        <c:if test="${not empty payment and payment.status eq 'SUCCESS'}">
            <a class="btn btn-primary fw-semibold"
               href="${pageContext.request.contextPath}/customer/payment/receipt/pdf?bookingId=${ticket.bookingId}">
                <i class="bi bi-download"></i> Download Receipt (PDF)</a>
        </c:if>
        <button class="btn btn-outline-primary fw-semibold" onclick="window.print()">
            <i class="bi bi-printer"></i> Print</button>
        <a class="btn btn-outline-primary fw-semibold"
           href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${ticket.bookingId}">
            <i class="bi bi-ticket-detailed"></i> View E-Ticket</a>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
