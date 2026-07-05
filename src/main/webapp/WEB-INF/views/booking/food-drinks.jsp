<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%--
    Food & Drinks (booking step 3) — redesigned to match showtime/seats polish.
    Logic / form data: KHONG DOI — chi restructure HTML + new CSS classes.
    Category navigation: pill-tabs giong date-tabs-row cua showtimes.
    Summary panel: sticky giong sel-panel cua seats.
--%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Select Food & Drinks – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/booking.css?v=${applicationScope.assetVersion}" rel="stylesheet">
</head>
<body class="bk-page">
<jsp:include page="../common/header.jsp" />

<%-- ===== Context bar (dong bo seats.jsp) ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <c:choose>
                <c:when test="${not empty bookingId}">
                    <a href="${pageContext.request.contextPath}/customer/booking/detail?bookingId=${bookingId}"
                       class="btn btn-sm btn-outline-secondary" title="Back to Booking">
                        <i class="bi bi-arrow-left"></i>
                    </a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/booking/seats?showtimeId=${showtimeId}"
                       class="btn btn-sm btn-outline-secondary" title="Back to Seats">
                        <i class="bi bi-arrow-left"></i>
                    </a>
                </c:otherwise>
            </c:choose>
            <c:choose>
                <c:when test="${not empty booking.posterUrl}">
                    <img class="bk-poster" src="<c:url value='${booking.posterUrl}'/>" alt="<c:out value='${booking.movieTitle}'/>">
                </c:when>
                <c:when test="${not empty showtime.posterUrl}">
                    <img class="bk-poster" src="<c:url value='${showtime.posterUrl}'/>" alt="<c:out value='${showtime.movieTitle}'/>">
                </c:when>
                <c:otherwise><div class="bk-poster"><i class="bi bi-film"></i></div></c:otherwise>
            </c:choose>
            <div class="flex-grow-1">
                <div class="fw-bold bk-context-title">
                    <c:out value="${not empty booking.movieTitle ? booking.movieTitle : showtime.movieTitle}"/>
                </div>
                <div class="text-muted small">
                    <i class="bi bi-calendar-event"></i>
                    <c:choose>
                        <c:when test="${not empty startTimeStr}">${startTimeStr}</c:when>
                        <c:otherwise>Showtime #${showtimeId}</c:otherwise>
                    </c:choose>
                    <span class="badge bg-light text-dark border ms-1">${showtime.format}</span>
                    <span class="badge bg-light text-dark border ms-1">${showtime.subtitleType}</span>
                </div>
            </div>
            <div class="text-end">
                <div class="text-muted small">Seats</div>
                <div class="fw-bold bk-mono bk-context-title">
                    <c:choose>
                        <c:when test="${not empty booking.seatLabels}">
                            <c:forEach var="lbl" items="${booking.seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                        </c:when>
                        <c:when test="${not empty seatLabels}">
                            <c:forEach var="lbl" items="${seatLabels}" varStatus="s">${lbl}<c:if test="${not s.last}">, </c:if></c:forEach>
                        </c:when>
                        <c:otherwise>—</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <c:choose>
        <c:when test="${not empty bookingId}">
            <%-- Post-purchase flow --%>
            <div class="fnb-post-purchase">
                <div class="fnb-post-purchase-icon"><i class="bi bi-bag-plus-fill"></i></div>
                <div>
                    <div class="fnb-post-purchase-title">Post-Purchase Concessions</div>
                    <div class="fnb-post-purchase-desc">Choose your snacks and drinks. Pay at the counter when you arrive.</div>
                </div>
            </div>
        </c:when>
        <c:otherwise>
            <%-- ===== Stepper (3/6 Food & Drinks) ===== --%>
            <div class="bk-steps mb-4">
                <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Showtime</div>
                <div class="bk-line done"></div>
                <div class="bk-step done"><span class="bk-dot"><i class="bi bi-check-lg"></i></span>Seats</div>
                <div class="bk-line done"></div>
                <div class="bk-step active"><span class="bk-dot">3</span>Food & Drinks</div>
                <div class="bk-line"></div>
                <div class="bk-step"><span class="bk-dot">4</span>Review</div>
                <div class="bk-line"></div>
                <div class="bk-step"><span class="bk-dot">5</span>Payment</div>
                <div class="bk-line"></div>
                <div class="bk-step"><span class="bk-dot">6</span>Confirm</div>
            </div>
        </c:otherwise>
    </c:choose>

    <h3 class="fw-bold mb-1 bk-title">Snacks & Drinks Catalog</h3>
    <p class="text-muted mb-4">Select items to add to your order. You can skip if you don't want any.</p>

    <form id="foodForm" action="${pageContext.request.contextPath}/booking/food-drinks" method="POST">
        <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
        <input type="hidden" name="showtimeId" value="${showtimeId}">
        <input type="hidden" name="seatIds" value="${seatIds}">
        <c:if test="${not empty bookingId}">
            <input type="hidden" name="bookingId" value="${bookingId}">
        </c:if>

        <div class="row g-4">
            <%-- ====== Left: Catalog items ====== --%>
            <div class="col-lg-8">

                <%-- Category pill-tabs navigation --%>
                <div class="fnb-cat-nav" role="tablist">
                    <button type="button" class="fnb-cat-btn active" data-cat="all" onclick="filterCategory('all')" role="tab">
                        <i class="bi bi-grid-3x3-gap-fill"></i> All Items
                    </button>
                    <button type="button" class="fnb-cat-btn" data-cat="COMBO" onclick="filterCategory('COMBO')" role="tab">
                        <i class="bi bi-gift-fill"></i> Combos
                    </button>
                    <button type="button" class="fnb-cat-btn" data-cat="SNACK" onclick="filterCategory('SNACK')" role="tab">
                        <i class="bi bi-egg-fried"></i> Popcorn / Snacks
                    </button>
                    <button type="button" class="fnb-cat-btn" data-cat="DRINK" onclick="filterCategory('DRINK')" role="tab">
                        <i class="bi bi-cup-straw"></i> Drinks
                    </button>
                </div>

                <%-- Category: COMBO --%>
                <div class="fnb-section" data-section="COMBO">
                    <h5 class="fnb-section-title"><i class="bi bi-gift-fill"></i> Combos & Deals</h5>
                    <div class="row g-3 mb-4">
                        <c:forEach var="item" items="${foodItems}">
                            <c:if test="${item.category == 'COMBO'}">
                                <c:set var="qty" value="0"/>
                                <c:if test="${not empty existingFood}">
                                    <c:forEach var="entry" items="${existingFood}">
                                        <c:if test="${entry.key.foodId == item.foodId}">
                                            <c:set var="qty" value="${entry.value}"/>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                <c:set var="iconClass" value="bi-gift-fill"/>
                                <c:set var="colorClass" value="combo-red"/>
                                <c:choose>
                                    <c:when test="${item.name == 'Combo Solo'}">
                                        <c:set var="iconClass" value="bi-gift"/>
                                        <c:set var="colorClass" value="combo-green"/>
                                    </c:when>
                                    <c:when test="${item.name == 'Combo for 2'}">
                                        <c:set var="iconClass" value="bi-gift-fill"/>
                                        <c:set var="colorClass" value="combo-red"/>
                                    </c:when>
                                </c:choose>
                                <div class="col-lg-4 col-sm-6">
                                    <div class="food-card ${qty > 0 ? 'added' : ''}" id="food_card_${item.foodId}">
                                        <div id="added_badge_${item.foodId}" class="added-badge ${qty > 0 ? '' : 'd-none'}">
                                            <span class="badge bg-primary text-white border border-light food-added-badge">
                                                <i class="bi bi-check-circle-fill me-1"></i> Added
                                            </span>
                                        </div>
                                        <div class="food-img-wrapper themed ${colorClass}">
                                            <div class="glow-circle"></div>
                                            <i class="bi ${iconClass}"></i>
                                        </div>
                                        <div class="food-info">
                                            <div>
                                                <div class="food-name">${item.name}</div>
                                                <div class="text-muted small mt-1">${item.description}</div>
                                            </div>
                                            <div class="d-flex justify-content-between align-items-center mt-3">
                                                <div class="food-price">
                                                    <fmt:formatNumber value="${item.price}" pattern="#,###"/> VND
                                                </div>
                                                <div>
                                                    <input type="hidden" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}">
                                                    <button type="button" id="add_btn_${item.foodId}" class="btn btn-outline-primary btn-sm px-3 fw-bold food-add-btn ${qty > 0 ? 'd-none' : ''}" onclick="updateQty(${item.foodId}, 1)">
                                                        + Add
                                                    </button>
                                                    <div id="stepper_${item.foodId}" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 food-stepper ${qty > 0 ? '' : 'd-none'}">
                                                        <button type="button" class="btn btn-sm text-white p-0 fw-bold food-stepper-btn" onclick="updateQty(${item.foodId}, -1)">-</button>
                                                        <strong id="stepper_qty_${item.foodId}">${qty}</strong>
                                                        <button type="button" class="btn btn-sm text-white p-0 fw-bold food-stepper-btn" onclick="updateQty(${item.foodId}, 1)">+</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

                <%-- Category: SNACK --%>
                <div class="fnb-section" data-section="SNACK">
                    <h5 class="fnb-section-title"><i class="bi bi-egg-fried"></i> Popcorn / Snacks</h5>
                    <div class="row g-3 mb-4">
                        <c:forEach var="item" items="${foodItems}">
                            <c:if test="${item.category == 'SNACK'}">
                                <c:set var="qty" value="0"/>
                                <c:if test="${not empty existingFood}">
                                    <c:forEach var="entry" items="${existingFood}">
                                        <c:if test="${entry.key.foodId == item.foodId}">
                                            <c:set var="qty" value="${entry.value}"/>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                <c:set var="iconClass" value="bi-cookie"/>
                                <c:set var="colorClass" value="snack-yellow"/>
                                <c:choose>
                                    <c:when test="${item.name == 'Popcorn (Large)'}">
                                        <c:set var="iconClass" value="bi-cookie"/>
                                        <c:set var="colorClass" value="snack-orange"/>
                                    </c:when>
                                    <c:when test="${item.name == 'Popcorn (Medium)'}">
                                        <c:set var="iconClass" value="bi-cookie"/>
                                        <c:set var="colorClass" value="snack-yellow"/>
                                    </c:when>
                                </c:choose>
                                <div class="col-lg-4 col-sm-6">
                                    <div class="food-card ${qty > 0 ? 'added' : ''}" id="food_card_${item.foodId}">
                                        <div id="added_badge_${item.foodId}" class="added-badge ${qty > 0 ? '' : 'd-none'}">
                                            <span class="badge bg-primary text-white border border-light food-added-badge">
                                                <i class="bi bi-check-circle-fill me-1"></i> Added
                                            </span>
                                        </div>
                                        <div class="food-img-wrapper themed ${colorClass}">
                                            <div class="glow-circle"></div>
                                            <i class="bi ${iconClass}"></i>
                                        </div>
                                        <div class="food-info">
                                            <div>
                                                <div class="food-name">${item.name}</div>
                                                <div class="text-muted small mt-1">${item.description}</div>
                                            </div>
                                            <div class="d-flex justify-content-between align-items-center mt-3">
                                                <div class="food-price">
                                                    <fmt:formatNumber value="${item.price}" pattern="#,###"/> VND
                                                </div>
                                                <div>
                                                    <input type="hidden" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}">
                                                    <button type="button" id="add_btn_${item.foodId}" class="btn btn-outline-primary btn-sm px-3 fw-bold food-add-btn ${qty > 0 ? 'd-none' : ''}" onclick="updateQty(${item.foodId}, 1)">
                                                        + Add
                                                    </button>
                                                    <div id="stepper_${item.foodId}" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 food-stepper ${qty > 0 ? '' : 'd-none'}">
                                                        <button type="button" class="btn btn-sm text-white p-0 fw-bold food-stepper-btn" onclick="updateQty(${item.foodId}, -1)">-</button>
                                                        <strong id="stepper_qty_${item.foodId}">${qty}</strong>
                                                        <button type="button" class="btn btn-sm text-white p-0 fw-bold food-stepper-btn" onclick="updateQty(${item.foodId}, 1)">+</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

                <%-- Category: DRINK --%>
                <div class="fnb-section" data-section="DRINK">
                    <h5 class="fnb-section-title"><i class="bi bi-cup-straw"></i> Drinks</h5>
                    <div class="row g-3 mb-4">
                        <c:forEach var="item" items="${foodItems}">
                            <c:if test="${item.category == 'DRINK'}">
                                <c:set var="qty" value="0"/>
                                <c:if test="${not empty existingFood}">
                                    <c:forEach var="entry" items="${existingFood}">
                                        <c:if test="${entry.key.foodId == item.foodId}">
                                            <c:set var="qty" value="${entry.value}"/>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                                <c:set var="iconClass" value="bi-cup-straw"/>
                                <c:set var="colorClass" value="drink-blue"/>
                                <c:choose>
                                    <c:when test="${item.name == 'Coca-Cola'}">
                                        <c:set var="iconClass" value="bi-cup-straw"/>
                                        <c:set var="colorClass" value="drink-red"/>
                                    </c:when>
                                    <c:when test="${item.name == 'Mineral Water'}">
                                        <c:set var="iconClass" value="bi-droplet-fill"/>
                                        <c:set var="colorClass" value="drink-cyan"/>
                                    </c:when>
                                </c:choose>
                                <div class="col-lg-4 col-sm-6">
                                    <div class="food-card ${qty > 0 ? 'added' : ''}" id="food_card_${item.foodId}">
                                        <div id="added_badge_${item.foodId}" class="added-badge ${qty > 0 ? '' : 'd-none'}">
                                            <span class="badge bg-primary text-white border border-light food-added-badge">
                                                <i class="bi bi-check-circle-fill me-1"></i> Added
                                            </span>
                                        </div>
                                        <div class="food-img-wrapper themed ${colorClass}">
                                            <div class="glow-circle"></div>
                                            <i class="bi ${iconClass}"></i>
                                        </div>
                                        <div class="food-info">
                                            <div>
                                                <div class="food-name">${item.name}</div>
                                                <div class="text-muted small mt-1">${item.description}</div>
                                            </div>
                                            <div class="d-flex justify-content-between align-items-center mt-3">
                                                <div class="food-price">
                                                    <fmt:formatNumber value="${item.price}" pattern="#,###"/> VND
                                                </div>
                                                <div>
                                                    <input type="hidden" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}">
                                                    <button type="button" id="add_btn_${item.foodId}" class="btn btn-outline-primary btn-sm px-3 fw-bold food-add-btn ${qty > 0 ? 'd-none' : ''}" onclick="updateQty(${item.foodId}, 1)">
                                                        + Add
                                                    </button>
                                                    <div id="stepper_${item.foodId}" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 food-stepper ${qty > 0 ? '' : 'd-none'}">
                                                        <button type="button" class="btn btn-sm text-white p-0 fw-bold food-stepper-btn" onclick="updateQty(${item.foodId}, -1)">-</button>
                                                        <strong id="stepper_qty_${item.foodId}">${qty}</strong>
                                                        <button type="button" class="btn btn-sm text-white p-0 fw-bold food-stepper-btn" onclick="updateQty(${item.foodId}, 1)">+</button>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:if>
                        </c:forEach>
                    </div>
                </div>

            </div>

            <%-- ====== Right: Summary panel (mirrors sel-panel from seats) ====== --%>
            <div class="col-lg-4">
                <div class="fnb-summary">
                    <div class="fnb-summary-body">
                        <h5 class="fnb-summary-title"><i class="bi bi-bag me-2"></i>Concessions Order</h5>

                        <div id="selectedFoodList" class="fnb-summary-list">
                            <div class="fnb-summary-empty">
                                <i class="bi bi-basket3"></i>
                                <div>No concessions added yet.<br>Browse the catalog to add items.</div>
                            </div>
                        </div>

                        <hr class="fnb-summary-divider">

                        <div class="fnb-summary-total">
                            <span>Subtotal</span>
                            <span class="fnb-summary-total-amount" id="foodSubtotal">0 VND</span>
                        </div>

                        <button type="submit" class="fnb-summary-cta">
                            <span><c:choose><c:when test="${not empty bookingId}">Confirm Concessions</c:when><c:otherwise>Continue to Review</c:otherwise></c:choose></span>
                            <i class="bi bi-arrow-right"></i>
                        </button>

                        <c:if test="${empty bookingId}">
                            <button type="button" class="fnb-summary-skip" onclick="document.getElementById('foodForm').submit();">
                                Skip – I don't want concessions
                            </button>
                        </c:if>
                    </div>

                    <div class="fnb-info">
                        <i class="bi bi-info-circle-fill"></i>
                        <span>Concessions are optional. You can also purchase them at the cinema counter.</span>
                    </div>
                </div>
            </div>
        </div>
    </form>
</div>

<jsp:include page="../common/footer.jsp" />

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Prepare catalog data for dynamic calculation
    const foodCatalog = {
        <c:forEach var="item" items="${foodItems}" varStatus="loop">
            "${item.foodId}": {
                name: "${item.name}",
                price: ${item.price},
                category: "${item.category}"
            }${not loop.last ? ',' : ''}
        </c:forEach>
    };

    const selections = {};

    /* ── Category filter (like showtime date-tabs) ── */
    function filterCategory(cat) {
        // Update tab buttons
        document.querySelectorAll('.fnb-cat-btn').forEach(btn => {
            btn.classList.toggle('active', btn.dataset.cat === cat);
        });

        // Show/hide sections with animation
        document.querySelectorAll('.fnb-section').forEach(sec => {
            if (cat === 'all') {
                sec.classList.remove('is-hidden');
            } else {
                sec.classList.toggle('is-hidden', sec.dataset.section !== cat);
            }
        });
    }

    /* ── Quantity update (same logic as before) ── */
    function updateQty(foodId, change) {
        const input = document.getElementById("food_qty_input_" + foodId);
        let qty = parseInt(input.value) + change;
        if (qty < 0) qty = 0;
        if (qty > 10) qty = 10; // Cap at 10 (as per business specs)
        input.value = qty;

        const card = document.getElementById("food_card_" + foodId);
        const badge = document.getElementById("added_badge_" + foodId);
        const addBtn = document.getElementById("add_btn_" + foodId);
        const stepper = document.getElementById("stepper_" + foodId);
        const qtyText = document.getElementById("stepper_qty_" + foodId);

        if (qty > 0) {
            selections[foodId] = qty;
            if (card) card.classList.add("added");
            if (badge) badge.classList.remove("d-none");
            if (addBtn) addBtn.classList.add("d-none");
            if (stepper) stepper.classList.remove("d-none");
            if (qtyText) qtyText.textContent = qty;
        } else {
            delete selections[foodId];
            if (card) card.classList.remove("added");
            if (badge) badge.classList.add("d-none");
            if (addBtn) addBtn.classList.remove("d-none");
            if (stepper) stepper.classList.add("d-none");
        }

        recalculateSummary();
    }

    /* ── Recalculate summary (enhanced layout) ── */
    function recalculateSummary() {
        const listDiv = document.getElementById("selectedFoodList");
        const subtotalSpan = document.getElementById("foodSubtotal");

        listDiv.innerHTML = "";
        let subtotal = 0;

        const keys = Object.keys(selections);
        if (keys.length === 0) {
            listDiv.innerHTML = '<div class="fnb-summary-empty">'
                + '<i class="bi bi-basket3"></i>'
                + '<div>No concessions added yet.<br>Browse the catalog to add items.</div>'
                + '</div>';
        } else {
            keys.forEach(id => {
                const item = foodCatalog[id];
                const qty = selections[id];
                const itemCost = item.price * qty;
                subtotal += itemCost;

                const row = document.createElement("div");
                row.className = "fnb-summary-item";
                row.innerHTML = '<span class="fnb-summary-item-name">'
                    + item.name + ' <span class="fnb-summary-item-qty">x' + qty + '</span>'
                    + '</span>'
                    + '<span class="fnb-summary-item-price">' + formatCurrency(itemCost) + ' VND</span>';
                listDiv.appendChild(row);
            });
        }

        subtotalSpan.textContent = formatCurrency(subtotal) + " VND";
    }

    function formatCurrency(value) {
        return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    // Initialize UI on load
    document.addEventListener("DOMContentLoaded", () => {
        // Initialize selections from inputs
        document.querySelectorAll("input[name^='food_qty_']").forEach(input => {
            const id = input.name.replace("food_qty_", "");
            const qty = parseInt(input.value);
            if (qty > 0) {
                selections[id] = qty;
            }
        });
        recalculateSummary();
    });
</script>
</body>
</html>
