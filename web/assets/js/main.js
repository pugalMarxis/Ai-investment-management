/**
 * InvestMS — Main JavaScript
 * Global UI behaviours: dropdowns, sidebar, alerts, charts, etc.
 */

'use strict';

/* ── DOMContentLoaded ─────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', function () {
    initDropdowns();
    initAlertAutoDismiss();
    initSidebarActiveLink();
    initTableSearch();
    initAnimatedNumbers();
    updateBreadcrumb();
});

/* ── 1. Dropdown Toggle ───────────────────────────────────── */
function toggleDropdown(menuId) {
    const menu = document.getElementById(menuId);
    if (!menu) return;
    const isOpen = menu.classList.contains('show');
    closeAllDropdowns();
    if (!isOpen) menu.classList.add('show');
}

function closeAllDropdowns() {
    document.querySelectorAll('.dropdown-menu.show').forEach(m => m.classList.remove('show'));
}

function initDropdowns() {
    document.addEventListener('click', function (e) {
        if (!e.target.closest('.dropdown')) closeAllDropdowns();
    });
}

/* ── 2. Sidebar Active State ──────────────────────────────── */
function initSidebarActiveLink() {
    const path = window.location.pathname;
    document.querySelectorAll('.nav-link').forEach(link => {
        if (link.href && link.href.includes(path.split('/').pop())) {
            link.classList.add('active');
        }
    });
}

/* ── 3. Auto-dismiss Alerts ───────────────────────────────── */
function initAlertAutoDismiss() {
    document.querySelectorAll('.alert').forEach(function (alert) {
        setTimeout(function () {
            alert.style.transition = 'opacity 0.5s ease';
            alert.style.opacity    = '0';
            setTimeout(() => alert.remove(), 500);
        }, 5000);
    });
}

/* ── 4. Table Search (generic) ────────────────────────────── */
function initTableSearch() {
    const searchInput = document.getElementById('tableSearch');
    if (!searchInput) return;
    searchInput.addEventListener('input', function () {
        const q = this.value.toLowerCase();
        document.querySelectorAll('table tbody tr').forEach(row => {
            row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
        });
    });
}

/* ── 5. Animated Counter Numbers ─────────────────────────── */
function initAnimatedNumbers() {
    document.querySelectorAll('.metric-value').forEach(function (el) {
        const text = el.textContent.trim();
        if (text.startsWith('$') || /^\d/.test(text)) {
            el.style.animation = 'fadeInUp 0.5s ease forwards';
        }
    });
}

/* ── 6. Update Breadcrumb ─────────────────────────────────── */
function updateBreadcrumb() {
    const el = document.getElementById('pageTitleBreadcrumb');
    if (!el) return;
    const title = document.title.split('—')[0].trim();
    if (title) el.textContent = title;
}

/* ── 7. Format currency helper ────────────────────────────── */
function formatCurrency(amount) {
    return '$' + parseFloat(amount).toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

/* ── 8. Confirm action helper ─────────────────────────────── */
function confirmAction(message) {
    return window.confirm(message || 'Are you sure?');
}

/* ── 9. Sidebar toggle (shared) ──────────────────────────── */
document.addEventListener('DOMContentLoaded', function () {
    const toggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('sidebar');
    const main = document.getElementById('mainContent');
    if (toggle && sidebar && main) {
        toggle.addEventListener('click', function () {
            sidebar.classList.toggle('collapsed');
            main.classList.toggle('sidebar-collapsed');
            localStorage.setItem('sidebarCollapsed',
                sidebar.classList.contains('collapsed') ? '1' : '0');
        });
        // Restore from localStorage
        if (localStorage.getItem('sidebarCollapsed') === '1') {
            sidebar.classList.add('collapsed');
            main.classList.add('sidebar-collapsed');
        }
    }
});

/* ── 10. Form submission loading state ────────────────────── */
document.addEventListener('submit', function (e) {
    const form = e.target;
    const submitBtn = form.querySelector('[type="submit"]');
    if (submitBtn && !submitBtn.dataset.noLoading) {
        const original = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
        submitBtn.disabled = true;
        // Re-enable after 10s as safety net
        setTimeout(() => {
            submitBtn.innerHTML = original;
            submitBtn.disabled = false;
        }, 10000);
    }
});

/* ── 11. Tooltips (simple title-based) ────────────────────── */
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('[title]').forEach(el => {
        el.addEventListener('mouseenter', function () {
            const tip = document.createElement('div');
            tip.className = 'custom-tooltip';
            tip.textContent = this.getAttribute('title');
            tip.style.cssText = `
                position:fixed;background:#1e293b;color:#f1f5f9;
                padding:4px 10px;border-radius:6px;font-size:0.75rem;
                z-index:99999;pointer-events:none;white-space:nowrap;
                border:1px solid #2d3748;
            `;
            document.body.appendChild(tip);
            this._tooltip = tip;
        });
        el.addEventListener('mousemove', function (ev) {
            if (this._tooltip) {
                this._tooltip.style.left = (ev.clientX + 12) + 'px';
                this._tooltip.style.top  = (ev.clientY + 12) + 'px';
            }
        });
        el.addEventListener('mouseleave', function () {
            if (this._tooltip) { this._tooltip.remove(); this._tooltip = null; }
        });
    });
});

/* ── 12. Number formatting in tables ─────────────────────── */
function formatTableNumbers() {
    document.querySelectorAll('.text-mono').forEach(el => {
        const t = el.textContent.trim();
        if (t.startsWith('$') && !t.includes(',')) {
            const n = parseFloat(t.replace('$',''));
            if (!isNaN(n)) el.textContent = formatCurrency(n);
        }
    });
}

/* ── 13. Chart.js global defaults ────────────────────────── */
if (typeof Chart !== 'undefined') {
    Chart.defaults.color              = '#94a3b8';
    Chart.defaults.font.family        = "'Inter', sans-serif";
    Chart.defaults.plugins.legend.labels.usePointStyle = true;
    Chart.defaults.animation.duration = 800;
}

/* ── 14. Responsive table overflow hint ──────────────────── */
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.table-responsive').forEach(wrap => {
        if (wrap.scrollWidth > wrap.clientWidth) {
            wrap.style.cursor = 'grab';
        }
    });
});

/* ── CSS animation keyframes (injected) ──────────────────── */
const styleSheet = document.createElement('style');
styleSheet.textContent = `
@keyframes fadeInUp {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}
@keyframes slideInLeft {
  from { opacity: 0; transform: translateX(-20px); }
  to   { opacity: 1; transform: translateX(0); }
}
@keyframes shimmer {
  0%   { background-position: -200% 0; }
  100% { background-position:  200% 0; }
}
`;
document.head.appendChild(styleSheet);
