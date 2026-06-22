package com.investms.ai;

import com.investms.model.Investment;
import com.investms.model.Portfolio;

import java.math.BigDecimal;
import java.util.*;

/**
 * AI Feature #3 — Financial Chat Assistant
 *
 * Provides rule-based NLP responses to investment queries.
 * Supports contextual answers using user's actual portfolio data.
 * No external API dependency — fully offline capable.
 */
public class AIChatbot {

    // ── Keyword → response intent mappings ───────────────────────────────────
    private static final Map<String[], String> KNOWLEDGE_BASE = new LinkedHashMap<>();

    static {
        KNOWLEDGE_BASE.put(new String[]{"hello","hi","hey","good morning","good afternoon"},
            "Hello! I'm your AI Financial Assistant. I can help you with investment strategies, "
          + "portfolio analysis, risk management, and market insights. What would you like to know?");

        KNOWLEDGE_BASE.put(new String[]{"what is a portfolio","portfolio meaning","define portfolio"},
            "A portfolio is a collection of financial investments — stocks, bonds, ETFs, crypto, "
          + "and more. A well-diversified portfolio spreads risk across different asset classes, "
          + "reducing the impact of any single investment's poor performance.");

        KNOWLEDGE_BASE.put(new String[]{"diversification","diversify","spread risk"},
            "Diversification is the practice of spreading investments across different assets, "
          + "sectors, and geographies. The core idea: don't put all your eggs in one basket. "
          + "A diversified portfolio typically includes 40% stocks, 30% bonds, 20% ETFs, "
          + "and 10% alternatives like commodities or crypto.");

        KNOWLEDGE_BASE.put(new String[]{"risk","risky","safe","safe investment"},
            "Investment risk is the probability of losing money. Key risk types:\n"
          + "• Market Risk: overall market decline\n"
          + "• Concentration Risk: too much in one asset\n"
          + "• Liquidity Risk: can't sell quickly\n"
          + "• Currency Risk: exchange rate changes\n"
          + "Use my Risk Analyzer to see your portfolio's current risk score.");

        KNOWLEDGE_BASE.put(new String[]{"stock","stocks","equities","shares"},
            "Stocks (equities) represent ownership in a company. They offer growth potential "
          + "but come with volatility. Key metrics to evaluate stocks:\n"
          + "• P/E Ratio (Price-to-Earnings)\n"
          + "• EPS (Earnings Per Share)\n"
          + "• Dividend Yield\n"
          + "• Market Cap\n"
          + "Blue-chip stocks like AAPL and MSFT historically provide 10–15% annual returns.");

        KNOWLEDGE_BASE.put(new String[]{"bond","bonds","fixed income","treasury"},
            "Bonds are fixed-income instruments where you lend money to a government or company "
          + "in exchange for regular interest payments. They're lower risk than stocks. "
          + "US Treasury Bonds are the safest — backed by the full faith of the US government. "
          + "Ideal for capital preservation and income generation.");

        KNOWLEDGE_BASE.put(new String[]{"crypto","bitcoin","ethereum","cryptocurrency","btc","eth"},
            "Cryptocurrency is a highly volatile digital asset class. Bitcoin (BTC) and "
          + "Ethereum (ETH) are the most established. Key considerations:\n"
          + "• Risk Rating: 8–10/10 (very high)\n"
          + "• Never invest more than 5–10% of total portfolio\n"
          + "• 24/7 markets — highly reactive to news\n"
          + "• Use dollar-cost averaging (DCA) to reduce timing risk");

        KNOWLEDGE_BASE.put(new String[]{"etf","exchange traded fund","index fund"},
            "ETFs (Exchange-Traded Funds) track an index like the S&P 500 and trade like stocks. "
          + "They offer instant diversification at low cost. SPY (S&P 500 ETF) has averaged "
          + "~10% annual return historically. ETFs are ideal for long-term passive investing.");

        KNOWLEDGE_BASE.put(new String[]{"profit","return","gains","how much profit"},
            "Investment returns come from:\n"
          + "• Capital Gains: selling for more than you paid\n"
          + "• Dividends: regular income payments\n"
          + "• Interest: from bonds/fixed income\n"
          + "Your portfolio P&L is visible on the Dashboard. Use the AI Portfolio Analyzer "
          + "for a detailed breakdown of your returns.");

        KNOWLEDGE_BASE.put(new String[]{"loss","losing money","negative return","down"},
            "Investment losses are normal and expected. Key strategies when in a loss:\n"
          + "1. Don't panic-sell — assess if fundamentals changed\n"
          + "2. Consider tax-loss harvesting\n"
          + "3. Use stop-loss orders for volatile assets\n"
          + "4. Review asset allocation and rebalance\n"
          + "My Risk Analyzer can identify which holdings are dragging performance.");

        KNOWLEDGE_BASE.put(new String[]{"rebalance","rebalancing","portfolio weight"},
            "Rebalancing restores your portfolio to its target allocation. Example: if stocks "
          + "grew from 60% to 75%, you'd sell some stocks and buy bonds/ETFs. "
          + "Rebalance quarterly or when any asset class drifts >5% from target. "
          + "This locks in gains and maintains your desired risk level.");

        KNOWLEDGE_BASE.put(new String[]{"dollar cost averaging","dca","invest regularly"},
            "Dollar-Cost Averaging (DCA) means investing a fixed amount at regular intervals "
          + "regardless of price. Benefits:\n"
          + "• Removes emotional decision-making\n"
          + "• Automatically buys more when prices are low\n"
          + "• Reduces average cost basis over time\n"
          + "DCA is especially effective for volatile assets like crypto and growth stocks.");

        KNOWLEDGE_BASE.put(new String[]{"compound interest","compounding","compound"},
            "Compounding is earning returns on your returns. Albert Einstein called it the "
          + "'8th wonder of the world'. Example: $10,000 at 10% annual return:\n"
          + "• Year 1:  $11,000\n"
          + "• Year 5:  $16,105\n"
          + "• Year 10: $25,937\n"
          + "• Year 20: $67,275\n"
          + "Start investing early — time is your biggest advantage.");

        KNOWLEDGE_BASE.put(new String[]{"inflation","inflation rate","purchasing power"},
            "Inflation erodes purchasing power over time. At 3% annual inflation, $100 today "
          + "is worth ~$74 in 10 years. To beat inflation, your investments must return >3% "
          + "annually. Stocks, real estate, and commodities historically outpace inflation. "
          + "Cash and low-yield bonds may actually lose value in real terms.");

        KNOWLEDGE_BASE.put(new String[]{"how to start","beginner","new investor","start investing"},
            "Getting started with investing:\n"
          + "1. Build an emergency fund (3–6 months expenses) first\n"
          + "2. Define your goals (retirement, house, wealth)\n"
          + "3. Assess your risk tolerance\n"
          + "4. Start with ETFs for instant diversification\n"
          + "5. Invest consistently using DCA\n"
          + "6. Use InvestMS to track everything!\n"
          + "A good starting allocation: 60% ETFs, 30% stocks, 10% bonds.");

        KNOWLEDGE_BASE.put(new String[]{"tax","capital gains tax","tax on investments"},
            "Investment taxation varies by country. Key concepts:\n"
          + "• Short-term capital gains (< 1 year): taxed as ordinary income\n"
          + "• Long-term capital gains (> 1 year): lower tax rates\n"
          + "• Tax-loss harvesting: offset gains with losses\n"
          + "• Dividend income is taxable\n"
          + "Consult a tax advisor for personalised guidance.");

        KNOWLEDGE_BASE.put(new String[]{"recommendation","suggest","what should i buy","advice"},
            "For personalised investment recommendations, use the AI Recommendations page. "
          + "General guidance:\n"
          + "• Conservative: 70% bonds, 20% ETFs, 10% stocks\n"
          + "• Moderate:     50% stocks, 30% ETFs, 20% bonds\n"
          + "• Aggressive:   70% stocks, 20% crypto, 10% bonds\n"
          + "My AI analyses your actual portfolio to give tailored suggestions.");

        KNOWLEDGE_BASE.put(new String[]{"help","what can you do","features","capabilities"},
            "I can help you with:\n"
          + "💼 Portfolio strategy & diversification\n"
          + "📊 Investment analysis & metrics\n"
          + "⚠️ Risk assessment & management\n"
          + "💡 Market concepts & education\n"
          + "🤖 AI-powered recommendations\n"
          + "💰 Crypto, stocks, bonds, ETFs explained\n"
          + "📈 Compounding & long-term wealth building\n"
          + "Just ask me anything about investing!");
    }

    // ── Main chat method ──────────────────────────────────────────────────────

    /**
     * Process a user message and return an AI response.
     * Optionally uses portfolio context for personalised answers.
     */
    public String getResponse(String userMessage,
                              List<Investment> investments,
                              List<Portfolio>  portfolios) {
        if (userMessage == null || userMessage.trim().isEmpty()) {
            return "Please type a question and I'll be happy to help!";
        }

        String lower = userMessage.toLowerCase().trim();

        // ── Contextual portfolio queries ──────────────────────────────────
        if (containsAny(lower, "my portfolio","my investments","how am i doing","my performance")) {
            return buildPortfolioSummaryResponse(investments, portfolios);
        }
        if (containsAny(lower, "my risk","my risk score","how risky am i")) {
            return buildRiskSummaryResponse(investments);
        }

        // ── Knowledge base lookup ─────────────────────────────────────────
        for (Map.Entry<String[], String> entry : KNOWLEDGE_BASE.entrySet()) {
            for (String keyword : entry.getKey()) {
                if (lower.contains(keyword)) {
                    return entry.getValue();
                }
            }
        }

        // ── Numeric / specific questions ──────────────────────────────────
        if (lower.contains("how many") && lower.contains("investment")) {
            int count = investments != null ? (int) investments.stream()
                .filter(i -> "ACTIVE".equals(i.getStatus())).count() : 0;
            return "You currently have " + count + " active investment(s) in your portfolio.";
        }

        // ── Fallback ──────────────────────────────────────────────────────
        return "Great question! I'm still learning about that specific topic. "
             + "Here's what I suggest:\n"
             + "• Check the AI Recommendations page for personalised suggestions\n"
             + "• Visit the Risk Analyzer for portfolio risk insights\n"
             + "• Try asking about: stocks, bonds, ETFs, diversification, risk, or DCA";
    }

    // ── Contextual response builders ──────────────────────────────────────────

    private String buildPortfolioSummaryResponse(List<Investment> investments,
                                                  List<Portfolio>  portfolios) {
        if (investments == null || investments.isEmpty()) {
            return "You don't have any active investments yet. "
                 + "Create a portfolio and add investments to get started!";
        }
        double totalInv = 0, totalVal = 0;
        int active = 0;
        for (Investment inv : investments) {
            if (!"ACTIVE".equals(inv.getStatus())) continue;
            totalInv += inv.getInvestedAmount().doubleValue();
            totalVal += inv.getCurrentValue().doubleValue();
            active++;
        }
        double pl  = totalVal - totalInv;
        double pct = totalInv > 0 ? (pl / totalInv) * 100 : 0;
        return String.format(
            "Here's your portfolio summary:\n"
          + "• Active Investments: %d\n"
          + "• Total Invested: $%,.2f\n"
          + "• Current Value: $%,.2f\n"
          + "• Profit / Loss: %s$%,.2f (%.1f%%)\n"
          + "Overall your portfolio is %s. Use the AI Recommendations page for detailed insights!",
            active, totalInv, totalVal,
            pl >= 0 ? "+" : "-", Math.abs(pl), Math.abs(pct),
            pct > 5 ? "performing well 📈" : pct >= 0 ? "roughly flat ➡️" : "in a drawdown 📉"
        );
    }

    private String buildRiskSummaryResponse(List<Investment> investments) {
        if (investments == null || investments.isEmpty()) {
            return "No investments to analyze. Add investments to get a risk assessment.";
        }
        int cryptoCount = 0, bondCount = 0;
        for (Investment inv : investments) {
            if (!"ACTIVE".equals(inv.getStatus())) continue;
            String type = inv.getAssetType() != null ? inv.getAssetType().toUpperCase() : "";
            if ("CRYPTO".equals(type))    cryptoCount++;
            if ("BOND".equals(type))      bondCount++;
        }
        String level = cryptoCount > investments.size() / 2 ? "HIGH ⚠️"
                     : bondCount > investments.size() / 2   ? "LOW ✅"
                     : "MODERATE 🟡";
        return "Quick risk assessment:\n"
             + "• Estimated Risk Level: " + level + "\n"
             + "• Crypto positions: " + cryptoCount + "\n"
             + "• Bond/stable positions: " + bondCount + "\n"
             + "For a detailed risk score with metrics, visit the Risk Analyzer page!";
    }

    private boolean containsAny(String text, String... keywords) {
        for (String kw : keywords) {
            if (text.contains(kw)) return true;
        }
        return false;
    }
}
