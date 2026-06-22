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
    double maxWithdraw = walletBalance.doubleValue();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Withdraw Funds — InvestMS</title>
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
                    <h1 class="page-title">Withdraw Funds</h1>
                    <p class="page-subtitle">Transfer money from your wallet</p>
                </div>
                <a href="<%= request.getContextPath() %>/TransactionServlet"
                   class="btn-secondary-custom">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </a>
            </div>

            <% if (error   != null) { %><div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div><% } %>
            <% if (success != null) { %><div class="alert alert-success"><i class="fas fa-check-circle me-2"></i><%= success %></div><% } %>

            <% if (maxWithdraw <= 0) { %>
            <div class="alert alert-warning">
                <i class="fas fa-exclamation-triangle me-2"></i>
                Your wallet balance is <strong>$0.00</strong>. Please
                <a href="<%= request.getContextPath() %>/TransactionServlet?action=deposit">deposit funds</a>
                before withdrawing.
            </div>
            <% } %>

            <div class="transaction-layout">

                <!-- Withdrawal Form -->
                <div class="form-card transaction-form-card">
                    <div class="form-card-header">
                        <div class="form-card-icon withdraw-icon"><i class="fas fa-arrow-up"></i></div>
                        <div>
                            <h3>Withdraw Funds</h3>
                            <p>Transfer your available balance to your bank</p>
                        </div>
                    </div>

                    <!-- Current Balance Display -->
                    <div class="balance-display">
                        <span class="balance-label">Available Balance</span>
                        <span class="balance-amount">$<%= String.format("%,.2f", walletBalance) %></span>
                    </div>

                    <form action="<%= request.getContextPath() %>/TransactionServlet"
                          method="POST" class="main-form" id="withdrawForm">
                        <input type="hidden" name="action" value="withdraw">

                        <!-- Quick Percentage Buttons -->
                        <div class="form-group-custom">
                            <label class="form-label-custom">Quick Select</label>
                            <div class="quick-amounts">
                                <button type="button" class="quick-amount-btn"
                                        onclick="setPct(25)">25%</button>
                                <button type="button" class="quick-amount-btn"
                                        onclick="setPct(50)">50%</button>
                                <button type="button" class="quick-amount-btn"
                                        onclick="setPct(75)">75%</button>
                                <button type="button" class="quick-amount-btn"
                                        onclick="setPct(100)">Max</button>
                            </div>
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Withdrawal Amount ($) *</label>
                            <div class="input-wrapper input-large">
                                <i class="fas fa-dollar-sign input-icon"></i>
                                <input type="number"
                                       name="amount"
                                       id="withdrawAmount"
                                       class="form-input form-input-large"
                                       placeholder="0.00"
                                       min="1"
                                       max="<%= maxWithdraw %>"
                                       step="0.01"
                                       required
                                       oninput="updateWithdrawPreview()"
                                       <%= maxWithdraw <= 0 ? "disabled" : "" %>>
                            </div>
                            <small class="input-hint">
                                Max: $<%= String.format("%,.2f", walletBalance) %>
                            </small>
                        </div>

                        <!-- Preview -->
                        <div class="new-balance-preview" id="withdrawPreview" style="display:none;">
                            <div class="preview-row">
                                <span>Current Balance</span>
                                <span>$<%= String.format("%,.2f", walletBalance) %></span>
                            </div>
                            <div class="preview-row preview-deduct">
                                <span>- Withdrawal</span>
                                <span id="previewWithdrawAmt" class="text-loss">-$0.00</span>
                            </div>
                            <div class="preview-row preview-total">
                                <span><strong>Remaining Balance</strong></span>
                                <span id="previewRemaining" class="fw-700">
                                    $<%= String.format("%,.2f", walletBalance) %>
                                </span>
                            </div>
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Description (optional)</label>
                            <div class="input-wrapper">
                                <i class="fas fa-comment input-icon"></i>
                                <input type="text" name="description" class="form-input"
                                       placeholder="e.g. Bank withdrawal, Expense..."
                                       maxlength="255">
                            </div>
                        </div>

                        <div class="form-group-custom">
                            <label class="form-label-custom">Withdraw To</label>
                            <div class="payment-methods">
                                <label class="payment-option selected">
                                    <input type="radio" name="withdrawTo" value="BANK" checked>
                                    <i class="fas fa-university"></i>
                                    <span>Bank Account</span>
                                </label>
                                <label class="payment-option">
                                    <input type="radio" name="withdrawTo" value="PAYPAL">
                                    <i class="fab fa-paypal"></i>
                                    <span>PayPal</span>
                                </label>
                                <label class="payment-option">
                                    <input type="radio" name="withdrawTo" value="CRYPTO">
                                    <i class="fab fa-bitcoin"></i>
                                    <span>Crypto Wallet</span>
                                </label>
                            </div>
                        </div>

                        <button type="submit" class="btn-danger-full"
                                id="withdrawBtn" <%= maxWithdraw <= 0 ? "disabled" : "" %>>
                            <i class="fas fa-arrow-up me-2"></i>Withdraw Funds
                        </button>
                    </form>
                </div>

                <!-- Info Sidebar -->
                <div class="transaction-info-sidebar">
                    <div class="card-panel">
                        <h4 class="card-panel-title">
                            <i class="fas fa-info-circle me-2 text-blue"></i>Withdrawal Info
                        </h4>
                        <ul class="info-list">
                            <li><i class="fas fa-clock text-warning me-2"></i>Processing: 1–3 business days</li>
                            <li><i class="fas fa-check text-profit me-2"></i>No withdrawal fees</li>
                            <li><i class="fas fa-check text-profit me-2"></i>Minimum withdrawal: $1.00</li>
                            <li><i class="fas fa-check text-profit me-2"></i>Secure bank transfer</li>
                            <li><i class="fas fa-info-circle text-blue me-2"></i>Must have sufficient balance</li>
                        </ul>
                    </div>

                    <div class="card-panel mt-3">
                        <h4 class="card-panel-title">Balance Summary</h4>
                        <div class="quick-stats-list">
                            <div class="quick-stat-item">
                                <span>Available Balance</span>
                                <strong class="text-profit">$<%= String.format("%,.2f", walletBalance) %></strong>
                            </div>
                        </div>
                    </div>

                    <div class="ai-suggestion-card mt-3">
                        <div class="ai-card-header">
                            <i class="fas fa-robot"></i>
                            <span>AI Tip</span>
                        </div>
                        <p class="ai-card-body">
                            Keep at least 20% of your wallet as liquid reserve for new investment
                            opportunities and market dips.
                        </p>
                    </div>
                </div>

            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
const availableBalance = <%= maxWithdraw %>;

function setPct(pct) {
    const amount = (availableBalance * pct / 100).toFixed(2);
    document.getElementById('withdrawAmount').value = amount;
    updateWithdrawPreview();
    document.querySelectorAll('.quick-amount-btn').forEach(b => b.classList.remove('selected'));
    event.target.classList.add('selected');
}

function updateWithdrawPreview() {
    const input     = parseFloat(document.getElementById('withdrawAmount').value) || 0;
    const preview   = document.getElementById('withdrawPreview');
    const remaining = availableBalance - input;

    document.getElementById('previewWithdrawAmt').textContent = '-$' + input.toLocaleString('en-US', {minimumFractionDigits: 2});
    document.getElementById('previewRemaining').textContent   = '$' + Math.max(0, remaining).toLocaleString('en-US', {minimumFractionDigits: 2});

    const remEl = document.getElementById('previewRemaining');
    remEl.className = remaining < 0 ? 'fw-700 text-loss' : 'fw-700 text-profit';

    preview.style.display = input > 0 ? 'block' : 'none';
}

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
