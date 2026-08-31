<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.ReplyDAO" %>

<%
    // 1. 넘어온 데이터 받기 (댓글 번호, 원래 게시글 번호)
    String replyIdStr = request.getParameter("replyId");
    String postId = request.getParameter("postId");
    String sid = (String)session.getAttribute("sid");

    // 로그인 확인 (보안)
    if (sid == null) {
        %>
        <script>
            alert("로그인이 필요하거나 권한이 없습니다.");
            history.back();
        </script>
        <%
        return;
    }

    if (replyIdStr != null && postId != null) {
        int replyId = Integer.parseInt(replyIdStr);
        
        // 2. DAO를 불러와서 삭제 메서드 실행
        ReplyDAO dao = new ReplyDAO();
        dao.deleteReply(replyId); 
        
        // 3. 삭제 완료 후 원래 보던 게시글 상세페이지로 이동
        response.sendRedirect("detail.jsp?postId=" + postId);
    } else {
        %>
        <script>
            alert("잘못된 접근입니다.");
            history.back();
        </script>
        <%
    }
%>