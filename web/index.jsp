<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.investms.util.SessionUtil" %>
<%
    /* Root redirect */
    if (SessionUtil.isLoggedIn(request)) {
        response.sendRedirect(request.getContextPath() + "/DashboardServlet");
    } else {
        response.sendRedirect(request.getContextPath() + "/auth/login.jsp");
    }
%>
