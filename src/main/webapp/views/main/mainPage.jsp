<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <%-- 사이트이름 --%>
    <title>여기댕 - 우리 동네 댕댕이 커뮤니티</title>
    
    <link href="https://fonts.googleapis.com/css2?family=Jua&display=swap" rel="stylesheet">
    <link href="https://hangeul.pstatic.net/hangeul_static/css/nanum-square-round.css" rel="stylesheet">
    
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <jsp:include page="../components/header.jsp" />
    <%-- 메인페이지 상단 내용 --%>
    <main class="content-wrapper">
        <section class="welcome-banner">
            <h2>우리 애완동물들을 위한 모든 것, 여기댕에서 찾아보세요!</h2>
            <p>원하는 지역의 병원, 호텔, 미용실, 놀이터를 검색해보세요.</p>
        </section>
         
        <div id="mainContentArea">

            <%-- 이달의 인기 핫플 슬라이더 영역 --%>
            <section class="hot-carousel-section">
                <h3 class="carousel-title">🔥 이달의 HOT 여기댕 핫플</h3>
                
                <div class="carousel-wrapper">
                    <%-- 왼쪽 화살표 --%>
                    <button class="carousel-arrow left-arrow" id="slideLeftBtn">&lt;</button>
                    
                    <%-- 실제 카드가 담기고 가로로 스크롤 될 트랙 --%>
                    <div class="carousel-track-container" id="carouselTrack">
                        <%-- 자바스크립트가 인기 게시글 카드를 여기에 동적으로 꽂아줍니다! --%>
                    </div>
                    
                    <%-- 오른쪽 화살표 --%>
                    <button class="carousel-arrow right-arrow" id="slideRightBtn">&gt;</button>
                </div>
            </section>
        
            <section class="board-section">
            
                <%-- 리스트 제어 필터 바 (정렬 버튼과 타이틀을 감싸는 올바른 포장지) --%>
                <div class="list-filter-bar">
                    <%-- 자바스크립트가 검색어 입력 여부에 따라 글자를 바꿔치기할 타겟 --%>
                    <h3 id="resultTitle">전체 게시글</h3>
                    
                    <%-- 정렬 스위칭 버튼 그룹 --%>                    
                    <div class="sort-buttons">
                        <%-- id를 통해 JS 이벤트 리스너를 바인딩하며, active 클래스로 현재 선택 상태를 표시 --%>
                        <button class="sort-btn active" id="sortLatest">최신순</button>
                        <button class="sort-btn" id="sortPopular">인기순</button>
                    </div>
                </div> <%-- list-filter-bar 끝 --%>
            
                <%-- 동적 데이터 주입 타겟 (정렬 및 검색된 게시글들이 li 형태로 꽂히는 공간) --%>      
                <ul class="board-list" id="mainPostList">
                    <%-- 자바스크립트(main.js)가 조건에 맞는 데이터를 여기에 동적으로 뿌려줌 --%>
                </ul>
            
                <%-- 페이징 버튼 네비게이션 공간 --%>
                <div class="pagination" id="paginationArea">
                    <%-- 자바스크립트(main.js)가 페이지 번호를 동적으로 생성 --%>
                </div>
            
            </section> <%-- board-section 끝 --%>      
        </div> <%-- mainContentArea 끝 --%>
    </main>

    <%-- 푸터 호출 --%>
    <jsp:include page="../components/footer.jsp" />

    <%-- 자바스크립트 메인기능 호출 --%>
	<script src="../js/main.js?v=4"></script>
</body>
</html>