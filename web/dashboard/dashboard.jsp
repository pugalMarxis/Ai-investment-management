<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%
    /* ── Auth guard ── */
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
        return;
    }

    /* ── If accessed directly (not via servlet), load data here ── */
    User dashUser = SessionUtil.getLoggedUser(request);
    int  uid      = dashUser.getUserId();

    BigDecimal totalInvested   = (BigDecimal) request.getAttribute("totalInvested");
    BigDecimal totalCurrentVal = (BigDecimal) request.getAttribute("totalCurrentVal");
    BigDecimal totalProfitLoss = (BigDecimal) request.getAttribute("totalProfitLoss");
    BigDecimal walletBalance   = (BigDecimal) request.getAttribute("walletBalance");
    BigDecimal returnPct       = (BigDecimal) request.getAttribute("returnPct");
    Integer portfolioCount     = (Integer)   request.getAttribute("portfolioCount");
    Integer investmentCount    = (Integer)   request.getAttribute("investmentCount");

    @SuppressWarnings("unchecked")
    List<Portfolio>   portfolios  = (List<Portfolio>)   request.getAttribute("portfolios");
    @SuppressWarnings("unchecked")
    List<Investment>  investments = (List<Investment>)  request.getAttribute("investments");
    @SuppressWarnings("unchecked")
    List<Transaction> recentTxns  = (List<Transaction>) request.getAttribute("recentTxns");

    // Fallback — load data if servlet was bypassed
    if (totalInvested == null) {
        InvestmentDAO  iDao = new InvestmentDAO();
        PortfolioDAO   pDao = new PortfolioDAO();
        TransactionDAO tDao = new TransactionDAO();
        totalInvested   = iDao.getTotalInvestedByUser(uid);
        totalCurrentVal = iDao.getTotalCurrentValueByUser(uid);
        totalProfitLoss = totalCurrentVal.subtract(totalInvested);
        walletBalance   = tDao.getWalletBalance(uid);
        returnPct       = totalInvested.compareTo(BigDecimal.ZERO) > 0
            ? totalProfitLoss.divide(totalInvested, 4, RoundingMode.HALF_UP)
                             .multiply(new BigDecimal("100")).setScale(2, RoundingMode.HALF_UP)
            : BigDecimal.ZERO;
        portfolioCount  = pDao.countByUser(uid);
        investmentCount = iDao.countByUser(uid);
        portfolios      = pDao.findByUser(uid);
        investments     = iDao.findByUser(uid);
        recentTxns      = tDao.findByUser(uid);
    }

    // Safe defaults
    if (totalInvested   == null) totalInvested   = BigDecimal.ZERO;
    if (totalCurrentVal == null) totalCurrentVal = BigDecimal.ZERO;
    if (totalProfitLoss == null) totalProfitLoss = BigDecimal.ZERO;
    if (walletBalance   == null) walletBalance   = BigDecimal.ZERO;
    if (returnPct       == null) returnPct       = BigDecimal.ZERO;
    if (portfolioCount  == null) portfolioCount  = 0;
    if (investmentCount == null) investmentCount = 0;
    if (portfolios      == null) portfolios      = new ArrayList<>();
    if (investments     == null) investments     = new ArrayList<>();
    if (recentTxns      == null) recentTxns      = new ArrayList<>();

    boolean isProfit = totalProfitLoss.compareTo(BigDecimal.ZERO) >= 0;

    /* ── Build Chart.js data from investments ── */
    StringBuilder assetLabels  = new StringBuilder();
    StringBuilder assetValues  = new StringBuilder();
    StringBuilder assetColors  = new StringBuilder();
    String[] chartPalette = {
        "'#e74c3c'","'#3498db'","'#2ecc71'","'#f39c12'",
        "'#9b59b6'","'#1abc9c'","'#e67e22'","'#34495e'",
        "'#e91e63'","'#00bcd4'"
    };
    int ci = 0;
    for (Investment inv : investments) {
        if (!"ACTIVE".equals(inv.getStatus())) continue;
        if (assetLabels.length() > 0) { assetLabels.append(","); assetValues.append(","); assetColors.append(","); }
        assetLabels.append("'").append(inv.getAssetSymbol() != null ? inv.getAssetSymbol() : inv.getAssetName()).append("'");
        assetValues.append(inv.getCurrentValue());
        assetColors.append(chartPalette[ci % chartPalette.length]);
        ci++;
    }

    /* ── Monthly performance (last 6 months labels mock) ── */
    String[] months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};
    java.util.Calendar cal = java.util.Calendar.getInstance();
    StringBuilder monthLabels = new StringBuilder();
    StringBuilder monthValues = new StringBuilder();
    for (int m = 5; m >= 0; m--) {
        java.util.Calendar c2 = java.util.Calendar.getInstance();
        c2.add(java.util.Calendar.MONTH, -m);
        int idx = c2.get(java.util.Calendar.MONTH);
        if (monthLabels.length() > 0) { monthLabels.append(","); monthValues.append(","); }
        monthLabels.append("'").append(months[idx]).append("'");
        // Simulate increasing portfolio growth
        double base = totalCurrentVal.doubleValue();
        double factor = 1.0 - (m * 0.05);
        monthValues.append(String.format("%.2f", base * factor));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Dashboard — InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
</head>
<body class="app-body">

<div class="app-layout">
    <%@ include file="/includes/sidebar.jsp" %>

    <div class="main-content" id="mainContent">
        <%@ include file="/includes/topnav.jsp" %>

        <div class="content-area">

            <!-- ── Page Header ── -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        Welcome back, <%= dashUser.getFullName().split(" ")[0] %>! 👋
                    </h1>
                    <p class="page-subtitle">Here's your investment overview for today</p>
                </div>
                <div class="page-header-actions">
                    <a href="<%= request.getContextPath() %>/portfolio/add-portfolio.jsp"
                       class="btn-primary-custom">
                        <i class="fas fa-plus me-2"></i>New Portfolio
                    </a>
                    <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
                       class="btn-ai-custom">
                        <i class="fas fa-robot me-2"></i>AI Insights
                    </a>
                </div>
            </div>

            <!-- ══════════════════════════════════════════
                 ROW 1: KEY METRIC CARDS
            ══════════════════════════════════════════ -->
            <div class="metrics-grid">

                <!-- Wallet Balance -->
                <div class="metric-card metric-blue">
                    <div class="metric-icon">
                        <i class="fas fa-wallet"></i>
                    </div>
                    <div class="metric-body">
                        <span class="metric-label">Wallet Balance</span>
                        <span class="metric-value">$<%= String.format("%,.2f", walletBalance) %></span>
                        <span class="metric-sub">Available funds</span>
                    </div>
                    <div class="metric-bg-icon"><i class="fas fa-wallet"></i></div>
                </div>

                <!-- Total Invested -->
                <div class="metric-card metric-purple">
                    <div class="metric-icon">
                        <i class="fas fa-coins"></i>
                    </div>
                    <div class="metric-body">
                        <span class="metric-label">Total Invested</span>
                        <span class="metric-value">$<%= String.format("%,.2f", totalInvested) %></span>
                        <span class="metric-sub"><%= investmentCount %> active investments</span>
                    </div>
                    <div class="metric-bg-icon"><i class="fas fa-coins"></i></div>
                </div>

                <!-- Portfolio Value -->
                <div class="metric-card metric-green">
                    <div class="metric-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <div class="metric-body">
                        <span class="metric-label">Portfolio Value</span>
                        <span class="metric-value">$<%= String.format("%,.2f", totalCurrentVal) %></span>
                        <span class="metric-sub"><%= portfolioCount %> portfolios</span>
                    </div>
                    <div class="metric-bg-icon"><i class="fas fa-chart-line"></i></div>
                </div>

                <!-- Profit / Loss -->
                <div class="metric-card <%= isProfit ? "metric-teal" : "metric-red" %>">
                    <div class="metric-icon">
                        <i class="fas fa-<%= isProfit ? "arrow-trend-up" : "arrow-trend-down" %>"></i>
                    </div>
                    <div class="metric-body">
                        <span class="metric-label">Total P&L</span>
                        <span class="metric-value <%= isProfit ? "text-profit" : "text-loss" %>">
                            <%= isProfit ? "+" : "" %>$<%= String.format("%,.2f", totalProfitLoss.abs()) %>
                        </span>
                        <span class="metric-sub badge-return <%= isProfit ? "return-pos" : "return-neg" %>">
                            <%= isProfit ? "▲" : "▼" %> <%= returnPct.abs() %>%
                        </span>
                    </div>
                    <div class="metric-bg-icon">
                        <i class="fas fa-percentage"></i>
                    </div>
                </div>

            </div><!-- /metrics-grid -->

            <!-- ══════════════════════════════════════════
                 ROW 2: CHARTS
            ══════════════════════════════════════════ -->
            <div class="charts-grid">

                <!-- Portfolio Performance Line Chart -->
                <div class="chart-card chart-large">
                    <div class="chart-header">
                        <div>
                            <h3 class="chart-title">Portfolio Performance</h3>
                            <p class="chart-subtitle">Last 6 months overview</p>
                        </div>
                        <div class="chart-actions">
                            <button class="chart-btn active" onclick="switchChartPeriod('6m', this)">6M</button>
                            <button class="chart-btn" onclick="switchChartPeriod('3m', this)">3M</button>
                            <button class="chart-btn" onclick="switchChartPeriod('1m', this)">1M</button>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="performanceChart"></canvas>
                    </div>
                </div>

                <!-- Asset Allocation Doughnut -->
                <div class="chart-card chart-small">
                    <div class="chart-header">
                        <div>
                            <h3 class="chart-title">Asset Allocation</h3>
                            <p class="chart-subtitle">Current distribution</p>
                        </div>
                    </div>
                    <div class="chart-container">
                        <canvas id="allocationChart"></canvas>
                    </div>
                    <% if (investments.isEmpty()) { %>
                    <div class="chart-empty">
                        <i class="fas fa-chart-pie"></i>
                        <p>No investments yet</p>
                        <a href="<%= request.getContextPath() %>/investment/add-investment.jsp"
                           class="btn-sm-primary">Add Investment</a>
                    </div>
                    <% } %>
                </div>

            </div><!-- /charts-grid -->

            <!-- ══════════════════════════════════════════
                 ROW 3: PORTFOLIOS TABLE + RECENT ACTIVITY
            ══════════════════════════════════════════ -->
            <div class="data-grid">

                <!-- Portfolios Summary -->
                <div class="data-card data-large">
                    <div class="data-card-header">
                        <h3 class="data-card-title">
                            <i class="fas fa-briefcase me-2"></i>My Portfolios
                        </h3>
                        <a href="<%= request.getContextPath() %>/portfolio/portfolios.jsp"
                           class="view-all-link">View All →</a>
                    </div>
                    <div class="table-responsive">
                        <table class="data-table">
                            <thead>
                                <tr>
                                    <th>Portfolio</th>
                                    <th>Risk</th>
                                    <th>Invested</th>
                                    <th>Value</th>
                                    <th>P&L</th>
                                    <th>Return</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% if (portfolios.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="empty-row">
                                        <i class="fas fa-briefcase"></i>
                                        No portfolios yet.
                                        <a href="<%= request.getContextPath() %>/portfolio/add-portfolio.jsp">
                                            Create one →
                                        </a>
                                    </td>
                                </tr>
                            <% } else {
                                int pMax = Math.min(portfolios.size(), 5);
                                for (int pi = 0; pi < pMax; pi++) {
                                    Portfolio p = portfolios.get(pi);
                                    boolean pp = p.isProfitable();
                            %>
                                <tr>
                                    <td>
                                        <div class="table-name-cell">
                                            <div class="table-avatar">
                                                <%= p.getPortfolioName().substring(0,1).toUpperCase() %>
                                            </div>
                                            <span><%= p.getPortfolioName() %></span>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge <%= p.getRiskBadgeClass() %>">
                                            <%= p.getRiskLevel() %>
                                        </span>
                                    </td>
                                    <td class="text-mono">$<%= String.format("%,.2f", p.getTotalInvested()) %></td>
                                    <td class="text-mono">$<%= String.format("%,.2f", p.getTotalCurrentValue()) %></td>
                                    <td class="text-mono <%= pp ? "text-profit" : "text-loss" %>">
                                        <%= pp ? "+" : "" %>$<%= String.format("%,.2f", p.getTotalProfitLoss().abs()) %>
                                    </td>
                                    <td>
                                        <span class="badge-return-sm <%= pp ? "return-pos" : "return-neg" %>">
                                            <%= pp ? "▲" : "▼" %> <%= p.getReturnPct().abs() %>%
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge badge-status-<%= p.getStatus().toLowerCase() %>">
                                            <%= p.getStatus() %>
                                        </span>
                                    </td>
                                </tr>
                            <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Recent Transactions -->
                <div class="data-card data-small">
                    <div class="data-card-header">
                        <h3 class="data-card-title">
                            <i class="fas fa-history me-2"></i>Recent Activity
                        </h3>
                        <a href="<%= request.getContextPath() %>/transaction/transactions.jsp"
                           class="view-all-link">View All →</a>
                    </div>
                    <div class="activity-list">
                    <% if (recentTxns.isEmpty()) { %>
                        <div class="empty-state-sm">
                            <i class="fas fa-receipt"></i>
                            <p>No transactions yet</p>
                        </div>
                    <% } else {
                        int tMax = Math.min(recentTxns.size(), 7);
                        for (int ti = 0; ti < tMax; ti++) {
                            Transaction t = recentTxns.get(ti);
                            boolean isCredit = t.isCredit();
                    %>
                        <div class="activity-item">
                            <div class="activity-icon-wrap
                                 <%= isCredit ? "activity-green" : "activity-red" %>">
                                <i class="fas fa-<%= isCredit ? "arrow-down" : "arrow-up" %>"></i>
                            </div>
                            <div class="activity-info">
                                <span class="activity-type"><%= t.getType() %></span>
                                <span class="activity-desc">
                                    <%= t.getDescription() != null ? t.getDescription() : t.getReferenceNo() %>
                                </span>
                            </div>
                            <div class="activity-amount <%= isCredit ? "text-profit" : "text-loss" %>">
                                <%= isCredit ? "+" : "-" %>$<%= String.format("%,.2f", t.getAmount()) %>
                            </div>
                        </div>
                    <% } } %>
                    </div>
                </div>

            </div><!-- /data-grid -->

            <!-- ══════════════════════════════════════════
                 ROW 4: TOP INVESTMENTS + AI TEASER
            ══════════════════════════════════════════ -->
            <div class="bottom-grid">

                <!-- Top Investments -->
                <div class="data-card data-medium">
                    <div class="data-card-header">
                        <h3 class="data-card-title">
                            <i class="fas fa-star me-2"></i>Top Investments
                        </h3>
                        <a href="<%= request.getContextPath() %>/investment/investments.jsp"
                           class="view-all-link">View All →</a>
                    </div>
                    <% if (investments.isEmpty()) { %>
                    <div class="empty-state-sm">
                        <i class="fas fa-coins"></i>
                        <p>No investments yet.</p>
                        <a href="<%= request.getContextPath() %>/investment/add-investment.jsp"
                           class="btn-sm-primary">Add Investment</a>
                    </div>
                    <% } else {
                        int iMax = Math.min(investments.size(), 5);
                        for (int ii = 0; ii < iMax; ii++) {
                            Investment inv = investments.get(ii);
                            boolean ip = inv.isProfitable();
                    %>
                    <div class="invest-row">
                        <div class="invest-symbol">
                            <%= inv.getAssetSymbol() != null ? inv.getAssetSymbol() : "?" %>
                        </div>
                        <div class="invest-info">
                            <span class="invest-name"><%= inv.getPlanName() %></span>
                            <span class="invest-asset"><%= inv.getAssetName() %></span>
                        </div>
                        <div class="invest-pnl">
                            <span class="invest-value">$<%= String.format("%,.2f", inv.getCurrentValue()) %></span>
                            <span class="invest-return <%= ip ? "return-pos" : "return-neg" %>">
                                <%= ip ? "▲" : "▼" %> <%= inv.getReturnPct().abs() %>%
                            </span>
                        </div>
                    </div>
                    <% } } %>
                </div>

                <!-- AI Features Teaser Cards -->
                <div class="ai-teaser-grid">
                    <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
                       class="ai-teaser-card">
                        <div class="ai-teaser-icon"><i class="fas fa-robot"></i></div>
                        <div class="ai-teaser-text">
                            <strong>AI Recommendations</strong>
                            <span>Get personalised investment suggestions</span>
                        </div>
                        <i class="fas fa-chevron-right ai-arrow"></i>
                    </a>
                    <a href="<%= request.getContextPath() %>/ai/risk-analyzer.jsp"
                       class="ai-teaser-card">
                        <div class="ai-teaser-icon"><i class="fas fa-shield-alt"></i></div>
                        <div class="ai-teaser-text">
                            <strong>Risk Analyzer</strong>
                            <span>Predict portfolio risk level</span>
                        </div>
                        <i class="fas fa-chevron-right ai-arrow"></i>
                    </a>
                    <a href="<%= request.getContextPath() %>/ai/chatbot.jsp"
                       class="ai-teaser-card">
                        <div class="ai-teaser-icon"><i class="fas fa-comment-dots"></i></div>
                        <div class="ai-teaser-text">
                            <strong>AI Financial Chatbot</strong>
                            <span>Ask anything about investing</span>
                        </div>
                        <i class="fas fa-chevron-right ai-arrow"></i>
                    </a>
                    <a href="<%= request.getContextPath() %>/ai/reports.jsp"
                       class="ai-teaser-card">
                        <div class="ai-teaser-icon"><i class="fas fa-file-chart-line"></i></div>
                        <div class="ai-teaser-text">
                            <strong>AI Reports</strong>
                            <span>Intelligent performance reports</span>
                        </div>
                        <i class="fas fa-chevron-right ai-arrow"></i>
                    </a>
                </div>

            </div><!-- /bottom-grid -->

        </div><!-- /content-area -->

        <%@ include file="/includes/footer.jsp" %>
    </div><!-- /main-content -->
</div><!-- /app-layout -->

<!-- ══════════════════════════════════════════
     CHART.JS INITIALISATION
══════════════════════════════════════════ -->
<script>
// ── Portfolio Performance (Line Chart) ──────────────────────────────────────
const perfCtx = document.getElementById('performanceChart').getContext('2d');
const perfGradient = perfCtx.createLinearGradient(0, 0, 0, 300);
perfGradient.addColorStop(0,   'rgba(229, 57, 53, 0.35)');
perfGradient.addColorStop(1,   'rgba(229, 57, 53, 0.00)');

const performanceChart = new Chart(perfCtx, {
    type: 'line',
    data: {
        labels: [<%= monthLabels %>],
        datasets: [{
            label: 'Portfolio Value ($)',
            data:  [<%= monthValues %>],
            borderColor:     '#e53935',
            backgroundColor: perfGradient,
            borderWidth: 3,
            pointBackgroundColor: '#e53935',
            pointBorderColor:     '#fff',
            pointBorderWidth: 2,
            pointRadius: 5,
            pointHoverRadius: 7,
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { mode: 'index', intersect: false },
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#1a1a2e',
                titleColor: '#fff',
                bodyColor:  '#aaa',
                borderColor: '#e53935',
                borderWidth: 1,
                padding: 12,
                callbacks: {
                    label: ctx => ' $' + parseFloat(ctx.raw).toLocaleString('en-US', {minimumFractionDigits: 2})
                }
            }
        },
        scales: {
            x: {
                grid: { color: 'rgba(255,255,255,0.05)' },
                ticks: { color: '#888', font: { size: 12 } }
            },
            y: {
                grid: { color: 'rgba(255,255,255,0.05)' },
                ticks: {
                    color: '#888',
                    font: { size: 12 },
                    callback: v => '$' + v.toLocaleString()
                }
            }
        }
    }
});

// ── Asset Allocation (Doughnut Chart) ────────────────────────────────────────
<% if (!investments.isEmpty()) { %>
const allocCtx = document.getElementById('allocationChart').getContext('2d');
new Chart(allocCtx, {
    type: 'doughnut',
    data: {
        labels: [<%= assetLabels %>],
        datasets: [{
            data:            [<%= assetValues %>],
            backgroundColor: [<%= assetColors %>],
            borderColor:     '#1a1a2e',
            borderWidth: 3,
            hoverOffset: 8
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        cutout: '68%',
        plugins: {
            legend: {
                position: 'bottom',
                labels: {
                    color: '#ccc',
                    padding: 16,
                    font: { size: 11 },
                    boxWidth: 14
                }
            },
            tooltip: {
                backgroundColor: '#1a1a2e',
                titleColor: '#fff',
                bodyColor:  '#aaa',
                borderColor: '#333',
                borderWidth: 1,
                callbacks: {
                    label: ctx => ' $' + parseFloat(ctx.raw).toLocaleString('en-US', {minimumFractionDigits: 2})
                }
            }
        }
    }
});
<% } %>

// ── Chart period switcher ─────────────────────────────────────────────────────
function switchChartPeriod(period, btn) {
    document.querySelectorAll('.chart-btn').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    // In production, fetch real data via AJAX here
}

// ── Sidebar toggle ────────────────────────────────────────────────────────────
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>

</body>
</html>
