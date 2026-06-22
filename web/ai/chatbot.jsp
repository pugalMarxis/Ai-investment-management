<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%@ page import="com.investms.model.*" %>
<%@ page import="com.investms.ai.AIChatbot" %>
<%@ page import="com.investms.dao.*" %>
<%@ page import="java.util.*" %>
<%
    if (!SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp"); return;
    }
    int uid = SessionUtil.getLoggedUserId(request);

    @SuppressWarnings("unchecked")
    List<String[]> chatHistory = (List<String[]>) request.getAttribute("chatHistory");
    @SuppressWarnings("unchecked")
    List<Investment> investments = (List<Investment>) request.getAttribute("investments");
    @SuppressWarnings("unchecked")
    List<Portfolio> portfolios = (List<Portfolio>) request.getAttribute("portfolios");

    if (chatHistory == null) {
        AiRecommendationDAO aiDao = new AiRecommendationDAO();
        chatHistory = aiDao.getChatHistory(uid, 30);
    }
    if (investments == null) investments = new InvestmentDAO().findByUser(uid);
    if (portfolios  == null) portfolios  = new PortfolioDAO().findByUser(uid);
    if (chatHistory == null) chatHistory = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>AI Chatbot — InvestMS</title>
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
                        <i class="fas fa-comment-dots me-2 text-ai"></i>AI Financial Assistant
                    </h1>
                    <p class="page-subtitle">Ask me anything about investing</p>
                </div>
                <div class="chatbot-status">
                    <span class="status-dot online"></span>
                    <span class="status-text">AI Online</span>
                </div>
            </div>

            <div class="chatbot-layout">

                <!-- Chat Window -->
                <div class="chatbot-main">
                    <div class="chat-window" id="chatWindow">

                        <!-- Welcome message -->
                        <div class="chat-msg ai-msg">
                            <div class="chat-avatar ai-avatar">
                                <i class="fas fa-robot"></i>
                            </div>
                            <div class="chat-bubble ai-bubble">
                                <p>Hello! I'm your <strong>AI Financial Assistant</strong>. 🤖</p>
                                <p>I can help you with:</p>
                                <ul>
                                    <li>📊 Portfolio analysis &amp; strategy</li>
                                    <li>⚠️ Risk assessment &amp; management</li>
                                    <li>💡 Investment concepts &amp; education</li>
                                    <li>📈 Market insights &amp; recommendations</li>
                                </ul>
                                <p>What would you like to know today?</p>
                                <span class="chat-time">AI System</span>
                            </div>
                        </div>

                        <!-- Chat History -->
                        <% for (String[] msg : chatHistory) {
                            boolean isUser = "USER".equals(msg[0]);
                            String msgText = msg[1].replace("\n", "<br>");
                        %>
                        <div class="chat-msg <%= isUser ? "user-msg" : "ai-msg" %>">
                            <% if (!isUser) { %>
                            <div class="chat-avatar ai-avatar">
                                <i class="fas fa-robot"></i>
                            </div>
                            <% } %>
                            <div class="chat-bubble <%= isUser ? "user-bubble" : "ai-bubble" %>">
                                <p><%= msgText %></p>
                                <span class="chat-time">
                                    <%= isUser ? "You" : "AI Assistant" %>
                                    <% if (msg.length > 2 && msg[2] != null) { %>
                                    · <%= msg[2].substring(0, Math.min(16, msg[2].length())) %>
                                    <% } %>
                                </span>
                            </div>
                            <% if (isUser) { %>
                            <div class="chat-avatar user-avatar">
                                <%= SessionUtil.getLoggedUser(request).getInitials() %>
                            </div>
                            <% } %>
                        </div>
                        <% } %>

                    </div><!-- /chat-window -->

                    <!-- Message Input -->
                    <div class="chat-input-area">
                        <form action="<%= request.getContextPath() %>/AIServlet"
                              method="POST" class="chat-form" id="chatForm">
                            <input type="hidden" name="action" value="chatMessage">
                            <div class="chat-input-wrapper">
                                <textarea name="message"
                                          id="chatInput"
                                          class="chat-textarea"
                                          placeholder="Ask about stocks, diversification, risk, returns..."
                                          rows="1"
                                          maxlength="500"
                                          onkeydown="handleEnter(event)"></textarea>
                                <button type="submit" class="chat-send-btn" id="sendBtn">
                                    <i class="fas fa-paper-plane"></i>
                                </button>
                            </div>
                        </form>
                        <div class="chat-hints">
                            <span>Try:</span>
                            <button class="hint-chip" onclick="fillQuestion('What is diversification?')">What is diversification?</button>
                            <button class="hint-chip" onclick="fillQuestion('How is my portfolio doing?')">How is my portfolio?</button>
                            <button class="hint-chip" onclick="fillQuestion('What is DCA?')">What is DCA?</button>
                            <button class="hint-chip" onclick="fillQuestion('Tell me about crypto risk')">Crypto risk</button>
                            <button class="hint-chip" onclick="fillQuestion('How to start investing?')">How to start?</button>
                        </div>
                    </div>
                </div>

                <!-- Sidebar -->
                <div class="chatbot-sidebar">

                    <!-- AI Status Card -->
                    <div class="card-panel">
                        <div class="chatbot-ai-card-header">
                            <div class="chatbot-ai-icon"><i class="fas fa-brain"></i></div>
                            <div>
                                <strong>AI Financial Assistant</strong>
                                <p class="text-muted mb-0">Powered by InvestMS AI</p>
                            </div>
                        </div>
                        <div class="chatbot-stats">
                            <div class="chatbot-stat">
                                <span><%= chatHistory.size() %></span>
                                <small>Messages</small>
                            </div>
                            <div class="chatbot-stat">
                                <span><%= investments.size() %></span>
                                <small>Investments</small>
                            </div>
                            <div class="chatbot-stat">
                                <span>18+</span>
                                <small>Topics</small>
                            </div>
                        </div>
                    </div>

                    <!-- Topics -->
                    <div class="card-panel mt-3">
                        <h5 class="card-panel-title">I Can Help With</h5>
                        <div class="topic-list">
                            <% String[] topics = {
                                "Stocks & Equities", "Bonds & Fixed Income",
                                "Cryptocurrency", "ETFs & Index Funds",
                                "Risk Management", "Portfolio Strategy",
                                "Dollar-Cost Averaging", "Compounding Interest",
                                "Diversification", "Tax & Capital Gains",
                                "Portfolio Analysis", "Investment Basics"
                            }; %>
                            <% for (String t : topics) { %>
                            <button class="topic-chip"
                                    onclick="fillQuestion('Tell me about <%= t %>')">
                                <%= t %>
                            </button>
                            <% } %>
                        </div>
                    </div>

                    <!-- Quick Actions -->
                    <div class="card-panel mt-3">
                        <h5 class="card-panel-title">Quick Actions</h5>
                        <a href="<%= request.getContextPath() %>/ai/recommendations.jsp"
                           class="quick-action-link">
                            <i class="fas fa-robot"></i> AI Recommendations
                        </a>
                        <a href="<%= request.getContextPath() %>/ai/risk-analyzer.jsp"
                           class="quick-action-link">
                            <i class="fas fa-shield-alt"></i> Risk Analyzer
                        </a>
                        <a href="<%= request.getContextPath() %>/ai/portfolio-analyzer.jsp"
                           class="quick-action-link">
                            <i class="fas fa-chart-pie"></i> Portfolio Analyzer
                        </a>
                    </div>
                </div>

            </div><!-- /chatbot-layout -->

        </div>
        <%@ include file="/includes/footer.jsp" %>
    </div>
</div>

<script>
// Auto-scroll to bottom
function scrollToBottom() {
    const win = document.getElementById('chatWindow');
    win.scrollTop = win.scrollHeight;
}
scrollToBottom();

// Submit on Enter (Shift+Enter for newline)
function handleEnter(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        if (document.getElementById('chatInput').value.trim()) {
            document.getElementById('chatForm').submit();
        }
    }
}

// Fill a question into the input
function fillQuestion(q) {
    document.getElementById('chatInput').value = q;
    document.getElementById('chatInput').focus();
}

// Auto-resize textarea
document.getElementById('chatInput').addEventListener('input', function () {
    this.style.height = 'auto';
    this.style.height = Math.min(this.scrollHeight, 120) + 'px';
});

// Show loading state on submit
document.getElementById('chatForm').addEventListener('submit', function () {
    const btn = document.getElementById('sendBtn');
    btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    btn.disabled = true;
});

document.getElementById('sidebarToggle').addEventListener('click', function () {
    document.getElementById('sidebar').classList.toggle('collapsed');
    document.getElementById('mainContent').classList.toggle('sidebar-collapsed');
});
</script>
</body>
</html>
