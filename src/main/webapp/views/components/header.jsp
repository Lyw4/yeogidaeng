<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="main-header">
    <div class="header-container">
        <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp" class="logo">🐾여기댕🐾</a>
        
        <%-- 로그인 회원가입 및 마이페이지 (JS가 동적으로 채워넣을 빈 공간) --%>
        <div class="util-menu" id="headerUtilMenu"></div>
    </div>
    
    <%-- 🌟 모든 카테고리 링크에 <%= request.getContextPath() %>를 붙여 폴더 위치와 상관없이 경로를 고정합니다. --%> 
    <nav class="main-nav">
        <ul class="nav-list">
            <li><a href="<%= request.getContextPath() %>/views/board/list.jsp?boardType=HOSPITAL&page=1">🏥 병원 💊</a></li>
            <li><a href="<%= request.getContextPath() %>/views/board/list.jsp?boardType=BEAUTY&page=1">✂️ 미용 ✂️</a></li>        
            <li><a href="<%= request.getContextPath() %>/views/board/list.jsp?boardType=HOTEL&page=1">🏨 호텔 🏨</a></li>
            <li><a href="<%= request.getContextPath() %>/views/board/list.jsp?boardType=PLAY&page=1">🏃‍♂️ 놀거리 🐕</a></li>
            
            <li><a href="<%= request.getContextPath() %>/views/board/list.jsp?boardType=NOTICE&page=1" class="special-nav">📢 공지사항</a></li>
            <li><a href="<%= request.getContextPath() %>/views/board/list.jsp?boardType=SUGGESTION&page=1" class="special-nav">💡 건의사항</a></li>
        </ul>
    </nav>
    
    <div class="search-area-bottom">
        <%-- 검색 Form의 action 주소도 컨텍스트 패스를 적용하여 board 폴더 안의 list.jsp로 직결합니다. --%>
        <form action="<%= request.getContextPath() %>/views/board/list.jsp" method="get" class="search-box" style="margin: 0;">
            <input type="hidden" name="searchType" value="title"> 
            <input type="text" name="searchKeyword" class="search-input" placeholder="어떤 정보를 찾으시나요? 통합검색" required>
            <button type="submit" class="search-btn">검색</button>
        </form>
    </div>    
</header>

<%-- 서버의 세션(sid) 상태를 확인해서 자바스크립트에게 알려주는 역할 --%>
<%
    String sessionId = (String) session.getAttribute("sid");
    boolean isLogin = (sessionId != null);
    String userRole = "";
    
    if (isLogin) {
        web.bean.member.MemberDAO headerDao = new web.bean.member.MemberDAO();
        web.bean.member.MemberDTO headerDto = headerDao.idInfo(sessionId);
        
        if (headerDto != null && headerDto.getRole() != null) {
            userRole = headerDto.getRole().trim(); 
        }
    }
%>

<script>
    // 1. 로그인 여부 (true / false)
    const isUserLoggedIn = <%= isLogin %>;
    
    // 2. 로그인된 사용자 아이디
    const loggedInUserId = '<%= sessionId != null ? sessionId : "" %>';
    
    // 3. 자바스크립트 변수로 로그인한 유저의 권한을 바인딩
    const loggedInUserRole = '<%= userRole %>';
    
    // 자바스크립트 파일(main.js)에서도 이 절대 경로 주소를 쓸 수 있도록 공유합니다.
    const contextPath = '<%= request.getContextPath() %>';
</script>