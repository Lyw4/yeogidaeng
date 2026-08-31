document.addEventListener('DOMContentLoaded', () => {

    const searchBtn = document.getElementById('searchBtn');
    const keywordInput = document.getElementById('keywordInput');
    const mainPostList = document.getElementById('mainPostList');
    const paginationArea = document.getElementById('paginationArea');
    const resultTitle = document.getElementById('resultTitle');
    const sortLatest = document.getElementById('sortLatest');
    const sortPopular = document.getElementById('sortPopular');
    const headerUtilMenu = document.getElementById('headerUtilMenu');

    // 모든 길찾기의 기준이 되는 절대 경로(Context Path)를 고정
    const ctx = '/mini';
    const DEFAULT_POST_IMAGE = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=500&q=80';

    function renderHeaderUtil() {
        let utilHtml = '';
        if (typeof isUserLoggedIn !== 'undefined' && isUserLoggedIn === true) {
            let isAdmin = (typeof loggedInUserRole !== 'undefined' && loggedInUserRole.trim().toUpperCase() === 'ADMIN');

            // 자바스크립트 변수로 지정된 경로에도 /views 폴더를 추가했습니다!
            let targetPage = isAdmin ? `${ctx}/views/admin/adminMain.jsp` : `${ctx}/views/member/myPage.jsp`;
            let buttonLabel = isAdmin ? '관리자페이지' : '마이페이지';

            utilHtml = `
                <span class="user-greet">🐶 <strong>${loggedInUserId}</strong>님 환영합니다!</span>
                <span class="util-divider">|</span>
                <a href="${targetPage}" class="login-link">${buttonLabel}</a>
                <span class="util-divider">|</span>
                <a href="${ctx}/views/member/logout.jsp" class="signup-link">로그아웃</a>
            `;
        } else {
            utilHtml = `
                <a href="${ctx}/views/member/loginForm.jsp" class="login-link">로그인</a>
                <span class="util-divider">|</span>
                <a href="${ctx}/views/member/insertForm.jsp" class="signup-link">회원가입</a>
            `;
        }
        if (headerUtilMenu) headerUtilMenu.innerHTML = utilHtml;
    }
    renderHeaderUtil();

    let currentBoardType = '';
    let currentKeyword = '';
    let currentSort = 'latest';
    let currentPage = 1;

    function loadMainPostList() {
        if (!mainPostList) return;

        if (resultTitle) {
            resultTitle.innerHTML = currentKeyword !== ''
                ? `'<span style="color:#ff8c00">${currentKeyword}</span>' 검색 결과`
                : (currentBoardType === '' ? '전체 게시글' : `${currentBoardType} 게시판`);
        }

        const url = `${ctx}/views/main/getPostDataJson.jsp?page=${currentPage}&boardType=${currentBoardType}&category=&sort=${currentSort}&searchType=title&searchKeyword=${currentKeyword}`;

        fetch(url)
            .then(response => response.json())
            .then(data => {
                let listHtml = '';

                if (!data || !data.posts || data.posts.length === 0) {
                    listHtml = `<li style="text-align:center; padding:50px 0; color:#888; border:none; width:100%; grid-column: 1 / -1;">등록된 게시글이 없습니다. 첫 글의 주인공이 되어보세요! 🐾</li>`;
                    mainPostList.innerHTML = listHtml;
                    if (paginationArea) paginationArea.innerHTML = '';
                    return;
                }

                data.posts.forEach(item => {

                    const pId = item.postId || item.post_id;
                    const bType = item.boardType || item.board_type;
                    const regD = item.regDate || item.reg_date || '';
                    const vCount = item.viewCount || item.view_count || 0;
                    const lCount = item.likeCount || item.like_count || 0;
                    const ctg = item.category || '일반';
                    const wtr = item.writer || '익명';
                    const tit = item.title || '제목 없음';

                    // forEach 안에 forEach가 또 들어있어서 콘솔창에 로그가 수백 개씩 찍히는 오타 버그를 수정했습니다.
                    console.log("DB에서 넘어온 데이터 확인:", item);

                    let shortDate = String(regD).substring(5, 10);

                    listHtml += `
                        <li style="display: flex; flex-direction: column; align-items: flex-start; padding: 15px 10px; border-bottom: 1px dashed #FFCBA4; cursor:pointer; transition: background 0.2s;" 
                            onmouseover="this.style.backgroundColor='#FFF0EC'" onmouseout="this.style.backgroundColor='transparent'"
                            onclick="location.href='${ctx}/views/board/detail.jsp?postId=${pId}'">
                            
                            <div style="margin-bottom: 8px;">
                                <span class="badge" style="background-color: #FFDBCB; color: #FF725E; padding: 4px 10px; border-radius: 15px; font-size: 13px; font-weight: bold; margin-right: 5px;">${bType}</span>
                                <span style="color: #999; font-size: 13px; font-weight: bold;">[${ctg}]</span>
                            </div>
                            
                            <div style="font-size: 16px; font-weight: bold; color: #333; margin-bottom: 8px;">${tit}</div>
                            
                            <div style="font-size: 13px; color: #888; display: flex; gap: 10px; width: 100%;">
                                <span>🐾 ${wtr}</span>
                                <span>${shortDate}</span>
                                <span style="margin-left: auto; color: #FF725E;">👀 조회 ${vCount} | ❤️ 추천 ${lCount}</span>
                            </div>
                        </li>
                    `;
                });

                mainPostList.innerHTML = listHtml;
                renderPagination(data.totalPages);
            })
            .catch(error => console.error("DB 리스트 연동 에러:", error));
    }

    function renderPagination(totalPages) {
        if (!paginationArea || totalPages === 0) return;
        let html = `<button class="page-link arrow" ${currentPage === 1 ? 'disabled style="opacity:0.4; cursor:default;"' : ''} data-page="${currentPage - 1}">&lt;</button>`;
        for (let i = 1;i <= totalPages;i++) {
            html += `<button class="page-link ${i === currentPage ? 'active' : ''}" data-page="${i}">${i}</button>`;
        }
        html += `<button class="page-link arrow" ${currentPage === totalPages ? 'disabled style="opacity:0.4; cursor:default;"' : ''} data-page="${currentPage + 1}">&gt;</button>`;
        paginationArea.innerHTML = html;

        paginationArea.querySelectorAll('.page-link:not([disabled])').forEach(link => {
            link.addEventListener('click', () => {
                currentPage = parseInt(link.getAttribute('data-page'));
                loadMainPostList();
            });
        });
    }

    if (searchBtn && keywordInput) {
        searchBtn.addEventListener('click', (e) => {
            e.preventDefault();
            currentKeyword = keywordInput.value.trim();
            currentPage = 1;
            loadMainPostList();
        });
        keywordInput.addEventListener('keyup', (e) => { if (e.key === 'Enter') searchBtn.click(); });
    }

    if (sortLatest && sortPopular) {
        sortLatest.addEventListener('click', () => {
            if (sortPopular) sortPopular.classList.remove('active');
            sortLatest.classList.add('active');
            currentSort = 'latest';
            currentPage = 1;
            loadMainPostList();
        });
        sortPopular.addEventListener('click', () => {
            if (sortLatest) sortLatest.classList.remove('active');
            sortPopular.classList.add('active');
            currentSort = 'views';
            currentPage = 1;
            loadMainPostList();
        });
    }

    function initPopularCarousel() {
        const carouselTrack = document.getElementById('carouselTrack');
        const slideLeftBtn = document.getElementById('slideLeftBtn');
        const slideRightBtn = document.getElementById('slideRightBtn');

        if (!carouselTrack) return;

        const url = `${ctx}/views/main/getPostDataJson.jsp?page=1&sort=views`;

        fetch(url)
            .then(response => response.json())
            .then(data => {
                let carouselHtml = '';
                if (!data || !data.posts) return;
                // 메인에 나타나는 이미지 갯수 설정
                const topPosts = data.posts.slice(0, 8);

                topPosts.forEach(item => {
                    let targetImg = DEFAULT_POST_IMAGE;
                    const fName = item.file_name || item.fileName;
                    const pId = item.postId || item.post_id;
                    const bType = item.boardType || item.board_type;
                    const regD = item.regDate || item.reg_date || '';
                    const vCount = item.viewCount || item.view_count || 0;
                    const tit = item.title || '제목 없음';
                    let shortDate = String(regD).substring(5, 10);

                    // 슬라이더 사진 경로를 detail.jsp 와 동일하게 강제 고정
                    if (fName && fName !== "null" && fName !== "") {
                        targetImg = `${ctx}/views/upload/${fName.trim()}`;
                        console.log("이미지 경로 확인:", targetImg); // F12 개발자도구에서 경로가 맞는지 확인 가능
                    }

                    carouselHtml += `
                        <a href="${ctx}/views/board/detail.jsp?postId=${pId}" class="carousel-card" style="text-decoration:none; color:inherit; display:block;">
                             <img src="${targetImg}" alt="${tit}" class="carousel-image" onerror="this.onerror=null; this.src='${DEFAULT_POST_IMAGE}';">
                             <div class="carousel-info">
                                 <div class="carousel-info-title">[${bType}] ${tit}</div>
                                 <div class="carousel-info-stats">
                                    <span>👀 조회수 ${vCount}</span>
                                    <span>${shortDate}</span>
                                </div>
                            </div>
                        </a>
                    `;
                });

                carouselTrack.innerHTML = carouselHtml;
            })
            .catch(err => console.error("슬라이더 연동 에러:", err));

        if (slideRightBtn) {
            slideRightBtn.addEventListener('click', () => {
                // 끝에 도달했는지 확인 (약간의 오차범위 5px를 둠)
                if (carouselTrack.scrollLeft + carouselTrack.offsetWidth >= carouselTrack.scrollWidth - 5) {
                    carouselTrack.scrollTo({ left: 0, behavior: 'smooth' }); // 처음으로 이동
                } else {
                    carouselTrack.scrollBy({ left: 300, behavior: 'smooth' });
                }
            });
        }

        if (slideLeftBtn) {
            slideLeftBtn.addEventListener('click', () => {
                // 처음에 도달했는지 확인
                if (carouselTrack.scrollLeft <= 0) {
                    carouselTrack.scrollTo({ left: carouselTrack.scrollWidth, behavior: 'smooth' }); // 맨 끝으로 이동
                } else {
                    carouselTrack.scrollBy({ left: -300, behavior: 'smooth' });
                }
            });
        }
    }

    initPopularCarousel();

    if (sortLatest) sortLatest.classList.add('active');
    currentSort = 'latest';
    loadMainPostList();
});