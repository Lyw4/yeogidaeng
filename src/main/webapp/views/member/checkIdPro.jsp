<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 
===========================
	아이디 중복 확인 처리
===========================
--%>
<jsp:useBean class="web.bean.member.MemberDAO" id="dao" />

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    
    boolean isExist = dao.checkId(id); 
    
    // 앞뒤에 절대 공백이나 다른 글자가 안 섞이도록 지우고 깔끔하게 텍스트만 출력!
    if (isExist) {
        out.print("DUPLICATE");		// 사용 불가능 
    } else {
        out.print("USABLE");		// 사용 가능
    }
%>