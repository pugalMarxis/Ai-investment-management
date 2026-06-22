<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.ai.AIRiskAnalyzer" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);

    AIRiskAnalyzer.RiskReport riskReport =
        (AIRiskAnalyzer.RiskReport) request.getAttribute("riskReport");
    @SuppressWarnings("unchecked")
    List<Investment> investments = (List<Investment>) request.getAttribute("investments");

    if (riskReport == null) {
        InvestmentDAO iDao = new InvestmentDAO();
        PortfolioDAO  pDao = new PortfolioDAO();
        investments = iDao.findByUser(uid);
        List<Portfolio> portfolios = pDao.findByUser(uid);
        AIRiskAnalyzer analyzer = new AIRiskAnalyzer();
        riskReport = analyzer.analyzePortfolio(investments, portfolios);
    }
    if (investments == null) investments = new ArrayList<>();

    int score = riskReport.getOverallScore();
    // Gauge needle angle: score 0=−90deg, 100=+90deg → range 180deg
    int needleAngle = (int)(-90 + (score * 1.8));

    // Build alloc chart data
    StringBuilder allocLabels = new StringBuilder();
    StringBuilder allocValues = new StringBuilder();
    StringBuilder allocColors = new StringBuilder();
    String[] palette = {"'#e74c3c'","'#3b82f6'","'#10b981'","'#f59e0b'","'#8b5cf6'","'#06b6d4'","'#f97316'","'#64748b'"};
    int ci = 0;
    if (riskReport.getAllocationByType() != null) {
        for (Map.Entry<String, Double> e : riskReport.getAllocationByType().entrySet()) {
            if (allocLabels.length() > 0) { allocLabels.append(","); allocValues.append(","); allocColors.append(","); }
            allocLabels.append("'").append(e.getKey()).append("'");
            allocValues.append(String.format("%.2f", e.getValue()));
            allocColors.append(palette[ci % palette.length]);
            ci++;
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>AI Risk Analyzer — InvestMS</title>
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
                        <i class="fas fa-shield-alt me-2 text-ai"></i>AI Risk Analyzer
                    </h1>
                    <p class="page-subtitle">Comprehensive portfolio risk assessment</p>
                </div>
                <a href="<%= request.getContextPath() %>/AIServlet?action=risk"
                   class="btn-ai-custom">
                    <i class="fas fa-sync-alt me-2"></i>Re-analyze
                </a>
            </div>

            <div class="ai-banner">
                <div class="ai-banner-icon"><i class="fas fa-shield-alt"></i></div>
                <div class="ai-banner-content">
                    <strong>Risk Analysis Complete</strong>
                    <span>Analysed <%= investments.size() %> investment(s) —
                          composite risk score calculated across 4 metrics</span>
                </div>
                <span class="ai-banner-badge">AI</span>
            </div>

            <!-- ROW 1: Risk Gauge + Score Breakdown -->
            <div class="risk-layout-top">

                <!-- Risk Gauge -->
                <div class="card-panel risk-gauge-card">
                    <h4 class="card-panel-title">Overall Risk Score</h4>
                    <div class="gauge-container">
                        <div class="gauge-arc">
                            <svg viewBox="0 0 200 110" class="gauge-svg">
                                <!-- Background arc -->
                                <path d="M 15 100 A 85 85 0 0 1 185 100"
                                      fill="none" stroke="#1e293b" stroke-width="18" stroke-linecap="round"/>
                                <!-- Colored arc segments -->
                                <path d="M 15 100 A 85 85 0 0 1 57 26"
                                      fill="none" stroke="#10b981" stroke-width="18" stroke-linecap="butt"/>
                                <path d="M 57 26 A 85 85 0 0 1 100 15"
                                      fill="none" stroke="#3b82f6" stroke-width="18" stroke-linecap="butt"/>
                                <path d="M 100 15 A 85 85 0 0 1 143 26"
                                      fill="none" stroke="#f59e0b" stroke-width="18" stroke-linecap="butt"/>
                                <path d="M 143 26 A 85 85 0 0 1 185 100"
                                      fill="none" stroke="#ef4444" stroke-width="18" stroke-linecap="butt"/>
                                <!-- Needle -->
                                <line x1="100" y1="100"
                                      x2="<%= (int)(100 + 70 * Math.cos(Math.toRadians(needleAngle))) %>"
                                      y2="<%= (int)(100 - 70 * Math.sin(Math.toRadians(-needleAngle + 180))) %>"
                                      stroke="<%= riskReport.getGaugeColor() %>"
                                      stroke-width="3" stroke-linecap="round"/>
                                <circle cx="100" cy="100" r="6"
                                        fill="<%= riskReport.getGaugeColor() %>"/>
                            </svg>
                        </div>
                        <div class="gauge-score-display">
                            <span class="gauge-number" style="color:<%= riskReport.getGaugeColor() %>">
                                <%= score %>
                            </span>
                            <span class="gauge-max">/ 100</span>
                        </div>
                        <div class="gauge-label">
                            <span class="<%= riskReport.getRiskBadgeClass() %> risk-level-badge">
                                <%= riskReport.getRiskLabel() %> RISK
                            </span>
                        </div>
                    </div>
                    <p class="risk-message"><%= riskReport.getMessage() %></p>
                </div>

                <!-- Score Breakdown -->
                <div class="card-panel risk-breakdown-card">
                    <h4 class="card-panel-title">Score Breakdown</h4>
                    <div class="score-components">

                        <div class="score-component">
                            <div class="sc-header">
                                <span class="sc-label">
                                    <i class="fas fa-chart-bar me-2 text-blue"></i>
                                    Weighted Asset Risk
                                </span>
                                <span class="sc-value">+<%= riskReport.getWeightedAssetRisk() %></span>
                            </div>
                            <div class="sc-bar-track">
                                <div class="sc-bar-fill fill-blue"
                                     style="width:<%= Math.min(100, riskReport.getWeightedAssetRisk()) %>%"></div>
                            </div>
                            <span class="sc-hint">Based on asset type risk ratings</span>
                        </div>

                        <div class="score-component">
                            <div class="sc-header">
                                <span class="sc-label">
                                    <i class="fas fa-compress-arrows-alt me-2 text-orange"></i>
                                    Concentration Penalty
                                </span>
                                <span class="sc-value sc-negative">+<%= riskReport.getConcentrationPenalty() %></span>
                            </div>
                            <div class="sc-bar-track">
                                <div class="sc-bar-fill fill-orange"
                                     style="width:<%= Math.min(100, riskReport.getConcentrationPenalty() * 5) %>%"></div>
                            </div>
                            <span class="sc-hint">Penalty for over-concentrated positions</span>
                        </div>

                        <div class="score-component">
                            <div class="sc-header">
                                <span class="sc-label">
                                    <i class="fas fa-arrow-down me-2 text-red"></i>
                                    P&L Drawdown Penalty
                                </span>
                                <span class="sc-value sc-negative">+<%= riskReport.getPlPenalty() %></span>
                            </div>
                            <div class="sc-bar-track">
                                <div class="sc-bar-fill fill-red"
                                     style="width:<%= Math.min(100, riskReport.getPlPenalty() * 5) %>%"></div>
                            </div>
                            <span class="sc-hint">Penalty for significant losing positions</span>
                        </div>

                        <div class="score-component">
                            <div class="sc-header">
                                <span class="sc-label">
                                    <i class="fas fa-th me-2 text-green"></i>
                                    Diversification Bonus
                                </span>
                                <span class="sc-value sc-positive">-<%= riskReport.getDiversityBonus() %></span>
                            </div>
                            <div class="sc-bar-track">
                                <div class="sc-bar-fill fill-green"
                                     style="width:<%= Math.min(100, riskReport.getDiversityBonus() * 10) %>%"></div>
                            </div>
                            <span class="sc-hint"><%= riskReport.getDistinctAssetTypes() %> distinct asset types detected</span>
                        </div>

                        <div class="score-total-row">
                            <span>Final Risk Score</span>
                            <span class="score-total-val" style="color:<%= riskReport.getGaugeColor() %>">
                                <%= score %>/100
                            </span>
                        </div>
                    </div>
                </div>

            </div><!-- /risk-layout-top -->

            <!-- ROW 2: Allocation Chart + Recommendation -->
            <div class="risk-layout-bottom">

                <!-- Allocation Doughnut -->
                <div class="card-panel">
                    <h4 class="card-panel-title">Portfolio Allocation by Asset Type</h4>
                    <% if (riskReport.getAllocationByType() == null || riskReport.getAllocationByType().isEmpty()) { %>
                    <div class="empty-state-sm">
                        <i class="fas fa-chart-pie"></i>
                        <p>No allocation data available</p>
                    </div>
                    <% } else { %>
                    <div style="height:260px; position:relative;">
                        <canvas id="allocChart"></canvas>
                    </div>
                    <!-- Allocation table -->
                    <table class="data-table mt-3">
                        <thead><tr><th>Asset Type</th><th>Value</th><th>Allocation</th><th>Risk Level</th></tr></thead>
                        <tbody>
                        <% for (Map.Entry<String, Double> e : riskReport.getAllocationByType().entrySet()) {
                            double pct = riskReport.getTotalValue() > 0
                                ? (e.getValue() / riskReport.getTotalValue()) * 100 : 0;
                            String rLvl = "CRYPTO".equals(e.getKey()) ? "HIGH"
                                : "BOND".equals(e.getKey()) ? "LOW"
                                : "STOCK".equals(e.getKey()) ? "MEDIUM" : "MEDIUM";
                        %>
                        <tr>
                            <td><strong><%= e.getKey() %></strong></td>
                            <td class="text-mono">$<%= String.format("%,.2f", e.getValue()) %></td>
                            <td>
                                <div class="mini-bar-wrap">
                                    <div class="mini-bar-fill" style="width:<%= String.format("%.0f", pct) %>%"></div>
                                    <span><%= String.format("%.1f", pct) %>%</span>
                                </div>
                            </td>
                            <td><span class="badge badge-risk-<%= rLvl.toLowerCase() %>"><%= rLvl %></span></td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                    <% } %>
                </div>

                <!-- AI Recommendation Panel -->
                <div class="card-panel ai-risk-rec-panel">
                    <div class="ai-rec-header">
                        <i class="fas fa-brain"></i>
                        <h4>AI Risk Recommendation</h4>
                    </div>
                    <div class="risk-level-display">
                        <span class="<%= riskReport.getRiskBadgeClass() %> risk-level-badge-lg">
                            <%= riskReport.getRiskLabel() %> RISK
                        </span>
                    </div>
                    <p class="ai-rec-text"><%= riskReport.getRecommendation() %></p>

                    <div class="risk-metrics-mini">
                        <div class="rmm-item">
                            <i class="fas fa-exclamation-triangle text-warning"></i>
                            <span><strong><%= riskReport.getLoserCount() %></strong> underperforming</span>
                        </div>
                        <div class="rmm-item">
                            <i class="fas fa-th text-blue"></i>
                            <span><strong><%= riskReport.getDistinctAssetTypes() %></strong> asset types</span>
                        </div>
                        <div class="rmm-item">
                            <i class="fas fa-coins text-green"></i>
                            <span><strong>$<%= String.format("%,.0f", riskReport.getTotalValue()) %></strong> total value</span>
                        </div>
                    </div>

                    <div class="ai-risk-actions">
                        <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
                           class="btn-ai-custom w-100 text-center">
                            <i class="fas fa-robot me-2"></i>Get AI Recommendations
                        </a>
                        <a href="<%= request.getContextPath() %>/ai/portfolio-analyzer.jsp"
                           class="btn-secondary-custom w-100 text-center mt-2">
                            <i class="fas fa-chart-pie me-2"></i>Full Portfolio Analysis
                        </a>
                    </div>
                </div>

            </div><!-- /risk-layout-bottom -->

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
<% if (riskReport.getAllocationByType() != null && !riskReport.getAllocationByType().isEmpty()) { %>
const allocCtx = document.getElementById('allocChart').getContext('2d');
new Chart(allocCtx, {
    type: 'doughnut',
    data: {
        labels: [<%= allocLabels %>],
        datasets: [{
            data:            [<%= allocValues %>],
            backgroundColor: [<%= allocColors %>],
            borderColor: '#0f172a', borderWidth: 3, hoverOffset: 8
        }]
    },
    options: {
        responsive: true, maintainAspectRatio: false, cutout: '65%',
        plugins: {
            legend: { position: 'bottom', labels: { color: '#ccc', padding: 14, font: { size: 11 } } },
            tooltip: {
                backgroundColor: '#1a1a2e',
                callbacks: { label: ctx => ' $' + parseFloat(ctx.raw).toLocaleString('en-US', {minimumFractionDigits:2}) }
            }
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
