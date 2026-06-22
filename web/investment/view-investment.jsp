<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.Investment" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    Investment vi = (Investment) request.getAttribute("investment");
    if (vi == null) {
        response.sendRedirect(request.getContextPath() + "/InvestmentServlet"); return;
    }
    boolean ip = vi.isProfitable();
    double plAmount = vi.getProfitLoss().doubleValue();
    double retPct   = vi.getReturnPct().doubleValue();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title><%= vi.getPlanName() %> — InvestMS</title>
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
                    <h1 class="page-title"><%= vi.getPlanName() %></h1>
                    <p class="page-subtitle">Investment Details</p>
                </div>
                <div class="page-header-actions">
                    <a href="<%= request.getContextPath() %>/InvestmentServlet"
                       class="btn-secondary-custom">
                        <i class="fas fa-arrow-left me-2"></i>Back
                    </a>
                    <% if ("ACTIVE".equals(vi.getStatus())) { %>
                    <a href="<%= request.getContextPath() %>/InvestmentServlet?action=sell&id=<%= vi.getInvestmentId() %>"
                       class="btn-danger-custom"
                       onclick="return confirm('Sell this investment?')">
                        <i class="fas fa-dollar-sign me-2"></i>Sell
                    </a>
                    <% } %>
                </div>
            </div>

            <div class="row">
                <!-- Left: Investment Details -->
                <div class="col-lg-8 mb-4">
                    <div class="card-panel">
                        <div class="inv-detail-header">
                            <div class="asset-symbol-large">
                                <%= vi.getAssetSymbol() != null ? vi.getAssetSymbol() : "?" %>
                            </div>
                            <div class="inv-detail-title">
                                <h2><%= vi.getPlanName() %></h2>
                                <p class="text-muted"><%= vi.getAssetName() %> &bull; <%= vi.getAssetType() %></p>
                                <span class="badge <%= vi.getStatusBadgeClass() %>"><%= vi.getStatus() %></span>
                            </div>
                        </div>

                        <!-- P&L Hero -->
                        <div class="pnl-hero <%= ip ? "pnl-positive" : "pnl-negative" %>">
                            <div class="pnl-label">Total Profit / Loss</div>
                            <div class="pnl-value">
                                <%= ip ? "+" : "" %>$<%= String.format("%,.2f", Math.abs(plAmount)) %>
                            </div>
                            <div class="pnl-pct">
                                <i class="fas fa-<%= ip ? "arrow-up" : "arrow-down" %>"></i>
                                <%= String.format("%.2f", Math.abs(retPct)) %>% return
                            </div>
                        </div>

                        <!-- Detail Grid -->
                        <div class="detail-grid">
                            <div class="detail-item">
                                <span class="detail-label">Invested Amount</span>
                                <span class="detail-value">$<%= String.format("%,.2f", vi.getInvestedAmount()) %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Current Value</span>
                                <span class="detail-value text-<%= ip ? "profit" : "loss" %>">
                                    $<%= String.format("%,.2f", vi.getCurrentValue()) %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Units Held</span>
                                <span class="detail-value"><%= vi.getUnits() %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Buy Price / Unit</span>
                                <span class="detail-value">$<%= String.format("%,.4f", vi.getBuyPrice()) %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Current Price / Unit</span>
                                <span class="detail-value">$<%= String.format("%,.4f", vi.getCurrentPrice()) %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Portfolio</span>
                                <span class="detail-value"><%= vi.getPortfolioName() %></span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Invested On</span>
                                <span class="detail-value">
                                    <%= vi.getInvestedAt() != null ? vi.getInvestedAt().toLocalDate() : "—" %>
                                </span>
                            </div>
                            <div class="detail-item">
                                <span class="detail-label">Last Updated</span>
                                <span class="detail-value">
                                    <%= vi.getUpdatedAt() != null ? vi.getUpdatedAt().toLocalDate() : "—" %>
                                </span>
                            </div>
                        </div>

                        <% if (vi.getNotes() != null && !vi.getNotes().isEmpty()) { %>
                        <div class="notes-section">
                            <h5>Notes</h5>
                            <p><%= vi.getNotes() %></p>
                        </div>
                        <% } %>
                    </div>
                </div>

                <!-- Right: Mini Chart + AI Suggestion -->
                <div class="col-lg-4 mb-4">
                    <div class="card-panel mb-3">
                        <h4 class="card-panel-title">Performance Gauge</h4>
                        <canvas id="gaugeChart" height="180"></canvas>
                    </div>
                    <div class="ai-suggestion-card">
                        <div class="ai-card-header">
                            <i class="fas fa-robot"></i>
                            <span>AI Suggestion</span>
                        </div>
                        <p class="ai-card-body">
                            <% if (retPct > 10) { %>
                            This investment is performing well (<%= String.format("%.2f", retPct) %>% return).
                            Consider holding or rebalancing for further growth.
                            <% } else if (retPct > 0) { %>
                            Moderate positive return. AI recommends monitoring market conditions.
                            <% } else { %>
                            This investment is currently at a loss. Review asset performance and
                            consider diversification strategy.
                            <% } %>
                        </p>
                        <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
                           class="btn-ai-sm">
                            <i class="fas fa-robot me-1"></i>Full AI Analysis
                        </a>
                    </div>
                </div>
            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>
<script>
// Mini bar chart
const gCtx = document.getElementById('gaugeChart').getContext('2d');
new Chart(gCtx, {
    type: 'bar',
    data: {
        labels: ['Invested', 'Current Value'],
        datasets: [{
            data: [<%= vi.getInvestedAmount() %>, <%= vi.getCurrentValue() %>],
            backgroundColor: ['#3b82f6', '<%= ip ? "#10b981" : "#ef4444" %>'],
            borderRadius: 8,
            borderSkipped: false
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display: false } },
        scales: {
            x: { ticks: { color: '#888' }, grid: { display: false } },
            y: {
                ticks: { color: '#888', callback: v => '$' + v.toLocaleString() },
                grid: { color: 'rgba(255,255,255,0.05)' }
            }
        }
    }
});
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
