document.addEventListener('DOMContentLoaded', () => {
    const list = document.getElementById('mainPostList');
    const pagination = document.getElementById('paginationArea');
    const title = document.getElementById('resultTitle');
    const latest = document.getElementById('sortLatest');
    const popular = document.getElementById('sortPopular');
    const form = document.querySelector('.main-header .search-box');
    const input = form && form.querySelector('[name="searchKeyword"]');
    const ctx = typeof contextPath === 'string' ? contextPath : '/mini';
    const defaultImage = 'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=500&q=80';

    function node(tag, text, className, style) {
        const el = document.createElement(tag);
        if (text !== undefined) el.textContent = String(text);
        if (className) el.className = className;
        if (style) el.style.cssText = style;
        return el;
    }
    function link(text, path, className) {
        const el = node('a', text, className);
        el.href = ctx + path;
        return el;
    }
    function renderHeader() {
        const menu = document.getElementById('headerUtilMenu');
        if (!menu) return;
        menu.replaceChildren();
        if (typeof isUserLoggedIn !== 'undefined' && isUserLoggedIn === true) {
            const admin = typeof loggedInUserRole === 'string' && loggedInUserRole.trim().toUpperCase() === 'ADMIN';
            const greeting = node('span', undefined, 'user-greet');
            greeting.append('🐶 ', node('strong', typeof loggedInUserId === 'string' ? loggedInUserId : ''), '님 환영합니다!');
            menu.append(greeting, node('span', '|', 'util-divider'),
                link(admin ? '관리자페이지' : '마이페이지', admin ? '/views/admin/adminMain.jsp' : '/views/member/myPage.jsp', 'login-link'),
                node('span', '|', 'util-divider'), link('로그아웃', '/views/member/logout.jsp', 'signup-link'));
        } else {
            menu.append(link('로그인', '/views/member/loginForm.jsp', 'login-link'), node('span', '|', 'util-divider'),
                link('회원가입', '/views/member/insertForm.jsp', 'signup-link'));
        }
    }
    function postId(item) {
        const id = String(item.postId ?? item.post_id ?? '');
        return /^[1-9]\d*$/.test(id) ? id : null;
    }
    function imagePath(value) {
        if (typeof value !== 'string') return defaultImage;
        const name = value.trim();
        // 업로드 폴더 안의 파일 이름만 받는다. 경로나 외부 주소는 허용하지 않는다.
        if (!name || name === 'null' || /[\/\\:\x00-\x1f\x7f]/.test(name) || name === '.' || name === '..') return defaultImage;
        return `${ctx}/views/upload/${encodeURIComponent(name)}`;
    }
    function count(value) {
        const n = Number(value);
        return Number.isSafeInteger(n) && n >= 0 ? n : 0;
    }
    function message(container, text, retry) {
        const box = node(container === list ? 'li' : 'div', undefined, '', 'padding:30px 10px;text-align:center;width:100%;display:block;');
        box.setAttribute('role', retry ? 'alert' : 'status');
        box.append(node('p', text));
        if (retry) {
            const button = node('button', '다시 불러오기', 'page-link');
            button.type = 'button';
            button.addEventListener('click', retry);
            box.append(button);
        }
        container.replaceChildren(box);
    }
    async function getPosts(params, signal) {
        const response = await fetch(`${ctx}/views/main/getPostDataJson.jsp?${new URLSearchParams(params)}`, { signal });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const data = await response.json();
        if (!data || !Array.isArray(data.posts) || !Number.isSafeInteger(data.totalPages) || data.totalPages < 0 ||
            data.posts.some(item => !item || typeof item !== 'object')) throw new Error('Invalid post response');
        return data;
    }
    let keyword = '';
    let sort = 'latest';
    let page = 1;
    let requestNumber = 0;
    let controller;

    function renderPost(item) {
        const id = postId(item);
        if (!id) return null;
        const row = node('li', undefined, '', 'display:block;padding:15px 10px;border-bottom:1px dashed #FFCBA4;');
        const entry = link('', `/views/board/detail.jsp?postId=${id}`);
        entry.style.cssText = 'display:block;color:inherit;text-decoration:none;';
        const tags = node('div', undefined, '', 'margin-bottom:8px;');
        tags.append(node('span', item.boardType ?? item.board_type ?? '', 'badge'),
            node('span', ` [${item.category || '일반'}]`, '', 'color:#999;font-size:13px;'));
        const details = node('div', undefined, '', 'font-size:13px;color:#888;display:flex;gap:10px;flex-wrap:wrap;');
        details.append(node('span', `🐾 ${item.writer || '익명'}`),
            node('span', String(item.regDate ?? item.reg_date ?? '').substring(5, 10)),
            node('span', `👀 조회 ${count(item.viewCount ?? item.view_count)} | ❤️ 추천 ${count(item.likeCount ?? item.like_count)}`, '', 'margin-left:auto;color:#FF725E;'));
        entry.append(tags, node('div', item.title || '제목 없음', '', 'font-size:16px;font-weight:bold;color:#333;margin-bottom:8px;'), details);
        row.append(entry);
        return row;
    }
    async function loadList() {
        if (!list) return;
        const number = ++requestNumber;
        if (controller) controller.abort();
        controller = new AbortController();
        if (title) title.textContent = keyword ? `'${keyword}' 검색 결과` : '전체 게시글';
        if (pagination) pagination.replaceChildren();
        list.setAttribute('aria-busy', 'true');
        message(list, '게시글을 불러오는 중입니다.');
        try {
            const data = await getPosts({ page, boardType: '', category: '', sort, searchType: 'title', searchKeyword: keyword }, controller.signal);
            // 취소 직전에 도착한 응답도 새 검색 결과를 덮어쓰지 않게 한다.
            if (number !== requestNumber) return;
            const rows = data.posts.map(renderPost).filter(Boolean);
            if (!rows.length) {
                message(list, keyword ? '검색 결과가 없습니다. 다른 검색어로 찾아보세요.' : '아직 등록된 게시글이 없습니다.');
                return;
            }
            list.replaceChildren(...rows);
            renderPagination(data.totalPages);
        } catch (error) {
            if (number !== requestNumber || error.name === 'AbortError') return;
            message(list, '게시글을 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.', loadList);
        } finally {
            if (number === requestNumber) list.setAttribute('aria-busy', 'false');
        }
    }
    function renderPagination(totalPages) {
        if (!pagination) return;
        pagination.replaceChildren();
        function add(label, targetPage, disabled, active) {
            const button = node('button', label, `page-link${active ? ' active' : ''}`);
            button.type = 'button';
            button.disabled = disabled;
            if (active) button.setAttribute('aria-current', 'page');
            button.addEventListener('click', () => { page = targetPage; loadList(); });
            pagination.append(button);
        }
        add('이전', page - 1, page <= 1, false);
        for (let p = Math.max(1, page - 2); p <= Math.min(totalPages, page + 2); p++) add(String(p), p, false, p === page);
        add('다음', page + 1, page >= totalPages, false);
    }
    if (form && input && list) {
        input.required = false; // 검색어를 지우고 전체 목록으로 돌아갈 수 있게 한다.
        form.addEventListener('submit', event => {
            event.preventDefault();
            keyword = input.value.trim();
            page = 1;
            loadList();
        });
        input.addEventListener('keydown', event => {
            if (event.key === 'Enter' && (event.isComposing || event.keyCode === 229)) event.preventDefault();
        });
    }
    if (latest && popular) {
        function setSort(value) {
            sort = value;
            page = 1;
            latest.classList.toggle('active', sort === 'latest');
            popular.classList.toggle('active', sort === 'views');
            loadList();
        }
        latest.addEventListener('click', () => setSort('latest'));
        popular.addEventListener('click', () => setSort('views'));
    }
    const track = document.getElementById('carouselTrack');
    async function loadPopular() {
        if (!track) return;
        track.setAttribute('aria-busy', 'true');
        message(track, '인기글을 불러오는 중입니다.');
        try {
            const data = await getPosts({ page: 1, sort: 'views' });
            const cards = [];
            for (const item of data.posts.slice(0, 8)) {
                const id = postId(item);
                if (!id) continue;
                const card = link('', `/views/board/detail.jsp?postId=${id}`, 'carousel-card');
                card.style.cssText = 'text-decoration:none;color:inherit;display:block;';
                const image = node('img', undefined, 'carousel-image');
                image.alt = String(item.title || '제목 없음');
                image.addEventListener('error', () => { image.src = defaultImage; }, { once: true });
                image.src = imagePath(item.fileName ?? item.file_name);
                const info = node('div', undefined, 'carousel-info');
                const stats = node('div', undefined, 'carousel-info-stats');
                stats.append(node('span', `👀 조회수 ${count(item.viewCount ?? item.view_count)}`),
                    node('span', String(item.regDate ?? item.reg_date ?? '').substring(5, 10)));
                info.append(node('div', `[${item.boardType ?? item.board_type ?? ''}] ${item.title || '제목 없음'}`, 'carousel-info-title'), stats);
                card.append(image, info);
                cards.push(card);
            }
            if (cards.length) track.replaceChildren(...cards);
            else message(track, '아직 등록된 인기글이 없습니다.');
        } catch (error) {
            message(track, '인기글을 불러오지 못했습니다.', loadPopular);
        } finally {
            track.setAttribute('aria-busy', 'false');
        }
    }
    const left = document.getElementById('slideLeftBtn');
    const right = document.getElementById('slideRightBtn');
    if (track && right) right.addEventListener('click', () => {
        if (track.scrollLeft + track.offsetWidth >= track.scrollWidth - 5) track.scrollTo({ left: 0, behavior: 'smooth' });
        else track.scrollBy({ left: 300, behavior: 'smooth' });
    });
    if (track && left) left.addEventListener('click', () => {
        if (track.scrollLeft <= 0) track.scrollTo({ left: track.scrollWidth, behavior: 'smooth' });
        else track.scrollBy({ left: -300, behavior: 'smooth' });
    });
    renderHeader();
    loadPopular();
    loadList();
});
