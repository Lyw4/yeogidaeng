<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "web.bean.member.MemberDTO" %>
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
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>내 정보 조회</title>
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

    /* 1. 다른 페이지들과 동일한 부모 배경 및 폰트 세팅 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; /* 따뜻한 살구/베이지빛 배경 */
        margin: 0;
        padding: 40px 20px;
        display: flex;
        justify-content: center;
        align-items: flex-start;
        min-height: 100vh;
    }

    /* 2. 주황색 테두리가 들어간 동글동글한 정보 조회 박스 */
    .mypage-container {
        width: 480px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 40px 35px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
    }

    /* 대제목 스타일 */
    .mypage-container h2 {
        margin: 0 0 20px 0;
        color: #e65c47;            /* 패밀리룩 다홍/주황색 */
        font-size: 24px;
        font-weight: bold;
        text-align: center;
    }

    /* 구분선 스타일 입히기 */
    .mypage-container hr {
        border: none;
        border-top: 2px dashed #fcdad4;
        margin-bottom: 25px;
    }

    /* 3. 깔끔한 정보 테이블 가공 */
    .info-table {
        width: 100%;
        border-collapse: collapse;
        margin-bottom: 30px;
    }

    .info-table th, .info-table td {
        padding: 12px 10px;
        font-size: 14px;
        border-bottom: 1px solid #f8f1eb; /* 은은한 베이지색 구분선 */
    }

    /* 테이블 왼쪽 항목 이름 (라벨 역할) */
    .info-table th {
        width: 30%;
        text-align: left;
        color: #7d6b60;            /* 부드러운 브라운 톤 */
        font-weight: bold;
    }

    /* 테이블 오른쪽 실제 데이터 내용 */
    .info-table td {
        width: 70%;
        color: #333333;
        font-weight: 500;
    }

    /* 비밀번호처럼 보안이 필요한 항목 전용 회색 글씨 */
    .info-table td.masked-pw {
        color: #b0a090;
        letter-spacing: 2px;
    }

    /* 버튼들을 가로 일렬로 나란히 배치하는 부모 박스 */
	.button-group {
    	display: flex;            /* 가로 정렬 활성화 */
    	justify-content: center;  /* 버튼들을 가운데로 정렬 (좌측 정렬은 flex-start) */
    	gap: 12px;                /* 버튼과 버튼 사이의 간격 */
    	margin-top: 20px;         /* 위쪽 컴포넌트와의 여백 */
    	width: 100%;              /* 부모 너비에 맞춤 */
	}

	/* 기존 btn-submit 스타일에 width: 100%가 있다면 제거하거나 반반씩 나눠 갖도록 설정 */
	.btn-submit {
   	 	flex: 1;                  /* 두 버튼이 너비를 정확히 1:1로 반반 나눠 가짐 */
    	max-width: 160px;         /* 버튼이 너무 커지지 않도록 최대 너비 제한 */
   		padding: 11px;
    	font-size: 14px;
    	font-weight: bold;
    	border-radius: 50px;      /* 둥근 캡슐 마감 */
    	cursor: pointer;
    	/* 기존에 작성하신 배경색(그라데이션 등)이나 테두리 스타일이 아래에 적용됩니다 */
	}

    .btn-submit:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }
</style>
</head>

<body>
<div class="mypage-container">
	<div style="position: absolute; width: 100%; top: 0; left: 0;">
        <div class="top-logo">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp">🐾여기댕🐾</a>
        </div>
    </div>


    <h2>🐶 내 정보 조회 🐱</h2>
    <hr>
    
    <% if(member != null) { %>
        <table class="info-table">
            <tr>
                <th>아이디</th>
                <td><%= member.getId() %></td>
            </tr>
		
			<tr>
            <th>비밀번호</th>
            <%-- 정규식의 점(.)은 '모든 문자'를 의미합니다. 즉, 비밀번호의 모든 글자를 '●'로 바꿉니다! --%>
            <td class="masked-pw"><%= member.getPw().replaceAll(".", "●") %></td>
        </tr>
            <tr>
                <th>이름</th>
                <td><%= member.getName() %></td>
            </tr>
            <tr>
                <th>생년월일</th>
                <td>
                    <%= member.getBirth() != null && member.getBirth().toString().length() >= 10 ? member.getBirth().toString().substring(0, 10) : "미등록" %>
                </td>
            </tr>
            <tr>
                <th>전화번호</th>
                <td><%= member.getPhone() %></td>
            </tr>
            <tr>
                <th>성별</th>
                <td>
                    <%= member.getGender() != null && member.getGender().equals("m") ? "남자 👦" : "여자 👧" %>
                </td>
            </tr>
            <tr>
                <th>이메일</th>
                <td><%= member.getEmail() %></td>
            </tr>
            <tr>
                <th>가입일</th>
                <td>
                    <%= member.getReg() != null && member.getReg().toString().length() >= 10 ? member.getReg().toString().substring(0, 10) : member.getReg() %>
                </td>
            </tr>
        </table>
        
        <div class="button-group">
    	<button class="btn-submit" onclick="location.href='updateForm.jsp'">✏️ 정보 수정</button>
    	<button class="btn-submit" onclick="location.href='myPage.jsp'">📋 마이 페이지</button>
        <button class="btn-submit" onclick="if(confirm('정말 탈퇴하시겠습니까?')) location.href='deletePro.jsp'">❌ 회원 탈퇴</button>
		</div>
    <% } else { %>
        <p style="color: #d54c37; text-align: center; font-weight: bold;">💬 회원 정보를 불러오는 데 실패했습니다.</p>
    <% } %>
</div>
</body>
</html>