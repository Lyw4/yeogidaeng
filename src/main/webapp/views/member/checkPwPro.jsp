<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.member.MemberDAO" %>
<%@ page import="web.bean.member.MemberDTO" %>

<%
    // 1. 세션에서 로그인된 아이디 확보 및 한글 인코딩
    request.setCharacterEncoding("UTF-8");
    String sid = (String)session.getAttribute("sid");
    
    if(sid == null) {
        response.sendRedirect("loginForm.jsp");
        return;
    }

    // 사용자가 입력 폼에 적은 비밀번호 가져오기
    String pw = request.getParameter("pw");

    // 2. DAO를 생성하여 본인 확인 메서드 실행
    MemberDAO dao = new MemberDAO();
    
	// checkPwPro.jsp 내부 검증 로직 대체 예시
    MemberDTO member = dao.idInfo(sid);

    if(member != null && member.getPw().equals(pw)) {
        // 비밀번호 일치! 조회 페이지로 이동
        response.sendRedirect("myInfo.jsp"); 
    } else {
%>
       <script> 
       	alert("맞지 않은 비밀번호입니다. 다시 입력해주세요.");
       	history.back();
       </script> 
             
<%    }	%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비밀번호 확인</title>
</head>

<body>
</body>
</html>