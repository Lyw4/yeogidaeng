<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<jsp:include page="checkStatus.jsp" />
<%
    // 🔥 관리자 권한 완벽 수정
    String role = (String)session.getAttribute("role");
    if(!"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자만 블라인드 기능을 사용할 수 있습니다.");
            history.back(); 
        </script>
<%
        return;
    }

    int postId = Integer.parseInt(request.getParameter("post_id"));
    BoardDAO boardDAO = new BoardDAO();
    boardDAO.toggleBlind(postId);
%>
<script>
    alert("🔒 블라인드 상태가 변경되었습니다.");
    location.href = "QnaDetail.jsp?post_id=<%= postId %>";
</script>