<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="web.bean.admin.AdminDAO" %>
<%@ page import="web.bean.member.MemberDTO" %>

<%
    // 🔥 최신 보안 체크 적용 (관리자 권한 완벽 확인)
    String id = (String)session.getAttribute("id");
    if(id == null) id = (String)session.getAttribute("sid");
    String role = (String)session.getAttribute("role");

    if(id == null || !"ADMIN".equals(role)) {
%>
        <script>
            alert("관리자만 접근 가능한 페이지입니다.");
            location.href = "../member/loginForm.jsp";
        </script>
<%
        return; 
    }

    request.setCharacterEncoding("UTF-8");
    // 회원님의 기존 변수명(adminDAO) 유지
    AdminDAO adminDAO = new AdminDAO();
    List<MemberDTO> memberList = adminDAO.getAllMember();
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>관리자 - 유저 관리</title>
    <style>
        /* 🎨 다른 관리자 페이지와 완벽하게 동일한 UI 디자인 */
        body { font-family: 'Malgun Gothic', sans-serif; margin: 0; padding: 0; display: flex; background-color: #f4f6f9; }
        
        /* 왼쪽 사이드바 */
        .sidebar { width: 250px; height: 100vh; background-color: #2c3e50; color: white; padding-top: 20px; position: fixed; }
        .sidebar h3 { text-align: center; margin-bottom: 30px; color: #3498db; }
        .sidebar a { display: block; color: #bdc3c7; padding: 15px 25px; text-decoration: none; font-size: 16px; border-left: 4px solid transparent; transition: 0.3s; }
        .sidebar a:hover { color: white; background-color: #34495e; border-left: 4px solid #3498db; }
        .sidebar a.active { color: white; background-color: #1a252f; border-left: 4px solid #2ecc71; }
        
        /* 오른쪽 메인 컨텐츠 */
        .content { margin-left: 250px; padding: 40px; width: calc(100% - 250px); box-sizing: border-box; }
        .content h2 { color: #333; margin-bottom: 20px; border-bottom: 2px solid #2c3e50; padding-bottom: 10px; }
        
        /* 카드 및 테이블 디자인 */
        .card { background-color: white; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); padding: 20px; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { border: 1px solid #f1f2f6; padding: 12px; text-align: center; font-size: 14px; vertical-align: middle; }
        th { background-color: #f8f9fa; color: #7f8c8d; font-weight: bold; }
        tr:hover { background-color: #f1f1f1; }
        
        /* select 및 버튼 디자인 */
        select { padding: 6px 10px; border-radius: 4px; border: 1px solid #ccc; font-size: 13px; outline: none; cursor: pointer; }
        select:focus { border-color: #3498db; }
        
        .btn-save { background-color: #2ecc71; color: white; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; font-weight: bold; font-size: 13px; transition: 0.2s; }
        .btn-save:hover { background-color: #27ae60; transform: translateY(-1px); }
    </style>
    <script>
        function changeStatus(userId) {
            var statusVal = document.getElementById("status_" + userId).value;
            var roleVal = document.getElementById("role_" + userId).value;
            
            if(confirm(userId + " 님의 권한과 상태를 변경하시겠습니까?")) {
                location.href = "memberUpdateAction.jsp?id=" + userId + "&status=" + statusVal + "&role=" + roleVal;
            }
        }
    </script>
</head>
<body>
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
        <h2>👥 유저 권한 및 상태 관리</h2>
        
        <div class="card">
            <table>
                <thead>
                    <tr>
                        <th width="15%">아이디</th>
                        <th width="10%">이름</th>
                        <th width="20%">이메일</th>
                        <th width="15%">가입일</th>
                        <th width="10%">블라인드 수</th> <th width="10%">권한(Role)</th>
                        <th width="10%">상태</th>
                        <th width="10%">관리</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if (memberList != null && !memberList.isEmpty()) {
                        // 날짜를 보기 좋게 자르기 위한 포맷 객체
                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
                        
                        for (MemberDTO member : memberList) {
                            // 블라인드 횟수 조회
                            int blindCount = adminDAO.getBlindedPostCount(member.getId());
                %>
                    <tr>
                        <td style="font-weight: bold; color: #2c3e50;"><%= member.getId() %></td>
                        <td><%= member.getName() %></td>
                        <!-- 💡 추가: 이메일 출력 -->
                        <td><%= member.getEmail() %></td>
                        <!-- 💡 추가: 가입일 출력 (null 체크 포함) -->
                        <td><%= (member.getReg() != null) ? sdf.format(member.getReg()) : "미등록" %></td>
                        
                        <!-- 블라인드 수 -->
                        <td style="color: <%= blindCount >= 5 ? "red" : "black" %>; font-weight: bold;">
                            <%= blindCount %>회
                        </td>

                        <td>
                            <select id="role_<%= member.getId() %>">
                                <option value="USER" <%="USER".equals(member.getRole())?"selected":""%>>일반회원</option>
                                <option value="ADMIN" <%="ADMIN".equals(member.getRole())?"selected":""%>>관리자</option>
                            </select>
                        </td>
                        <td>
                            <select id="status_<%= member.getId() %>">
                                <option value="1" <%=member.getStatus()==1?"selected":""%>>정상</option>
                                <option value="-1" <%=member.getStatus()==-1?"selected":""%>>정지</option>
                                <option value="0" <%=member.getStatus()==0?"selected":""%>>탈퇴</option>
                            </select>
                        </td>
                        <td>
                            <button class="btn-save" onclick="changeStatus('<%= member.getId() %>')">적용</button>
                        </td>
                    </tr>
                <%
                        }
                    } else {
                %>
                    <tr><td colspan="8" style="padding: 30px; color: #7f8c8d;">등록된 회원이 없습니다.</td></tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
</body>
</html>