<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.Investment" %>
<%@ page import="com.investms.dao.InvestmentDAO" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);

    @SuppressWarnings("unchecked")
    List<Investment> investments = (List<Investment>) request.getAttribute("investments");
    if (investments == null) {
        String pidStr = request.getParameter("portfolioId");
        InvestmentDAO iDao = new InvestmentDAO();
        if (pidStr != null && !pidStr.isEmpty()) {
            investments = iDao.findByPortfolio(Integer.parseInt(pidStr));
        } else {
            investments = iDao.findByUser(uid);
        }
    }

    boolean created = "true".equals(request.getParameter("created"));
    boolean sold    = "true".equals(request.getParameter("sold"));

    BigDecimal totalInv = BigDecimal.ZERO, totalVal = BigDecimal.ZERO;
    for (Investment i : investments) {
        if ("ACTIVE".equals(i.getStatus())) {
            totalInv = totalInv.add(i.getInvestedAmount());
            totalVal = totalVal.add(i.getCurrentValue());
        }
    }
    BigDecimal totalPL = totalVal.subtract(totalInv);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Investments — InvestMS</title>
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
                    <h1 class="page-title">Investments</h1>
                    <p class="page-subtitle"><%= investments.size() %> investment<%= investments.size() != 1 ? "s" : "" %> found</p>
                </div>
                <a href="<%= request.getContextPath() %>/InvestmentServlet?action=add"
                   class="btn-primary-custom">
                    <i class="fas fa-plus me-2"></i>New Investment
                </a>
            </div>

            <% if (created) { %><div class="alert alert-success"><i class="fas fa-check-circle me-2"></i>Investment created successfully!</div><% } %>
            <% if (sold)    { %><div class="alert alert-info"><i class="fas fa-info-circle me-2"></i>Investment sold and proceeds credited to wallet.</div><% } %>

            <!-- Summary -->
            <div class="metrics-grid-3">
                <div class="metric-card metric-blue">
                    <div class="metric-icon"><i class="fas fa-coins"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total Invested</span>
                        <span class="metric-value">$<%= String.format("%,.2f", totalInv) %></span>
                    </div>
                </div>
                <div class="metric-card metric-green">
                    <div class="metric-icon"><i class="fas fa-chart-line"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Current Value</span>
                        <span class="metric-value">$<%= String.format("%,.2f", totalVal) %></span>
                    </div>
                </div>
                <div class="metric-card <%= totalPL.compareTo(BigDecimal.ZERO) >= 0 ? "metric-teal" : "metric-red" %>">
                    <div class="metric-icon"><i class="fas fa-percentage"></i></div>
                    <div class="metric-body">
                        <span class="metric-label">Total P&L</span>
                        <span class="metric-value <%= totalPL.compareTo(BigDecimal.ZERO) >= 0 ? "text-profit" : "text-loss" %>">
                            <%= totalPL.compareTo(BigDecimal.ZERO) >= 0 ? "+" : "" %>$<%= String.format("%,.2f", totalPL.abs()) %>
                        </span>
                    </div>
                </div>
            </div>

            <!-- Filter Tabs -->
            <div class="filter-tabs">
                <button class="filter-tab active" onclick="filterInvestments('ALL', this)">All</button>
                <button class="filter-tab" onclick="filterInvestments('ACTIVE', this)">Active</button>
                <button class="filter-tab" onclick="filterInvestments('SOLD', this)">Sold</button>
                <button class="filter-tab" onclick="filterInvestments('MATURED', this)">Matured</button>
            </div>

            <!-- Investments Table -->
            <div class="card-panel">
                <% if (investments.isEmpty()) { %>
                <div class="empty-state-full">
                    <div class="empty-icon"><i class="fas fa-coins"></i></div>
                    <h3>No Investments Yet</h3>
                    <p>Create a portfolio first, then add your investments.</p>
                    <a href="<%= request.getContextPath() %>/InvestmentServlet?action=add"
                       class="btn-primary-custom">
                        <i class="fas fa-plus me-2"></i>Add Investment
                    </a>
                </div>
                <% } else { %>
                <div class="table-responsive">
                    <table class="data-table" id="investmentTable">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Plan Name</th>
                                <th>Asset</th>
                                <th>Portfolio</th>
                                <th>Invested</th>
                                <th>Current Value</th>
                                <th>P&L</th>
                                <th>Return %</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% int rowNum = 1; for (Investment inv : investments) {
                            boolean ip = inv.isProfitable(); %>
                        <tr class="inv-row" data-status="<%= inv.getStatus() %>">
                            <td class="text-muted"><%= rowNum++ %></td>
                            <td>
                                <div class="table-name-cell">
                                    <div class="asset-type-badge <%= inv.getAssetType() != null ? inv.getAssetType().toLowerCase() : "" %>">
                                        <%= inv.getAssetSymbol() != null ? inv.getAssetSymbol() : "?" %>
                                    </div>
                                    <div>
                                        <span class="fw-600"><%= inv.getPlanName() %></span>
                                        <br><small class="text-muted"><%= inv.getAssetName() %></small>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-asset-type">
                                    <%= inv.getAssetType() %>
                                </span>
                            </td>
                            <td class="text-muted"><%= inv.getPortfolioName() %></td>
                            <td class="text-mono">$<%= String.format("%,.2f", inv.getInvestedAmount()) %></td>
                            <td class="text-mono">$<%= String.format("%,.2f", inv.getCurrentValue()) %></td>
                            <td class="text-mono <%= ip ? "text-profit" : "text-loss" %>">
                                <%= ip ? "+" : "" %>$<%= String.format("%,.2f", inv.getProfitLoss().abs()) %>
                            </td>
                            <td>
                                <span class="badge-return-sm <%= ip ? "return-pos" : "return-neg" %>">
                                    <%= ip ? "▲" : "▼" %> <%= inv.getReturnPct().abs() %>%
                                </span>
                            </td>
                            <td>
                                <span class="badge <%= inv.getStatusBadgeClass() %>">
                                    <%= inv.getStatus() %>
                                </span>
                            </td>
                            <td>
                                <div class="table-actions">
                                    <a href="<%= request.getContextPath() %>/InvestmentServlet?action=view&id=<%= inv.getInvestmentId() %>"
                                       class="btn-icon-blue" title="View">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                    <% if ("ACTIVE".equals(inv.getStatus())) { %>
                                    <button class="btn-icon-red"
                                            onclick="confirmSell(<%= inv.getInvestmentId() %>, '<%= inv.getPlanName() %>')"
                                            title="Sell">
                                        <i class="fas fa-dollar-sign"></i>
                                    </button>
                                    <% } %>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                </div>
                <% } %>
            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<!-- Sell Confirm Modal -->
<div class="modal-overlay" id="sellModal" style="display:none;">
    <div class="modal-box">
        <div class="modal-icon success"><i class="fas fa-dollar-sign"></i></div>
        <h3 class="modal-title">Sell Investment?</h3>
        <p class="modal-msg">Sell <strong id="sellInvName"></strong>? Proceeds will be credited to your wallet.</p>
        <div class="modal-actions">
            <button class="btn-modal-cancel" onclick="document.getElementById('sellModal').style.display='none'">Cancel</button>
            <a id="sellConfirmLink" href="#" class="btn-modal-success">Confirm Sell</a>
        </div>
    </div>
</div>

<script>
function filterInvestments(status, btn) {
    document.querySelectorAll('.filter-tab').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('.inv-row').forEach(row => {
        row.style.display = (status === 'ALL' || row.dataset.status === status) ? '' : 'none';
    });
}
function confirmSell(id, name) {
    document.getElementById('sellInvName').textContent = name;
    document.getElementById('sellConfirmLink').href =
        '<%= request.getContextPath() %>/InvestmentServlet?action=sell&id=' + id;
    document.getElementById('sellModal').style.display = 'flex';
}
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
