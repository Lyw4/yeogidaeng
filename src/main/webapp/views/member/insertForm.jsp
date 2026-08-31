<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');

/* =========================================================
       🐾 상단 좌측 둥둥 떠있는 홈 로고 
    ========================================================= */
    .top-logo {
        position: absolute;
        top: 30px;
        left: 40px;
        z-index: 9999;
    }
    .top-logo a {
        font-family: 'Jua', sans-serif; /* 메인 로고와 동일한 글꼴 */
        font-size: 29px;                /* 메인 로고와 동일한 크기 */
        font-weight: normal;            /* 메인 로고와 동일한 굵기 */
        color: #FF725E;                 /* 메인 로고와 동일한 색상 */
        text-decoration: none;
    }
    
    

    /* 1. 마이페이지와 통일한 부모 배경 및 폰트 세팅 */
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0; /* 따뜻한 살구/베이지빛 배경 */
        margin: 0;
        padding: 40px 20px;
        display: flex;
        justify-content: center;
        align-items: flex-start;
        min-height: 100vh;
    }

    /* 2. 주황색 포인트가 들어간 동글동글 뽀짝한 가입 폼 카드 */
    form {
        width: 400px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 35px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
    }

    /* 대제목 스타일 */
    form h2 {
        margin: 0 0 30px 0;
        color: #e65c47;            /* 마이페이지 시그니처 다홍/주황색 */
        font-size: 24px;
        font-weight: bold;
        text-align: center;
        display: block;
        border-bottom: 2px dashed #fcdad4;
        padding-bottom: 12px;
    }

    /* 입력창 라벨 (아이디, 비밀번호 등 글씨) */
    form label {
        display: block;
        font-size: 14px;
        font-weight: bold;
        color: #7d6b60;            /* 따뜻한 브라운 톤 글씨 */
        margin-bottom: 6px;
        margin-top: 14px;
    }
    
    /* 첫번째 라벨 상단 여백 제거 */
    form label:first-of-type { margin-top: 0; } 
	
	
    /* 3. 입력 필드 및 선택 상자 디자인 통일 (input, select) */
    form input[type="text"],
    form input[type="password"],
    form input[type="date"],
    form select {
        width: 100%;
        padding: 11px 15px;
        border: 2px solid #f1ece7;
        border-radius: 12px;       /* 창도 동글동글하게 */
        font-size: 14px;
        background-color: #faf8f6;
        color: #4a4a4a;
        box-sizing: border-box;
        outline: none;
        transition: all 0.2s ease;
    }
	
	
    /* 입력창이나 셀렉트 박스에 마우스 커서를 올리거나 클릭했을 때 노랗게 빛나는 효과 */
    form input[type="text"]:focus,
    form input[type="password"]:focus,
    form input[type="date"]:focus,
    form select:focus {
        border-color: #ff9944;
        background-color: #ffffff;
        box-shadow: 0 0 8px rgba(255, 153, 68, 0.15);
    }
    

    /* 4. 아이디 중복확인 레이아웃 전용 조절 */
    .id-container {
        display: flex;
        gap: 8px;
    }
    
    /* 아이디 입력칸은 옆에 버튼이 있으니까 width 자동 조절 */
    .id-container input[type="text"] {
        flex: 1;
    }

    /* 이메일 입력 영역 가로 정렬 컨테이너 스타일 */
    .email-container {
        display: flex;
        align-items: center;
        gap: 8px;
        color: #7d6b60; /* @ 기호 색상을 라벨 톤과 매칭 */
        font-weight: bold;
    }
    
    /* 이메일 아이디 입력칸과 도메인 선택창이 균등하게 공간을 나누어 가짐 */
    .email-container input[type="text"],
    .email-container select {
        flex: 1;
    }
	
	/* 전화번호 컨테이너 스타일 */
	.phone-container {
    width: 100%;
	}
	
	.phone-container input[type="text"] {
    width: 100%; /* 가로폭을 다른 입력창들과 동일하게 100%로 지정 */
	}
	
    /* 중복확인 미니 캡슐 버튼 */
    .btn-inline {
        padding: 0 15px;
        background-color: #cda685; /* 마이페이지 로그아웃 버튼과 같은 톤 */
        color: white;
        border: none;
        border-radius: 12px;
        font-size: 13px;
        font-weight: bold;
        cursor: pointer;
        transition: background-color 0.2s;
    }
    .btn-inline:hover {
        background-color: #bd936f;
    }

    /* 중복확인 결과 텍스트가 들어갈 자리 */
    #idResult {
        font-size: 12px;
        margin-top: 4px;
        color: #ff7711;
        padding-left: 4px;
    }

    /* 5. 성별 라디오 버튼 영역 래핑 */
    .gender-group {
        display: flex;
        align-items: center;
        gap: 15px;
        padding: 5px 0;
        font-size: 14px;
        color: #4a4a4a;
        font-weight: bold;
    }
    .gender-group input[type="radio"] {
        accent-color: #e65c47; /* 라디오 버튼 서클 색상 주황색으로 변경 */
        cursor: pointer;
    }

    /* 6. 메인 하단 회원가입 제출 버튼 (그라데이션 대형 캡슐) */
    form input[type="submit"] {
        width: 100%;
        padding: 13px;
        margin-top: 30px;
        background: linear-gradient(135deg, #f38f7d, #e65c47); /* 마이페이지와 동일 그라데이션 */
        color: #ffffff;
        border: none;
        font-size: 16px;
        font-weight: bold;
        border-radius: 50px;       /* 갓벽한 가로형 캡슐 마감 */
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(230, 92, 71, 0.25);
        transition: all 0.2s ease;
    }

    form input[type="submit"]:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }
</style>
</head>

<body>
  	<div style="position: absolute; width: 100%; top: 0; left: 0;">
        <div class="top-logo">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp">🐾여기댕🐾</a>
        </div>
    </div>
    
<form action="insertPro.jsp" method="post" name="userInput" onsubmit="return memCheck()">
    <h2>🐶 회원가입 🐱</h2>
    
    <label for="uid">아이디</label>
    <div class="id-container">
        <input type="text" name="id" id="uid" 
       placeholder="영문 소문자+숫자 조합 (5~20자)" 
       oninput="this.value = this.value.toLowerCase(); idChecked = false; document.getElementById('idResult').innerHTML='';" />
        <input type="button" class="btn-inline" value="중복확인" onclick="idCheck()">
    </div>
    <div id="idResult"></div>
    
    <input type="hidden" name="pw" id="realPw" value="">
	<label for="fakePw">비밀번호</label>
	<input type="text" id="fakePw" placeholder="영문 대소문자+숫자+특수문자 조합 (5~20자)" oninput="handlePasswordInput(this)">
    
    <input type="hidden" name="pw2" id="realPw2" value="">
	<label for="fakePw2">비밀번호 확인</label>
	<input type="text" id="fakePw2" placeholder="비밀번호 확인" oninput="handlePasswordConfirmInput(this)">
    
    <label for="uname">이름</label>
    <input type="text" name="name" id="uname" placeholder="이름 입력">
    
    <label for="ubirth">생년월일</label>
    <input type="date" name="birth" id="ubirth">
    
    <label for="uemail">이메일</label>
    <div class="email-container">
        <input type="text" name="email" id="uemail" placeholder="example@gmail.com">
    </div>
    
    <label for="uphone">전화번호</label>
    <div class="phone-container">
    	<input type="text" name="phone" id="uphone" placeholder="010-0000-0000" maxlength="13" >
    </div>
    
    <label for="ugender">성별</label>
    <div class="gender-group">
        <input type="radio" name="gender" id="genderM" value="m"><label for="genderM" style="display:inline; margin:0; cursor:pointer;">남자</label>
        <input type="radio" name="gender" id="genderW" value="w"><label for="genderW" style="display:inline; margin:0; cursor:pointer;">여자</label>
    </div>
    
    
    <input type="submit" value="가입하기">
</form>

<script>
	 
/*	======================== 
	회원가입 유효성 검사 
	======================== */
	
	var idChecked = false;
	function memCheck(){		
		// 아이디 입력 여부 확인
		if ( !userInput.id.value ){
			alert("아이디를 입력해주세요.");
			return false;
		}
		// 아이디: 영문 소문자 + 숫자 조합, 5~20자
	    var idReg = /^(?=.*[a-z])(?=.*[0-9])[a-z0-9]{5,20}$/;
	    if ( !idReg.test(userInput.id.value) ) {
	        alert("아이디는 5~20자의 영문 소문자와 숫자의 조합이어야 합니다.");
	        userInput.id.focus();
	        return false;
	    }
		// 아이디 중복 여부 확인
		if ( !idChecked ){
			alert("아이디 중복확인을 해주세요.");
			return false;
		}
		// 비밀번호 여부 확인
	    let realPwValue = document.getElementById("realPw").value; 
	    if( !realPwValue ){
	        alert("비밀번호를 입력해주세요.");
	        document.getElementById("fakePw").focus();
	        return false;
	    }
	    
	 	// 비밀번호 정규식 검사
	    var pwReg = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+|~`{}?]).{5,20}$/;
	    if ( !pwReg.test(realPwValue) ) {
	        alert("비밀번호는 5~20자의 영문 대소문자, 숫자, 특수문자가 모두 포함되어야 합니다.");
	        document.getElementById("fakePw").focus();
	        return false;
	    }
		
	    // 비밀번호 확인 여부 확인
	    let realPwValue2 = document.getElementById("realPw2").value;
	    if( !realPwValue2 ){
	        alert("비밀번호 확인을 입력해주세요.");
	        document.getElementById("fakePw2").focus();
	        return false;
	    }
		// 비밀번호 일치 여부 확인
		if( realPwValue != realPwValue2 ){
			alert("비밀번호가 일치하지 않습니다.");
            document.getElementById("fakePw2").focus();
			return false;
		}
		// 이름 입력 여부 확인
		if( !userInput.name.value ){
			alert("이름을 입력해주세요.");
            userInput.name.focus();
			return false;
		}
		// 생년월일 입력 여부 확인
		if( !userInput.birth.value ){
			alert("생년월일을 입력해주세요.");
            userInput.birth.focus();
			return false;
		}
		// 이메일 입력 여부 확인
		if( !userInput.email.value ){
			alert("이메일을 입력해주세요.");
            userInput.email.focus();
			return false;
		}
		
	    // 1. 값 입력 여부 확인
	    if ( !userInput.phone.value ) {
	        alert("전화번호를 입력해주세요.");
	        document.getElementById("uphone").focus();
	        return false;
	    }

	    // 2. 010-0000-0000 형식을 검증하는 정규표현식
	    // - ^01[016789] : 010, 011, 016, 017, 018, 019 등으로 시작
	    // - -[0-9]{3,4} : 하이픈(-) 뒤에 3자리 또는 4자리 숫자
	    // - -[0-9]{4}$  : 하이픈(-) 뒤에 정확히 4자리 숫자로 끝남
	    var phoneReg = /^01[016789]-[0-9]{3,4}-[0-9]{4}$/;

	    // 3. 정규식 패턴과 사용자가 입력한 값이 일치하지 않는 경우 (! 패턴.test)
	    if ( !phoneReg.test(userInput.phone.value) ) {
	        alert("올바른 전화번호 형식이 아닙니다.\n예시와 같이 하이픈(-)을 포함하여 입력해주세요.\n(예: 010-0000-0000)");
	        document.getElementById("uphone").focus();
	        return false;
	    }
	    
		// 성별 체크 여부 확인
		if( !userInput.gender.value ){
			alert("성별을 체크해주세요.");
			return false;
		}
	
		return true;	
	}
	
/*	======================== 
	아이디 중복 확인 유효성 검사 
	======================== */
	
	function idCheck() {	
	    let id = document.getElementById("uid").value;
	    let idResultDiv = document.getElementById("idResult");
	    
	    if(!id) {
	        alert("아이디를 먼저 입력한 후 중복확인을 해주세요.");
	        return;
	    }
	    
	 	// 1. 아이디 유효성 검사를 위한 정규표현식(Regex) 정의
	    var idReg = /^(?=.*[a-z])(?=.*[0-9])[a-z0-9]{5,20}$/;
	    
	 	// 2. 입력된 아이디가 정규표현식 규칙에 맞지 않는지 검사
	    if ( !idReg.test(id) ) {
	        alert("아이디는 5~20자의 영문 소문자와 숫자의 조합이어야 중복확인이 가능합니다.");
	        document.getElementById("uid").focus();
	        return;
	    }
	    
		 // 3. Fetch API를 이용해 서버(checkIdPro.jsp)로 비동기 중복 확인 요청 전송
	    fetch("checkIdPro.jsp?id=" + id)	
	        .then(response => response.text()) 
	        .then(data => {
	            if (data.trim() === "USABLE") {
	                idResultDiv.innerHTML = "사용 가능한 아이디 입니다";
	                idResultDiv.style.color = "#0066ff"; 
	                idChecked = true; 
	            } else {
	                idResultDiv.innerHTML = "사용 불가능한 아이디 입니다.";
	                idResultDiv.style.color = "#ff0000"; 
	                idChecked = false;
	                document.getElementById("uid").focus();
	            }
	        })
	        .catch(error => {
	            console.error("에러 발생:", error);
	            alert("중복 확인 중 오류가 발생했습니다.");
	        });
	}
	
	
/*	======================== 
	비밀번호 실시간 글자 마스킹 
	======================== */
	
	let actualPassword = "";        
	let actualPasswordConfirm = ""; 

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

	function handlePasswordConfirmInput(inputField) {
	    let currentDisplay = inputField.value; 
	    
	    if (currentDisplay.length < actualPasswordConfirm.length) {
	        actualPasswordConfirm = actualPasswordConfirm.substring(0, currentDisplay.length);
	    } else if (currentDisplay.length > actualPasswordConfirm.length) {
	        let lastChar = currentDisplay.charAt(currentDisplay.length - 1);
	        actualPasswordConfirm += lastChar;
	    }

	    let maskedString = "";
	    for (let i = 0; i < actualPasswordConfirm.length; i++) {
	        if (i === actualPasswordConfirm.length - 1) {
	            maskedString += actualPasswordConfirm.charAt(i); 
	        } else {
	            maskedString += "●"; 
	        }
	    }
	    
	    inputField.value = maskedString;
	    document.getElementById("realPw2").value = actualPasswordConfirm; 

	    setTimeout(() => {
	        if (inputField.value === maskedString) {
	            inputField.value = "●".repeat(actualPasswordConfirm.length);
	        }
	    }, 400); 
	}
</script>
</body>
</html>