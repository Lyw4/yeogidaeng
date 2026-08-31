<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>

<%
    // 🔥 범인 1 해결: insertPost.jsp와 완벽하게 동일한 경로로 맞춤!
    String uploadPath = request.getServletContext().getRealPath("/views/upload");
    int maxSize = 10 * 1024 * 1024; // 10MB
    String encoding = "UTF-8";

    // 폴더가 없으면 자동으로 만들어주는 로직
    File uploadDir = new File(uploadPath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs();
    }

    try {
        // 폼에서 보낸 파일과 데이터를 낚아채는 도구
        MultipartRequest multi = new MultipartRequest(
            request, uploadPath, maxSize, encoding, new DefaultFileRenamePolicy()
        );

        int postId = Integer.parseInt(multi.getParameter("postId"));
        String category = multi.getParameter("category");
        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        
        // 새롭게 첨부된 사진 파일의 진짜 이름 가져오기
        String fileName = multi.getFilesystemName("uploadFile");

        // 바구니(DTO)에 수정된 데이터 담기
        BoardDTO dto = new BoardDTO();
        dto.setPost_id(postId);       
        dto.setCategory(category);
        dto.setTitle(title);         
        dto.setContent(content);
        
        // 🔥 범인 2 해결: 사용자가 새 사진을 올렸다면, DB에도 새 파일명을 저장하라고 알려줌!
        if (fileName != null) {
            dto.setFile_name(fileName); 
        }

        // DAO에게 DB 업데이트 시키기
        BoardDAO dao = new BoardDAO();
        int result = dao.updatePost(dto);

        // 업데이트 성공 시 상세 페이지로 이동
        if(result > 0) {
            response.sendRedirect("detail.jsp?postId=" + postId);
        } else {
%>
            <script>
                alert("글 수정에 실패했습니다."); 
                history.back();
            </script>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("파일 처리 중 오류가 발생했습니다.");
            history.back();
        </script>
<%
    }
%>