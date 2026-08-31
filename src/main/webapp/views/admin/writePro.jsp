<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.admin.AdminDAO" %>
<%
    // 1. 파라미터 한글 깨짐 방지
    request.setCharacterEncoding("UTF-8");

    // 2. 폼에서 날아온 데이터 꺼내기
    String title = request.getParameter("title");
    String content = request.getParameter("content");
    String isPinned = request.getParameter("is_pinned"); // 체크되면 "Y", 안되면 null
    
    // 3. DTO 가방에 데이터 담기
    BoardDTO boardDTO = new BoardDTO();
    boardDTO.setTitle(title);
    boardDTO.setContent(content);
    boardDTO.setWriter("ad"); // 관리자 아이디 고정값 세팅 (member 데이터 매치)
    
    // [핀 고정 여부 분기 구조]
    // 광일님의 AdminDAO insertNotice SQL문과 BoardDTO 필드에 맞춰 category에 명확하게 주입합니다.
    if("Y".equals(isPinned)) {
        boardDTO.setCategory("PIN"); 
    } else {
        boardDTO.setCategory("NORMAL");
    }

    // 4. DAO를 통해 오라클 IDENTITY 자동 증가 기능이 탑재된 board 테이블에 최종 데이터 삽입
    AdminDAO adminDAO = new AdminDAO();
    int result = adminDAO.insertNotice(boardDTO);

    if(result > 0) {
%>
        <script>
            alert("✅ 공지사항이 성공적으로 등록되었습니다!");
            location.href = "<%= request.getContextPath() %>/admin/noticeManage.jsp"; 
        </script>
<%
    } else {
%>
        <script>
            alert("❌ 공지사항 등록에 실패했습니다. 데이터베이스 연동을 다시 확인해 주세요.");
            history.back(-1); // 실패 시 작성하던 내용 유지한 채로 폼으로 복귀
        </script>
<%
    }
%>