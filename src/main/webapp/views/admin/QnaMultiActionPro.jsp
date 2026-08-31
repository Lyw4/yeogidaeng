<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="java.io.File" %>
<jsp:include page="checkStatus.jsp" />
<%
    request.setCharacterEncoding("UTF-8");
    
    // 1. 관리자 권한 철저히 확인
    String role = (String)session.getAttribute("role");
    if(!"ADMIN".equals(role)) {
        out.println("<script>alert('관리자 권한이 없습니다.'); history.back();</script>");
        return;
    }
    
    // 2. 파라미터 받기
    String actionType = request.getParameter("action"); // 'blind' 또는 'delete'
    String[] postIds = request.getParameterValues("chk_post"); // 체크된 글 번호들 (배열)
    
    // 선택된 항목이 없다면 뒤로가기
    if(postIds == null || postIds.length == 0) {
        out.println("<script>alert('선택된 항목이 없습니다.'); history.back();</script>");
        return;
    }

    BoardDAO dao = new BoardDAO();
    
    // 3. 배열을 돌면서 일괄 처리 실행
    for(String idStr : postIds) {
        int postId = Integer.parseInt(idStr);
        
        if("blind".equals(actionType)) {
            // [블라인드 토글]
            dao.toggleBlind(postId);
            
        } else if("delete".equals(actionType)) {
            // [일괄 삭제] 서버의 물리적 이미지 파일도 함께 삭제
            BoardDTO dto = dao.getQnaDetail(postId);
            if(dto != null && dto.getImage_file() != null && !dto.getImage_file().isEmpty()) {
                String uploadPath = application.getRealPath("/upload");
                File file = new File(uploadPath + "/" + dto.getImage_file());
                if(file.exists()) file.delete();
            }
            dao.deleteQna(postId); 
        }
    }
%>
<script>
    alert("선택한 항목의 처리가 완료되었습니다.");
    // 처리가 끝나면 다시 목록 1페이지로 새로고침
    location.href = "QnaList.jsp";
</script>