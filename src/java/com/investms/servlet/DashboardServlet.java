package com.investms.servlet;

import com.investms.dao.*;
import com.investms.model.*;
import com.investms.util.SessionUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

/**
 * Loads all dashboard data and forwards to dashboard.jsp.
 */
@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {

    private final InvestmentDAO  investmentDAO  = new InvestmentDAO();
    private final PortfolioDAO   portfolioDAO   = new PortfolioDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final NotificationDAO notifDAO      = new NotificationDAO();
    private final UserDAO        userDAO        = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        int userId = SessionUtil.getLoggedUserId(req);

        // ── Key metrics ────────────────────────────────────────────────────
        BigDecimal totalInvested    = investmentDAO.getTotalInvestedByUser(userId);
        BigDecimal totalCurrentVal  = investmentDAO.getTotalCurrentValueByUser(userId);
        BigDecimal totalProfitLoss  = totalCurrentVal.subtract(totalInvested);
        BigDecimal walletBalance    = transactionDAO.getWalletBalance(userId);
        BigDecimal totalDeposited   = transactionDAO.getTotalDeposited(userId);

        // Return percentage
        BigDecimal returnPct = BigDecimal.ZERO;
        if (totalInvested.compareTo(BigDecimal.ZERO) > 0) {
            returnPct = totalProfitLoss
                    .divide(totalInvested, 4, RoundingMode.HALF_UP)
                    .multiply(new BigDecimal("100"))
                    .setScale(2, RoundingMode.HALF_UP);
        }

        int portfolioCount  = portfolioDAO.countByUser(userId);
        int investmentCount = investmentDAO.countByUser(userId);

        // ── Lists ──────────────────────────────────────────────────────────
        List<Portfolio>   portfolios    = portfolioDAO.findByUser(userId);
        List<Investment>  investments   = investmentDAO.findByUser(userId);
        List<Transaction> recentTxns    = transactionDAO.findByUser(userId);
        List<Notification> notifications = notifDAO.findByUser(userId);
        int unreadNotif = notifDAO.countUnread(userId);

        // Admin extras
        int totalUsers = 0;
        if (SessionUtil.getLoggedUser(req).isAdmin()) {
            totalUsers = userDAO.countInvestors();
        }

        // ── Set attributes ─────────────────────────────────────────────────
        req.setAttribute("totalInvested",   totalInvested);
        req.setAttribute("totalCurrentVal", totalCurrentVal);
        req.setAttribute("totalProfitLoss", totalProfitLoss);
        req.setAttribute("walletBalance",   walletBalance);
        req.setAttribute("totalDeposited",  totalDeposited);
        req.setAttribute("returnPct",       returnPct);
        req.setAttribute("portfolioCount",  portfolioCount);
        req.setAttribute("investmentCount", investmentCount);
        req.setAttribute("portfolios",      portfolios);
        req.setAttribute("investments",     investments);
        req.setAttribute("recentTxns",      recentTxns);
        req.setAttribute("notifications",   notifications);
        req.setAttribute("unreadNotif",     unreadNotif);
        req.setAttribute("totalUsers",      totalUsers);

        req.getRequestDispatcher("/dashboard/dashboard.jsp").forward(req, resp);
    }
}
