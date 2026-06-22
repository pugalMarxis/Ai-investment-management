<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.Portfolio" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    Portfolio ep = (Portfolio) request.getAttribute("portfolio");
    if (ep == null) {
        response.sendRedirect(request.getContextPath() + "/PortfolioServlet"); return;
    }
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Edit Portfolio — InvestMS</title>
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
                    <h1 class="page-title">Edit Portfolio</h1>
                    <p class="page-subtitle"><%= ep.getPortfolioName() %></p>
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
                <form action="<%= request.getContextPath() %>/PortfolioServlet"
                      method="POST" class="main-form">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="portfolioId" value="<%= ep.getPortfolioId() %>">

                    <div class="form-row-two">
                        <div class="form-group-custom">
                            <label class="form-label-custom">Portfolio Name *</label>
                            <div class="input-wrapper">
                                <i class="fas fa-briefcase input-icon"></i>
                                <input type="text" name="portfolioName" class="form-input"
                                       value="<%= ep.getPortfolioName() %>" required maxlength="150">
                            </div>
                        </div>
                        <div class="form-group-custom">
                            <label class="form-label-custom">Target Amount ($)</label>
                            <div class="input-wrapper">
                                <i class="fas fa-dollar-sign input-icon"></i>
                                <input type="number" name="targetAmount" class="form-input"
                                       value="<%= ep.getTargetAmount() %>" min="0" step="0.01">
                            </div>
                        </div>
                    </div>

                    <div class="form-group-custom">
                        <label class="form-label-custom">Description</label>
                        <textarea name="description" class="form-textarea" rows="3"><%=
                            ep.getDescription() != null ? ep.getDescription() : "" %></textarea>
                    </div>

                    <div class="form-row-two">
                        <div class="form-group-custom">
                            <label class="form-label-custom">Risk Level</label>
                            <select name="riskLevel" class="form-select-custom">
                                <option value="LOW"    <%= "LOW".equals(ep.getRiskLevel())    ? "selected" : "" %>>Low Risk</option>
                                <option value="MEDIUM" <%= "MEDIUM".equals(ep.getRiskLevel()) ? "selected" : "" %>>Medium Risk</option>
                                <option value="HIGH"   <%= "HIGH".equals(ep.getRiskLevel())   ? "selected" : "" %>>High Risk</option>
                            </select>
                        </div>
                        <div class="form-group-custom">
                            <label class="form-label-custom">Status</label>
                            <select name="status" class="form-select-custom">
                                <option value="ACTIVE"  <%= "ACTIVE".equals(ep.getStatus())  ? "selected" : "" %>>Active</option>
                                <option value="PAUSED"  <%= "PAUSED".equals(ep.getStatus())  ? "selected" : "" %>>Paused</option>
                                <option value="CLOSED"  <%= "CLOSED".equals(ep.getStatus())  ? "selected" : "" %>>Closed</option>
                            </select>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="<%= request.getContextPath() %>/PortfolioServlet"
                           class="btn-secondary-custom">Cancel</a>
                        <button type="submit" class="btn-primary-custom">
                            <i class="fas fa-save me-2"></i>Save Changes
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
