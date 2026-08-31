<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %> 
<%@ page import="web.bean.member.MemberDAO" %> 

<%
    // 0. 한글 깨짐 방지 및 세션 체크
    request.setCharacterEncoding("UTF-8");
    
    String sid = (String)session.getAttribute("sid");
    
    // 🔥 에러 해결: isAdmin 대신 로그인할 때 세션에 저장한 'role' 정보를 꺼내옵니다!
    String role = (String)session.getAttribute("role");

    // 🔒 [보안 코드] 로그인을 안 했거나, 권한이 "ADMIN"이 아니라면 일반 페이지로 튕겨내기
    if (sid == null || role == null || !role.equals("ADMIN")) {
%>
        <script>
            alert("관리자만 접근할 수 있는 페이지입니다.");
            location.href = "../main/mainPage.jsp"; // 💡 일반 게시판 대신 메인페이지로 가도록 경로 수정
        </script>
<%
        return; // 이하 JSP 코드 실행 중단
    }

    // 1. 대시보드용 간단한 통계 데이터 가져오기 
    int pendingSuggestions = 3;  // 임시 데이터 
    int totalReportedPosts = 1;  // 임시 데이터 
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>관리자 전용 센터</title>
    <style>
        body { margin: 0; padding: 20px 0; background-color: #fffaf5; font-family: 'Malgun Gothic', sans-serif; }
        .admin-container { width: 80%; min-width: 1150px; margin: 0 auto; box-sizing: border-box; }
        
        /* 대시보드 상단 요약 카드 */
        .dashboard-wrapper { display: flex; gap: 20px; margin: 30px 0; }
        .stat-card { flex: 1; background: #fff; padding: 20px; border-radius: 15px; border: 2px solid #ffe5df; box-shadow: 0 4px 10px rgba(255,229,223,0.3); text-align: center; }
        .stat-card h3 { margin: 0 0 10px 0; color: #ff735d; font-size: 16px; }
        .stat-card .count { font-size: 28px; font-weight: bold; color: #e65c47; }

        /* 관리자 메뉴 그리드 */
        .admin-menu-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 25px; margin-top: 20px; }
        .menu-box { background-color: #ffffff; border: 2px solid #ffe5df; border-radius: 20px; padding: 30px; text-align: center; box-shadow: 0 6px 15px rgba(255, 229, 223, 0.4); transition: all 0.2s ease; cursor: pointer; }
        .menu-box:hover { transform: translateY(-5px); border-color: #ffbfb5; box-shadow: 0 10px 20px rgba(255, 191, 181, 0.5); }
        .menu-icon { font-size: 45px; margin-bottom: 15px; }
        .menu-box h2 { margin: 0 0 10px 0; color: #4a4a4a; font-size: 20px; }
        .menu-box p { margin: 0; color: #888; font-size: 14px; line-height: 1.5; }
        
        /* 하단 돌아가기 버튼 */
        .back-box { text-align: center; margin-top: 40px; }
        .back-box button { padding: 12px 40px; border-radius: 50px; border: none; background-color: #ff9999; color: white; font-weight: bold; cursor: pointer; font-size: 15px; }
        .back-box button:hover { background-color: #ff8b77; }
    </style>
</head>
<body>

    <%-- 우리가 만든 공통 헤더 포함 (페이지 제목 전달) --%>
    <jsp:include page="header.jsp">
        <jsp:param name="pageTitle" value="관리자 전용 시스템 ⚙️" />
    </jsp:include>

    <div class="admin-container">
        
        <div class="dashboard-wrapper">
            <div class="stat-card">
                <h3>💡 신규 건의사항 (답변대기)</h3>
                <div class="count"><%= pendingSuggestions %>건</div>
            </div>
            <div class="stat-card">
                <h3>🚨 신고 접수된 게시글</h3>
                <div class="count"><%= totalReportedPosts %>건</div>
            </div>
            <div class="stat-card">
                <h3>👥 현재 활성 회원수</h3>
                <div class="count">이용중</div>
            </div>
        </div>

        <div class="admin-menu-grid">
            
            <div class="menu-box" onclick="location.href='adminMemberList.jsp'">
                <div class="menu-icon">👥</div>
                <h2>회원 권한 및 상태 관리</h2>
                <p>전체 회원 목록을 조회하고,<br>불량 회원을 정지(SUSPENDED)시키거나 복구합니다.</p>
            </div>

            <div class="menu-box" onclick="location.href='list.jsp?boardType=SUGGESTION&status=답변대기'">
                <div class="menu-icon">💡</div>
                <h2>건의사항 답변 처리</h2>
                <p>유저들이 작성한 건의사항을 확인하고<br>답변 완료 상태로 변경합니다.</p>
            </div>

            <div class="menu-box" onclick="location.href='adminReportList.jsp'">
                <div class="menu-icon">🚨</div>
                <h2>신고/블랙리스트 관리</h2>
                <p>신고 횟수가 누적된 게시글을 감시하고<br>강제 삭제 혹은 블라인드 처리합니다.</p>
            </div>

        </div>

        <div class="back-box">
            <button onclick="location.href='list.jsp'">🐾 일반 커뮤니티로 돌아가기</button>
        </div>
    </div>

</body>
</html>