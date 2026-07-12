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
        <title>${isEdit ? 'Edit Promotion' : 'Add New Promotion'} - PentaPlex Manager</title>
        <%@ include file="/WEB-INF/views/branch/_branch-assets.jspf" %>
        <style>
            .lc-picker-icon.pct { background-color: var(--primary-100, #E7F0FF); color: var(--primary, #2563eb); }
            .lc-picker-icon.fix { background-color: #fef3c7; color: #d97706; }
            .ticket-card {
                background: linear-gradient(135deg, #1e40af 0%, #1e3a8a 100%);
                color: white;
                border-radius: 16px;
                padding: 1.5rem;
                position: relative;
                overflow: hidden;
                box-shadow: 0 10px 25px rgba(30, 58, 138, 0.2);
            }
            .ticket-card::before, .ticket-card::after {
                content: '';
                position: absolute;
                width: 20px;
                height: 20px;
                background-color: var(--lc-bg);
                border-radius: 50%;
                top: 50%;
                transform: translateY(-50%);
                z-index: 2;
            }
            .ticket-card::before {
                left: -10px;
            }
            .ticket-card::after {
                right: -10px;
            }

            .ticket-dash {
                border-left: 2px dashed rgba(255, 255, 255, 0.25);
                height: 100%;
                position: absolute;
                left: 70%;
                top: 0;
            }

            .card-glow {
                position: absolute;
                width: 150px;
                height: 150px;
                border-radius: 50%;
                background: radial-gradient(circle, rgba(59, 130, 246, 0.3) 0%, transparent 70%);
                top: -50px;
                right: -50px;
                pointer-events: none;
            }
            .form-switch .form-check-input {
                width: 2.8em;
                height: 1.5em;
                cursor: pointer;
            }
                    .ticket-card,
            .ticket-card .small,
            .ticket-card small,
            .ticket-card h3,
            .ticket-card h4,
            .ticket-card div,
            .ticket-card span,
            .ticket-card h3.text-white,
            .ticket-card h4.text-white {
                color: #ffffff !important;
                opacity: 1 !important;
            }
            .ticket-card .text-white-50 {
                color: rgba(255, 255, 255, 0.75) !important;
            }
        </style>
    </head>
    <body class="lc-console">

        <jsp:include page="/WEB-INF/views/branch/_sidebar.jsp">
            <jsp:param name="active" value="promotions" />
        </jsp:include>

        <main class="lc-admin-main">
            <div class="lc-page">

                <div class="lc-form-actions">
                    <div>
                        <div class="lc-page-crumb">
                            <a href="${pageContext.request.contextPath}/branch/promotions" class="text-decoration-none text-muted">Promotions</a>
                            / <strong>${isEdit ? 'Edit' : 'Add new'}</strong>
                        </div>
                        <h1 class="lc-page-title mb-0">${isEdit ? 'Edit Promotion' : 'Add New Promotion'}</h1>
                    </div>
                    <div class="lc-form-actions-end">
                        <a class="lc-btn-ghost" href="${pageContext.request.contextPath}/branch/promotions">Cancel</a>
                        <button type="submit" form="promoForm" class="st-toolbar-add border-0">
                            <i class="bi bi-check-lg" aria-hidden="true"></i>${isEdit ? 'Save Changes' : 'Create Promotion'}
                        </button>
                    </div>
                </div>

                <%-- ===== Scope Notice ===== --%>
                <div class="lc-scope mb-4">
                    <i class="bi bi-info-circle-fill" style="color:#cf9a00;"></i>
                    <span>Promotions created here are <strong>branch-specific</strong> and can only be used by this cinema branch.</span>
                </div>

                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger py-2 alert-dismissible fade show" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-1"></i> ${errorMsg}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close" style="padding: 0.75rem 1rem;"></button>
                    </div>
                </c:if>

                <div class="row g-4">
                    <%-- Left column: Form input fields --%>
                    <div class="col-lg-7">
                        <form id="promoForm" action="${pageContext.request.contextPath}/branch/promotions/${isEdit ? 'edit' : 'create'}" method="post">
            <%@ include file="/WEB-INF/views/common/csrf-hidden.jspf" %>
                            <c:if test="${isEdit}">
                                <input type="hidden" name="promoId" value="${promo.promoId}">
                            </c:if>

                            <%-- Section: Basic Information --%>
                            <div class="card lc-elev p-4 mb-4 lc-rise" style="--i:0;">
                                <h5 class="text-navy fw-bold mb-3">Basic Information</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-navy small">Promotion Code *</label>
                                        <div class="input-group input-group-sm">
                                            <span class="input-group-text bg-light"><i class="bi bi-scissors"></i></span>
                                            <input type="text" class="form-control" name="code" id="inputCode"
                                                   maxlength="20" placeholder="e.g. SUMMER20" required
                                                   value="${fn:escapeXml(promo.code)}"
                                                   oninput="this.value = this.value.toUpperCase().replace(/[^A-Z0-9]/g, '')">
                                        </div>
                                        <div class="text-muted small mt-1" style="font-size: 0.75rem;">Alphanumeric and uppercase only. Max 20 chars.</div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-navy small">Promotion Name *</label>
                                        <input type="text" class="form-control form-control-sm" name="name" id="inputName"
                                               maxlength="150" placeholder="e.g. Summer 2026 Sale" required
                                               value="${fn:escapeXml(promo.name)}">
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label fw-semibold text-navy small">Description (Internal Notes)</label>
                                        <textarea class="form-control form-control-sm" name="description" id="inputDesc" rows="2"
                                                  placeholder="Internal notes: who this is for, marketing channel, etc."></textarea>
                                    </div>
                                </div>
                            </div>

                            <%-- Section: Discount --%>
                            <div class="card lc-elev p-4 mb-4 lc-rise" style="--i:1;">
                                <h5 class="text-navy fw-bold mb-3">Discount</h5>
                                <label class="form-label fw-semibold text-navy small">Discount Type *</label>
                                <div class="row g-3 mb-3">
                                    <div class="col-6">
                                        <input type="radio" class="btn-check" name="discountType" id="typePercentage" value="PERCENT" 
                                               ${promo.discountType != 'FIXED_AMOUNT' ? 'checked' : ''} onchange="onDiscountTypeChange()">
                                        <label class="lc-picker-card h-100" for="typePercentage">
                                            <span class="lc-picker-icon pct"><i class="bi bi-percent"></i></span>
                                            <div class="fw-bold text-navy">Percentage</div>
                                            <div class="text-muted small mt-1" style="font-size: 0.75rem;">e.g. 10% off the order</div>
                                        </label>
                                    </div>
                                    <div class="col-6">
                                        <input type="radio" class="btn-check" name="discountType" id="typeFixed" value="FIXED_AMOUNT" 
                                               ${promo.discountType == 'FIXED_AMOUNT' ? 'checked' : ''} onchange="onDiscountTypeChange()">
                                        <label class="lc-picker-card h-100" for="typeFixed">
                                            <span class="lc-picker-icon fix"><i class="bi bi-cash"></i></span>
                                            <div class="fw-bold text-navy">Fixed amount</div>
                                            <div class="text-muted small mt-1" style="font-size: 0.75rem;">e.g. 50,000₫ off the order</div>
                                        </label>
                                    </div>
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-navy small">Discount Value *</label>
                                        <div class="input-group input-group-sm">
                                            <input type="number" class="form-control" name="discountValue" id="inputValue"
                                                   min="1" step="any" required
                                                   value="${rawDiscountValue}">
                                            <span class="input-group-text" id="valueSuffix">%</span>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-navy small">Minimum Order Amount</label>
                                        <div class="input-group input-group-sm">
                                            <input type="number" class="form-control" name="minOrderAmount" id="inputMinOrder"
                                                   min="0" step="any"
                                                   value="${rawMinOrderAmount}">
                                            <span class="input-group-text">₫</span>
                                        </div>
                                        <div class="text-muted small mt-1" style="font-size: 0.75rem;">Leave 0 for no minimum.</div>
                                    </div>
                                </div>
                            </div>

                            <%-- Section: Validity Period --%>
                            <div class="card lc-elev p-4 mb-4 lc-rise" style="--i:2;">
                                <h5 class="text-navy fw-bold mb-3">Validity Period</h5>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label fw-semibold text-navy small">Start date *</label>
                                        <input type="date" class="form-control form-control-sm" name="startDate" id="inputStart" required
                                               value="${rawStartDate}"
                                               <c:if test="${!isEdit}">min="${todayStr}"</c:if>>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold text-navy small">End date *</label>
                                            <input type="date" class="form-control form-control-sm" name="endDate" id="inputEnd" required
                                                   value="${rawEndDate}">
                                    </div>
                                </div>
                            </div>

                            <%-- Section: Usage Limits & Active status --%>
                            <div class="card lc-elev p-4 mb-4 lc-rise" style="--i:3;">
                                <h5 class="text-navy fw-bold mb-3">Usage Limits</h5>
                                <div class="d-flex align-items-center justify-content-between mb-3">
                                    <div>
                                        <div class="fw-bold text-navy small">Limit total usage</div>
                                        <div class="text-muted small" style="font-size:0.8rem;">When off, this code can be used unlimited times.</div>
                                    </div>
                                    <div class="form-check form-switch p-0">
                                        <input class="form-check-input ms-0" type="checkbox" id="toggleLimit" 
                                               ${not empty rawMaxUses ? 'checked' : ''} onchange="onLimitToggleChange()">
                                    </div>
                                </div>
                                <div class="mb-4 d-none" id="maxUsesGroup">
                                    <label class="form-label fw-semibold text-navy small">Max Uses *</label>
                                    <input type="number" class="form-control form-control-sm" name="maxUses" id="inputMaxUses"
                                           min="1" placeholder="e.g. 1000"
                                           value="${rawMaxUses}">
                                </div>
                                <hr class="my-3 text-muted" style="opacity: 0.15;">

                                <div class="d-flex align-items-center justify-content-between">
                                    <div>
                                        <div class="fw-bold text-navy small">Active status</div>
                                        <div class="text-muted small" style="font-size:0.8rem;">Inactive codes cannot be applied by customers.</div>
                                    </div>
                                    <div class="form-check form-switch p-0">
                                        <input class="form-check-input ms-0" type="checkbox" name="active" value="true"
                                               ${promo.active ? 'checked' : ''}>
                                    </div>
                                </div>

                                <c:if var="isEditMode" test="${isEdit}">
                                    <hr class="my-3 text-muted" style="opacity: 0.15;">
                                    <div class="row">
                                        <div class="col-md-6">
                                            <label class="form-label fw-semibold text-navy small">Used Count (Read-only)</label>
                                            <input type="text" class="form-control form-control-sm bg-light" readonly value="${promo.usedCount}">
                                        </div>
                                    </div>
                                </c:if>
                            </div>
                        </form>
                    </div>

                    <%-- Right column: Live preview and discount simulation --%>
                    <div class="col-lg-5">
                        <div class="sticky-top" style="top: 24px; z-index: 100;">
                            <%-- Live preview card --%>
                            <div class="card border-0 mb-4 p-0 overflow-hidden" style="background: transparent;">
                                <div class="text-muted small fw-semibold mb-2 uppercase" style="letter-spacing: 0.05em;">Live preview</div>
                                <div class="ticket-card">
                                    <div class="card-glow"></div>
                                    <div class="d-flex flex-column h-100 justify-content-between position-relative" style="z-index: 3; min-height: 150px;">
                                        <div>
                                            <div class="small text-white" style="font-size: 0.72rem; letter-spacing: 0.05em;"><i class="bi bi-tag-fill me-1"></i>PROMO CODE</div>
                                            <h4 class="fw-bold mb-2 text-white font-monospace" id="previewCode" style="letter-spacing: 0.05em;">PROMO_CODE</h4>
                                            <div class="fw-semibold text-truncate text-white small" id="previewName" style="max-width: 90%;">Promotion name</div>
                                        </div>

                                        <div class="d-flex align-items-end justify-content-between mt-4">
                                            <div>
                                                <div class="small text-white" style="font-size: 0.7rem; font-weight: 500;">YOU SAVE</div>
                                                <h3 class="fw-extrabold text-white mb-0" id="previewValue" style="font-size: 1.8rem; font-weight: 800;">10%</h3>
                                            </div>
                                            <div class="text-end">
                                                <div class="small text-white" id="previewMinOrder" style="font-size: 0.72rem;">No minimum order</div>
                                                <div class="small text-white mt-1" style="font-size: 0.72rem; font-weight: 500;" id="previewDates">Valid: dd/MM &rarr; dd/MM</div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="ticket-dash"></div>
                                </div>
                            </div>

                            <%-- Discount Example --%>
                            <div class="card lc-elev p-4">
                                <h6 class="text-navy fw-bold mb-3">Discount example</h6>
                                <div class="d-flex justify-content-between py-2 border-bottom border-light small text-muted">
                                    <span>Order subtotal</span>
                                    <span class="fw-semibold text-navy">265,000₫</span>
                                </div>
                                <div class="d-flex justify-content-between py-2 border-bottom border-light small text-muted">
                                    <span id="examplePromoLabel">Discount (CODE)</span>
                                    <span class="fw-semibold text-danger" id="exampleDiscount">-0₫</span>
                                </div>
                                <div class="d-flex justify-content-between py-2 mt-2">
                                    <span class="fw-bold text-navy">Final</span>
                                    <span class="fw-extrabold text-navy" style="font-size: 1.15rem; font-weight: 800;" id="exampleFinal">265,000₫</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </main>

        <%@ include file="/WEB-INF/views/branch/_branch-scripts.jspf" %>
        <script>
            // ── DOM Element Bindings ──────────────────────────────────────────
            // Obtain references to HTML inputs for form processing
            const inputCode = document.getElementById('inputCode');
            const inputName = document.getElementById('inputName');
            const typePercentage = document.getElementById('typePercentage');
            const typeFixed = document.getElementById('typeFixed');
            const inputValue = document.getElementById('inputValue');
            const inputMinOrder = document.getElementById('inputMinOrder');
            const inputStart = document.getElementById('inputStart');
            const inputEnd = document.getElementById('inputEnd');
            const toggleLimit = document.getElementById('toggleLimit');
            const inputMaxUses = document.getElementById('inputMaxUses');

            // Obtain references to Live Preview card nodes (dynamic update targets)
            const previewCode = document.getElementById('previewCode');
            const previewName = document.getElementById('previewName');
            const previewValue = document.getElementById('previewValue');
            const previewMinOrder = document.getElementById('previewMinOrder');
            const previewDates = document.getElementById('previewDates');
            const examplePromoLabel = document.getElementById('examplePromoLabel');
            const exampleDiscount = document.getElementById('exampleDiscount');
            const exampleFinal = document.getElementById('exampleFinal');

            /**
             * [Flow Step: JavaScript] Formats numbers to local Vietnamese Dong currency format (e.g., 250,000₫)
             */
            function formatCurrency(num) {
                return new Intl.NumberFormat('vi-VN').format(num) + '₫';
            }

            /**
             * [Flow Step: JavaScript] Converts date string format 'YYYY-MM-DD' to friendly 'DD/MM' display
             */
            function formatDateString(dateStr) {
                if (!dateStr) return '';
                const parts = dateStr.split('-');
                if (parts.length === 3) {
                    return parts[2] + '/' + parts[1]; // Returns Day/Month only for clean layout space
                }
                return dateStr;
            }

            /**
             * [Flow Step: JavaScript] Recalculates simulated cart values and reflects inputs onto the preview card
             */
            function updatePreview() {
                const isPercent = typePercentage.checked;
                const val = parseFloat(inputValue.value) || 0;
                const code = inputCode.value || 'PROMO_CODE';
                const name = inputName.value || 'Promotion name';
                const minOrder = parseFloat(inputMinOrder.value) || 0;

                // Sync code and name to the preview DOM text nodes
                previewCode.textContent = code;
                previewName.textContent = name;
                examplePromoLabel.textContent = 'Discount (' + code + ')';

                // Handle percentage vs fixed amount discount preview math
                if (isPercent) {
                    previewValue.textContent = val + '%';
                    exampleDiscount.textContent = '-' + formatCurrency(265000 * (val / 100));
                    exampleFinal.textContent = formatCurrency(265000 - (265000 * (val / 100)));
                } else {
                    previewValue.textContent = formatCurrency(val);
                    exampleDiscount.textContent = '-' + formatCurrency(val);
                    exampleFinal.textContent = formatCurrency(Math.max(0, 265000 - val));
                }

                // Sync minimum order requirements
                previewMinOrder.textContent = minOrder > 0 ? 'Min. ' + formatCurrency(minOrder) : 'No minimum order';

                // Sync validity date strings
                const start = formatDateString(inputStart.value);
                const end = formatDateString(inputEnd.value);
                previewDates.textContent = 'Valid: ' + start + ' → ' + end;
            }

            /**
             * [Flow Step: JavaScript] Enforces date continuity (end date cannot be before start date)
             */
            function updateEndDateMin() {
                if (inputStart.value) {
                    inputEnd.min = inputStart.value; // Dynamically set the minimum allowed date on the end-date calendarpicker
                }
            }

            /**
             * [Flow Step: JavaScript] Changes form constraints depending on discount type selection
             */
            function onDiscountTypeChange() {
                const suffix = document.getElementById('valueSuffix');
                if (typePercentage.checked) {
                    suffix.textContent = '%';
                    inputValue.max = 100; // Enforce maximum 100% discount boundary on browser side
                } else {
                    suffix.textContent = '₫';
                    inputValue.removeAttribute('max');
                }
                updatePreview();
            }

            /**
             * [Flow Step: JavaScript] Shows or hides usage count inputs based on limit toggler switch
             */
            function onLimitToggleChange() {
                const group = document.getElementById('maxUsesGroup');
                if (toggleLimit.checked) {
                    group.classList.remove('d-none');
                    inputMaxUses.setAttribute('required', 'required');
                } else {
                    group.classList.add('d-none');
                    inputMaxUses.removeAttribute('required');
                    inputMaxUses.value = ''; // Clean input value when disabled
                }
            }

            // ── Event Listener Registrations ──────────────────────────────────
            // Re-render live preview on any input interaction
            inputCode.addEventListener('input', updatePreview);
            inputName.addEventListener('input', updatePreview);
            inputValue.addEventListener('input', updatePreview);
            inputMinOrder.addEventListener('input', updatePreview);
            inputStart.addEventListener('change', () => {
                updateEndDateMin();
                updatePreview();
            });
            inputEnd.addEventListener('change', updatePreview);

            // ── Page Initialization ──────────────────────────────────────────
            // Trigger baseline rendering when browser finishes parsing DOM
            window.addEventListener('DOMContentLoaded', () => {
                onDiscountTypeChange();
                onLimitToggleChange();
                updateEndDateMin();
                updatePreview();
            });
        </script>
    </body>
</html>
