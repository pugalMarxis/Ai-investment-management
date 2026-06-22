<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.dao.TransactionDAO" %>
<%@ page import="java.math.BigDecimal" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);
    BigDecimal walletBalance = (BigDecimal) request.getAttribute("walletBalance");
    if (walletBalance == null) walletBalance = new TransactionDAO().getWalletBalance(uid);
    String error   = (String) request.getAttribute("error");
    String success = (String) request.getAttribute("success");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Deposit Funds — InvestMS</title>
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
                    <h1 class="page-title">Deposit Funds</h1>
                    <p class="page-subtitle">Add money to your investment wallet</p>
                </div>
                <a href="<%= request.getContextPath() %>/TransactionServlet"
                   class="btn-secondary-custom">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </a>
            </div>

            <% if (error   != null) { %><div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div><% } %>
            <% if (success != null) { %><div class="alert alert-success"><i class="fas fa-check-circle me-2"></i><%= success %></div><% } %>

            <div class="transaction-layout">

                <!-- Deposit Form -->
                <div class="form-card transaction-form-card">
                    <div class="form-card-header">
                        <div class="form-card-icon deposit-icon"><i class="fas fa-arrow-down"></i></div>
                        <div>
                            <h3>Add Funds</h3>
                            <p>Transfer money into your InvestMS wallet</p>
                        </div>
                    </div>

                    <!-- Current Balance Display -->
                    <div class="balance-display">
                        <span class="balance-label">Current Balance</span>
                        <span class="balance-amount">$<%= String.format("%,.2f", walletBalance) %></span>
                    </div>

                    <form action="<%= request.getContextPath() %>/TransactionServlet"
                          method="POST" class="main-form" id="depositForm">
                        <input type="hidden" name="action" value="deposit">

                        <!-- Quick Amount Buttons -->
                        <div class="form-group-custom">
                            <label class="form-label-custom">Quick Select Amount</label>
                            <div class="quick-amounts">
                                <% int[] quickAmounts = {100, 500, 1000, 5000, 10000, 25000}; %>
                                <% for (int qa : quickAmounts) { %>
                                <button type="button" class="quick-amount-btn"
                                        onclick="setAmount(<%= qa %>)">
                                    $<%= String.format("%,d", qa) %>
                                </button>
                                <% } %>
                            </div>
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Deposit Amount ($) *</label>
                            <div class="input-wrapper input-large">
                                <i class="fas fa-dollar-sign input-icon"></i>
                                <input type="number"
                                       name="amount"
                                       id="depositAmount"
                                       class="form-input form-input-large"
                                       placeholder="0.00"
                                       min="1"
                                       max="1000000"
                                       step="0.01"
                                       required
                                       oninput="updateNewBalance()">
                            </div>
                        </div>

                        <!-- New Balance Preview -->
                        <div class="new-balance-preview" id="newBalancePreview" style="display:none;">
                            <div class="preview-row">
                                <span>Current Balance</span>
                                <span>$<%= String.format("%,.2f", walletBalance) %></span>
                            </div>
                            <div class="preview-row preview-add">
                                <span>+ Deposit</span>
                                <span id="previewAmount" class="text-profit">+$0.00</span>
                            </div>
                            <div class="preview-row preview-total">
                                <span><strong>New Balance</strong></span>
                                <span id="previewNewBalance" class="text-profit fw-700">
                                    $<%= String.format("%,.2f", walletBalance) %>
                                </span>
                            </div>
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Description (optional)</label>
                            <div class="input-wrapper">
                                <i class="fas fa-comment input-icon"></i>
                                <input type="text" name="description" class="form-input"
                                       placeholder="e.g. Bank transfer, Salary deposit..."
                                       maxlength="255">
                            </div>
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Payment Method</label>
                            <div class="payment-methods">
                                <label class="payment-option selected" id="pm-bank">
                                    <input type="radio" name="paymentMethod" value="BANK" checked>
                                    <i class="fas fa-university"></i>
                                    <span>Bank Transfer</span>
                                </label>
                                <label class="payment-option" id="pm-card">
                                    <input type="radio" name="paymentMethod" value="CARD">
                                    <i class="fas fa-credit-card"></i>
                                    <span>Credit / Debit</span>
                                </label>
                                <label class="payment-option" id="pm-crypto">
                                    <input type="radio" name="paymentMethod" value="CRYPTO">
                                    <i class="fab fa-bitcoin"></i>
                                    <span>Crypto</span>
                                </label>
                            </div>
                        </div>

                        <button type="submit" class="btn-success-full" id="depositBtn">
                            <i class="fas fa-arrow-down me-2"></i>
                            Deposit Funds
                        </button>
                    </form>
                </div>

                <!-- Info Sidebar -->
                <div class="transaction-info-sidebar">
                    <div class="card-panel">
                        <h4 class="card-panel-title">
                            <i class="fas fa-info-circle me-2 text-blue"></i>Deposit Info
                        </h4>
                        <ul class="info-list">
                            <li><i class="fas fa-check text-profit me-2"></i>Instant wallet credit</li>
                            <li><i class="fas fa-check text-profit me-2"></i>No deposit fees</li>
                            <li><i class="fas fa-check text-profit me-2"></i>Maximum $1,000,000 per deposit</li>
                            <li><i class="fas fa-check text-profit me-2"></i>Secure &amp; encrypted</li>
                            <li><i class="fas fa-check text-profit me-2"></i>Full transaction history</li>
                        </ul>
                    </div>

                    <div class="card-panel mt-3">
                        <h4 class="card-panel-title">
                            <i class="fas fa-chart-bar me-2 text-blue"></i>Quick Stats
                        </h4>
                        <div class="quick-stats-list">
                            <div class="quick-stat-item">
                                <span>Wallet Balance</span>
                                <strong>$<%= String.format("%,.2f", walletBalance) %></strong>
                            </div>
                        </div>
                    </div>

                    <div class="ai-suggestion-card mt-3">
                        <div class="ai-card-header">
                            <i class="fas fa-robot"></i>
                            <span>AI Tip</span>
                        </div>
                        <p class="ai-card-body">
                            Deposit consistently each month to take advantage of dollar-cost averaging
                            and reduce market timing risk.
                        </p>
                    </div>
                </div>

            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
const currentBalance = <%= walletBalance %>;

function setAmount(amount) {
    document.getElementById('depositAmount').value = amount;
    updateNewBalance();
    // Highlight selected quick button
    document.querySelectorAll('.quick-amount-btn').forEach(b => b.classList.remove('selected'));
    event.target.classList.add('selected');
}

function updateNewBalance() {
    const input   = parseFloat(document.getElementById('depositAmount').value) || 0;
    const preview = document.getElementById('newBalancePreview');
    const newBal  = currentBalance + input;
    document.getElementById('previewAmount').textContent     = '+$' + input.toLocaleString('en-US', {minimumFractionDigits: 2});
    document.getElementById('previewNewBalance').textContent = '$' + newBal.toLocaleString('en-US', {minimumFractionDigits: 2});
    preview.style.display = input > 0 ? 'block' : 'none';
}

// Payment method selection style
document.querySelectorAll('.payment-option').forEach(opt => {
    opt.addEventListener('click', function () {
        document.querySelectorAll('.payment-option').forEach(o => o.classList.remove('selected'));
        this.classList.add('selected');
    });
});

document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
