<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.admin.AdminDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"ADMIN".equals(userRole)) {
%>
        <script>alert('⚠️ 관리자 권한이 필요합니다.'); location.href='noticeManage.jsp';</script>
<%
        return;
    }

    String postIdStr = request.getParameter("post_id");
    int postId = 0;
    try {
        postId = Integer.parseInt(postIdStr);
    } catch (NumberFormatException e) {
%>
        <script>alert('❌ 잘못된 요청입니다.'); location.href='noticeManage.jsp';</script>
<%
        return;
    }

    AdminDAO adminDAO = new AdminDAO();
    BoardDTO notice = adminDAO.getNoticeDetail(postId);

    if(notice == null) {
%>
        <script>alert('❌ 존재하지 않는 공지글입니다.'); location.href='noticeManage.jsp';</script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>공지사항 수정</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; background-color: #f4f6f9; padding: 40px; margin: 0; }
    .container { max-width: 700px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    h2 { color: #2c3e50; border-bottom: 2px solid #f1c40f; padding-bottom: 10px; margin-top: 0; }
    .form-group { margin-bottom: 20px; }
    .form-group label { display: block; font-weight: bold; margin-bottom: 8px; color: #333; }
    .form-group input[type="text"], .form-group textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; font-size: 14px; }
    .form-group textarea { height: 200px; resize: none; }
    .checkbox-group { display: flex; align-items: center; margin-bottom: 20px; }
    .checkbox-group input { margin-right: 8px; width: 18px; height: 18px; cursor: pointer; }
    .checkbox-group label { font-weight: bold; color: #e67e22; cursor: pointer; }
    .btn-box { text-align: right; }
    .btn { padding: 10px 20px; border: none; border-radius: 4px; font-size: 14px; cursor: pointer; font-weight: bold; }
    .btn-submit { background-color: #f1c40f; color: white; margin-left: 5px; }
    .btn-cancel { background-color: #95a5a6; color: white; }
    .btn:hover { opacity: 0.9; }
</style>
</head>
<body>
<div class="container">
    <h2>🛠️ 공지사항 수정하기</h2>
    <form action="noticeUpdatePro.jsp" method="post">
        <input type="hidden" name="post_id" value="<%= notice.getPost_id() %>">
        
        <div class="checkbox-group">
            <input type="checkbox" id="is_pinned" name="is_pinned" value="Y" <%="PIN".equals(notice.getCategory()) ? "checked" : "" %>>
            <label for="is_pinned">📌 이 공지사항을 게시판 최상단에 고정합니다</label>
        </div>

        <div class="form-group">
            <label for="title">공지 제목</label>
            <input type="text" id="title" name="title" value="<%= notice.getTitle().replace("\"", "&quot;") %>" required>
        </div>

        <div class="form-group">
            <label for="content">공지 내용</label>
            <textarea id="content" name="content" required><%= notice.getContent() %></textarea>
        </div>

        <div class="btn-box">
            <button type="button" class="btn btn-cancel" onclick="location.href='noticeManage.jsp'">취소</button>
            <button type="submit" class="btn btn-submit">수정 완료하기</button>
        </div>
    </form>
</div>
</body>
</html>