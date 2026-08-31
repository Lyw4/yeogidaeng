<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>

<%
    // 💡 [보안 강화] 로그인을 안 한 사용자가 직접 접근할 경우 여기서 차단
    String sid = (String)session.getAttribute("sid");
    if (sid == null) {
%>
        <script>
            alert("로그인 후 이용 가능합니다.");
            history.back(); // 이전 페이지로 돌려보냄
        </script>
<%
        return; // 아래의 DAO 로직이 실행되지 않도록 여기서 코드 종료
    }

    // --- (이 아래부터 기존의 정상적인 로직을 그대로 두시면 됩니다) ---
    int postId = Integer.parseInt(request.getParameter("postId"));
    String type = request.getParameter("type"); 

    BoardDAO dao = new BoardDAO();
    int result = dao.updateCount(postId, type); 

    if (result > 0) {
        if ("report_count".equals(type)) {
%>
            <script>
                alert("신고가 접수되었습니다.");
                location.href="detail.jsp?postId=<%= postId %>";
            </script>
<%
        } else {
            response.sendRedirect("detail.jsp?postId=" + postId);
        }
    } else {
%>
        <script>
            alert("이미 참여하셨거나 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>