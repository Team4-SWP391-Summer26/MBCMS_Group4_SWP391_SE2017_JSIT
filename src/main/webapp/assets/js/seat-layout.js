/*
 * seat-layout.js - shared multi-select seat editor for /branch/seats & /admin/seats.
 * Requires globals (set inline before this script): CTX, ROOM_ID, ENDPOINT.
 * Backend contract: POST action=updateSeat & roomId & seatId & (seatType | active).
 */
(function () {
    // DOM bindings for multi-select seat configuration dashboard controls
    const tools = document.querySelectorAll('.sl-tool');
    const seats = Array.from(document.querySelectorAll('.sl-seat'));
    const applyBtn = document.getElementById('applyBtn');
    const selCount = document.getElementById('selCount');
    const selectAllBtn = document.getElementById('selectAllBtn');
    const clearBtn = document.getElementById('clearBtn');

    let currentTool = 'STANDARD';
    const selected = new Set(); // Store unique selected seat IDs

    // ----- Tool switch -----
    tools.forEach(function (t) {
        t.addEventListener('click', function () {
            // Remove active style from other tool pills and set current configuration type
            tools.forEach(x => x.classList.remove('active'));
            t.classList.add('active');
            currentTool = t.getAttribute('data-tool');
        });
    });

    // ----- Seat select (off seats can still be re-selected to turn back on) -----
    seats.forEach(function (s) {
        s.addEventListener('click', function () {
            const id = s.getAttribute('data-seatid');
            // Toggle seat ID in the selection set
            if (selected.has(id)) { 
                selected.delete(id); 
                s.classList.remove('selected'); 
            } else { 
                selected.add(id); 
                s.classList.add('selected'); 
            }
            refresh();
        });
    });

    // Select all seats inside the grid
    selectAllBtn && selectAllBtn.addEventListener('click', function () {
        seats.forEach(s => { selected.add(s.getAttribute('data-seatid')); s.classList.add('selected'); });
        refresh();
    });

    // Clear current client-side selections
    clearBtn && clearBtn.addEventListener('click', function () {
        seats.forEach(s => s.classList.remove('selected'));
        selected.clear();
        refresh();
    });

    // ----- Apply current tool to all selected seats -----
    applyBtn && applyBtn.addEventListener('click', async function () {
        if (selected.size === 0) return;
        applyBtn.disabled = true;
        applyBtn.textContent = 'Applying...';
        try {
            // [Flow Step: JavaScript -> Servlet] Sequentially post modifications for each selected seat
            for (const id of selected) {
                if (currentTool === 'OFF') {
                    await postSeat(id, { active: 'false' });
                } else {
                    await postSeat(id, { seatType: currentTool, active: 'true' });
                }
            }
            // Reload page to reflect updated database states in grid
            location.reload();
        } catch (e) {
            lcAlert('Update failed. Please try again.');
            applyBtn.disabled = false;
            updateApplyLabel();
        }
    });

    /**
     * [Flow Step: JavaScript -> API] Prepares and routes seat parameter adjustments to backend
     */
    async function postSeat(seatId, extra) {
        const body = new URLSearchParams(Object.assign({ action: 'updateSeat', roomId: ROOM_ID, seatId: seatId }, extra));
        
        // Active toggle and type are separate updates in the backend -> send sequentially
        if (extra.seatType && extra.active) {
            await rawPost(new URLSearchParams({ action: 'updateSeat', roomId: ROOM_ID, seatId: seatId, seatType: extra.seatType }));
            await rawPost(new URLSearchParams({ action: 'updateSeat', roomId: ROOM_ID, seatId: seatId, active: 'true' }));
            return;
        }
        await rawPost(body);
    }

    /**
     * [Flow Step: AJAX -> Servlet] Dispatches POST request containing URL-encoded parameters and CSRF security header
     */
    async function rawPost(body) {
        // [Security Check] Include CSRF token value in request parameters if defined
        if (typeof CSRF_TOKEN !== 'undefined' && CSRF_TOKEN) {
            body.append('_csrf', CSRF_TOKEN);
        }
        
        const headers = { 'Content-Type': 'application/x-www-form-urlencoded' };
        if (typeof CSRF_TOKEN !== 'undefined' && CSRF_TOKEN) {
            headers['X-CSRF-TOKEN'] = CSRF_TOKEN;
        }
        
        const res = await fetch(ENDPOINT, {
            method: 'POST',
            headers: headers,
            body: body.toString()
        });
        const json = await res.json();
        if (!json.success) throw new Error(json.message || 'failed');
    }

    function updateApplyLabel() {
        applyBtn.textContent = 'Apply (' + selected.size + ')';
    }

    function refresh() {
        if (selCount) selCount.textContent = selected.size;
        if (applyBtn) { applyBtn.disabled = selected.size === 0; updateApplyLabel(); }
    }

    // ----- Summary counts -----
    function countSummary() {
        let std = 0, vip = 0, off = 0;
        seats.forEach(s => {
            if (s.classList.contains('is-off')) off++;
            else if (s.classList.contains('is-vip')) vip++;
            else std++;
        });
        setText('sumTotal', seats.length);
        setText('sumStd', std);
        setText('sumVip', vip);
        setText('sumOff', off);
    }
    function setText(id, v) { const el = document.getElementById(id); if (el) el.textContent = v; }

    countSummary();
    refresh();
})();
