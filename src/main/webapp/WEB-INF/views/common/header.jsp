<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<nav class="navbar navbar-expand-lg navbar-dark" style="background-color:#1a1a2e;">
  <div class="container">
    <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home">
      <span style="color:#e94560;">&#9670;</span> MBCMS
    </a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMenu">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navMenu">
      <ul class="navbar-nav me-auto">
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/movies?status=NOW_SHOWING">Phim dang chieu</a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="${pageContext.request.contextPath}/movies?status=UPCOMING">Phim sap chieu</a>
        </li>
      </ul>
      <ul class="navbar-nav ms-auto">
        <c:choose>
          <c:when test="${not empty sessionScope.currentUser}">
            <li class="nav-item dropdown">
              <a class="nav-link dropdown-toggle" href="#" data-bs-toggle="dropdown">
                ${sessionScope.currentUser.fullName}
              </a>
              <ul class="dropdown-menu dropdown-menu-end">
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile">Ho so</a></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/customer/bookings">Lich su dat ve</a></li>
                <li><hr class="dropdown-divider"></li>
                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/auth/logout">Dang xuat</a></li>
              </ul>
            </li>
          </c:when>
          <c:otherwise>
            <li class="nav-item">
              <a class="nav-link" href="${pageContext.request.contextPath}/auth/login">Dang nhap</a>
            </li>
            <li class="nav-item">
              <a class="btn btn-sm ms-2" style="background:#e94560;color:#fff;"
                 href="${pageContext.request.contextPath}/auth/register">Dang ky</a>
            </li>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>
  </div>
</nav>
