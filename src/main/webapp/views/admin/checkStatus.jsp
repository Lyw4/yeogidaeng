<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.admin.AdminDAO" %> 

<%
    String sessionId = (String)session.getAttribute("id");
    
    // 🔥 로그인을 한 유저에 대해서만 상태를 검사합니다! (비로그인 방문자 보호)
    if (sessionId != null) {
        // 1. 세션에서 상태값 가져오기
        Integer userStatus = (Integer)session.getAttribute("userStatus");
        
        // 2. 세션에 상태값이 없다면 DB 조회 후 세션에 저장
        if (userStatus == null) {
            AdminDAO checkDao = new AdminDAO();
            userStatus = checkDao.getMemberStatus(sessionId);
            session.setAttribute("userStatus", userStatus); 
        }
        
        // 3. 상태 체크 (1: 정상, 0: 탈퇴, -1: 정지) -> 1이 아니면 무조건 쫓아냄
        if (userStatus != null && userStatus != 1) {
%>
            <script>
                alert("활동 정지 또는 탈퇴된 계정은 이용이 제한됩니다.");
                location.href = "<%= request.getContextPath() %>/views/main/mainPage.jsp";
            </script>
<%
            return; 
        }
    }
%>