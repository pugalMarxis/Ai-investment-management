<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>500 — Server Error | InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
</head>
<body style="background:#0d0d1a;display:flex;align-items:center;justify-content:center;min-height:100vh;">
<div style="text-align:center;padding:40px;max-width:500px;">
    <div style="font-size:6rem;font-weight:900;color:#ef4444;">500</div>
    <h2 style="color:#f1f5f9;font-size:1.5rem;margin:16px 0 8px;">Internal Server Error</h2>
    <p style="color:#64748b;margin-bottom:12px;">Something went wrong on our end. Please try again.</p>
    <% if (exception != null) { %>
    <pre style="background:#1a1a2e;color:#94a3b8;padding:16px;border-radius:8px;
                font-size:0.75rem;text-align:left;overflow:auto;margin-bottom:20px;
                border:1px solid #1e293b;"><%= exception.getMessage() %></pre>
    <% } %>
    <a href="<%= request.getContextPath() %>/DashboardServlet"
       style="display:inline-flex;align-items:center;gap:8px;
              background:#ef4444;color:#fff;padding:12px 24px;
              border-radius:8px;font-weight:700;text-decoration:none;">
        <i class="fas fa-home"></i> Back to Dashboard
    </a>
</div>
</body>
</html>
