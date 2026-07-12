<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%--
  PentaPlex logo for public pages (header, footer, auth).
  param variant: navbar | footer | auth  (controls rendered height via CSS)
  param linked: true | false (default true) — wrap in home link when true
--%>
<c:set var="brandVariant" value="${empty param.variant ? 'navbar' : param.variant}" />
<c:set var="brandLinked" value="${param.linked != 'false'}" />
<c:set var="brandHome" value="${pageContext.request.contextPath}/home" />

<c:choose>
    <c:when test="${brandLinked}">
        <a class="lc-brand-link lc-brand-link--${brandVariant}" href="${brandHome}">
            <img src="${pageContext.request.contextPath}/assets/img/logo.png"
                 alt="PentaPlex"
                 class="lc-brand-logo lc-brand-logo--${brandVariant}"
                 width="168"
                 height="40"
                 decoding="async">
        </a>
    </c:when>
    <c:otherwise>
        <img src="${pageContext.request.contextPath}/assets/img/logo.png"
             alt="PentaPlex"
             class="lc-brand-logo lc-brand-logo--${brandVariant}"
             width="168"
             height="40"
             decoding="async">
    </c:otherwise>
</c:choose>
