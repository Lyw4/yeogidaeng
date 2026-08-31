<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.ReplyDAO" %>
<%@ page import="web.bean.board.ReplyDTO" %>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>

<%
    request.setCharacterEncoding("UTF-8");

    String sid = (String) session.getAttribute("sid");
    if (sid == null) {
%>
        <script>
            alert("로그인이 만료되었거나 로그인이 필요합니다.");
            window.location="loginForm.jsp";
        </script>
<%
        return; 
    }

    int postId = Integer.parseInt(request.getParameter("postId"));
    String content = request.getParameter("content");
    String writer = sid; 

    String pIdParam = request.getParameter("parentReplyId");
    String depthParam = request.getParameter("depth");
    int parentReplyId = (pIdParam != null && !pIdParam.isEmpty()) ? Integer.parseInt(pIdParam) : 0;
    int depth = (depthParam != null && !depthParam.isEmpty()) ? Integer.parseInt(depthParam) : 0;

    ReplyDTO dto = new ReplyDTO();
    dto.setPostId(postId);
    dto.setWriter(writer);
    dto.setContent(content);
    dto.setParentReplyId(parentReplyId);
    dto.setDepth(depth);

    ReplyDAO dao = new ReplyDAO();
    int result = dao.insertReply(dto);

    // 🔥 관리자가 건의사항에 답변 시 '답변완료'로 자동 업데이트
    if (result > 0) {
        BoardDAO boardDao = new BoardDAO();
        BoardDTO post = boardDao.getPostDetail(postId); 
        
        boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin")) || "admin".equals(sid);

        if (post != null && "SUGGESTION".equals(post.getBoard_type()) && isAdmin) {
            boardDao.updateSuggestionStatus(postId, "답변완료");
        }
%>
        <script>
            location.href = "detail.jsp?postId=<%= postId %>";
        </script>
<%
    } else {
%>
        <script>
            alert("댓글 등록에 실패했습니다. 다시 시도해 주세요.");
            history.back();
        </script>
<%
    }
%>