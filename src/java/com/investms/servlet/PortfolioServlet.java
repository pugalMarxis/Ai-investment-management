package com.investms.servlet;

import com.investms.dao.PortfolioDAO;
import com.investms.model.Portfolio;
import com.investms.util.SessionUtil;
import com.investms.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Handles all portfolio CRUD operations.
 * Actions: list | create | edit | update | delete
 */
@WebServlet("/PortfolioServlet")
public class PortfolioServlet extends HttpServlet {

    private final PortfolioDAO portfolioDAO = new PortfolioDAO();

    // ── GET: list or show edit form ────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) action = "list";

        int userId = SessionUtil.getLoggedUserId(req);

        switch (action) {
            case "list":
                List<Portfolio> portfolios = portfolioDAO.findByUser(userId);
                req.setAttribute("portfolios", portfolios);
                req.getRequestDispatcher("/portfolio/portfolios.jsp").forward(req, resp);
                break;

            case "edit":
                int pid = ValidationUtil.parseIntSafe(req.getParameter("id"), -1);
                Portfolio p = portfolioDAO.findById(pid);
                if (p == null || p.getUserId() != userId) {
                    resp.sendRedirect(req.getContextPath() + "/PortfolioServlet");
                    return;
                }
                req.setAttribute("portfolio", p);
                req.getRequestDispatcher("/portfolio/edit-portfolio.jsp").forward(req, resp);
                break;

            case "delete":
                int delId = ValidationUtil.parseIntSafe(req.getParameter("id"), -1);
                portfolioDAO.delete(delId, userId);
                resp.sendRedirect(req.getContextPath() + "/PortfolioServlet?deleted=true");
                break;

            default:
                resp.sendRedirect(req.getContextPath() + "/PortfolioServlet");
        }
    }

    // ── POST: create or update ─────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (!SessionUtil.requireLogin(req, resp)) return;

        int    userId        = SessionUtil.getLoggedUserId(req);
        String action        = req.getParameter("action");
        String portfolioName = req.getParameter("portfolioName");
        String description   = req.getParameter("description");
        String riskLevel     = req.getParameter("riskLevel");
        String targetStr     = req.getParameter("targetAmount");

        // Validation
        if (ValidationUtil.isNullOrEmpty(portfolioName)) {
            req.setAttribute("error", "Portfolio name is required.");
            req.getRequestDispatcher(
                "create".equals(action) ? "/portfolio/add-portfolio.jsp" : "/portfolio/edit-portfolio.jsp"
            ).forward(req, resp);
            return;
        }

        BigDecimal targetAmount = new BigDecimal(
            ValidationUtil.parseDoubleSafe(targetStr, 0.0) + ""
        );

        if ("create".equals(action)) {
            Portfolio p = new Portfolio();
            p.setUserId(userId);
            p.setPortfolioName(portfolioName.trim());
            p.setDescription(description);
            p.setRiskLevel(riskLevel != null ? riskLevel : "MEDIUM");
            p.setTargetAmount(targetAmount);

            if (portfolioDAO.create(p)) {
                resp.sendRedirect(req.getContextPath() + "/PortfolioServlet?created=true");
            } else {
                req.setAttribute("error", "Failed to create portfolio. Please try again.");
                req.getRequestDispatcher("/portfolio/add-portfolio.jsp").forward(req, resp);
            }

        } else if ("update".equals(action)) {
            int pid = ValidationUtil.parseIntSafe(req.getParameter("portfolioId"), -1);
            Portfolio p = portfolioDAO.findById(pid);
            if (p == null || p.getUserId() != userId) {
                resp.sendRedirect(req.getContextPath() + "/PortfolioServlet");
                return;
            }
            p.setPortfolioName(portfolioName.trim());
            p.setDescription(description);
            p.setRiskLevel(riskLevel != null ? riskLevel : "MEDIUM");
            p.setTargetAmount(targetAmount);
            String status = req.getParameter("status");
            if (status != null) p.setStatus(status);

            if (portfolioDAO.update(p)) {
                resp.sendRedirect(req.getContextPath() + "/PortfolioServlet?updated=true");
            } else {
                req.setAttribute("error", "Failed to update portfolio.");
                req.setAttribute("portfolio", p);
                req.getRequestDispatcher("/portfolio/edit-portfolio.jsp").forward(req, resp);
            }
        }
    }
}
