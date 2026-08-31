<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    // 🔥 [수정] 실제 로그인 세션 복구 및 testUser 삭제
    String id = (String) session.getAttribute("id");
    if(id == null) id = (String) session.getAttribute("sid");

    if (id == null) {
%>
        <script>
            alert("⚠️ 로그인이 필요한 서비스입니다.");
            location.href = "../member/loginForm.jsp"; 
        </script>
<%
        return;
    }

    // 답글 작성을 위해 넘어오는 파라미터 받기 (없으면 새 글이므로 0)
    String ref = request.getParameter("ref");
    String re_step = request.getParameter("re_step");
    String re_level = request.getParameter("re_level");
    
    if(ref == null) ref = "0";
    if(re_step == null) re_step = "0";
    if(re_level == null) re_level = "0";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>건의사항 작성</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; background-color: #f8f9fa; margin: 30px; }
    .container { max-width: 700px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; font-weight: bold; margin-bottom: 5px; color: #34495e; }
    .form-control { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    textarea.form-control { height: 200px; resize: none; }
    .btn-box { text-align: center; margin-top: 20px; }
    .btn { padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; font-size: 14px; text-decoration: none; }
    .btn-submit { background-color: #3498db; color: white; margin-right: 5px; }
    .btn-submit:hover { background-color: #2980b9; }
    .btn-cancel { background-color: #95a5a6; color: white; }
    .btn-cancel:hover { background-color: #7f8c8d; }
</style>
</head>
<body>

<div class="container">
    <h2>📝 건의사항 <%= ("0".equals(ref) ? "작성하기" : "답변 달기") %></h2>
    
    <form action="QnaWritePro.jsp" method="post" enctype="multipart/form-data">
        
        <%-- 🔥 [수정] 서버가 에러를 뿜지 않도록 답글 데이터를 숨겨서 전달! --%>
        <input type="hidden" name="ref" value="<%= ref %>">
        <input type="hidden" name="re_step" value="<%= re_step %>">
        <input type="hidden" name="re_level" value="<%= re_level %>">

        <div class="form-group">
            <label for="writer">작성자</label>
            <input type="text" id="writer" name="writer" class="form-control" value="<%= id %>" readonly>
        </div>
        
        <div class="form-group">
            <label for="title">제목</label>
            <input type="text" id="title" name="title" class="form-control" placeholder="제목을 입력하세요." required>
        </div>
        
        <div class="form-group">
            <label for="content">내용</label>
            <textarea id="content" name="content" class="form-control" placeholder="건의하실 내용을 상세히 적어주세요." required></textarea>
        </div>
        
        <div class="form-group">
            <label for="image_file">📸 이미지 첨부 (선택)</label>
            <input type="file" id="image_file" name="image_file" class="form-control" accept="image/*">
        </div>
        
        <div class="btn-box">
            <button type="submit" class="btn btn-submit">등록하기</button>
            <a href="QnaList.jsp" class="btn btn-cancel">취소</a>
        </div>
    </form>
</div>

</body>
</html>