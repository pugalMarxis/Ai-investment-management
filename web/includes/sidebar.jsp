<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.User" %>
<%
    User sidebarUser = SessionUtil.getLoggedUser(request);
    String currentURI = request.getRequestURI();
%>
<!-- ═══════════════════════════════════════════════════
     SIDEBAR NAVIGATION
═══════════════════════════════════════════════════ -->
<nav class="sidebar" id="sidebar">

    <!-- Brand -->
    <div class="sidebar-brand">
        <div class="brand-icon">
            <i class="fas fa-chart-line"></i>
        </div>
        <div class="brand-text">
            <span class="brand-name">InvestMS</span>
            <span class="brand-tagline">AI Powered</span>
        </div>
    </div>

    <!-- User mini-profile -->
    <div class="sidebar-user">
        <div class="user-avatar-sm">
            <%= sidebarUser != null ? sidebarUser.getInitials() : "?" %>
        </div>
        <div class="user-info-sm">
            <span class="user-name-sm"><%= sidebarUser != null ? sidebarUser.getFullName() : "Guest" %></span>
            <span class="user-role-sm badge-role"><%= sidebarUser != null ? sidebarUser.getRoleName() : "" %></span>
        </div>
    </div>

    <div class="sidebar-divider"></div>

    <!-- Navigation Links -->
    <ul class="sidebar-nav">

        <li class="nav-section-label">MAIN</li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/dashboard/dashboard.jsp"
               class="nav-link <%= currentURI.contains("dashboard") ? "active" : "" %>">
                <i class="fas fa-th-large"></i>
                <span>Dashboard</span>
            </a>
        </li>

        <li class="nav-section-label">INVESTMENTS</li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/portfolio/portfolios.jsp"
               class="nav-link <%= currentURI.contains("portfolio") ? "active" : "" %>">
                <i class="fas fa-briefcase"></i>
                <span>Portfolios</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/investment/investments.jsp"
               class="nav-link <%= currentURI.contains("investment") ? "active" : "" %>">
                <i class="fas fa-coins"></i>
                <span>Investments</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/transaction/transactions.jsp"
               class="nav-link <%= currentURI.contains("transaction") ? "active" : "" %>">
                <i class="fas fa-exchange-alt"></i>
                <span>Transactions</span>
            </a>
        </li>

        <li class="nav-section-label">AI FEATURES</li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
               class="nav-link ai-link <%= currentURI.contains("recommendation") ? "active" : "" %>">
                <i class="fas fa-robot"></i>
                <span>AI Recommendations</span>
                <span class="badge-ai">AI</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/ai/risk-analyzer.jsp"
               class="nav-link ai-link <%= currentURI.contains("risk") ? "active" : "" %>">
                <i class="fas fa-shield-alt"></i>
                <span>Risk Analyzer</span>
                <span class="badge-ai">AI</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/ai/chatbot.jsp"
               class="nav-link ai-link <%= currentURI.contains("chatbot") ? "active" : "" %>">
                <i class="fas fa-comment-dots"></i>
                <span>AI Chatbot</span>
                <span class="badge-ai">AI</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/ai/portfolio-analyzer.jsp"
               class="nav-link ai-link <%= currentURI.contains("portfolio-analyzer") ? "active" : "" %>">
                <i class="fas fa-chart-pie"></i>
                <span>Portfolio AI</span>
                <span class="badge-ai">AI</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/ai/reports.jsp"
               class="nav-link ai-link <%= currentURI.contains("reports") ? "active" : "" %>">
                <i class="fas fa-file-alt"></i>
                <span>AI Reports</span>
                <span class="badge-ai">AI</span>
            </a>
        </li>

        <% if (sidebarUser != null && sidebarUser.isAdmin()) { %>
        <li class="nav-section-label">ADMIN</li>
        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/admin/users.jsp"
               class="nav-link <%= currentURI.contains("admin") ? "active" : "" %>">
                <i class="fas fa-users-cog"></i>
                <span>Manage Users</span>
            </a>
        </li>
        <% } %>

        <li class="nav-section-label">ACCOUNT</li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/auth/profile.jsp" class="nav-link">
                <i class="fas fa-user-circle"></i>
                <span>Profile</span>
            </a>
        </li>

        <li class="nav-item">
            <a href="<%= request.getContextPath() %>/LogoutServlet" class="nav-link nav-link-logout">
                <i class="fas fa-sign-out-alt"></i>
                <span>Logout</span>
            </a>
        </li>

    </ul>
</nav>
<!-- END SIDEBAR -->
