/*
 * seat-layout.js - shared multi-select seat editor for /branch/seats & /admin/seats.
 * Requires globals (set inline before this script): CTX, ROOM_ID, ENDPOINT.
 * Backend contract: POST action=updateSeat & roomId & seatId & (seatType | active).
 */
(function () {
    const tools = document.querySelectorAll('.sl-tool');
    const seats = Array.from(document.querySelectorAll('.sl-seat'));
    const applyBtn = document.getElementById('applyBtn');
    const selCount = document.getElementById('selCount');
    const selectAllBtn = document.getElementById('selectAllBtn');
    const clearBtn = document.getElementById('clearBtn');

    let currentTool = 'STANDARD';
    const selected = new Set();

    // ----- Tool switch -----
    tools.forEach(function (t) {
        t.addEventListener('click', function () {
            tools.forEach(x => x.classList.remove('active'));
            t.classList.add('active');
            currentTool = t.getAttribute('data-tool');
        });
    });

    // ----- Seat select (off seats can still be re-selected to turn back on) -----
    seats.forEach(function (s) {
        s.addEventListener('click', function () {
            const id = s.getAttribute('data-seatid');
            if (selected.has(id)) { selected.delete(id); s.classList.remove('selected'); }
            else { selected.add(id); s.classList.add('selected'); }
            refresh();
        });
    });

    selectAllBtn && selectAllBtn.addEventListener('click', function () {
        seats.forEach(s => { selected.add(s.getAttribute('data-seatid')); s.classList.add('selected'); });
        refresh();
    });
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
            for (const id of selected) {
                if (currentTool === 'OFF') {
                    await postSeat(id, { active: 'false' });
                } else {
                    await postSeat(id, { seatType: currentTool, active: 'true' });
                }
            }
            location.reload();
        } catch (e) {
            lcAlert('Update failed. Please try again.');
            applyBtn.disabled = false;
            updateApplyLabel();
        }
    });

    async function postSeat(seatId, extra) {
        const body = new URLSearchParams(Object.assign({ action: 'updateSeat', roomId: ROOM_ID, seatId: seatId }, extra));
        // active toggle and type are separate updates in the backend -> send sequentially
        if (extra.seatType && extra.active) {
            await rawPost(new URLSearchParams({ action: 'updateSeat', roomId: ROOM_ID, seatId: seatId, seatType: extra.seatType }));
            await rawPost(new URLSearchParams({ action: 'updateSeat', roomId: ROOM_ID, seatId: seatId, active: 'true' }));
            return;
        }
        await rawPost(body);
    }

    async function rawPost(body) {
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
