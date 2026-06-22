<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);

    @SuppressWarnings("unchecked")
    List<Portfolio> portfolios = (List<Portfolio>) request.getAttribute("portfolios");
    @SuppressWarnings("unchecked")
    List<Asset> assets = (List<Asset>) request.getAttribute("assets");

    if (portfolios == null) portfolios = new PortfolioDAO().findByUser(uid);
    if (assets     == null) assets     = new AssetDAO().findAll();

    BigDecimal walletBal = new TransactionDAO().getWalletBalance(uid);
    String error         = (String) request.getAttribute("error");
    String prePortfolio  = request.getParameter("portfolioId");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>New Investment — InvestMS</title>
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
                    <h1 class="page-title">New Investment</h1>
                    <p class="page-subtitle">Add a new investment to your portfolio</p>
                </div>
                <a href="<%= request.getContextPath() %>/InvestmentServlet"
                   class="btn-secondary-custom">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </a>
            </div>

            <!-- Wallet Balance Banner -->
            <div class="wallet-banner">
                <i class="fas fa-wallet me-2"></i>
                Available Balance: <strong>$<%= String.format("%,.2f", walletBal) %></strong>
                <a href="<%= request.getContextPath() %>/transaction/deposit.jsp"
                   class="wallet-deposit-link">
                    <i class="fas fa-plus-circle me-1"></i>Deposit Funds
                </a>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div>
            <% } %>

            <% if (portfolios.isEmpty()) { %>
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle me-2"></i>
                You need a portfolio first.
                <a href="<%= request.getContextPath() %>/portfolio/add-portfolio.jsp">Create one →</a>
            </div>
            <% } else { %>
            <div class="two-col-layout">

                <!-- Form -->
                <div class="form-card">
                    <form action="<%= request.getContextPath() %>/InvestmentServlet"
                          method="POST" class="main-form" id="investForm">

                        <div class="form-group-custom">
                            <label class="form-label-custom">Plan Name *</label>
                            <div class="input-wrapper">
                                <i class="fas fa-tag input-icon"></i>
                                <input type="text" name="planName" class="form-input"
                                       placeholder="e.g. Long-term Apple Buy" required maxlength="150">
                            </div>
                        </div>

                        <div class="form-row-two">
                            <div class="form-group-custom">
                                <label class="form-label-custom">Portfolio *</label>
                                <select name="portfolioId" class="form-select-custom" required>
                                    <option value="">Select Portfolio</option>
                                    <% for (Portfolio p : portfolios) { %>
                                    <option value="<%= p.getPortfolioId() %>"
                                        <%= (prePortfolio != null && prePortfolio.equals(String.valueOf(p.getPortfolioId()))) ? "selected" : "" %>>
                                        <%= p.getPortfolioName() %> (<%= p.getRiskLevel() %>)
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-group-custom">
                                <label class="form-label-custom">Asset *</label>
                                <select name="assetId" class="form-select-custom" id="assetSelect"
                                        required onchange="updateAssetInfo(this)">
                                    <option value="">Select Asset</option>
                                    <% for (Asset a : assets) { %>
                                    <option value="<%= a.getAssetId() %>"
                                            data-type="<%= a.getAssetType() %>"
                                            data-risk="<%= a.getRiskRating() %>"
                                            data-symbol="<%= a.getSymbol() %>">
                                        <%= a.getAssetName() %> (<%= a.getSymbol() %>) — <%= a.getAssetType() %>
                                    </option>
                                    <% } %>
                                </select>
                            </div>
                        </div>

                        <!-- Asset Info Panel (dynamic) -->
                        <div class="asset-info-panel" id="assetInfoPanel" style="display:none;">
                            <div class="asset-info-row">
                                <span>Type: <strong id="assetTypeDisplay">-</strong></span>
                                <span>Risk Rating: <strong id="assetRiskDisplay">-</strong>/10</span>
                                <span>Symbol: <strong id="assetSymbolDisplay">-</strong></span>
                            </div>
                        </div>

                        <div class="form-row-two">
                            <div class="form-group-custom">
                                <label class="form-label-custom">Investment Amount ($) *</label>
                                <div class="input-wrapper">
                                    <i class="fas fa-dollar-sign input-icon"></i>
                                    <input type="number" name="investedAmount" id="investedAmount"
                                           class="form-input" placeholder="0.00"
                                           min="1" step="0.01" required
                                           oninput="calculateUnits()">
                                </div>
                                <small class="input-hint">Max: $<%= String.format("%,.2f", walletBal) %></small>
                            </div>
                            <div class="form-group-custom">
                                <label class="form-label-custom">Buy Price per Unit ($) *</label>
                                <div class="input-wrapper">
                                    <i class="fas fa-tag input-icon"></i>
                                    <input type="number" name="buyPrice" id="buyPrice"
                                           class="form-input" placeholder="0.00"
                                           min="0.0001" step="0.0001" required
                                           oninput="calculateUnits()">
                                </div>
                            </div>
                        </div>

                        <!-- Calculated units display -->
                        <div class="calc-units-banner" id="calcUnitsBanner" style="display:none;">
                            <i class="fas fa-calculator me-2"></i>
                            You will receive <strong id="calcUnits">0</strong> units
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Notes</label>
                            <textarea name="notes" class="form-textarea"
                                      placeholder="Investment notes or strategy..." rows="2"></textarea>
                        </div>

                        <div class="form-actions">
                            <a href="<%= request.getContextPath() %>/InvestmentServlet"
                               class="btn-secondary-custom">Cancel</a>
                            <button type="submit" class="btn-primary-custom">
                                <i class="fas fa-coins me-2"></i>Invest Now
                            </button>
                        </div>
                    </form>
                </div>

                <!-- Asset Sidebar Info -->
                <div class="asset-sidebar">
                    <div class="card-panel">
                        <h4 class="card-panel-title">Available Assets</h4>
                        <% for (Asset a : assets) { %>
                        <div class="asset-list-item">
                            <div class="asset-symbol-badge">
                                <%= a.getSymbol() %>
                            </div>
                            <div class="asset-list-info">
                                <span class="asset-list-name"><%= a.getAssetName() %></span>
                                <span class="asset-list-type"><%= a.getAssetType() %></span>
                            </div>
                            <div class="asset-list-risk">
                                <span class="risk-dot risk-<%= a.getRiskRating() <= 3 ? "low" : a.getRiskRating() <= 6 ? "medium" : "high" %>"></span>
                                <span class="risk-score"><%= a.getRiskRating() %>/10</span>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>

            </div>
            <% } %>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>
<script>
function updateAssetInfo(select) {
    const opt = select.options[select.selectedIndex];
    if (opt.value) {
        document.getElementById('assetTypeDisplay').textContent   = opt.dataset.type;
        document.getElementById('assetRiskDisplay').textContent   = opt.dataset.risk;
        document.getElementById('assetSymbolDisplay').textContent = opt.dataset.symbol;
        document.getElementById('assetInfoPanel').style.display = 'block';
    } else {
        document.getElementById('assetInfoPanel').style.display = 'none';
    }
}
function calculateUnits() {
    const amount = parseFloat(document.getElementById('investedAmount').value) || 0;
    const price  = parseFloat(document.getElementById('buyPrice').value) || 0;
    const banner = document.getElementById('calcUnitsBanner');
    if (amount > 0 && price > 0) {
        const units = (amount / price).toFixed(6);
        document.getElementById('calcUnits').textContent = units;
        banner.style.display = 'flex';
    } else {
        banner.style.display = 'none';
    }
}
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
