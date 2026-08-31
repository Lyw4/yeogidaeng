<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>

<%--
로그아웃 처리
===============
일반 로그아웃
	1. 특정 세션 값만 삭제
		session.removeAttribute("");
	2. 세션 전체 삭제
		session.invalidate();
		
자동로그인 로그아웃
	쿠키 + 세션 삭제
	.setMaxAge(0);
	
--%>

<head>
<meta charset="UTF-8">
<title>로그아웃</title>
</head>

<body>
<% 
	// 쿠키 꺼냄
	Cookie[] cookies = request.getCookies();
	
	// 쿠키 존재할 때 처리
	if( cookies != null ){
		// 하나씩 꺼내기
		for( Cookie c : cookies ){
			// 쿠키 이름이 cid, cpw, cauto 중 하나만 삭제
			if( c.getName().equals("cid") || c.getName().equals("cpw") || c.getName().equals("cauto")){
				
				// 유효시간 0초 -> 즉시 만료 
				c.setMaxAge(0);
				// 만료된 쿠키 브라우저에 전송 -> 삭제
				response.addCookie(c);
				
			}
		}
	}
	
	// 세션 전체 삭제
	session.invalidate();
	
	// 메인 페이지로 이동
	response.sendRedirect("../main/mainPage.jsp");
%>
</body>
</html>