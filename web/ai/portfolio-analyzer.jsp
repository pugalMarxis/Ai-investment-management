<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.ai.AIPortfolioAnalyzer" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);

    AIPortfolioAnalyzer.PortfolioAnalysisReport report =
        (AIPortfolioAnalyzer.PortfolioAnalysisReport) request.getAttribute("analysisReport");
    @SuppressWarnings("unchecked")
    List<Investment> investments = (List<Investment>) request.getAttribute("investments");
    @SuppressWarnings("unchecked")
    List<Portfolio> portfolios = (List<Portfolio>) request.getAttribute("portfolios");

    if (report == null) {
        InvestmentDAO iDao = new InvestmentDAO();
        PortfolioDAO  pDao = new PortfolioDAO();
        investments = iDao.findByUser(uid);
        portfolios  = pDao.findByUser(uid);
        AIPortfolioAnalyzer analyzer = new AIPortfolioAnalyzer();
        report = analyzer.analyze(investments, portfolios);
    }
    if (investments == null) investments = new ArrayList<>();
    if (portfolios  == null) portfolios  = new ArrayList<>();

    // Sector chart data
    StringBuilder sLabels = new StringBuilder();
    StringBuilder sValues = new StringBuilder();
    StringBuilder sColors = new StringBuilder();
    String[] palette = {"'#3b82f6'","'#10b981'","'#f59e0b'","'#e74c3c'","'#8b5cf6'","'#06b6d4'","'#f97316'","'#64748b'"};
    int ci = 0;
    for (Map.Entry<String, Double> e : report.getSectorAllocation().entrySet()) {
        if (sLabels.length() > 0) { sLabels.append(","); sValues.append(","); sColors.append(","); }
        sLabels.append("'").append(e.getKey()).append("'");
        sValues.append(String.format("%.2f", e.getValue()));
        sColors.append(palette[ci % palette.length]);
        ci++;
    }
    boolean overallPositive = report.getOverallReturn() >= 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>AI Portfolio Analyzer — InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
</head>
<body class="app-body">
<div class="app-layout">
    <%@ include file="/includes/sidebar.jsp" %>
    <div class="main-content" id="mainContent">
        <%@ include file="/includes/topnav.jsp" %>
        <div class="content-area">

            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        <i class="fas fa-chart-pie me-2 text-ai"></i>AI Portfolio Analyzer
                    </h1>
                    <p class="page-subtitle">Deep-dive AI analysis of your portfolio health</p>
                </div>
                <a href="<%= request.getContextPath() %>/AIServlet?action=portfolio-analyzer"
                   class="btn-ai-custom">
                    <i class="fas fa-sync-alt me-2"></i>Re-analyze
                </a>
            </div>

            <div class="ai-banner">
                <div class="ai-banner-icon"><i class="fas fa-chart-pie"></i></div>
                <div class="ai-banner-content">
                    <strong>Portfolio Analysis Complete</strong>
                    <span><%= report.getActiveCount() %> active investment(s) across
                          <%= report.getSectorAllocation().size() %> asset class(es) analysed</span>
                </div>
                <span class="ai-banner-badge">AI</span>
            </div>

            <!-- ROW 1: Health Score + Key Metrics -->
            <div class="analyzer-top-grid">

                <!-- Health Score Circle -->
                <div class="card-panel health-score-card">
                    <h4 class="card-panel-title">Portfolio Health Score</h4>
                    <div class="health-circle-wrap">
                        <div class="health-circle"
                             style="--score:<%= report.getHealthScore() %>;
                                    --color:<%= report.getHealthColor() %>">
                            <svg class="health-svg" viewBox="0 0 120 120">
                                <circle cx="60" cy="60" r="50"
                                        fill="none" stroke="#1e293b" stroke-width="12"/>
                                <circle cx="60" cy="60" r="50"
                                        fill="none"
                                        stroke="<%= report.getHealthColor() %>"
                                        stroke-width="12"
                                        stroke-dasharray="<%= (int)(3.14159 * 100 * report.getHealthScore() / 100) %> 314"
                                        stroke-dashoffset="78"
                                        stroke-linecap="round"
                                        transform="rotate(-90 60 60)"/>
                            </svg>
                            <div class="health-score-inner">
                                <span class="health-score-num"
                                      style="color:<%= report.getHealthColor() %>">
                                    <%= report.getHealthScore() %>
                                </span>
                                <span class="health-score-label"><%= report.getHealthLabel() %></span>
                            </div>
                        </div>
                    </div>
                    <p class="health-summary"><%= report.getSummary() %></p>
                </div>

                <!-- Key Metrics Grid -->
                <div class="metrics-grid-2x2">
                    <div class="metric-card metric-blue">
                        <div class="metric-icon"><i class="fas fa-coins"></i></div>
                        <div class="metric-body">
                            <span class="metric-label">Total Invested</span>
                            <span class="metric-value">$<%= String.format("%,.2f", report.getTotalInvested()) %></span>
                        </div>
                    </div>
                    <div class="metric-card metric-green">
                        <div class="metric-icon"><i class="fas fa-chart-line"></i></div>
                        <div class="metric-body">
                            <span class="metric-label">Current Value</span>
                            <span class="metric-value">$<%= String.format("%,.2f", report.getTotalCurrentValue()) %></span>
                        </div>
                    </div>
                    <div class="metric-card <%= overallPositive ? "metric-teal" : "metric-red" %>">
                        <div class="metric-icon">
                            <i class="fas fa-percentage"></i>
                        </div>
                        <div class="metric-body">
                            <span class="metric-label">Overall Return</span>
                            <span class="metric-value <%= overallPositive ? "text-profit" : "text-loss" %>">
                                <%= overallPositive ? "+" : "" %><%= String.format("%.2f", report.getOverallReturn()) %>%
                            </span>
                        </div>
                    </div>
                    <div class="metric-card metric-purple">
                        <div class="metric-icon"><i class="fas fa-layer-group"></i></div>
                        <div class="metric-body">
                            <span class="metric-label">Asset Classes</span>
                            <span class="metric-value"><%= report.getSectorAllocation().size() %></span>
                        </div>
                    </div>
                </div>

            </div><!-- /analyzer-top-grid -->

            <!-- ROW 2: Sector Chart + Best/Worst Performers -->
            <div class="charts-grid">
                <div class="chart-card chart-large">
                    <div class="chart-header">
                        <div>
                            <h3 class="chart-title">Sector Allocation</h3>
                            <p class="chart-subtitle">Distribution by asset type</p>
                        </div>
                    </div>
                    <% if (report.getSectorAllocation().isEmpty()) { %>
                    <div class="empty-state-sm"><i class="fas fa-chart-pie"></i><p>No data</p></div>
                    <% } else { %>
                    <div class="chart-container">
                        <canvas id="sectorChart"></canvas>
                    </div>
                    <% } %>
                </div>

                <div class="chart-card chart-small">
                    <div class="chart-header">
                        <h3 class="chart-title">Top &amp; Bottom Performers</h3>
                    </div>
                    <% if (report.getBestPerformer() != null) { %>
                    <div class="performer-card performer-best">
                        <div class="performer-icon green"><i class="fas fa-trophy"></i></div>
                        <div class="performer-info">
                            <span class="performer-label">Best Performer</span>
                            <span class="performer-name"><%= report.getBestPerformer().getPlanName() %></span>
                            <span class="performer-asset"><%= report.getBestPerformer().getAssetName() %></span>
                        </div>
                        <span class="performer-return return-pos">
                            +<%= String.format("%.1f", report.getBestReturn()) %>%
                        </span>
                    </div>
                    <% } %>
                    <% if (report.getWorstPerformer() != null) { %>
                    <div class="performer-card performer-worst">
                        <div class="performer-icon red"><i class="fas fa-arrow-down"></i></div>
                        <div class="performer-info">
                            <span class="performer-label">Worst Performer</span>
                            <span class="performer-name"><%= report.getWorstPerformer().getPlanName() %></span>
                            <span class="performer-asset"><%= report.getWorstPerformer().getAssetName() %></span>
                        </div>
                        <span class="performer-return return-neg">
                            <%= String.format("%.1f", report.getWorstReturn()) %>%
                        </span>
                    </div>
                    <% } %>

                    <!-- Sector breakdown mini table -->
                    <div class="sector-mini-list mt-3">
                        <% for (Map.Entry<String, String> e : report.getSectorPct().entrySet()) { %>
                        <div class="sector-mini-row">
                            <span class="sector-mini-name"><%= e.getKey() %></span>
                            <div class="sector-mini-bar">
                                <div class="sector-mini-fill"
                                     style="width:<%= e.getValue() %>%"></div>
                            </div>
                            <span class="sector-mini-pct"><%= e.getValue() %>%</span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- ROW 3: AI Suggestions -->
            <div class="card-panel">
                <div class="ai-suggestions-header">
                    <div class="ai-suggestions-icon"><i class="fas fa-lightbulb"></i></div>
                    <div>
                        <h4>AI Improvement Suggestions</h4>
                        <p class="text-muted">Based on your current portfolio structure</p>
                    </div>
                </div>
                <div class="suggestions-list">
                    <% int sIdx = 1; for (String suggestion : report.getSuggestions()) { %>
                    <div class="suggestion-item">
                        <div class="suggestion-num"><%= sIdx++ %></div>
                        <div class="suggestion-text">
                            <i class="fas fa-arrow-right me-2 text-ai"></i><%= suggestion %>
                        </div>
                    </div>
                    <% } %>
                </div>
                <div class="mt-3">
                    <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
                       class="btn-ai-custom">
                        <i class="fas fa-robot me-2"></i>Get Full AI Recommendations
                    </a>
                </div>
            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
<% if (!report.getSectorAllocation().isEmpty()) { %>
const sCtx = document.getElementById('sectorChart').getContext('2d');
new Chart(sCtx, {
    type: 'bar',
    data: {
        labels: [<%= sLabels %>],
        datasets: [{
            label: 'Portfolio Value ($)',
            data:  [<%= sValues %>],
            backgroundColor: [<%= sColors %>],
            borderRadius: 8, borderSkipped: false
        }]
    },
    options: {
        responsive: true, maintainAspectRatio: false, indexAxis: 'y',
        plugins: {
            legend: { display: false },
            tooltip: {
                backgroundColor: '#1a1a2e',
                callbacks: { label: ctx => ' $' + parseFloat(ctx.raw).toLocaleString('en-US', {minimumFractionDigits:2}) }
            }
        },
        scales: {
            x: { ticks: { color: '#888', callback: v => '$' + v.toLocaleString() }, grid: { color: 'rgba(255,255,255,0.05)' } },
            y: { ticks: { color: '#ccc', font: { size: 12 } }, grid: { display: false } }
        }
    }
});
<% } %>
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
