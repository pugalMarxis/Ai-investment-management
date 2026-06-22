package com.investms.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Represents a financial transaction (deposit, withdrawal, buy, sell, etc.).
 */
public class Transaction {

    private int           transactionId;
    private int           userId;
    private String        userFullName;   // joined
    private Integer       investmentId;   // nullable
    private String        planName;       // joined from investments
    private String        type;           // DEPOSIT | WITHDRAWAL | BUY | SELL | DIVIDEND | FEE
    private BigDecimal    amount;
    private BigDecimal    fee;
    private BigDecimal    balanceAfter;
    private String        description;
    private String        status;         // PENDING | COMPLETED | FAILED | CANCELLED
    private String        referenceNo;
    private LocalDateTime createdAt;

    public Transaction() {
        this.amount       = BigDecimal.ZERO;
        this.fee          = BigDecimal.ZERO;
        this.balanceAfter = BigDecimal.ZERO;
    }

    // ── Getters & Setters ─────────────────────────────────────────────────────

    public int           getTransactionId()               { return transactionId; }
    public void          setTransactionId(int v)           { this.transactionId = v; }

    public int           getUserId()                      { return userId; }
    public void          setUserId(int v)                  { this.userId = v; }

    public String        getUserFullName()                 { return userFullName; }
    public void          setUserFullName(String v)         { this.userFullName = v; }

    public Integer       getInvestmentId()                 { return investmentId; }
    public void          setInvestmentId(Integer v)        { this.investmentId = v; }

    public String        getPlanName()                     { return planName; }
    public void          setPlanName(String v)             { this.planName = v; }

    public String        getType()                         { return type; }
    public void          setType(String v)                 { this.type = v; }

    public BigDecimal    getAmount()                       { return amount; }
    public void          setAmount(BigDecimal v)           { this.amount = v; }

    public BigDecimal    getFee()                          { return fee; }
    public void          setFee(BigDecimal v)              { this.fee = v; }

    public BigDecimal    getBalanceAfter()                 { return balanceAfter; }
    public void          setBalanceAfter(BigDecimal v)     { this.balanceAfter = v; }

    public String        getDescription()                  { return description; }
    public void          setDescription(String v)          { this.description = v; }

    public String        getStatus()                       { return status; }
    public void          setStatus(String v)               { this.status = v; }

    public String        getReferenceNo()                  { return referenceNo; }
    public void          setReferenceNo(String v)          { this.referenceNo = v; }

    public LocalDateTime getCreatedAt()                    { return createdAt; }
    public void          setCreatedAt(LocalDateTime v)     { this.createdAt = v; }

    // ── Helpers ───────────────────────────────────────────────────────────────

    public boolean isCredit() {
        return "DEPOSIT".equals(type) || "DIVIDEND".equals(type) || "SELL".equals(type);
    }

    public String getTypeBadgeClass() {
        switch (type == null ? "" : type.toUpperCase()) {
            case "DEPOSIT":    return "badge-success";
            case "WITHDRAWAL": return "badge-danger";
            case "BUY":        return "badge-primary";
            case "SELL":       return "badge-info";
            case "DIVIDEND":   return "badge-success";
            case "FEE":        return "badge-warning";
            default:           return "badge-secondary";
        }
    }

    public String getStatusBadgeClass() {
        switch (status == null ? "" : status.toUpperCase()) {
            case "COMPLETED":  return "badge-success";
            case "PENDING":    return "badge-warning";
            case "FAILED":     return "badge-danger";
            case "CANCELLED":  return "badge-secondary";
            default:           return "badge-dark";
        }
    }
}
