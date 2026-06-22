package com.investms.servlet;

import com.investms.dao.UserDAO;
import com.investms.model.User;
import com.investms.util.PasswordUtil;
import com.investms.util.SessionUtil;
import com.investms.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Handles new investor registration.
 */
@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        if (SessionUtil.isLoggedIn(req)) {
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
            return;
        }
        req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String fullName  = req.getParameter("fullName");
        String email     = req.getParameter("email");
        String phone     = req.getParameter("phone");
        String password  = req.getParameter("password");
        String confirm   = req.getParameter("confirmPassword");

        // ── Preserve form values on error ──────────────────────────────────
        req.setAttribute("fullNameValue", ValidationUtil.sanitize(fullName));
        req.setAttribute("emailValue",    ValidationUtil.sanitize(email));
        req.setAttribute("phoneValue",    ValidationUtil.sanitize(phone));

        // ── Validation ─────────────────────────────────────────────────────
        if (ValidationUtil.isNullOrEmpty(fullName) || ValidationUtil.isNullOrEmpty(email)
                || ValidationUtil.isNullOrEmpty(password)) {
            req.setAttribute("error", "Full name, email, and password are required.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        if (!ValidationUtil.isValidEmail(email)) {
            req.setAttribute("error", "Please enter a valid email address.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        if (!ValidationUtil.isStrongPassword(password)) {
            req.setAttribute("error",
                "Password must be at least 8 characters with uppercase, lowercase, number, and special character.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        if (!password.equals(confirm)) {
            req.setAttribute("error", "Passwords do not match.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        if (userDAO.emailExists(email.trim().toLowerCase())) {
            req.setAttribute("error", "An account with this email already exists.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        // ── Build and persist user ─────────────────────────────────────────
        User newUser = new User();
        newUser.setFullName(fullName.trim());
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setPasswordHash(PasswordUtil.hashPassword(password));
        newUser.setPhone(phone != null ? phone.trim() : "");
        newUser.setRoleId(2); // INVESTOR

        if (!userDAO.register(newUser)) {
            req.setAttribute("error", "Registration failed. Please try again.");
            req.getRequestDispatcher("/auth/register.jsp").forward(req, resp);
            return;
        }

        // ── Auto-login after registration ──────────────────────────────────
        // Reload with role info
        User savedUser = userDAO.findByEmail(newUser.getEmail());
        if (savedUser != null) {
            SessionUtil.loginUser(req, savedUser);
            resp.sendRedirect(req.getContextPath() + "/dashboard/dashboard.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/auth/login.jsp?registered=true");
        }
    }
}
