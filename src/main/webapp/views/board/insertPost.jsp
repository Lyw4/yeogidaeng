<%-- 1. 페이지 설정 및 인코딩 지정 --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>

<%-- 💡 cos.jar 라이브러리 (파일 업로드 해결사) --%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="java.io.File" %>

<%
    // [1. 한글 인코딩 및 파일 저장 경로 설정]
    request.setCharacterEncoding("UTF-8");

    // 💡 경로 마법: '절대 경로'는 컴퓨터의 C드라이브부터 프로젝트 위치까지 쭈욱 이어지는 고유 주소입니다.
    // 서버가 바껴도 내 프로젝트 안의 'upload' 폴더를 정확히 찾아가게 해줍니다.
    String savePath = request.getServletContext().getRealPath("/views/upload");
    
    // 폴더가 실제 존재하는지 확인하고, 없으면 서버가 알아서 '자동으로 생성'합니다.
    File uploadDir = new File(savePath);
    if (!uploadDir.exists()) {
        uploadDir.mkdirs(); // 하위 폴더까지 싹 다 생성!
    }

    // [2. 업로드 규칙 설정]
    int maxSize = 10 * 1024 * 1024; // 10MB (숫자가 너무 크면 서버가 터지니까 제한을 둡니다)
    String encoding = "UTF-8";      // 파일명에 한글이 있어도 깨지지 않게 방어

    // [3. 🔥 MultipartRequest 객체 생성 (파일 업로드의 심장)]
    // 이 생성자를 호출하는 순간 서버는 사용자가 보낸 파일을 낚아채서 지정된 폴더에 쏙 저장합니다!
    // 'DefaultFileRenamePolicy'는 만약 '사진.jpg'가 이미 있으면 '사진1.jpg'로 이름을 바꿔주는 똑똑한 보호장치입니다.
    MultipartRequest multi = new MultipartRequest(
        request, 
        savePath, 
        maxSize, 
        encoding, 
        new DefaultFileRenamePolicy()
    );

    // [4. 파라미터 수집]
    // ⚠️ 왜 request.getParameter가 아니라 multi.getParameter일까요?
    // 파일 업로드(multipart/form-data) 방식은 일반적인 데이터 전송 방식이 아니라 
    // 파일과 텍스트가 섞인 '복합 데이터'라서 기존 request가 처리하지 못합니다. 
    // 이제 'multi'라는 이름의 새로운 도구한테 물어봐야 합니다.
    String boardType = multi.getParameter("boardType");
    String category  = multi.getParameter("category");
    String title     = multi.getParameter("title");
    String writer    = multi.getParameter("writer");
    String content   = multi.getParameter("content");
    
    // 💡 중요: 파일의 진짜 이름은 multi.getFilesystemName으로 꺼냅니다. 
    // (서버 폴더에 저장된 파일명을 정확히 가져와야 나중에 불러올 수 있으니까요!)
    String fileName  = multi.getFilesystemName("uploadFile");

    // [5. DTO에 데이터 담기]
    BoardDTO dto = new BoardDTO();
    dto.setBoard_type(boardType);
    dto.setCategory(category);
    dto.setTitle(title);
    dto.setWriter(writer);
    dto.setContent(content);
    dto.setFile_name(fileName); // 💡 서버에 저장된 파일 이름을 DTO 바구니에 저장 완료!

    // [6. DB 등록]
    BoardDAO dao = new BoardDAO();
    int result = dao.insertPost(dto); // 💡 이 메서드 호출 시 이제 BoardDAO에서 fileName도 DB에 넣게 수정해주면 됩니다!

    // [7. 결과 분기]
    if (result > 0) {
        response.sendRedirect("list.jsp"); // 성공하면 목록으로
    } else {
%>
        <script>
            alert("글 등록에 실패했습니다.");
            history.back(); // 실패하면 이전 글쓰기 화면으로
        </script>
<%
    }
%>