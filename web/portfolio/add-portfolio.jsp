<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>New Portfolio — InvestMS</title>
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
                    <h1 class="page-title">Create Portfolio</h1>
                    <p class="page-subtitle">Set up a new investment portfolio</p>
                </div>
                <a href="<%= request.getContextPath() %>/PortfolioServlet"
                   class="btn-secondary-custom">
                    <i class="fas fa-arrow-left me-2"></i>Back
                </a>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-danger"><i class="fas fa-exclamation-circle me-2"></i><%= error %></div>
            <% } %>

            <div class="form-card">
                <div class="form-card-header">
                    <div class="form-card-icon"><i class="fas fa-briefcase"></i></div>
                    <div>
                        <h3>Portfolio Details</h3>
                        <p>Define your portfolio strategy and risk preference</p>
                    </div>
                </div>

                <form action="<%= request.getContextPath() %>/PortfolioServlet"
                      method="POST" class="main-form">
                    <input type="hidden" name="action" value="create">

                    <div class="form-row-two">
                        <div class="form-group-custom">
                            <label class="form-label-custom">Portfolio Name *</label>
                            <div class="input-wrapper">
                                <i class="fas fa-briefcase input-icon"></i>
                                <input type="text" name="portfolioName" class="form-input"
                                       placeholder="e.g. Growth Portfolio" required maxlength="150">
                            </div>
                        </div>
                        <div class="form-group-custom">
                            <label class="form-label-custom">Target Amount ($)</label>
                            <div class="input-wrapper">
                                <i class="fas fa-dollar-sign input-icon"></i>
                                <input type="number" name="targetAmount" class="form-input"
                                       placeholder="e.g. 50000" min="0" step="0.01">
                            </div>
                        </div>
                    </div>

                    <div class="form-group-custom">
                        <label class="form-label-custom">Description</label>
                        <textarea name="description" class="form-textarea"
                                  placeholder="Describe your portfolio strategy..." rows="3"></textarea>
                    </div>

                    <div class="form-group-custom">
                        <label class="form-label-custom">Risk Level *</label>
                        <div class="risk-selector">
                            <label class="risk-option risk-low">
                                <input type="radio" name="riskLevel" value="LOW">
                                <div class="risk-card">
                                    <i class="fas fa-shield-alt"></i>
                                    <strong>Low Risk</strong>
                                    <span>Bonds, ETFs, Stable assets</span>
                                    <span class="risk-return">4–8% annual return</span>
                                </div>
                            </label>
                            <label class="risk-option risk-medium">
                                <input type="radio" name="riskLevel" value="MEDIUM" checked>
                                <div class="risk-card">
                                    <i class="fas fa-balance-scale"></i>
                                    <strong>Medium Risk</strong>
                                    <span>Mixed stocks & bonds</span>
                                    <span class="risk-return">8–15% annual return</span>
                                </div>
                            </label>
                            <label class="risk-option risk-high">
                                <input type="radio" name="riskLevel" value="HIGH">
                                <div class="risk-card">
                                    <i class="fas fa-rocket"></i>
                                    <strong>High Risk</strong>
                                    <span>Stocks, Crypto, Growth</span>
                                    <span class="risk-return">15%+ annual return</span>
                                </div>
                            </label>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/PortfolioServlet"
                           class="btn-secondary-custom">Cancel</a>
                        <button type="submit" class="btn-primary-custom">
                            <i class="fas fa-plus me-2"></i>Create Portfolio
                        </button>
                    </div>
                </form>
            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>
<script>
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
