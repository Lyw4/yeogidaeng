<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="web.bean.member.MyBoardDAO" %>
<%@ page import="web.bean.board.ReplyDTO" %> 
<%@ page import="java.text.SimpleDateFormat" %> 

<%
    // 1. 세션에서 현재 로그인한 유저의 ID 가져오기
    String id = (String) session.getAttribute("sid");
    
    // 로그인이 안 되어 있으면 로그인 페이지로 튕겨내기
    if (id == null) {
%>
    	<script> 
    		alert("로그인 후 사용가능합니다.");
    		window.location="../mini/loginForm.jsp";
    	</script>
<%
        return; 
    }
    
    // 싱글톤으로 DAO 객체 가져오기
    MyBoardDAO dao = MyBoardDAO.getInstance();
    
    // 💡 댓글 목록 페이징 처리 (내 글 목록과 규칙 일치)
    int pageSize = 5; 
	
    String pageNum = request.getParameter("pageNum");
    if( pageNum == null ){
        pageNum = "1";
    }
	
    int currentPage = Integer.parseInt(pageNum);
    int startRow = (currentPage - 1) * pageSize + 1; 
    int endRow = currentPage * pageSize;             

    // 사용자가 작성한 '댓글'의 총 개수 가져오기
    List<ReplyDTO> myCommentList = dao.commentMyList(id); 
    int count = (myCommentList != null) ? myCommentList.size() : 0;

    // 날짜 포맷(yyyy-MM-dd) 가공 도구
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>내 댓글 목록</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');

/*  =========================================================
       🐾 상단 좌측 둥둥 떠있는 홈 로고 
	========================================================= */
    .top-logo {
        position: absolute; 
        top: 30px;
        left: 40px;
        z-index: 9999;
    }
    .top-logo a {
        font-family: 'Jua', sans-serif; /* 메인 로고와 동일한 글꼴 */
        font-size: 29px;                /* 메인 로고와 동일한 크기 */
        font-weight: normal;            /* 메인 로고와 동일한 굵기 */
        color: #FF725E;                 /* 메인 로고와 동일한 색상 */
        text-decoration: none;
    }
    


    /* 전체 배경을 내 글 목록과 똑같이 화사하고 맑은 연핑크/베이지 톤으로 일치 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fff9f6; 
        margin: 0;
        padding: 40px 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    /* 상단 메인 타이틀 스타일 변경 (내 글 목록과 완벽 일치) */
    .mypage-title {
        color: #ff6b6b;
        font-size: 24px;
        font-weight: bold;
        margin-bottom: 25px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* 컨테이너 폭 넓히기 일치 */
    .activity-container {
        width: 95%;
        max-width: 1400px;
    }

    /* 필터바 레이아웃 상단 탭 구조 일치 */
    .filter-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 20px;
    }

    .filter-left {
        display: flex;          
        flex-direction: row;    
        gap: 10px;              
        align-items: center;    
    }

    /* 알약 모양의 귀여운 탭 스타일 일치 */
    .btn-tab {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 8px 18px;
        background-color: #ffe5e0; 
        color: #ff8a75;
        text-decoration: none;
        font-size: 14px;
        font-weight: bold;
        border-radius: 50px;
        transition: all 0.2s ease;
    }
    
    .btn-tab.active, .btn-tab:hover {
        background-color: #ff8a75;
        color: #ffffff;
    }

    /* 섹션 타이틀 스타일 일치 */
    .section-subtitle {
        font-size: 16px;
        font-weight: bold;
        color: #ff765e;
        margin: 20px 0 12px 10px;
        text-align: left;
    }

    /* 테이블 라운딩 블록 및 그림자 완벽 매칭 */
    .activity-table {
        width: 100%;
        border-collapse: collapse;
        background-color: #ffffff;
        border-radius: 15px;
        overflow: hidden; 
        box-shadow: 0 4px 20px rgba(255, 138, 117, 0.08);
        margin-bottom: 30px;
    }

    .activity-table th, .activity-table td {
        padding: 16px 12px;
        text-align: center;
        font-size: 14px;
        border-bottom: 1px solid #fff0ed;
    }

    /* 부드러운 살구 핑크색 헤더 매칭 */
    .activity-table th {
        background-color: #fff0ed; 
        color: #ff765e;
        font-weight: bold;
    }

    .activity-table td {
        color: #555555;
    }

    .activity-table td.text-left {
        text-align: left;
        padding-left: 20px;
    }
    
    .activity-table td a {
        color: #333333;
        text-decoration: none;
        font-weight: bold;
    }
    
    .activity-table td a:hover {
        color: #ff6b6b;
    }

    .activity-table tr:hover {
        background-color: #fffdfd;
    }

    /* 💡 알록달록 게시판 뱃지(Badge) 전용 스타일 똑같이 반영 */
    .board-badge {
        display: inline-block;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: bold;
        border-radius: 50px;
        text-transform: uppercase;
    }
    
    /* 각 게시판 종류별 커스텀 색상 매칭 */
    .badge-hospital { background-color: #ffeae8; color: #ff6b6b; }
    .badge-suggestion { background-color: #fff1db; color: #ffa826; }
    .badge-play { background-color: #e3f9ff; color: #00b4d8; }
    .badge-hotel { background-color: #f0e6ff; color: #8a2be2; }
    .badge-beauty { background-color: #ffe6f2; color: #ff1493; }
    .badge-default { background-color: #f0f0f0; color: #777777; }

    .no-data {
        text-align: center;
        padding: 60px 0;
        color: #ffb3a7;
        font-weight: bold;
        font-size: 16px;
    }

    /* 하단 페이징 스타일 일치 */
    .pagination {
        display: flex;
        justify-content: center;
        align-items: center;
        gap: 12px;
        margin-top: 15px;
    }

    .pagination a {
        display: inline-block;
        padding: 4px 10px;
        color: #ff8a75;
        text-decoration: none;
        font-size: 15px;
        font-weight: bold;
        transition: all 0.2s ease;
    }

    .pagination a:hover {
        color: #ff5233;
        transform: scale(1.1);
    }

    .pagination .current-page {
        display: inline-block;
        padding: 4px 10px;
        color: #ff5233;
        font-size: 16px;
        font-weight: bold;
        text-decoration: underline;
    }
</style>
</head>
<body>
	<div style="position: absolute; width: 100%; top: 0; left: 0;">
        <div class="top-logo">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp">🐾여기댕🐾</a>
        </div>
    </div>


    <div class="mypage-title">💬 내 댓글 목록</div>

    <div class="activity-container">
        
        <div class="filter-bar">
            <div class="filter-left">
                <a href="myList.jsp" class="btn-tab">📝 내 글 목록</a>
                <a href="myCommentList.jsp" class="btn-tab active">💬 내 댓글 목록</a> 
                <a href="myQnaList.jsp" class="btn-tab">❓ 내 문의 목록</a>
            </div>
            <div>
                <a href="myPage.jsp" class="btn-tab" style="background-color: #ff8a75; color: white;">🏠 마이페이지 홈</a>
            </div>
        </div>

        <div class="section-subtitle">내가 작성한 댓글 수 : <%= count %>개</div>

        <table class="activity-table">
            <thead>
                <tr>
                    <th width="10%">번호</th>
                    <th width="15%">게시판</th>
                    <th width="15%">카테고리</th>
                    <th width="40%">댓글 내용</th>
                    <th width="20%">날짜</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (myCommentList != null && !myCommentList.isEmpty()) {
                        int endLoop = Math.min(startRow - 1 + pageSize, myCommentList.size());
                        for (int i = startRow - 1; i < endLoop; i++) {
                            ReplyDTO reply = myCommentList.get(i);
                            
                            // 안전하게 reply 객체의 데이터를 가져옵니다.
                            String boardType = reply.getCategory() != null ? reply.getCategory().toLowerCase() : ""; 
                            String badgeClass = "badge-default";
                            String badgeName = "";
                            
                            // 🔥 에러 원인 해결: category 변수를 딱 한 번만 선언합니다!
                            String category = "일반"; 
                            
                            // 가져온 카테고리 명칭에 따라 뱃지 스타일 분기 처리
                            if(boardType.contains("병원") || boardType.toLowerCase().contains("hospital")) { badgeClass = "badge-hospital"; badgeName = "HOSPITAL"; }
                            else if(boardType.contains("놀거리") || boardType.toLowerCase().contains("play")) { badgeClass = "badge-play"; badgeName = "PLAY"; }
                            else if(boardType.contains("호텔") || boardType.toLowerCase().contains("hotel")) { badgeClass = "badge-hotel"; badgeName = "HOTEL"; }
                            else if(boardType.contains("미용") || boardType.toLowerCase().contains("beauty")) { badgeClass = "badge-beauty"; badgeName = "BEAUTY"; }
                %>
		                    <tr>
		                        <td><%= reply.getReplyId() %></td>
		                        
		                        <td><span class="board-badge <%= badgeClass %>"><%= badgeName %></span></td>
		                        
		                        <td><%= category %></td>
		                        
		                        <td class="text-left">
    							    <a href="../board/detail.jsp?postId=<%= reply.getPostId() %>"><%= reply.getContent() %></a>
								</td>
		                        
		                        <td><%= sdf.format(reply.getRegDate()) %></td>
		                    </tr>
                <%
                        } 
                    } else { 
                %>
                    <tr>
                        <td colspan="5" class="no-data">작성한 댓글이 존재하지 않습니다.</td>
                    </tr>
                <%
                    } 
                %>
            </tbody>
        </table>
        
        <div class="pagination">
            <%	
                if (count > 0) {
                    int pageCount = count / pageSize + (count % pageSize == 0 ? 0 : 1);
                	int pageBlock = 5; 
                    int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
                    int endPage = startPage + pageBlock - 1;
                    if (endPage > pageCount) endPage = pageCount;
                    
                    if (startPage > pageBlock) {
            %>
                        <a href="myCommentList.jsp?pageNum=<%= startPage - pageBlock %>">이전</a>
            <%      
                    }
                    
                    for (int i = startPage; i <= endPage; i++) { 
                        if (i == currentPage) {
            %>
                            <span class="current-page"><%= i %></span>
            <%          
                        } else {
            %>
                            <a href="myCommentList.jsp?pageNum=<%= i %>"><%= i %></a> 
            <%          
                        }
                    }
                    
                    if (endPage < pageCount) {
            %>
                        <a href="myCommentList.jsp?pageNum=<%= startPage + pageBlock %>">다음</a>
            <%
                    }
                }
            %>
        </div>
    </div>

</body>
</html>