<%-- 1. 페이지 기본 설정: "이 문서는 자바(Java)를 쓰고, 글자가 깨지지 않게 UTF-8(한글 지원)을 쓸 거야!" --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%-- 2. 도구 불러오기: DB 삭제 명령을 내리기 위해 우리가 아까 만든 '택배 기사님(BoardDAO)'을 이 페이지로 부릅니다. --%>
<%@ page import="web.bean.board.BoardDAO" %>

<%-- 💡 [핵심] 여기서부터 <% %> 안쪽은 '순수한 자바(Java) 코드'가 실행되는 공간입니다. --%>
<%
    // 3. 삭제할 글 번호 받아오기
    // 사용자가 '삭제' 버튼을 누를 때 URL(주소창)이나 숨겨진 값으로 넘어온 "postId"를 꺼냅니다.
    // request.getParameter()로 꺼낸 값은 무조건 '문자열(String)'이기 때문에, 
    // Integer.parseInt()라는 마법 지팡이를 써서 '숫자(int)'로 변환해 주머니(postId)에 담습니다.
    int postId = Integer.parseInt(request.getParameter("postId"));

    // 4. 삭제 임무 지시하기
    BoardDAO dao = new BoardDAO();           // 택배 기사님 호출!
    int result = dao.deletePost(postId);     // 기사님께 "이 번호(postId) 글 좀 DB에서 지워주세요!"라고 명령합니다.
                                             // 성공하면 result에 1이, 실패하면 0이 담깁니다.

    // 5. 결과에 따라 화면 이동시키기
    if(result > 0) {
        // 성공(1)했을 때! 
        // 자바 공간()을 잠깐 닫고, 웹 브라우저의 팝업창(JavaScript)을 띄웁니다.
%>

        <script>
            alert("게시글이 삭제되었습니다.");  // 확인 팝업창 띄우기
            location.href="list.jsp";        // 확인을 누르면 게시글 목록(list.jsp)으로 자동 이동!
        </script>
<%
    } else {
        // 실패(0)했을 때!
%>
        <script>
            alert("글 삭제에 실패했습니다.");  // 실패 팝업창 띄우기
            history.back();                  // 뒤로 가기(사용자가 원래 있던 페이지로 돌려보냄)
        </script>
<%
    }
%>