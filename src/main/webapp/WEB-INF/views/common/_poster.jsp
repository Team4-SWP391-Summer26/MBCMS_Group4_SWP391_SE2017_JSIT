<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%--
  Reusable movie poster.
  - posterUrl + image OK  -> photo on top of gradient base
  - no posterUrl / broken -> gradient-art fallback (poster-bg + title)
  Params: movieId, title, posterUrl (opt), ribbon (opt), rating (opt)
--%>
<div class="poster-art" data-movie-id="<c:out value='${param.movieId}'/>">
    <div class="poster-bg" aria-hidden="true"></div>
    <div class="poster-rings" aria-hidden="true"></div>
    <div class="poster-name poster-name-fallback" <c:if test="${not empty param.posterUrl}">hidden</c:if>>
        <c:out value="${fn:toUpperCase(param.title)}" />
    </div>
    <c:if test="${not empty param.posterUrl}">
        <img class="poster-img"
             src="<c:url value='${param.posterUrl}'/>"
             alt="<c:out value='${param.title}'/> poster"
             loading="eager"
             decoding="async"
             onerror="this.classList.add('is-broken');var a=this.closest('.poster-art');if(a){a.classList.add('poster-art--fallback');var n=a.querySelector('.poster-name-fallback');if(n)n.hidden=false;a.dispatchEvent(new CustomEvent('poster:ready',{bubbles:true}));}">
    </c:if>
    <c:if test="${not empty param.ribbon}">
        <span class="poster-ribbon"><c:out value="${param.ribbon}" /></span>
    </c:if>
    <c:if test="${not empty param.rating}">
        <span class="poster-rating"><i class="bi bi-star-fill"></i> <span><c:out value="${param.rating}" /></span></span>
    </c:if>
</div>
