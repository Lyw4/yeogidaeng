<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.board.BoardDAO" %>

<%
    // 로그인 체크 방어 코드
    String sid = (String)session.getAttribute("sid");
    if( sid == null ){
%>
        <script>
            alert("로그인이 필요합니다.");
            window.location="loginForm.jsp";
        </script>
<%      
        return;
    }

    int postId = Integer.parseInt(request.getParameter("postId"));
    BoardDAO dao = new BoardDAO();
    BoardDTO post = dao.getPostDetail(postId);
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 수정</title>
    
    <%-- 웹 에디터(Summernote Lite) 및 jQuery CDN 추가 --%>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/dist/summernote-lite.min.js"></script>
    <%-- Summernote 한국어 패치 --%>
    <script src="https://cdn.jsdelivr.net/npm/summernote@0.8.18/lang/summernote-ko-KR.min.js"></script>

    <style>
        /* 기존 몽글몽글 스타일 유지 + 디시인사이드 UI 감성 */
        body { margin: 0; padding: 40px 0; background-color: #fffaf5; font-family: 'Malgun Gothic', sans-serif; }
        .write-container { width: 65%; min-width: 800px; margin: 0 auto; background: #fff; padding: 40px 50px; border-radius: 30px; box-shadow: 0 10px 25px rgba(255, 136, 34, 0.08); border: 3px solid #ffe4d0; }
        
        .header-title { font-size: 26px; color: #e65c47; font-weight: bold; border-bottom: 2px solid #ffe4d0; padding-bottom: 15px; margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end; }
        
        .form-group { margin-bottom: 25px; }
        .form-group label { display: block; font-weight: bold; color: #7d6b60; margin-bottom: 10px; font-size: 15px; }
        .form-group input[type="text"], .form-group select { width: 100%; padding: 12px 15px; border: 2px solid #f1ece7; border-radius: 12px; font-size: 15px; outline: none; transition: border-color 0.2s; box-sizing: border-box; }
        .form-group input[type="text"]:focus, .form-group select:focus { border-color: #ff9944; }

        /* 가로 배치용 레이아웃 */
        .flex-row { display: flex; gap: 15px; }
        .flex-row > div { flex: 1; }
        .flex-row > div.category-box { flex: 0.3; } /* 카테고리는 조금 작게 */

        /* 파일 첨부 미리보기 UI */
        .file-upload-wrapper { border: 2px dashed #ffccbc; padding: 20px; border-radius: 12px; text-align: center; background-color: #fff0ec; transition: all 0.3s; }
        .file-upload-wrapper:hover { background-color: #ffe4d0; }
        .file-notice { font-size: 12px; color: #e65c47; margin-top: 10px; font-weight: bold; }
        #imagePreview { max-width: 200px; max-height: 200px; display: none; margin: 15px auto 0 auto; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); }

        /* 버튼 및 기타 UI */
        .btn-group { display: flex; justify-content: center; gap: 15px; margin-top: 40px; }
        .btn-group button { padding: 12px 35px; border-radius: 50px; font-size: 16px; font-weight: bold; cursor: pointer; border: none; transition: all 0.2s; }
        .submit-btn { background: linear-gradient(135deg, #f38f7d, #e65c47); color: white; box-shadow: 0 4px 10px rgba(230, 92, 71, 0.25); }
        .submit-btn:hover { transform: translateY(-2px); box-shadow: 0 6px 15px rgba(230, 92, 71, 0.35); }
        .cancel-btn { background-color: #f1ece7; color: #7d6b60; }
        .cancel-btn:hover { background-color: #e3dcd5; }

        /* 에디터 글자 수 카운터 */
        .char-counter { text-align: right; font-size: 12px; color: #999; margin-top: 5px; }
    </style>
</head>
<body>

    <div class="write-container">
        <div class="header-title">
            <span>게시글 수정 🐾</span>
        </div>

        <form action="updateAction.jsp" method="post" enctype="multipart/form-data" id="updateForm">
            <input type="hidden" name="postId" value="<%= post.getPost_id() %>">

            <div class="flex-row">
                <div class="form-group category-box">
                    <label for="category">🏷️ 말머리</label>
                    <select name="category" id="category">
                        <option value="일반" <%= "일반".equals(post.getCategory()) ? "selected" : "" %>>일반</option>
                        <option value="질문" <%= "질문".equals(post.getCategory()) ? "selected" : "" %>>질문</option>
                        <option value="정보" <%= "정보".equals(post.getCategory()) ? "selected" : "" %>>정보</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="title">📝 제목</label>
                    <input type="text" name="title" id="title" value="<%= post.getTitle().replace("\"", "&quot;") %>" required>
                </div>
            </div>

            <div class="form-group">
                <label for="writer">👤 작성자</label>
                <input type="text" name="writer" id="writer" value="<%= post.getWriter() %>" readonly style="background-color: #f9f9f9; color: #888;">
            </div>

            <div class="form-group">
                <label for="content">본문</label>
                <%-- 에디터가 씌워질 영역 --%>
                <textarea name="content" id="content" required><%= post.getContent() %></textarea>
                <div class="char-counter"><span id="charCount">0</span>자 작성됨</div>
            </div>

            <div class="form-group">
                <label>🖼️ 대표 썸네일 이미지 수정 (선택)</label>
                <div class="file-upload-wrapper">
                    <input type="file" name="uploadFile" id="uploadFile" accept="image/*" onchange="previewImage(event)">
                    <div class="file-notice">새로운 파일을 첨부하면 기존 파일이 덮어씌워집니다. (최대 10MB)</div>
                    
                    <%-- 실시간 이미지 미리보기 --%>
                    <img id="imagePreview" alt="미리보기 이미지">
                </div>
            </div>
            
            <div class="btn-group">
                <button type="button" class="cancel-btn" onclick="history.back()">취소하기</button>
                <button type="submit" class="submit-btn" onclick="return validateForm()">수정 완료</button>
            </div>
        </form>
    </div>

    <script>
        // ----------------------------------------------------
        // 1. Summernote 웹 에디터 초기화
        // ----------------------------------------------------
        $(document).ready(function() {
            $('#content').summernote({
                placeholder: '게시글 내용을 작성해주세요. (이미지 삽입, 표 작성 가능)',
                tabsize: 2,
                height: 400, // 에디터 높이
                lang: 'ko-KR', // 한국어 패치
                toolbar: [
                    ['style', ['style']],
                    ['font', ['bold', 'underline', 'clear', 'color']],
                    ['para', ['ul', 'ol', 'paragraph']],
                    ['table', ['table']],
                    ['insert', ['link', 'video']], // DB 보호를 위해 사진(picture)업로드는 기본 폼 사용
                    ['view', ['fullscreen', 'codeview', 'help']]
                ],
                callbacks: {
                    // 글자 수 실시간 카운팅
                    onChange: function(contents, $editable) {
                        // HTML 태그를 제외한 순수 텍스트의 길이만 측정
                        let textLength = $('<div>').html(contents).text().length;
                        $('#charCount').text(textLength);
                    }
                }
            });
            // 초기 글자 수 세팅
            let initialLength = $('<div>').html($('#content').summernote('code')).text().length;
            $('#charCount').text(initialLength);
        });

        // ----------------------------------------------------
        // 2. 실시간 이미지 미리보기 로직
        // ----------------------------------------------------
        function previewImage(event) {
            var reader = new FileReader();
            var imgPreview = document.getElementById('imagePreview');
            
            reader.onload = function() {
                imgPreview.src = reader.result;
                imgPreview.style.display = 'block'; 
            };
            
            if(event.target.files[0]) {
                reader.readAsDataURL(event.target.files[0]);
            } else {
                imgPreview.style.display = 'none';
                imgPreview.src = '';
            }
        }

        // ----------------------------------------------------
        // 3. 최종 전송 전 빈칸 검사
        // ----------------------------------------------------
        function validateForm() {
            if ($('#content').summernote('isEmpty')) {
                alert('본문 내용을 입력해주세요.');
                $('#content').summernote('focus');
                return false;
            }
            return true;
        }
    </script>
</body>
</html>