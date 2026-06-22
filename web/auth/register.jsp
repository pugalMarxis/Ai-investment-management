<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%
    if (SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/dashboard/dashboard.jsp");
        return;
    }
    String error         = (String) request.getAttribute("error");
    String fullNameVal   = request.getAttribute("fullNameValue") != null ? (String) request.getAttribute("fullNameValue") : "";
    String emailVal      = request.getAttribute("emailValue")    != null ? (String) request.getAttribute("emailValue")    : "";
    String phoneVal      = request.getAttribute("phoneValue")    != null ? (String) request.getAttribute("phoneValue")    : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Register — InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
    <style>
        body { background: #0d0d1a; min-height: 100vh; display: flex; align-items: center; justify-content: center; }
    </style>
</head>
<body class="auth-body">

<div class="auth-wrapper">

    <!-- Left panel -->
    <div class="auth-left">
        <div class="auth-brand-section">
            <div class="auth-logo">
                <i class="fas fa-chart-line"></i>
            </div>
            <h1 class="auth-brand-name">InvestMS</h1>
            <p class="auth-brand-tagline">Start Your Investment Journey</p>
            <div class="auth-features">
                <div class="auth-feature-item">
                    <i class="fas fa-rocket"></i>
                    <span>Quick 2-minute setup</span>
                </div>
                <div class="auth-feature-item">
                    <i class="fas fa-brain"></i>
                    <span>AI-powered insights</span>
                </div>
                <div class="auth-feature-item">
                    <i class="fas fa-chart-bar"></i>
                    <span>Real-time analytics</span>
                </div>
                <div class="auth-feature-item">
                    <i class="fas fa-shield-alt"></i>
                    <span>Secure & encrypted</span>
                </div>
            </div>
        </div>
    </div>

    <!-- Right panel -->
    <div class="auth-right">
        <div class="auth-card">

            <div class="auth-card-header">
                <h2>Create Account</h2>
                <p>Join InvestMS and start investing smarter</p>
            </div>

            <% if (error != null) { %>
            <div class="alert alert-danger">
                <i class="fas fa-exclamation-circle me-2"></i><%= error %>
            </div>
            <% } %>

            <!-- Register Form -->
            <form action="<%= request.getContextPath() %>/RegisterServlet"
                  method="POST" class="auth-form" id="registerForm" novalidate>

                <div class="form-group-custom">
                    <label class="form-label-custom">Full Name *</label>
                    <div class="input-wrapper">
                        <i class="fas fa-user input-icon"></i>
                        <input type="text"
                               name="fullName"
                               class="form-input"
                               placeholder="John Smith"
                               value="<%= fullNameVal %>"
                               required maxlength="120">
                    </div>
                </div>

                <div class="form-group-custom">
                    <label class="form-label-custom">Email Address *</label>
                    <div class="input-wrapper">
                        <i class="fas fa-envelope input-icon"></i>
                        <input type="email"
                               name="email"
                               class="form-input"
                               placeholder="you@example.com"
                               value="<%= emailVal %>"
                               required>
                    </div>
                </div>

                <div class="form-group-custom">
                    <label class="form-label-custom">Phone Number</label>
                    <div class="input-wrapper">
                        <i class="fas fa-phone input-icon"></i>
                        <input type="tel"
                               name="phone"
                               class="form-input"
                               placeholder="+1-555-0100"
                               value="<%= phoneVal %>">
                    </div>
                </div>

                <div class="form-row-two">
                    <div class="form-group-custom">
                        <label class="form-label-custom">Password *</label>
                        <div class="input-wrapper">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password"
                                   name="password"
                                   id="regPassword"
                                   class="form-input"
                                   placeholder="Min. 8 characters"
                                   required>
                            <button type="button"
                                    class="toggle-password"
                                    onclick="togglePassword('regPassword', this)">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>

                    <div class="form-group-custom">
                        <label class="form-label-custom">Confirm Password *</label>
                        <div class="input-wrapper">
                            <i class="fas fa-lock input-icon"></i>
                            <input type="password"
                                   name="confirmPassword"
                                   id="regConfirm"
                                   class="form-input"
                                   placeholder="Repeat password"
                                   required>
                            <button type="button"
                                    class="toggle-password"
                                    onclick="togglePassword('regConfirm', this)">
                                <i class="fas fa-eye"></i>
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Password strength indicator -->
                <div class="password-strength" id="strengthContainer">
                    <div class="strength-bar">
                        <div class="strength-fill" id="strengthFill"></div>
                    </div>
                    <span class="strength-label" id="strengthLabel">Enter a password</span>
                </div>

                <div class="form-check-custom">
                    <input type="checkbox" id="agreeTerms" name="agreeTerms"
                           class="form-check-input-custom" required>
                    <label for="agreeTerms">
                        I agree to the <a href="#" class="auth-link">Terms of Service</a>
                        and <a href="#" class="auth-link">Privacy Policy</a>
                    </label>
                </div>

                <button type="submit" class="btn-auth-primary" id="registerBtn">
                    <i class="fas fa-user-plus me-2"></i>Create Account
                </button>

                <div class="auth-divider"><span>or</span></div>

                <p class="auth-switch-text">
                    Already have an account?
                    <a href="<%= request.getContextPath() %>/LoginServlet" class="auth-link">
                        Sign In
                    </a>
                </p>

            </form>
        </div>
    </div>

</div>

<script>
function togglePassword(fieldId, btn) {
    const field = document.getElementById(fieldId);
    const icon  = btn.querySelector('i');
    if (field.type === 'password') {
        field.type = 'text';
        icon.classList.replace('fa-eye', 'fa-eye-slash');
    } else {
        field.type = 'password';
        icon.classList.replace('fa-eye-slash', 'fa-eye');
    }
}

// Password strength meter
document.getElementById('regPassword').addEventListener('input', function () {
    const val = this.value;
    const fill  = document.getElementById('strengthFill');
    const label = document.getElementById('strengthLabel');
    let score = 0;
    if (val.length >= 8)                                     score++;
    if (/[A-Z]/.test(val))                                   score++;
    if (/[a-z]/.test(val))                                   score++;
    if (/[0-9]/.test(val))                                   score++;
    if (/[^A-Za-z0-9]/.test(val))                            score++;

    const colors = ['#e74c3c','#e67e22','#f1c40f','#2ecc71','#27ae60'];
    const labels = ['Very Weak','Weak','Fair','Strong','Very Strong'];
    fill.style.width  = (score * 20) + '%';
    fill.style.background = colors[score - 1] || '#444';
    label.textContent = labels[score - 1] || 'Enter a password';
});

// Client-side confirm match
document.getElementById('registerForm').addEventListener('submit', function (e) {
    const pw  = document.getElementById('regPassword').value;
    const cpw = document.getElementById('regConfirm').value;
    if (pw !== cpw) {
        e.preventDefault();
        alert('Passwords do not match!');
    }
    const terms = document.getElementById('agreeTerms');
    if (!terms.checked) {
        e.preventDefault();
        alert('Please agree to the Terms of Service.');
    }
});
</script>

</body>
</html>
