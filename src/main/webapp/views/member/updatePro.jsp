<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%	request.setCharacterEncoding("UTF-8"); %>

<jsp:useBean class="web.bean.member.MemberDAO" id="dao" />
<jsp:useBean class="web.bean.member.MemberDTO" id="dto" />
<jsp:setProperty name="dto" property="*" />

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 정보 수정 처리</title>
</head>

<body>
<% 
	// hidden으로 넘긴 id 사용
	dao.updateMember(dto);
%>

<script>
	alert("수정이 완료되었습니다.");
	window.location="myInfo.jsp";
</script>
</body>
</html>