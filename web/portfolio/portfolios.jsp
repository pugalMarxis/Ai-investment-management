<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.Portfolio" %>
<%@ page import="com.investms.dao.PortfolioDAO" %>
<%@ page import="java.util.*" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);
    @SuppressWarnings("unchecked")
    List<Portfolio> portfolios = (List<Portfolio>) request.getAttribute("portfolios");
    if (portfolios == null) {
        portfolios = new PortfolioDAO().findByUser(uid);
    }
    boolean created = "true".equals(request.getParameter("created"));
    boolean updated = "true".equals(request.getParameter("updated"));
    boolean deleted = "true".equals(request.getParameter("deleted"));

    // Totals
    double sumInvested = 0, sumValue = 0, sumPL = 0;
    for (Portfolio p : portfolios) {
        sumInvested += p.getTotalInvested().doubleValue();
        sumValue    += p.getTotalCurrentValue().doubleValue();
        sumPL       += p.getTotalProfitLoss().doubleValue();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Portfolios — InvestMS</title>
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
                    <h1 class="page-title">My Portfolios</h1>
                    <p class="page-subtitle">Manage your investment portfolios</p>
                </div>
                <a href="<%= request.getContextPath() %>/portfolio/add-portfolio.jsp"
                   class="btn-primary-custom">
                    <i class="fas fa-plus me-2"></i>New Portfolio
                </a>
            </div>

            <!-- Alerts -->
            <% if (created) { %><div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>Portfolio created successfully!</div><% } %>
            <% if (updated) { %><div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>Portfolio updated successfully!</div><% } %>
            <% if (deleted) { %><div class="alert alert-warning"><i class="fas fa-trash me-2"></i>Portfolio deleted.</div><% } %>

            <!-- Summary Cards -->
            <div class="metrics-grid-3">
                <div class="metric-card metric-blue">
                    <div class="metric-icon"><i class="fas fa-coins"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total Invested</span>
                        <span class="metric-value">$<%= String.format("%,.2f", sumInvested) %></span>
                    </div>
                </div>
                <div class="metric-card metric-green">
                    <div class="metric-icon"><i class="fas fa-chart-line"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Current Value</span>
                        <span class="metric-value">$<%= String.format("%,.2f", sumValue) %></span>
                    </div>
                </div>
                <div class="metric-card <%= sumPL >= 0 ? "metric-teal" : "metric-red" %>">
                    <div class="metric-icon"><i class="fas fa-percentage"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total P&L</span>
                        <span class="metric-value <%= sumPL >= 0 ? "text-profit" : "text-loss" %>">
                            <%= sumPL >= 0 ? "+" : "" %>$<%= String.format("%,.2f", Math.abs(sumPL)) %>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Portfolio Cards Grid -->
            <% if (portfolios.isEmpty()) { %>
            <div class="empty-state-full">
                <div class="empty-icon"><i class="fas fa-briefcase"></i></div>
                <h3>No Portfolios Yet</h3>
                <p>Create your first portfolio to start tracking your investments.</p>
                <a href="<%= request.getContextPath() %>/portfolio/add-portfolio.jsp"
                   class="btn-primary-custom">
                    <i class="fas fa-plus me-2"></i>Create Portfolio
                </a>
            </div>
            <% } else { %>
            <div class="portfolio-cards-grid">
                <% for (Portfolio p : portfolios) {
                    boolean pp = p.isProfitable();
                    double progPct = p.getTargetAmount().doubleValue() > 0
                        ? Math.min(100, (p.getTotalCurrentValue().doubleValue() / p.getTargetAmount().doubleValue()) * 100)
                        : 0;
                %>
                <div class="portfolio-card">
                    <!-- Card Header -->
                    <div class="portfolio-card-header">
                        <div class="portfolio-card-title-row">
                            <div class="portfolio-card-avatar">
                                <%= p.getPortfolioName().substring(0,1).toUpperCase() %>
                            </div>
                            <div>
                                <h4 class="portfolio-card-name"><%= p.getPortfolioName() %></h4>
                                <span class="badge <%= p.getRiskBadgeClass() %> badge-sm">
                                    <i class="fas fa-shield-alt me-1"></i><%= p.getRiskLevel() %> RISK
                                </span>
                            </div>
                        </div>
                        <span class="badge badge-status-<%= p.getStatus().toLowerCase() %>">
                            <%= p.getStatus() %>
                        </span>
                    </div>

                    <!-- Card Description -->
                    <% if (p.getDescription() != null && !p.getDescription().isEmpty()) { %>
                    <p class="portfolio-card-desc"><%= p.getDescription() %></p>
                    <% } %>

                    <!-- Stats Row -->
                    <div class="portfolio-stats-row">
                        <div class="portfolio-stat">
                            <span class="pstat-label">Invested</span>
                            <span class="pstat-value">$<%= String.format("%,.2f", p.getTotalInvested()) %></span>
                        </div>
                        <div class="portfolio-stat">
                            <span class="pstat-label">Value</span>
                            <span class="pstat-value">$<%= String.format("%,.2f", p.getTotalCurrentValue()) %></span>
                        </div>
                        <div class="portfolio-stat">
                            <span class="pstat-label">P&L</span>
                            <span class="pstat-value <%= pp ? "text-profit" : "text-loss" %>">
                                <%= pp ? "+" : "" %>$<%= String.format("%,.2f", p.getTotalProfitLoss().abs()) %>
                            </span>
                        </div>
                        <div class="portfolio-stat">
                            <span class="pstat-label">Return</span>
                            <span class="pstat-value badge-return-sm <%= pp ? "return-pos" : "return-neg" %>">
                                <%= pp ? "▲" : "▼" %> <%= p.getReturnPct().abs() %>%
                            </span>
                        </div>
                    </div>

                    <!-- Target Progress -->
                    <% if (p.getTargetAmount().doubleValue() > 0) { %>
                    <div class="progress-section">
                        <div class="progress-label-row">
                            <span>Target Progress</span>
                            <span><%= String.format("%.1f", progPct) %>%</span>
                        </div>
                        <div class="progress-bar-wrap">
                            <div class="progress-bar-fill <%= progPct >= 100 ? "fill-green" : "fill-blue" %>"
                                 style="width: <%= Math.min(100, progPct) %>%"></div>
                        </div>
                        <span class="progress-target">Target: $<%= String.format("%,.2f", p.getTargetAmount()) %></span>
                    </div>
                    <% } %>

                    <!-- Investments count -->
                    <div class="portfolio-inv-count">
                        <i class="fas fa-coins me-1"></i>
                        <%= p.getTotalInvestments() %> investment<%= p.getTotalInvestments() != 1 ? "s" : "" %>
                    </div>

                    <!-- Card Actions -->
                    <div class="portfolio-card-actions">
                        <a href="<%= request.getContextPath() %>/investment/investments.jsp?portfolioId=<%= p.getPortfolioId() %>"
                           class="btn-action-outline">
                            <i class="fas fa-eye me-1"></i>View
                        </a>
                        <a href="<%= request.getContextPath() %>/PortfolioServlet?action=edit&id=<%= p.getPortfolioId() %>"
                           class="btn-action-outline">
                            <i class="fas fa-edit me-1"></i>Edit
                        </a>
                        <a href="<%= request.getContextPath() %>/investment/add-investment.jsp?portfolioId=<%= p.getPortfolioId() %>"
                           class="btn-action-primary">
                            <i class="fas fa-plus me-1"></i>Invest
                        </a>
                        <button class="btn-action-danger"
                                onclick="confirmDelete(<%= p.getPortfolioId() %>, '<%= p.getPortfolioName() %>')">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<!-- Delete Confirm Modal -->
<div class="modal-overlay" id="deleteModal" style="display:none;">
    <div class="modal-box">
        <div class="modal-icon danger"><i class="fas fa-exclamation-triangle"></i></div>
        <h3 class="modal-title">Delete Portfolio?</h3>
        <p class="modal-msg">Are you sure you want to delete <strong id="delPortfolioName"></strong>?
            This will also remove all investments inside it.</p>
        <div class="modal-actions">
            <button class="btn-modal-cancel" onclick="closeModal()">Cancel</button>
            <a id="delConfirmLink" href="#" class="btn-modal-danger">Delete</a>
        </div>
    </div>
</div>

<script>
function confirmDelete(id, name) {
    document.getElementById('delPortfolioName').textContent = name;
    document.getElementById('delConfirmLink').href =
        '<%= request.getContextPath() %>/PortfolioServlet?action=delete&id=' + id;
    document.getElementById('deleteModal').style.display = 'flex';
}
function closeModal() {
    document.getElementById('deleteModal').style.display = 'none';
}
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
