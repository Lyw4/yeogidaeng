<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");
    
    // 1. 세션에서 현재 로그인 유저 가져오기
    String userId = (String)session.getAttribute("userId");
    
    // 2. 삭제할 글 번호 및 권한 체크
    int postId = Integer.parseInt(request.getParameter("post_id"));
    BoardDAO boardDAO = new BoardDAO();
    BoardDTO dto = boardDAO.getQnaDetail(postId); // 글 정보 불러오기

    // 3. 보안 로직: 로그인 안 했거나, 작성자/관리자가 아니면 삭제 불가
    boolean isAdmin = "admin".equals(userId);
    boolean isAuthor = (userId != null && userId.equals(dto.getWriter()));

    if(userId == null || (!isAdmin && !isAuthor)) {
%>
        <script>
            alert("권한이 없습니다. 본인의 글만 삭제할 수 있습니다.");
            history.back();
        </script>
<%
        return;
    }

    // 4. [파일 삭제] DB 삭제 전, 서버의 물리적 이미지 파일 삭제
    if(dto.getImage_file() != null && !dto.getImage_file().isEmpty()) {
        String uploadPath = application.getRealPath("/upload");
        File file = new File(uploadPath + "/" + dto.getImage_file());
        if(file.exists()) {
            file.delete();
        }
    }

    // 5. [DB 삭제] 데이터 삭제
    boardDAO.deleteQna(postId);
%>
<script>
    alert("🗑️ 게시글이 안전하게 삭제되었습니다.");
    location.href = "QnaList.jsp";
</script>