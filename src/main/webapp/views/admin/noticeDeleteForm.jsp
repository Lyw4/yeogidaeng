<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 🔒 [보안] 세션 권한 체크 (role로 통일)
    String userRole = (String) session.getAttribute("role"); 
    if (userRole == null || !"ADMIN".equals(userRole)) {
%>
        <script>
            alert("⚠️ 관리자 권한이 필요합니다.");
            location.href = "noticeManage.jsp";
        </script>
<%
        return;
    }

    // 2. 넘어온 글 번호 검증
    String postIdStr = request.getParameter("post_id");
    if (postIdStr == null || postIdStr.trim().equals("")) {
%>
        <script>
            alert("❌ 잘못된 접근입니다. 대상 번호가 없습니다.");
            history.back();
        </script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>삭제 처리 중...</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; background: #f4f6f9; }
    .loading-box { text-align: center; padding: 20px; }
</style>
<script>
    // 페이지 로딩 완료 후 0.5초 대기 후 전송 (사용자에게 "처리 중"임을 보여주기 위함)
    window.onload = function() {
        setTimeout(function() {
            document.getElementById("deleteForm").submit();
        }, 500);
    }
</script>
</head>
<body>
    <div class="loading-box">
        <p>⏳ 데이터를 안전하게 삭제하고 있습니다...</p>
        <p style="font-size: 0.9em; color: #666;">잠시만 기다려주세요.</p>
    </div>
    
    <form id="deleteForm" action="noticeDeletePro.jsp" method="post">
        <input type="hidden" name="post_id" value="<%= postIdStr %>">
    </form>
</body>
</html>