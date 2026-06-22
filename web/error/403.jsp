<%@ page contentType="text/html;charset=UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>403 — Access Denied | InvestMS</title>
    <%@ include file="/includes/head.jsp" %>
</head>
<body style="background:#0d0d1a;display:flex;align-items:center;justify-content:center;min-height:100vh;">
<div style="text-align:center;padding:40px;">
    <div style="font-size:6rem;font-weight:900;color:#f59e0b;">403</div>
    <h2 style="color:#f1f5f9;font-size:1.5rem;margin:16px 0 8px;">Access Denied</h2>
    <p style="color:#64748b;margin-bottom:28px;">You don't have permission to access this resource.</p>
    <a href="<%= request.getContextPath() %>/DashboardServlet"
       style="display:inline-flex;align-items:center;gap:8px;
              background:linear-gradient(135deg,#f59e0b,#f97316);
              color:#fff;padding:12px 24px;border-radius:8px;font-weight:700;text-decoration:none;">
        <i class="fas fa-home"></i> Back to Dashboard
    </a>
</div>
</body>
</html>
