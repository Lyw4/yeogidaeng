<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="web.bean.board.ReplyDAO" %>    
<%@ page import="web.bean.board.ReplyDTO" %>
<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파라미터 받기
    String content = request.getParameter("content");
    int postId = Integer.parseInt(request.getParameter("postId"));
    
    // 대댓글 정보 (없으면 0으로 처리)
    String parentIdStr = request.getParameter("parentReplyId");
    String depthStr = request.getParameter("depth");
    
    int parentReplyId = (parentIdStr != null) ? Integer.parseInt(parentIdStr) : 0;
    int depth = (depthStr != null) ? Integer.parseInt(depthStr) : 0;
    String sid = (String)session.getAttribute("sid");

    // 2. DTO 설정
    ReplyDTO dto = new ReplyDTO();
    dto.setPostId(postId);
    dto.setContent(content);
    dto.setWriter(sid);
    dto.setParentReplyId(parentReplyId); // 부모 ID 설정
    dto.setDepth(depth);                 // 깊이 설정 (기본 댓글은 0, 대댓글은 1부터)

    // 3. DAO 실행
    ReplyDAO dao = new ReplyDAO();
    dao.insertReply(dto); // 이 메서드 안에서 SQL을 통해 그룹번호 등 처리

    response.sendRedirect("detail.jsp?postId=" + postId);
%>