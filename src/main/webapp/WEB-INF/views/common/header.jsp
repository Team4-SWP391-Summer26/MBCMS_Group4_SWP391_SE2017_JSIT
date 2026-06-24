<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container">
        <!-- Brand/Logo -->
        <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/home">
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none"
                 xmlns="http://www.w3.org/2000/svg" style="border-radius: 8px;">
                <rect width="32" height="32" rx="8" fill="#182c54" />
                <rect x="4"  y="3"  width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="11" y="3"  width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="18" y="3"  width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="25" y="3"  width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="4"  y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="11" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="18" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="25" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <path d="M13 11V21L21 16L13 11Z" fill="#FFC107" />
            </svg>
            <span class="ms-2 fw-bold"
                  style="color: #0F1E36; font-size: 1.35rem; letter-spacing: -0.5px;">MBCMS</span>
        </a>

        <!-- Mobile toggle -->
        <button class="navbar-toggler border-0 shadow-none" type="button"
                data-bs-toggle="collapse" data-bs-target="#navMenu"
                aria-controls="navMenu" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Nav items -->
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav ms-lg-5 me-auto mb-2 mb-lg-0 mt-2 mt-lg-0 gap-4">
                <li class="nav-item">
                    <a class="nav-link"
                       href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Movies</a>
                </li>
                <li class="nav-item"><a class="nav-link" href="#">Cinemas</a></li>
                <li class="nav-item"><a class="nav-link" href="#">Promotions</a></li>
            </ul>

            <!-- Right Side Actions -->
            <div class="d-flex align-items-center flex-column flex-lg-row gap-3 mt-2 mt-lg-0">

                <!-- Search -->
                <form class="search-container w-100"
                      action="${pageContext.request.contextPath}/movies" method="GET"
                      style="max-width: 250px; margin-bottom: 0;">
                    <span class="search-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                    </span>
                    <input type="text" class="search-input"
                           placeholder="Search movies..." name="q" maxlength="100"
                           value="<c:out value='${param.q}' />" />
                </form>

                <div class="d-flex align-items-center gap-3">

                    <%-- ── Notification Bell (CUSTOMER only) ── --%>
                    <c:if test="${not empty sessionScope.currentUser
                                  and sessionScope.userRole == 'CUSTOMER'}">
                          <div class="notif-wrap" style="position:relative;">

                              <%-- Bell trigger button – icon-only to match existing CSS --%>
                              <button class="notification-btn" id="notifBell"
                                      type="button" title="Thông báo" aria-label="Thông báo">
                                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                       stroke="currentColor" stroke-width="2"
                                       stroke-linecap="round" stroke-linejoin="round">
                                      <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                                      <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                                  </svg>
                                  <%-- Dot hidden by default; JS shows it when unreadCount > 0 --%>
                                  <span class="notification-dot" id="notifDot"
                                        style="display:none;"></span>
                              </button>

                              <%-- Dropdown panel --%>
                              <div class="notif-panel" id="notifPanel">

                                  <div class="notif-panel-header">
                                      <span>Notification</span>
                                      <a href="#" id="notifMarkAll" class="notif-markall"
                                         style="display:none;">Mark all as read</a>
                                  </div>

                                  <div class="notif-list" id="notifList">
                                      <p class="notif-empty">Loading...</p>
                                  </div>

                                  <a href="${pageContext.request.contextPath}/customer/notifications"
                                     class="notif-viewall">View all</a>
                              </div>
                          </div>
                    </c:if>

                    <%-- ── Auth state ── --%>
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <div class="dropdown">
                                <a class="dropdown-toggle text-dark fw-semibold text-decoration-none
                                   d-flex align-items-center gap-2"
                                   href="#" data-bs-toggle="dropdown"
                                   style="color:#1f2937 !important; font-size:.95rem;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none"
                                         stroke="currentColor" stroke-width="2"
                                         stroke-linecap="round" stroke-linejoin="round"
                                         style="color:#4b5563;">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="12" cy="7" r="4"></circle>
                                    </svg>
                                    ${sessionScope.currentUser.fullName}
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end border-0 shadow-sm"
                                    style="border:1px solid #e5e7eb !important;border-radius:8px;">
                                    <li>
                                        <a class="dropdown-item py-2 px-3"
                                           href="${pageContext.request.contextPath}/customer/profile"
                                           style="color:#4b5563;font-size:.9rem;
                                           display:flex;align-items:center;gap:.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                 stroke="currentColor" stroke-width="2">
                                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                <circle cx="12" cy="7" r="4"></circle>
                                            </svg> Profile
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3"
                                           href="${pageContext.request.contextPath}/customer/booking/history"
                                           style="color:#4b5563;font-size:.9rem;
                                           display:flex;align-items:center;gap:.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                 stroke="currentColor" stroke-width="2">
                                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                                <line x1="16" y1="2" x2="16" y2="6"></line>
                                                <line x1="8"  y1="2" x2="8"  y2="6"></line>
                                                <line x1="3"  y1="10" x2="21" y2="10"></line>
                                            </svg> Bookings
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3"
                                           href="${pageContext.request.contextPath}/customer/notifications"
                                           style="color:#4b5563;font-size:.9rem;
                                           display:flex;align-items:center;gap:.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                 stroke="currentColor" stroke-width="2">
                                                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                                                <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                                            </svg> Thông báo
                                            <c:if test="${not empty sessionScope.userRole
                                                          and sessionScope.userRole == 'CUSTOMER'}">
                                                <%-- Unread count badge - loaded via JS --%>
                                                <span id="dropdownUnreadBadge"
                                                      class="badge bg-danger ms-auto"
                                                      style="display:none;font-size:.65rem;"></span>
                                            </c:if>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3" href="${pageContext.request.contextPath}/customer/payments"
                                           style="color: #4b5563; font-size: 0.9rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <rect x="1" y="4" width="22" height="16" rx="2" ry="2"></rect>
                                                <line x1="1" y1="10" x2="23" y2="10"></line>
                                            </svg>
                                            Payment History
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3"
                                           href="${pageContext.request.contextPath}/auth/change-password"
                                           style="color:#4b5563;font-size:.9rem;
                                           display:flex;align-items:center;gap:.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                 stroke="currentColor" stroke-width="2">
                                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                                            </svg> Change Password
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider" style="border-top:1px solid #e5e7eb;"></li>
                                    <li>
                                        <form method="post" action="${pageContext.request.contextPath}/auth/logout" class="d-inline m-0">
                                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                            <button type="submit" class="dropdown-item py-2 px-3 text-danger border-0 bg-transparent w-100 text-start"
                                                    style="font-size:.9rem;display:flex;align-items:center;gap:.5rem;">
                                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                                                     stroke="currentColor" stroke-width="2">
                                                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                                                    <polyline points="16 17 21 12 16 7"></polyline>
                                                    <line x1="21" y1="12" x2="9" y2="12"></line>
                                                </svg> Logout
                                            </button>
                                        </form>
                                    </li>
                                </ul>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/auth/login"
                               class="btn-signin text-decoration-none text-nowrap">Sign In</a>
                            <a href="${pageContext.request.contextPath}/auth/register"
                               class="btn-register-custom">Register</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</nav>

<%-- ── Notification dropdown CSS + JS (only injected for CUSTOMER) ── --%>
<c:if test="${not empty sessionScope.currentUser
              and sessionScope.userRole == 'CUSTOMER'}">
      <style>
          .notif-panel {
              display: none;
              position: absolute;
              top: calc(100% + 10px);
              right: 0;
              width: 360px;
              max-width: 92vw;
              background: #fff;
              border: 1px solid #e5e7eb;
              border-radius: 12px;
              box-shadow: 0 10px 40px rgba(0,0,0,.13);
              overflow: hidden;
              z-index: 1050;
              animation: notifFadeIn .18s ease;
          }
          .notif-panel.show {
              display: block;
          }
          @keyframes notifFadeIn {
              from {
                  opacity:0;
                  transform:translateY(-6px);
              }
              to {
                  opacity:1;
                  transform:translateY(0);
              }
          }

          .notif-panel-header {
              padding: 12px 16px;
              border-bottom: 1px solid #f1f5f9;
              display: flex;
              justify-content: space-between;
              align-items: center;
              font-size: .88rem;
              font-weight: 700;
              color: #1f2937;
          }
          .notif-markall {
              font-size: .75rem;
              font-weight: 600;
              color: #2563eb;
              text-decoration: none;
          }
          .notif-markall:hover {
              text-decoration: underline;
          }

          .notif-list {
              max-height: 360px;
              overflow-y: auto;
          }

          .notif-item {
              display: flex;
              gap: 10px;
              padding: 11px 16px;
              text-decoration: none;
              border-bottom: 1px solid #f8fafc;
              position: relative;
              transition: background .12s;
          }
          .notif-item:last-child {
              border-bottom: none;
          }
          .notif-item:hover {
              background: #f8fafc;
          }
          .notif-item.unread {
              background: #eff6ff;
          }
          .notif-item.unread::before {
              content: '';
              position: absolute;
              left: 5px;
              top: 50%;
              transform: translateY(-50%);
              width: 5px;
              height: 5px;
              border-radius: 50%;
              background: #2563eb;
          }

          .notif-item-icon {
              width: 34px;
              height: 34px;
              border-radius: 8px;
              flex-shrink: 0;
              display: flex;
              align-items: center;
              justify-content: center;
          }
          .notif-item-icon.BOOKING   {
              background:#eff6ff;
              color:#2563eb;
          }
          .notif-item-icon.PAYMENT   {
              background:#f0fdf4;
              color:#16a34a;
          }
          .notif-item-icon.PROMOTION {
              background:#fff7ed;
              color:#ea580c;
          }
          .notif-item-icon.REMINDER  {
              background:#fef9c3;
              color:#ca8a04;
          }
          .notif-item-icon.SYSTEM    {
              background:#f8fafc;
              color:#6b7280;
          }

          .notif-item-title {
              margin: 0 0 2px;
              font-size: .82rem;
              font-weight: 700;
              color: #1e293b;
              white-space: nowrap;
              overflow: hidden;
              text-overflow: ellipsis;
              max-width: 240px;
          }
          .notif-item-desc {
              margin: 0 0 3px;
              font-size: .76rem;
              color: #6b7280;
              line-height: 1.4;
              display: -webkit-box;
              -webkit-line-clamp: 2;
              -webkit-box-orient: vertical;
              overflow: hidden;
          }
          .notif-item-time {
              font-size: .7rem;
              color: #9ca3af;
          }

          .notif-empty {
              padding: 24px 16px;
              text-align: center;
              color: #9ca3af;
              font-size: .83rem;
              margin: 0;
          }
          .notif-viewall {
              display: block;
              text-align: center;
              padding: 10px;
              font-size: .82rem;
              font-weight: 700;
              color: #2563eb;
              border-top: 1px solid #f1f5f9;
              text-decoration: none;
          }
          .notif-viewall:hover {
              background: #f8fafc;
          }
      </style>

      <script>
          document.addEventListener('DOMContentLoaded', function () {
              var ctx = '${pageContext.request.contextPath}';
              var bell = document.getElementById('notifBell');
              var panel = document.getElementById('notifPanel');
              var list = document.getElementById('notifList');
              var dot = document.getElementById('notifDot');
              var markAllBtn = document.getElementById('notifMarkAll');
              var ddBadge = document.getElementById('dropdownUnreadBadge');

              // ── SVG icons per type ────────────────────────────────────────────────
              var icons = {
                  BOOKING:
                          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
                          + '<rect x="3" y="4" width="18" height="18" rx="2"></rect>'
                          + '<line x1="16" y1="2" x2="16" y2="6"></line>'
                          + '<line x1="8" y1="2" x2="8" y2="6"></line>'
                          + '<line x1="3" y1="10" x2="21" y2="10"></line></svg>',
                  PAYMENT:
                          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
                          + '<rect x="1" y="4" width="22" height="16" rx="2"></rect>'
                          + '<line x1="1" y1="10" x2="23" y2="10"></line></svg>',
                  PROMOTION:
                          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
                          + '<polyline points="20 12 20 22 4 22 4 12"></polyline>'
                          + '<rect x="2" y="7" width="20" height="5"></rect>'
                          + '<line x1="12" y1="22" x2="12" y2="7"></line></svg>',
                  REMINDER:
                          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
                          + '<circle cx="12" cy="13" r="8"></circle><path d="M12 9v4l2 2"></path></svg>',
                  SYSTEM:
                          '<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">'
                          + '<circle cx="12" cy="12" r="10"></circle>'
                          + '<line x1="12" y1="16" x2="12" y2="12"></line>'
                          + '<line x1="12" y1="8" x2="12.01" y2="8"></line></svg>'
              };

              // ── Relative time ─────────────────────────────────────────────────────
              function timeAgo(isoStr) {
                  if (!isoStr)
                      return '';
                  var d = new Date(isoStr + 'Z'); // DB stores UTC
                  var diff = Math.floor((Date.now() - d.getTime()) / 1000);
                  if (diff < 60)
                      return 'Vừa xong';
                  if (diff < 3600)
                      return Math.floor(diff / 60) + ' phút trước';
                  if (diff < 86400)
                      return Math.floor(diff / 3600) + ' giờ trước';
                  return Math.floor(diff / 86400) + ' ngày trước';
              }

              // ── Render one item ───────────────────────────────────────────────────
              function renderItem(n) {
                  var a = document.createElement('a');
                  a.href = n.linkUrl || '#';
                  a.className = 'notif-item' + (n.read ? '' : ' unread');
                  a.innerHTML =
                          '<div class="notif-item-icon ' + n.type + '">'
                          + (icons[n.type] || icons.SYSTEM) + '</div>'
                          + '<div style="flex:1;min-width:0">'
                          + '<p class="notif-item-title">' + n.title + '</p>'
                          + '<p class="notif-item-desc">' + n.content + '</p>'
                          + '<span class="notif-item-time">' + timeAgo(n.createdAt) + '</span>'
                          + '</div>';

                  // Mark single as read on click
                  if (!n.read && a.href !== '#') {
                      a.addEventListener('click', function (e) {
                          e.preventDefault();
                          fetch(ctx + '/api/notifications?id=' + n.id, {
                              method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-TOKEN': '${sessionScope.csrfToken}' }
                          }).finally(function () {
                              window.location.href = a.href;
                          });
                      });
                  }
                  return a;
              }

              // ── Load from API ─────────────────────────────────────────────────────
              function loadNotifications() {
                  fetch(ctx + '/api/notifications', {credentials: 'same-origin'})
                          .then(function (res) {
                              return res.json();
                          })
                          .then(function (data) {
                              list.innerHTML = '';
                              if (!data.items || data.items.length === 0) {
                                  list.innerHTML = '<p class="notif-empty">The is no notification</p>';
                              } else {
                                  data.items.forEach(function (n) {
                                      list.appendChild(renderItem(n));
                                  });
                              }

                              // Dot on bell
                              var hasUnread = data.unreadCount > 0;
                              dot.style.display = hasUnread ? 'block' : 'none';

                              // "Mark all" link
                              markAllBtn.style.display = hasUnread ? 'inline' : 'none';

                              // Badge in dropdown menu
                              if (ddBadge) {
                                  if (hasUnread) {
                                      ddBadge.textContent = data.unreadCount;
                                      ddBadge.style.display = 'inline-block';
                                  } else {
                                      ddBadge.style.display = 'none';
                                  }
                              }
                          })
                          .catch(function () {
                              list.innerHTML = '<p class="notif-empty">Unable to load notification</p>';
                          });
              }

              // ── Mark all ─────────────────────────────────────────────────────────
              markAllBtn.addEventListener('click', function (e) {
                  e.preventDefault();
                  fetch(ctx + '/api/notifications/mark-all-read', {
                      method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-TOKEN': '${sessionScope.csrfToken}' }
                  }).then(loadNotifications);
              });

              // ── Toggle panel ──────────────────────────────────────────────────────
              bell.addEventListener('click', function (e) {
                  e.stopPropagation();
                  var willOpen = !panel.classList.contains('show');
                  panel.classList.toggle('show');
                  if (willOpen)
                      loadNotifications();
              });

              // Close on outside click
              document.addEventListener('click', function (e) {
                  if (!panel.contains(e.target) && !bell.contains(e.target)) {
                      panel.classList.remove('show');
                  }
              });

              // ── Init: load count immediately, then poll every 30s ────────────────
              loadNotifications();
              setInterval(loadNotifications, 30000);
          });
      </script>
</c:if>
