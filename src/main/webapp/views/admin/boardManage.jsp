<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO"%>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="java.util.*" %>
<%
    // 1. 보안 체크: 로그인 세션 및 관리자 권한 확인
    String sessionId = (String)session.getAttribute("id");
    if(sessionId == null) sessionId = (String)session.getAttribute("sid");
    String role = (String)session.getAttribute("role");
    if(sessionId == null || !"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자만 접근 가능한 페이지입니다.");
            location.href = "../member/loginForm.jsp";
        </script>
<%
        return;
    }

    // 2. 데이터 가져오기
    request.setCharacterEncoding("UTF-8");
    String boardType = request.getParameter("boardType");
    if(boardType == null) boardType = "HOSPITAL"; // 기본값
    
    BoardDAO dao = new BoardDAO();
    List<BoardDTO> boardList = null;

    // 💡 추가된 로직: boardType이 'BLIND'일 경우 전용 메서드를 호출하도록 분기 처리
    if ("BLIND".equals(boardType)) {
        // 신고 5회 이상(블라인드) 게시물을 가져오는 새로운 DAO 메서 호출
        boardList = dao.getBlindBoardList(0, 20); 
    } else {
        // 기존 카테고리별 게시물 조회
        boardList = dao.getBoardList(boardType, 0, 20);
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 - 통합 게시판 관리</title>
    <style>
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 0; display: flex; background-color: #f4f6f9; }
        .sidebar { width: 250px; height: 100vh; background-color: #2c3e50; color: white; padding-top: 20px; position: fixed; }
        .sidebar h3 { text-align: center; margin-bottom: 30px; color: #3498db; }
        .sidebar a { display: block; color: #bdc3c7; padding: 15px 25px; text-decoration: none; font-size: 16px; border-left: 4px solid transparent; transition: 0.3s; }
        .sidebar a:hover { color: white; background-color: #34495e; border-left: 4px solid #3498db; }
        .sidebar a.active { color: white; background-color: #1a252f; border-left: 4px solid #2ecc71; }
        .content { margin-left: 250px; padding: 40px; width: calc(100% - 250px); box-sizing: border-box; }
        .content h2 { color: #333; margin-bottom: 20px; border-bottom: 2px solid #2c3e50; padding-bottom: 10px; }
        .tab-menu { margin-bottom: 20px; display: flex; gap: 10px; }
        .tab-menu a { padding: 10px 20px; background-color: white; color: #7f8c8d; text-decoration: none; border-radius: 4px; font-size: 14px; font-weight: bold; border: 1px solid #ddd; transition: 0.2s; }
        .tab-menu a:hover { background-color: #f1f2f6; }
        .tab-menu a.active { background-color: #3498db; color: white; border-color: #3498db; }
        
        /* 💡 블라인드 탭 전용 활성화 스타일 */
        .tab-menu a.active-blind { background-color: #e74c3c; color: white; border-color: #e74c3c; }

        .card { background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #f1f2f6; padding: 12px; text-align: center; font-size: 14px; vertical-align: middle; }
        th { background-color: #f8f9fa; color: #7f8c8d; font-weight: bold; }
        tr:hover { background-color: #f1f1f1; }
        .btn-action { border: none; padding: 8px 14px; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 13px; transition: 0.2s; }
        .btn-action:hover { transform: translateY(-1px); }
        .btn-edit { background-color: #3498db; color: white; }
        .btn-edit:hover { background-color: #2980b9; }
        .btn-blind { background-color: #f39c12; color: white; }
        .btn-blind:hover { background-color: #e67e22; }
        .btn-del { background-color: #e74c3c; color: white; }
        .btn-del:hover { background-color: #c0392b; }
    </style>
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
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp" style="color: #f1c40f;">🌐 서비스 메인페이지</a>
            <a href="<%= request.getContextPath() %>/views/board/list.jsp" style="color: #2ecc71;">📄 전체 글 보기</a>
        </div>
    </div>

    <div class="content">
        <h2>📋 모든 게시판 관리 - <%= "BLIND".equals(boardType) ? "블라인드 게시물" : boardType %></h2>
        
        <div class="tab-menu">
            <a href="boardManage.jsp?boardType=HOSPITAL" class="<%= "HOSPITAL".equals(boardType)?"active":"" %>">🏥 병원</a>
            <a href="boardManage.jsp?boardType=BEAUTY" class="<%= "BEAUTY".equals(boardType)?"active":"" %>">✂️ 미용</a>
            <a href="boardManage.jsp?boardType=HOTEL" class="<%= "HOTEL".equals(boardType)?"active":"" %>">🏨 호텔</a>
            <a href="boardManage.jsp?boardType=PLAY" class="<%= "PLAY".equals(boardType)?"active":"" %>">🎾 놀거리</a>
            <a href="boardManage.jsp?boardType=BLIND" class="<%= "BLIND".equals(boardType)?"active-blind":"" %>">🚨 신고 누적(블라인드)</a>
        </div>

        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th width="10%">번호</th>
                        <th width="40%">제목</th>
                        <th width="15%">작성자</th>
                        <th width="10%">상태</th>
                        <th width="25%">관리</th>
                    </tr>
                </thead>
               <tbody>
                <% if(boardList == null || boardList.isEmpty()) { %>
                    <tr><td colspan="5" style="padding: 30px; color: #7f8c8d;">등록된 데이터가 없습니다.</td></tr>
                <% } else {
                    for(BoardDTO dto : boardList) { %>
                    <tr>
                        <td style="font-weight: bold; color: #2c3e50;"><%= dto.getPost_id() %></td>
                        <td style="text-align:left; padding-left:15px;">
                            <a href="../board/detail.jsp?postId=<%= dto.getPost_id() %>" style="text-decoration:none; color:#333; font-weight:bold;">
                                <%= dto.getTitle() %>
                            </a>
                        </td>
                        <td><%= dto.getWriter() %></td>
                        <td style="font-weight: bold; color: <%= "Y".equals(dto.getIs_blind()) ? "#e74c3c" : "#2ecc71" %>;">
                            <%= "Y".equals(dto.getIs_blind()) ? "🔒 블라인드" : "정상" %>
                        </td>
                        
                        <td>
                            <div style="display: flex; gap: 5px; justify-content: center;">
                                <button class="btn-action btn-edit" onclick="location.href='AdminUpdateForm.jsp?post_id=<%=dto.getPost_id()%>&boardType=<%=boardType%>'">수정</button>
                                
                                <button class="btn-action btn-blind" 
                                    onclick="if(confirm('이 글을 <%= "Y".equals(dto.getIs_blind()) ? "블라인드 해제" : "블라인드 처리" %>하시겠습니까?')) 
                                    location.href='AdminActionPro.jsp?action=blind&post_id=<%=dto.getPost_id()%>&boardType=<%=boardType%>'">
                                    <%= "Y".equals(dto.getIs_blind()) ? "해제" : "블라인드" %>
                                </button>
                                
                                <button class="btn-action btn-del" onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='AdminActionPro.jsp?action=delete&post_id=<%=dto.getPost_id()%>&boardType=<%=boardType%>'">삭제</button>
                            </div>
                        </td>
                    </tr>
                <% } } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>