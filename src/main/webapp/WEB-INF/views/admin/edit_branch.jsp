<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Cinema</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
          rel="stylesheet">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css"
          rel="stylesheet">

    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}"
          rel="stylesheet">
</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/admin/_sidebar.jsp">
    <jsp:param name="active" value="branches"/>
</jsp:include>

<main class="lc-admin-main">

<div class="container-fluid px-4 py-4">

    <!-- HEADER -->

    <div class="d-flex justify-content-between align-items-center mb-4">

        <div>
            <div class="text-muted small">
                Cinema Management
            </div>

            <h3 class="fw-bold">
                Edit Cinema
            </h3>
        </div>

        <a href="${pageContext.request.contextPath}/admin/branches"
           class="btn btn-outline-secondary">

            <i class="bi bi-arrow-left"></i>
            Back to Cinemas

        </a>

    </div>

    <form method="post"
          action="${pageContext.request.contextPath}/admin/branches">

        <input type="hidden"
               name="action"
               value="edit">

        <input type="hidden"
               name="branchId"
               value="${branch.branchId}">

        <div class="row">

            <!-- LEFT -->

            <div class="col-lg-8">

                <div class="card shadow-sm mb-4">

                    <div class="card-header fw-bold">
                        Cinema Information
                    </div>

                    <div class="card-body">

                        <div class="row">

                            <div class="col-md-6 mb-3">

                                <label class="form-label">
                                    Cinema Name
                                </label>

                                <input type="text"
                                       class="form-control"
                                       name="name"
                                       value="${branch.name}"
                                       required>

                            </div>

                            <div class="col-md-6 mb-3">

                                <label class="form-label">
                                    City
                                </label>

                                <input type="text"
                                       class="form-control"
                                       name="city"
                                       value="${branch.city}"
                                       required>

                            </div>

                        </div>

                        <div class="mb-3">

                            <label class="form-label">
                                Address
                            </label>

                            <input type="text"
                                   class="form-control"
                                   name="address"
                                   value="${branch.address}"
                                   required>

                        </div>

                        <div class="row">

                            <div class="col-md-6 mb-3">

                                <label class="form-label">
                                    Phone
                                </label>

                                <input type="text"
                                       class="form-control"
                                       name="phone"
                                       value="${branch.phone}">

                            </div>

                            <div class="col-md-6 mb-3">

                                <label class="form-label">
                                    Email
                                </label>

                                <input type="email"
                                       class="form-control"
                                       name="email"
                                       value="${branch.email}">

                            </div>

                        </div>

                    </div>

                </div>

                <!-- OPERATING HOURS — đã gỡ khỏi giao diện theo yêu cầu; giữ giá trị để lưu không lỗi -->
                <input type="hidden" name="openingTime" value="${branch.openingTime}">
                <input type="hidden" name="closingTime" value="${branch.closingTime}">
                <div class="d-none">

                    <div class="card-body">

                        <table class="table">

                            <thead>

                            <tr>
                                <th>Day</th>
                                <th>Open</th>
                                <th>Close</th>
                                <th>Status</th>
                            </tr>

                            </thead>

                            <tbody>

                            <c:forEach var="day"
                                       items="${['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']}"
                                       varStatus="loop">

                                <tr>

                                    <td>${day}</td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${loop.index == 0}">
                                                <input type="time"
                                                       class="form-control"
                                                       value="${branch.openingTime}"
                                                       disabled>
                                            </c:when>
                                            <c:otherwise>
                                                <input type="time"
                                                       class="form-control"
                                                       value="${branch.openingTime}"
                                                       disabled>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${loop.index == 0}">
                                                <input type="time"
                                                       class="form-control"
                                                       value="${branch.closingTime}"
                                                       disabled>
                                            </c:when>
                                            <c:otherwise>
                                                <input type="time"
                                                       class="form-control"
                                                       value="${branch.closingTime}"
                                                       disabled>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>

                                        <div class="form-check form-switch">

                                            <input class="form-check-input"
                                                   type="checkbox"
                                                   checked>

                                        </div>

                                    </td>

                                </tr>

                            </c:forEach>

                            </tbody>

                        </table>

                    </div>

                </div>

                <!-- STATUS -->

                <div class="card shadow-sm">

                    <div class="card-header fw-bold">
                        Cinema Status
                    </div>

                    <div class="card-body">

                        <div class="form-check form-switch">

                            <input class="form-check-input"
                                   type="checkbox"
                                   name="active"

                                   <c:if test="${branch.active}">
                                       checked
                                   </c:if>>

                            <label class="form-check-label">
                                Active Cinema
                            </label>

                        </div>

                    </div>

                </div>

            </div>

            <!-- RIGHT -->

            <div class="col-lg-4">

                <div class="card shadow-sm mb-4">

                    <div class="card-header fw-bold">
                        Location Preview
                    </div>

                    <div class="card-body text-center">

                        <div style="
                            height:300px;
                            background:#f5f5f5;
                            border-radius:12px;
                            display:flex;
                            align-items:center;
                            justify-content:center;
                            color:#666;
                        ">

                            <div>

                                <i class="bi bi-geo-alt-fill fs-1"></i>

                                <p class="mb-0 mt-2">
                                    Map Preview
                                </p>

                                <small>
                                    ${branch.city}
                                </small>

                            </div>

                        </div>

                    </div>

                </div>

                <div class="card shadow-sm">

                    <div class="card-body d-grid gap-2">

                        <button type="submit"
                                class="btn btn-primary">

                            <i class="bi bi-check-circle"></i>
                            Save Changes

                        </button>

                        <a href="${pageContext.request.contextPath}/admin/halls?branchId=${branch.branchId}"
                           class="btn btn-outline-dark">

                            <i class="bi bi-door-open"></i>
                            View Rooms

                        </a>

                    </div>

                </div>

            </div>

        </div>

    </form>

</div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>