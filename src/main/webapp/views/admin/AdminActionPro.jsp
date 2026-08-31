<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<jsp:include page="checkStatus.jsp" />
<% 
    request.setCharacterEncoding("UTF-8");

//🔥 1. 보안 체크: 회원님의 완벽한 로그인 시스템(role)에 맞게 암구호 수정!
String sessionId = (String)session.getAttribute("id");
String role = (String)session.getAttribute("role"); 

// 로그인이 안 되어있거나, DB상 권한이 'ADMIN'이 아니면 차단!
if(sessionId == null || !"ADMIN".equals(role)) {
%>
    <script>
        alert("관리자만 접근 가능합니다.");
        location.href = "QnaList.jsp";
    </script>	
<% 
    return; 
}

    // 2. 파라미터 가져오기 및 예외 처리
    String action = request.getParameter("action");
    String postIdParam = request.getParameter("post_id");
    String boardType = request.getParameter("boardType");

    if (postIdParam == null || postIdParam.trim().isEmpty()) {
%>
        <script>alert("잘못된 요청입니다."); history.back();</script>
<%
        return;
    }

    int postId = Integer.parseInt(postIdParam);
    BoardDAO dao = new BoardDAO();

    // 3. 액션 실행
   if ("blind".equals(action)) {
        dao.toggleBlind(postId);
    } else if ("delete".equals(action)) {
        dao.deletePost(postId); // ⭕ 일반 게시판 전용 삭제 로직으로 변경!
    } else {
%>
        <script>alert("정의되지 않은 액션입니다."); history.back();</script>
<%
        return;
    }

    // 4. 리다이렉트 (null 방지 처리)
	String redirectUrl = "boardManage.jsp?boardType=" + (boardType != null ? boardType : "HOSPITAL"); // ⭕ "HOSPITAL"로 안전하게 이동
    response.sendRedirect(redirectUrl);
%>