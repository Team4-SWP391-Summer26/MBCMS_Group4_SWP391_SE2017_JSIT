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
    <title>${isAdd ? 'Add Item' : 'Edit Item'} – F&amp;B Menu – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/manager.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* ── Category picker cards ──────────────────────── */
        .cat-card-btn {
            border: 2px solid var(--lc-border); border-radius: 12px;
            background: #fff; color: #0f1e36;
            padding: 1rem .75rem; display: block;
            cursor: pointer; transition: all .2s; user-select: none;
            text-align: center;
        }
        .btn-check:checked + .cat-card-btn {
            border-color: var(--lc-primary); background: var(--lc-light);
        }
        .cat-icon {
            font-size: 1.4rem; margin-bottom: .4rem; display: inline-block;
            padding: .35rem .55rem; border-radius: 8px;
        }
        .cat-icon.snack { background: #FFF7ED; color: #C2410C; }
        .cat-icon.drink { background: #EFF6FF; color: #1D4ED8; }
        .cat-icon.combo { background: #F5F3FF; color: #6D28D9; }

        /* ── Preview card ───────────────────────────────── */
        .preview-card {
            border: 1px solid var(--lc-border); border-radius: 14px;
            overflow: hidden; background: #fff;
            box-shadow: var(--lc-shadow);
        }
        .preview-img {
            width: 100%; height: 160px; object-fit: cover;
            background: #F1F5F9;
            display: flex; align-items: center; justify-content: center;
            color: #94A3B8; font-size: 2.5rem;
        }
        .preview-body { padding: 1rem; }
        .preview-name { font-size: 1rem; font-weight: 700; color: #0f1e36; }
        .preview-desc { font-size: .78rem; color: var(--lc-muted); margin-top: .2rem; }
        .preview-price { font-size: 1.25rem; font-weight: 800; color: var(--lc-primary); margin-top: .5rem; }
        .preview-meta  { font-size: .72rem; color: var(--lc-muted); margin-top: .35rem; }

        .form-switch .form-check-input { width: 2.8em; height: 1.5em; cursor: pointer; }
    </style>
</head>
<body class="lc-console">

<jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
    <jsp:param name="active" value="fnb"/>
</jsp:include>

<main class="lc-admin-main">
<div class="container-fluid px-4 py-4" style="max-width:1200px;">

    <%-- ── Page header ────────────────────────────────── --%>
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <div class="text-muted small mb-1">
                <a href="${pageContext.request.contextPath}/branch/food"
                   class="text-decoration-none text-muted">F&amp;B Menu</a>
                / <c:choose><c:when test="${isAdd}">Add Item</c:when><c:otherwise>Edit Item</c:otherwise></c:choose>
            </div>
            <h4 class="text-navy fw-bold mb-0">
                <c:choose>
                    <c:when test="${isAdd}">Add New Item</c:when>
                    <c:otherwise>Edit Item</c:otherwise>
                </c:choose>
            </h4>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-secondary btn-sm"
               href="${pageContext.request.contextPath}/branch/food">Cancel</a>
            <button type="submit" form="foodForm" class="btn btn-primary btn-sm">
                <i class="bi bi-check-lg me-1"></i>
                <c:choose>
                    <c:when test="${isAdd}">Add Item</c:when>
                    <c:otherwise>Save Changes</c:otherwise>
                </c:choose>
            </button>
        </div>
    </div>

    <%-- ── Error alert ─────────────────────────────────── --%>
    <c:if test="${not empty errorMsg}">
        <div class="alert alert-danger py-2 alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-1"></i> ${errorMsg}
            <button type="button" class="btn-close" data-bs-dismiss="alert" style="padding:.75rem 1rem;"></button>
        </div>
    </c:if>

    <div class="row g-4">

        <%-- ══ LEFT: Form ════════════════════════════════ --%>
        <div class="col-lg-7">
            <form id="foodForm"
                  method="post"
                  action="${pageContext.request.contextPath}/branch/food">

                <input type="hidden" name="action" value="${isAdd ? 'add' : 'edit'}">
                <c:if test="${not isAdd}">
                    <input type="hidden" name="foodId" value="${item.foodId}">
                </c:if>

                <%-- Section: Basic info --%>
                <div class="card lc-elev p-4 mb-4">
                    <h5 class="text-navy fw-bold mb-3">Basic Information</h5>

                    <div class="mb-3">
                        <label class="form-label fw-semibold text-navy small">
                            Item Name <span class="text-danger">*</span>
                        </label>
                        <input type="text" class="form-control form-control-sm"
                               name="name" id="inputName"
                               maxlength="100" required
                               placeholder="e.g. Popcorn Large"
                               value="${fn:escapeXml(item.name)}"
                               oninput="updatePreview()">
                    </div>

                    <div class="mb-0">
                        <label class="form-label fw-semibold text-navy small">Description</label>
                        <textarea class="form-control form-control-sm" name="description"
                                  id="inputDesc" rows="2" maxlength="255"
                                  placeholder="Short description shown to customers"
                                  oninput="updatePreview()"><c:out value="${item.description}"/></textarea>
                    </div>
                </div>

                <%-- Section: Category --%>
                <div class="card lc-elev p-4 mb-4">
                    <h5 class="text-navy fw-bold mb-3">
                        Category <span class="text-danger">*</span>
                    </h5>
                    <div class="row g-3">
                        <div class="col-4">
                            <input type="radio" class="btn-check" name="category"
                                   id="catSnack" value="SNACK" required
                                   ${item.category == 'SNACK' or (isAdd and empty item.category) ? 'checked' : ''}
                                   onchange="updatePreview()">
                            <label class="cat-card-btn h-100" for="catSnack">
                                <div class="cat-icon snack"><i class="bi bi-bag"></i></div>
                                <div class="fw-bold text-navy small">Snack</div>
                                <div class="text-muted" style="font-size:.72rem;">Popcorn, nachos…</div>
                            </label>
                        </div>
                        <div class="col-4">
                            <input type="radio" class="btn-check" name="category"
                                   id="catDrink" value="DRINK"
                                   ${item.category == 'DRINK' ? 'checked' : ''}
                                   onchange="updatePreview()">
                            <label class="cat-card-btn h-100" for="catDrink">
                                <div class="cat-icon drink"><i class="bi bi-cup-straw"></i></div>
                                <div class="fw-bold text-navy small">Drink</div>
                                <div class="text-muted" style="font-size:.72rem;">Soda, water…</div>
                            </label>
                        </div>
                        <div class="col-4">
                            <input type="radio" class="btn-check" name="category"
                                   id="catCombo" value="COMBO"
                                   ${item.category == 'COMBO' ? 'checked' : ''}
                                   onchange="updatePreview()">
                            <label class="cat-card-btn h-100" for="catCombo">
                                <div class="cat-icon combo"><i class="bi bi-box-seam"></i></div>
                                <div class="fw-bold text-navy small">Combo</div>
                                <div class="text-muted" style="font-size:.72rem;">Snack + drink…</div>
                            </label>
                        </div>
                    </div>
                </div>

                <%-- Section: Pricing & Stock --%>
                <div class="card lc-elev p-4 mb-4">
                    <h5 class="text-navy fw-bold mb-3">Pricing &amp; Stock</h5>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-navy small">
                                Price (VNĐ) <span class="text-danger">*</span>
                            </label>
                            <div class="input-group input-group-sm">
                                <input type="number" class="form-control"
                                       name="price" id="inputPrice"
                                       min="0" step="1000" required
                                       placeholder="e.g. 45000"
                                       value="${item.price}"
                                       oninput="updatePreview()">
                                <span class="input-group-text">đ</span>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-semibold text-navy small">
                                Stock <span class="text-danger">*</span>
                            </label>
                            <input type="number" class="form-control form-control-sm"
                                   name="stock" id="inputStock"
                                   min="0" required
                                   placeholder="e.g. 100"
                                   value="${item.stock}"
                                   oninput="updatePreview()">
                            <div class="text-muted small mt-1" style="font-size:.75rem;">
                                Set to 0 to mark as out of stock.
                            </div>
                        </div>
                    </div>
                </div>

                <%-- Section: Image & Status --%>
                <div class="card lc-elev p-4 mb-4">
                    <h5 class="text-navy fw-bold mb-3">Image &amp; Status</h5>

                    <div class="mb-3">
                        <label class="form-label fw-semibold text-navy small">Image URL</label>
                        <input type="url" class="form-control form-control-sm"
                               name="imageUrl" id="inputImageUrl"
                               placeholder="https://example.com/image.jpg"
                               value="${fn:escapeXml(item.imageUrl)}"
                               oninput="updatePreviewImage()">
                        <div class="text-muted small mt-1" style="font-size:.75rem;">
                            Paste a direct image URL. Leave blank to use default icon.
                        </div>
                    </div>

                    <hr class="my-3 text-muted" style="opacity:.15;">

                    <div class="d-flex align-items-center justify-content-between">
                        <div>
                            <div class="fw-bold text-navy small">Active Status</div>
                            <div class="text-muted small" style="font-size:.8rem;">
                                Inactive items are hidden from customers.
                            </div>
                        </div>
                        <div class="form-check form-switch p-0">
                            <input class="form-check-input ms-0" type="checkbox"
                                   name="active" id="activeToggle"
                                   ${(isAdd or item.active) ? 'checked' : ''}>
                        </div>
                    </div>
                </div>

            </form>
        </div>

        <%-- ══ RIGHT: Live preview ═══════════════════════ --%>
        <div class="col-lg-5">
            <div class="sticky-top" style="top:24px;z-index:100;">

                <div class="text-muted small fw-semibold mb-2"
                     style="letter-spacing:.05em;text-transform:uppercase;">
                    Live Preview
                </div>

                <div class="preview-card mb-4">
                    <%-- Image area --%>
                    <div id="previewImgWrap">
                        <c:choose>
                            <c:when test="${not empty item.imageUrl}">
                                <img id="previewImg" src="${fn:escapeXml(item.imageUrl)}"
                                     alt="preview"
                                     style="width:100%;height:160px;object-fit:cover;">
                            </c:when>
                            <c:otherwise>
                                <div id="previewImgPlaceholder"
                                     class="preview-img">
                                    <i class="bi bi-image"></i>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="preview-body">
                        <%-- Category pill --%>
                        <div id="previewCatWrap" class="mb-2">
                            <span id="previewCat" class="pill"
                                  style="font-size:.72rem;"></span>
                        </div>
                        <div class="preview-name"  id="previewName">Item name</div>
                        <div class="preview-desc"  id="previewDesc"></div>
                        <div class="preview-price" id="previewPrice">0đ</div>
                        <div class="preview-meta"  id="previewStock"></div>
                    </div>
                </div>

                <%-- Notes --%>
                <div class="card lc-elev p-3">
                    <div class="text-navy fw-bold small mb-2">
                        <i class="bi bi-info-circle me-1 text-primary"></i> Notes
                    </div>
                    <ul class="text-muted small mb-0 ps-3" style="font-size:.8rem;line-height:1.7;">
                        <li>Items are visible only to customers booking at <strong>this branch</strong>.</li>
                        <li>Price and stock can be updated anytime from the menu list.</li>
                        <li>Setting stock to <strong>0</strong> marks the item as out of stock but keeps it in the menu.</li>
                    </ul>
                </div>

            </div>
        </div>

    </div><%-- /row --%>
</div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const CAT_CONFIG = {
        SNACK: { label: 'Snack', cls: 'cat-snack' },
        DRINK: { label: 'Drink', cls: 'cat-drink' },
        COMBO: { label: 'Combo', cls: 'cat-combo' }
    };

    function selectedCategory() {
        const r = document.querySelector('input[name="category"]:checked');
        return r ? r.value : '';
    }

    function formatPrice(val) {
        if (!val || isNaN(val)) return '0đ';
        return new Intl.NumberFormat('vi-VN').format(val) + 'đ';
    }

    function updatePreview() {
        const name  = document.getElementById('inputName').value.trim()  || 'Item name';
        const desc  = document.getElementById('inputDesc').value.trim();
        const price = document.getElementById('inputPrice').value;
        const stock = document.getElementById('inputStock').value;
        const cat   = selectedCategory();

        document.getElementById('previewName').textContent  = name;
        document.getElementById('previewDesc').textContent  = desc;
        document.getElementById('previewPrice').textContent = formatPrice(price);

        const stockVal = parseInt(stock, 10);
        const stockEl  = document.getElementById('previewStock');
        if (!isNaN(stockVal)) {
            stockEl.textContent = stockVal === 0 ? '⚠ Out of stock' : stockVal + ' in stock';
            stockEl.style.color = stockVal === 0 ? '#B02A37' : '#64748B';
        } else {
            stockEl.textContent = '';
        }

        // Category pill
        const catEl = document.getElementById('previewCat');
        if (cat && CAT_CONFIG[cat]) {
            const cfg = CAT_CONFIG[cat];
            catEl.textContent = cfg.label;
            catEl.className   = 'pill ' + cfg.cls;
            catEl.style.fontSize = '.72rem';
        } else {
            catEl.textContent = '';
        }
    }

    function updatePreviewImage() {
        const url  = document.getElementById('inputImageUrl').value.trim();
        const wrap = document.getElementById('previewImgWrap');

        if (url) {
            wrap.innerHTML = '<img id="previewImg" src="' + url + '" alt="preview" '
                + 'style="width:100%;height:160px;object-fit:cover;" '
                + 'onerror="this.style.display=\'none\';document.getElementById(\'imgErr\').style.display=\'flex\';">'
                + '<div id="imgErr" style="display:none;width:100%;height:160px;'
                + 'align-items:center;justify-content:center;background:#FEE2E2;'
                + 'color:#991B1B;font-size:.82rem;gap:.4rem;">'
                + '<i class="bi bi-exclamation-triangle"></i> Invalid image URL</div>';
        } else {
            wrap.innerHTML = '<div class="preview-img"><i class="bi bi-image"></i></div>';
        }
    }

    // Init preview on load
    window.addEventListener('DOMContentLoaded', function () {
        updatePreview();
        // Bind category radio change
        document.querySelectorAll('input[name="category"]').forEach(r => {
            r.addEventListener('change', updatePreview);
        });
    });
</script>
</body>
</html>
