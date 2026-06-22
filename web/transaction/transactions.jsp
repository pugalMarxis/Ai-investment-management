<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.Transaction" %>
<%@ page import="com.investms.dao.TransactionDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);
    TransactionDAO tDao = new TransactionDAO();

    @SuppressWarnings("unchecked")
    List<Transaction> transactions = (List<Transaction>) request.getAttribute("transactions");
    BigDecimal walletBalance  = (BigDecimal) request.getAttribute("walletBalance");
    BigDecimal totalDeposited = (BigDecimal) request.getAttribute("totalDeposited");
    BigDecimal totalWithdrawn = (BigDecimal) request.getAttribute("totalWithdrawn");

    if (transactions   == null) transactions   = tDao.findByUser(uid);
    if (walletBalance  == null) walletBalance  = tDao.getWalletBalance(uid);
    if (totalDeposited == null) totalDeposited = tDao.getTotalDeposited(uid);
    if (totalWithdrawn == null) totalWithdrawn = tDao.getTotalWithdrawn(uid);

    boolean deposited  = "true".equals(request.getParameter("deposited"));
    boolean withdrawn  = "true".equals(request.getParameter("withdrawn"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Transactions — InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
</head>
<body class="app-body">
<div class="app-layout">
    <%@ include file="/includes/sidebar.jsp" %>
    <div class="main-content" id="mainContent">
        <%@ include file="/includes/topnav.jsp" %>
        <div class="content-area">

            <!-- Page Header -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">Transactions</h1>
                    <p class="page-subtitle">Complete financial history &amp; wallet management</p>
                </div>
                <div class="page-header-actions">
                    <a href="<%= request.getContextPath() %>/TransactionServlet?action=deposit"
                       class="btn-success-custom">
                        <i class="fas fa-plus-circle me-2"></i>Deposit
                    </a>
                    <a href="<%= request.getContextPath() %>/TransactionServlet?action=withdraw"
                       class="btn-danger-custom">
                        <i class="fas fa-minus-circle me-2"></i>Withdraw
                    </a>
                </div>
            </div>

            <!-- Alerts -->
            <% if (deposited) { %>
            <div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>
                Funds deposited successfully to your wallet!</div>
            <% } %>
            <% if (withdrawn) { %>
            <div class="alert alert-info"><i class="fas fa-info-circle me-2"></i>
                Withdrawal processed successfully!</div>
            <% } %>

            <!-- Wallet + Stats Cards -->
            <div class="metrics-grid">

                <!-- Wallet Balance (Hero) -->
                <div class="metric-card metric-gradient-blue wallet-hero-card">
                    <div class="wallet-hero-content">
                        <div class="wallet-icon-wrap">
                            <i class="fas fa-wallet"></i>
                        </div>
                        <div>
                            <span class="metric-label">Wallet Balance</span>
                            <span class="wallet-balance-hero">
                                $<%= String.format("%,.2f", walletBalance) %>
                            </span>
                            <div class="wallet-actions-inline">
                                <a href="<%= request.getContextPath() %>/TransactionServlet?action=deposit"
                                   class="btn-wallet-deposit">
                                    <i class="fas fa-arrow-up"></i> Deposit
                                </a>
                                <a href="<%= request.getContextPath() %>/TransactionServlet?action=withdraw"
                                   class="btn-wallet-withdraw">
                                    <i class="fas fa-arrow-down"></i> Withdraw
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Total Deposited -->
                <div class="metric-card metric-green">
                    <div class="metric-icon"><i class="fas fa-arrow-down"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total Deposited</span>
                        <span class="metric-value text-profit">
                            +$<%= String.format("%,.2f", totalDeposited) %>
                        </span>
                        <span class="metric-sub">All-time deposits</span>
                    </div>
                    <div class="metric-bg-icon"><i class="fas fa-arrow-down"></i></div>
                </div>

                <!-- Total Withdrawn -->
                <div class="metric-card metric-red">
                    <div class="metric-icon"><i class="fas fa-arrow-up"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total Withdrawn</span>
                        <span class="metric-value text-loss">
                            -$<%= String.format("%,.2f", totalWithdrawn) %>
                        </span>
                        <span class="metric-sub">All-time withdrawals</span>
                    </div>
                    <div class="metric-bg-icon"><i class="fas fa-arrow-up"></i></div>
                </div>

                <!-- Transaction Count -->
                <div class="metric-card metric-purple">
                    <div class="metric-icon"><i class="fas fa-receipt"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total Transactions</span>
                        <span class="metric-value"><%= transactions.size() %></span>
                        <span class="metric-sub">All time</span>
                    </div>
                    <div class="metric-bg-icon"><i class="fas fa-receipt"></i></div>
                </div>

            </div><!-- /metrics-grid -->

            <!-- Filter + Search Bar -->
            <div class="txn-toolbar">
                <div class="filter-tabs">
                    <button class="filter-tab active" onclick="filterTxn('ALL', this)">
                        <i class="fas fa-list me-1"></i>All
                    </button>
                    <button class="filter-tab" onclick="filterTxn('DEPOSIT', this)">
                        <i class="fas fa-arrow-down me-1"></i>Deposits
                    </button>
                    <button class="filter-tab" onclick="filterTxn('WITHDRAWAL', this)">
                        <i class="fas fa-arrow-up me-1"></i>Withdrawals
                    </button>
                    <button class="filter-tab" onclick="filterTxn('BUY', this)">
                        <i class="fas fa-shopping-cart me-1"></i>Buys
                    </button>
                    <button class="filter-tab" onclick="filterTxn('SELL', this)">
                        <i class="fas fa-tag me-1"></i>Sells
                    </button>
                </div>
                <div class="txn-search-wrap">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txnSearch" class="txn-search-input"
                           placeholder="Search reference, description..."
                           oninput="searchTransactions(this.value)">
                </div>
            </div>

            <!-- Transactions Table -->
            <div class="card-panel">
                <% if (transactions.isEmpty()) { %>
                <div class="empty-state-full">
                    <div class="empty-icon"><i class="fas fa-receipt"></i></div>
                    <h3>No Transactions Yet</h3>
                    <p>Deposit funds to get started with your investments.</p>
                    <a href="<%= request.getContextPath() %>/TransactionServlet?action=deposit"
                       class="btn-primary-custom">
                        <i class="fas fa-plus me-2"></i>Make First Deposit
                    </a>
                </div>
                <% } else { %>
                <div class="table-responsive">
                    <table class="data-table" id="txnTable">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Date &amp; Time</th>
                                <th>Type</th>
                                <th>Reference</th>
                                <th>Description</th>
                                <th>Amount</th>
                                <th>Balance After</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody id="txnTableBody">
                        <% int rn = 1; for (Transaction t : transactions) {
                            boolean credit = t.isCredit();
                        %>
                        <tr class="txn-row" data-type="<%= t.getType() %>"
                            data-search="<%= (t.getReferenceNo() != null ? t.getReferenceNo() : "") + " " + (t.getDescription() != null ? t.getDescription() : "") %>">
                            <td class="text-muted"><%= rn++ %></td>
                            <td>
                                <div class="txn-date-cell">
                                    <span class="txn-date">
                                        <%= t.getCreatedAt() != null ? t.getCreatedAt().toLocalDate() : "—" %>
                                    </span>
                                    <span class="txn-time text-muted">
                                        <%= t.getCreatedAt() != null
                                            ? String.format("%02d:%02d",
                                                t.getCreatedAt().getHour(),
                                                t.getCreatedAt().getMinute())
                                            : "" %>
                                    </span>
                                </div>
                            </td>
                            <td>
                                <div class="txn-type-cell">
                                    <div class="txn-type-icon <%= credit ? "txn-credit" : "txn-debit" %>">
                                        <i class="fas fa-<%= credit ? "arrow-down" : "arrow-up" %>"></i>
                                    </div>
                                    <span class="badge <%= t.getTypeBadgeClass() %>">
                                        <%= t.getType() %>
                                    </span>
                                </div>
                            </td>
                            <td>
                                <span class="txn-ref">
                                    <%= t.getReferenceNo() != null ? t.getReferenceNo() : "—" %>
                                </span>
                            </td>
                            <td class="text-muted txn-desc">
                                <%= t.getDescription() != null ? t.getDescription() : "—" %>
                                <% if (t.getPlanName() != null) { %>
                                <br><small><%= t.getPlanName() %></small>
                                <% } %>
                            </td>
                            <td class="text-mono fw-700 <%= credit ? "text-profit" : "text-loss" %>">
                                <%= credit ? "+" : "-" %>$<%= String.format("%,.2f", t.getAmount()) %>
                            </td>
                            <td class="text-mono text-muted">
                                $<%= String.format("%,.2f", t.getBalanceAfter()) %>
                            </td>
                            <td>
                                <span class="badge <%= t.getStatusBadgeClass() %>">
                                    <%= t.getStatus() %>
                                </span>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <div class="table-footer-info">
                    Showing <span id="visibleCount"><%= transactions.size() %></span>
                    of <%= transactions.size() %> transactions
                </div>
                <% } %>
            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
function filterTxn(type, btn) {
    document.querySelectorAll('.filter-tab').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    let visible = 0;
    document.querySelectorAll('.txn-row').forEach(row => {
        const show = type === 'ALL' || row.dataset.type === type;
        row.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    updateVisibleCount(visible);
}

function searchTransactions(query) {
    query = query.toLowerCase().trim();
    let visible = 0;
    document.querySelectorAll('.txn-row').forEach(row => {
        const text = (row.dataset.search || '').toLowerCase();
        const show = !query || text.includes(query);
        row.style.display = show ? '' : 'none';
        if (show) visible++;
    });
    updateVisibleCount(visible);
}

function updateVisibleCount(n) {
    const el = document.getElementById('visibleCount');
    if (el) el.textContent = n;
}

document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
