package com.investms.servlet;

import com.investms.dao.TransactionDAO;
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
 * Handles all transaction operations:
 * GET  actions: list | deposit-form | withdraw-form
 * POST actions: deposit | withdraw
 */
@WebServlet("/TransactionServlet")
public class TransactionServlet extends HttpServlet {

    private final TransactionDAO transactionDAO = new TransactionDAO();

    // ── GET ────────────────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) action = "list";
        int userId = SessionUtil.getLoggedUserId(req);

        switch (action) {
            case "list":
                List<Transaction> all = transactionDAO.findByUser(userId);
                req.setAttribute("transactions",   all);
                req.setAttribute("walletBalance",  transactionDAO.getWalletBalance(userId));
                req.setAttribute("totalDeposited", transactionDAO.getTotalDeposited(userId));
                req.setAttribute("totalWithdrawn", transactionDAO.getTotalWithdrawn(userId));
                req.getRequestDispatcher("/transaction/transactions.jsp").forward(req, resp);
                break;

            case "deposit":
                req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
                req.getRequestDispatcher("/transaction/deposit.jsp").forward(req, resp);
                break;

            case "withdraw":
                req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
                req.getRequestDispatcher("/transaction/withdraw.jsp").forward(req, resp);
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/TransactionServlet");
        }
    }

    // ── POST ───────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        String action = req.getParameter("action");
        int    userId = SessionUtil.getLoggedUserId(req);

        if ("deposit".equals(action)) {
            handleDeposit(req, resp, userId);
        } else if ("withdraw".equals(action)) {
            handleWithdraw(req, resp, userId);
        } else {
            resp.sendRedirect(req.getContextPath() + "/TransactionServlet");
        }
    }

    // ── Deposit handler ────────────────────────────────────────────────────
    private void handleDeposit(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {

        String amtStr = req.getParameter("amount");
        String desc   = req.getParameter("description");

        double amount = ValidationUtil.parseDoubleSafe(amtStr, 0);
        if (!ValidationUtil.isPositiveAmount(amount)) {
            req.setAttribute("error", "Please enter a valid positive amount.");
            req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
            req.getRequestDispatcher("/transaction/deposit.jsp").forward(req, resp);
            return;
        }
        if (amount > 1_000_000) {
            req.setAttribute("error", "Maximum single deposit is $1,000,000.");
            req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
            req.getRequestDispatcher("/transaction/deposit.jsp").forward(req, resp);
            return;
        }

        boolean ok = transactionDAO.deposit(
            userId,
            new BigDecimal(amount + ""),
            ValidationUtil.isNullOrEmpty(desc) ? "Wallet Deposit" : desc.trim()
        );

        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/TransactionServlet?deposited=true");
        } else {
            req.setAttribute("error", "Deposit failed. Please try again.");
            req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
            req.getRequestDispatcher("/transaction/deposit.jsp").forward(req, resp);
        }
    }

    // ── Withdrawal handler ─────────────────────────────────────────────────
    private void handleWithdraw(HttpServletRequest req, HttpServletResponse resp, int userId)
            throws ServletException, IOException {

        String amtStr = req.getParameter("amount");
        String desc   = req.getParameter("description");

        double amount = ValidationUtil.parseDoubleSafe(amtStr, 0);
        if (!ValidationUtil.isPositiveAmount(amount)) {
            req.setAttribute("error", "Please enter a valid positive amount.");
            req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
            req.getRequestDispatcher("/transaction/withdraw.jsp").forward(req, resp);
            return;
        }

        BigDecimal balance = transactionDAO.getWalletBalance(userId);
        if (balance.compareTo(new BigDecimal(amount + "")) < 0) {
            req.setAttribute("error",
                "Insufficient balance. Available: $" + String.format("%,.2f", balance));
            req.setAttribute("walletBalance", balance);
            req.getRequestDispatcher("/transaction/withdraw.jsp").forward(req, resp);
            return;
        }

        boolean ok = transactionDAO.withdraw(
            userId,
            new BigDecimal(amount + ""),
            ValidationUtil.isNullOrEmpty(desc) ? "Wallet Withdrawal" : desc.trim()
        );

        if (ok) {
            resp.sendRedirect(req.getContextPath() + "/TransactionServlet?withdrawn=true");
        } else {
            req.setAttribute("error", "Withdrawal failed. Please try again.");
            req.setAttribute("walletBalance", transactionDAO.getWalletBalance(userId));
            req.getRequestDispatcher("/transaction/withdraw.jsp").forward(req, resp);
        }
    }
}
