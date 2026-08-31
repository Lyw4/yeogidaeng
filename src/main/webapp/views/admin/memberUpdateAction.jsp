<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.admin.AdminDAO" %>
<jsp:include page="checkStatus.jsp" />
<%
    request.setCharacterEncoding("UTF-8");

    // 🔥 1. 보안: 최신 로그인 시스템(role)에 맞춰 관리자 권한 완벽 검증!
    String sessionId = (String)session.getAttribute("id");
    String role = (String)session.getAttribute("role");

    if (sessionId == null || !"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자 권한이 없습니다."); 
            location.href='memberList.jsp';
        </script>
<%
        return;
    }

    try {
        // 2. 파라미터 받기
        String id = request.getParameter("id");
        int status = Integer.parseInt(request.getParameter("status"));
        String roleParam = request.getParameter("role");

        // 3. DAO 호출
        AdminDAO dao = new AdminDAO();
        dao.updateMember(id, status, roleParam);

        // 4. 성공 시 이동
        response.sendRedirect("memberList.jsp");
        
    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("처리 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>