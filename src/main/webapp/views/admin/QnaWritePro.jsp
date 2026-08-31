<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<jsp:include page="checkStatus.jsp" />
<%@ page import="com.oreilly.servlet.MultipartRequest"%>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@ page import="web.bean.board.BoardDAO"%>
<%@ page import="web.bean.board.BoardDTO"%>

<%
	String uploadPath = application.getRealPath("/upload");
	int size = 10 * 1024 * 1024; // 10MB 제한
	
	// 🔥 [핵심 수정] 폴더가 없으면 자동으로 생성해 주는 마법의 코드 3줄!
	java.io.File uploadDir = new java.io.File(uploadPath);
	if (!uploadDir.exists()) {
		uploadDir.mkdirs(); // 경로상의 모든 폴더를 알아서 만들어 줍니다.
	}
	
	try {
		MultipartRequest multi = new MultipartRequest(request, uploadPath, size, "UTF-8", new DefaultFileRenamePolicy());
		String title = multi.getParameter("title");
		String content = multi.getParameter("content");
		String writer = multi.getParameter("writer");
		String fileName = multi.getFilesystemName("image_file");
	
		// 🔥 [수정] 폼에서 안 보냈을 때를 대비한 안전한 숫자 변환 (NumberFormatException 방지)
		String refStr = multi.getParameter("ref");
		String stepStr = multi.getParameter("re_step");
		String levelStr = multi.getParameter("re_level");
	
		int ref = (refStr != null && !refStr.isEmpty()) ? Integer.parseInt(refStr) : 0;
		int re_step = (stepStr != null && !stepStr.isEmpty()) ? Integer.parseInt(stepStr) : 0;
		int re_level = (levelStr != null && !levelStr.isEmpty()) ? Integer.parseInt(levelStr) : 0;
	
		BoardDTO dto = new BoardDTO();
		dto.setWriter(writer);
		dto.setTitle(title);
		dto.setContent(content);
		dto.setRef(ref);
		dto.setRe_step(re_step);
		dto.setRe_level(re_level);
		dto.setImage_file(fileName);
	
		BoardDAO dao = new BoardDAO();
		if (ref == 0) {
			dao.insertQna(dto); // 새 글
		} else {
			dao.insertReply(dto); // 답글
		}
	%>
	<script>
		alert("✅ 등록이 완료되었습니다.");
		location.href = "QnaList.jsp";
	</script>
	<%
	} catch (Exception e) {
	e.printStackTrace();
	%>
	<script>
		alert("❌ 등록에 실패했습니다. (파일 용량 초과 등)");
		history.back();
	</script>
<% } %>