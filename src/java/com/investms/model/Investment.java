package com.investms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Represents a single investment within a portfolio.
 */
public class Investment {

    private int           investmentId;
    private int           userId;
    private int           portfolioId;
    private String        portfolioName;  // joined
    private int           assetId;
    private String        assetName;      // joined
    private String        assetType;      // joined
    private String        assetSymbol;    // joined
    private String        planName;
    private BigDecimal    investedAmount;
    private BigDecimal    currentValue;
    private BigDecimal    units;
    private BigDecimal    buyPrice;
    private BigDecimal    currentPrice;
    private BigDecimal    returnPct;
    private String        status;         // ACTIVE | SOLD | MATURED | PENDING
    private String        notes;
    private LocalDateTime investedAt;
    private LocalDateTime updatedAt;

    public Investment() {
        this.investedAmount = BigDecimal.ZERO;
        this.currentValue   = BigDecimal.ZERO;
        this.units          = BigDecimal.ZERO;
        this.buyPrice       = BigDecimal.ZERO;
        this.currentPrice   = BigDecimal.ZERO;
        this.returnPct      = BigDecimal.ZERO;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getInvestmentId()               { return investmentId; }
    public void          setInvestmentId(int v)           { this.investmentId = v; }

    public int           getUserId()                     { return userId; }
    public void          setUserId(int v)                 { this.userId = v; }

    public int           getPortfolioId()                { return portfolioId; }
    public void          setPortfolioId(int v)            { this.portfolioId = v; }

    public String        getPortfolioName()              { return portfolioName; }
    public void          setPortfolioName(String v)       { this.portfolioName = v; }

    public int           getAssetId()                    { return assetId; }
    public void          setAssetId(int v)                { this.assetId = v; }

    public String        getAssetName()                  { return assetName; }
    public void          setAssetName(String v)           { this.assetName = v; }

    public String        getAssetType()                  { return assetType; }
    public void          setAssetType(String v)           { this.assetType = v; }

    public String        getAssetSymbol()                { return assetSymbol; }
    public void          setAssetSymbol(String v)         { this.assetSymbol = v; }

    public String        getPlanName()                   { return planName; }
    public void          setPlanName(String v)            { this.planName = v; }

    public BigDecimal    getInvestedAmount()              { return investedAmount; }
    public void          setInvestedAmount(BigDecimal v)  { this.investedAmount = v; }

    public BigDecimal    getCurrentValue()                { return currentValue; }
    public void          setCurrentValue(BigDecimal v)    { this.currentValue = v; }

    public BigDecimal    getUnits()                       { return units; }
    public void          setUnits(BigDecimal v)           { this.units = v; }

    public BigDecimal    getBuyPrice()                    { return buyPrice; }
    public void          setBuyPrice(BigDecimal v)        { this.buyPrice = v; }

    public BigDecimal    getCurrentPrice()                { return currentPrice; }
    public void          setCurrentPrice(BigDecimal v)    { this.currentPrice = v; }

    public BigDecimal    getReturnPct()                   { return returnPct; }
    public void          setReturnPct(BigDecimal v)       { this.returnPct = v; }

    public String        getStatus()                      { return status; }
    public void          setStatus(String v)              { this.status = v; }

    public String        getNotes()                       { return notes; }
    public void          setNotes(String v)               { this.notes = v; }

    public LocalDateTime getInvestedAt()                  { return investedAt; }
    public void          setInvestedAt(LocalDateTime v)   { this.investedAt = v; }

    public LocalDateTime getUpdatedAt()                   { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v)    { this.updatedAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public BigDecimal getProfitLoss() {
        if (currentValue == null || investedAmount == null) return BigDecimal.ZERO;
        return currentValue.subtract(investedAmount);
    }

    public boolean isProfitable() {
        return getProfitLoss().compareTo(BigDecimal.ZERO) > 0;
    }

    public String getStatusBadgeClass() {
        switch (status == null ? "" : status.toUpperCase()) {
            case "ACTIVE":  return "badge-success";
            case "SOLD":    return "badge-secondary";
            case "MATURED": return "badge-info";
            case "PENDING": return "badge-warning";
            default:        return "badge-dark";
        }
    }
}
