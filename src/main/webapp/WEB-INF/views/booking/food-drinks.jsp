<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Select Food & Drinks – PentaPlex</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css?v=${applicationScope.assetVersion}" rel="stylesheet">
    <style>
        /* --bk-* tokens come from tokens.css */
        body.bk-page { background: var(--bk-bg); }
        .bk-wrap { max-width: 1080px; }
        .bk-card { background:#fff; border:1px solid var(--bk-border); border-radius:14px;
            box-shadow:0 4px 12px rgba(15,23,42,.05); }
        .bk-summary { position:sticky; top:18px; }
        
        .bk-ctx { background:#fff; border-bottom:1px solid var(--bk-border); }
        
        .bk-steps { display:flex; align-items:center; }
        .bk-step { display:flex; align-items:center; gap:.5rem; font-size:.9rem; font-weight:600; color:var(--text-subtle); white-space:nowrap; }
        .bk-step .bk-dot { width:26px; height:26px; border-radius:999px; display:flex; align-items:center;
            justify-content:center; font-size:.78rem; background:var(--border); color:var(--text-muted); flex-shrink:0; }
        .bk-step.done { color:var(--success); } .bk-step.done .bk-dot { background:var(--success); color:#fff; }
        .bk-step.active { color:var(--bk-primary); } .bk-step.active .bk-dot { background:var(--bk-primary); color:#fff; }
        .bk-line { flex:1; height:2px; background:var(--border); margin:0 .5rem; min-width:12px; }
        .bk-line.done { background:var(--success); }
        @media (max-width:640px) { .bk-step span:not(.bk-dot) { display:none; } }

        .food-card {
            display: flex;
            flex-direction: column;
            border: 1px solid var(--bk-border);
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            background: #fff;
            position: relative;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.02), 0 2px 4px -1px rgba(0, 0, 0, 0.01);
            height: 100%;
        }
        .food-card:hover {
            border-color: rgba(37, 99, 235, 0.2);
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.05), 0 10px 10px -5px rgba(0, 0, 0, 0.02);
            transform: translateY(-6px);
        }
        .food-card.added {
            border-color: var(--bk-primary);
            border-width: 1.5px;
            box-shadow: 0 10px 25px -5px rgba(37, 99, 235, 0.15), 0 8px 10px -6px rgba(37, 99, 235, 0.1);
        }
        .drink-red { --item-theme: #dc2626; --item-bg: rgba(220, 38, 38, 0.08); --item-gradient: linear-gradient(135deg, rgba(220, 38, 38, 0.1) 0%, rgba(220, 38, 38, 0.01) 100%); }
        .drink-cyan { --item-theme: #0284c7; --item-bg: rgba(2, 132, 199, 0.08); --item-gradient: linear-gradient(135deg, rgba(2, 132, 199, 0.1) 0%, rgba(2, 132, 199, 0.01) 100%); }
        .snack-orange { --item-theme: #ea580c; --item-bg: rgba(234, 88, 12, 0.08); --item-gradient: linear-gradient(135deg, rgba(234, 88, 12, 0.1) 0%, rgba(234, 88, 12, 0.01) 100%); }
        .snack-yellow { --item-theme: #ca8a04; --item-bg: rgba(202, 138, 4, 0.08); --item-gradient: linear-gradient(135deg, rgba(202, 138, 4, 0.1) 0%, rgba(202, 138, 4, 0.01) 100%); }
        .combo-green { --item-theme: #059669; --item-bg: rgba(5, 150, 105, 0.08); --item-gradient: linear-gradient(135deg, rgba(5, 150, 105, 0.1) 0%, rgba(5, 150, 105, 0.01) 100%); }
        .combo-red { --item-theme: #db2777; --item-bg: rgba(219, 39, 119, 0.08); --item-gradient: linear-gradient(135deg, rgba(219, 39, 119, 0.1) 0%, rgba(219, 39, 119, 0.01) 100%); }

        .food-img-wrapper.themed {
            background: var(--item-gradient, radial-gradient(circle at 50% 50%, #ffffff 0%, var(--bg) 100%));
            color: var(--item-theme);
            height: 150px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-bottom: 1px solid #f1f5f9;
            position: relative;
            overflow: hidden;
        }
        .food-card .glow-circle {
            position: absolute;
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: var(--item-bg);
            z-index: 1;
            filter: blur(16px);
            transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
        }
        .food-card:hover .glow-circle {
            transform: scale(1.3) rotate(15deg);
            filter: blur(12px);
            opacity: 0.85;
        }
        .food-img-wrapper.themed i {
            font-size: 2.8rem;
            z-index: 2;
            color: var(--item-theme);
            filter: drop-shadow(0 4px 6px rgba(0,0,0,0.03));
            transition: all 0.35s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .food-card:hover .themed i {
            transform: scale(1.18) translateY(-4px) rotate(4deg);
            filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.08));
        }
        .food-info {
            padding: 1.2rem;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            flex-grow: 1;
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
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
        <input type="hidden" name="showtimeId" value="${showtimeId}">
        <input type="hidden" name="seatIds" value="${seatIds}">
        <c:if test="${not empty bookingId}">
            <input type="hidden" name="bookingId" value="${bookingId}">
        </c:if>

        <div class="row g-4">
            <%-- Left side: Catalog items --%>
            <div class="col-lg-8">
                
                <%-- Category: COMBO --%>
                <div class="category-tab mt-2"><i class="bi bi-gift text-primary me-2"></i>Combos & Deals</div>
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
                            <div class="col-lg-4 col-sm-6 mb-3">
                                <div class="food-card ${qty > 0 ? 'added' : ''}" id="food_card_${item.foodId}">
                                    <div id="added_badge_${item.foodId}" class="added-badge position-absolute ${qty > 0 ? '' : 'd-none'}" style="top: 12px; left: 12px; z-index: 10;">
                                        <span class="badge bg-primary text-white border border-light" style="padding: 6px 12px; border-radius: 20px; font-size: 0.72rem; font-weight: 700;">
                                            <i class="bi bi-check-circle-fill me-1"></i> Added
                                        </span>
                                    </div>
                                    <div class="food-img-wrapper themed ${colorClass}">
                                        <div class="glow-circle"></div>
                                        <i class="bi ${iconClass}"></i>
                                    </div>
                                    <div class="food-info p-3 d-flex flex-column justify-content-between" style="min-height: 140px;">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:0.95rem;">${item.name}</div>
                                            <div class="text-muted small mt-1">${item.description}</div>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-3">
                                            <div class="fw-bold text-primary" style="font-size:1.05rem;">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <div>
                                                <input type="hidden" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}">
                                                <button type="button" id="add_btn_${item.foodId}" class="btn btn-outline-primary btn-sm px-3 fw-bold ${qty > 0 ? 'd-none' : ''}" onclick="updateQty(${item.foodId}, 1)" style="border-radius: 20px;">
                                                    + Add
                                                </button>
                                                <div id="stepper_${item.foodId}" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 ${qty > 0 ? '' : 'd-none'}" style="border-radius: 20px; width: 90px; font-size: 0.85rem;">
                                                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateQty(${item.foodId}, -1)" style="line-height:1; border:none; background:transparent;">-</button>
                                                    <strong id="stepper_qty_${item.foodId}">${qty}</strong>
                                                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateQty(${item.foodId}, 1)" style="line-height:1; border:none; background:transparent;">+</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <%-- Category: SNACK --%>
                <div class="category-tab"><i class="bi bi-egg-fried text-primary me-2"></i>Popcorn / Snacks</div>
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
                            <div class="col-lg-4 col-sm-6 mb-3">
                                <div class="food-card ${qty > 0 ? 'added' : ''}" id="food_card_${item.foodId}">
                                    <div id="added_badge_${item.foodId}" class="added-badge position-absolute ${qty > 0 ? '' : 'd-none'}" style="top: 12px; left: 12px; z-index: 10;">
                                        <span class="badge bg-primary text-white border border-light" style="padding: 6px 12px; border-radius: 20px; font-size: 0.72rem; font-weight: 700;">
                                            <i class="bi bi-check-circle-fill me-1"></i> Added
                                        </span>
                                    </div>
                                    <div class="food-img-wrapper themed ${colorClass}">
                                        <div class="glow-circle"></div>
                                        <i class="bi ${iconClass}"></i>
                                    </div>
                                    <div class="food-info p-3 d-flex flex-column justify-content-between" style="min-height: 140px;">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:0.95rem;">${item.name}</div>
                                            <div class="text-muted small mt-1">${item.description}</div>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-3">
                                            <div class="fw-bold text-primary" style="font-size:1.05rem;">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <div>
                                                <input type="hidden" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}">
                                                <button type="button" id="add_btn_${item.foodId}" class="btn btn-outline-primary btn-sm px-3 fw-bold ${qty > 0 ? 'd-none' : ''}" onclick="updateQty(${item.foodId}, 1)" style="border-radius: 20px;">
                                                    + Add
                                                </button>
                                                <div id="stepper_${item.foodId}" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 ${qty > 0 ? '' : 'd-none'}" style="border-radius: 20px; width: 90px; font-size: 0.85rem;">
                                                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateQty(${item.foodId}, -1)" style="line-height:1; border:none; background:transparent;">-</button>
                                                    <strong id="stepper_qty_${item.foodId}">${qty}</strong>
                                                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateQty(${item.foodId}, 1)" style="line-height:1; border:none; background:transparent;">+</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:if>
                    </c:forEach>
                </div>

                <%-- Category: DRINK --%>
                <div class="category-tab"><i class="bi bi-cup-straw text-primary me-2"></i>Drinks</div>
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
                            <div class="col-lg-4 col-sm-6 mb-3">
                                <div class="food-card ${qty > 0 ? 'added' : ''}" id="food_card_${item.foodId}">
                                    <div id="added_badge_${item.foodId}" class="added-badge position-absolute ${qty > 0 ? '' : 'd-none'}" style="top: 12px; left: 12px; z-index: 10;">
                                        <span class="badge bg-primary text-white border border-light" style="padding: 6px 12px; border-radius: 20px; font-size: 0.72rem; font-weight: 700;">
                                            <i class="bi bi-check-circle-fill me-1"></i> Added
                                        </span>
                                    </div>
                                    <div class="food-img-wrapper themed ${colorClass}">
                                        <div class="glow-circle"></div>
                                        <i class="bi ${iconClass}"></i>
                                    </div>
                                    <div class="food-info p-3 d-flex flex-column justify-content-between" style="min-height: 140px;">
                                        <div>
                                            <div class="fw-bold text-dark" style="font-size:0.95rem;">${item.name}</div>
                                            <div class="text-muted small mt-1">${item.description}</div>
                                        </div>
                                        <div class="d-flex justify-content-between align-items-center mt-3">
                                            <div class="fw-bold text-primary" style="font-size:1.05rem;">
                                                <fmt:formatNumber value="${item.price}" pattern="#,###"/>đ
                                            </div>
                                            <div>
                                                <input type="hidden" id="food_qty_input_${item.foodId}" name="food_qty_${item.foodId}" value="${qty}">
                                                <button type="button" id="add_btn_${item.foodId}" class="btn btn-outline-primary btn-sm px-3 fw-bold ${qty > 0 ? 'd-none' : ''}" onclick="updateQty(${item.foodId}, 1)" style="border-radius: 20px;">
                                                    + Add
                                                </button>
                                                <div id="stepper_${item.foodId}" class="d-flex align-items-center justify-content-between bg-primary text-white px-2 py-1 ${qty > 0 ? '' : 'd-none'}" style="border-radius: 20px; width: 90px; font-size: 0.85rem;">
                                                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateQty(${item.foodId}, -1)" style="line-height:1; border:none; background:transparent;">-</button>
                                                    <strong id="stepper_qty_${item.foodId}">${qty}</strong>
                                                    <button type="button" class="btn btn-sm text-white p-0 fw-bold" onclick="updateQty(${item.foodId}, 1)" style="line-height:1; border:none; background:transparent;">+</button>
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
