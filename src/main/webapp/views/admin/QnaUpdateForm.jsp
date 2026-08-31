<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    // 🔥 최신 로그인 세션 적용
    String id = (String)session.getAttribute("id");
    if(id == null) id = (String)session.getAttribute("sid");
    String role = (String)session.getAttribute("role");

    String postIdParam = request.getParameter("post_id");
    if (postIdParam == null || id == null) {
%>
        <script>alert('잘못된 접근입니다.'); location.href='QnaList.jsp';</script>
<%
        return;
    }

    int postId = Integer.parseInt(postIdParam);
    BoardDAO boardDAO = new BoardDAO();
    BoardDTO dto = boardDAO.getQnaDetail(postId);

    // 작성자 본인이거나 관리자만 수정 가능하도록 제한
    if (dto == null || (!id.equals(dto.getWriter()) && !"ADMIN".equals(role))) {
%>
        <script>alert('수정 권한이 없습니다.'); location.href='QnaList.jsp';</script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>건의사항 수정하기</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; background-color: #f8f9fa; margin: 30px; }
    .container { max-width: 700px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    h2 { color: #e67e22; border-bottom: 2px solid #e67e22; padding-bottom: 10px; }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; font-weight: bold; margin-bottom: 5px; color: #34495e; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    textarea.form-control { height: 200px; resize: none; }
    .btn-box { text-align: center; margin-top: 20px; }
    .btn { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; text-decoration: none; display: inline-block; }
    .btn-submit { background-color: #e67e22; color: white; margin-right: 5px; }
    .btn-cancel { background-color: #95a5a6; color: white; }
    .file-info { font-size: 12px; color: #666; margin-top: 5px; }
</style>
</head>
<body>
<div class="container">
    <h2>✏️ 건의사항 글 수정하기</h2>
    <form action="QnaUpdatePro.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="post_id" value="<%= dto.getPost_id() %>">

        <div class="form-group">
            <label>작성자</label>
            <input type="text" class="form-control" value="<%= dto.getWriter() %>" readonly>
        </div>
        
        <div class="form-group">
            <label for="title">글 제목</label>
            <input type="text" id="title" name="title" class="form-control" value="<%= dto.getTitle() %>" required>
        </div>
        
        <div class="form-group">
            <label for="content">글 내용</label>
            <textarea id="content" name="content" class="form-control" required><%= dto.getContent() %></textarea>
        </div>

        <div class="form-group">
            <label>첨부 이미지</label>
            <% if(dto.getImage_file() != null && !dto.getImage_file().isEmpty()) { %>
                <div class="file-info">현재 파일: <%= dto.getImage_file() %></div>
            <% } %>
            <input type="file" name="image_file" class="form-control">
        </div>
        
        <div class="btn-box">
            <button type="submit" class="btn btn-submit">수정 완료하기</button>
            <a href="QnaDetail.jsp?post_id=<%= dto.getPost_id() %>" class="btn btn-cancel">취소</a>
        </div>
    </form>
</div>
</body>
</html>