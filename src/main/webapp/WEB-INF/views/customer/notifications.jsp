<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Thông Báo – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        body { background: var(--bg); }

        /* ── Sidebar (copied from profile.jsp pattern) ── */
        .lc-elev {
            background: #fff;
            border: none;
            border-radius: 14px;
            box-shadow: 0 1px 3px rgba(15,30,54,.08), 0 8px 24px rgba(15,30,54,.04);
        }
        .lc-avatar {
            width: 72px; height: 72px;
            border-radius: 50%;
            background: linear-gradient(135deg,var(--primary),#1e3a5f);
            color: #fff;
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 1.55rem;
        }
        .lc-navitem {
            display: flex; align-items: center; gap: .6rem;
            padding: .55rem .85rem; border-radius: 8px;
            font-size: .92rem; font-weight: 500;
            color: #475569; text-decoration: none; margin-bottom: 2px;
            transition: background .12s, color .12s;
        }
        .lc-navitem:hover  { background: #f1f5fb; color: var(--primary); }
        .lc-navitem.active { background: #e8f0fe; color: var(--primary); font-weight: 600; }
        .lc-navitem i { width: 18px; text-align: center; font-size: 1rem; }
        .lc-navitem .lc-badge {
            margin-left: auto;
            background: var(--danger); color: #fff;
            font-size: .67rem; font-weight: 700;
            padding: 1px 6px; border-radius: 99px;
            line-height: 1.5;
        }

        /* ── Main card ── */
        .notif-page-card {
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 1px 3px rgba(15,30,54,.08), 0 8px 24px rgba(15,30,54,.04);
            overflow: hidden;
        }

        /* ── Header ── */
        .notif-page-header {
            padding: 20px 24px 16px;
            border-bottom: 1px solid #f1f5f9;
        }
        .notif-page-header h4 {
            font-size: 1.25rem;
            font-weight: 700;
            color: var(--text-dark);
            margin: 0;
            display: flex; align-items: center; gap: 10px;
        }
        .new-badge {
            font-size: .72rem; font-weight: 700;
            background: var(--primary-100); color: var(--primary-700);
            padding: 2px 9px; border-radius: 99px;
        }
        .mark-all-btn {
            background: none; border: none; cursor: pointer;
            font-size: .83rem; font-weight: 600;
            color: var(--primary);
            display: flex; align-items: center; gap: 4px;
            padding: 0; transition: opacity .15s;
        }
        .mark-all-btn:hover { opacity: .7; }

        /* ── Filter tabs ── */
        .filter-strip {
            display: flex; gap: 4px; flex-wrap: wrap;
            padding: 12px 24px;
            border-bottom: 1px solid #f1f5f9;
            background: #fafbfc;
        }
        .ftab {
            padding: 5px 14px;
            border-radius: 99px;
            font-size: .78rem; font-weight: 600;
            border: 1.5px solid var(--border);
            background: #fff; color: var(--text-muted);
            cursor: pointer; text-decoration: none;
            transition: all .12s;
            white-space: nowrap;
        }
        .ftab:hover       { border-color: var(--primary); color: var(--primary); }
        .ftab.active      { background: var(--primary); border-color: var(--primary); color: #fff; }

        /* ── Notification item ── */
        .nitem {
            display: flex; align-items: center; gap: 14px;
            padding: 16px 24px;
            border-bottom: 1px solid #f1f5f9;
            border-left: 3px solid transparent;
            text-decoration: none; color: inherit;
            transition: background .12s;
            position: relative;
        }
        .nitem:last-child { border-bottom: none; }
        .nitem:hover      { background: var(--bg); }
        .nitem.unread     { background: #f8fbff; }

        /* Unread được nhận biết qua nền + chấm cạnh tiêu đề; bỏ thanh màu trái gây rối. */

        /* Icon circle */
        .nicon {
            width: 40px; height: 40px; border-radius: 10px; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.05rem;
        }
        .nicon.BOOKING   { background: var(--primary-100); color: var(--primary); }
        .nicon.PAYMENT   { background: #dcfce7; color: var(--success); }
        .nicon.PROMOTION { background: #ffedd5; color: #ea580c; }
        .nicon.REMINDER  { background: #fef9c3; color: #ca8a04; }
        .nicon.SYSTEM    { background: #ede9fe; color: #7c3aed; }

        .nbody { flex: 1; min-width: 0; }

        .ntitle {
            font-size: .9rem; font-weight: 700;
            color: var(--text-dark);
            margin: 0 0 3px;
            display: flex; align-items: center; gap: 7px;
        }
        .unread-dot {
            width: 7px; height: 7px; border-radius: 50%;
            background: var(--primary); flex-shrink: 0;
        }
        .ncontent {
            font-size: .82rem; color: #4b5563;
            line-height: 1.55; margin: 0 0 6px;
        }
        /* Highlight key info in content */
        .ncontent strong { color: var(--text-dark); }
        .ncontent .hl-blue   { color: var(--primary); font-weight: 600; }
        .ncontent .hl-green  { color: var(--success); font-weight: 600; }
        .ncontent .hl-orange { color: #ea580c; font-weight: 600; }

        .nmeta {
            display: flex; align-items: center; gap: 10px;
            font-size: .74rem; color: #9ca3af;
        }
        .nview-link {
            font-size: .78rem; font-weight: 600;
            color: var(--primary); text-decoration: none;
            display: inline-flex; align-items: center; gap: 3px;
        }
        .nview-link:hover { text-decoration: underline; }

        /* Type badge (top-right) */
        .ntype-badge {
            position: absolute; top: 14px; right: 20px;
            font-size: .67rem; font-weight: 700;
            padding: 2px 9px; border-radius: 99px;
            white-space: nowrap;
        }
        .ntype-badge.BOOKING   { background: var(--primary-100); color: var(--primary-700); }
        .ntype-badge.PAYMENT   { background: #dcfce7; color: #15803d; }
        .ntype-badge.PROMOTION { background: #ffedd5; color: #c2410c; }
        .ntype-badge.REMINDER  { background: #fef9c3; color: #92400e; }
        .ntype-badge.SYSTEM    { background: #ede9fe; color: #6d28d9; }

        /* ── Load more ── */
        .load-more-wrap { padding: 18px 24px; text-align: center; border-top: 1px solid #f1f5f9; }
        .btn-load-more {
            background: none; border: none;
            font-size: .85rem; font-weight: 600;
            color: var(--text-muted); cursor: pointer;
            transition: color .12s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-load-more:hover { color: var(--primary); }

        /* ── Empty state ── */
        .notif-empty-state {
            padding: 56px 24px; text-align: center;
        }
        .notif-empty-state .ei { font-size: 3rem; margin-bottom: 12px; }
        .notif-empty-state h5 { font-weight: 700; color: #374151; margin-bottom: 6px; }
        .notif-empty-state p  { font-size: .85rem; color: #9ca3af; margin: 0; }

        @media (max-width: 768px) {
            .nitem { padding: 14px 16px; }
            .ntype-badge { display: none; }
            .filter-strip { padding: 10px 16px; }
            .notif-page-header { padding: 16px 16px 12px; }
        }
    </style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <c:set var="cu" value="${sessionScope.currentUser}"/>

    <div class="container py-4" style="max-width:1100px;">
        <div class="row g-4">

            <%-- ══════════ SIDEBAR ══════════ --%>
            <div class="col-lg-3">
                <div class="card lc-elev p-3">
                    <div class="d-flex flex-column align-items-center text-center py-3 mb-2"
                         style="border-bottom:1px solid #eef1f5;">
                        <div class="lc-avatar mb-2">
                            ${fn:toUpperCase(fn:substring(cu.fullName, 0, 1))}
                        </div>
                        <h6 class="fw-bold mb-0" style="color:var(--text-dark);">
                            <c:out value="${cu.fullName}"/>
                        </h6>
                        <div class="text-muted small">@<c:out value="${cu.username}"/></div>
                        <div class="small mt-1">
                            <c:choose>
                                <c:when test="${cu.emailVerified}">
                                    <i class="bi bi-patch-check-fill text-success"></i>
                                    <span class="text-muted">Email verified</span>
                                </c:when>
                                <c:otherwise>
                                    <i class="bi bi-exclamation-circle text-warning"></i>
                                    <span class="text-muted">Email not verified</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>

                    <nav class="d-flex flex-column">
                        <a class="lc-navitem"
                           href="${pageContext.request.contextPath}/customer/profile">
                            <i class="bi bi-person"></i> Profile
                        </a>
                        <a class="lc-navitem"
                           href="${pageContext.request.contextPath}/auth/change-password">
                            <i class="bi bi-shield-lock"></i> Security
                        </a>
                        <a class="lc-navitem"
                           href="${pageContext.request.contextPath}/customer/booking/history">
                            <i class="bi bi-ticket-perforated"></i> My Bookings
                        </a>
                        <a class="lc-navitem active"
                           href="${pageContext.request.contextPath}/customer/notifications">
                            <i class="bi bi-bell"></i> Notifications
                            <c:if test="${unreadCount > 0}">
                                <span class="lc-badge">${unreadCount}</span>
                            </c:if>
                        </a>
                        <a class="lc-navitem" href="${pageContext.request.contextPath}/customer/complaints">
                            <i class="bi bi-exclamation-circle"></i> Khiếu nại
                        </a>
                        <a class="lc-navitem" href="${pageContext.request.contextPath}/customer/support">
                            <i class="bi bi-headset"></i> Hỗ trợ
                        </a>
                        <hr style="margin:10px 0;border-color:#eef1f5;">
                        <form method="post" action="${pageContext.request.contextPath}/auth/logout" class="m-0">
                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <button type="submit" class="lc-navitem" style="color:var(--danger);border:0;background:none;width:100%;text-align:left;cursor:pointer;">
                                <i class="bi bi-box-arrow-right"></i> Sign out
                            </button>
                        </form>
                    </nav>
                </div>
            </div>

            <%-- ══════════ MAIN CONTENT ══════════ --%>
            <div class="col-lg-9">
                <div class="notif-page-card">

                    <%-- Header --%>
                    <div class="notif-page-header">
                        <div class="d-flex align-items-center justify-content-between">
                            <h4>
                                Notifications
                                <c:if test="${unreadCount > 0}">
                                    <span class="new-badge">${unreadCount} new</span>
                                </c:if>
                            </h4>
                            <c:if test="${unreadCount > 0}">
                                <button class="mark-all-btn" id="markAllBtn">
                                    <i class="bi bi-check2-all"></i> Mark all as read
                                </button>
                            </c:if>
                        </div>
                        <p class="text-muted small mb-0 mt-1">
                            Showtime reminders, booking updates, and promotions.
                        </p>
                    </div>

                    <%-- Filter tabs — counts from JS via data attributes --%>
                    <div class="filter-strip">
                        <a href="#" class="ftab active" data-filter="ALL">
                            All (${totalCount})
                        </a>
                        <a href="#" class="ftab" data-filter="BOOKING">Bookings</a>
                        <a href="#" class="ftab" data-filter="PAYMENT">Payments</a>
                        <a href="#" class="ftab" data-filter="PROMOTION">Promotions</a>
                        <a href="#" class="ftab" data-filter="REMINDER">Reminders</a>
                        <a href="#" class="ftab" data-filter="SYSTEM">System</a>
                    </div>

                    <%-- Notification list (rendered by JS from API) --%>
                    <div id="notifPageList">
                        <div class="notif-empty-state">
                            <div class="ei"><i class="bi bi-hourglass-split"></i></div>
                            <h5>Loading...</h5>
                        </div>
                    </div>

                    <%-- Load more --%>
                    <div class="load-more-wrap" id="loadMoreWrap" style="display:none;">
                        <button class="btn-load-more" id="loadMoreBtn">
                            <i class="bi bi-arrow-down-circle"></i>
                            Load older notifications
                        </button>
                    </div>

                </div><%-- /.notif-page-card --%>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <script>
    (function () {
        var ctx       = '${pageContext.request.contextPath}';
        var PAGE_SIZE = 15;

        var state = {
            all:    [],          // all fetched notifications
            filtered: [],        // after type filter
            shown:  0,           // how many rendered
            activeFilter: 'ALL',
            loading: false
        };

        // ── Icon map (inline SVG, same stroke style as header) ───────────────
        var icons = {
            BOOKING:
                '<i class="bi bi-ticket-perforated"></i>',
            PAYMENT:
                '<i class="bi bi-credit-card"></i>',
            PROMOTION:
                '<i class="bi bi-gift"></i>',
            REMINDER:
                '<i class="bi bi-alarm"></i>',
            SYSTEM:
                '<i class="bi bi-shield-lock"></i>'
        };

        var typeLabels = {
            BOOKING:   'Bookings',
            PAYMENT:   'Payments',
            PROMOTION: 'Promotions',
            REMINDER:  'Reminders',
            SYSTEM:    'System'
        };

        // ── Relative time (UTC → local) ──────────────────────────────────────
        function timeAgo(isoStr) {
            if (!isoStr) return '';
            var d    = new Date(isoStr + 'Z');
            var diff = Math.floor((Date.now() - d.getTime()) / 1000);
            if (diff < 60)    return 'Just now';
            if (diff < 3600)  return Math.floor(diff / 60)   + ' minutes ago';
            if (diff < 86400) return Math.floor(diff / 3600) + ' hours ago';
            if (diff < 604800) return Math.floor(diff / 86400) + ' days ago';
            // Older: format as "10 May 2026"
            return d.toLocaleDateString('en-GB', { day:'numeric', month:'short', year:'numeric' });
        }

        // ── Build one notification row ────────────────────────────────────────
        function buildItem(n) {
            var a       = document.createElement('a');
            a.className = 'nitem ' + n.type + (n.read ? '' : ' unread');
            a.href      = n.linkUrl || '#';
            a.dataset.notiId = n.id;

            var viewLink = (n.linkUrl && n.linkUrl !== '#')
                ? '<a href="' + n.linkUrl + '" class="nview-link">'
                  + 'View booking <i class="bi bi-arrow-right"></i></a>'
                : '';

            a.innerHTML =
                '<div class="nicon ' + n.type + '">'
                + (icons[n.type] || icons.SYSTEM) + '</div>'
                + '<div class="nbody">'
                +   '<p class="ntitle">'
                +     n.title
                +     (n.read ? '' : '<span class="unread-dot"></span>')
                +   '</p>'
                +   '<p class="ncontent">' + n.content + '</p>'
                +   '<div class="nmeta">'
                +     '<span>' + timeAgo(n.createdAt) + '</span>'
                +     (viewLink ? '<span>·</span>' + viewLink : '')
                +   '</div>'
                + '</div>'
                + '<span class="ntype-badge ' + n.type + '">'
                + (typeLabels[n.type] || n.type) + '</span>';

            // Mark as read on click (only for unread with a real link)
            if (!n.read) {
                a.addEventListener('click', function (e) {
                    if (!n.linkUrl || n.linkUrl === '#') return;
                    e.preventDefault();
                    fetch(ctx + '/api/notifications?id=' + n.id, {
                        method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-TOKEN': '${sessionScope.csrfToken}' }
                    }).finally(function () {
                        window.location.href = n.linkUrl;
                    });
                });
            }
            return a;
        }

        // ── Render next PAGE_SIZE items ───────────────────────────────────────
        function renderBatch() {
            var list   = document.getElementById('notifPageList');
            var batch  = state.filtered.slice(state.shown, state.shown + PAGE_SIZE);

            if (state.shown === 0) {
                list.innerHTML = '';
                if (state.filtered.length === 0) {
                    list.innerHTML =
                        '<div class="notif-empty-state">'
                        + '<div class="ei"><i class="bi bi-bell-slash"></i></div>'
                        + '<h5>No notifications</h5>'
                        + '<p>Booking confirmations, payment receipts, and promotions will appear here.</p>'
                        + '</div>';
                    document.getElementById('loadMoreWrap').style.display = 'none';
                    return;
                }
            }

            batch.forEach(function (n) {
                list.appendChild(buildItem(n));
            });
            state.shown += batch.length;

            // Show / hide "load more"
            var wrap = document.getElementById('loadMoreWrap');
            wrap.style.display = state.shown < state.filtered.length ? 'block' : 'none';
        }

        // ── Apply filter ──────────────────────────────────────────────────────
        function applyFilter(type) {
            state.activeFilter = type;
            state.filtered     = (type === 'ALL')
                ? state.all
                : state.all.filter(function (n) { return n.type === type; });
            state.shown        = 0;

            // Update filter tab counts
            document.querySelectorAll('.ftab').forEach(function (tab) {
                var f = tab.dataset.filter;
                tab.classList.toggle('active', f === type);
                if (f === 'ALL') {
                    tab.textContent = 'All (' + state.all.length + ')';
                } else {
                    var cnt = state.all.filter(function (n) { return n.type === f; }).length;
                    tab.textContent = typeLabels[f] + (cnt ? ' (' + cnt + ')' : '');
                }
            });

            renderBatch();
        }

        // ── Fetch from API ────────────────────────────────────────────────────
        function fetchNotifications() {
            if (state.loading) return;
            state.loading = true;
            // Request a large number so the page has everything for client-side filtering
            fetch(ctx + '/api/notifications?limit=100', { credentials: 'same-origin' })
                .then(function (r) { return r.json(); })
                .then(function (data) {
                    state.all = data.items || [];
                    applyFilter(state.activeFilter);
                })
                .catch(function () {
                    document.getElementById('notifPageList').innerHTML =
                        '<div class="notif-empty-state">'
                        + '<div class="ei"><i class="bi bi-exclamation-triangle"></i></div>'
                        + '<h5>Could not load notifications</h5>'
                        + '<p>Please refresh the page to try again.</p>'
                        + '</div>';
                })
                .finally(function () { state.loading = false; });
        }

        // ── Filter tab clicks ─────────────────────────────────────────────────
        document.querySelectorAll('.ftab').forEach(function (tab) {
            tab.addEventListener('click', function (e) {
                e.preventDefault();
                applyFilter(tab.dataset.filter);
            });
        });

        // ── Load more ─────────────────────────────────────────────────────────
        document.getElementById('loadMoreBtn').addEventListener('click', function () {
            renderBatch();
        });

        // ── Mark all as read ──────────────────────────────────────────────────
        var markAllBtn = document.getElementById('markAllBtn');
        if (markAllBtn) {
            markAllBtn.addEventListener('click', function () {
                fetch(ctx + '/api/notifications/mark-all-read', {
                    method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-TOKEN': '${sessionScope.csrfToken}' }
                }).then(function () {
                    window.location.reload();
                });
            });
        }

        // ── Init ──────────────────────────────────────────────────────────────
        fetchNotifications();
    })();
    </script>
</body>
</html>
