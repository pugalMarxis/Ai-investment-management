package com.investms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Represents an AI-generated investment recommendation.
 */
public class AiRecommendation {

    private int           recId;
    private int           userId;
    private String        recommendation;
    private BigDecimal    confidenceScore;  // 0–100
    private String        recType;          // BUY | SELL | HOLD | REBALANCE | DIVERSIFY
    private Integer       assetId;          // nullable
    private String        assetName;        // joined
    private String        assetSymbol;      // joined
    private boolean       read;
    private LocalDateTime generatedAt;

    public AiRecommendation() {
        this.confidenceScore = BigDecimal.ZERO;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getRecId()                        { return recId; }
    public void          setRecId(int v)                   { this.recId = v; }

    public int           getUserId()                       { return userId; }
    public void          setUserId(int v)                  { this.userId = v; }

    public String        getRecommendation()               { return recommendation; }
    public void          setRecommendation(String v)       { this.recommendation = v; }

    public BigDecimal    getConfidenceScore()               { return confidenceScore; }
    public void          setConfidenceScore(BigDecimal v)   { this.confidenceScore = v; }

    public String        getRecType()                       { return recType; }
    public void          setRecType(String v)               { this.recType = v; }

    public Integer       getAssetId()                       { return assetId; }
    public void          setAssetId(Integer v)              { this.assetId = v; }

    public String        getAssetName()                     { return assetName; }
    public void          setAssetName(String v)             { this.assetName = v; }

    public String        getAssetSymbol()                   { return assetSymbol; }
    public void          setAssetSymbol(String v)           { this.assetSymbol = v; }

    public boolean       isRead()                           { return read; }
    public void          setRead(boolean v)                 { this.read = v; }

    public LocalDateTime getGeneratedAt()                   { return generatedAt; }
    public void          setGeneratedAt(LocalDateTime v)    { this.generatedAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public String getTypeBadgeClass() {
        switch (recType == null ? "" : recType.toUpperCase()) {
            case "BUY":        return "badge-success";
            case "SELL":       return "badge-danger";
            case "HOLD":       return "badge-info";
            case "REBALANCE":  return "badge-warning";
            case "DIVERSIFY":  return "badge-primary";
            default:           return "badge-secondary";
        }
    }

    public String getConfidenceLabel() {
        if (confidenceScore == null) return "Unknown";
        double score = confidenceScore.doubleValue();
        if (score >= 80) return "High";
        if (score >= 50) return "Medium";
        return "Low";
    }
}
