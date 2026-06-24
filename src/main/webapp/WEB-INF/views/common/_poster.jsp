<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  Reusable movie poster.
  - Real posterUrl present  -> show ONLY the image (no generated text/gradient).
  - No posterUrl            -> generated gradient-art fallback (deep colour from
                               movieId + faint gold rings + title text).
  Params: movieId, title, posterUrl (opt), ribbon (opt), rating (opt)
--%>
<div class="poster-art">
    <c:choose>
        <c:when test="${not empty param.posterUrl}">
            <img src="<c:url value='${param.posterUrl}'/>" alt="<c:out value='${param.title}'/> poster">
        </c:when>
        <c:otherwise>
            <c:set var="pHue" value="${(param.movieId * 47) mod 360}" />
            <div class="poster-bg" style="background:linear-gradient(160deg, hsl(${pHue} 58% 22%), hsl(${pHue} 60% 8%));"></div>
            <svg class="poster-rings" viewBox="0 0 200 300" preserveAspectRatio="xMidYMid slice" aria-hidden="true">
                <c:forEach var="i" begin="0" end="7">
                    <circle cx="${(i*31) mod 200}" cy="${(i*43) mod 300}" r="${20 + i*8}"
                            fill="none" stroke="#FFC107" stroke-width="0.5" opacity="0.12" />
                </c:forEach>
            </svg>
            <div class="poster-name"><c:out value="${fn:toUpperCase(param.title)}" /></div>
        </c:otherwise>
    </c:choose>
    <c:if test="${not empty param.ribbon}">
        <span class="poster-ribbon"><c:out value="${param.ribbon}" /></span>
    </c:if>
    <c:if test="${not empty param.rating}">
        <span class="poster-rating"><i class="bi bi-star-fill"></i> <span><c:out value="${param.rating}" /></span></span>
    </c:if>
</div>
