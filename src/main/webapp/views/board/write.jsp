<%-- 페이지 설정: 자바 언어를 사용하고, HTML 형식으로 출력하며, 인코딩은 UTF-8로 지정합니다. --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<% 
    // 1. 세션에서 로그인한 아이디 가져오기
    String sid = (String)session.getAttribute("sid");

    // 2. 로그인 안 되어 있으면 로그인 폼으로 튕겨내기 
    if( sid == null ){
%>
        <script>
            alert("게시글을 작성하려면 로그인이 필요합니다.");
            window.location="../member/loginForm.jsp";
        </script>
<%      
        return; 
    }

    // 3. 현재 접속자가 관리자인지 확인 (세션의 isAdmin 값 또는 아이디가 'admin'인지 체크)
    boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin")) || "admin".equals(sid);

    // 4. (보안) 강제로 URL 파라미터를 조작해 공지사항에 접근하려는 시도 차단
    String paramBoardType = request.getParameter("boardType");
    if ("NOTICE".equals(paramBoardType) && !isAdmin) {
%>
        <script>
            alert("공지사항은 관리자만 작성할 수 있습니다.");
            history.back();
        </script>
<%
        return;
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시글 작성</title>
    <style>
        /* 몽글몽글한 배경 및 폰트 세팅 */
        body {
            margin: 0;
            padding: 40px 0;
            background-color: #fffaf5; 
            font-family: 'Malgun Gothic', sans-serif;
        }

        /* 🎀 글쓰기 폼을 담는 하얀색 둥근 박스 */
        .write-container {
            width: 60%; 
            min-width: 700px; 
            margin: 0 auto;
            background: #fff;
            padding: 40px 50px;
            border-radius: 30px;
            box-shadow: 0 10px 25px rgba(255, 204, 204, 0.25);
            border: 2px solid #ffe5df;
            box-sizing: border-box;
        }

        /* 상단 귀여운 타이틀 */
        .main-title {
            color: #ff8b77;
            font-size: 28px;
            font-weight: bold;
            text-align: center;
            margin-bottom: 35px;
        }

        /* 각 입력항목 그룹화 */
        .form-group {
            margin-bottom: 25px;
        }

        /* 입력창 위에 달리는 귀여운 라벨 텍스트 */
        .form-group label {
            display: block;
            font-weight: bold;
            color: #ff735d;
            margin-bottom: 10px;
            font-size: 15px;
        }

        /* 🔍 일반 입력창 디자인 (둥글고 말랑하게) */
        .form-group input[type="text"],
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 14px 18px;
            border: 2px solid #ffdcdc;
            border-radius: 15px;
            background-color: #fff9f9;
            font-size: 15px;
            color: #555;
            box-sizing: border-box;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }

        /* 마우스 클릭 시 포커스 효과 */
        .form-group input[type="text"]:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            border-color: #ff9999;
            box-shadow: 0 0 8px rgba(255, 153, 153, 0.3);
        }

        /* 내용 입력창(textarea) 크기 설정 */
        .form-group textarea {
            resize: vertical;
            min-height: 350px;
            line-height: 1.6;
        }

        /* 🖼️ 파일 첨부 입력창 특별 디자인 (귀여운 점선) */
        .form-group input[type="file"] {
            width: 100%;
            padding: 12px;
            border: 2px dashed #ffcccc;
            border-radius: 15px;
            background-color: #fffaf5;
            font-size: 14px;
            color: #555;
            box-sizing: border-box;
            cursor: pointer;
        }

        .file-notice {
            font-size: 12px; 
            color: #ff9999; 
            margin-top: 8px;
            font-weight: bold;
        }

        /* 🎈 하단 버튼 그룹 */
        .btn-group {
            text-align: center;
            margin-top: 40px;
            display: flex;
            justify-content: center;
            gap: 15px;
        }

        /* 버튼 공통 스타일 */
        .btn-group button {
            padding: 12px 40px;
            border-radius: 50px;
            border: none;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: all 0.2s;
        }

        /* ✨ 등록하기 버튼 */
        .submit-btn {
            background-color: #ff9999;
            color: white;
            box-shadow: 0 5px 10px rgba(255, 153, 153, 0.4);
        }

        .submit-btn:hover {
            background-color: #ff8080;
            transform: translateY(-2px);
        }

        /* ☁️ 취소 버튼 */
        .cancel-btn {
            background-color: #fff0ec;
            color: #ff735d;
            border: 2px solid #ffcccc;
        }

        .cancel-btn:hover {
            background-color: #ffe5df;
            transform: translateY(-2px);
        }
    </style>
</head>
<body>

    <div class="write-container">
        <div class="main-title">📝 게시글 작성</div>
        
        <form action="insertPost.jsp" method="POST" enctype="multipart/form-data">
            
            <%-- 게시판 유형 선택 구역 --%>
            <div class="form-group">
                <label for="boardType">📌 게시판 유형</label>
                <select name="boardType" id="boardType" required onchange="changeCategory()">
                    <option value="HOSPITAL" <%= "HOSPITAL".equals(paramBoardType) ? "selected" : "" %>>🏥 병원</option>
                    <option value="BEAUTY" <%= "BEAUTY".equals(paramBoardType) ? "selected" : "" %>>✂️ 미용</option>
                    <option value="HOTEL" <%= "HOTEL".equals(paramBoardType) ? "selected" : "" %>>🏨 호텔</option>
                    <option value="PLAY" <%= "PLAY".equals(paramBoardType) ? "selected" : "" %>>🧸 놀거리</option>
                    <option value="SUGGESTION" <%= "SUGGESTION".equals(paramBoardType) ? "selected" : "" %>>💡 건의사항</option>
                    
                    <%-- 🔥 [핵심 추가] 관리자일 경우에만 '공지사항' 옵션이 추가로 보이게 됩니다! --%>
                    <% if (isAdmin) { %>
                        <option value="NOTICE" <%= "NOTICE".equals(paramBoardType) ? "selected" : "" %>>📢 공지사항 (관리자 전용)</option>
                    <% } %>
                </select>
            </div>

            <%-- 카테고리 선택 구역 --%>
            <div class="form-group" id="categoryGroup">
                <label for="category">🧸 카테고리</label>
                <select name="category" id="category">
                    <option value="일반">일반</option>
                    <option value="질문">질문</option>
                </select>
            </div>

            <%-- 제목 입력 구역 --%>
            <div class="form-group">
                <label for="title">💡 제목</label>
                <input type="text" name="title" id="title" placeholder="어떤 제목으로 글을 올릴까요?" required>
            </div>

            <%-- 작성자 입력 구역 --%>
            <div class="form-group">
             <label for="writer">👤 작성자 (자동입력)</label>
             <input type="text" name="writer" id="writer" value="<%= sid %>" readonly 
                    style="background-color: #f5efe9; color: #7d7d7d; border: 2px solid #f1ece7;">
         </div>

            <%-- 내용 입력 구역 --%>
            <div class="form-group">
                <label for="content">📝 내용</label>
                <textarea name="content" id="content" placeholder="여기에 자유롭게 이야기를 나눠주세요 🐾" required></textarea>
            </div>

            <%-- 파일 첨부 구역 --%>
            <div class="form-group">
                <label for="uploadFile">🖼️ 파일 첨부</label>
                <input type="file" name="uploadFile" id="uploadFile">
                <div class="file-notice">* 최대 10MB 크기의 이미지나 일반 파일을 첨부할 수 있어요.</div>
            </div>

            <%-- 전송 및 취소 버튼 --%>
            <div class="btn-group">
                <button type="submit" class="submit-btn">작성 완료</button>
                <button type="button" class="cancel-btn" onclick="history.back()">취소</button>
            </div>
        </form>
    </div>

    <%-- 자바스크립트: 게시판 종류에 따라 카테고리를 변경하거나 숨깁니다. --%>
    <script>
    function changeCategory() {
        var boardType = document.getElementById("boardType").value;
        var categorySelect = document.getElementById("category");
        var categoryGroup = document.getElementById("categoryGroup"); 
        
        categorySelect.innerHTML = "";
        
        if (boardType === "SUGGESTION") {
            // 건의사항일 때
            categorySelect.add(new Option("신고/문의", "신고/문의"));
            categoryGroup.style.display = "none";
        } else if (boardType === "NOTICE") {
            // 🔥 공지사항일 때: '공지' 카테고리만 보이도록 추가
            categorySelect.add(new Option("공지", "공지"));
            categoryGroup.style.display = "none";
        } else {
            // 그 외 게시판일 때
            categorySelect.add(new Option("일반", "일반"));
            categorySelect.add(new Option("질문", "질문"));
            categoryGroup.style.display = "block"; 
        }
    }

    // 페이지 로드 시 초기 상태 싱크 맞추기
    window.onload = function() {
        changeCategory();
    };
    </script>

</body>
</html>