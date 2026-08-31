<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.*" %> 
<%@ page import="web.bean.admin.AdminDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    // 1. [보안] 세션 확인 및 접근 제어 
    String userRole = (String) session.getAttribute("role");
    if (userRole == null || !"ADMIN".equals(userRole)) {
%>
        <script>
            alert("⚠️ 접근 권한이 없습니다.");
            location.href = "../member/loginForm.jsp"; 
        </script>
<%
        return;
    }

    // 2. 데이터 가져오기
    AdminDAO adminDAO = new AdminDAO();
    List<BoardDTO> dbList = adminDAO.getAllNotices();
    
    List<BoardDTO> pinnedList = new ArrayList<>(); 
    List<BoardDTO> normalList = new ArrayList<>();
    if (dbList != null) {
        for (BoardDTO b : dbList) {
            if ("PIN".equals(b.getCategory())) pinnedList.add(b);
            else normalList.add(b);
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
	<title>공지사항 관리</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 0; display: flex; background-color: #f4f6f9; }
        .sidebar { width: 250px; height: 100vh; background-color: #2c3e50; color: white; padding-top: 20px; position: fixed; }
        .sidebar h3 { text-align: center; margin-bottom: 30px; color: #3498db; }
        .sidebar a { display: block; color: #bdc3c7; padding: 15px 25px; text-decoration: none; font-size: 16px; border-left: 4px solid transparent; }
        .sidebar a:hover { color: white; background-color: #34495e; border-left: 4px solid #3498db; }
        .sidebar a.active { color: white; background-color: #1a252f; border-left: 4px solid #2ecc71; }

        /* 🔥 누락되었던 content 스타일 복구 */
        .content { margin-left: 250px; padding: 40px; width: calc(100% - 250px); box-sizing: border-box; }
        .content h2 { color: #333; margin-bottom: 20px; border-bottom: 2px solid #2c3e50; padding-bottom: 10px; }
        
        .card { background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { border: 1px solid #f1f2f6; padding: 12px; text-align: center; font-size: 14px; }
        th { background-color: #f8f9fa; color: #7f8c8d; font-weight: bold; }
        
        .pin-row { background-color: #fff9db; font-weight: bold; }
        .pin-badge { background-color: #e67e22; color: white; padding: 2px 6px; border-radius: 4px; font-size: 11px; }

        .btn-container { margin-top: 20px; text-align: right; }
        .btn { padding: 10px 20px; border: none; border-radius: 4px; font-size: 14px; cursor: pointer; font-weight: bold; margin-left: 5px; }
        .btn-write { background-color: #3498db; color: white; }
        .btn-edit { background-color: #f1c40f; color: white; }
        .btn-delete { background-color: #e74c3c; color: white; }
        .btn:hover { opacity: 0.9; }
        .data-row:hover { cursor: pointer; background-color: #f1f1f1; }
    </style>
    <script>
        // 🔥 라디오 버튼 선택 및 이동 스크립트 추가
        function getSelectedPostId() {
            const radios = document.getElementsByName('select_post');
            for(let i=0; i<radios.length; i++) {
                if(radios[i].checked) return radios[i].value;
            }
            return null;
        }
        function goEdit() {
            const postId = getSelectedPostId();
            if(!postId) { alert("수정할 공지사항을 선택해주세요."); return; }
            location.href = 'noticeUpdateForm.jsp?post_id=' + postId;
        }
        function goDelete() {
            const postId = getSelectedPostId();
            if(!postId) { alert("삭제할 공지사항을 선택해주세요."); return; }
            if(confirm("정말 삭제하시겠습니까?")) {
                location.href = 'noticeDeleteForm.jsp?post_id=' + postId;
            }
        }
    </script>
</head>
<body>

  <div class="sidebar">
        <h3>대시보드</h3>
        <a href="<%= request.getContextPath() %>/views/admin/adminMain.jsp">🏠 메인 홈</a>
        <a href="<%= request.getContextPath() %>/views/admin/noticeManage.jsp">📢 공지 사항</a>
        <a href="<%= request.getContextPath() %>/views/admin/memberList.jsp">👥 유저 관리</a>
        <a href="<%= request.getContextPath() %>/views/admin/QnaList.jsp">💬 건의 사항</a>
        <a href="<%= request.getContextPath() %>/views/admin/boardManage.jsp">📋 모든 게시판 관리</a>
        
        <div style="margin-top: 50px; border-top: 1px solid #34495e; padding-top: 10px;">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp" style="color: #f1c40f;">
                🌐 서비스 메인페이지
            </a>
            <a href="<%= request.getContextPath() %>/views/board/list.jsp" style="color: #2ecc71;">
                📄 전체 글 보기
            </a>
        </div>
    </div>
    <%-- 🔥 누락되었던 우측 컨텐츠 래퍼 및 제목 추가 --%>
    <div class="content">
        <h2>📢 공지사항 관리</h2>
        
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th style="width: 50px;">선택</th>
                        <th style="width: 80px;">구분</th>
                        <th>공지사항 제목</th>
                        <th style="width: 100px;">작성자</th>
                        <th style="width: 180px;">작성일자</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (pinnedList.isEmpty() && normalList.isEmpty()) {
                %>
                    <tr><td colspan="5">등록된 공지사항이 없습니다.</td></tr>
                <% 
                    } else {
                        // 고정 공지 출력
                        for (BoardDTO pin : pinnedList) {
                %>
                    <tr class="pin-row data-row" onclick="document.getElementById('radio_<%=pin.getPost_id()%>').checked = true;">
                        <td><input type="radio" id="radio_<%=pin.getPost_id()%>" name="select_post" value="<%= pin.getPost_id() %>"></td>
                        <td><span class="pin-badge">📌 고정</span></td>
                        <td style="text-align: left; padding-left: 15px;"><%= pin.getTitle() %></td>
                        <td><%= pin.getWriter() %></td>
                        <td><%= pin.getReg_date() %></td>
                    </tr>
                <%      }
                        // 일반 공지 출력
                        for (BoardDTO normal : normalList) {
                %>
                    <tr class="data-row" onclick="document.getElementById('radio_<%=normal.getPost_id()%>').checked = true;">
                        <td><input type="radio" id="radio_<%=normal.getPost_id()%>" name="select_post" value="<%= normal.getPost_id() %>"></td>
                        <td><%= normal.getPost_id() %></td>
                        <td style="text-align: left; padding-left: 15px;"><%= normal.getTitle() %></td>
                        <td><%= normal.getWriter() %></td>
                        <td><%= normal.getReg_date() %></td>
                    </tr>
                <%      }
                    }
                %>
                </tbody>
            </table>

            <%-- 🔥 기능 동작을 위한 버튼들 추가 --%>
            <div class="btn-container">
                <button class="btn btn-write" onclick="location.href='noticeWriteForm.jsp'">✍️ 새 공지 작성</button>
                <button class="btn btn-edit" onclick="goEdit()">✏️ 수정</button>
                <button class="btn btn-delete" onclick="goDelete()">🗑️ 삭제</button>
            </div>
        </div>
    </div>
</body>
</html>