<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.admin.AdminDAO" %>
<jsp:include page="checkStatus.jsp" />

<%
    request.setCharacterEncoding("UTF-8");

    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"ADMIN".equals(userRole)) {
%>
        <script>alert('⚠️ 관리자 권한이 필요합니다.'); location.href='noticeManage.jsp';</script>
<%
        return;
    }

    String postIdStr = request.getParameter("post_id");
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String isPinned = request.getParameter("is_pinned");

    int postId = 0;
    try {
        if(postIdStr == null || postIdStr.isEmpty()) throw new Exception();
        postId = Integer.parseInt(postIdStr);
    } catch (Exception e) {
%>
        <script>alert('❌ 잘못된 요청입니다.'); history.back();</script>
<%
        return;
    }

    BoardDTO boardDTO = new BoardDTO();
    boardDTO.setPost_id(postId);
    boardDTO.setTitle(title);
    boardDTO.setContent(content);
    boardDTO.setCategory("Y".equals(isPinned) ? "PIN" : "NORMAL");

    int result = 0;
    try {
        AdminDAO adminDAO = new AdminDAO();
        result = adminDAO.updateNotice(boardDTO);
    } catch (Exception e) {
        e.printStackTrace(); 
    }

    if(result > 0) {
%>
        <script>
            alert("✅ 성공적으로 수정되었습니다!");
            location.href = "noticeManage.jsp"; 
        </script>
<%
    } else {
%>
        <script>
            alert("❌ 수정에 실패했습니다. 데이터를 다시 확인해 주세요.");
            history.back();
        </script>
<%
    }
%>