<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <aside class="lc-sidebar">
            <div class="px-2 pb-3 mb-2" style="border-bottom:1px solid rgba(255,255,255,.08);">
                <a class="lc-sb-brand text-decoration-none" href="${pageContext.request.contextPath}/admin/dashboard"><img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="PentaPlex Logo" height="24" style="filter: brightness(0) invert(1);" /></a>
                <div class="lc-sb-subtitle">
                    ADMIN CONSOLE
                </div>
            </div>

            <div class="lc-sb-section">MAIN</div>

            <a class="lc-sb-item ${param.active == 'dashboard' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2"></i>
                Dashboard
            </a>

            <a class="lc-sb-item ${param.active == 'users' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/users">
                <i class="bi bi-people"></i>
                Users
            </a>

            <a class="lc-sb-item ${param.active == 'branches' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/branches">
                <i class="bi bi-building"></i>
                Cinemas
            </a>


            <a class="lc-sb-item ${param.active == 'promotions' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/promotions">
                <i class="bi bi-ticket-perforated"></i>
                Promotions
            </a>

            <div class="lc-sb-section">Catalog</div>

            <a class="lc-sb-item ${param.active == 'movies' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/movies">
                <i class="bi bi-film"></i>
                Movies
            </a>

            <a class="lc-sb-item ${param.active == 'genres' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/genres">
                <i class="bi bi-tags"></i>
                Genres
            </a>

            <a class="lc-sb-item ${param.active == 'movie-branches' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/movie-branches">
                <i class="bi bi-diagram-3"></i>
                Movie Assignment
            </a>

            <div class="lc-sb-section">Finance</div>
            <a class="lc-sb-item ${param.active == 'payments' ? 'active' : ''}"
                href="${pageContext.request.contextPath}/admin/payments">
                <i class="bi bi-credit-card"></i> Payments</a>

            <span class="lc-sb-item disabled">
                <i class="bi bi-bar-chart"></i>
                System Reports
                <span class="lc-sb-soon">Soon</span>
            </span>

            <span class="lc-sb-item disabled">
                <i class="bi bi-star"></i>
                Review Approval
                <span class="lc-sb-soon">Soon</span>
            </span>

            <span class="lc-sb-item disabled">
                <i class="bi bi-gear"></i>
                Settings
                <span class="lc-sb-soon">Soon</span>
            </span>

            <div style="flex:1"></div>

            <div class="d-flex align-items-center gap-2 p-2 mt-3 lc-sb-user">
                <div class="lc-sb-avatar">
                    SA
                </div>
                <div style="min-width:0; flex:1;">
                    <div style="font-size:.85rem;font-weight:600;" class="text-truncate text-white">
                        System Admin
                    </div>
                    <div style="font-size:.72rem;color:rgba(255,255,255,.55);">
                        System-wide access
                    </div>
                </div>
                <form method="post" action="${pageContext.request.contextPath}/auth/logout" class="m-0 d-inline">
                    <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                        <button type="submit"
                            style="color:rgba(255,255,255,.6);border:0;background:none;cursor:pointer;padding:0;">
                            <i class="bi bi-box-arrow-right fs-5"></i>
                        </button>
                </form>
            </div>
        </aside>