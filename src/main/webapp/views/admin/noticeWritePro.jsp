<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.admin.AdminDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

    String role = (String) session.getAttribute("role");
    if (role == null || !"ADMIN".equals(role)) {
%>
        <script>
            alert("⚠️ 접근 권한이 없습니다.");
            location.href = "noticeManage.jsp";
        </script>
<%
        return;
    }

    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String isPinned = request.getParameter("is_pinned");

    if (title == null || title.trim().equals("") || content == null || content.trim().equals("")) {
%>
        <script>
            alert("❌ 제목과 내용은 필수 입력 항목입니다.");
            history.back();
        </script>
<%
        return;
    }
    
    // 🔥 하드코딩 제거! 로그인한 관리자의 실제 아이디 가져오기
    String writerId = (String) session.getAttribute("id");
    if(writerId == null) writerId = (String) session.getAttribute("sid");
    if(writerId == null) writerId = "ADMIN"; // 최후의 기본값

    BoardDTO boardDTO = new BoardDTO();
    boardDTO.setTitle(title);
    boardDTO.setContent(content);
    boardDTO.setWriter(writerId); // 🔥 세션 아이디 적용 완료!
    boardDTO.setCategory("Y".equals(isPinned) ? "PIN" : "NORMAL");

    AdminDAO adminDAO = new AdminDAO();
    int result = adminDAO.insertNotice(boardDTO);
    if(result > 0) {
%>
        <script>
            alert("✅ 공지사항이 성공적으로 등록되었습니다!");
            location.href = "noticeManage.jsp"; 
        </script>
<%
    } else {
%>
        <script>
            alert("❌ 등록 실패: 데이터베이스 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>