<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.ReplyDAO" %>

<%
    // 1. 한글 깨짐 방지
    request.setCharacterEncoding("UTF-8");

    // 2. 폼에서 넘어온 데이터 받기 (댓글 번호, 게시글 번호, 수정된 내용)
    String replyIdStr = request.getParameter("replyId");
    String postId = request.getParameter("postId");
    String content = request.getParameter("content");
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

    if (replyIdStr != null && postId != null && content != null) {
        int replyId = Integer.parseInt(replyIdStr);
        
        // 3. DAO를 불러와서 수정 메서드 실행
        ReplyDAO dao = new ReplyDAO();
        dao.updateReply(replyId, content);
        
        // 4. 수정 완료 후 원래 보던 게시글 상세페이지로 이동
        response.sendRedirect("detail.jsp?postId=" + postId);
    } else {
        %>
        <script>
            alert("내용을 입력해주세요.");
            history.back();
        </script>
        <%
    }
%>