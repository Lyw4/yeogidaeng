<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 세션 체크: 로그인 안 되어 있으면 로그인 폼으로 튕겨내기
    String sid = (String)session.getAttribute("sid");
    if(sid == null) {
%>
        <script>
            alert("로그인이 필요한 서비스입니다.");
            location.href = "loginForm.jsp";
        </script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>내 정보 조회 전 본인 확인</title>
<style>
    /* 프로젝트 통합 패밀리룩 세팅 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; /* 따뜻한 살구/베이지빛 배경 */
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        min-height: 100vh;
    }

    .confirm-card {
        width: 380px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 40px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
        text-align: center;
    }

    .confirm-card h2 {
        margin: 0 0 20px 0;
        color: #e65c47;            /* 패밀리룩 다홍/주황색 */
        font-size: 22px;
        font-weight: bold;
        border-bottom: 2px dashed #fcdad4;
        padding-bottom: 12px;
    }

    .confirm-card p {
        font-size: 14px;
        color: #7d6b60;            /* 부드러운 브라운 톤 */
        line-height: 1.5;
        margin-bottom: 25px;
    }

    /* 비밀번호 입력 필드 디자인 (input text 형태로 통일) */
    .confirm-card input[type="text"] {
        width: 100%;
        padding: 12px 15px;
        margin-bottom: 20px;
        border: 2px solid #f1ece7;
        border-radius: 12px;
        font-size: 14px;
        background-color: #faf8f6;
        color: #4a4a4a;
        box-sizing: border-box;
        outline: none;
        transition: all 0.2s ease;
    }

    .confirm-card input[type="text"]:focus {
        border-color: #ff9944;
        background-color: #ffffff;
        box-shadow: 0 0 8px rgba(255, 153, 68, 0.15);
    }

    /* 제출 버튼 (그라데이션 대형 캡슐) */
    .confirm-card input[type="submit"] {
        width: 100%;
        padding: 13px;
        background: linear-gradient(135deg, #f38f7d, #e65c47);
        color: #ffffff;
        border: none;
        font-size: 16px;
        font-weight: bold;
        border-radius: 50px;
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(230, 92, 71, 0.25);
        transition: all 0.2s ease;
    }

    .confirm-card input[type="submit"]:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }
</style>
</head>
<body>

<div class="confirm-card">
    <h2>🔒 비밀번호 확인</h2>
    <p>안전한 정보 보호를 위해<br>비밀번호를 입력해 주세요.</p>
    
    <form name="checkPwForm" action="checkPwPro.jsp" method="post" onsubmit="return validateFields()">
        <input type="hidden" name="pw" id="realPw" value="">

        <input type="text" id="fakePw" placeholder="비밀번호를 입력하세요." oninput="handlePasswordInput(this)">
        
        <input type="submit" value="인증 및 조회하기 ">
    </form>
</div>

<script>
// 진짜 비밀번호를 실시간으로 조립해 둘 자바스크립트 전역 변수
let actualPassword = ""; 

// 비밀번호 유효성 검사 
function validateFields() {
    // 유효성 검사 대상을 진짜 비밀번호가 들어있는 hidden 값으로 변경
    let realPwValue = document.getElementById("realPw").value;
    
    if(realPwValue.trim() === "") {
        alert("비밀번호를 입력해주세요.");
        document.getElementById("fakePw").focus();
        return false;
    }
    return true;
}

// 비밀번호 실시간 글자 마스킹
function handlePasswordInput(inputField) {
    let currentDisplay = inputField.value; 
    
    // 1. 글자가 지워졌을 때 처리 (백스페이스)
    if (currentDisplay.length < actualPassword.length) {
        actualPassword = actualPassword.substring(0, currentDisplay.length);
    } 
    // 2. 새 글자가 추가되었을 때 처리
    else if (currentDisplay.length > actualPassword.length) {
        let lastChar = currentDisplay.charAt(currentDisplay.length - 1);
        actualPassword += lastChar;
    }

    // 3. 화면 표시용 문자열 조립 (마지막 글자만 노출)
    let maskedString = "";
    for (let i = 0; i < actualPassword.length; i++) {
        if (i === actualPassword.length - 1) {
            maskedString += actualPassword.charAt(i); 
        } else {
            maskedString += "●"; 
        }
    }
    
    // 4. 각각의 인풋 엘리먼트에 값 할당
    inputField.value = maskedString;
    document.getElementById("realPw").value = actualPassword;

    // 5. 0.4초 후 마지막 글자까지 완전히 감추기
    setTimeout(() => {
        if (inputField.value === maskedString) {
            inputField.value = "●".repeat(actualPassword.length);
        }
    }, 400); 
}
</script>

</body>
</html>