<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiet phim - MBCMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    </head>
    <body>
        <%@ include file="/WEB-INF/views/common/header.jsp" %>
        <main class="container py-4">
            <h4>Chi tiet phim</h4>
            <p class="text-muted">Placeholder — owner <strong>AnhND</strong> implement View movie details + showtimes.</p>
        </main>
        <%@ include file="/WEB-INF/views/common/footer.jsp" %>
    </body>
</html>
