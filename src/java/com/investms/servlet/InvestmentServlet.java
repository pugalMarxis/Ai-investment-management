package com.investms.servlet;

import com.investms.dao.AssetDAO;
import com.investms.dao.InvestmentDAO;
import com.investms.dao.PortfolioDAO;
import com.investms.dao.TransactionDAO;
import com.investms.model.Asset;
import com.investms.model.Investment;
import com.investms.model.Portfolio;
import com.investms.model.Transaction;
import com.investms.util.SessionUtil;
import com.investms.util.ValidationUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Handles all investment CRUD operations.
 * Actions: list | create | view | sell | history
 */
@WebServlet("/InvestmentServlet")
public class InvestmentServlet extends HttpServlet {

    private final InvestmentDAO  investmentDAO  = new InvestmentDAO();
    private final PortfolioDAO   portfolioDAO   = new PortfolioDAO();
    private final AssetDAO       assetDAO       = new AssetDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) action = "list";
        int userId = SessionUtil.getLoggedUserId(req);

        switch (action) {
            case "list":
                req.setAttribute("investments", investmentDAO.findByUser(userId));
                req.getRequestDispatcher("/investment/investments.jsp").forward(req, resp);
                break;

            case "add":
                req.setAttribute("portfolios", portfolioDAO.findByUser(userId));
                req.setAttribute("assets",     assetDAO.findAll());
                req.getRequestDispatcher("/investment/add-investment.jsp").forward(req, resp);
                break;

            case "view":
                int viewId = ValidationUtil.parseIntSafe(req.getParameter("id"), -1);
                Investment inv = investmentDAO.findById(viewId);
                if (inv == null || inv.getUserId() != userId) {
                    resp.sendRedirect(req.getContextPath() + "/InvestmentServlet");
                    return;
                }
                req.setAttribute("investment", inv);
                req.getRequestDispatcher("/investment/view-investment.jsp").forward(req, resp);
                break;

            case "sell":
                int sellId = ValidationUtil.parseIntSafe(req.getParameter("id"), -1);
                Investment sellInv = investmentDAO.findById(sellId);
                if (sellInv != null && sellInv.getUserId() == userId) {
                    investmentDAO.sellInvestment(sellId, userId);
                    // Record SELL transaction
                    Transaction txn = new Transaction();
                    txn.setUserId(userId);
                    txn.setInvestmentId(sellId);
                    txn.setType("SELL");
                    txn.setAmount(sellInv.getCurrentValue());
                    txn.setDescription("Sold: " + sellInv.getPlanName());
                    txn.setStatus("COMPLETED");
                    transactionDAO.create(txn);
                }
                resp.sendRedirect(req.getContextPath() + "/InvestmentServlet?sold=true");
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/InvestmentServlet");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        int    userId      = SessionUtil.getLoggedUserId(req);
        int    portfolioId = ValidationUtil.parseIntSafe(req.getParameter("portfolioId"), -1);
        int    assetId     = ValidationUtil.parseIntSafe(req.getParameter("assetId"),     -1);
        String planName    = req.getParameter("planName");
        double amount      = ValidationUtil.parseDoubleSafe(req.getParameter("investedAmount"), 0);
        double buyPrice    = ValidationUtil.parseDoubleSafe(req.getParameter("buyPrice"),      0);
        double units       = buyPrice > 0 ? amount / buyPrice : 0;
        String notes       = req.getParameter("notes");

        // ── Validation ─────────────────────────────────────────────────────
        if (ValidationUtil.isNullOrEmpty(planName) || portfolioId < 1 || assetId < 1 || amount <= 0) {
            req.setAttribute("error", "Please fill in all required fields with valid values.");
            req.setAttribute("portfolios", portfolioDAO.findByUser(userId));
            req.setAttribute("assets",     assetDAO.findAll());
            req.getRequestDispatcher("/investment/add-investment.jsp").forward(req, resp);
            return;
        }

        // Check portfolio belongs to user
        Portfolio portfolio = portfolioDAO.findById(portfolioId);
        if (portfolio == null || portfolio.getUserId() != userId) {
            req.setAttribute("error", "Invalid portfolio selected.");
            req.setAttribute("portfolios", portfolioDAO.findByUser(userId));
            req.setAttribute("assets",     assetDAO.findAll());
            req.getRequestDispatcher("/investment/add-investment.jsp").forward(req, resp);
            return;
        }

        // ── Check wallet balance ────────────────────────────────────────────
        BigDecimal walletBal = transactionDAO.getWalletBalance(userId);
        if (walletBal.compareTo(new BigDecimal(amount + "")) < 0) {
            req.setAttribute("error",
                "Insufficient wallet balance. Available: $" + String.format("%,.2f", walletBal));
            req.setAttribute("portfolios", portfolioDAO.findByUser(userId));
            req.setAttribute("assets",     assetDAO.findAll());
            req.getRequestDispatcher("/investment/add-investment.jsp").forward(req, resp);
            return;
        }

        // ── Create investment ───────────────────────────────────────────────
        Investment inv = new Investment();
        inv.setUserId(userId);
        inv.setPortfolioId(portfolioId);
        inv.setAssetId(assetId);
        inv.setPlanName(planName.trim());
        inv.setInvestedAmount(new BigDecimal(amount + ""));
        inv.setUnits(new BigDecimal(String.format("%.6f", units)));
        inv.setBuyPrice(new BigDecimal(buyPrice + ""));
        inv.setNotes(notes);

        if (investmentDAO.create(inv)) {
            // Deduct from wallet
            transactionDAO.withdraw(userId, new BigDecimal(amount + ""),
                "Investment: " + planName);
            // Record BUY transaction
            Transaction txn = new Transaction();
            txn.setUserId(userId);
            txn.setInvestmentId(inv.getInvestmentId());
            txn.setType("BUY");
            txn.setAmount(new BigDecimal(amount + ""));
            txn.setDescription("Bought: " + planName);
            txn.setStatus("COMPLETED");
            transactionDAO.create(txn);

            resp.sendRedirect(req.getContextPath() + "/InvestmentServlet?created=true");
        } else {
            req.setAttribute("error", "Failed to create investment. Please try again.");
            req.setAttribute("portfolios", portfolioDAO.findByUser(userId));
            req.setAttribute("assets",     assetDAO.findAll());
            req.getRequestDispatcher("/investment/add-investment.jsp").forward(req, resp);
        }
    }
}
