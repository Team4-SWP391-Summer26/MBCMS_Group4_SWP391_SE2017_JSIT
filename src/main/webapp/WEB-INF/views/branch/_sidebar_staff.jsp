<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%-- _sidebar_staff.jsp - Branch Staff Console sidebar. Ported from Manager's sidebar but filtered for Staff
                operations. Usage: <jsp:include page="/WEB-INF/views/branch/_sidebar_staff.jsp">
                <jsp:param name="active" value="booking" />
                </jsp:include>
                --%>
                <aside class="lc-sidebar">
                    <div class="px-2 pb-3 mb-2" style="border-bottom:1px solid rgba(255,255,255,.08);">
                        <a class="lc-sb-brand" href="${pageContext.request.contextPath}/staff/booking"><img src="${pageContext.request.contextPath}/assets/img/logo.png" alt="PentaPlex Logo" height="24" style="filter: brightness(0) invert(1);" /></a>
                        <div class="lc-sb-subtitle">BRANCH STAFF CONSOLE</div>
                    </div>

                    <div class="lc-sb-section">Counter Operations</div>
                    <a class="lc-sb-item ${param.active == 'booking' ? 'active' : ''}"
                        href="${pageContext.request.contextPath}/staff/booking">
                        <i class="bi bi-ticket-perforated"></i> Counter Booking</a>
                    <a class="lc-sb-item ${param.active == 'food-orders' ? 'active' : ''}"
                        href="${pageContext.request.contextPath}/staff/food-orders">
                        <i class="bi bi-cup-straw"></i> F&B Fulfillments</a>

                    <div style="flex:1;"></div>

                    <div class="d-flex align-items-center gap-2 p-2 mt-3 lc-sb-user">
                        <div class="lc-sb-avatar">${fn:toUpperCase(fn:substring(sessionScope.currentUser.fullName, 0,
                            1))}</div>
                        <div style="min-width:0; flex:1;">
                            <div style="font-size:.85rem; font-weight:600;" class="text-truncate">
                                <c:out value="${sessionScope.currentUser.fullName}" />
                            </div>
                            <div style="font-size:.72rem; color:rgba(255,255,255,.55);" class="text-truncate">
                                <c:out
                                    value="${empty sessionScope.currentBranchName ? 'Counter Staff' : sessionScope.currentBranchName}" />
                            </div>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/auth/logout"
                            class="m-0 d-inline">
                            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                                <button type="submit" title="Sign out"
                                    style="color:rgba(255,255,255,.6);border:0;background:none;cursor:pointer;padding:0;"><i
                                        class="bi bi-box-arrow-right"></i></button>
                        </form>
                    </div>
                </aside>