<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Select Food & Drinks – MBCMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        :root {
            --bk-primary: #2563EB;
            --bk-navy: #0F1E36;
            --bk-border: #E6EAF2;
            --bk-muted: #64748B;
            --bk-light: #EFF4FF;
            --bk-bg: #F5F7FA;
        }
        body.bk-page { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }
        .bk-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px;
            box-shadow:0 4px 12px rgba(15,23,42,.05); }
        .bk-summary { position:sticky; top:18px; }
        
        .bk-ctx { background:#fff; border-bottom:1px solid var(--bk-border); }
        
        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:#94a3b8; white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:#E2E8F0; color:#64748b; flex-shrink:0; }
        .bk-step.done { color:#16a34a; } .bk-step.done .bk-dot { background:#16a34a; color:#fff; }
        .bk-step.active { color:var(--bk-primary); } .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:#E2E8F0; margin:0 .5rem; min-width:12px; }
        .bk-line.done { background:#16a34a; }
        @media (max-width:640px) { .bk-step span:not(.bk-dot) { display:none; } }

        .food-card {
            display: flex;
            border: 1px solid var(--bk-border);
            border-radius: 12px;
            overflow: hidden;
            transition: all 0.2s ease;
            background: #fff;
            height: 120px;
        }
        .food-card:hover {
            border-color: #bfdbfe;
            box-shadow: 0 4px 15px rgba(37,99,235,0.06);
            transform: translateY(-2px);
        }
        .food-img-wrapper {
            width: 120px;
            background: #f1f5f9;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 2.2rem;
            color: var(--bk-muted);
            flex-shrink: 0;
        }
        .food-info {
            padding: 1rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            flex-grow: 1;
        }
        .qty-btn {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            border: 1px solid var(--bk-border);
            background: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.15s ease;
            font-weight: bold;
        }
        .qty-btn:hover {
            background: var(--bk-light);
            border-color: #bfdbfe;
            color: var(--bk-primary);
        }
        .qty-input {
            width: 40px;
            text-align: center;
            border: none;
            font-weight: 600;
            background: transparent;
        }
        .category-tab {
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--bk-navy);
            border-bottom: 2px solid var(--bk-border);
            padding-bottom: 0.5rem;
            margin-bottom: 1.2rem;
        }
        .bk-sum-line { display:flex; justify-content:space-between; align-items:center; padding:.35rem 0; font-size:.92rem; }
        .bk-sum-total { padding-top:.6rem; margin-top:.2rem; border-top:1px solid var(--bk-border); }
    </style>
</head>
<body class="bk-page">
<jsp:include page="../common/header.jsp" />

<%-- ===== Context bar ===== --%>
<div class="bk-ctx mt-3">
    <div class="container bk-wrap py-2">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <a href="<c:choose><c:when test='${not empty bookingId}'>${pageContext.request.contextPath}/customer/booking/detail?bookingId=${bookingId}</c:when><c:otherwise>${pageContext.request.contextPath}/booking/seats?showtimeId=${showtimeId}&seatIds=${seatIds}</c:otherwise></c:choose>" class="btn btn-sm btn-outline-secondary">
                <i class="bi bi-arrow-left"></i> Back
            </a>
            <div class="flex-grow-1">
                <div class="fw-bold" style="color:var(--bk-navy);">Select Food & Drinks</div>
                <div class="text-muted small">Add concessions to enjoy during your movie!</div>
            </div>
        </div>
    </div>
</div>

<div class="container bk-wrap py-4">

    <c:choose>
        <c:when test="${not empty bookingId}">
            <div class="mb-4">
                <span class="badge bg-primary-subtle text-primary fw-bold mb-2">Post-Purchase Concessions</span>
                <h3 class="fw-bold mb-1" style="color:var(--bk-navy);">Add concessions to Booking</h3>
                <p class="text-muted">Choose your snacks and drinks. You can pay for them at the counter when you arrive.</p>
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

            <h3 class="fw-bold mb-1" style="color:var(--bk-navy);">Snacks & Drinks Catalog</h3>
            <p class="text-muted mb-4">Select items to add to your order. You can skip if you don't want any.</p>
        </c:otherwise>
    </c:choose>

    <form id="foodForm" action="${pageContext.request.contextPath}/booking/food-drinks" method="POST">
        <input type="hidden" name="showtimeId" value="${showtimeId}">
        <input type="hidden" name="seatIds" value="${seatIds}">
        <c:if test="${not empty bookingId}">
            <input type="hidden" name="bookingId" value="${bookingId}">
        </c:if>

        <div class="row g-4">
            <%-- Left side: Catalog items --%>
            <div class="col-lg-8">
                
                <%-- Category: COMBO --%>
                <div class="category-tab mt-2">✨ Combo & Deals</div>
                <div class="row g-3 mb-4">
                    <c:forEach var="item" items="${foodItems}">
                        <c:if test="${item.category == 'COMBO'}">
                            <div class="col-md-6">
                                <div class="food-card">
                                    <div class="food-img-wrapper">
                                        <i class="bi bi-box2-heart"></i>
                                    </div>
                                    <div class="food-info">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:0.95rem;">${item.name}</div>
                                            <div class="text-muted small">${item.description}</div>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div class="fw-bold text-primary" style="font-size:1.05rem;">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <c:set var="qty" value="0"/>
                                            <c:if test="${not empty existingFood}">
                                                <c:forEach var="entry" items="${existingFood}">
                                                    <c:if test="${entry.key.foodId == item.foodId}">
                                                        <c:set var="qty" value="${entry.value}"/>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                            <div class="d-flex align-items-center">
                                                <button type="button" class="qty-btn minus-btn" onclick="updateQty(${item.foodId}, -1)">-</button>
                                                <input type="text" class="qty-input" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}" readonly>
                                                <button type="button" class="qty-btn plus-btn" onclick="updateQty(${item.foodId}, 1)">+</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <%-- Category: SNACK --%>
                <div class="category-tab">🍿 Popcorn / Snacks</div>
                <div class="row g-3 mb-4">
                    <c:forEach var="item" items="${foodItems}">
                        <c:if test="${item.category == 'SNACK'}">
                            <div class="col-md-6">
                                <div class="food-card">
                                    <div class="food-img-wrapper">
                                        <i class="bi bi-egg-fried"></i>
                                    </div>
                                    <div class="food-info">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:0.95rem;">${item.name}</div>
                                            <div class="text-muted small">${item.description}</div>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div class="fw-bold text-primary" style="font-size:1.05rem;">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <c:set var="qty" value="0"/>
                                            <c:if test="${not empty existingFood}">
                                                <c:forEach var="entry" items="${existingFood}">
                                                    <c:if test="${entry.key.foodId == item.foodId}">
                                                        <c:set var="qty" value="${entry.value}"/>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                            <div class="d-flex align-items-center">
                                                <button type="button" class="qty-btn minus-btn" onclick="updateQty(${item.foodId}, -1)">-</button>
                                                <input type="text" class="qty-input" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}" readonly>
                                                <button type="button" class="qty-btn plus-btn" onclick="updateQty(${item.foodId}, 1)">+</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <%-- Category: DRINK --%>
                <div class="category-tab">🥤 Drinks</div>
                <div class="row g-3 mb-4">
                    <c:forEach var="item" items="${foodItems}">
                        <c:if test="${item.category == 'DRINK'}">
                            <div class="col-md-6">
                                <div class="food-card">
                                    <div class="food-img-wrapper">
                                        <i class="bi bi-cup-straw"></i>
                                    </div>
                                    <div class="food-info">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:0.95rem;">${item.name}</div>
                                            <div class="text-muted small">${item.description}</div>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center">
                                            <div class="fw-bold text-primary" style="font-size:1.05rem;">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <c:set var="qty" value="0"/>
                                            <c:if test="${not empty existingFood}">
                                                <c:forEach var="entry" items="${existingFood}">
                                                    <c:if test="${entry.key.foodId == item.foodId}">
                                                        <c:set var="qty" value="${entry.value}"/>
                                                    </c:if>
                                                </c:forEach>
                                            </c:if>
                                            <div class="d-flex align-items-center">
                                                <button type="button" class="qty-btn minus-btn" onclick="updateQty(${item.foodId}, -1)">-</button>
                                                <input type="text" class="qty-input" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}" readonly>
                                                <button type="button" class="qty-btn plus-btn" onclick="updateQty(${item.foodId}, 1)">+</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

            </div>

            <%-- Right side: Summary --%>
            <div class="col-lg-4">
                <div class="bk-card p-4 bk-summary">
                    <h5 class="fw-bold mb-3" style="color:var(--bk-navy);">Concessions Order</h5>
                    
                    <div class="py-2 border-bottom border-light">
                        <div class="text-muted small">Selected Concessions</div>
                        <div id="selectedFoodList" class="mt-2 text-dark small" style="min-height: 40px;">
                            <span class="text-muted italic">No concessions added yet.</span>
                        </div>
                    </div>

                    <div class="mt-3">
                        <div class="bk-sum-line">
                            <span class="text-muted">Concessions Subtotal</span>
                            <span class="fw-bold" id="foodSubtotal">0đ</span>
                        </div>
                    </div>

                    <div class="mt-4">
                        <button type="submit" class="btn btn-primary w-100 py-2.5 fw-semibold d-flex justify-content-center align-items-center gap-2">
                            <span><c:choose><c:when test="${not empty bookingId}">Confirm Concessions</c:when><c:otherwise>Proceed to Checkout</c:otherwise></c:choose></span>
                            <i class="bi bi-arrow-right"></i>
                        </button>
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
                price: ${item.price}
            }${not loop.last ? ',' : ''}
        </c:forEach>
    };

    const selections = {};

    function updateQty(foodId, change) {
        const input = document.getElementById("food_qty_input_" + foodId);
        let qty = parseInt(input.value) + change;
        if (qty < 0) qty = 0;
        if (qty > 10) qty = 10; // Cap at 10 (as per business specs)
        input.value = qty;

        if (qty > 0) {
            selections[foodId] = qty;
        } else {
            delete selections[foodId];
        }

        recalculateSummary();
    }

    function recalculateSummary() {
        const listDiv = document.getElementById("selectedFoodList");
        const subtotalSpan = document.getElementById("foodSubtotal");
        
        listDiv.innerHTML = "";
        let subtotal = 0;

        const keys = Object.keys(selections);
        if (keys.length === 0) {
            listDiv.innerHTML = '<span class="text-muted italic">No concessions added yet.</span>';
        } else {
            keys.forEach(id => {
                const item = foodCatalog[id];
                const qty = selections[id];
                const itemCost = item.price * qty;
                subtotal += itemCost;

                const row = document.createElement("div");
                row.className = "d-flex justify-content-between align-items-center mb-2";
                row.innerHTML = '<span>' + item.name + ' <strong class="text-primary">x' + qty + '</strong></span>' +
                                '<span>' + formatCurrency(itemCost) + 'đ</span>';
                listDiv.appendChild(row);
            });
        }

        subtotalSpan.textContent = formatCurrency(subtotal) + "đ";
    }

    function formatCurrency(value) {
        return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

    // Initialize UI on load
    document.addEventListener("DOMContentLoaded", () => {
        // Initialize selections from inputs
        document.querySelectorAll(".qty-input").forEach(input => {
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
