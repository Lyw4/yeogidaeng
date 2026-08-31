<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%@ page import="web.bean.board.ReplyDAO" %>
<%@ page import="web.bean.board.ReplyDTO" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat" %>
<jsp:include page="checkStatus.jsp" />
<%
    request.setCharacterEncoding("UTF-8");
    
    String id = (String)session.getAttribute("id");
    if(id == null) id = (String)session.getAttribute("sid"); 
    String role = (String)session.getAttribute("role");
    
    boolean isAdmin = "ADMIN".equals(role); 
    String filter = request.getParameter("filter");
    
    BoardDAO boardDAO = new BoardDAO();
    ReplyDAO replyDAO = new ReplyDAO(); 
    List<BoardDTO> qnaList = boardDAO.getQnaList();
    
    // [페이징 & 필터링 처리]
    List<BoardDTO> filteredList = new ArrayList<>();
    Map<Integer, Boolean> answerMap = new HashMap<>(); 
    
    if (qnaList != null) {
        for(BoardDTO dto : qnaList) {
            if("Y".equals(dto.getIs_blind()) && !isAdmin) continue;
            
            List<ReplyDTO> replies = replyDAO.getReplies(dto.getPost_id());
            boolean isAnswered = (replies != null && !replies.isEmpty());
            answerMap.put(dto.getPost_id(), isAnswered);

            if("w".equals(filter) && isAnswered) continue; 
            
            filteredList.add(dto);
        }
    }

    int pageSize = 10; 
    String pageNumStr = request.getParameter("pageNum");
    int currentPage = (pageNumStr == null || pageNumStr.isEmpty()) ? 1 : Integer.parseInt(pageNumStr);
    int totalCount = filteredList.size();
    int totalPages = (int) Math.ceil((double) totalCount / pageSize);
    if(currentPage > totalPages && totalPages > 0) currentPage = totalPages;
    
    int startIdx = (currentPage - 1) * pageSize;
    int endIdx = Math.min(startIdx + pageSize, totalCount);

    int pageBlock = 5; 
    int startPage = ((currentPage - 1) / pageBlock) * pageBlock + 1;
    int endPage = startPage + pageBlock - 1;
    if(endPage > totalPages) endPage = totalPages;

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>건의게시판 목록</title>
<style>
    body { font-family: 'Malgun Gothic', sans-serif; }
    table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    th, td { padding: 12px; text-align: center; vertical-align: middle; }
    td { border-bottom: 1px solid #ddd; font-size: 14px; }
    tr:hover { background-color: #f1f2f6; }
    
    .title-td { text-align: left; padding-left: 15px; }
    
    .filter-box { margin-bottom: 15px; }
    .filter-box a { text-decoration: none; color: #3498db; margin-right: 10px; font-size: 14px; font-weight: bold; }
    .btn { background-color: #3498db; color: white; padding: 8px 15px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; font-size: 14px; display: inline-block; font-weight:bold; white-space: nowrap; }
    .btn-delete { background-color: #e74c3c; }
    .btn-blind { background-color: #f39c12; }
    
    /* 🔥 뱃지 스타일 통일 */
    .badge { padding: 4px 8px; border-radius: 12px; font-size: 11px; font-weight: bold; display: inline-block; }
    .badge-wait { background-color: #ffeaa7; color: #d63031; }
    .badge-complete { background-color: #badc58; color: #2f3542; }
    .badge-blind { background-color: #fadbd8; color: #e74c3c; }

    .pagination { text-align: center; }
    .pagination a { display: inline-block; padding: 6px 12px; margin: 0 2px; border: 1px solid #ddd; text-decoration: none; color: #333; border-radius: 4px; font-size: 14px; }
    .pagination a.active { background-color: #3498db; color: white; border-color: #3498db; font-weight: bold; }
    .pagination a:hover:not(.active) { background-color: #f1f2f6; }

    <% if(isAdmin) { %>
    body { margin: 0; padding: 0; display: flex; background-color: #f4f6f9; }
    .sidebar { width: 250px; height: 100vh; background-color: #2c3e50; color: white; padding-top: 20px; position: fixed; }
    .sidebar h3 { text-align: center; margin-bottom: 30px; color: #3498db; }
    .sidebar a { display: block; color: #bdc3c7; padding: 15px 25px; text-decoration: none; font-size: 16px; border-left: 4px solid transparent; transition: 0.3s; }
    .sidebar a:hover { color: white; background-color: #34495e; border-left: 4px solid #3498db; }
    .sidebar a.active { color: white; background-color: #1a252f; border-left: 4px solid #2ecc71; }
    .content { margin-left: 250px; padding: 40px; width: calc(100% - 250px); box-sizing: border-box; }
    .content h2 { color: #333; margin-bottom: 20px; border-bottom: 2px solid #2c3e50; padding-bottom: 10px; }
    .card { background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 30px; }
    th { background-color: #f8f9fa; color: #7f8c8d; font-weight: bold; border-top: 2px solid #34495e; border-bottom: 1px solid #ddd; }
    <% } else { %>
    body { background-color: #f8f9fa; margin: 30px; }
    .container { max-width: 900px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
    h2 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
    th { background-color: #3498db; color: white; }
    <% } %>
</style>
<script>
    function toggleAll(source) {
        let checkboxes = document.getElementsByName('chk_post');
        for(let i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = source.checked;
        }
    }

    function submitMultiAction(actionType) {
        let checkboxes = document.getElementsByName('chk_post');
        let isChecked = false;
        for(let i=0; i<checkboxes.length; i++) {
            if(checkboxes[i].checked) { isChecked = true; break; }
        }
        
        if(!isChecked) {
            alert("처리할 게시글을 하나 이상 선택해주세요.");
            return;
        }
        
        if(actionType === 'delete' && !confirm("선택한 글을 정말 삭제하시겠습니까?\\n(복구 불가능)")) return;
        if(actionType === 'blind' && !confirm("선택한 글의 블라인드 상태를 변경하시겠습니까?")) return;
        
        document.getElementById('multiActionType').value = actionType;
        document.getElementById('multiForm').submit();
    }
</script>
</head>
<body>

<% if(isAdmin) { %>
     <div class="sidebar">
        <h3>대시보드</h3>
        <a href="<%= request.getContextPath() %>/views/admin/adminMain.jsp">🏠 메인 홈</a>
        <a href="<%= request.getContextPath() %>/views/admin/noticeManage.jsp">📢 공지 사항</a>
        <a href="<%= request.getContextPath() %>/views/admin/memberList.jsp">👥 유저 관리</a>
        <a href="<%= request.getContextPath() %>/views/admin/QnaList.jsp">💬 건의 사항</a>
        <a href="<%= request.getContextPath() %>/views/admin/boardManage.jsp">📋 모든 게시판 관리</a>
        
        <div style="margin-top: 50px; border-top: 1px solid #34495e; padding-top: 10px;">
            <a href="<%= request.getContextPath() %>/views/main/mainPage.jsp" style="color: #f1c40f;">
                🌐 서비스 메인페이지
            </a>
            <a href="<%= request.getContextPath() %>/views/board/list.jsp" style="color: #2ecc71;">
                📄 전체 글 보기
            </a>
        </div>
    </div>
    <div class="content">
        <h2>💬 건의사항 관리</h2>
        <div class="card">
<% } else { %>
    <div class="container">
        <h2>📋 고객의 소리</h2>
<% } %>

        <div class="filter-box">
            <a href="QnaList.jsp">전체 보기</a> |
            <a href="QnaList.jsp?filter=w">⏳ 미답변 질문만 보기</a>
        </div>

        <% if(isAdmin) { %>
        <form id="multiForm" action="QnaMultiActionPro.jsp" method="post">
            <input type="hidden" id="multiActionType" name="action" value="">
        <% } %>

        <table>
            <thead>
                <tr>
                    <% if(isAdmin) { %><th width="5%"><input type="checkbox" onclick="toggleAll(this)"></th><% } %>
                    <th width="10%">번호</th>
                    <th width="15%">상태</th>
                    <th width="<%= isAdmin ? 40 : 45 %>%">제목</th>
                    <th width="15%">작성자</th>
                    <th width="15%">작성일</th>
                </tr>
            </thead>
            <tbody>
            <%
                if(totalCount == 0) {
                    out.println("<tr><td colspan='" + (isAdmin ? 6 : 5) + "' style='padding:30px;'>등록된 게시글이 없습니다.</td></tr>");
                } else {
                    for(int i = startIdx; i < endIdx; i++) {
                        BoardDTO dto = filteredList.get(i);
                        boolean isAnswered = answerMap.get(dto.getPost_id());
            %>
                <tr>
                    <% if(isAdmin) { %>
                        <td><input type="checkbox" name="chk_post" value="<%= dto.getPost_id() %>"></td>
                    <% } %>
                    <td><%= dto.getPost_id() %></td>
                    
                    <%-- 🔥 상태 칸에 블라인드 여부와 답변 여부를 함께 깔끔하게 배치 --%>
                    <td>
                        <% if("Y".equals(dto.getIs_blind())) { %>
                            <div style="margin-bottom: 5px;">
                                <span class="badge badge-blind">🔒 블라인드</span>
                            </div>
                        <% } %>
                        <%= isAnswered 
                            ? "<span class='badge badge-complete'>✅ 답변 완료</span>" 
                            : "<span class='badge badge-wait'>⏳ 답변 대기 중</span>" %>
                    </td>
                    
                    <td class="title-td">
                        <a href="../board/detail.jsp?postId=<%= dto.getPost_id() %>" style="text-decoration: none; color: #2c3e50; font-weight: bold;">
                            <% if("Y".equals(dto.getIs_blind())) { %>
                                <span style="color: #95a5a6; text-decoration: line-through;"><%= dto.getTitle() %></span>
                            <% } else { %>
                                <%= dto.getTitle() %>
                            <% } %>
                        </a>
                    </td>
                    
                    <td><%= isAdmin && "admin".equals(dto.getWriter()) ? "🛠️ 관리자" : dto.getWriter() %></td>
                    <td><%= sdf.format(dto.getReg_date()) %></td>
                </tr>
            <%
                    }
                }
            %>
            </tbody>
        </table>

        <% if(isAdmin) { %>
        </form>
        <% } %>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 20px; width: 100%;">
            
            <div style="flex: 1; text-align: left;">
                <% if(isAdmin) { %>
                    <button type="button" class="btn btn-blind" onclick="submitMultiAction('blind')">블라인드</button>
                    <button type="button" class="btn btn-delete" onclick="submitMultiAction('delete')">일괄삭제</button>
                <% } %>
            </div>

            <div class="pagination" style="flex: 1;">
                <% if(startPage > 1) { %>
                    <a href="?pageNum=<%= startPage - 1 %>&filter=<%= filter!=null?filter:"" %>">이전</a>
                <% } %>
                <% for(int i = startPage; i <= endPage; i++) { %>
                    <a href="?pageNum=<%= i %>&filter=<%= filter!=null?filter:"" %>" class="<%= (i == currentPage) ? "active" : "" %>"><%= i %></a>
                <% } %>
                <% if(endPage < totalPages) { %>
                    <a href="?pageNum=<%= endPage + 1 %>&filter=<%= filter!=null?filter:"" %>">다음</a>
                <% } %>
            </div>
            
            <div style="flex: 1; text-align: right;">
                <% if(!isAdmin) { %>
                    <a href="QnaWriteForm.jsp" class="btn">📝 질문하기</a>
                <% } %>
            </div>

        </div>

<% if(isAdmin) { %>
        </div> 
    </div> 
<% } else { %>
    </div> 
<% } %>

</body>
</html>