package com.investms.servlet;

import com.investms.ai.*;
import com.investms.dao.*;
import com.investms.model.*;
import com.investms.util.SessionUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * Central servlet for all AI features.
 *
 * GET  actions: recommendations | risk | chatbot | portfolio-analyzer | reports
 * POST actions: chatMessage | generateReport | refreshRecommendations
 */
@WebServlet("/AIServlet")
public class AIServlet extends HttpServlet {

    private final InvestmentDAO        investmentDAO  = new InvestmentDAO();
    private final PortfolioDAO         portfolioDAO   = new PortfolioDAO();
    private final TransactionDAO       transactionDAO = new TransactionDAO();
    private final AiRecommendationDAO  aiRecDAO       = new AiRecommendationDAO();
    private final UserDAO              userDAO        = new UserDAO();

    // ── GET ────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        int    userId = SessionUtil.getLoggedUserId(req);
        String action = req.getParameter("action");
        if (action == null) action = "recommendations";

        List<Investment>  investments = investmentDAO.findByUser(userId);
        List<Portfolio>   portfolios  = portfolioDAO.findByUser(userId);

        switch (action) {

            case "recommendations":
                // Generate fresh recommendations
                AIRecommendationEngine engine = new AIRecommendationEngine();
                List<AiRecommendation> recs   = engine.generateRecommendations(
                                                    portfolios, investments, userId);
                // Persist & load saved ones
                aiRecDAO.saveAll(recs);
                aiRecDAO.pruneOld(userId);
                aiRecDAO.markAllRead(userId);
                req.setAttribute("recommendations", aiRecDAO.findByUser(userId));
                req.setAttribute("investments",     investments);
                req.setAttribute("portfolios",      portfolios);
                req.getRequestDispatcher("/ai/recommendations.jsp").forward(req, resp);
                break;

            case "risk":
                AIRiskAnalyzer riskAnalyzer = new AIRiskAnalyzer();
                AIRiskAnalyzer.RiskReport riskReport =
                    riskAnalyzer.analyzePortfolio(investments, portfolios);
                req.setAttribute("riskReport",  riskReport);
                req.setAttribute("investments", investments);
                req.getRequestDispatcher("/ai/risk-analyzer.jsp").forward(req, resp);
                break;

            case "chatbot":
                List<String[]> history = aiRecDAO.getChatHistory(userId, 30);
                req.setAttribute("chatHistory",  history);
                req.setAttribute("investments",  investments);
                req.setAttribute("portfolios",   portfolios);
                req.getRequestDispatcher("/ai/chatbot.jsp").forward(req, resp);
                break;

            case "portfolio-analyzer":
                AIPortfolioAnalyzer analyzer = new AIPortfolioAnalyzer();
                AIPortfolioAnalyzer.PortfolioAnalysisReport paReport =
                    analyzer.analyze(investments, portfolios);
                req.setAttribute("analysisReport", paReport);
                req.setAttribute("investments",    investments);
                req.setAttribute("portfolios",     portfolios);
                req.getRequestDispatcher("/ai/portfolio-analyzer.jsp").forward(req, resp);
                break;

            case "reports":
                req.setAttribute("investments",  investments);
                req.setAttribute("portfolios",   portfolios);
                req.getRequestDispatcher("/ai/reports.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/AIServlet?action=recommendations");
        }
    }

    // ── POST ───────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        int    userId = SessionUtil.getLoggedUserId(req);
        String action = req.getParameter("action");
        if (action == null) action = "";

        switch (action) {

            case "chatMessage":
                handleChatMessage(req, resp, userId);
                break;

            case "generateReport":
                handleGenerateReport(req, resp, userId);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/AIServlet");
        }
    }

    // ── Chat message handler ───────────────────────────────────────────────
    private void handleChatMessage(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {

        String userMsg = req.getParameter("message");
        if (userMsg == null || userMsg.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/AIServlet?action=chatbot");
            return;
        }

        List<Investment> investments = investmentDAO.findByUser(userId);
        List<Portfolio>  portfolios  = portfolioDAO.findByUser(userId);

        // Get AI response
        AIChatbot chatbot = new AIChatbot();
        String aiResponse = chatbot.getResponse(userMsg.trim(), investments, portfolios);

        // Persist both messages
        aiRecDAO.saveChatMessage(userId, "USER", userMsg.trim());
        aiRecDAO.saveChatMessage(userId, "AI",   aiResponse);

        // Reload chat page
        List<String[]> history = aiRecDAO.getChatHistory(userId, 30);
        req.setAttribute("chatHistory",  history);
        req.setAttribute("investments",  investments);
        req.setAttribute("portfolios",   portfolios);
        req.getRequestDispatcher("/ai/chatbot.jsp").forward(req, resp);
    }

    // ── Report generator handler ───────────────────────────────────────────
    private void handleGenerateReport(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {

        String reportTypeStr = req.getParameter("reportType");
        AIReportGenerator.ReportType reportType;
        try {
            reportType = AIReportGenerator.ReportType.valueOf(reportTypeStr);
        } catch (Exception e) {
            reportType = AIReportGenerator.ReportType.PERFORMANCE;
        }

        User user = SessionUtil.getLoggedUser(req);
        List<Investment>  investments  = investmentDAO.findByUser(userId);
        List<Portfolio>   portfolios   = portfolioDAO.findByUser(userId);
        List<Transaction> transactions = transactionDAO.findByUser(userId);

        AIReportGenerator generator = new AIReportGenerator();
        AIReportGenerator.InvestmentReport report =
            generator.generateReport(reportType, user, investments, portfolios, transactions);

        req.setAttribute("generatedReport", report);
        req.setAttribute("investments",     investments);
        req.setAttribute("portfolios",      portfolios);
        req.getRequestDispatcher("/ai/reports.jsp").forward(req, resp);
    }
}
