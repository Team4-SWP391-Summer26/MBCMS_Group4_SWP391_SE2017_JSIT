<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>

<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Branch Operating Hours</title>

```
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">

<link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}"
      rel="stylesheet">
```

</head>

<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
<jsp:param name="active" value="hours"/>
</jsp:include>

<main class="lc-admin-main">

```
<div class="container-fluid px-4 py-4" style="max-width:900px;">

    <div class="mb-4">
        <div class="text-muted small">Branch Management</div>
        <h4 class="fw-bold text-navy mb-0">
            Operating Hours
        </h4>
    </div>

    <c:if test="${not empty successMsg}">
        <div class="alert alert-success alert-dismissible fade show">
            ${successMsg}
            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger alert-dismissible fade show">
            ${errorMsg}
            <button type="button"
                    class="btn-close"
                    data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="card lc-elev">

        <div class="card-header bg-white">
            <h5 class="mb-0">
                <i class="bi bi-clock-history me-2"></i>
                Configure Branch Operating Hours
            </h5>
        </div>

        <div class="card-body">

            <form method="post"
                  action="${pageContext.request.contextPath}/branch/hours">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>

                <div class="row">

                    <div class="col-md-6 mb-3">

                        <label class="form-label">
                            Opening Time
                        </label>

                        <input type="time"
                               class="form-control"
                               name="openingTime"
                               value="<c:choose><c:when test="${branch.openingTime != null}">${fn:substring(branch.openingTime, 0, 5)}</c:when><c:otherwise>08:00</c:otherwise></c:choose>"
                               required>

                    </div>

                    <div class="col-md-6 mb-3">

                        <label class="form-label">
                            Closing Time
                        </label>

                        <input type="time"
                               class="form-control"
                               name="closingTime"
                               value="<c:choose><c:when test="${branch.closingTime != null}">${fn:substring(branch.closingTime, 0, 5)}</c:when><c:otherwise>23:00</c:otherwise></c:choose>"
                               required>

                    </div>

                </div>

                <hr>

                <div class="d-flex justify-content-end">

                    <button type="submit"
                            class="btn btn-primary">

                        <i class="bi bi-save me-1"></i>
                        Save Changes

                    </button>

                </div>

            </form>

        </div>

    </div>

</div>
```

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
