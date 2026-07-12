(function () {
    'use strict';

    function ensureRegion() {
        var region = document.querySelector('.lc-toast-region');
        if (region) {
            return region;
        }
        region = document.createElement('div');
        region.className = 'lc-toast-region';
        region.setAttribute('aria-live', 'polite');
        region.setAttribute('aria-atomic', 'true');
        document.body.appendChild(region);
        return region;
    }

    function normalizeType(type) {
        if (type === 'success' || type === 'warning' || type === 'error') {
            return type;
        }
        return 'info';
    }

    window.LCToast = function (message, type, timeout) {
        var text = String(message || '').trim();
        if (!text) {
            return null;
        }

        var region = ensureRegion();
        var toast = document.createElement('div');
        var safeType = normalizeType(type);
        toast.className = 'lc-toast' + (safeType === 'info' ? '' : ' is-' + safeType);
        toast.setAttribute('role', safeType === 'error' ? 'alert' : 'status');
        toast.textContent = text;
        region.appendChild(toast);

        window.setTimeout(function () {
            toast.style.opacity = '0';
            toast.style.transform = 'translateY(6px)';
            window.setTimeout(function () {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, 180);
        }, timeout || 4200);

        return toast;
    };

    window.lcAlert = function (message, type) {
        return window.LCToast(message, type || 'warning');
    };

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('a[aria-disabled="true"]').forEach(function (link) {
            link.addEventListener('click', function (event) {
                event.preventDefault();
            });
        });
    });
}());
