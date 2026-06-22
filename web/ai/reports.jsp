<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.ai.AIReportGenerator" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);
    User rptUser = SessionUtil.getLoggedUser(request);

    AIReportGenerator.InvestmentReport generatedReport =
        (AIReportGenerator.InvestmentReport) request.getAttribute("generatedReport");

    @SuppressWarnings("unchecked")
    List<Investment>  investments  = (List<Investment>)  request.getAttribute("investments");
    @SuppressWarnings("unchecked")
    List<Portfolio>   portfolios   = (List<Portfolio>)   request.getAttribute("portfolios");

    if (investments == null) investments = new InvestmentDAO().findByUser(uid);
    if (portfolios  == null) portfolios  = new PortfolioDAO().findByUser(uid);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>AI Reports — InvestMS</title>
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
                        <i class="fas fa-file-alt me-2 text-ai"></i>AI Reports
                    </h1>
                    <p class="page-subtitle">Intelligent investment reports with AI insights</p>
                </div>
            </div>

            <!-- Report Type Selector -->
            <div class="report-type-grid">
                <form action="<%= request.getContextPath() %>/AIServlet" method="POST" class="report-type-form">
                    <input type="hidden" name="action" value="generateReport">

                    <label class="report-type-card <%= generatedReport != null && "PERFORMANCE".equals(generatedReport.getReportType()) ? "selected" : "" %>">
                        <input type="radio" name="reportType" value="PERFORMANCE"
                               <%= generatedReport == null || "PERFORMANCE".equals(generatedReport.getReportType()) ? "checked" : "" %>>
                        <div class="rtc-icon rtc-blue"><i class="fas fa-chart-line"></i></div>
                        <div class="rtc-info">
                            <strong>Performance Report</strong>
                            <span>Returns, P&L, investment breakdown</span>
                        </div>
                    </label>

                    <label class="report-type-card <%= generatedReport != null && "RISK".equals(generatedReport.getReportType()) ? "selected" : "" %>">
                        <input type="radio" name="reportType" value="RISK"
                               <%= "RISK".equals(generatedReport != null ? generatedReport.getReportType() : "") ? "checked" : "" %>>
                        <div class="rtc-icon rtc-red"><i class="fas fa-shield-alt"></i></div>
                        <div class="rtc-info">
                            <strong>Risk Assessment</strong>
                            <span>Risk scores, allocation analysis</span>
                        </div>
                    </label>

                    <label class="report-type-card <%= generatedReport != null && "PORTFOLIO_HEALTH".equals(generatedReport.getReportType()) ? "selected" : "" %>">
                        <input type="radio" name="reportType" value="PORTFOLIO_HEALTH"
                               <%= "PORTFOLIO_HEALTH".equals(generatedReport != null ? generatedReport.getReportType() : "") ? "checked" : "" %>>
                        <div class="rtc-icon rtc-green"><i class="fas fa-heartbeat"></i></div>
                        <div class="rtc-info">
                            <strong>Portfolio Health</strong>
                            <span>Health score, sector breakdown</span>
                        </div>
                    </label>

                    <label class="report-type-card <%= generatedReport != null && "TRANSACTION_SUMMARY".equals(generatedReport.getReportType()) ? "selected" : "" %>">
                        <input type="radio" name="reportType" value="TRANSACTION_SUMMARY"
                               <%= "TRANSACTION_SUMMARY".equals(generatedReport != null ? generatedReport.getReportType() : "") ? "checked" : "" %>>
                        <div class="rtc-icon rtc-purple"><i class="fas fa-receipt"></i></div>
                        <div class="rtc-info">
                            <strong>Transaction Summary</strong>
                            <span>Cash flows, deposits, withdrawals</span>
                        </div>
                    </label>

                    <div class="report-generate-row">
                        <button type="submit" class="btn-ai-custom btn-generate-report">
                            <i class="fas fa-magic me-2"></i>Generate AI Report
                        </button>
                    </div>
                </form>
            </div>

            <!-- Generated Report -->
            <% if (generatedReport != null) { %>
            <div class="report-output" id="reportOutput">

                <!-- Report Header -->
                <div class="report-header-card">
                    <div class="report-header-left">
                        <div class="report-type-icon">
                            <i class="fas fa-<%= generatedReport.getIcon() %>"></i>
                        </div>
                        <div>
                            <h2 class="report-title"><%= generatedReport.getTitle() %></h2>
                            <p class="report-meta">
                                <i class="fas fa-user me-1"></i><%= generatedReport.getUserName() %>
                                &nbsp;|&nbsp;
                                <i class="fas fa-clock me-1"></i>Generated: <%= generatedReport.getGeneratedAt() %>
                            </p>
                        </div>
                    </div>
                    <button class="btn-print" onclick="window.print()">
                        <i class="fas fa-print me-2"></i>Print
                    </button>
                </div>

                <!-- Summary Items -->
                <div class="report-summary-grid">
                    <% for (String item : generatedReport.getSummaryItems()) {
                        String[] parts = item.split(": ", 2);
                        String label = parts.length > 1 ? parts[0] : "";
                        String value = parts.length > 1 ? parts[1] : item;
                    %>
                    <div class="report-summary-item">
                        <span class="rsi-label"><%= label %></span>
                        <span class="rsi-value"><%= value %></span>
                    </div>
                    <% } %>
                </div>

                <!-- Data Table -->
                <% if (!generatedReport.getTableRows().isEmpty()) { %>
                <div class="report-section">
                    <h4 class="report-section-title">
                        <i class="fas fa-table me-2"></i>Detailed Breakdown
                    </h4>
                    <div class="table-responsive">
                        <table class="data-table report-table">
                            <thead>
                                <tr>
                                    <% for (String header : generatedReport.getTableHeaders()) { %>
                                    <th><%= header %></th>
                                    <% } %>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Map<String, String> row : generatedReport.getTableRows()) { %>
                                <tr>
                                    <% for (String val : row.values()) {
                                        boolean isNeg = val != null && val.startsWith("-") && val.contains("$");
                                        boolean isPos = val != null && val.startsWith("+") && val.contains("$");
                                    %>
                                    <td class="<%= isNeg ? "text-loss" : isPos ? "text-profit" : "" %>">
                                        <%= val != null ? val : "—" %>
                                    </td>
                                    <% } %>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
                <% } %>

                <!-- AI Insight -->
                <div class="report-ai-insight">
                    <div class="insight-header">
                        <i class="fas fa-brain"></i>
                        <strong>AI Analysis &amp; Insights</strong>
                    </div>
                    <div class="insight-body">
                        <% String insightText = generatedReport.getAiInsight();
                           if (insightText != null) {
                               out.print(insightText.replace("\n", "<br>"));
                           } %>
                    </div>
                </div>

                <!-- Report Footer -->
                <div class="report-footer">
                    <p>This report was automatically generated by InvestMS AI Engine.
                    All data reflects your current portfolio state. Not financial advice.</p>
                    <p>Generated: <%= generatedReport.getGeneratedAt() %> &bull;
                       InvestMS v1.0.0 &bull; AI-Powered Investment Management</p>
                </div>

            </div><!-- /report-output -->
            <% } else { %>
            <!-- No report generated yet -->
            <div class="empty-state-full">
                <div class="empty-icon"><i class="fas fa-file-alt"></i></div>
                <h3>Select a Report Type</h3>
                <p>Choose a report type above and click "Generate AI Report" to see detailed AI analysis.</p>
            </div>
            <% } %>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
// Highlight selected report type card
document.querySelectorAll('.report-type-card input[type=radio]').forEach(radio => {
    radio.addEventListener('change', function () {
        document.querySelectorAll('.report-type-card').forEach(c => c.classList.remove('selected'));
        this.closest('.report-type-card').classList.add('selected');
    });
});

// Scroll to report on load if generated
<% if (generatedReport != null) { %>
document.addEventListener('DOMContentLoaded', function () {
    const el = document.getElementById('reportOutput');
    if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' });
});
<% } %>

document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
