<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.ai.*" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);

    @SuppressWarnings("unchecked")
    List<AiRecommendation> recommendations = (List<AiRecommendation>) request.getAttribute("recommendations");
    @SuppressWarnings("unchecked")
    List<Investment> investments = (List<Investment>) request.getAttribute("investments");
    @SuppressWarnings("unchecked")
    List<Portfolio> portfolios = (List<Portfolio>) request.getAttribute("portfolios");

    // Load fresh if accessed directly
    if (recommendations == null) {
        InvestmentDAO iDao = new InvestmentDAO();
        PortfolioDAO  pDao = new PortfolioDAO();
        investments   = iDao.findByUser(uid);
        portfolios    = pDao.findByUser(uid);
        AIRecommendationEngine engine = new AIRecommendationEngine();
        List<AiRecommendation> fresh = engine.generateRecommendations(portfolios, investments, uid);
        AiRecommendationDAO aiDao = new AiRecommendationDAO();
        aiDao.saveAll(fresh);
        aiDao.pruneOld(uid);
        recommendations = aiDao.findByUser(uid);
    }
    if (investments    == null) investments    = new ArrayList<>();
    if (portfolios     == null) portfolios     = new ArrayList<>();
    if (recommendations== null) recommendations= new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>AI Recommendations — InvestMS</title>
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
                    <h1 class="page-title">
                        <i class="fas fa-robot me-2 text-ai"></i>AI Recommendations
                    </h1>
                    <p class="page-subtitle">Personalised investment suggestions powered by AI</p>
                </div>
                <a href="<%= request.getContextPath() %>/AIServlet?action=recommendations"
                   class="btn-ai-custom">
                    <i class="fas fa-sync-alt me-2"></i>Refresh AI Analysis
                </a>
            </div>

            <!-- AI Status Banner -->
            <div class="ai-banner">
                <div class="ai-banner-icon"><i class="fas fa-brain"></i></div>
                <div class="ai-banner-content">
                    <strong>AI Engine Active</strong>
                    <span>Analysed <%= investments.size() %> investment(s) across
                          <%= portfolios.size() %> portfolio(s) —
                          generated <%= recommendations.size() %> recommendation(s)</span>
                </div>
                <span class="ai-banner-badge">LIVE</span>
            </div>

            <!-- Recommendation Type Filter -->
            <div class="filter-tabs">
                <button class="filter-tab active" onclick="filterRecs('ALL', this)">
                    <i class="fas fa-list me-1"></i>All (<%= recommendations.size() %>)
                </button>
                <button class="filter-tab" onclick="filterRecs('BUY', this)">
                    <i class="fas fa-arrow-up me-1"></i>Buy
                </button>
                <button class="filter-tab" onclick="filterRecs('SELL', this)">
                    <i class="fas fa-arrow-down me-1"></i>Sell
                </button>
                <button class="filter-tab" onclick="filterRecs('HOLD', this)">
                    <i class="fas fa-pause me-1"></i>Hold
                </button>
                <button class="filter-tab" onclick="filterRecs('REBALANCE', this)">
                    <i class="fas fa-balance-scale me-1"></i>Rebalance
                </button>
                <button class="filter-tab" onclick="filterRecs('DIVERSIFY', this)">
                    <i class="fas fa-th me-1"></i>Diversify
                </button>
            </div>

            <!-- Recommendations Grid -->
            <% if (recommendations.isEmpty()) { %>
            <div class="empty-state-full">
                <div class="empty-icon"><i class="fas fa-robot"></i></div>
                <h3>No Recommendations Yet</h3>
                <p>Add investments to your portfolio and the AI will generate personalised suggestions.</p>
                <a href="<%= request.getContextPath() %>/investment/add-investment.jsp"
                   class="btn-primary-custom">
                    <i class="fas fa-plus me-2"></i>Add Investment
                </a>
            </div>
            <% } else { %>
            <div class="rec-cards-grid" id="recGrid">
                <% for (AiRecommendation rec : recommendations) { %>
                <div class="rec-card" data-type="<%= rec.getRecType() %>">

                    <!-- Card Header -->
                    <div class="rec-card-header">
                        <div class="rec-type-icon rec-type-<%= rec.getRecType().toLowerCase() %>">
                            <%
                                String recIcon = "lightbulb";
                                switch(rec.getRecType()) {
                                    case "BUY":       recIcon = "arrow-trend-up"; break;
                                    case "SELL":      recIcon = "arrow-trend-down"; break;
                                    case "HOLD":      recIcon = "pause-circle"; break;
                                    case "REBALANCE": recIcon = "balance-scale"; break;
                                    case "DIVERSIFY": recIcon = "th"; break;
                                }
                            %>
                            <i class="fas fa-<%= recIcon %>"></i>
                        </div>
                        <div class="rec-type-info">
                            <span class="badge rec-badge-<%= rec.getRecType().toLowerCase() %>">
                                <%= rec.getRecType() %>
                            </span>
                            <% if (rec.getAssetName() != null) { %>
                            <span class="rec-asset-tag">
                                <i class="fas fa-tag me-1"></i><%= rec.getAssetName() %>
                            </span>
                            <% } %>
                        </div>
                        <div class="rec-confidence">
                            <div class="confidence-ring"
                                 style="--pct:<%= rec.getConfidenceScore() %>">
                                <span><%= rec.getConfidenceScore().intValue() %>%</span>
                            </div>
                            <span class="confidence-label"><%= rec.getConfidenceLabel() %></span>
                        </div>
                    </div>

                    <!-- Recommendation Text -->
                    <div class="rec-body">
                        <p class="rec-text"><%= rec.getRecommendation() %></p>
                    </div>

                    <!-- Confidence Bar -->
                    <div class="rec-confidence-bar">
                        <div class="conf-bar-label">
                            <span>AI Confidence</span>
                            <span><%= rec.getConfidenceScore() %>%</span>
                        </div>
                        <div class="conf-bar-track">
                            <div class="conf-bar-fill conf-<%= rec.getConfidenceLabel().toLowerCase().replace(" ","") %>"
                                 style="width:<%= rec.getConfidenceScore() %>%"></div>
                        </div>
                    </div>

                    <!-- Card Footer -->
                    <div class="rec-footer">
                        <span class="rec-date">
                            <i class="fas fa-clock me-1"></i>
                            <%= rec.getGeneratedAt() != null
                                ? rec.getGeneratedAt().toLocalDate().toString() : "Now" %>
                        </span>
                        <% if ("BUY".equals(rec.getRecType())) { %>
                        <a href="<%= request.getContextPath() %>/InvestmentServlet?action=add"
                           class="btn-rec-action btn-rec-buy">
                            <i class="fas fa-coins me-1"></i>Invest Now
                        </a>
                        <% } else if ("SELL".equals(rec.getRecType())) { %>
                        <a href="<%= request.getContextPath() %>/InvestmentServlet"
                           class="btn-rec-action btn-rec-sell">
                            <i class="fas fa-dollar-sign me-1"></i>Review
                        </a>
                        <% } else { %>
                        <a href="<%= request.getContextPath() %>/portfolio/portfolios.jsp"
                           class="btn-rec-action btn-rec-neutral">
                            <i class="fas fa-eye me-1"></i>View Portfolio
                        </a>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>
            <% } %>

            <!-- AI Disclaimer -->
            <div class="ai-disclaimer">
                <i class="fas fa-info-circle me-2"></i>
                AI recommendations are generated algorithmically based on your portfolio data.
                They are for informational purposes only and do not constitute financial advice.
                Always consult a qualified financial advisor before making investment decisions.
            </div>

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>
<script>
function filterRecs(type, btn) {
    document.querySelectorAll('.filter-tab').forEach(b => b.classList.remove('active'));
    btn.classList.add('active');
    document.querySelectorAll('.rec-card').forEach(card => {
        card.style.display = (type === 'ALL' || card.dataset.type === type) ? '' : 'none';
    });
}
document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
