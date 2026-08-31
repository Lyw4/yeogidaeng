<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 
	 DELETE로 DB를 삭제하지 않고 UPDATE로 status를 탈퇴 상태(예: 0에서 1)로 바꾸기 
	 가장 많이 사용하는 표준적인 회원 탈퇴 방식
	 데이터를 DELETE로 날려버리면 해당 회원이 썼던 글이나 댓글 등이 전부 에러가 나거나 미아가 되기 때문에, 
	 status(상태) 값을 변경하는 방식이 훨씬 안전
--%>
<%@ page import = "web.bean.member.MemberDAO" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 탈퇴 처리</title>
<style>
    /* 1. 다른 페이지들과 동일한 부모 배경 및 폰트 세팅 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; /* 따뜻한 살구/베이지빛 배경 */
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh; /* 화면 정확히 정중앙 배치 */
    }

    /* 2. 주황색 테두리가 들어간 동글동글한 로딩/알림 카드 상자 */
    .loading-card {
        width: 380px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 50px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
        text-align: center;        /* 내용물 가운데 정렬 */
    }

    /* 알림 메시지 폰트 스타일 */
    .loading-card p {
        font-size: 16px;
        font-weight: bold;
        color: #e65c47;            /* 패밀리룩 다홍/주황색 */
        margin: 0;
    }
</style>
</head>

<body>

<div class="loading-card">
    <p>🐶 회원 탈퇴 처리 중 🐱</p>
</div>

<% 
	// 1. 세션에서 현재 로그인한 유저의 아이디 가져오기
	String sid = (String) session.getAttribute("sid");
	
	// 2. 로그인 안 되어 있으면 거부 처리
	if( sid == null ){
%>
	<script> 
		alert("로그인이 필요한 서비스 입니다.");
		location.href = "loginForm.jsp";
	</script>
<% 
	return;
	}
	
	// 3. DAO를 통해 회원 상태를 '탈퇴'로 업데이트하기
	MemberDAO dao = new MemberDAO();
	
	// 데이터를 delete 하지 않고, status를 업데이트하는 메서드 호출
	int result = dao.deleteMember(sid);
	
	if( result > 0 ){
		// 3. 탈퇴 성공 시 세션을 완전히 초기화하여 자동 로그아웃 처리!
		session.invalidate();
%>
		<script> 
			alert("회원 탈퇴가 정상적으로 완료되었습니다.");
			location.href="../main/mainPage.jsp";
		</script>
<% } else { %>
		<script> 
			alert("탈퇴 처리 중 오류가 발생했습니다. 다시 시도해 주세요.");
			history.back();
		</script>
<%	 } %>

</body>
</html>