<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인 처리</title>
</head>
<%
request.setCharacterEncoding("UTF-8");
%>

<jsp:useBean class="web.bean.member.MemberDAO" id="dao" />
<jsp:useBean class="web.bean.member.MemberDTO" id="dto" />
<jsp:setProperty name="dto" property="*" />

<body>
	<%--
1. id/pw 확인	-> 결과 String

2. 일치하면 (SUCCESS)
	session 에 id 저장
	mainPage.jsp 으로 이동
	
3. 상황별 실패 코드에 따라 알림창 띄우고 이전 페이지로 이동
--%>
</body>
<%
String pw = request.getParameter("pw").trim(); // 앞뒤 공백 강제 제거
String loginResult = dao.loginCheck(dto);

if ("SUCCESS".equals(loginResult)) {
	// 로그인 성공 -> 세션 무조건 생성

	// 자동로그인 체크시에만 쿠키 생성 -> 새로운 쿠키 굽기
	if (dto.getAuto() != null && dto.getAuto().equals("1")) {

		// 쿠키 생성
		Cookie coo1 = new Cookie("cid", dto.getId());
		Cookie coo2 = new Cookie("cpw", dto.getPw());
		Cookie coo3 = new Cookie("cauto", dto.getAuto());

		// 유효시간 7일 설정 ( 60초 * 60초 * 24시간 * 7일 )
		coo1.setMaxAge(60 * 60 * 24 * 7);
		coo2.setMaxAge(60 * 60 * 24 * 7);
		coo3.setMaxAge(60 * 60 * 24 * 7);

		// 쿠키 브라우저 전송 -> 브라우저가 쿠키를 저장
		response.addCookie(coo1);
		response.addCookie(coo2);
		response.addCookie(coo3);

	} else {
		// 자동로그인 체크를 안 하고 로그인
		// 자동로그인을 쓰다가 안 쓸 때 기존에 남아있는 쿠키들을 삭제
		Cookie coo1 = new Cookie("cid", "");
		Cookie coo2 = new Cookie("cpw", "");
		Cookie coo3 = new Cookie("cauto", "");

		// 유효시간을 0으로 만들면 브라우저가 즉시 쿠키를 삭제
		coo1.setMaxAge(0);
		coo2.setMaxAge(0);
		coo3.setMaxAge(0);

		response.addCookie(coo1);
		response.addCookie(coo2);
		response.addCookie(coo3);
	}

	// 💡 세션 생성 (회원님 게시판용 sid + 팀원 관리자용 id 모두 발급)
	session.setAttribute("sid", dto.getId());
	session.setAttribute("id", dto.getId());

	// 🔥 핵심 수정! 아이디로 구별하지 않고, DB에서 꺼내온 '진짜 권한'을 바로 부여합니다!
	String userRole = dto.getRole();
	if (userRole == null || userRole.isEmpty()) {
		userRole = "USER"; // 혹시 DB에 권한이 비어있으면 기본으로 일반 유저 처리
	}
	session.setAttribute("role", userRole);

	response.sendRedirect("../main/mainPage.jsp");

} else if ("WITHDRAWN".equals(loginResult)) { // 탈퇴한 회원 (status = 0)
%>
<script>
	alert("탈퇴한 회원입니다.");
	history.go(-1);
</script>

<%
} else if ("NOT_FOUND".equals(loginResult)) { // 존재하지 않는 아이디
%>
<script>
	alert("존재하지 않는 아이디입니다.");
	history.go(-1);
</script>

<%
} else if ("WRONG_PW".equals(loginResult)) { // 일치하지 않은 비밀번호
%>
<script>
	alert("비밀번호가 일치하지 않습니다.");
	history.go(-1);
</script>
<%
} else if ("SUSPENDED".equals(loginResult)) { // 변수명 loginResult로 일치 및 괄호 정돈 (status = -1)
%>
<script>
	alert("이용이 일시 정지된 계정입니다. 관리자에게 문의하세요.");
	history.go(-1);
</script>
<%
} else { // FAIL 이나 알 수 없는 결과가 리턴되었을 때의 예외 처리
%>
<script>
	alert("로그인 정보가 올바르지 않습니다.");
	history.go(-1);
</script>
<%
}
%>
</html>