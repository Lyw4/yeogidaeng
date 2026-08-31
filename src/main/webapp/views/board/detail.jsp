<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDTO" %>    
<%@ page import="web.bean.board.BoardDAO" %>    
<%@ page import="web.bean.board.ReplyDAO" %>    
<%@ page import="web.bean.board.ReplyDTO" %>    
<%@ page import="java.util.List" %>

<%
    String idParam = request.getParameter("postId");
    if (idParam == null || idParam.isEmpty()) { response.sendRedirect("list.jsp"); return; }
    
    int postId = Integer.parseInt(idParam);
    String sid = (String)session.getAttribute("sid"); 
    String role = (String)session.getAttribute("role"); 
    
    boolean isAdmin = "ADMIN".equals(role) || "admin".equals(sid);

    BoardDAO dao = new BoardDAO();
    if (sid != null) { 
        if (!dao.hasAlreadyPerformed(postId, sid, "VIEW")) {
            dao.recordActionAndIncreaseCount(postId, sid, "VIEW");
        }
    } else {
        dao.incrementViewCount(postId);
    }
    
    BoardDTO post = dao.getPostDetail(postId);
    if (post == null) {
%>
        <script> alert("존재하지 않거나 삭제된 게시글입니다."); location.href="list.jsp"; </script>
<%
        return;
    }

    String boardName = "전체게시판";
    String bType = post.getBoard_type();
    if ("HOSPITAL".equals(bType)) boardName = "병원";
    else if ("BEAUTY".equals(bType)) boardName = "미용";
    else if ("HOTEL".equals(bType)) boardName = "호텔";
    else if ("PLAY".equals(bType)) boardName = "놀거리";
    else if ("SUGGESTION".equals(bType)) boardName = "건의사항";
    else if ("NOTICE".equals(bType)) boardName = "공지사항";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= post.getTitle() %></title>
    <style>
        body { background-color: #fffaf5; font-family: 'Malgun Gothic', sans-serif; margin: 0; padding-bottom: 50px; }
        .detail-wrapper { max-width: 800px; margin: 30px auto; padding: 40px; background-color: #ffffff; border: 2px solid #ffe5df; border-radius: 30px; box-shadow: 0 10px 25px rgba(255, 204, 204, 0.3); }
        table { width: 100%; border-collapse: separate; border-spacing: 0; table-layout: fixed; word-break: break-all; margin-top: 20px; }
        th { width: 25%; background-color: #fff0ec; color: #ff735d; padding: 15px; border-bottom: 2px solid #ffe5df; text-align: center; font-weight: bold; }
        td { padding: 15px; border-bottom: 1px solid #fff0ec; color: #555; vertical-align: middle; }
        .content-cell { min-height: 250px; vertical-align: top; padding: 20px; line-height: 1.8; }
        .action-group { display: flex; justify-content: center; gap: 10px; margin-top: 30px; }
        .pill-btn { padding: 10px 25px; border-radius: 50px; border: none; background-color: #ffcccc; color: white; font-weight: bold; cursor: pointer; transition: all 0.2s; box-shadow: 0 4px 6px rgba(255, 153, 153, 0.2); }
        .pill-btn:hover { background-color: #ffb3b3; transform: translateY(-2px); }
        .reply-box { margin-top: 40px; padding: 20px; background-color: #fff9f9; border-radius: 20px; border: 1px solid #ffe5df; }
        .reply-item { padding: 15px; border-bottom: 1px dashed #ffcccc; }
        textarea { width: 100%; padding: 10px; border: 2px solid #ffe5df; border-radius: 15px; resize: none; box-sizing: border-box; }
        .lock-msg { padding: 20px; text-align: center; color: #888; background-color: #f1ece7; border-radius: 10px; font-weight: bold; margin-top: 15px; }
        .reply-submit-btn { padding: 10px 20px; background-color: #ff8b77; color: white; border: none; border-radius: 10px; font-weight: bold; cursor: pointer; margin-top: 5px; }
        .reply-submit-btn:hover { background-color: #e6735e; }
    </style>
</head>
<body>

    <div class="detail-wrapper">
        <h2 style="color: #ff8b77; margin-top: 0;">📄 <%= boardName %></h2>
        
       <table>
            <tr>
                <th>분류</th>
                <td>[<%= boardName %>] <%= post.getCategory() %></td>
            </tr>
            <tr>
                <th>제목</th>
                <td>
                    <% if ("SUGGESTION".equals(post.getBoard_type())) { 
                        String currentStatus = post.getStatus() != null ? post.getStatus() : "답변대기";
                    %>
                        <span style="color: <%= "답변완료".equals(currentStatus) ? "#0066cc" : "#cc0000" %>;">[<%= currentStatus %>]</span>
                    <% } %>
                    <b><%= post.getTitle() %></b>
                </td>
            </tr>
            <tr>
                <th>작성자</th>
                <td><%= post.getWriter() %> | <%= post.getReg_date() %></td>
            </tr>
            <tr>
                <th>통계</th>
                <td>👀 <%= post.getView_count() %> |
                👍 <span id="like_count_text"><%= post.getLike_count() %></span> | 
                👎 <span id="dislike_count_text"><%= post.getDislike_count() %></span> |
                <span style="color: #ff4d4d; font-weight: bold;">🚨 <span id="report_count_text"><%= post.getReport_count() %></span></span>
                </td>
            </tr>
            <tr>
                <th>내용</th>
                <td class="content-cell">
                    <% if (post.getReport_count() >= 5) { %>
                        <div style="padding: 40px; text-align: center; background-color: #fff0f0; border: 2px dashed #ff8080; border-radius: 10px; color: #ff5555;">
                            <h3>🚨 블라인드 처리된 게시물</h3>
                            <p>이 게시물은 다수의 신고로 인해 관리자에 의해 블라인드 처리되었습니다.</p>
                        </div>
                    <% } else { %>
                        <%= post.getContent().replaceAll("\n", "<br>") %>
                    <% } %>
                </td>
            </tr>
            <tr>
	                <th>첨부파일</th>
			    <td>
			        <% 
			            String fileName = post.getFile_name();
			            if (fileName != null && !fileName.isEmpty()) { 
			                // 파일 확장자 추출
			                String ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
			                boolean isImage = ext.equals("jpg") || ext.equals("jpeg") || ext.equals("png") || ext.equals("gif");
			        %>
			            <a href="<%= request.getContextPath() %>/views/upload/<%= fileName %>" target="_blank" style="color: #ff8b77; text-decoration:none;">
			                💾 <%= fileName %>
			            </a>
			            
			            <% if (isImage) { %>
			                <br><img src="<%= request.getContextPath() %>/views/upload/<%= fileName %>" 
			                         style="max-width: 100%; margin-top: 10px; border-radius: 10px;">
			            <% } %>
			            
			        <% } else { %> - <% } %>
			    </td>
			</tr>
        </table>
        
        <% if (post.getReport_count() < 5) { %>
        <div class="action-group">
            <button class="pill-btn" onclick="sendReaction('like')">👍 추천</button>
            <button class="pill-btn" onclick="sendReaction('dislike')">👎 비추천</button>
            <button class="pill-btn" onclick="sendReaction('report')">🚨 신고</button>
        </div>
        <% } %>
        
        <div class="action-group">
            <button class="pill-btn" style="background-color: #eee; color: #666;" onclick="location.href='list.jsp?boardType=<%= post.getBoard_type() %>'">목록으로</button>
            <% if (sid != null && sid.equals(post.getWriter())) { %>
                <button class="pill-btn" onclick="location.href='update.jsp?postId=<%= post.getPost_id() %>'">수정</button>
                <button class="pill-btn" style="background-color: #ff8080;" onclick="if(confirm('삭제 하시겠습니까?')) location.href='deleteAction.jsp?postId=<%= post.getPost_id() %>'">삭제</button>
            <% } %>
        </div>

        <div class="reply-box">
            <h3>💬 댓글</h3>
            <% ReplyDAO replyDao = new ReplyDAO();
               List<ReplyDTO> replyList = replyDao.getReplyList(postId);
               boolean isSuggestion = "SUGGESTION".equals(post.getBoard_type());
               boolean canReply = !isSuggestion || isAdmin; 
               
               for(ReplyDTO reply : replyList) { %>
                
                <%-- 1. 개별 댓글 출력 영역 (대댓글 여부에 따라 margin-left 적용) --%>
                <div class="reply-item" style="margin-left: <%= reply.getDepth() * 30 %>px;">
                    <% if (reply.getDepth() > 0) { %>
                        <span style="color: #ff8b77; font-weight: bold; margin-right: 5px;">↳</span>
                    <% } %>
				    <strong><%= reply.getWriter() %></strong> 
				    <p style="margin: 5px 0;"><%= reply.getContent() %></p>
				    
                    <%-- 답글(대댓글) 작성 버튼 --%>
                    <% if(canReply) { %>
                        <button onclick="toggleReplyForm(<%= reply.getReplyId() %>)" style="font-size:11px; cursor:pointer; background:none; border:1px solid #ccc; border-radius:3px; padding:3px 6px;">답글</button>
                    <% } %>

				    <%-- [본인 확인] 로그인한 유저가 댓글 작성자와 같을 때만 노출 --%>
				    <% if(sid != null && sid.equals(reply.getWriter())) { %>
				        <button onclick="toggleReplyEdit(<%= reply.getReplyId() %>)" style="font-size:11px; cursor:pointer; background:none; border:1px solid #ccc; border-radius:3px; padding:3px 6px;">수정</button>
				        <button onclick="deleteReply(<%= reply.getReplyId() %>, <%= postId %>)" style="font-size:11px; cursor:pointer; color:red; background:none; border:1px solid #ffcccc; border-radius:3px; padding:3px 6px;">삭제</button>
				    <% } %>
                </div>
                
                <%-- 2. 댓글 수정 폼 (기존 유지) --%>
                <% if(canReply) { %>
                <div id="editForm_<%= reply.getReplyId() %>" style="display:none; padding:10px; background:#fff0f0; border-radius:10px; margin-bottom:10px; margin-left: <%= reply.getDepth() * 30 %>px;">
				    <form action="updateReplyPro.jsp" method="post">
				        <input type="hidden" name="replyId" value="<%= reply.getReplyId() %>">
				        <input type="hidden" name="postId" value="<%= postId %>">
				        <textarea name="content" rows="2" style="width:100%;"><%= reply.getContent() %></textarea>
				        <button type="submit" class="pill-btn" style="padding:5px 15px; font-size:12px; margin-top:5px;">수정완료</button>
				    </form>
				</div>
                
                <%-- 3. [신규 추가] 대댓글 작성 폼 --%>
                <div id="replyForm_<%= reply.getReplyId() %>" style="display:none; padding:10px; background:#f9f9f9; border-radius:10px; margin-bottom:10px; border:1px solid #ddd; margin-left: <%= (reply.getDepth() * 30) + 20 %>px;">
                    <form action="replyPro.jsp" method="post" onsubmit="return checkLogin('<%= sid %>')">
                        <input type="hidden" name="postId" value="<%= postId %>">
                        <input type="hidden" name="parentReplyId" value="<%= reply.getReplyId() %>">
                        <input type="hidden" name="depth" value="<%= reply.getDepth() + 1 %>">
                        <input type="text" name="writer" value="<%= (sid != null) ? sid : "" %>" readonly style="margin-bottom:5px; padding:5px; border-radius:5px; border:1px solid #ccc; background-color:#eee; font-size:12px;">
                        <textarea name="content" rows="2" style="width:100%;" placeholder="답글을 입력해주세요" required></textarea>
                        <button type="submit" class="pill-btn" style="padding:5px 15px; font-size:12px; margin-top:5px;">답글등록</button>
                    </form>
                </div>
                <% } %>
            <% } %>
            
            <%-- 4. 하단 일반 댓글 작성 폼 --%>
            <% if (canReply) { %>
                <form action="replyPro.jsp" method="post" style="margin-top:30px; border-top:2px solid #ffe5df; padding-top:20px;" onsubmit="return checkLogin('<%= sid %>')">
                    <input type="hidden" name="postId" value="<%= postId %>">
                    <input type="hidden" name="parentReplyId" value="0"> <%-- 최상위 댓글이므로 0 --%>
                    <input type="hidden" name="depth" value="0">
                    <input type="text" name="writer" value="<%= (sid != null) ? sid : "" %>" readonly placeholder="로그인 필요" style="margin-bottom:5px; padding:5px; border-radius:5px; border:1px solid #ccc; background-color:#eee;">
                    <textarea name="content" placeholder="댓글을 남겨주세요" rows="3" required></textarea>
                    <button type="submit" class="reply-submit-btn">등록</button>
                </form>
            <% } else { %>
                <div class="lock-msg">
                    🔒 건의사항에 대한 답변은 관리자만 작성할 수 있습니다.
                </div>
            <% } %>
        </div>
    </div>

<script>
    // [댓글 수정창 토글]
    function toggleReplyEdit(id) { 
        const f = document.getElementById('editForm_' + id); 
        if(f) {
            f.style.display = (f.style.display === 'none') ? 'block' : 'none'; 
        }
    }

    // [대댓글 작성창 토글]
    function toggleReplyForm(id) { 
        const f = document.getElementById('replyForm_'+id); 
        if(f) {
            f.style.display = (f.style.display === 'none') ? 'block' : 'none'; 
        }
    }
    
    // [댓글 삭제]
    function deleteReply(replyId, postId) {
        if(confirm("정말 삭제하시겠습니까?")) {
            location.href = "deleteReply.jsp?replyId=" + replyId + "&postId=" + postId;
        }
    }

    // [로그인 체크]
    function checkLogin(sid) { 
	    if (!sid || sid === "null") { 
	        alert("로그인이 필요합니다.");
	        location.href = "<%= request.getContextPath() %>/views/member/loginForm.jsp"; 
	        return false; 
	    } 
	    return true;
	}
    
    // [하단 폼 서브밋 유효성] - onsubmit으로 대체되어 삭제해도 무방하나 기존 버튼 유지 시 사용
    function checkAndSubmit(form) {
        if(checkLogin('<%= sid %>')) {
            form.submit();
        }
    }
    
    // [추천/비추천/신고]
    function sendReaction(actionName) {
    	if (!'<%= sid %>' || '<%= sid %>' === "null") { 
    	    alert("로그인이 필요합니다.");
    	    location.href = "<%= request.getContextPath() %>/views/member/loginForm.jsp"; 
    	    return; 
    	}
        fetch('updateReaction.jsp?postId=<%= post.getPost_id() %>&action=' + actionName)
            .then(res => res.text())
            .then(data => { 
                let result = data.trim();
                if(result === "success") { alert("반영되었습니다!"); location.reload(); }
                else if(result === "already_voted") { alert("이미 참여하셨습니다!"); }
            });
    }
</script>
</body>
</html>