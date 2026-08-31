<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<% 
	// 과거 쿠키 읽기 : 저장된 쿠키 있었는지 읽어와서 입력창에 넣어두는 역할 
	String cookieId = "";
	String cookiePw = "";
	String cookieAuto = "";

	// 브라우저에서 넘어온 쿠키 배열로 꺼내기
	Cookie[] cookies = request.getCookies();
	
	// 쿠키 존재 -> 처리
	if( cookies != null ){
		// 모든 쿠키를 하나씩 확인
		for( Cookie c : cookies ){
			// 쿠키 이름을 확인하고 각 변수에 값 저장
			if( c.getName().equals("cid") ){ cookieId = c.getValue(); }
			if( c.getName().equals("cpw") ){ cookiePw = c.getValue(); }
			if( c.getName().equals("cauto") ){ cookieAuto = c.getValue(); }
		}
	}
%>
<head>
<meta charset="UTF-8">
<title>로그인</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');

/* =========================================================
       🐾 상단 좌측 둥둥 떠있는 홈 로고 -> 중앙 배치로 변경!
    ========================================================= */
    .top-logo {
        width: 380px;            /* 폼(로그인 박스)의 너비와 동일하게 맞춤 */
        text-align: center;      /* 중앙 정렬 */
        margin-bottom: 25px;     /* 로그인 창과의 간격 */
    }
    
    .top-logo a {
        font-family: 'Jua', sans-serif; 
        font-size: 46px;         /* 🔥 크기를 시원하게 키움 (기존 29px -> 46px) */
        font-weight: normal;            
        color: #FF725E;                 
        text-decoration: none;
        text-shadow: 2px 2px 5px rgba(230, 92, 71, 0.15); /* 약간의 그림자로 입체감 추가 */
        transition: transform 0.2s ease, color 0.2s ease;
        display: inline-block;
    }
    
    .top-logo a:hover {
        color: #e65c47;
        transform: scale(1.05);  /* 마우스 올렸을 때 살짝 커지는 뽀짝한 효과 */
    }

    /* 1. 마이페이지/회원가입과 동일한 부모 배경 및 폰트 세팅 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; 
        margin: 0;
        padding: 0;
        display: flex;
        flex-direction: column;    /* 🔥 세로 정렬 추가 (이게 있어야 로고가 폼 위로 올라갑니다!) */
        justify-content: center;
        align-items: center;
        min-height: 100vh; 
    }

    /* 1. 마이페이지/회원가입과 동일한 부모 배경 및 폰트 세팅 */
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

    /* 2. 주황색 포인트가 들어간 동글동글 뽀짝한 로그인 카드 */
    form {
        width: 380px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 40px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
        text-align: center;
    }

    /* 대제목 스타일 */
    form h2 {
        margin: 0 0 30px 0;
        color: #e65c47;            /* 패밀리룩 다홍/주황색 */
        font-size: 24px;
        font-weight: bold;
        border-bottom: 2px dashed #fcdad4;
        padding-bottom: 12px;
    }

    /* 3. 입력 필드 디자인 통일 (input text, password) */
    form input[type="text"],
    form input[type="password"] {
        width: 100%;
        padding: 12px 15px;
        margin-bottom: 15px;
        border: 2px solid #f1ece7;
        border-radius: 12px;       /* 창도 동글동글하게 */
        font-size: 14px;
        background-color: #faf8f6;
        color: #4a4a4a;
        box-sizing: border-box;
        outline: none;
        transition: all 0.2s ease;
    }

    /* 입력창 클릭 시 노랗게 빛나는 효과 */
    form input[type="text"]:focus,
    form input[type="password"]:focus {
        border-color: #ff9944;
        background-color: #ffffff;
        box-shadow: 0 0 8px rgba(255, 153, 68, 0.15);
    }

    /* 4. 자동 로그인 체크박스 영역 스타일링 */
    .auto-login-group {
        display: flex;
        align-items: center;
        justify-content: flex-start;
        gap: 6px;
        margin-top: 5px;
        margin-bottom: 20px;
        padding-left: 4px;
    }
    
    .auto-login-group label {
        font-size: 13px;
        font-weight: bold;
        color: #7d6b60;            /* 부드러운 브라운 톤 */
        cursor: pointer;
    }
    
    .auto-login-group input[type="checkbox"] {
        accent-color: #e65c47;     /* 체크박스 색상을 주황색으로 고정 */
        cursor: pointer;
        width: 16px;
        height: 16px;
    }

    /* 5. 로그인 버튼 (그라데이션 대형 캡슐) */
    form input[type="submit"] {
        width: 100%;
        padding: 13px;
        background: linear-gradient(135deg, #f38f7d, #e65c47);
        color: #ffffff;
        border: none;
        font-size: 16px;
        font-weight: bold;
        border-radius: 50px;       /* 완벽한 캡슐 마감 */
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(230, 92, 71, 0.25);
        transition: all 0.2s ease;
    }

    form input[type="submit"]:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }

    /* 6. 하단 링크 영역 (아이디/비번찾기, 회원가입) */
    .login-links {
        margin-top: 25px;
        font-size: 13px;
        color: #cdbfae;
    }
    
    .login-links a {
        color: #7d6b60;
        text-decoration: none;
        font-weight: bold;
        transition: color 0.2s;
    }
    
    .login-links a:hover {
        color: #e65c47; /* 마우스 올리면 주황색으로 뿅 */
    }
    
    .login-links .divider {
        margin: 0 8px;
        color: #dcd1c4;
    }
</style>
</head>
<body>
    <div class="top-logo">
        <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp">🐾 여기댕 🐾</a>
    </div>

<form action="loginPro.jsp" method="post" onsubmit="return loginCheck()">
    <h2>🐶 로그인 🐱</h2>
    
    <input type="text" name="id" id="uid" placeholder="아이디" value="<%= cookieId %>">
    
    <input type="hidden" name="pw" id="realPw" value="<%= cookiePw %>">
    
    <input type="text" id="fakePw" placeholder="비밀번호" oninput="handlePasswordInput(this)">
    
    <div class="auto-login-group">
        <input type="checkbox" name="auto" id="auto" value="1" <%= cookieAuto.equals("1") ? "checked" : "" %>>
        <label for="auto">자동 로그인</label> 
    </div>
    
    <input type="submit" value="로그인하기">
    
    <div class="login-links">
        <a href="findIdForm.jsp">아이디 찾기</a>
        <span class="divider">|</span>
        <a href="findPwForm.jsp">비밀번호 재설정</a>
        <span class="divider">|</span>
        <a href="insertForm.jsp">회원가입</a>
    </div>
</form>

<script>
/*
	=====================
		자동 로그인
 	=====================
*/ 
 	// JSP 가 보낸 쿠키 비밀번호 값을 자바스크립트 변수 초기값으로 심어줍니다.
    let actualPassword = "<%= cookiePw %>"; 

    // 페이지 로드가 완료되었을 때 쿠키 값이 있다면 미리 가짜 창을 ●●●로 채워두는 설정
    window.onload = function() {
        if(actualPassword.length > 0) {
            document.getElementById("fakePw").value = "●".repeat(actualPassword.length);
        }
    }

    
    // 비밀번호 단순 빈 값 유효성 검사 함수 추가
    function loginCheck() {
        let uid = document.getElementById("uid").value.trim();
        let realPw = document.getElementById("realPw").value;

        if(!uid) {
            alert("아이디를 입력해주세요.");
            document.getElementById("uid").focus();
            return false;
        }
        if(!realPw) {
            alert("비밀번호를 입력해주세요.");
            document.getElementById("fakePw").focus();
            return false;
        }
        return true;
    }

    // 실시간 딜레이 마스킹 로직
    function handlePasswordInput(inputField) {
        let currentDisplay = inputField.value; 
        
        if (currentDisplay.length < actualPassword.length) {
            actualPassword = actualPassword.substring(0, currentDisplay.length);
        } else if (currentDisplay.length > actualPassword.length) {
            let lastChar = currentDisplay.charAt(currentDisplay.length - 1);
            actualPassword += lastChar;
        }

        let maskedString = "";
        for (let i = 0; i < actualPassword.length; i++) {
            if (i === actualPassword.length - 1) {
                maskedString += actualPassword.charAt(i); 
            } else {
                maskedString += "●"; 
            }
        }
        
        inputField.value = maskedString;
        document.getElementById("realPw").value = actualPassword;

        setTimeout(() => {
            if (inputField.value === maskedString) {
                inputField.value = "●".repeat(actualPassword.length);
            }
        }, 400); 
    }
</script>
</body>
</html>