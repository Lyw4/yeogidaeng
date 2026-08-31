<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %> 
<%@ page import="web.bean.member.MemberDAO" %>
<%@ page import="web.bean.member.MemberDTO" %>
<%@ page import="web.bean.member.MyBoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.board.ReplyDTO" %> 
<%@ page import="java.text.SimpleDateFormat" %>

<jsp:useBean class="web.bean.member.MemberDAO"  id="dao" />
<jsp:useBean class="web.bean.member.MemberDTO" id="dto" />
<jsp:setProperty name="dto" property="*" />

<% 
	// 1. 세션에서 로그인한 아이디 가져오기
	String sid = (String)session.getAttribute("sid");

	// 로그인 안 되어 있으면 로그인 폼으로 튕겨내기 
	if( sid == null ){
%>
		<script> 
			alert("로그인이 필요한 서비스 입니다.");
			location.href = "loginForm.jsp";
		</script>
<% 
		return;
	}
	
	// 3. DAO를 통해 DB에서 이 사용자(sid)의 진짜 정보 가져오기
	MemberDTO member = dao.idInfo(sid);
	
	// 게시판 전용 싱글톤 DAO 호출
 	MyBoardDAO boardDao = MyBoardDAO.getInstance(); 
	
	int startRow = 1; // 최신순 1등 행부터
	int endRow = 2;   // 딱 2등 행까지만 데이터 제한 설정!
	
	// 진짜 내 글 목록 가져오기
	List<BoardDTO> boardMyList = boardDao.boardMyList(sid, startRow, endRow);
	
	// 진짜 내 댓글 목록 전체 가져오기
	List<ReplyDTO> myCommentList = boardDao.commentMyList(sid);
	
	// 진짜 내 문의 목록 가져오기 
	List<BoardDTO> myQnaList = boardDao.boardMyQnaList(sid, startRow, endRow);
	
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>마이페이지 (내 정보 및 활동)</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');

/* =========================================================
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
    

    /* 전체 부모 및 배경 테마 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; /* 따뜻한 살구/베이지빛 배경 */
        margin: 0;
        padding: 40px 20px;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    /* 상단 타이틀 스타일 */
    .mypage-title {
        color: #4a3b32;
        font-size: 22px;
        font-weight: bold;
        margin-bottom: 25px;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    /* 1. 프로필 카드 박스 액자 스타일 */
    .profile-card {
        background-color: #ffffff;
        border: 2px solid #dcd1c4;
        border-radius: 12px;
        padding: 25px 50px;
        width: 450px;
        box-shadow: inset 0 0 0 4px #ffffff, 0 4px 15px rgba(224, 206, 194, 0.3);
        outline: 1px solid #dcd1c4;
        outline-offset: -6px;
        text-align: center;
        margin-bottom: 30px;
    }

    .profile-card h4 {
        margin: 0 0 15px 0;
        color: #333;
        font-size: 18px;
    }

    .profile-info-container {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 25px;
    }

    /* 프로필 이미지 동그라미 테두리 */
    .profile-avatar {
        width: 80px;
        height: 80px;
        border-radius: 50%;
        border: 2px solid #cdbfae;
        background-color: #fdf6f0;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 40px; 
    }

    /* 프로필 텍스트 줄 설정 */
    .profile-details {
        text-align: left;
    }

    .info-row {
        background-color: #f8f9fa;
        border: 1px solid #e9ecef;
        border-radius: 6px;
        padding: 6px 12px;
        margin: 6px 0;
        font-size: 14px;
        color: #495057;
        width: 180px;
    }
    
    .info-row strong {
        color: #333;
    }

    /* 2. 가로형 주요 메뉴 버튼 그룹 */
    .main-menu-group {
        display: flex;
        gap: 12px;
        margin-bottom: 45px;
    }

    .btn-capsule {
        display: flex;
        align-items: center;
        gap: 6px;
        padding: 10px 20px;
        background-color: #e88676; 
        color: #ffffff;
        text-decoration: none;
        font-size: 14px;
        font-weight: bold;
        border-radius: 50px; 
        box-shadow: 0 4px 6px rgba(232, 134, 118, 0.2);
        transition: all 0.2s ease;
    }

    .btn-capsule:hover {
        background-color: #df6f5d;
        transform: translateY(-2px);
    }
    
    .btn-capsule.logout {
        background-color: #cda685;
        box-shadow: 0 4px 6px rgba(205, 166, 133, 0.2);
    }
    .btn-capsule.logout:hover {
        background-color: #bd936f;
    }

    /* 3. 내 활동 영역 전체 컨테이너 */
    .activity-container {
        width: 90%;
        max-width: 1100px;
    }

    /* 내 활동 필터바 레이아웃 */
    .filter-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }

    .filter-left {
        display: flex;          
        flex-direction: row;    
        gap: 10px;              
        align-items: center;    
	}

    .btn-tab {
        display: flex;
        align-items: center;
        gap: 4px;
        padding: 6px 14px;
        background-color: #f7d5cc; 
        color: #e88676;
        text-decoration: none;
        font-size: 13px;
        font-weight: bold;
        border-radius: 50px;
    }
    
    .btn-tab:hover {
        background-color: #e88676;
        color: #ffffff;
    }

    /* 섹션 타이틀 */
    .section-subtitle {
        font-size: 17px;
        font-weight: bold;
        color: #3a2e2b;
        margin: 0 0 15px 0;
        text-align: left;
    }

    /* 4. 와이드 리스트 테이블 스타일 */
    .activity-table {
        width: 100%;
        border-collapse: collapse;
        background-color: #ffffff;
        border-radius: 12px;
        overflow: hidden; 
        box-shadow: 0 4px 12px rgba(0,0,0,0.03);
    }

    .activity-table th, .activity-table td {
        padding: 14px 20px;
        text-align: center;
        font-size: 14px;
        border-bottom: 1px solid #f1ece7;
    }

    .activity-table th {
        background-color: #e1ebf4; 
        color: #384d61;
        font-weight: bold;
    }

    .activity-table td {
        color: #4a4a4a;
    }

    .activity-table td.text-left {
        text-align: left;
    }
    
    /* 링크 컬러 스타일 추가 */
    .activity-table td a {
        color: #4a4a4a;
        text-decoration: none;
    }
    .activity-table td a:hover {
        color: #e88676;
        text-decoration: underline;
    }

    .activity-table tr:hover {
        background-color: #fafbfc;
    }

    /* 💡 알록달록 게시판 뱃지 전용 공통 스타일 정의 */
    .board-badge {
        display: inline-block;
        padding: 4px 10px;
        font-size: 11px;
        font-weight: bold;
        border-radius: 50px;
        text-transform: uppercase;
    }
    .badge-hospital { background-color: #ffeae8; color: #ff6b6b; }
    .badge-suggestion { background-color: #fff1db; color: #ffa826; }
    .badge-play { background-color: #e3f9ff; color: #00b4d8; }
    .badge-hotel { background-color: #f0e6ff; color: #8a2be2; }
    .badge-beauty { background-color: #ffe6f2; color: #ff1493; }
    .badge-default { background-color: #f0f0f0; color: #777777; }
    
    /* 답변 상태 뱃지 */
    .badge {
        padding: 4px 8px;
        border-radius: 8px;
        font-size: 11px;
        font-weight: bold;
    }
    .badge.wait { background-color: #f1ece7; color: #7d7d7d; }
    .badge.complete { background-color: #e3f2fd; color: #0d47a1; }
    
    .no-data {
        text-align: center;
        padding: 50px 0;
        color: #cdbfae;
        font-weight: bold;
    }
</style>
</head>
<body>
  	<div style="position: absolute; width: 100%; top: 0; left: 0;">
        <div class="top-logo">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp">🐾여기댕🐾</a>
        </div>
    </div>

    <div class="mypage-title">📋 마이페이지 </div>

    <div class="profile-card">
        <h4>환영합니다! <%= member.getId() %> 님</h4>
        <div class="profile-info-container">
            <div class="profile-avatar">🐶</div>
            <div class="profile-details">
                <div class="info-row">아이디: <strong><%= member.getId() %></strong></div>
                <div class="info-row">이름: <strong><%= member.getName() %></strong></div>
            </div>
        </div>
    </div>

    <div class="main-menu-group">
        <a href="checkPwForm.jsp" class="btn-capsule">👁️ 내 정보 조회</a>
        <a href="logout.jsp" class="btn-capsule logout">🚪 로그아웃</a>
    </div>

    <div class="activity-container">
        
        <div class="filter-bar">
            <div class="filter-left">
    			<a href="myList.jsp" class="btn-tab">📝 내 글 목록</a>
    			<a href="myCommentList.jsp" class="btn-tab">💬 내 댓글 목록</a>
    			<a href="myQnaList.jsp" class="btn-tab">❓ 내 문의 목록</a>
			</div>
        </div>

        <div class="section-subtitle">내 글 활동 내역 (최근 2개)</div>

        <table class="activity-table">
            <thead>
                <tr>
                    <th width="6%">번호</th>
                    <th width="12%">게시판</th>
                    <th width="10%">카테고리</th>
                    <th width="35%">제목</th>
                    <th width="10%">작성자</th>
                    <th width="11%">날짜</th>
                    <th width="4%">👀</th> <th width="4%">👍</th> <th width="4%">👎</th> <th width="4%">🚨</th> </tr>
            </thead>
            <tbody>
            
           		 <%-- ======================== 
		  				내 글 활동 내역  
	 				  ======================== --%>
	 				  
                <%
                    if (boardMyList != null && !boardMyList.isEmpty()) {
                        for (BoardDTO board : boardMyList) {
                            
                            String boardType = board.getBoard_type() != null ? board.getBoard_type().toLowerCase() : "";	
                            String badgeClass = "badge-default";	
                            String badgeName = board.getBoard_type() != null ? board.getBoard_type() : "일반";
                            
                            if(boardType.contains("hospital")) { badgeClass = "badge-hospital"; badgeName = "HOSPITAL"; }
                            else if(boardType.contains("play")) { badgeClass = "badge-play"; badgeName = "PLAY"; }
                            else if(boardType.contains("hotel")) { badgeClass = "badge-hotel"; badgeName = "HOTEL"; }
                            else if(boardType.contains("beauty")) { badgeClass = "badge-beauty"; badgeName = "BEAUTY"; }
                
                %>
		                    <tr>
		                        <td><%= board.getPost_id() %></td>
		                        
		                        <td><span class="board-badge <%= badgeClass %>"><%= badgeName %></span></td>
		                        
		                        <td><%= board.getCategory() %></td>
		                        
		                        <td class="text-left">
		                            <a href="../board/detail.jsp?postId=<%= board.getPost_id() %>"><%= board.getTitle() %></a>
		                        </td>
		                        
		                        <td><%= board.getWriter() %></td>
		                        
		                        <td><%= sdf.format(board.getReg_date()) %></td>
		                        
		                        <td><%= board.getView_count() %></td>
		                        <td><%= board.getLike_count() %></td>
		                        <td><%= board.getDislike_count() %></td>
		                        <td><span style="color: #ff6b6b;"><%= board.getReport_count() %></span></td>
		                    </tr>
                <%
                        } 
                    } else {
                %>
                    <tr>
                        <td colspan="10" class="no-data">최근에 작성한 게시글이 존재하지 않습니다.</td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <br><br>
        
        <%-- ======================== 
		  		내 댓글 활동 내역  
	 		 ======================== --%>
	 		 
        <div class="section-subtitle">내 댓글 활동 내역 (최근 2개)</div>

        <table class="activity-table">
            <thead>
                <tr>
                    <th width="10%">번호</th>
                    <th width="15%">게시판</th>
                    <th width="15%">카테고리</th>
                    <th width="40%">댓글 내용</th>                   
                    <th width="20%">작성일</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (myCommentList != null && !myCommentList.isEmpty()) {
                        int endLoop = Math.min(2, myCommentList.size());
                        
                        for (int i = 0; i < endLoop; i++) {
                            ReplyDTO reply = myCommentList.get(i);
                            
                            String boardType = reply.getCategory() != null ? reply.getCategory() : ""; 
                            String badgeClass = "badge-default";
                            String badgeName = "일반";
                            
                            if(boardType.contains("병원") || boardType.toLowerCase().contains("hospital")) { badgeClass = "badge-hospital"; badgeName = "HOSPITAL"; }
                            else if(boardType.contains("놀거리") || boardType.toLowerCase().contains("play")) { badgeClass = "badge-play"; badgeName = "PLAY"; }
                            else if(boardType.contains("호텔") || boardType.toLowerCase().contains("hotel")) { badgeClass = "badge-hotel"; badgeName = "HOTEL"; }
                            else if(boardType.contains("미용") || boardType.toLowerCase().contains("beauty")) { badgeClass = "badge-beauty"; badgeName = "BEAUTY"; }
                %>
		                    <tr>
		                        <td><%= reply.getReplyId() %></td>
		                        <td><span class="board-badge <%= badgeClass %>"><%= badgeName %></span></td>
		                        <td><%= reply.getCategory() %></td>
		                        <td class="text-left">
		                            <a href="../board/detail.jsp?postId=<%= reply.getPostId() %>">
		                                <%= reply.getContent() %>
		                            </a>
		                        </td>                 
		                        <td><%= sdf.format(reply.getRegDate()) %></td>
		                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="5" class="no-data">최근에 작성한 댓글이 존재하지 않습니다.</td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>
        
        <br><br>
        
  		<%-- ======================== 
		  		내 문의 활동 내역  
	 		 ======================== --%>
	 		 
        <div class="section-subtitle">내 문의 활동 내역 (최근 2개)</div>

        <table class="activity-table">
            <thead>
                <tr>
                	<th width="10%">번호</th>
                	<th width="15%">카테고리</th>
                    <th width="40%">문의 제목</th>
                    <th width="20%">작성일</th>
                    <th width="15%">처리상태</th>
                </tr>
            </thead>
            <tbody>
                <%
                    if (myQnaList != null && !myQnaList.isEmpty()) {
                        for (BoardDTO qna : myQnaList) {
                            
                            String currentStatus = qna.getStatus();
                            if(currentStatus == null) {
                                currentStatus = "답변대기";
                            }
                %>
		                    <tr>
		                    	<td><%= qna.getPost_id() %></td>
		                    	<td><%= qna.getCategory() %></td>
		                    	<td class="text-left">
		                    	    <a href="../board/detail.jsp?postId=<%= qna.getPost_id() %>"><%= qna.getTitle() %></a>
		                    	</td>
		                    	<td><%= sdf.format(qna.getReg_date()) %></td>
		                    	<td>
		                    		<% if("답변완료".equals(currentStatus.trim())) { %>
		                    			<span class="badge complete">답변완료</span>
		                    		<% } else { %>
		                    			<span class="badge wait">답변대기</span>
		                    		<% } %>
		                    	</td>
		                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr>
                        <td colspan="5" class="no-data">최근에 접수한 문의 내역이 존재하지 않습니다.</td>
                    </tr>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>
</body>
</html>