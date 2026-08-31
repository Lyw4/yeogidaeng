<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원 정보 수정</title>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');

    .top-logo {
        position: absolute;
        top: 30px;
        left: 40px;
        z-index: 9999;
    }
    .top-logo a {
        font-family: 'Jua', sans-serif;
        font-size: 29px;
        font-weight: normal;
        color: #FF725E;
        text-decoration: none;
    }
    
    body {
        font-family: 'Malgun Gothic', '맑은 고딕', sans-serif;
        background-color: #fbf5f0;
        margin: 0;
        padding: 40px 20px;
        display: flex;
        justify-content: center;
        align-items: flex-start;
        min-height: 100vh;
    }

    form {
        width: 400px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0;
        border-radius: 22px;
        padding: 35px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
    }

    form h2 {
        margin: 0 0 30px 0;
        color: #e65c47;
        font-size: 24px;
        font-weight: bold;
        text-align: center;
        display: block;
        border-bottom: 2px dashed #fcdad4;
        padding-bottom: 12px;
    }

    form label {
        display: block;
        font-size: 14px;
        font-weight: bold;
        color: #7d6b60;
        margin-bottom: 6px;
        margin-top: 14px;
    }
    form label:first-of-type { margin-top: 0; }

    form input[type="text"], 
    form input[type="date"] {
        width: 100%;
        padding: 11px 15px;
        border: 2px solid #f1ece7;
        border-radius: 12px;
        font-size: 14px;
        background-color: #faf8f6;
        color: #4a4a4a;
        box-sizing: border-box;
        outline: none;
        transition: all 0.2s ease;
    }

    form input[type="text"]:focus, 
    form input[type="date"]:focus {
        border-color: #ff9944;
        background-color: #ffffff;
        box-shadow: 0 0 8px rgba(255, 153, 68, 0.15);
    }
    
   form input[type="date"]::-webkit-calendar-picker-indicator {
        background-image: url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="%23e65c47" class="bi bi-calendar-heart" viewBox="0 0 16 16"><path d="M8 7.982C9.664 6.305 13.065 9.145 8 13c-5.065-3.855-1.664-6.695 0-5.018z"/><path d="M3.5 0a.5.5 0 0 1 .5.5V1h8V.5a.5.5 0 0 1 1 0V1h1a2 2 0 0 1 2 2v11a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2V3a2 2 0 0 1 2-2h1V.5a.5.5 0 0 1 .5-.5zM1 4v10a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V4H1z"/></svg>');
        cursor: pointer;
        padding: 5px;
        border-radius: 6px;
        transition: background-color 0.2s ease;
    }

    form input[type="date"]::-webkit-calendar-picker-indicator:hover {
        background-color: #ffe4d0;
    }
    
    .read-only-box {
        width: 100%;
        padding: 11px 15px;
        border: 2px solid #f1ece7;
        border-radius: 12px;
        font-size: 14px;
        background-color: #f5efe9;
        color: #7d7d7d;
        box-sizing: border-box;
        font-weight: bold;
    }

    form input[type="submit"] {
        width: 100%;
        padding: 13px;
        margin-top: 30px;
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

    form input[type="submit"]:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }
</style>
</head>

<body>
<% 
   String sid = (String)session.getAttribute("sid");    
   if( sid == null ){ 
%>
      <script>
         alert("로그인 후 사용가능합니다.");
         window.location="loginForm.jsp";
      </script>
<%      return;   
   }
%>

<jsp:useBean class="web.bean.member.MemberDTO" id="dto" />
<jsp:useBean class="web.bean.member.MemberDAO" id="dao" />
<%
   dto = dao.idInfo(sid);
%>

<form name="userInput" action="updatePro.jsp" onsubmit="return updateCheck(event)" method="post">
    <h2>🐶 회원 정보 수정 🐱</h2>
    
    <label>아이디</label>
    <div class="read-only-box">🐾 <%= dto.getId() %></div>
    <input type="hidden" name="id" value="<%= dto.getId() %>">
    
    <input type="hidden" name="pw" id="realPw" value="<%= dto.getPw() %>">
   <label for="fakePw">비밀번호 변경 (미입력 시 기존 비밀번호 유지)</label>
    <input type="text" id="fakePw" value="" placeholder="변경할 비밀번호 입력 (5~20자 영대소문+숫자+특수)" oninput="handlePasswordInput(this)">

   <input type="hidden" name="pw2" id="realPw2" value="">
   <label for="fakePw2">비밀번호 확인</label>
    <input type="text" id="fakePw2" value="" placeholder="변경할 비밀번호 확인 입력" oninput="handlePasswordConfirmInput(this)">
    
    <label for="uname">이름</label>
    <input type="text" name="name" id="uname" placeholder="이름 입력" value="<%= dto.getName() != null ? dto.getName() : "" %>">
    
    <label for="ubirth">생년월일</label>
    <input type="date" name="birth" id="ubirth" value="<%= dto.getBirth() != null && dto.getBirth().length() >= 10 ? dto.getBirth().substring(0, 10) : "" %>">
    
    <label for="uemail">이메일</label>
    <input type="text" name="email" id="uemail" placeholder="example@email.com" value="<%= dto.getEmail() %>">
    
    <label for="uphone">전화번호</label>
    <input type="text" name="phone" id="uphone" placeholder="010-0000-0000" value="<%= dto.getPhone() %>">
     
    <label>성별</label>
    <div class="read-only-box">
        <%= "m".equalsIgnoreCase(dto.getGender()) ? "남자 🧑" : "여자 👩" %>
    </div>
    
    <input type="submit" value="내 정보 수정">
</form>

<script>
    // 💡 스크립틀릿과의 충돌을 방지하기 위해 상단에서 원본 비밀번호를 변수로 직접 취급합니다.
    const originDbPassword = "<%= dto.getPw() %>";
    let actualPassword = "";        
    let actualPasswordConfirm = ""; 

    function handlePasswordInput(inputField) {
        let currentDisplay = inputField.value; 
        let updatedPassword = "";
        
        for (let i = 0; i < currentDisplay.length; i++) {
            let char = currentDisplay.charAt(i);
            if (char === "●") {
                if (i < actualPassword.length) {
                    updatedPassword += actualPassword.charAt(i);
                }
            } else {
                updatedPassword += char;
            }
        }
        
        if (currentDisplay.length < actualPassword.length && currentDisplay.indexOf("●") === -1) {
            updatedPassword = currentDisplay; 
        } else if (currentDisplay.length < actualPassword.length) {
            updatedPassword = updatedPassword.substring(0, currentDisplay.length);
        }

        actualPassword = updatedPassword;
        
        // 완전히 지우면 원본 DB 암호로 복원, 입력하면 입력한 값 세팅
        if(actualPassword === "") {
            document.getElementById("realPw").value = originDbPassword;
        } else {
            document.getElementById("realPw").value = actualPassword;
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

        setTimeout(() => {
            if (inputField.value === maskedString) {
                inputField.value = "●".repeat(actualPassword.length);
            }
        }, 400); 
    }

    function handlePasswordConfirmInput(inputField) {
        let currentDisplay = inputField.value; 
        let updatedPassword = "";
        
        for (let i = 0; i < currentDisplay.length; i++) {
            let char = currentDisplay.charAt(i);
            if (char === "●") {
                if (i < actualPasswordConfirm.length) {
                    // 💡 교정 완료: 오타였던 .length를 .charAt(i)로 원상 복구하여 버그 제거
                    updatedPassword += actualPasswordConfirm.charAt(i);
                }
            } else {
                updatedPassword += char;
            }
        }
        
        if (currentDisplay.length < actualPasswordConfirm.length && currentDisplay.indexOf("●") === -1) {
            updatedPassword = currentDisplay;
        } else if (currentDisplay.length < actualPasswordConfirm.length) {
            updatedPassword = updatedPassword.substring(0, currentDisplay.length);
        }

        actualPasswordConfirm = updatedPassword;
        document.getElementById("realPw2").value = actualPasswordConfirm; 

        let maskedString = "";
        for (let i = 0; i < actualPasswordConfirm.length; i++) {
            if (i === actualPasswordConfirm.length - 1) {
                maskedString += actualPasswordConfirm.charAt(i); 
            } else {
                maskedString += "●"; 
            }
        }
        inputField.value = maskedString;

        setTimeout(() => {
            if (inputField.value === maskedString) {
                inputField.value = "●".repeat(actualPasswordConfirm.length);
            }
        }, 400); 
    }
   
    function updateCheck(e){   
        let fakePwValue = document.getElementById("fakePw").value; 
        let realPwValue = document.getElementById("realPw").value;
        let realPwValue2 = document.getElementById("realPw2").value;

        if (fakePwValue.length > 0) {
            var pwReg = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*()_+|~`{}?]).{5,20}$/;
            if ( !pwReg.test(realPwValue) ) {
                alert("변경할 비밀번호는 5~20자의 영문 대소문자, 숫자, 특수문자가 모두 포함되어야 합니다.");
                document.getElementById("fakePw").focus();
                e.preventDefault();
                return false;
            }
            if( !realPwValue2 ){
                alert("변경할 비밀번호 확인을 입력해주세요.");
                document.getElementById("fakePw2").focus();
                e.preventDefault();
                return false;
            }
            if( realPwValue != realPwValue2 ){
                alert("변경할 비밀번호가 서로 일치하지 않습니다.");
                document.getElementById("fakePw2").focus();
                e.preventDefault();
                return false;
            }
        }
        
      if( !userInput.name.value ){
         alert("이름을 입력해주세요.");
         userInput.name.focus();
            e.preventDefault();
         return false;
      }
      if( !userInput.birth.value ){
         alert("생년월일을 입력해주세요.");
            userInput.birth.focus();
            e.preventDefault();
         return false;
      }
      if( !userInput.email.value ){
         alert("변경할 이메일을 입력해주세요.");
         userInput.email.focus();
            e.preventDefault();
         return false;
      }
      if( !userInput.phone.value ){
         alert("변경할 전화번호를 입력해주세요.");
         userInput.phone.focus();
            e.preventDefault();
         return false;
      }
      
      return true;   
   }
</script>
</body>
</html>