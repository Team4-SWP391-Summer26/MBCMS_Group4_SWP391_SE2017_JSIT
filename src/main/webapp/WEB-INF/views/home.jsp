<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>

    <body>

        <jsp:include page="common/header.jsp" />

        <div class="container mt-4">
            <h2 class="mb-4 fw-bold">Phim đang chiếu</h2>
            <div class="row row-cols-2 row-cols-md-4 g-3">
                <%-- TODO: forEach movieList --%>
                <div class="col">
                    <div class="card h-100 movie-card">
                        <img src="https://via.placeholder.com/300x450?text=Poster" class="card-img-top"
                             alt="poster">
                        <div class="card-body">
                            <h6 class="card-title fw-bold">Tên phim</h6>
                            <small class="text-secondary">2D | T13 | 120 phút</small>
                        </div>
                        <div class="card-footer border-0" style="background:transparent;">
                            <a href="#" class="btn btn-sm w-100 btn-primary-lc">Đặt vé</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="common/footer.jsp" />

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    </body>

</html>