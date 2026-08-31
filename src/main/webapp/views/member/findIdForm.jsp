<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>아이디 찾기</title>
<style>
    /* 1. 다른 페이지들과 동일한 부모 배경 및 폰트 세팅 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; /* 따뜻한 살구/베이지빛 배경 */
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh; /* 화면 정중앙 배치 */
    }

    /* 2. 주황색 테두리가 들어간 동글동글한 폼 카드 상자 */
    .find-card {
        width: 380px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 40px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
    }

    /* 대제목 스타일 */
    .find-card h2 {
        margin: 0 0 30px 0;
        color: #e65c47;            /* 패밀리룩 다홍/주황색 */
        font-size: 24px;
        font-weight: bold;
        text-align: center;
        border-bottom: 2px dashed #fcdad4;
        padding-bottom: 12px;
    }

    /* 입력창 라벨 (이름, 이메일 글씨) */
    .find-card label {
        display: block;
        font-size: 14px;
        font-weight: bold;
        color: #7d6b60;            /* 부드러운 브라운 톤 */
        margin-bottom: 6px;
        margin-top: 14px;
        padding-left: 4px;
    }
    .find-card label:first-of-type { margin-top: 0; } /* 첫번째 라벨 상단 여백 제거 */

    /* 3. 입력 필드 디자인 통일 (input text) */
    .find-card input[type="text"] {
        width: 100%;
        padding: 12px 15px;
        border: 2px solid #f1ece7;
        border-radius: 12px;       /* 인풋창도 동글동글하게 */
        font-size: 14px;
        background-color: #faf8f6;
        color: #4a4a4a;
        box-sizing: border-box;
        outline: none;
        transition: all 0.2s ease;
    }

    /* 입력창 클릭(Focus) 시 노랗게 빛나는 효과 */
    .find-card input[type="text"]:focus {
        border-color: #ff9944;
        background-color: #ffffff;
        box-shadow: 0 0 8px rgba(255, 153, 68, 0.15);
    }

    /* 4. 아이디 찾기 버튼 (그라데이션 대형 캡슐) */
    .find-card input[type="submit"] {
        width: 100%;
        padding: 13px;
        margin-top: 30px;
        background: linear-gradient(135deg, #f38f7d, #e65c47);
        color: #ffffff;
        border: none;
        font-size: 16px;
        font-weight: bold;
        border-radius: 50px;       /* 갓벽한 캡슐 마감 */
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(230, 92, 71, 0.25);
        transition: all 0.2s ease;
    }

    .find-card input[type="submit"]:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }
</style>
</head>
<body>

<div class="find-card">
    <h2>🐶 아이디 찾기 🐱</h2>
    <form name="findIdForm" action="findIdPro.jsp" method="post" onsubmit="return checkFields()">
        <label for="uname">이름</label>
        <input type="text" name="name" id="uname" placeholder="이름을 입력하세요.">
        
        <label for="uemail">이메일</label>
        <input type="text" name="email" id="uemail" placeholder="이메일을 입력하세요.">
        
        <input type="submit" value="아이디 찾기 ">
    </form>
</div>

<script>
function checkFields() {
    let form = document.findIdForm;
    // .trim()을 사용하셨으므로 비어있거나 공백만 있는 경우를 야무지게 잘 잡아냅니다!
    if(form.name.value.trim() === "") {
        alert("이름을 입력해주세요.");
        form.name.focus();
        return false;
    }
    if(form.email.value.trim() === "") {
        alert("이메일을 입력해주세요.");
        form.email.focus();
        return false;
    }
    return true;
}
</script> 
</body>
</html>