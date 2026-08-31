<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %> 
<%@ page import="web.bean.board.BoardDTO" %> 
<%@ page import="java.util.List" %> 

<%
    request.setCharacterEncoding("UTF-8");

    String boardType = request.getParameter("boardType");
    String category  = request.getParameter("category");
    String sort      = request.getParameter("sort");
    String searchType = request.getParameter("searchType");
    String searchKeyword = request.getParameter("searchKeyword");
    String status = request.getParameter("status");
    
    // 관리자 여부 확인 및 글쓰기 버튼 제어
    String sid = (String)session.getAttribute("sid");
    boolean isAdmin = Boolean.TRUE.equals(session.getAttribute("isAdmin")) || "admin".equals(sid);
    
    boolean showWriteBtn = true;
    
    if ("NOTICE".equals(boardType) && !isAdmin) {
        showWriteBtn = false;
    }
    
    // 페이징 처리
    String paramPage = request.getParameter("page");
    int currentPage = 1;
    if (paramPage != null && !paramPage.isEmpty()) {
        try { currentPage = Integer.parseInt(paramPage); } catch (NumberFormatException e) { currentPage = 1; }
    }

    String boardName = "전체게시판";
    if ("HOSPITAL".equals(boardType)) boardName = "병원 게시판";
    else if ("BEAUTY".equals(boardType)) boardName = "미용 게시판";
    else if ("HOTEL".equals(boardType)) boardName = "호텔 게시판";
    else if ("PLAY".equals(boardType)) boardName = "놀거리 게시판";
    else if ("SUGGESTION".equals(boardType)) boardName = "건의사항"; 
    else if ("NOTICE".equals(boardType)) boardName = "공지사항";
    
    if (boardType == null) boardType = "";
    if (category == null) category = "";
    if (sort == null) sort = "latest";
    if (searchType == null) searchType = "";
    if (searchKeyword == null) searchKeyword = "";
    if (status == null) status = ""; 

    BoardDAO dao = new BoardDAO();
    int totalPostCount = dao.getTotalPostCount(boardType, category, searchType, searchKeyword, status);
    int limit = 10;
    int totalPages = (int) Math.ceil((double) totalPostCount / limit);
    if (totalPages == 0) totalPages = 1;
    
    int pageBlock = 5;
    int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
    int endPage = startPage + pageBlock - 1;
    if (endPage > totalPages) endPage = totalPages;
    
    int startRow = (currentPage - 1) * limit + 1;
    List<BoardDTO> postList = dao.getPostList(startRow, boardType, category, sort, searchType, searchKeyword, status);

    // 🔥 [핵심 수정 부분] 공지사항을 불러오는 전용 메서드 사용!
    // BoardDAO.java에 이미 만들어져 있는 "getBoardListByType" 메서드를 사용합니다. 
    // 이 메서드는 검색 조건(숨김 조건)에 영향받지 않고 순수하게 공지사항만 긁어옵니다.
    List<BoardDTO> noticePinnedList = null;
    if ("HOSPITAL".equals(boardType) || "BEAUTY".equals(boardType) || "HOTEL".equals(boardType) || "PLAY".equals(boardType) || "".equals(boardType)) {
        noticePinnedList = dao.getBoardListByType("NOTICE");
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판</title>
<style>
    @import url('https://fonts.googleapis.com/css2?family=Jua&display=swap');

    body { 
        margin: 0; 
        padding: 0;
        background-color: #fbf5f0; 
        font-family: 'Malgun Gothic', sans-serif; 
        display: flex;
        flex-direction: column;
        min-height: 100vh;
    }

    .board-container { 
        width: 85%; 
        min-width: 1200px;
        margin: 40px auto auto auto;
        background: #ffffff; 
        padding: 40px 50px; 
        border-radius: 30px; 
        box-shadow: 0 10px 25px rgba(255, 136, 34, 0.08); 
        border: 3px solid #ffe4d0;
        box-sizing: border-box; 
    }


    .home-logo { text-align: center; margin-bottom: 25px; }
    .home-logo a { font-family: 'Jua', sans-serif; font-size: 46px; color: #FF725E; text-decoration: none; text-shadow: 2px 2px 5px rgba(230, 92, 71, 0.15); transition: transform 0.2s ease, color 0.2s ease; display: inline-block; }
    .home-logo a:hover { color: #e65c47; transform: scale(1.05); }

    .search-top-box { width: 540px; margin: 0 auto 30px auto; background: #fffaf5; padding: 16px 20px; border-radius: 50px; border: 2px solid #ffe4d0; }
    .search-top-box form { display: flex; justify-content: center; align-items: center; gap: 10px; margin: 0; }
    .search-top-box select, .search-top-box input[type="text"] { padding: 10px 16px; border-radius: 30px; border: 2px solid #ffdcdc; background-color: #ffffff; outline: none; }
    .search-top-box select:focus, .search-top-box input[type="text"]:focus { border-color: #ff9944; }
    .search-top-box button { padding: 10px 24px; border-radius: 30px; border: none; background: linear-gradient(135deg, #f38f7d, #e65c47); color: #fff; font-weight: bold; cursor: pointer; box-shadow: 0 4px 10px rgba(230, 92, 71, 0.2); transition: transform 0.2s; }
    .search-top-box button:hover { transform: translateY(-2px); }

    .nav-buttons { display: flex; justify-content: center; gap: 12px; margin: 20px auto 30px auto; }
    .nav-buttons button { padding: 10px 22px; border-radius: 50px; border: 2px solid #ffe4d0; background-color: #ffffff; color: #e65c47; font-weight: bold; cursor: pointer; transition: all 0.2s; }
    .nav-buttons button:hover { background-color: #ffe4d0; transform: translateY(-2px); }

    .filter-wrapper { display: flex; justify-content: space-between; align-items: center; margin: 25px 0 15px 0; font-weight: bold; color: #e65c47; }
    .filter-btn { padding: 6px 16px; border-radius: 50px; border: 1px solid #ffccbc; background-color: #fff0ec; color: #e65c47; font-size: 13px; cursor: pointer; transition: background 0.2s; }
    .filter-btn:hover { background-color: #ffccbc; }
    
    .top-write-btn { background: #ff9999; color: white; border: none; font-weight: bold; padding: 6px 18px; border-radius: 50px; cursor: pointer; transition: all 0.2s; }
    .top-write-btn:hover { background: #ff735d; transform: translateY(-2px); }

    table { width: 100%; border-collapse: collapse; text-align: center; background-color: #ffffff; border-top: 3px solid #ff9944; border-bottom: 2px solid #ffe4d0; font-size: 14.5px; }
    th { background-color: #fffaf5; color: #e65c47; padding: 15px 10px; border-bottom: 1px solid #ffe4d0; }
    td { padding: 15px 8px; border-bottom: 1px solid #f1ece7; color: #4a4a4a; }
    td a { color: #4a4a4a; text-decoration: none; transition: color 0.2s; }
    td a:hover { color: #e65c47; font-weight: bold; }
    
    .admin-badge { background-color: #e65c47; color: white; padding: 2px 6px; border-radius: 4px; font-size: 11px; font-weight: bold; margin-right: 4px; }

    .status-badge { padding: 3px 8px; border-radius: 12px; font-size: 12px; font-weight: bold; margin-right: 6px; display: inline-block; }
    .status-wait { background-color: #fff0ec; color: #ff735d; border: 1px solid #ffccbc; }
    .status-done { background-color: #e6f7ff; color: #0088cc; border: 1px solid #b3e6ff; }

    .pagination-box { text-align: center; margin-top: 35px; }
    .pagination-box a, .pagination-box span { display: inline-block; padding: 8px 14px; margin: 0 3px; border-radius: 10px; color: #7d6b60; font-weight: bold; text-decoration: none; transition: all 0.2s; }
    .pagination-box a:hover { background-color: #ffe4d0; color: #e65c47; }
    
    .write-box { text-align: right; margin-top: 20px; }
    .write-box button { padding: 12px 30px; border-radius: 50px; border: none; background: linear-gradient(135deg, #f38f7d, #e65c47); color: white; font-weight: bold; font-size: 15px; cursor: pointer; box-shadow: 0 4px 12px rgba(230, 92, 71, 0.25); transition: transform 0.2s; }
    .write-box button:hover { transform: translateY(-2px); }
</style>
</head>
<body>

    <jsp:include page="header.jsp">
        <jsp:param name="pageTitle" value="<%= boardName %>" />
    </jsp:include>

    <div class="board-container">
        <div class="home-logo">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp">🐾 여기댕 🐾</a>
        </div>

        <div class="search-top-box">
            <form action="list.jsp" method="get">
                <input type="hidden" name="boardType" value="<%= boardType %>">
                <input type="hidden" name="status" value="<%= status %>">
                <input type="hidden" name="category" value="<%= category %>">
                <select name="searchType">
                    <option value="title" <%= "title".equals(searchType) ? "selected" : "" %>>제목</option>
                    <option value="content" <%= "content".equals(searchType) ? "selected" : "" %>>내용</option>
                    <option value="writer" <%= "writer".equals(searchType) ? "selected" : "" %>>작성자</option>
                </select>
                <input type="text" name="searchKeyword" value="<%= searchKeyword %>" placeholder="검색어 입력">
                <button type="submit">🔍 검색</button>
            </form>
        </div>

        <div class="nav-buttons">
            <button onclick="location.href='list.jsp?boardType=HOSPITAL&page=1'">🏥 병원</button>
            <button onclick="location.href='list.jsp?boardType=BEAUTY&page=1'">✂️ 미용</button>
            <button onclick="location.href='list.jsp?boardType=HOTEL&page=1'">🏨 호텔</button>
            <button onclick="location.href='list.jsp?boardType=PLAY&page=1'">🧸 놀거리</button>
            <button onclick="location.href='list.jsp?boardType=SUGGESTION&page=1'">💡 건의사항</button>
            <button onclick="location.href='list.jsp?boardType=NOTICE&page=1'">📢 공지사항</button>
            <button onclick="location.href='list.jsp?page=1'">전체보기</button>
        </div>
        
        <div class="filter-wrapper">
            <div>
                <% if (!"SUGGESTION".equals(boardType)) { %>
                    🧸 카테고리: 
                    <button class="filter-btn" onclick="location.href='list.jsp?boardType=<%=boardType%>&category=일반&sort=<%=sort%>&searchType=<%=searchType%>&searchKeyword=<%=searchKeyword%>'">일반</button>
                    <button class="filter-btn" onclick="location.href='list.jsp?boardType=<%=boardType%>&category=질문&sort=<%=sort%>&searchType=<%=searchType%>&searchKeyword=<%=searchKeyword%>'">질문</button>
                <% } %>
            </div>
            
            <div class="filter-right-group" style="display: flex; gap: 8px; align-items: center;">
                <button class="filter-btn" onclick="location.href='list.jsp?boardType=<%=boardType%>&category=<%=category%>&searchType=<%=searchType%>&searchKeyword=<%=searchKeyword%>&sort=latest'">⏰ 최신순</button>
                <button class="filter-btn" onclick="location.href='list.jsp?boardType=<%=boardType%>&category=<%=category%>&searchType=<%=searchType%>&searchKeyword=<%=searchKeyword%>&sort=views'">🔥 조회순</button>
                <button class="filter-btn" onclick="location.href='list.jsp?boardType=<%=boardType%>&category=<%=category%>&searchType=<%=searchType%>&searchKeyword=<%=searchKeyword%>&sort=recommend'">👍 추천순</button>
                
                <% if (showWriteBtn) { %>
                    <span style="color: #ffe4d0; margin: 0 5px;">|</span>
                    <button class="top-write-btn" onclick="location.href='write.jsp?boardType=<%= boardType %>'">✏️ 글쓰기</button>
                <% } %>
            </div>
        </div>
        
        <table>
            <thead>
                <tr>
                    <th width="5%">번호</th>
                    <th width="10%">게시판</th>
                    <th width="8%">카테고리</th>
                    <th width="35%">제목</th>
                    <th width="10%">작성자</th>
                    <th width="10%">날짜</th>
                    <th width="6%">조회</th>
                    <th width="5%">추천</th>
                    <th width="6%">비추천</th>
                    <th width="5%">신고</th>
                </tr>
            </thead>
            <tbody>
                <%-- 📌 [수정 됨!] 상단 핀고정 공지사항 출력 구역 --%>
                <% if (noticePinnedList != null && !noticePinnedList.isEmpty()) { %>
                    <% for (BoardDTO notice : noticePinnedList) { %>
                        <tr style="background-color: #fff0ec; font-weight: bold;"> 
                            <td><span style="color: #ff735d; font-size: 16px;">📌</span></td>
                            <td><span class="admin-badge" style="background-color: #ff735d;">공지</span></td>
                            <td>-</td>
                            <td style="text-align: left;">
                                <a href="detail.jsp?postId=<%= notice.getPost_id() %>" style="color: #e65c47; font-weight: bold;">
                                    <%= notice.getTitle() %>
                                </a>
                            </td>
                            <td>
                                <span class="admin-badge">[관리자]</span>
                                admin
                            </td>
                            <td><%= notice.getReg_date() != null ? notice.getReg_date().toString().substring(0, 10) : "" %></td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                            <td>-</td>
                        </tr>
                    <% } %>
                <% } %>

                <%-- 📝 일반 게시글 출력 구역 --%>
                <% if (postList == null || postList.isEmpty()) { %>
                    <tr>
                        <td colspan="10" style="padding: 50px 0; color: #ff8b77; font-weight: bold; font-size: 16px;">
                            🐾 아직 등록된 게시글이 없어요!
                        </td>
                    </tr>
                <% } else { %>
                    <% for (BoardDTO post : postList) { %>
                        <tr>
                            <td><%= post.getPost_id() %></td>
                            <td><%= post.getBoard_type() %></td>
                            <td><%= post.getCategory() %></td>
                            
                            <td style="text-align: left;">
                                <% if (post.getReport_count() >= 5) { %>
                                    <span style="color: #999; font-style: italic;">🚫 신고 누적 블라인드 게시물</span>
                                <% } else { %>
                                    <% if ("SUGGESTION".equals(post.getBoard_type())) { 
                                        String currentStatus = post.getStatus();
                                        if ("답변완료".equals(currentStatus)) { %>
                                            <span class="status-badge status-done">답변완료</span>
                                        <% } else { %>
                                            <span class="status-badge status-wait">답변대기</span>
                                        <% } 
                                    } %>
                                    
                                    <a href="detail.jsp?postId=<%= post.getPost_id() %>">
                                        <%= post.getTitle() %>
                                        <% if(post.getCommentCount() > 0) { %>
                                            <span style="color:#ff735d; font-weight:bold; font-size:13px;">[<%= post.getCommentCount() %>]</span>
                                        <% } %>
                                    </a>
                                <% } %>
                            </td>
                            
                            <td>
                                <% if ("admin".equals(post.getWriter())) { %><span class="admin-badge">[관리자]</span><% } %>
                                <%= post.getWriter() %>
                            </td>
                            
                            <td><%= post.getReg_date() != null ? post.getReg_date().toString().substring(0, 10) : "" %></td>
                            <td><%= post.getView_count() %></td>
                            <td><%= post.getLike_count() %></td>
                            <td><%= post.getDislike_count() %></td>
                            <td><%= post.getReport_count() %></td>
                        </tr>
                    <% } %>
                <% } %>
            </tbody>
        </table>

        <div class="pagination-box">
            <% if (startPage > 1) { %>
                <a href="list.jsp?page=<%= startPage - 1 %>&boardType=<%= boardType %>&category=<%= category %>&sort=<%= sort %>&searchType=<%= searchType %>&searchKeyword=<%= searchKeyword %>">◀</a>
            <% } %>
            
            <% for (int i = startPage; i <= endPage; i++) { %>
                <a href="list.jsp?page=<%= i %>&boardType=<%= boardType %>&category=<%= category %>&sort=<%= sort %>&searchType=<%= searchType %>&searchKeyword=<%= searchKeyword %>" 
                   style='<%= (i == currentPage) ? "color:#ff5d42; font-weight:bold;" : "" %>'>
                   <%= i %>
                </a>
            <% } %>
            
            <% if (endPage < totalPages) { %>
                <a href="list.jsp?page=<%= endPage + 1 %>&boardType=<%= boardType %>&category=<%= category %>&sort=<%= sort %>&searchType=<%= searchType %>&searchKeyword=<%= searchKeyword %>">▶</a>
            <% } %>
        </div>

        <% if (showWriteBtn) { %>
            <div class="write-box">
                <button onclick="location.href='write.jsp?boardType=<%= boardType %>'">✏️ 글쓰기</button>
            </div>
        <% } %>
    </div>
    <jsp:include page="../components/footer.jsp" />
    
</body>
</html>