package com.investms.ai;

import com.investms.model.Investment;
import com.investms.model.Portfolio;

import java.util.*;

/**
 * AI Feature #4 — Portfolio Performance Analyzer
 *
 * Deep-analyses the user's full portfolio and generates:
 * - Performance scores per portfolio
 * - Sector/asset breakdown
 * - Best & worst performers
 * - Improvement suggestions
 * - Health score (0–100)
 */
public class AIPortfolioAnalyzer {

    // ── Public analysis entry point ───────────────────────────────────────────

    public PortfolioAnalysisReport analyze(List<Investment>  investments,
                                           List<Portfolio>   portfolios) {
        PortfolioAnalysisReport report = new PortfolioAnalysisReport();

        if (investments == null || investments.isEmpty()) {
            report.setHealthScore(0);
            report.setSummary("No investments to analyze.");
            report.setTopSuggestion("Add investments to your portfolio to receive AI analysis.");
            return report;
        }

        // ── Active investments only ────────────────────────────────────────
        List<Investment> active = new ArrayList<>();
        for (Investment inv : investments) {
            if ("ACTIVE".equals(inv.getStatus())) active.add(inv);
        }

        if (active.isEmpty()) {
            report.setHealthScore(0);
            report.setSummary("No active investments found.");
            report.setTopSuggestion("All investments appear to be sold or matured. Add new positions.");
            return report;
        }

        // ── Core metrics ───────────────────────────────────────────────────
        double totalInvested = 0, totalValue = 0;
        Investment bestPerformer  = null, worstPerformer = null;
        double bestReturn = Double.MIN_VALUE, worstReturn = Double.MAX_VALUE;
        Map<String, Double> sectorAlloc = new LinkedHashMap<>();
        Map<String, Double> sectorValue = new LinkedHashMap<>();

        for (Investment inv : active) {
            double inv_amt = inv.getInvestedAmount().doubleValue();
            double cur_val = inv.getCurrentValue().doubleValue();
            double ret     = inv.getReturnPct().doubleValue();
            totalInvested += inv_amt;
            totalValue    += cur_val;

            String type = inv.getAssetType() != null ? inv.getAssetType() : "OTHER";
            sectorAlloc.merge(type, inv_amt, Double::sum);
            sectorValue.merge(type, cur_val, Double::sum);

            if (ret > bestReturn)  { bestReturn = ret;  bestPerformer  = inv; }
            if (ret < worstReturn) { worstReturn = ret; worstPerformer = inv; }
        }

        double overallReturn = totalInvested > 0
            ? ((totalValue - totalInvested) / totalInvested) * 100 : 0;

        // ── Health score calculation ──────────────────────────────────────
        // Starts at 50, adjusted by metrics
        int healthScore = 50;

        // Diversity score (+0 to +20)
        int types = sectorAlloc.size();
        if      (types >= 5) healthScore += 20;
        else if (types >= 4) healthScore += 15;
        else if (types >= 3) healthScore += 10;
        else if (types >= 2) healthScore +=  5;

        // Return performance (+0 to +20 or -0 to -20)
        if      (overallReturn > 20)  healthScore += 20;
        else if (overallReturn > 10)  healthScore += 15;
        else if (overallReturn >  5)  healthScore += 10;
        else if (overallReturn >  0)  healthScore +=  5;
        else if (overallReturn > -5)  healthScore -=  5;
        else if (overallReturn > -15) healthScore -= 10;
        else                          healthScore -= 20;

        // Concentration penalty (-0 to -10)
        if (totalInvested > 0) {
            for (double sectVal : sectorAlloc.values()) {
                double pct = sectVal / totalInvested;
                if (pct > 0.7) healthScore -= 10;
                else if (pct > 0.5) healthScore -= 5;
            }
        }

        // Number of investments diversity (+0 to +10)
        if      (active.size() >= 10) healthScore += 10;
        else if (active.size() >= 6)  healthScore +=  7;
        else if (active.size() >= 3)  healthScore +=  4;

        healthScore = Math.min(100, Math.max(0, healthScore));

        // ── Sector allocation percentages ─────────────────────────────────
        Map<String, String> sectorPct = new LinkedHashMap<>();
        if (totalInvested > 0) {
            for (Map.Entry<String, Double> e : sectorAlloc.entrySet()) {
                sectorPct.put(e.getKey(), String.format("%.1f", (e.getValue() / totalInvested) * 100));
            }
        }

        // ── Improvement suggestions ────────────────────────────────────────
        List<String> suggestions = buildSuggestions(
            active, overallReturn, types, sectorAlloc, totalInvested);

        // ── Assemble report ────────────────────────────────────────────────
        report.setHealthScore(healthScore);
        report.setTotalInvested(totalInvested);
        report.setTotalCurrentValue(totalValue);
        report.setOverallReturn(overallReturn);
        report.setActiveCount(active.size());
        report.setBestPerformer(bestPerformer);
        report.setWorstPerformer(worstPerformer);
        report.setBestReturn(bestReturn == Double.MIN_VALUE ? 0 : bestReturn);
        report.setWorstReturn(worstReturn == Double.MAX_VALUE ? 0 : worstReturn);
        report.setSectorAllocation(sectorAlloc);
        report.setSectorPct(sectorPct);
        report.setSectorValue(sectorValue);
        report.setSuggestions(suggestions);
        report.setSummary(buildSummary(healthScore, overallReturn, types, active.size()));
        report.setTopSuggestion(suggestions.isEmpty() ? "Portfolio looks great!" : suggestions.get(0));

        return report;
    }

    // ── Suggestion builder ────────────────────────────────────────────────────

    private List<String> buildSuggestions(List<Investment> active, double overallReturn,
                                           int types, Map<String, Double> sectorAlloc,
                                           double totalInvested) {
        List<String> list = new ArrayList<>();

        if (types < 3)
            list.add("Diversify across at least 3–4 asset classes. Currently only "
                   + types + " type(s) detected. Add bonds and ETFs for stability.");

        if (overallReturn < -5)
            list.add("Portfolio return is " + String.format("%.1f", overallReturn) + "%. "
                   + "Consider reviewing underperformers and rebalancing toward stable assets.");

        if (active.size() < 4)
            list.add("Only " + active.size() + " active investment(s). "
                   + "Increase to 6–10 positions for better risk distribution.");

        if (totalInvested > 0) {
            for (Map.Entry<String, Double> e : sectorAlloc.entrySet()) {
                double pct = (e.getValue() / totalInvested) * 100;
                if (pct > 60) {
                    list.add(String.format("%.0f", pct) + "% concentrated in "
                           + e.getKey() + ". Reduce to max 40% per asset class.");
                }
            }
        }

        if (overallReturn > 20)
            list.add("Strong " + String.format("%.1f", overallReturn) + "% return! "
                   + "Take partial profits and rebalance to lock in gains and reduce risk.");

        if (list.isEmpty())
            list.add("Portfolio is well-structured. Maintain diversification and review quarterly.");

        return list;
    }

    private String buildSummary(int health, double ret, int types, int count) {
        String grade = health >= 80 ? "Excellent" : health >= 60 ? "Good"
                     : health >= 40 ? "Fair" : "Needs Improvement";
        return String.format(
            "Portfolio Health: %s (%d/100). "
          + "Overall return: %.1f%%. "
          + "%d active investment(s) across %d asset class(es).",
            grade, health, ret, count, types);
    }

    // ── Report model ──────────────────────────────────────────────────────────

    public static class PortfolioAnalysisReport {
        private int                 healthScore;
        private double              totalInvested;
        private double              totalCurrentValue;
        private double              overallReturn;
        private int                 activeCount;
        private Investment          bestPerformer;
        private Investment          worstPerformer;
        private double              bestReturn;
        private double              worstReturn;
        private Map<String, Double> sectorAllocation = new LinkedHashMap<>();
        private Map<String, String> sectorPct        = new LinkedHashMap<>();
        private Map<String, Double> sectorValue      = new LinkedHashMap<>();
        private List<String>        suggestions      = new ArrayList<>();
        private String              summary;
        private String              topSuggestion;

        // Getters & Setters
        public int                 getHealthScore()                        { return healthScore; }
        public void                setHealthScore(int v)                   { this.healthScore = v; }
        public double              getTotalInvested()                      { return totalInvested; }
        public void                setTotalInvested(double v)              { this.totalInvested = v; }
        public double              getTotalCurrentValue()                  { return totalCurrentValue; }
        public void                setTotalCurrentValue(double v)          { this.totalCurrentValue = v; }
        public double              getOverallReturn()                      { return overallReturn; }
        public void                setOverallReturn(double v)              { this.overallReturn = v; }
        public int                 getActiveCount()                        { return activeCount; }
        public void                setActiveCount(int v)                   { this.activeCount = v; }
        public Investment          getBestPerformer()                      { return bestPerformer; }
        public void                setBestPerformer(Investment v)          { this.bestPerformer = v; }
        public Investment          getWorstPerformer()                     { return worstPerformer; }
        public void                setWorstPerformer(Investment v)         { this.worstPerformer = v; }
        public double              getBestReturn()                         { return bestReturn; }
        public void                setBestReturn(double v)                 { this.bestReturn = v; }
        public double              getWorstReturn()                        { return worstReturn; }
        public void                setWorstReturn(double v)               { this.worstReturn = v; }
        public Map<String, Double> getSectorAllocation()                  { return sectorAllocation; }
        public void                setSectorAllocation(Map<String, Double> v) { this.sectorAllocation = v; }
        public Map<String, String> getSectorPct()                         { return sectorPct; }
        public void                setSectorPct(Map<String, String> v)    { this.sectorPct = v; }
        public Map<String, Double> getSectorValue()                       { return sectorValue; }
        public void                setSectorValue(Map<String, Double> v)  { this.sectorValue = v; }
        public List<String>        getSuggestions()                       { return suggestions; }
        public void                setSuggestions(List<String> v)         { this.suggestions = v; }
        public String              getSummary()                           { return summary; }
        public void                setSummary(String v)                   { this.summary = v; }
        public String              getTopSuggestion()                     { return topSuggestion; }
        public void                setTopSuggestion(String v)             { this.topSuggestion = v; }

        public String getHealthLabel() {
            if (healthScore >= 80) return "Excellent";
            if (healthScore >= 60) return "Good";
            if (healthScore >= 40) return "Fair";
            return "Needs Work";
        }
        public String getHealthColor() {
            if (healthScore >= 80) return "#10b981";
            if (healthScore >= 60) return "#3b82f6";
            if (healthScore >= 40) return "#f59e0b";
            return "#ef4444";
        }
        public double getProfitLoss()  { return totalCurrentValue - totalInvested; }
    }
}
