<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. 세션에서 현재 로그인한 유저 아이디와 관리자 권한(role) 가져오기
    String headerSid = (String)session.getAttribute("sid");
    // 🔥 로그인 시 MemberDAO에서 담아준 role 값을 꺼내옵니다.
    String headerRole = (String)session.getAttribute("role"); 
    
    // 2. 각 페이지(list.jsp 등)에서 보낸 pageTitle 파라미터 수신
    String pageTitle = request.getParameter("pageTitle");
    if (pageTitle == null || pageTitle.isEmpty()) {
        pageTitle = "반려동물 커뮤니티"; 
    }
    
    // 3. 링크 에러 방지용 절대 경로 추출
    String ctx = request.getContextPath();
%>
<style>
    .main-header {
        width: 100%;
        background-color: #ffffff;
        border-bottom: 2px solid #ffe5df;
        padding: 18px 0;
        box-shadow: 0 4px 12px rgba(255, 229, 223, 0.3);
    }
    .header-container {
        width: 80%;
        min-width: 1150px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        box-sizing: border-box;
    }
    .header-logo h1 {
        margin: 0;
        font-size: 24px;
        color: #ff735d;
        cursor: pointer;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .header-user-zone {
        display: flex;
        align-items: center;
        gap: 15px; /* 요소들 간의 간격 */
        font-size: 14.5px;
        color: #4a4a4a;
    }
    
    /* 일반 텍스트 링크 (마이페이지, 로그인 등) */
    .header-user-zone a {
        color: #7d6b60;
        text-decoration: none;
        font-weight: bold;
        transition: color 0.2s;
    }
    .header-user-zone a:hover {
        color: #e65c47;
    }

    /* 관리자 뱃지 스타일 */
    .header-admin-badge {
        background-color: #e65c47; 
        color: white; 
        padding: 3px 8px; 
        border-radius: 4px; 
        font-size: 11px; 
        font-weight: bold;
        display: inline-block;
        vertical-align: middle;
    }

    /* 관리자 페이지 이동 버튼 스타일 */
    .header-admin-btn {
        background-color: #fff;
        color: #e65c47;
        border: 1.5px solid #e65c47;
        padding: 5px 12px;
        border-radius: 20px;
        font-weight: bold;
        font-size: 12px;
        cursor: pointer;
        transition: all 0.2s;
    }
    .header-admin-btn:hover {
        background-color: #fff0ec;
        transform: translateY(-2px);
    }
</style>

<header class="main-header">
    <div class="header-container">
        
        <%-- 로고 클릭 시 메인 페이지(mainPage.jsp)로 이동하도록 수정 --%>
        <div class="header-logo" onclick="location.href='<%= ctx %>/views/main/mainPage.jsp'">
            <h1>🐾 <%= pageTitle %></h1>
        </div>
        
        <div class="header-user-zone">
            <% if (headerSid != null) { %>
                
                <%-- 🔥 관리자일 경우 (role == "ADMIN") --%>
                <% if ("ADMIN".equals(headerRole)) { %>
                    <button class="header-admin-btn" onclick="location.href='<%= ctx %>/views/admin/adminMain.jsp'">⚙️ 관리자 페이지</button>
                    <span class="header-admin-badge">관리자</span>
                <% } %>
                
                <span><strong><%= headerSid %></strong>님 환영합니다!</span>
                
                <%-- 🔥 로그인 상태일 때 공통 메뉴 --%>
                <a href="<%= ctx %>/views/member/myPage.jsp">👤 마이페이지</a>
                <a href="<%= ctx %>/views/member/logout.jsp">🔓 로그아웃</a>
                
            <% } else { %>
                <%-- 🔥 비로그인 상태일 때 메뉴 --%>
                <a href="<%= ctx %>/views/member/loginForm.jsp">🔐 로그인</a>
                <a href="<%= ctx %>/views/member/joinForm.jsp">📝 회원가입</a>
            <% } %>
        </div>
        
    </div>
</header>