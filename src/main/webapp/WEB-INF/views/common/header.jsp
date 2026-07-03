<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%-- Bootstrap Icons shared by public pages. --%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link href="${pageContext.request.contextPath}/assets/css/public-nav.css?v=${applicationScope.assetVersion}" rel="stylesheet">
<script src="${pageContext.request.contextPath}/assets/js/lc-ui.js?v=${applicationScope.assetVersion}" defer></script>
<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container public-shell">
        <!-- Brand/Logo -->
        <a class="navbar-brand d-flex align-items-center py-0" href="${pageContext.request.contextPath}/home">
            <img src="${pageContext.request.contextPath}/assets/img/logo.png"
                 alt="PentaPlex"
                 class="lc-brand-logo lc-brand-logo--navbar"
                 width="168"
                 height="34"
                 decoding="async">
        </a>

        <!-- Mobile toggle -->
        <button class="navbar-toggler border-0 shadow-none" type="button"
                data-bs-toggle="collapse" data-bs-target="#navMenu"
                aria-controls="navMenu" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Nav items -->
        <c:set var="activeMenu" value="${param.activeMenu}" />
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav ms-lg-5 me-auto mb-2 mb-lg-0 mt-2 mt-lg-0 gap-4">
                <li class="nav-item">
                    <a class="nav-link <c:if test="${activeMenu == 'movies'}">active</c:if>"
                       href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Movies</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test="${activeMenu == 'cinemas'}">active</c:if>" href="" aria-disabled="true">Cinemas</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link <c:if test="${activeMenu == 'promotions'}">active</c:if>" href="" aria-disabled="true">Promotions</a>
                </li>
            </ul>

            <!-- Right Side Actions -->
            <div class="d-flex align-items-center flex-column flex-lg-row gap-3 mt-2 mt-lg-0">

                <!-- Search -->
                <form class="search-container w-100"
                      action="${pageContext.request.contextPath}/movies" method="GET">
                    <span class="search-icon">
                        <i class="bi bi-search"></i>
                    </span>
                    <input type="text" class="search-input"
                           placeholder="Search movies..." name="q" maxlength="100"
                           value="<c:out value='${param.q}' />" />
                </form>

                <div class="d-flex align-items-center gap-3">

                    <c:set var="role" value="${sessionScope.userRole}" />

                    <%-- Notification Bell: customer only --%>
                    <c:if test="${not empty sessionScope.currentUser and role == 'CUSTOMER'}">
                    <div class="notif-wrap">
                        <%-- Bell trigger button --%>
                        <button class="notification-btn" id="notifBell"
                                type="button" title="Notifications" aria-label="Notifications">
                            <i class="bi bi-bell"></i>
                            <%-- Dot hidden by default; JS shows it when unreadCount > 0 --%>
                            <span class="notification-dot is-hidden" id="notifDot"></span>
                        </button>

                        <%-- Dropdown panel for Customer --%>
                        <div class="notif-panel" id="notifPanel">
                            <div class="notif-panel-header">
                                <span>Notification</span>
                                <a href="" id="notifMarkAll" class="notif-markall is-hidden">Mark all as read</a>
                            </div>
                            <div class="notif-list" id="notifList">
                                <p class="notif-empty">Loading...</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/customer/notifications"
                               class="notif-viewall">View all</a>
                        </div>
                    </div>
                    </c:if>

                    <%-- Auth state --%>
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser and role == 'CUSTOMER'}">
                            <div class="dropdown">
                                <a class="dropdown-toggle fw-semibold text-decoration-none nav-user-trigger
                                   d-flex align-items-center gap-2"
                                   href="" data-bs-toggle="dropdown">
                                    <i class="bi bi-person-circle"></i>
                                    ${sessionScope.currentUser.fullName}
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end border-0 shadow-sm">
                                    <li>
                                        <a class="dropdown-item py-2 px-3 nav-menu-item"
                                           href="${pageContext.request.contextPath}/customer/profile">
                                            <i class="bi bi-person"></i> Profile
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3 nav-menu-item"
                                           href="${pageContext.request.contextPath}/customer/booking/history">
                                            <i class="bi bi-calendar2-week"></i> Bookings
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3 nav-menu-item"
                                           href="${pageContext.request.contextPath}/customer/payments">
                                            <i class="bi bi-credit-card"></i> Payment History
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3 nav-menu-item"
                                           href="${pageContext.request.contextPath}/auth/change-password">
                                            <i class="bi bi-shield-lock"></i> Change Password
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <form method="post" action="${pageContext.request.contextPath}/auth/logout" class="d-inline m-0">
                                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                            <button type="submit" class="dropdown-item py-2 px-3 border-0 bg-transparent w-100 text-start nav-menu-item is-danger">
                                                <i class="bi bi-box-arrow-right"></i> Logout
                                            </button>
                                        </form>
                                    </li>
                                </ul>
                            </div>
                        </c:when>
                        <%-- Admin / Branch Manager / Branch Staff: Dashboard + Logout --%>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <c:choose>
                                <c:when test="${role == 'ADMIN'}"><c:set var="dashUrl" value="/admin/dashboard" /></c:when>
                                <c:when test="${role == 'BRANCH_STAFF'}"><c:set var="dashUrl" value="/staff/booking" /></c:when>
                                <c:otherwise><c:set var="dashUrl" value="/branch/dashboard" /></c:otherwise>
                            </c:choose>
                            <div class="dropdown">
                                <a class="dropdown-toggle fw-semibold text-decoration-none d-flex align-items-center gap-2 nav-user-trigger"
                                   href="" data-bs-toggle="dropdown">
                                    <i class="bi bi-person-circle"></i>
                                    ${sessionScope.currentUser.fullName}
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end border-0 shadow-sm">
                                    <li>
                                        <a class="dropdown-item py-2 px-3 nav-menu-item"
                                           href="${pageContext.request.contextPath}${dashUrl}">
                                            <i class="bi bi-speedometer2"></i> Dashboard
                                        </a>
                                    </li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li>
                                        <form method="post" action="${pageContext.request.contextPath}/auth/logout" class="d-inline m-0">
                                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                            <button type="submit" class="dropdown-item py-2 px-3 border-0 bg-transparent w-100 text-start nav-menu-item is-danger">
                                                <i class="bi bi-box-arrow-right"></i> Logout
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

<c:if test="${not empty sessionScope.currentUser
              and sessionScope.userRole == 'CUSTOMER'}">
      <script>
          document.addEventListener('DOMContentLoaded', function () {
              var ctx = '${pageContext.request.contextPath}';
              var bell = document.getElementById('notifBell');
              var panel = document.getElementById('notifPanel');
              var list = document.getElementById('notifList');
              var dot = document.getElementById('notifDot');
              var markAllBtn = document.getElementById('notifMarkAll');
              var ddBadge = document.getElementById('dropdownUnreadBadge');

              // Bootstrap icon per notification type.
              var icons = {
                  BOOKING: '<i class="bi bi-calendar-check"></i>',
                  PAYMENT: '<i class="bi bi-credit-card"></i>',
                  PROMOTION: '<i class="bi bi-gift"></i>',
                  REMINDER: '<i class="bi bi-clock"></i>',
                  SYSTEM: '<i class="bi bi-info-circle"></i>'
              };

              // Relative time
              function timeAgo(isoStr) {
                  if (!isoStr)
                      return '';
                  var d = new Date(isoStr + 'Z'); // DB stores UTC
                  var diff = Math.floor((Date.now() - d.getTime()) / 1000);
                  if (diff < 60)
                      return 'Just now';
                  if (diff < 3600)
                      return Math.floor(diff / 60) + ' min ago';
                  if (diff < 86400)
                      return Math.floor(diff / 3600) + ' hr ago';
                  return Math.floor(diff / 86400) + ' days ago';
              }

              // Render one item
              function renderItem(n) {
                  var a = document.createElement('a');
                  a.href = n.linkUrl || '';
                  a.className = 'notif-item' + (n.read ? '' : ' unread');
                  a.innerHTML =
                          '<div class="notif-item-icon ' + n.type + '">'
                          + (icons[n.type] || icons.SYSTEM) + '</div>'
                          + '<div class="notif-item-body">'
                          + '<p class="notif-item-title">' + n.title + '</p>'
                          + '<p class="notif-item-desc">' + n.content + '</p>'
                          + '<span class="notif-item-time">' + timeAgo(n.createdAt) + '</span>'
                          + '</div>';

                  // Mark single as read on click
                  if (!n.read && n.linkUrl) {
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

              // Load from API
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
                              dot.classList.toggle('is-hidden', !hasUnread);

                              // "Mark all" link
                              markAllBtn.classList.toggle('is-hidden', !hasUnread);

                              // Badge in dropdown menu
                              if (ddBadge) {
                                  if (hasUnread) {
                                      ddBadge.textContent = data.unreadCount;
                                      ddBadge.classList.remove('is-hidden');
                                  } else {
                                      ddBadge.classList.add('is-hidden');
                                  }
                              }
                          })
                          .catch(function () {
                              list.innerHTML = '<p class="notif-empty">Unable to load notification</p>';
                          });
              }

              function closeBootstrapDropdowns() {
                  document.querySelectorAll('.dropdown-menu.show').forEach(function (menu) {
                      var toggle = menu.closest('.dropdown') ? menu.closest('.dropdown').querySelector('[data-bs-toggle="dropdown"]') : null;
                      if (window.bootstrap && toggle) {
                          bootstrap.Dropdown.getOrCreateInstance(toggle).hide();
                      } else {
                          menu.classList.remove('show');
                          if (toggle) {
                              toggle.setAttribute('aria-expanded', 'false');
                          }
                      }
                  });
              }

              // Mark all
              markAllBtn.addEventListener('click', function (e) {
                  e.preventDefault();
                  fetch(ctx + '/api/notifications/mark-all-read', {
                      method: 'POST', credentials: 'same-origin', headers: { 'X-CSRF-TOKEN': '${sessionScope.csrfToken}' }
                  }).then(loadNotifications);
              });

              // Toggle panel
              bell.addEventListener('click', function (e) {
                  e.stopPropagation();
                  var willOpen = !panel.classList.contains('show');
                  if (willOpen) {
                      closeBootstrapDropdowns();
                  }
                  panel.classList.toggle('show');
                  if (willOpen)
                      loadNotifications();
              });

              document.addEventListener('show.bs.dropdown', function () {
                  panel.classList.remove('show');
              });

              // Close on outside click
              document.addEventListener('click', function (e) {
                  if (!panel.contains(e.target) && !bell.contains(e.target)) {
                      panel.classList.remove('show');
                  }
              });

              // Init: load count immediately, then poll every 30s
              loadNotifications();
              setInterval(loadNotifications, 30000);
          });
      </script>
</c:if>

<%-- Guest bell notifications panel toggle script --%>
<c:if test="${empty sessionScope.currentUser or sessionScope.userRole != 'CUSTOMER'}">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var bell = document.getElementById('notifBell');
            var panel = document.getElementById('notifPanel');
            if (bell && panel) {
                function closeBootstrapDropdowns() {
                    document.querySelectorAll('.dropdown-menu.show').forEach(function (menu) {
                        var toggle = menu.closest('.dropdown') ? menu.closest('.dropdown').querySelector('[data-bs-toggle="dropdown"]') : null;
                        if (window.bootstrap && toggle) {
                            bootstrap.Dropdown.getOrCreateInstance(toggle).hide();
                        } else {
                            menu.classList.remove('show');
                            if (toggle) {
                                toggle.setAttribute('aria-expanded', 'false');
                            }
                        }
                    });
                }

                bell.addEventListener('click', function (e) {
                    e.stopPropagation();
                    if (!panel.classList.contains('show')) {
                        closeBootstrapDropdowns();
                    }
                    panel.classList.toggle('show');
                });
                document.addEventListener('show.bs.dropdown', function () {
                    panel.classList.remove('show');
                });
                document.addEventListener('click', function (e) {
                    if (!panel.contains(e.target) && !bell.contains(e.target)) {
                        panel.classList.remove('show');
                    }
                });
            }
        });
    </script>
</c:if>
