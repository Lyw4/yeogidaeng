<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="java.io.File" %>

<%
    request.setCharacterEncoding("UTF-8");

    // 1. 파일 업로드 설정
    String uploadPath = application.getRealPath("/upload");
    int size = 10 * 1024 * 1024; // 10MB 제한

    // 🔥 [핵심 수정] 폴더가 없으면 자동으로 생성해 주는 마법의 코드 3줄!
    java.io.File uploadDir = new java.io.File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs(); // 경로상의 모든 폴더를 알아서 만들어 줍니다.
    }

    // 🔥 빠져있던 try ~ catch 블록 완벽하게 복구!
    try {
        MultipartRequest multi = new MultipartRequest(request, uploadPath, size, "UTF-8", new DefaultFileRenamePolicy());
        
        // 3. 파라미터 접수 (request 대신 multi 사용!)
        int postId = Integer.parseInt(multi.getParameter("post_id"));
        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        
        // 새롭게 업로드된 파일명 확인
        String newImage = multi.getFilesystemName("image_file");

        // 4. DTO 세팅
        BoardDAO boardDAO = new BoardDAO();
        BoardDTO dto = new BoardDTO();
        dto.setPost_id(postId);
        dto.setTitle(title);
        dto.setContent(content);

        // [중요 로직] 
        // 사용자가 수정 시 새 파일을 선택했다면 새 파일명을 넣고, 
        // 선택하지 않았다면 기존의 파일명을 유지해야 합니다.
        if (newImage != null) {
            dto.setImage_file(newImage); // 새 파일로 교체
        } else {
            // 새 파일이 없으면 DB에서 기존 파일명을 가져와서 유지
            BoardDTO oldData = boardDAO.getQnaDetail(postId);
            dto.setImage_file(oldData.getImage_file());
        }

        // 5. DB 업데이트 호출
        int result = boardDAO.updateQna(dto); 

        if(result > 0) {
%>
            <script>
                alert("✏️ 글 수정이 정상적으로 완료되었습니다.");
                location.href = "QnaDetail.jsp?post_id=<%= postId %>";
            </script>
<%
        } else {
%>
            <script>
                alert("❌ 수정에 실패했습니다.");
                history.back();
            </script>
<%
        }
    } catch (Exception e) {
        // 🔥 에러가 발생하면 서버가 멈추지 않고 이쪽으로 빠져나옵니다.
        e.printStackTrace();
%>
        <script>
            alert("❌ 에러가 발생했습니다. (파일 용량 초과 또는 데이터 오류)");
            history.back();
        </script>
<%
    }
%>