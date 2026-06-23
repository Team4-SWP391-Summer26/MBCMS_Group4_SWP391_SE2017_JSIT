<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    _sidebar.jsp - Admin Console sidebar (owner: HungNT).
    Dung chung manager.css voi Branch console. Cac muc chua co module thi
    disabled + badge "Soon" (Branches/Users/Movies catalog/Reports - nguoi khac).

    Cach dung:  <jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
                    <jsp:param name="active" value="distribution" />
                </jsp:include>
--%>
<aside class="lc-sidebar">
    <div class="px-2 pb-3 mb-2" style="border-bottom:1px solid rgba(255,255,255,.08);">
        <a class="lc-sb-brand" href="${pageContext.request.contextPath}/admin/dashboard">MBCMS</a>
        <div class="lc-sb-subtitle">ADMIN CONSOLE</div>
    </div>

    <div class="lc-sb-section">Main</div>
    <a class="lc-sb-item ${param.active == 'dashboard' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/dashboard">
        <i class="bi bi-speedometer2"></i> Dashboard</a>

    <div class="lc-sb-section">Catalog</div>
    <span class="lc-sb-item disabled"><i class="bi bi-film"></i> Movies <span class="lc-sb-soon">Soon</span></span>
    <a class="lc-sb-item ${param.active == 'distribution' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/movie-branches">
        <i class="bi bi-diagram-3"></i> Movie Distribution</a>

    <div class="lc-sb-section">Finance</div>
    <a class="lc-sb-item ${param.active == 'payments' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/admin/payments">
        <i class="bi bi-credit-card"></i> Payments</a>

    <div class="lc-sb-section">System</div>
    <span class="lc-sb-item disabled"><i class="bi bi-building"></i> Branches <span class="lc-sb-soon">Soon</span></span>
    <span class="lc-sb-item disabled"><i class="bi bi-people"></i> Users <span class="lc-sb-soon">Soon</span></span>
    <span class="lc-sb-item disabled"><i class="bi bi-bar-chart"></i> Reports <span class="lc-sb-soon">Soon</span></span>

    <div style="flex:1;"></div>

    <div class="d-flex align-items-center gap-2 p-2 mt-3 lc-sb-user">
        <div class="lc-sb-avatar">${fn:toUpperCase(fn:substring(sessionScope.currentUser.fullName, 0, 1))}</div>
        <div style="min-width:0; flex:1;">
            <div style="font-size:.85rem; font-weight:600;" class="text-truncate">
                <c:out value="${sessionScope.currentUser.fullName}" /></div>
            <div style="font-size:.72rem; color:rgba(255,255,255,.55);">Administrator</div>
        </div>
        <a href="${pageContext.request.contextPath}/auth/logout" title="Sign out"
           style="color:rgba(255,255,255,.6);"><i class="bi bi-box-arrow-right"></i></a>
    </div>
</aside>
