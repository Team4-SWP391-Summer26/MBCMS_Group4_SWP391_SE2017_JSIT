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
    <title>F&amp;B Menu – PentaPlex Manager</title>
    <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
    <style>
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
<div class="lc-page">

    <div class="lc-page-head mb-2">
        <div>
            <div class="lc-page-crumb">Dashboard / <strong>F&amp;B Menu</strong></div>
            <h1 class="lc-page-title">F&amp;B Menu Management</h1>
        </div>
        <c:if test="${not empty sessionScope.currentBranchName}">
            <span class="lc-branch-chip">
                <i class="bi bi-geo-alt-fill"></i>
                <c:out value="${sessionScope.currentBranchName}"/>
            </span>
        </c:if>
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
    <div class="lc-kpi-row lc-kpi-row--3">
        <div class="lc-kpi-card lc-rise" style="--i:0;">
            <div class="lc-stat-icon lc-kpi-icon--blue"><i class="bi bi-basket-fill"></i></div>
            <div>
                <div class="lc-kpi-label">Total items</div>
                <div class="lc-kpi-value">${totalItems}</div>
                <div class="lc-kpi-hint">Concessions in this branch</div>
            </div>
        </div>
        <div class="lc-kpi-card lc-rise" style="--i:1;">
            <div class="lc-stat-icon lc-kpi-icon--green"><i class="bi bi-check-circle-fill"></i></div>
            <div>
                <div class="lc-kpi-label">Active</div>
                <div class="lc-kpi-value">${activeItems}</div>
                <div class="lc-kpi-hint">Visible to customers</div>
            </div>
        </div>
        <div class="lc-kpi-card lc-rise" style="--i:2;">
            <div class="lc-stat-icon lc-kpi-icon--rose"><i class="bi bi-exclamation-triangle-fill"></i></div>
            <div>
                <div class="lc-kpi-label">Out of stock</div>
                <div class="lc-kpi-value" id="kpiOutOfStock">${outOfStock}</div>
                <div class="lc-kpi-hint">Needs restocking</div>
            </div>
        </div>
    </div>

    <%-- ── Toolbar ────────────────────────────────────────── --%>
    <div class="st-toolbar st-toolbar--single fnb-toolbar mb-4">
        <div class="st-toolbar-track">
            <div class="fnb-toolbar-search">
                <i class="bi bi-search" aria-hidden="true"></i>
                <input type="search" id="searchInput" class="fnb-search-input"
                       placeholder="Search items..." autocomplete="off"
                       oninput="filterTable()" aria-label="Search menu items">
            </div>

            <div class="st-toolbar-vrule" aria-hidden="true"></div>

            <div class="fnb-seg" role="tablist" aria-label="Filter by category">
                <button type="button" class="fnb-seg-btn active" id="tab-all" role="tab"
                        aria-selected="true" onclick="setCategory('')">
                    <i class="bi bi-grid-3x3-gap-fill" aria-hidden="true"></i> All
                </button>
                <button type="button" class="fnb-seg-btn" id="tab-snack" role="tab"
                        aria-selected="false" onclick="setCategory('SNACK')">
                    <i class="bi bi-bag" aria-hidden="true"></i> Snack
                </button>
                <button type="button" class="fnb-seg-btn" id="tab-drink" role="tab"
                        aria-selected="false" onclick="setCategory('DRINK')">
                    <i class="bi bi-cup-straw" aria-hidden="true"></i> Drink
                </button>
                <button type="button" class="fnb-seg-btn" id="tab-combo" role="tab"
                        aria-selected="false" onclick="setCategory('COMBO')">
                    <i class="bi bi-box-seam" aria-hidden="true"></i> Combo
                </button>
            </div>

            <div class="fnb-toolbar-spacer" aria-hidden="true"></div>

            <a class="st-toolbar-add"
               href="${pageContext.request.contextPath}/branch/food?action=add">
                <i class="bi bi-plus-lg" aria-hidden="true"></i> Add Item
            </a>
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
                            <td colspan="7" class="p-0">
                                <div class="lc-empty">
                                    <i class="bi bi-cup-straw"></i>
                                    <div class="lc-empty-title">No menu items yet</div>
                                    <div class="lc-empty-hint">Add snacks, drinks and combos to sell at this branch. Items you add here appear in the customer booking flow.</div>
                                    <a class="st-toolbar-add mt-2" href="${pageContext.request.contextPath}/branch/food?action=add">
                                        <i class="bi bi-plus-lg"></i> Add your first item</a>
                                </div>
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
                                                    color:var(--text-subtle);font-size:1.1rem;">
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
                                <fmt:formatNumber value="${item.price}" pattern="#,##0"/> VND
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
                                        <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
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
                                        <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
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

<%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
<script>
    // CTX: Dynamic Context Path binder matching client URLs to J2EE server paths
    const CTX = '${pageContext.request.contextPath}';
    let activeCategory = '';

    /**
     * [Flow Step: JavaScript] Sets active category filter and triggers table re-render
     */
    function setCategory(cat) {
        activeCategory = cat;
        document.querySelectorAll('.fnb-seg-btn').forEach(t => {
            t.classList.remove('active');
            t.setAttribute('aria-selected', 'false');
        });
        const id = cat === '' ? 'tab-all'
                 : cat === 'SNACK' ? 'tab-snack'
                 : cat === 'DRINK' ? 'tab-drink' : 'tab-combo';
        const activeTab = document.getElementById(id);
        activeTab.classList.add('active');
        activeTab.setAttribute('aria-selected', 'true');
        filterTable();
    }

    /**
     * [Flow Step: JavaScript] Client-side search and category filtering logic (no-reload UX)
     */
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

        // Show empty placeholder row if no elements match the query
        const emptyRow = document.querySelector('#menuTable tbody tr:not([data-name])');
        if (emptyRow) emptyRow.style.display = shown === 0 ? '' : 'none';
    }

    /**
     * [Flow Step: JavaScript] Display check button when stock quantity changes from original baseline
     */
    function onStockInput(input) {
        const btn = document.getElementById('stockBtn-' + input.dataset.foodId);
        if (btn) btn.style.display = input.value !== input.dataset.original ? 'inline-block' : 'none';
    }

    /**
     * [Flow Step: AJAX -> Servlet] Asynchronously updates stock values using fetch POST request without page reload
     */
    async function saveStock(foodId) {
        const input = document.getElementById('stock-' + foodId);
        const stock = parseInt(input.value, 10);

        if (isNaN(stock) || stock < 0) {
            lcAlert('Invalid quantity.');
            return;
        }

        try {
            // [Flow Step: JS -> Servlet] POST AJAX request containing updated stock values
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

                // Dynamically update Out of stock badge in the table cell
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

                // Update out-of-stock KPI counts dynamically
                recalcOutOfStock();
            } else {
                lcAlert(data.message || 'Update failed.');
            }
        } catch (e) {
            lcAlert('Network error. Please try again.');
        }
    }

    function recalcOutOfStock() {
        let count = 0;
        document.querySelectorAll('.stock-input').forEach(inp => {
            if (parseInt(inp.value, 10) === 0) count++;
        });
        // Update KPI "Out of stock" card value
        const oos = document.getElementById('kpiOutOfStock');
        if (oos) oos.textContent = count;
    }
</script>
</body>
</html>
