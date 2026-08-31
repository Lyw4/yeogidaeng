<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.member.MemberDAO" %>
<%@ page import="java.util.UUID" %> 

<%
    request.setCharacterEncoding("UTF-8");
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String email = request.getParameter("email");

    MemberDAO dao = new MemberDAO();
    
    // 1. 먼저 유저가 입력한 정보가 진짜 맞는지 조회
    boolean isMember = dao.checkMemberForPw(id, name, email);
    
    String tempPw = "";			
    boolean isSuccess = false;	
    
    if(isMember) {
        // 2. 정보가 일치하므로 임시 비밀번호 생성 (8자리 자르기)
        tempPw = UUID.randomUUID().toString().substring(0, 8);	
        
        // 3. ★[수정] DB에 생성된 임시 비밀번호를 실제로 갱신 처리
        int updateResult = dao.updatePw(id, tempPw);
        
        // 4. ★[수정] DB 업데이트까지 완벽하게 1(성공)로 완료되었다면 최종 성공 플래그를 true로!
        if(updateResult > 0) {
            isSuccess = true;
        }
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>비밀번호 찾기 결과</title>
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
        min-height: 100vh; /* 화면 정확히 정중앙 배치 */
    }

    /* 2. 주황색 테두리가 들어간 동글동글한 결과 카드 상자 */
    .result-card {
        width: 400px;
        background-color: #ffffff;
        border: 3px solid #ffe4d0; /* 파스텔 주황색 테두리 */
        border-radius: 22px;       /* 아기자기하게 둥근 모서리 */
        padding: 40px 30px;
        box-shadow: 0 8px 24px rgba(255, 136, 34, 0.08);
        box-sizing: border-box;
        text-align: center;        /* 내용물 가운데 정렬 */
    }

    /* 대제목 스타일 */
    .result-card h2 {
        margin: 0 0 25px 0;
        color: #e65c47;            /* 패밀리룩 다홍/주황색 */
        font-size: 24px;
        font-weight: bold;
        border-bottom: 2px dashed #fcdad4;
        padding-bottom: 12px;
    }

    /* 안내 메시지 폰트 스타일 */
    .result-card p {
        font-size: 15px;
        color: #665544;            /* 따뜻한 갈색 톤 */
        line-height: 1.6;
        margin: 15px 0;
    }

    /* 3. 💥 하이라이트: 임시 비밀번호 폰트 가공 박스 */
    .temp-pw-box {
        background-color: #fff6f0; /* 촉촉한 연주황 배경 */
        border: 2px dashed #ff9944; /* 주황색 점선 */
        border-radius: 12px;
        padding: 15px;
        margin: 25px 0;
        font-size: 26px;           /* 비밀번호가 잘 보이도록 큼직하게 */
        font-weight: bold;
        color: #e65c47;
        letter-spacing: 1px;       /* 글자 간격 살짝 띄우기 */
        box-shadow: inset 0 2px 4px rgba(255,136,34,0.05);
    }

    /* 4. 하단 캡슐형 메인 버튼 스타일 (로그인하러 가기 / 다시 시도하기 공통) */
    .result-card .btn-main {
        display: block;
        width: 100%;
        padding: 13px;
        margin-top: 20px;
        background: linear-gradient(135deg, #f38f7d, #e65c47); /* 메인 그라데이션 */
        color: #ffffff;
        border: none;
        font-size: 16px;
        font-weight: bold;
        border-radius: 50px;       /* 완벽한 캡슐 마감 */
        cursor: pointer;
        box-shadow: 0 4px 12px rgba(230, 92, 71, 0.25);
        text-decoration: none;     /* a 태그일 때 밑줄 방지 */
        box-sizing: border-box;
        transition: all 0.2s ease;
    }

    .result-card .btn-main:hover {
        background: linear-gradient(135deg, #e27f6c, #d54c37);
        transform: translateY(-2px);
    }
    
    /* 실패했을 때 버튼은 차분한 갈색 계열로 포인트 조절 */
    .result-card .btn-main.fail {
        background: linear-gradient(135deg, #cda685, #bd936f);
        box-shadow: 0 4px 12px rgba(189, 147, 111, 0.25);
    }
    .result-card .btn-main.fail:hover {
        background: linear-gradient(135deg, #bd936f, #aa7f5c);
    }
</style>
</head>
<body>

<div class="result-card">
    <h2>🐶 비밀번호 찾기 결과 🐱</h2>
    
    <% if(isSuccess) { %>
        <p>임시 비밀번호를 발급했습니다.<br>로그인 후 비밀번호를 변경해 주세요.</p>
        
        <div class="temp-pw-box"><%= tempPw %></div>
        
        <input type="button" class="btn-main" value="로그인하러 가기 🚪" onclick="location.href='loginForm.jsp'">
    <% } else { %>
        <p style="color: #d54c37; font-weight: bold; font-size: 16px;">💬 비밀번호를 찾을 수 없습니다.</p>
        <p>입력하신 아이디, 이름, 이메일 정보가<br>기록된 회원 정보와 일치하지 않습니다.</p>
        
        <a href="javascript:history.back();" class="btn-main fail">다시 시도하기 ↩️</a>
    <% } %>
</div>

</body>
</html>