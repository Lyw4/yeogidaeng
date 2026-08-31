<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<jsp:include page="checkStatus.jsp" />
<%
    request.setCharacterEncoding("UTF-8");

    // 🔥 1. 보안: 회원님의 로그인 시스템(role)에 맞게 권한 검증!
    String sessionId = (String)session.getAttribute("id");
    String role = (String)session.getAttribute("role"); 

    if (sessionId == null || !"ADMIN".equals(role)) {
    	%>
    	        <script>
    	            alert('관리자 권한이 없습니다.'); 
    	            location.href='boardManage.jsp';
    	        </script>
    	<%
    	        return;
    	    }

    try {
        // 2. 파라미터 받기 (숫자 변환 예외 처리)
        int postId = Integer.parseInt(request.getParameter("post_id"));
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String boardType = request.getParameter("boardType");

        // 3. DAO 호출
        BoardDAO dao = new BoardDAO();
        
        // 💡 [참고] 만약 BoardDAO.java에 updateBoardAdmin 메서드가 없어서 에러가 난다면,
        // 이전에 우리가 합쳐두었던 updatePost 메서드를 활용하도록 아래 주석을 풀고 사용하세요!
        /*
        BoardDTO dto = new BoardDTO();
        dto.setPost_id(postId);
        dto.setTitle(title);
        dto.setContent(content);
        dto.setCategory("공지"); // 카테고리가 null이 되지 않도록 임의값
        dao.updatePost(dto); 
        */
        
        dao.updateBoardAdmin(postId, title, content); // 기존 작성하신 메서드 그대로 유지
 
        // 4. 성공 시 이동 (boardType 유지, 오류 방지를 위해 기본값을 HOSPITAL로 설정)
        response.sendRedirect("boardManage.jsp?boardType=" + (boardType != null ? boardType : "HOSPITAL"));
        
    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("처리 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>