<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="en_US" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>F&amp;B Menu – MBCMS Manager</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* ── Category filter tabs ───────────────────────── */
        .filter-tab {
            cursor: pointer; padding: .4rem .85rem;
            font-size: .85rem; font-weight: 600;
            color: var(--lc-muted); border-radius: 6px;
            text-decoration: none; transition: all .15s;
        }
        .filter-tab:hover { background: #f1f5f9; color: #0f172a; }
        .filter-tab.active { background: var(--lc-primary); color: #fff; }

        /* ── Category pills ─────────────────────────────── */
        .cat-snack  { background: #FFF7ED; color: #C2410C; border: 1px solid #FED7AA; }
        .cat-drink  { background: #EFF6FF; color: #1D4ED8; border: 1px solid #BFDBFE; }
        .cat-combo  { background: #F5F3FF; color: #6D28D9; border: 1px solid #DDD6FE; }

        /* ── Stock inline edit ──────────────────────────── */
        .stock-input {
            width: 72px; border: 1px solid var(--lc-border);
            border-radius: 6px; padding: .25rem .45rem;
            font-size: .85rem; text-align: center;
        }
        .stock-input:focus { outline: none; border-color: var(--lc-primary); }
        .stock-save-btn {
            padding: .25rem .5rem; font-size: .78rem;
            border-radius: 6px; border: 1px solid var(--lc-border);
            background: #fff; cursor: pointer; color: #374151;
            display: none;
        }
        .stock-save-btn:hover { background: var(--lc-primary); color: #fff; border-color: var(--lc-primary); }
        .stock-wrap:focus-within .stock-save-btn { display: inline-block; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="fnb"/>
</jsp:include>

<main class="lc-admin-main">
<div class="container-fluid px-4 py-4" style="max-width:1240px;">

    <%-- ── Page header ──────────────────────────────────── --%>
    <div class="mb-3">
        <div class="text-muted small mb-1">Dashboard / F&amp;B Menu</div>
        <h4 class="text-navy fw-bold mb-0">F&amp;B Menu Management</h4>
    </div>

    <%-- ── Scope notice ──────────────────────────────────── --%>
    <div class="lc-scope mb-4">
        <i class="bi bi-info-circle-fill" style="color:#cf9a00;"></i>
        <span>Menu items are <strong>branch-specific</strong> — only visible to customers booking at this branch.</span>
    </div>

    <%-- ── Alerts ────────────────────────────────────────── --%>
    <c:if test="${not empty successMsg}">
        <div class="alert alert-success py-2 alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-1"></i> ${successMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert" style="padding:.75rem 1rem;"></button>
        </div>
    </c:if>
    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger py-2 alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-1"></i> ${errorMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert" style="padding:.75rem 1rem;"></button>
        </div>
    </c:if>

    <%-- ── KPI cards ──────────────────────────────────────── --%>
    <div class="row g-3 mb-4">
        <div class="col-sm-6 col-xl-4">
            <div class="card lc-elev p-3 h-100">
                <div class="d-flex align-items-center gap-3">
                    <div class="lc-stat-icon" style="background:#EFF6FF;color:#1D4ED8;">
                        <i class="bi bi-cup-straw-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small fw-semibold">Total Items</div>
                        <div class="text-navy lc-stat-value" style="font-size:1.6rem;">${totalItems}</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-4">
            <div class="card lc-elev p-3 h-100">
                <div class="d-flex align-items-center gap-3">
                    <div class="lc-stat-icon" style="background:#E8F5EE;color:#198754;">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small fw-semibold">Active</div>
                        <div class="text-navy lc-stat-value" style="font-size:1.6rem;">${activeItems}</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-sm-6 col-xl-4">
            <div class="card lc-elev p-3 h-100">
                <div class="d-flex align-items-center gap-3">
                    <div class="lc-stat-icon" style="background:#FBE4E6;color:#B02A37;">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>
                    <div>
                        <div class="text-muted small fw-semibold">Out of Stock</div>
                        <div class="text-navy lc-stat-value" style="font-size:1.6rem;">${outOfStock}</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- ── Toolbar ────────────────────────────────────────── --%>
    <div class="card lc-elev p-3 mb-4">
        <div class="row g-3 align-items-center">
            <%-- Search --%>
            <div class="col-md-4">
                <div class="input-group input-group-sm">
                    <span class="input-group-text bg-white border-end-0 text-muted">
                        <i class="bi bi-search"></i>
                    </span>
                    <input type="text" id="searchInput" class="form-control border-start-0"
                           placeholder="Search items..." oninput="filterTable()">
                </div>
            </div>

            <%-- Category filter tabs --%>
            <div class="col-md-5">
                <div class="d-flex gap-1 bg-light p-1 rounded">
                    <a class="filter-tab active" id="tab-all"    onclick="setCategory('')">All</a>
                    <a class="filter-tab"        id="tab-snack"  onclick="setCategory('SNACK')">
                        <i class="bi bi-bag me-1"></i>Snack
                    </a>
                    <a class="filter-tab"        id="tab-drink"  onclick="setCategory('DRINK')">
                        <i class="bi bi-cup-straw me-1"></i>Drink
                    </a>
                    <a class="filter-tab"        id="tab-combo"  onclick="setCategory('COMBO')">
                        <i class="bi bi-box-seam me-1"></i>Combo
                    </a>
                </div>
            </div>

            <%-- Add button --%>
            <div class="col-md-3 text-md-end">
                <a class="btn btn-primary btn-sm"
                   href="${pageContext.request.contextPath}/branch/food?action=add">
                    <i class="bi bi-plus-lg me-1"></i> Add Item
                </a>
            </div>
        </div>
    </div>

    <%-- ── Menu table ─────────────────────────────────────── --%>
    <div class="card lc-elev p-0 overflow-hidden">
        <div class="table-responsive">
            <table class="table lc-table align-middle mb-0" id="menuTable">
                <thead>
                    <tr>
                        <th class="ps-3" style="width:56px;">Image</th>
                        <th>Name</th>
                        <th>Category</th>
                        <th>Price</th>
                        <th>Stock</th>
                        <th>Status</th>
                        <th class="text-end pe-3">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <c:if test="${empty menuItems}">
                        <tr>
                            <td colspan="7" class="text-center text-muted py-5">
                                <i class="bi bi-cup-straw" style="font-size:2rem;display:block;margin-bottom:.5rem;"></i>
                                No items yet. <a href="${pageContext.request.contextPath}/branch/food?action=add">Add your first item</a>.
                            </td>
                        </tr>
                    </c:if>

                    <c:forEach var="item" items="${menuItems}">
                        <tr data-name="${fn:toLowerCase(item.name)}"
                            data-category="${item.category}">

                            <%-- Image --%>
                            <td class="ps-3">
                                <c:choose>
                                    <c:when test="${not empty item.imageUrl}">
                                        <img src="${fn:escapeXml(item.imageUrl)}"
                                             alt="${fn:escapeXml(item.name)}"
                                             style="width:40px;height:40px;object-fit:cover;border-radius:8px;border:1px solid var(--lc-border);">
                                    </c:when>
                                    <c:otherwise>
                                        <div style="width:40px;height:40px;border-radius:8px;
                                                    background:#F1F5F9;border:1px solid var(--lc-border);
                                                    display:flex;align-items:center;justify-content:center;
                                                    color:#94A3B8;font-size:1.1rem;">
                                            <i class="bi bi-image"></i>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <%-- Name + description --%>
                            <td>
                                <div class="text-navy fw-semibold">
                                    <c:out value="${item.name}"/>
                                </div>
                                <c:if test="${not empty item.description}">
                                    <div class="text-muted small text-truncate" style="max-width:220px;">
                                        <c:out value="${item.description}"/>
                                    </div>
                                </c:if>
                            </td>

                            <%-- Category --%>
                            <td>
                                <c:choose>
                                    <c:when test="${item.category == 'SNACK'}">
                                        <span class="pill cat-snack">
                                            <i class="bi bi-bag me-1"></i>Snack
                                        </span>
                                    </c:when>
                                    <c:when test="${item.category == 'DRINK'}">
                                        <span class="pill cat-drink">
                                            <i class="bi bi-cup-straw me-1"></i>Drink
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pill cat-combo">
                                            <i class="bi bi-box-seam me-1"></i>Combo
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <%-- Price --%>
                            <td class="fw-bold text-navy">
                                <fmt:formatNumber value="${item.price}" pattern="#,##0"/>đ
                            </td>

                            <%-- Stock — inline AJAX edit --%>
                            <td>
                                <div class="d-flex align-items-center gap-1 stock-wrap">
                                    <input type="number" min="0"
                                           class="stock-input"
                                           id="stock-${item.foodId}"
                                           value="${item.stock}"
                                           data-food-id="${item.foodId}"
                                           data-original="${item.stock}"
                                           oninput="onStockInput(this)">
                                    <button class="stock-save-btn"
                                            id="stockBtn-${item.foodId}"
                                            onclick="saveStock(${item.foodId})">
                                        <i class="bi bi-check-lg"></i>
                                    </button>
                                    <c:if test="${item.stock == 0}">
                                        <span class="pill pill-red ms-1" style="font-size:.7rem;">Out</span>
                                    </c:if>
                                </div>
                            </td>

                            <%-- Status --%>
                            <td>
                                <c:choose>
                                    <c:when test="${item.active}">
                                        <span class="pill pill-green">Active</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pill pill-gray">Inactive</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>

                            <%-- Actions --%>
                            <td class="text-end pe-3">
                                <div class="d-flex gap-1 justify-content-end">

                                    <%-- Edit --%>
                                    <a class="btn btn-sm btn-outline-primary" title="Edit"
                                       href="${pageContext.request.contextPath}/branch/food?action=edit&foodId=${item.foodId}">
                                        <i class="bi bi-pencil"></i>
                                    </a>

                                    <%-- Toggle active --%>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/branch/food"
                                          class="d-inline">
                                        <input type="hidden" name="action"  value="toggleStatus">
                                        <input type="hidden" name="foodId"  value="${item.foodId}">
                                        <input type="hidden" name="active"  value="${!item.active}">
                                        <button type="submit"
                                                class="btn btn-sm ${item.active ? 'btn-outline-warning' : 'btn-outline-success'}"
                                                title="${item.active ? 'Deactivate' : 'Activate'}">
                                            <i class="bi ${item.active ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
                                        </button>
                                    </form>

                                    <%-- Delete --%>
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/branch/food"
                                          class="d-inline"
                                          onsubmit="return confirm('Delete \'${fn:escapeXml(item.name)}\'? This cannot be undone.');">
                                        <input type="hidden" name="action"  value="delete">
                                        <input type="hidden" name="foodId"  value="${item.foodId}">
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                            <i class="bi bi-trash-fill"></i>
                                        </button>
                                    </form>

                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

</div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const CTX = '${pageContext.request.contextPath}';
    let activeCategory = '';

    /* ── Category filter tabs ──────────────────────────── */
    function setCategory(cat) {
        activeCategory = cat;
        document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
        const id = cat === '' ? 'tab-all'
                 : cat === 'SNACK' ? 'tab-snack'
                 : cat === 'DRINK' ? 'tab-drink' : 'tab-combo';
        document.getElementById(id).classList.add('active');
        filterTable();
    }

    /* ── Search + category filter ──────────────────────── */
    function filterTable() {
        const q   = document.getElementById('searchInput').value.toLowerCase();
        const rows = document.querySelectorAll('#menuTable tbody tr[data-name]');
        let   shown = 0;

        rows.forEach(row => {
            const matchName = !q || row.dataset.name.includes(q);
            const matchCat  = !activeCategory || row.dataset.category === activeCategory;
            const show      = matchName && matchCat;
            row.style.display = show ? '' : 'none';
            if (show) shown++;
        });

        // Show empty state if nothing visible
        const emptyRow = document.querySelector('#menuTable tbody tr:not([data-name])');
        if (emptyRow) emptyRow.style.display = shown === 0 ? '' : 'none';
    }

    /* ── Stock inline edit ─────────────────────────────── */
    function onStockInput(input) {
        const btn = document.getElementById('stockBtn-' + input.dataset.foodId);
        if (btn) btn.style.display = input.value !== input.dataset.original ? 'inline-block' : 'none';
    }

    async function saveStock(foodId) {
        const input = document.getElementById('stock-' + foodId);
        const stock = parseInt(input.value, 10);

        if (isNaN(stock) || stock < 0) {
            alert('Số lượng không hợp lệ.');
            return;
        }

        try {
            const res  = await fetch(CTX + '/branch/food', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'action=updateStock&foodId=' + foodId + '&stock=' + stock
            });
            const data = await res.json();
            if (data.success) {
                input.dataset.original = String(stock);
                const btn = document.getElementById('stockBtn-' + foodId);
                if (btn) btn.style.display = 'none';

                // Update Out of stock badge in same cell
                const cell  = input.closest('td');
                const badge = cell.querySelector('.pill-red');
                if (stock === 0 && !badge) {
                    const span = document.createElement('span');
                    span.className = 'pill pill-red ms-1';
                    span.style.fontSize = '.7rem';
                    span.textContent = 'Out';
                    cell.querySelector('.stock-wrap').appendChild(span);
                } else if (stock > 0 && badge) {
                    badge.remove();
                }

                // Update KPI out-of-stock count
                recalcOutOfStock();
            } else {
                alert(data.message || 'Cập nhật thất bại.');
            }
        } catch (e) {
            alert('Lỗi mạng. Vui lòng thử lại.');
        }
    }

    function recalcOutOfStock() {
        let count = 0;
        document.querySelectorAll('.stock-input').forEach(inp => {
            if (parseInt(inp.value, 10) === 0) count++;
        });
        // Update KPI card value (3rd card)
        const cards = document.querySelectorAll('.lc-stat-value');
        if (cards[2]) cards[2].textContent = count;
    }
</script>
</body>
</html>
