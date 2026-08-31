<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.admin.AdminDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. [보안] 권한 체크
    String userRole = (String) session.getAttribute("role"); 
    if (userRole == null || !"ADMIN".equals(userRole)) {
%>
        <script>
            alert("⚠️ 관리자 권한이 필요합니다."); 
            location.href="noticeManage.jsp";
        </script>
<%
        return;
    }

    // 2. 파라미터 검증 및 예외 처리
    String postIdStr = request.getParameter("post_id");
    int postId = 0;

    try {
        if (postIdStr == null || postIdStr.trim().equals("")) {
            throw new Exception("번호 없음");
        }
        postId = Integer.parseInt(postIdStr); 
    } catch (Exception e) {
%>
        <script>
            alert("❌ 잘못된 요청입니다."); 
            history.back();
        </script>
<%
        return;
    }

    // 3. DB 작업
    AdminDAO adminDAO = new AdminDAO();
    int result = adminDAO.deleteNotice(postId); 

    if (result > 0) {
%>
        <script>
            alert("✅ 공지사항이 삭제되었습니다.");
            location.href = "noticeManage.jsp";
        </script>
<%
    } else {
%>
        <script>
            alert("❌ 삭제할 공지사항을 찾을 수 없거나 DB 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>