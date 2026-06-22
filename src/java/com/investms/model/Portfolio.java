package com.investms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Represents an investment portfolio belonging to a user.
 */
public class Portfolio {

    private int           portfolioId;
    private int           userId;
    private String        userFullName;   // joined
    private String        portfolioName;
    private String        description;
    private String        riskLevel;      // LOW | MEDIUM | HIGH
    private BigDecimal    targetAmount;
    private BigDecimal    currentValue;
    private String        status;         // ACTIVE | CLOSED | PAUSED
    private int           totalInvestments;
    private BigDecimal    totalInvested;
    private BigDecimal    totalCurrentValue;
    private BigDecimal    totalProfitLoss;
    private BigDecimal    returnPct;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    // ── Constructors ──────────────────────────────────────────────────────────

    public Portfolio() {
        this.targetAmount     = BigDecimal.ZERO;
        this.currentValue     = BigDecimal.ZERO;
        this.totalInvested    = BigDecimal.ZERO;
        this.totalCurrentValue= BigDecimal.ZERO;
        this.totalProfitLoss  = BigDecimal.ZERO;
        this.returnPct        = BigDecimal.ZERO;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getPortfolioId()         { return portfolioId; }
    public void          setPortfolioId(int v)     { this.portfolioId = v; }

    public int           getUserId()              { return userId; }
    public void          setUserId(int v)          { this.userId = v; }

    public String        getUserFullName()              { return userFullName; }
    public void          setUserFullName(String v)      { this.userFullName = v; }

    public String        getPortfolioName()             { return portfolioName; }
    public void          setPortfolioName(String v)     { this.portfolioName = v; }

    public String        getDescription()               { return description; }
    public void          setDescription(String v)       { this.description = v; }

    public String        getRiskLevel()                 { return riskLevel; }
    public void          setRiskLevel(String v)         { this.riskLevel = v; }

    public BigDecimal    getTargetAmount()              { return targetAmount; }
    public void          setTargetAmount(BigDecimal v)  { this.targetAmount = v; }

    public BigDecimal    getCurrentValue()              { return currentValue; }
    public void          setCurrentValue(BigDecimal v)  { this.currentValue = v; }

    public String        getStatus()                    { return status; }
    public void          setStatus(String v)            { this.status = v; }

    public int           getTotalInvestments()          { return totalInvestments; }
    public void          setTotalInvestments(int v)     { this.totalInvestments = v; }

    public BigDecimal    getTotalInvested()             { return totalInvested; }
    public void          setTotalInvested(BigDecimal v) { this.totalInvested = v; }

    public BigDecimal    getTotalCurrentValue()              { return totalCurrentValue; }
    public void          setTotalCurrentValue(BigDecimal v)  { this.totalCurrentValue = v; }

    public BigDecimal    getTotalProfitLoss()               { return totalProfitLoss; }
    public void          setTotalProfitLoss(BigDecimal v)   { this.totalProfitLoss = v; }

    public BigDecimal    getReturnPct()                { return returnPct; }
    public void          setReturnPct(BigDecimal v)    { this.returnPct = v; }

    public LocalDateTime getCreatedAt()                     { return createdAt; }
    public void          setCreatedAt(LocalDateTime v)      { this.createdAt = v; }

    public LocalDateTime getUpdatedAt()                     { return updatedAt; }
    public void          setUpdatedAt(LocalDateTime v)      { this.updatedAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public boolean isProfitable() {
        return totalProfitLoss != null && totalProfitLoss.compareTo(BigDecimal.ZERO) > 0;
    }

    public String getRiskBadgeClass() {
        if ("HIGH".equalsIgnoreCase(riskLevel))   return "badge-danger";
        if ("LOW".equalsIgnoreCase(riskLevel))    return "badge-success";
        return "badge-warning";
    }

    @Override
    public String toString() {
        return "Portfolio{id=" + portfolioId + ", name='" + portfolioName + "', risk=" + riskLevel + "}";
    }
}
