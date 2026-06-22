package com.investms.model;

import java.time.LocalDateTime;

/**
 * Represents a tradable asset (stock, crypto, bond, etc.).
 */
public class Asset {

    private int           assetId;
    private String        assetName;
    private String        assetType;   // STOCK | BOND | CRYPTO | ...
    private String        symbol;
    private String        description;
    private int           riskRating;  // 1–10
    private LocalDateTime createdAt;

    public Asset() {}

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getAssetId()             { return assetId; }
    public void          setAssetId(int v)         { this.assetId = v; }

    public String        getAssetName()             { return assetName; }
    public void          setAssetName(String v)     { this.assetName = v; }

    public String        getAssetType()             { return assetType; }
    public void          setAssetType(String v)     { this.assetType = v; }

    public String        getSymbol()                { return symbol; }
    public void          setSymbol(String v)        { this.symbol = v; }

    public String        getDescription()           { return description; }
    public void          setDescription(String v)   { this.description = v; }

    public int           getRiskRating()            { return riskRating; }
    public void          setRiskRating(int v)       { this.riskRating = v; }

    public LocalDateTime getCreatedAt()             { return createdAt; }
    public void          setCreatedAt(LocalDateTime v) { this.createdAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public String getRiskLabel() {
        if (riskRating <= 3) return "LOW";
        if (riskRating <= 6) return "MEDIUM";
        return "HIGH";
    }

    public String getTypeBadgeClass() {
        switch (assetType == null ? "" : assetType.toUpperCase()) {
            case "STOCK":       return "badge-primary";
            case "CRYPTO":      return "badge-danger";
            case "BOND":        return "badge-success";
            case "ETF":         return "badge-info";
            case "MUTUAL_FUND": return "badge-secondary";
            case "COMMODITY":   return "badge-warning";
            default:            return "badge-dark";
        }
    }
}
