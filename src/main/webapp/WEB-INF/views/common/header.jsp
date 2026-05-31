<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar navbar-expand-lg navbar-custom">
    <div class="container">
        <!-- Brand/Logo -->
        <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/home">
            <!-- Logo SVG -->
            <svg width="32" height="32" viewBox="0 0 32 32" fill="none" xmlns="http://www.w3.org/2000/svg"
                 style="border-radius: 8px;">
                <rect width="32" height="32" rx="8" fill="#182c54" />
                <!-- film strip dots -->
                <rect x="4" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="11" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="18" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="25" y="3" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="4" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="11" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="18" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <rect x="25" y="26" width="3" height="3" rx="1" fill="#FFFFFF" opacity="0.3" />
                <!-- play triangle -->
                <path d="M13 11V21L21 16L13 11Z" fill="#FFC107" />
            </svg>
            <span class="ms-2 fw-bold" style="color: #0F1E36; font-size: 1.35rem; letter-spacing: -0.5px;">MBCMS</span>
        </a>

        <!-- Mobile toggle button -->
        <button class="navbar-toggler border-0 shadow-none" type="button" data-bs-toggle="collapse"
                data-bs-target="#navMenu" aria-controls="navMenu" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>

        <!-- Nav items -->
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav ms-lg-5 me-auto mb-2 mb-lg-0 mt-2 mt-lg-0 gap-4">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Movies</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#">Cinemas</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#">Promotions</a>
                </li>
            </ul>

            <!-- Right Side Actions -->
            <div class="d-flex align-items-center flex-column flex-lg-row gap-3 mt-2 mt-lg-0">
                <!-- Search bar -->
                <form class="search-container w-100" action="${pageContext.request.contextPath}/movies" method="GET"
                      style="max-width: 250px; margin-bottom: 0;">
                    <span class="search-icon">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                    </span>
                    <input type="text" class="search-input" placeholder="Search movies..." name="searchQuery" />
                </form>

                <!-- Action items (Notification Bell & Auth) aligned horizontally with exact gap-3 spacing -->
                <div class="d-flex align-items-center gap-3">
                    <!-- Notification Bell -->
                    <div class="notification-btn" title="Notifications">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                             stroke-linecap="round" stroke-linejoin="round">
                            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                        </svg>
                        <span class="notification-dot"></span>
                    </div>

                    <!-- Auth state links -->
                    <c:choose>
                        <c:when test="${not empty sessionScope.currentUser}">
                            <div class="dropdown">
                                <a class="dropdown-toggle text-dark fw-semibold text-decoration-none d-flex align-items-center gap-2" href="#" data-bs-toggle="dropdown"
                                   style="color: #1f2937 !important; font-size: 0.95rem;">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                         stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: #4b5563;">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                        <circle cx="12" cy="7" r="4"></circle>
                                    </svg>
                                    ${sessionScope.currentUser.fullName}
                                </a>
                                <ul class="dropdown-menu dropdown-menu-end border-0 shadow-sm"
                                    style="border: 1px solid #e5e7eb !important; border-radius: 8px;">
                                    <li>
                                        <a class="dropdown-item py-2 px-3" href="${pageContext.request.contextPath}/customer/profile"
                                           style="color: #4b5563; font-size: 0.9rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                                                <circle cx="12" cy="7" r="4"></circle>
                                            </svg>
                                            Profile
                                        </a>
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3" href="${pageContext.request.contextPath}/customer/bookings"
                                           style="color: #4b5563; font-size: 0.9rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                                                <line x1="16" y1="2" x2="16" y2="6"></line>
                                                <line x1="8" y1="2" x2="8" y2="6"></line>
                                                <line x1="3" y1="10" x2="21" y2="10"></line>
                                            </svg>
                                            Bookings
                                        </a>
                                    </li>
                                    <li>
                                        <hr class="dropdown-divider" style="border-top: 1px solid #e5e7eb;">
                                    </li>
                                    <li>
                                        <a class="dropdown-item py-2 px-3 text-danger"
                                           href="${pageContext.request.contextPath}/auth/logout"
                                           style="font-size: 0.9rem; display: flex; align-items: center; gap: 0.5rem;">
                                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                                                 stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                                                <polyline points="16 17 21 12 16 7"></polyline>
                                                <line x1="21" y1="12" x2="9" y2="12"></line>
                                            </svg>
                                            Logout
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <!-- Sign In & Register spaced equally with gap-3 -->
                            <a href="${pageContext.request.contextPath}/auth/login" class="btn-signin text-decoration-none text-nowrap">Sign In</a>
                            <a href="${pageContext.request.contextPath}/auth/register" class="btn-register-custom">Register</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</nav>