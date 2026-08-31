<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.text.SimpleDateFormat" %>
<%@ page import="web.bean.member.MemberDTO" %>
<%@ page import="web.bean.admin.AdminDAO" %>
<%
    // 1. 보안 체크: 최신 로그인 세션 규격(role)에 맞게 완벽 호환!
    String id = (String)session.getAttribute("id");
    if(id == null) id = (String)session.getAttribute("sid");
    String role = (String)session.getAttribute("role"); 
    
    if(id == null || !"ADMIN".equals(role)) {
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
    AdminDAO adminDAO = new AdminDAO();
    List<MemberDTO> memberList = adminDAO.getAllMember();
    int qnaCount = adminDAO.getPendingQnaCount(); // 수정한 DAO 메서드 호출!
    
    // 날짜 포맷 객체
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 메인 시스템</title>
<style>
     /* 기본 레이아웃 스타일링 */
    body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 0; display: flex; background-color: #f4f6f9; }
    
    /* 왼쪽 사이드바 메뉴 스타일 */
    .sidebar { width: 250px; height: 100vh; background-color: #2c3e50; color: white; padding-top: 20px; position: fixed; }
    .sidebar h3 { text-align: center; margin-bottom: 30px; color: #3498db; }
    .sidebar a { display: block; color: #bdc3c7; padding: 15px 25px; text-decoration: none; font-size: 16px; border-left: 4px solid transparent; transition: 0.3s; }
    .sidebar a:hover { color: white; background-color: #34495e; border-left: 4px solid #3498db; }
    .sidebar a.active { color: white; background-color: #1a252f; border-left: 4px solid #2ecc71; }

    /* 오른쪽 메인 콘텐츠 영역 스타일 */
    .content { margin-left: 250px; padding: 40px; width: calc(100% - 250px); box-sizing: border-box; }
    .content h2 { color: #333; margin-bottom: 20px; border-bottom: 2px solid #2c3e50; padding-bottom: 10px; }
    
    /* 최근 가입 유저 테이블 스타일 */
    .card { background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 20px; margin-top: 20px; }
    .card h4 { margin-top: 0; color: #2c3e50; font-size: 18px; border-left: 4px solid #3498db; padding-left: 10px; }
    
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th, td { border: 1px solid #f1f2f6; padding: 12px; text-align: center; font-size: 14px; }
    th { background-color: #f8f9fa; color: #7f8c8d; font-weight: bold; }
    tr:hover { background-color: #f8f9fa; }
    .no-data { padding: 30px; color: #95a5a6; }

    /* 🎯 미답변 건의함 배너 스타일 */
    .qna-shortcut-box {
        background-color: #e3f2fd; border: 1px solid #90caf9; border-radius: 8px; padding: 15px 20px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center;
    }
    .qna-shortcut-box p { margin: 0; color: #1e88e5; font-weight: bold; font-size: 15px; }
    .qna-btn { background-color: #1e88e5; color: white; text-decoration: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; font-weight: bold; transition: 0.2s; }
    .qna-btn:hover { background-color: #1565c0; }
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
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp" style="color: #f1c40f;">
                🌐 서비스 메인페이지
            </a>
            <a href="<%= request.getContextPath() %>/views/board/list.jsp" style="color: #2ecc71;">
                📄 전체 글 보기
            </a>
        </div>
    </div>
    <div class="content">
        <h2>🛠️ 관리자 시스템 메인</h2>
        
        <%-- 미답변 Q&A 개수 연동 완료! --%>
        <div class="qna-shortcut-box" style="<%= (qnaCount == 0) ? "background-color: #e8f5e9; border-color: #a5d6a7;" : "" %>">
            <% if(qnaCount > 0) { %>
                <p style="color: #d35400;">⏳ 현재 <%= qnaCount %>건의 답변 대기 중인 건의사항이 있습니다.</p>
                <a href="QnaList.jsp?filter=w" class="qna-btn" style="background-color: #e67e22;">미답변 질문 보기 →</a>
            <% } else { %>
                <p style="color: #27ae60;">✅ 현재 모든 건의사항에 답변이 완료되었습니다.</p>
                <a href="QnaList.jsp" class="qna-btn" style="background-color: #2ecc71;">게시판 가기 →</a>
            <% } %>
        </div>
        
        <div class="card">
            <h4>🆕 최근 가입 유저 목록 (최신 5명)</h4>
            <table>
                <thead>
                    <tr><th>번호</th><th>아이디</th><th>닉네임</th><th>가입일자</th></tr>
                </thead>
                <tbody>
                <%
                    if (memberList != null && !memberList.isEmpty()) {
                        int count = 0;
                        for (MemberDTO member : memberList) {
                            if(count >= 5) break;
                %>
                    <tr>
                        <td><%= ++count %></td>
                        <td style="font-weight:bold; color:#2c3e50;"><%= member.getId() %></td>
                        <td><%= member.getName() %></td>
                        <td><%= (member.getReg() != null) ? sdf.format(member.getReg()) : "미등록" %></td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr><td colspan="4" class="no-data">등록된 회원이 없습니다.</td></tr>
                <%
                    }
                %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>