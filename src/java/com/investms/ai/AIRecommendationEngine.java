package com.investms.ai;

import com.investms.model.AiRecommendation;
import com.investms.model.Investment;
import com.investms.model.Portfolio;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * AI Feature #1 — Investment Recommendation Engine
 *
 * Analyses user portfolio data and generates personalised
 * buy / sell / hold / diversify recommendations using
 * rule-based scoring (no external API required).
 */
public class AIRecommendationEngine {

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Generate recommendations for a user based on their portfolios and investments.
     *
     * @param portfolios  user's portfolio list
     * @param investments user's active investment list
     * @param userId      user ID (for attaching to returned objects)
     * @return list of AiRecommendation objects (not yet persisted)
     */
    public List<AiRecommendation> generateRecommendations(
            List<Portfolio>  portfolios,
            List<Investment> investments,
            int              userId) {

        List<AiRecommendation> recs = new ArrayList<>();

        // ── 1. No portfolio / empty portfolio ──────────────────────────────
        if (portfolios == null || portfolios.isEmpty()) {
            recs.add(build(userId, null,
                "You have no portfolios yet. Start by creating a LOW or MEDIUM risk portfolio "
              + "to begin your investment journey. Diversification from day one reduces overall risk.",
                "DIVERSIFY", 92.0));
            return recs;
        }

        // ── 2. No investments ──────────────────────────────────────────────
        if (investments == null || investments.isEmpty()) {
            recs.add(build(userId, null,
                "Your portfolio is empty. Consider starting with an S&P 500 ETF (SPY) or a "
              + "Bond fund to establish a stable base. Low-risk assets provide a safety net.",
                "BUY", 88.0));
            return recs;
        }

        // ── 3. Per-investment analysis ─────────────────────────────────────
        double totalInvested  = 0, totalValue = 0;
        int    highRiskCount  = 0, lowRiskCount = 0;
        int    cryptoCount = 0, stockCount = 0, bondCount = 0;

        for (Investment inv : investments) {
            if (!"ACTIVE".equals(inv.getStatus())) continue;
            double invested = inv.getInvestedAmount().doubleValue();
            double current  = inv.getCurrentValue().doubleValue();
            double ret      = inv.getReturnPct().doubleValue();
            totalInvested  += invested;
            totalValue     += current;

            String type = inv.getAssetType() != null ? inv.getAssetType().toUpperCase() : "";
            if ("CRYPTO".equals(type))      cryptoCount++;
            else if ("STOCK".equals(type))  stockCount++;
            else if ("BOND".equals(type))   bondCount++;

            // Strong performer → HOLD
            if (ret > 20) {
                recs.add(build(userId, inv.getAssetId(),
                    "'" + inv.getPlanName() + "' is up " + String.format("%.1f", ret) + "%. "
                  + "Strong performer — consider holding and potentially adding more on dips.",
                    "HOLD", Math.min(95, 70 + ret / 5)));
            }
            // Big loser → SELL or REBALANCE
            else if (ret < -15) {
                recs.add(build(userId, inv.getAssetId(),
                    "'" + inv.getPlanName() + "' is down " + String.format("%.1f", Math.abs(ret)) + "%. "
                  + "Consider cutting losses and reallocating to higher-confidence assets.",
                    "SELL", Math.min(90, 60 + Math.abs(ret) / 3)));
            }
            // Moderate loss → monitor
            else if (ret < -5) {
                recs.add(build(userId, inv.getAssetId(),
                    "'" + inv.getPlanName() + "' shows a " + String.format("%.1f", Math.abs(ret)) + "% decline. "
                  + "Monitor closely. AI suggests waiting for market stabilisation before acting.",
                    "HOLD", 65.0));
            }
        }

        // ── 4. Diversification analysis ────────────────────────────────────
        if (cryptoCount > 0 && bondCount == 0) {
            recs.add(build(userId, null,
                "Your portfolio has " + cryptoCount + " crypto asset(s) but no bonds. "
              + "Adding bond ETFs (e.g. USTB) would reduce overall volatility by 30–40%.",
                "DIVERSIFY", 87.0));
        }
        if (stockCount == 0 && investments.size() >= 2) {
            recs.add(build(userId, null,
                "No equities detected in your portfolio. Stocks historically outperform inflation. "
              + "Consider adding 1–2 blue-chip stocks for long-term growth.",
                "BUY", 82.0));
        }

        // ── 5. Overall return analysis ─────────────────────────────────────
        if (totalInvested > 0) {
            double overallReturn = ((totalValue - totalInvested) / totalInvested) * 100;
            if (overallReturn > 15) {
                recs.add(build(userId, null,
                    "Excellent overall return of " + String.format("%.1f", overallReturn) + "%! "
                  + "Consider rebalancing: take some profits and reinvest in lower-risk assets "
                  + "to lock in gains.",
                    "REBALANCE", 91.0));
            } else if (overallReturn < -10) {
                recs.add(build(userId, null,
                    "Overall portfolio is down " + String.format("%.1f", Math.abs(overallReturn)) + "%. "
                  + "AI recommends a defensive rebalancing: increase bond allocation to 20–30%.",
                    "REBALANCE", 85.0));
            }
        }

        // ── 6. High-risk concentration ─────────────────────────────────────
        if (investments.size() > 0 && (double) cryptoCount / investments.size() > 0.5) {
            recs.add(build(userId, null,
                "Over 50% of your investments are in cryptocurrency — a highly volatile asset class. "
              + "Diversify into ETFs, bonds, or stable stocks to protect capital.",
                "DIVERSIFY", 93.0));
        }

        // ── 7. Minimum recommendations fallback ────────────────────────────
        if (recs.isEmpty()) {
            recs.add(build(userId, null,
                "Your portfolio looks balanced. AI recommends maintaining your current strategy "
              + "and reviewing quarterly. Consider adding to your best-performing assets.",
                "HOLD", 78.0));
        }

        return recs;
    }

    // ── Factory helper ────────────────────────────────────────────────────────
    private AiRecommendation build(int userId, Integer assetId,
                                   String text, String type, double confidence) {
        AiRecommendation r = new AiRecommendation();
        r.setUserId(userId);
        r.setAssetId(assetId);
        r.setRecommendation(text);
        r.setRecType(type);
        r.setConfidenceScore(new BigDecimal(String.format("%.2f", confidence)));
        return r;
    }
}
