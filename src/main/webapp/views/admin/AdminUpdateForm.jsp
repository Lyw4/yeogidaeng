<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.admin.AdminDAO" %>
<jsp:include page="checkStatus.jsp" />
<%
    request.setCharacterEncoding("UTF-8");

    // 🔥 1. 보안 체크: 회원님의 완벽한 로그인 시스템(role)에 맞게 암구호 수정!
    String sessionId = (String)session.getAttribute("id");
    String role = (String)session.getAttribute("role"); 

    // 🔥 2. 관리자 권한 확인: 로그인이 안 되어있거나, 권한이 'ADMIN'이 아니면 차단!
    if(sessionId == null || !"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자만 접근할 수 있는 페이지입니다.");
            location.href = "QnaList.jsp";
        </script>
<%
        return; // 코드 실행 중단
    }

    // 3. 파라미터 유효성 검사 및 데이터 가져오기
    String postIdParam = request.getParameter("post_id");
    if(postIdParam == null || postIdParam.equals("")) {
%>
        <script>alert("잘못된 접근입니다."); history.back();</script>
<%
        return;
    }

    int postId = Integer.parseInt(postIdParam);
    BoardDAO boardDao = new BoardDAO();
    BoardDTO dto = boardDao.getPostDetail(postId); // ⭕ 일반 통합 게시글용 메서드로 변경!

    if(dto == null) {
%>
        <script>alert("게시글이 존재하지 않습니다."); history.back();</script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 게시글 수정</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; background-color: #f4f6f9; padding: 40px; }
    .form-wrapper { max-width: 600px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 10px rgba(0,0,0,0.1); }
    h2 { color: #2c3e50; text-align: center; }
    .form-group { margin-bottom: 20px; }
    .form-group label { font-weight: bold; display: block; margin-bottom: 8px; color: #34495e; }
    .form-group input[type="text"], .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; box-sizing: border-box; }
    .form-group textarea { height: 200px; resize: vertical; }
    .btn-submit { width: 100%; padding: 12px; background: #3498db; color: white; font-weight: bold; border: none; border-radius: 5px; cursor: pointer; transition: 0.3s; }
    .btn-submit:hover { background: #2980b9; }
</style>
</head>
<body>

<div class="form-wrapper">
    <h2>🛠️ 관리자 게시글 수정</h2>
    <form action="AdminUpdatePro.jsp" method="post">
        <input type="hidden" name="post_id" value="<%=postId%>">
        <input type="hidden" name="boardType" value="<%=request.getParameter("boardType")%>">
        
        <div class="form-group">
            <label>제목:</label>
            <input type="text" name="title" value="<%=dto.getTitle()%>" required>
        </div>
        
        <div class="form-group">
            <label>내용:</label>
            <textarea name="content" required><%=dto.getContent()%></textarea>
        </div>

        <button type="submit" class="btn-submit">수정 완료</button>
    </form>
</div>

</body>
</html>