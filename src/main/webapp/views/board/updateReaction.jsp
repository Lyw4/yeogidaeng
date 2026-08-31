<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="web.bean.board.BoardDAO" %>
<%
    String postIdStr = request.getParameter("postId");
    String action = request.getParameter("action"); 
    String sid = (String)session.getAttribute("sid");

    if (sid == null) {
        out.print("not_login");
        return;
    }

    if (postIdStr != null && action != null) {
        int postId = Integer.parseInt(postIdStr);
        BoardDAO dao = new BoardDAO();
        String actionType = action.toUpperCase(); 
        
        if (dao.hasAlreadyPerformed(postId, sid, actionType)) {
            out.print("already_voted");
        } else {
            dao.recordActionAndIncreaseCount(postId, sid, actionType);
            out.print("success");
        }
    }
%>