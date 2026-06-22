package com.investms.ai;

import com.investms.model.Investment;
import com.investms.model.Portfolio;
import com.investms.model.Transaction;
import com.investms.model.User;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * AI Feature #5 — Intelligent Report Generator
 *
 * Generates rich HTML/text investment reports with AI commentary:
 * - Performance Report
 * - Risk Assessment Report
 * - Portfolio Health Report
 * - Transaction Summary Report
 */
public class AIReportGenerator {

    private static final DateTimeFormatter FMT = DateTimeFormatter.ofPattern("dd MMM yyyy, HH:mm");

    public enum ReportType {
        PERFORMANCE, RISK, PORTFOLIO_HEALTH, TRANSACTION_SUMMARY
    }

    // ── Main report builder ───────────────────────────────────────────────────

    public InvestmentReport generateReport(ReportType type, User user,
                                           List<Investment>  investments,
                                           List<Portfolio>   portfolios,
                                           List<Transaction> transactions) {
        InvestmentReport report = new InvestmentReport();
        report.setGeneratedAt(LocalDateTime.now().format(FMT));
        report.setUserName(user.getFullName());
        report.setReportType(type.name());

        switch (type) {
            case PERFORMANCE:
                buildPerformanceReport(report, investments, portfolios);
                break;
            case RISK:
                buildRiskReport(report, investments, portfolios);
                break;
            case PORTFOLIO_HEALTH:
                buildHealthReport(report, investments, portfolios);
                break;
            case TRANSACTION_SUMMARY:
                buildTransactionReport(report, transactions, investments);
                break;
        }
        return report;
    }

    // ── Report type builders ──────────────────────────────────────────────────

    private void buildPerformanceReport(InvestmentReport report,
                                         List<Investment> investments,
                                         List<Portfolio>  portfolios) {
        report.setTitle("Investment Performance Report");
        report.setIcon("fa-chart-line");

        double totalInvested = 0, totalValue = 0;
        List<Map<String, String>> rows = new ArrayList<>();
        int active = 0, sold = 0;

        for (Investment inv : investments) {
            double inv_amt = inv.getInvestedAmount().doubleValue();
            double cur_val = inv.getCurrentValue().doubleValue();
            double ret     = inv.getReturnPct().doubleValue();
            if ("ACTIVE".equals(inv.getStatus())) { totalInvested += inv_amt; totalValue += cur_val; active++; }
            else if ("SOLD".equals(inv.getStatus())) sold++;

            Map<String, String> row = new LinkedHashMap<>();
            row.put("Plan",    inv.getPlanName());
            row.put("Asset",   inv.getAssetName() + " (" + (inv.getAssetSymbol() != null ? inv.getAssetSymbol() : "") + ")");
            row.put("Type",    inv.getAssetType());
            row.put("Invested","$" + String.format("%,.2f", inv_amt));
            row.put("Value",   "$" + String.format("%,.2f", cur_val));
            row.put("P&L",     (ret >= 0 ? "+" : "") + "$" + String.format("%,.2f", Math.abs(cur_val - inv_amt)));
            row.put("Return",  (ret >= 0 ? "+" : "") + String.format("%.2f", ret) + "%");
            row.put("Status",  inv.getStatus());
            rows.add(row);
        }

        double overallReturn = totalInvested > 0
            ? ((totalValue - totalInvested) / totalInvested) * 100 : 0;

        List<String> summary = new ArrayList<>();
        summary.add("Total Invested: $" + String.format("%,.2f", totalInvested));
        summary.add("Current Portfolio Value: $" + String.format("%,.2f", totalValue));
        summary.add("Total P&L: " + (totalValue >= totalInvested ? "+" : "") +
                    "$" + String.format("%,.2f", Math.abs(totalValue - totalInvested)));
        summary.add("Overall Return: " + String.format("%.2f", overallReturn) + "%");
        summary.add("Active Investments: " + active);
        summary.add("Sold Investments: " + sold);
        summary.add("Total Portfolios: " + (portfolios != null ? portfolios.size() : 0));

        String aiInsight;
        if (overallReturn > 15)
            aiInsight = "Outstanding performance! Your portfolio has achieved a " +
                String.format("%.1f", overallReturn) + "% return. AI recommends taking partial profits " +
                "and rebalancing to maintain risk levels. Consider increasing allocation to stable assets.";
        else if (overallReturn > 5)
            aiInsight = "Good performance with " + String.format("%.1f", overallReturn) +
                "% return. Portfolio is growing steadily. AI suggests maintaining current strategy " +
                "and adding to outperforming positions on market dips.";
        else if (overallReturn >= 0)
            aiInsight = "Portfolio is slightly positive at " + String.format("%.1f", overallReturn) +
                "%. Consider reviewing underperformers and redirecting capital to higher-growth opportunities.";
        else
            aiInsight = "Portfolio shows a " + String.format("%.1f", Math.abs(overallReturn)) +
                "% decline. AI recommends portfolio review: identify the core underperformers, " +
                "consider tax-loss harvesting, and rebalance toward lower-risk assets.";

        report.setSummaryItems(summary);
        report.setTableHeaders(new ArrayList<>(rows.isEmpty() ? List.of() : rows.get(0).keySet()));
        report.setTableRows(rows);
        report.setAiInsight(aiInsight);
    }

    private void buildRiskReport(InvestmentReport report,
                                  List<Investment>  investments,
                                  List<Portfolio>   portfolios) {
        report.setTitle("Risk Assessment Report");
        report.setIcon("fa-shield-alt");

        AIRiskAnalyzer   analyzer  = new AIRiskAnalyzer();
        AIRiskAnalyzer.RiskReport riskResult = analyzer.analyzePortfolio(investments, portfolios);

        List<String> summary = new ArrayList<>();
        summary.add("Overall Risk Score: " + riskResult.getOverallScore() + "/100");
        summary.add("Risk Level: " + riskResult.getRiskLabel());
        summary.add("Asset Risk Component: " + riskResult.getWeightedAssetRisk());
        summary.add("Concentration Penalty: +" + riskResult.getConcentrationPenalty());
        summary.add("P&L Drawdown Penalty: +" + riskResult.getPlPenalty());
        summary.add("Diversification Bonus: -" + riskResult.getDiversityBonus());
        summary.add("Distinct Asset Types: " + riskResult.getDistinctAssetTypes());
        summary.add("Underperforming Positions: " + riskResult.getLoserCount());

        List<Map<String, String>> rows = new ArrayList<>();
        if (riskResult.getAllocationByType() != null) {
            for (Map.Entry<String, Double> e : riskResult.getAllocationByType().entrySet()) {
                Map<String, String> row = new LinkedHashMap<>();
                double pct = riskResult.getTotalValue() > 0
                    ? (e.getValue() / riskResult.getTotalValue()) * 100 : 0;
                row.put("Asset Type",  e.getKey());
                row.put("Value",       "$" + String.format("%,.2f", e.getValue()));
                row.put("Allocation",  String.format("%.1f", pct) + "%");
                rows.add(row);
            }
        }

        report.setSummaryItems(summary);
        report.setTableHeaders(rows.isEmpty() ? new ArrayList<>() : new ArrayList<>(rows.get(0).keySet()));
        report.setTableRows(rows);
        report.setAiInsight(riskResult.getMessage() + " " + riskResult.getRecommendation());
    }

    private void buildHealthReport(InvestmentReport report,
                                    List<Investment>  investments,
                                    List<Portfolio>   portfolios) {
        report.setTitle("Portfolio Health Report");
        report.setIcon("fa-heartbeat");

        AIPortfolioAnalyzer analyzer = new AIPortfolioAnalyzer();
        AIPortfolioAnalyzer.PortfolioAnalysisReport health =
            analyzer.analyze(investments, portfolios);

        List<String> summary = new ArrayList<>();
        summary.add("Health Score: " + health.getHealthScore() + "/100 — " + health.getHealthLabel());
        summary.add("Total Invested: $" + String.format("%,.2f", health.getTotalInvested()));
        summary.add("Current Value:  $" + String.format("%,.2f", health.getTotalCurrentValue()));
        summary.add("Overall Return: " + String.format("%.1f", health.getOverallReturn()) + "%");
        summary.add("Active Positions: " + health.getActiveCount());
        if (health.getBestPerformer() != null)
            summary.add("Best Performer: " + health.getBestPerformer().getPlanName() +
                        " (+" + String.format("%.1f", health.getBestReturn()) + "%)");
        if (health.getWorstPerformer() != null)
            summary.add("Worst Performer: " + health.getWorstPerformer().getPlanName() +
                        " (" + String.format("%.1f", health.getWorstReturn()) + "%)");

        List<Map<String, String>> rows = new ArrayList<>();
        for (Map.Entry<String, String> e : health.getSectorPct().entrySet()) {
            Map<String, String> row = new LinkedHashMap<>();
            row.put("Sector",     e.getKey());
            row.put("Allocation", e.getValue() + "%");
            Double val = health.getSectorValue().get(e.getKey());
            row.put("Value", val != null ? "$" + String.format("%,.2f", val) : "—");
            rows.add(row);
        }

        StringBuilder suggestions = new StringBuilder();
        for (String s : health.getSuggestions()) {
            suggestions.append("• ").append(s).append("\n");
        }

        report.setSummaryItems(summary);
        report.setTableHeaders(rows.isEmpty() ? new ArrayList<>() : new ArrayList<>(rows.get(0).keySet()));
        report.setTableRows(rows);
        report.setAiInsight(health.getSummary() + "\n\nAI Improvement Suggestions:\n" + suggestions);
    }

    private void buildTransactionReport(InvestmentReport report,
                                         List<Transaction> transactions,
                                         List<Investment>  investments) {
        report.setTitle("Transaction Summary Report");
        report.setIcon("fa-receipt");

        double totalDeposits = 0, totalWithdrawals = 0, totalBuys = 0, totalSells = 0;
        List<Map<String, String>> rows = new ArrayList<>();

        int limit = Math.min(transactions != null ? transactions.size() : 0, 50);
        for (int i = 0; i < limit; i++) {
            Transaction t = transactions.get(i);
            double amt = t.getAmount().doubleValue();
            switch (t.getType()) {
                case "DEPOSIT":    totalDeposits    += amt; break;
                case "WITHDRAWAL": totalWithdrawals += amt; break;
                case "BUY":        totalBuys        += amt; break;
                case "SELL":       totalSells       += amt; break;
            }
            Map<String, String> row = new LinkedHashMap<>();
            row.put("Date",    t.getCreatedAt() != null ? t.getCreatedAt().toLocalDate().toString() : "—");
            row.put("Type",    t.getType());
            row.put("Amount",  "$" + String.format("%,.2f", amt));
            row.put("Status",  t.getStatus());
            row.put("Reference", t.getReferenceNo() != null ? t.getReferenceNo() : "—");
            rows.add(row);
        }

        double netFlow = totalDeposits + totalSells - totalWithdrawals - totalBuys;

        List<String> summary = new ArrayList<>();
        summary.add("Total Transactions Shown: " + limit);
        summary.add("Total Deposited: $" + String.format("%,.2f", totalDeposits));
        summary.add("Total Withdrawn: $" + String.format("%,.2f", totalWithdrawals));
        summary.add("Total Buy Orders: $" + String.format("%,.2f", totalBuys));
        summary.add("Total Sell Orders: $" + String.format("%,.2f", totalSells));
        summary.add("Net Capital Flow: " + (netFlow >= 0 ? "+" : "") +
                    "$" + String.format("%,.2f", netFlow));

        String aiInsight = "Transaction analysis complete. " +
            (totalDeposits > totalWithdrawals
                ? "Net positive capital inflow of $" + String.format("%,.2f", totalDeposits - totalWithdrawals) +
                  ". You are consistently investing — this is a healthy pattern."
                : "Net capital outflow detected. Ensure withdrawals are planned and " +
                  "not impacting your investment strategy.");

        report.setSummaryItems(summary);
        report.setTableHeaders(rows.isEmpty() ? new ArrayList<>() : new ArrayList<>(rows.get(0).keySet()));
        report.setTableRows(rows);
        report.setAiInsight(aiInsight);
    }

    // ── Report model ──────────────────────────────────────────────────────────

    public static class InvestmentReport {
        private String              title;
        private String              icon;
        private String              reportType;
        private String              userName;
        private String              generatedAt;
        private List<String>        summaryItems   = new ArrayList<>();
        private List<String>        tableHeaders   = new ArrayList<>();
        private List<Map<String, String>> tableRows = new ArrayList<>();
        private String              aiInsight;

        public String              getTitle()          { return title; }
        public void                setTitle(String v)  { this.title = v; }
        public String              getIcon()           { return icon; }
        public void                setIcon(String v)   { this.icon = v; }
        public String              getReportType()     { return reportType; }
        public void                setReportType(String v) { this.reportType = v; }
        public String              getUserName()       { return userName; }
        public void                setUserName(String v) { this.userName = v; }
        public String              getGeneratedAt()    { return generatedAt; }
        public void                setGeneratedAt(String v) { this.generatedAt = v; }
        public List<String>        getSummaryItems()   { return summaryItems; }
        public void                setSummaryItems(List<String> v) { this.summaryItems = v; }
        public List<String>        getTableHeaders()   { return tableHeaders; }
        public void                setTableHeaders(List<String> v) { this.tableHeaders = v; }
        public List<Map<String, String>> getTableRows() { return tableRows; }
        public void                setTableRows(List<Map<String, String>> v) { this.tableRows = v; }
        public String              getAiInsight()      { return aiInsight; }
        public void                setAiInsight(String v) { this.aiInsight = v; }
    }
}
