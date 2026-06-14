<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
    _sidebar.jsp - Branch Manager Console sidebar (owner: HungNT).
    Port tu Sidebar component cua "Frontend demo" prototype (shared.jsx).

    Cach dung:  <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
                    <jsp:param name="active" value="showtimes" />
                </jsp:include>
    Gia tri active: dashboard | movies | showtimes | rooms | promotions | fnb | reports

    7 muc nav giu dung thu tu prototype. Muc nao module chua co thi disabled
    kem badge "Soon" (Movies=AnhND, Rooms=HoangHM, Promotions=AnhPQ,
    F&B=HoangHM, Reports=AnhND) - nguoi lam toi dau mo link toi do.
--%>
<aside class="lc-sidebar">
    <div class="px-2 pb-3 mb-2" style="border-bottom:1px solid rgba(255,255,255,.08);">
        <a class="lc-sb-brand" href="${pageContext.request.contextPath}/branch/dashboard">MBCMS</a>
        <div class="lc-sb-subtitle">BRANCH MANAGER CONSOLE</div>
    </div>

    <div class="lc-sb-section">Main</div>
    <a class="lc-sb-item ${param.active == 'dashboard' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/branch/dashboard">
        <i class="bi bi-speedometer2"></i> Dashboard</a>
    <span class="lc-sb-item disabled"><i class="bi bi-film"></i> Movies <span class="lc-sb-soon">Soon</span></span>
    <a class="lc-sb-item ${param.active == 'showtimes' ? 'active' : ''}"
       href="${pageContext.request.contextPath}/branch/showtimes">
        <i class="bi bi-calendar3"></i> Showtimes</a>
    <span class="lc-sb-item disabled"><i class="bi bi-grid-3x3"></i> Rooms &amp; Seats <span class="lc-sb-soon">Soon</span></span>
    <span class="lc-sb-item disabled"><i class="bi bi-ticket-perforated"></i> Promotions <span class="lc-sb-soon">Soon</span></span>
    <span class="lc-sb-item disabled"><i class="bi bi-cup-straw"></i> F&amp;B Menu <span class="lc-sb-soon">Soon</span></span>
    <span class="lc-sb-item disabled"><i class="bi bi-bar-chart"></i> Reports <span class="lc-sb-soon">Soon</span></span>

    <div style="flex:1;"></div>

    <div class="d-flex align-items-center gap-2 p-2 mt-3 lc-sb-user">
        <div class="lc-sb-avatar">${fn:toUpperCase(fn:substring(sessionScope.currentUser.fullName, 0, 1))}</div>
        <div style="min-width:0; flex:1;">
            <div style="font-size:.85rem; font-weight:600;" class="text-truncate">
                <c:out value="${sessionScope.currentUser.fullName}" /></div>
            <div style="font-size:.72rem; color:rgba(255,255,255,.55);" class="text-truncate">
                <c:out value="${empty sessionScope.currentBranchName ? 'Branch Manager' : sessionScope.currentBranchName}" /></div>
        </div>
        <a href="${pageContext.request.contextPath}/auth/logout" title="Sign out"
           style="color:rgba(255,255,255,.6);"><i class="bi bi-box-arrow-right"></i></a>
    </div>
</aside>
