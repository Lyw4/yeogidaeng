<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
</head>

<body>
<%-- post 방식 인코딩 --%>
<% request.setCharacterEncoding("UTF-8"); %>

<%-- DAO / DTO 객체 생성 --%>
<jsp:useBean class="web.bean.member.MemberDAO" id="dao" />
<jsp:useBean class="web.bean.member.MemberDTO" id="dto" />

<%-- 폼에서 넘어온 파라미터 dto에 자동으로 set --%>
<jsp:setProperty name="dto" property="*" />

<%
	// DB 작업 (INSERT)
	dao.insertMember(dto);
%>

<script> 
	alert("회원가입이 완료되었습니다.");
	window.location= "loginForm.jsp";
</script>

</body>
</html>