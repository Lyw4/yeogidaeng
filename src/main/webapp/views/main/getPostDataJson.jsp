<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ page import="java.util.List" %>
<%@ page import="web.bean.board.BoardDAO" %>
<%@ page import="web.bean.board.BoardDTO" %>
<%
    request.setCharacterEncoding("UTF-8");
    response.setHeader("Cache-Control", "no-cache");
    
    String paramPage = request.getParameter("page");
    int currentPage = (paramPage != null && !paramPage.isEmpty()) ? Integer.parseInt(paramPage) : 1;
    
    // 🔥 list.jsp와 똑같이 null 값을 빈 문자열로 바꿔주어 오라클 DB 에러 원천 차단!
    String boardType = request.getParameter("boardType"); if (boardType == null) boardType = "";
    String category = request.getParameter("category"); if (category == null) category = "";
    String sort = request.getParameter("sort"); if (sort == null) sort = "latest";
    String searchType = request.getParameter("searchType"); if (searchType == null) searchType = "";
    String searchKeyword = request.getParameter("searchKeyword"); if (searchKeyword == null) searchKeyword = "";

    BoardDAO dao = new BoardDAO();
    List<BoardDTO> postList = null;
    int totalCount = 0;
    int totalPages = 1;

    try {
        postList = dao.getPostList(currentPage, boardType, category, sort, searchType, searchKeyword);
        totalCount = dao.getTotalPostCount(boardType, category, searchType, searchKeyword);
        totalPages = (int) Math.ceil((double) totalCount / 10);
        if (totalPages == 0) totalPages = 1;
    } catch(Exception e) {
        e.printStackTrace();
    }

    StringBuilder json = new StringBuilder();
    json.append("{");
    json.append("\"totalPages\": ").append(totalPages).append(",");
    json.append("\"currentPage\": ").append(currentPage).append(",");
    json.append("\"posts\": [");
    
    if (postList != null) {
        for (int i = 0; i < postList.size(); i++) {
            BoardDTO dto = postList.get(i);
            json.append("{");
            json.append("\"postId\": ").append(dto.getPost_id()).append(",");
            json.append("\"boardType\": \"").append(dto.getBoard_type() != null ? dto.getBoard_type() : "").append("\",");
            json.append("\"category\": \"").append(dto.getCategory() != null ? dto.getCategory() : "").append("\",");
            
            String safeTitle = dto.getTitle() != null ? dto.getTitle().replace("\\", "\\\\").replace("\"", "\\\"").replace("\r", "").replace("\n", " ") : "";
            json.append("\"title\": \"").append(safeTitle).append("\",");
            
            json.append("\"writer\": \"").append(dto.getWriter() != null ? dto.getWriter() : "익명").append("\",");
            json.append("\"viewCount\": ").append(dto.getView_count()).append(",");
            json.append("\"likeCount\": ").append(dto.getLike_count()).append(",");
            
            if(dto.getFile_name() != null && !dto.getFile_name().trim().isEmpty()) {
                json.append("\"fileName\": \"").append(dto.getFile_name().replace("\\", "\\\\").replace("\"", "\\\"")).append("\",");
            } else {
                json.append("\"fileName\": null,");
            }
            
            String regDate = "";
            if(dto.getReg_date() != null) {
                regDate = dto.getReg_date().toString();
                if(regDate.length() >= 10) regDate = regDate.substring(0, 10);
            }
            json.append("\"regDate\": \"").append(regDate).append("\"");
            
            json.append("}");
            if (i < postList.size() - 1) json.append(",");
        }
    }
    json.append("]");
    json.append("}");

    out.print(json.toString());
%>