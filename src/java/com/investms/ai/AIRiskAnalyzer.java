package com.investms.ai;

import com.investms.model.Investment;
import com.investms.model.Portfolio;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AI Feature #2 — Risk Prediction & Portfolio Risk Analyzer
 *
 * Calculates a composite risk score (0–100) for a user's
 * portfolio using volatility, diversification, concentration,
 * and drawdown metrics.
 */
public class AIRiskAnalyzer {

    // Risk labels mapped from score ranges
    public static final String RISK_VERY_LOW  = "VERY LOW";
    public static final String RISK_LOW       = "LOW";
    public static final String RISK_MODERATE  = "MODERATE";
    public static final String RISK_HIGH      = "HIGH";
    public static final String RISK_VERY_HIGH = "VERY HIGH";

    // ── Main analysis method ──────────────────────────────────────────────────

    public RiskReport analyzePortfolio(List<Investment> investments, List<Portfolio> portfolios) {
        RiskReport report = new RiskReport();

        if (investments == null || investments.isEmpty()) {
            report.setOverallScore(0);
            report.setRiskLabel(RISK_VERY_LOW);
            report.setMessage("No investments found. Risk score is 0.");
            report.setRecommendation("Start investing to generate a risk profile.");
            return report;
        }

        // ── Metric 1: Asset type risk weights ─────────────────────────────
        Map<String, Integer> typeRisk = new HashMap<>();
        typeRisk.put("CRYPTO",      90);
        typeRisk.put("STOCK",       60);
        typeRisk.put("ETF",         40);
        typeRisk.put("MUTUAL_FUND", 35);
        typeRisk.put("COMMODITY",   50);
        typeRisk.put("REAL_ESTATE", 45);
        typeRisk.put("BOND",        20);
        typeRisk.put("OTHER",       55);

        double totalValue = 0;
        Map<String, Double> allocationByType = new HashMap<>();

        for (Investment inv : investments) {
            if (!"ACTIVE".equals(inv.getStatus())) continue;
            double val  = inv.getCurrentValue().doubleValue();
            String type = inv.getAssetType() != null ? inv.getAssetType().toUpperCase() : "OTHER";
            totalValue += val;
            allocationByType.merge(type, val, Double::sum);
        }

        // Weighted average risk score based on allocation
        double weightedRisk = 0;
        if (totalValue > 0) {
            for (Map.Entry<String, Double> e : allocationByType.entrySet()) {
                int    w   = typeRisk.getOrDefault(e.getKey(), 55);
                double pct = e.getValue() / totalValue;
                weightedRisk += pct * w;
            }
        }

        // ── Metric 2: Concentration penalty ───────────────────────────────
        double concentrationPenalty = 0;
        if (totalValue > 0) {
            for (double typeVal : allocationByType.values()) {
                double pct = typeVal / totalValue;
                if (pct > 0.6) concentrationPenalty += 15; // >60% in one type
                else if (pct > 0.4) concentrationPenalty += 7;
            }
        }

        // ── Metric 3: Portfolio P&L volatility penalty ─────────────────────
        double plPenalty = 0;
        int    loserCount = 0;
        for (Investment inv : investments) {
            if (!"ACTIVE".equals(inv.getStatus())) continue;
            double ret = inv.getReturnPct().doubleValue();
            if (ret < -20)      { plPenalty += 12; loserCount++; }
            else if (ret < -10) { plPenalty +=  6; loserCount++; }
        }

        // ── Metric 4: Portfolio count diversity bonus ──────────────────────
        double diversityBonus = 0;
        int distinctTypes = allocationByType.size();
        if (distinctTypes >= 4)      diversityBonus = 10;
        else if (distinctTypes >= 3) diversityBonus =  6;
        else if (distinctTypes >= 2) diversityBonus =  3;

        // ── Composite score ────────────────────────────────────────────────
        double raw = weightedRisk + concentrationPenalty + plPenalty - diversityBonus;
        int    score = (int) Math.min(100, Math.max(0, raw));

        // ── Build report ───────────────────────────────────────────────────
        report.setOverallScore(score);
        report.setRiskLabel(scoreToLabel(score));
        report.setWeightedAssetRisk((int) weightedRisk);
        report.setConcentrationPenalty((int) concentrationPenalty);
        report.setPlPenalty((int) plPenalty);
        report.setDiversityBonus((int) diversityBonus);
        report.setLoserCount(loserCount);
        report.setDistinctAssetTypes(distinctTypes);
        report.setAllocationByType(allocationByType);
        report.setTotalValue(totalValue);

        // Narrative
        report.setMessage(buildMessage(score, distinctTypes, loserCount));
        report.setRecommendation(buildRecommendation(score, allocationByType, distinctTypes));

        return report;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private String scoreToLabel(int score) {
        if (score <= 20) return RISK_VERY_LOW;
        if (score <= 40) return RISK_LOW;
        if (score <= 60) return RISK_MODERATE;
        if (score <= 80) return RISK_HIGH;
        return RISK_VERY_HIGH;
    }

    private String buildMessage(int score, int types, int losers) {
        StringBuilder sb = new StringBuilder();
        if (score <= 20)
            sb.append("Your portfolio has very low risk — predominantly stable, low-volatility assets.");
        else if (score <= 40)
            sb.append("Your portfolio carries low risk. Good balance of stability and growth.");
        else if (score <= 60)
            sb.append("Moderate risk portfolio. Balanced mix of growth and income assets.");
        else if (score <= 80)
            sb.append("High risk detected. Significant exposure to volatile assets.");
        else
            sb.append("Very high risk! Portfolio is heavily concentrated in volatile assets.");

        if (losers > 0)
            sb.append(" ").append(losers).append(" investment(s) are in significant drawdown.");
        if (types < 2)
            sb.append(" Very low diversification — single asset type detected.");
        return sb.toString();
    }

    private String buildRecommendation(int score, Map<String, Double> alloc, int types) {
        if (score > 75)
            return "Immediate action recommended: reduce crypto/high-volatility exposure, "
                 + "add 20–30% bonds/ETFs, and implement stop-loss strategies.";
        if (score > 55)
            return "Consider rebalancing: shift 15–20% from high-risk assets to bonds or dividend stocks. "
                 + "Review stop-loss levels for volatile positions.";
        if (score > 35)
            return "Portfolio is reasonably balanced. Monitor high-risk positions monthly "
                 + "and maintain current diversification.";
        return "Portfolio risk is well-managed. Continue current strategy and review annually.";
    }

    // ── Inner result class ────────────────────────────────────────────────────

    public static class RiskReport {
        private int    overallScore;
        private String riskLabel;
        private int    weightedAssetRisk;
        private int    concentrationPenalty;
        private int    plPenalty;
        private int    diversityBonus;
        private int    loserCount;
        private int    distinctAssetTypes;
        private double totalValue;
        private String message;
        private String recommendation;
        private Map<String, Double> allocationByType = new HashMap<>();

        // Getters & Setters
        public int    getOverallScore()             { return overallScore; }
        public void   setOverallScore(int v)         { this.overallScore = v; }
        public String getRiskLabel()                { return riskLabel; }
        public void   setRiskLabel(String v)         { this.riskLabel = v; }
        public int    getWeightedAssetRisk()         { return weightedAssetRisk; }
        public void   setWeightedAssetRisk(int v)    { this.weightedAssetRisk = v; }
        public int    getConcentrationPenalty()      { return concentrationPenalty; }
        public void   setConcentrationPenalty(int v) { this.concentrationPenalty = v; }
        public int    getPlPenalty()                 { return plPenalty; }
        public void   setPlPenalty(int v)            { this.plPenalty = v; }
        public int    getDiversityBonus()            { return diversityBonus; }
        public void   setDiversityBonus(int v)       { this.diversityBonus = v; }
        public int    getLoserCount()                { return loserCount; }
        public void   setLoserCount(int v)           { this.loserCount = v; }
        public int    getDistinctAssetTypes()        { return distinctAssetTypes; }
        public void   setDistinctAssetTypes(int v)   { this.distinctAssetTypes = v; }
        public double getTotalValue()                { return totalValue; }
        public void   setTotalValue(double v)        { this.totalValue = v; }
        public String getMessage()                   { return message; }
        public void   setMessage(String v)           { this.message = v; }
        public String getRecommendation()            { return recommendation; }
        public void   setRecommendation(String v)    { this.recommendation = v; }
        public Map<String, Double> getAllocationByType()              { return allocationByType; }
        public void   setAllocationByType(Map<String, Double> v)     { this.allocationByType = v; }

        /** CSS class for risk badge. */
        public String getRiskBadgeClass() {
            switch (riskLabel == null ? "" : riskLabel) {
                case "VERY LOW":  return "risk-badge-green";
                case "LOW":       return "risk-badge-teal";
                case "MODERATE":  return "risk-badge-yellow";
                case "HIGH":      return "risk-badge-orange";
                case "VERY HIGH": return "risk-badge-red";
                default:          return "risk-badge-grey";
            }
        }

        /** 0–100 gauge percentage. */
        public String getGaugeColor() {
            if (overallScore <= 25) return "#10b981";
            if (overallScore <= 50) return "#f59e0b";
            if (overallScore <= 75) return "#f97316";
            return "#ef4444";
        }
    }
}
