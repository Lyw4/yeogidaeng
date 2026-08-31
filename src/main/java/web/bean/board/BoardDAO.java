package web.bean.board;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import web.bean.admin.DBConnection;

public class BoardDAO extends DBConnection {
    
    private Connection getConnection() throws Exception {
        return getConn();
    }
    
    private void closeResources(Connection conn, PreparedStatement pstmt, ResultSet rs) {
        close(conn, pstmt, rs);
    }

    // ==========================================
    // [1. 건의글 쓰기 로직]
    // ==========================================
    public void insertQna(BoardDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "INSERT INTO board (post_id, title, content, writer, reg_date, board_type, ref, re_step, re_level) " +
                         "VALUES (board_seq.NEXTVAL, ?, ?, ?, sysdate, 'SUGGESTION', board_seq.CURRVAL, 0, 0)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getTitle());   
            pstmt.setString(2, dto.getContent()); 
            pstmt.setString(3, dto.getWriter());  
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace(); 
        } finally {
            closeResources(conn, pstmt, null);
        }
    }

    // ==========================================
    // [2. 건의글 목록 불러오기 로직]
    // ==========================================
    public List<BoardDTO> getQnaList() {
        List<BoardDTO> list = new ArrayList<>(); 
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            String sql = "SELECT * FROM board WHERE board_type = 'SUGGESTION' ORDER BY ref DESC, re_step ASC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery(); 
            while(rs.next()) {
                BoardDTO dto = new BoardDTO();
                dto.setPost_id(rs.getInt("post_id"));
                dto.setTitle(rs.getString("title"));
                dto.setWriter(rs.getString("writer"));
                dto.setReg_date(rs.getTimestamp("reg_date"));
                dto.setRe_level(rs.getInt("re_level")); 
                dto.setIs_blind(rs.getString("is_blind"));
                list.add(dto); 
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return list; 
    }

    // ==========================================
    // [3. 건의글 상세조회 로직]
    // ==========================================
    public BoardDTO getQnaDetail(int postId) {
        BoardDTO dto = null;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            String sql = "SELECT * FROM board WHERE post_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            rs = pstmt.executeQuery();
            if(rs.next()) {
                dto = new BoardDTO();
                dto.setPost_id(rs.getInt("post_id"));
                dto.setTitle(rs.getString("title"));
                dto.setContent(rs.getString("content"));
                dto.setWriter(rs.getString("writer"));
                dto.setReg_date(rs.getTimestamp("reg_date"));
                dto.setRef(rs.getInt("ref"));
                dto.setRe_step(rs.getInt("re_step"));
                dto.setRe_level(rs.getInt("re_level"));
                dto.setImage_file(rs.getString("image_file")); 
                dto.setIs_blind(rs.getString("is_blind"));    
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return dto; 
    }

    // ==========================================
    // [4. 건의글 수정 로직]
    // ==========================================
    public int updateQna(BoardDTO dto) {
        int result = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "UPDATE board SET title = ?, content = ?, image_file = ? WHERE post_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getImage_file());
            pstmt.setInt(4, dto.getPost_id());
            result = pstmt.executeUpdate(); 
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
        return result;
    }

    // ==========================================
    // [5. 건의글 삭제 로직]
    // ==========================================
    public int deleteQna(int postId) {
        int result = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "DELETE FROM board WHERE post_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
        return result;
    }

 // ==========================================
    // [6. 블라인드 토글 및 자동 정지 시스템]
    // ==========================================
    public void toggleBlind(int postId) {
        String sql = "UPDATE board SET is_blind = CASE WHEN is_blind = 'Y' THEN 'N' ELSE 'Y' END WHERE post_id = ?";
        
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
            
            // 💡 블라인드 상태 변경 직후, 작성자 정지 여부 체크 로직 호출
            checkAndSuspendUserByPostId(postId);
            
        } catch (Exception e) { e.printStackTrace(); }
    }

    // 작성자의 블라인드 글 개수를 세어 5개 이상이면 status를 -1(정지)로 변경
    private void checkAndSuspendUserByPostId(int postId) {
        String getWriterSql = "SELECT writer FROM board WHERE post_id = ?";
        String countBlindSql = "SELECT COUNT(*) FROM board WHERE writer = ? AND is_blind = 'Y'";
        String updateStatusSql = "UPDATE member SET status = -1 WHERE id = ?";
        
        try (Connection conn = getConn()) {
            // 1. 작성자 아이디 찾기
            PreparedStatement pstmt = conn.prepareStatement(getWriterSql);
            pstmt.setInt(1, postId);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                String writer = rs.getString("writer");
                
                // 2. 블라인드 게시글 개수 조회
                PreparedStatement pstmt2 = conn.prepareStatement(countBlindSql);
                pstmt2.setString(1, writer);
                ResultSet rs2 = pstmt2.executeQuery();
                
                if (rs2.next() && rs2.getInt(1) >= 5) {
                    // 3. 5개 이상이면 해당 유저 정지(-1) 처리
                    PreparedStatement pstmt3 = conn.prepareStatement(updateStatusSql);
                    pstmt3.setString(1, writer);
                    pstmt3.executeUpdate();
                    System.out.println(writer + " 님 블라인드 누적 5회 달성으로 자동 정지 처리되었습니다.");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ==========================================
    // [7. 답글(댓글) 쓰기 로직 (QNA용)]
    // ==========================================
    public void insertReply(BoardDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        String updateSql = "UPDATE board SET re_step = re_step + 1 WHERE ref = ? AND re_step > ?";
        String insertSql = "INSERT INTO board (post_id, title, content, writer, reg_date, board_type, ref, re_step, re_level, image_file) " +
                           "VALUES (board_seq.NEXTVAL, ?, ?, ?, sysdate, 'SUGGESTION', ?, ?, ?, ?)";
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, dto.getRef());
            pstmt.setInt(2, dto.getRe_step());
            pstmt.executeUpdate();
            pstmt.close(); 
            
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, dto.getTitle());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getWriter());
            pstmt.setInt(4, dto.getRef());            
            pstmt.setInt(5, dto.getRe_step() + 1);    
            pstmt.setInt(6, dto.getRe_level() + 1);   
            pstmt.setString(7, dto.getImage_file());  
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
    }
 
    // ==========================================
    // [8. 글쓰기 기능]
    // ==========================================
    public int insertPost(BoardDTO dto) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        int result = 0;
        try {
            conn = this.getConnection(); 
            String sql = "INSERT INTO board (post_id, board_type, category, title, writer, content, view_count, like_count, dislike_count, report_count, is_reported, file_name, reg_date) "
                       + "VALUES (board_seq.NEXTVAL, ?, ?, ?, ?, ?, 0, 0, 0, 0, 0, ?, sysdate)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, dto.getBoard_type());   
            pstmt.setString(2, dto.getCategory());
            pstmt.setString(3, dto.getTitle());
            pstmt.setString(4, dto.getWriter());
            pstmt.setString(5, dto.getContent());
            pstmt.setString(6, dto.getFile_name());    
            result = pstmt.executeUpdate();
        } catch (Exception e) { 
            e.printStackTrace(); 
        } finally {
            closeResources(conn, pstmt, null);
        }
        return result;
    }

    // ==========================================
    // [9. 공지사항 조회]
    // ==========================================
    public List<BoardDTO> getBoardListByType(String boardType) {
        List<BoardDTO> list = new ArrayList<>();
        String sql = "SELECT * FROM BOARD WHERE board_type = ? ORDER BY reg_date DESC";
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, boardType);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BoardDTO dto = new BoardDTO();
                    dto.setPost_id(rs.getInt("post_id"));
                    dto.setTitle(rs.getString("title"));
                    dto.setReg_date(rs.getTimestamp("reg_date"));
                    list.add(dto);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    // ==========================================
    // [10. 상세 페이지 조회]
    // ==========================================
    public BoardDTO getPostDetail(int postId) {
        String sql = "SELECT * FROM BOARD WHERE post_id = ?";
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    BoardDTO dto = new BoardDTO();
                    dto.setPost_id(rs.getInt("post_id"));
                    dto.setBoard_type(rs.getString("board_type"));
                    dto.setCategory(rs.getString("category"));
                    dto.setTitle(rs.getString("title"));
                    dto.setWriter(rs.getString("writer"));
                    dto.setContent(rs.getString("content"));
                    dto.setReg_date(rs.getTimestamp("reg_date"));
                    dto.setFile_name(rs.getString("file_name"));
                    dto.setView_count(rs.getInt("view_count"));
                    dto.setLike_count(rs.getInt("like_count"));
                    dto.setDislike_count(rs.getInt("dislike_count"));
                    dto.setReport_count(rs.getInt("report_count"));
                    dto.setStatus(rs.getString("status"));
                    return dto;
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public void incrementViewCount(int postId) {
        String sql = "UPDATE BOARD SET view_count = view_count + 1 WHERE post_id = ?";
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false);
            pstmt.setInt(1, postId); 
            pstmt.executeUpdate();
            conn.commit();
        } catch (Exception e) { e.printStackTrace(); }
    }

    // ==========================================
    // [게시글 수정 로직] 사진 변경 여부에 따라 똑똑하게 작동!
    // ==========================================
    public int updatePost(BoardDTO dto) {
        int result = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        
        try {
            conn = getConnection();
            
            // 🔥 핵심: 새로운 이미지가 넘어왔는지(null이 아닌지) 검사합니다.
            if (dto.getFile_name() != null) {
                // 1. 🖼️ 사용자가 새로운 사진을 첨부한 경우 -> file_name 컬럼도 함께 덮어쓰기!
                String sql = "UPDATE board SET category=?, title=?, content=?, file_name=? WHERE post_id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, dto.getCategory());
                pstmt.setString(2, dto.getTitle());
                pstmt.setString(3, dto.getContent());
                pstmt.setString(4, dto.getFile_name()); // 새 파일명 업데이트
                pstmt.setInt(5, dto.getPost_id());
                
            } else {
                // 2. 📝 사용자가 사진은 그대로 두고 글씨만 수정한 경우 -> 기존 사진 유지!
                String sql = "UPDATE board SET category=?, title=?, content=? WHERE post_id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, dto.getCategory());
                pstmt.setString(2, dto.getTitle());
                pstmt.setString(3, dto.getContent());
                pstmt.setInt(4, dto.getPost_id());
            }
            
            result = pstmt.executeUpdate();
            
        } catch (Exception e) {
            System.out.println("updatePost 에러: " + e.getMessage());
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null); // 닫기
        }
        
        return result;
    }

    public int deletePost(int postId) {
        String sql = "DELETE FROM BOARD WHERE post_id = ?";
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            return pstmt.executeUpdate();
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
 
    public int updateCount(int postId, String type) {
        String sql = "";
        if ("report_count".equals(type)) {
            sql = "UPDATE BOARD SET report_count = report_count + 1, "
                + "is_reported = CASE WHEN report_count + 1 >= 5 THEN 1 ELSE 0 END WHERE post_id = ?";
        } else {
            sql = "UPDATE BOARD SET " + type + " = " + type + " + 1 WHERE post_id = ?";
        }
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            conn.setAutoCommit(false); 
            pstmt.setInt(1, postId);
            int result = pstmt.executeUpdate();
            conn.commit(); 
            return result;
        } catch (Exception e) { e.printStackTrace(); }
        return 0;
    }
 
    public int updateSuggestionStatus(int postId, String status) {
        String sql = "UPDATE BOARD SET status = ? WHERE post_id = ?";
        int result = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); 
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, status);
            pstmt.setInt(2, postId);
            result = pstmt.executeUpdate();
            conn.commit(); 
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch(Exception ex) {} 
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, null);
        }
        return result;
    }

    // =========================================================
    // [추가 기능] 조회수, 추천수 등 중복 방지 로직 (이력 확인)
    // =========================================================
    public boolean hasAlreadyPerformed(int postId, String userId, String actionType) {
        boolean result = false;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT 1 FROM board_history WHERE post_id = ? AND user_id = ? AND action_type = ?";
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, postId);
            pstmt.setString(2, userId);
            pstmt.setString(3, actionType);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                result = true; // 이미 기록이 있음!
            }
        } catch (Exception e) {
            System.out.println("이력 확인 중 에러 (board_history 테이블 여부 확인요망): " + e.getMessage());
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return result;
    }

    // =========================================================
    // [추가 기능] 행동 이력 남기고 실제 카운트 증가시키기
    // =========================================================
    public void recordActionAndIncreaseCount(int postId, String userId, String actionType) {
        Connection conn = null;
        PreparedStatement pstmt1 = null;
        PreparedStatement pstmt2 = null;
        
        String insertHistorySql = "INSERT INTO board_history (post_id, user_id, action_type, reg_date) VALUES (?, ?, ?, sysdate)";
        String updateCountSql = "";
        
        if ("VIEW".equals(actionType)) {
            updateCountSql = "UPDATE board SET view_count = view_count + 1 WHERE post_id = ?";
        } else if ("LIKE".equals(actionType)) {
            updateCountSql = "UPDATE board SET like_count = like_count + 1 WHERE post_id = ?";
        } else if ("DISLIKE".equals(actionType)) {
            updateCountSql = "UPDATE board SET dislike_count = dislike_count + 1 WHERE post_id = ?";
        } else if ("REPORT".equals(actionType)) {
            updateCountSql = "UPDATE board SET report_count = report_count + 1 WHERE post_id = ?";
        }

        try {
            conn = getConnection();
            conn.setAutoCommit(false); 
            
            pstmt1 = conn.prepareStatement(insertHistorySql);
            pstmt1.setInt(1, postId);
            pstmt1.setString(2, userId);
            pstmt1.setString(3, actionType);
            pstmt1.executeUpdate();
            
            if (!updateCountSql.isEmpty()) {
                pstmt2 = conn.prepareStatement(updateCountSql);
                pstmt2.setInt(1, postId);
                pstmt2.executeUpdate();
            }
            
            conn.commit(); 
            
        } catch (Exception e) {
            if (conn != null) try { conn.rollback(); } catch (Exception ex) {} 
            e.printStackTrace();
        } finally {
            if (pstmt2 != null) try { pstmt2.close(); } catch (Exception e) {}
            closeResources(conn, pstmt1, null);
        }
    }
 
    // =========================================================
    // [11. 총 게시글 수 계산 (건의글, 공지사항 숨김)]
    // =========================================================
    public int getTotalPostCount(String boardType, String category, String searchType, String searchKeyword, String status) {
        int count = 0;
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM board WHERE 1=1 ");
        
        if (boardType != null && !boardType.isEmpty()) {
            sql.append(" AND board_type = ? ");
        } else {
            // 🔥 메인페이지 전체보기 등에서 건의글, 공지사항 숨김
            sql.append(" AND (board_type NOT IN ('SUGGESTION', 'SUGGESTION', 'NOTICE') OR board_type IS NULL) ");
        }
        
        if (category != null && !category.isEmpty()) sql.append(" AND category = ? ");
        if (status != null && !status.isEmpty()) sql.append(" AND status = ? "); 
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            if ("title".equals(searchType)) sql.append(" AND title LIKE ? ");
            else if ("writer".equals(searchType)) sql.append(" AND writer LIKE ? ");
            else if ("content".equals(searchType)) sql.append(" AND content LIKE ? ");
        }

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            
            if (boardType != null && !boardType.isEmpty()) pstmt.setString(idx++, boardType);
            if (category != null && !category.isEmpty()) pstmt.setString(idx++, category);
            if (status != null && !status.isEmpty()) pstmt.setString(idx++, status);
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                pstmt.setString(idx++, "%" + searchKeyword.trim() + "%");
            }
            
            rs = pstmt.executeQuery();
            if (rs.next()) count = rs.getInt(1);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return count;
    }

    // 💡 호환성용 메서드
    public int getTotalPostCount(String boardType, String category, String searchType, String searchKeyword) {
        return getTotalPostCount(boardType, category, searchType, searchKeyword, "");
    }

    // =========================================================
    // [12. 게시글 목록 조회 (건의글, 공지사항 숨김 + 정렬 완벽 지원)]
    // =========================================================
    public List<BoardDTO> getPostList(int startRow, String boardType, String category, String sort, String searchType, String searchKeyword, String status) {
        List<BoardDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        int pageSize = 10; 

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT * FROM ( ");
        sql.append("    SELECT rownum rnum, A.* FROM ( ");
        sql.append("        SELECT b.*, (SELECT COUNT(*) FROM board_reply r WHERE r.post_id = b.post_id) as commentCount ");
        sql.append("        FROM board b WHERE 1=1 ");
        
        sql.append("        AND (b.is_blind IS NULL OR b.is_blind != 'Y') ");
        
        if (boardType != null && !boardType.isEmpty()) {
            sql.append(" AND b.board_type = ? ");
        } else {
            sql.append(" AND (b.board_type NOT IN ('SUGGESTION', 'SUGGESTION', 'NOTICE') OR b.board_type IS NULL) ");
        }
        
        if (category != null && !category.isEmpty()) sql.append(" AND b.category = ? ");
        if (status != null && !status.isEmpty()) sql.append(" AND b.status = ? "); 
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            if ("title".equals(searchType)) sql.append(" AND b.title LIKE ? ");
            else if ("writer".equals(searchType)) sql.append(" AND b.writer LIKE ? ");
            else if ("content".equals(searchType)) sql.append(" AND b.content LIKE ? ");
        }
        
        if ("views".equals(sort)) {
            sql.append(" ORDER BY b.view_count DESC, b.post_id DESC ");
        } else if ("recommend".equals(sort)) {
            sql.append(" ORDER BY b.like_count DESC, b.post_id DESC "); 
        } else {
            sql.append(" ORDER BY b.post_id DESC "); 
        }
        
        sql.append("    ) A ");
        sql.append(") WHERE rnum >= ? AND rnum <= ? ");

        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql.toString());
            int idx = 1;
            
            if (boardType != null && !boardType.isEmpty()) pstmt.setString(idx++, boardType);
            if (category != null && !category.isEmpty()) pstmt.setString(idx++, category);
            if (status != null && !status.isEmpty()) pstmt.setString(idx++, status);
            if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
                pstmt.setString(idx++, "%" + searchKeyword.trim() + "%");
            }
            
            pstmt.setInt(idx++, startRow);
            pstmt.setInt(idx++, startRow + pageSize - 1);
            
            rs = pstmt.executeQuery();
            while (rs.next()) {
                BoardDTO dto = new BoardDTO();
                dto.setPost_id(rs.getInt("post_id"));
                dto.setBoard_type(rs.getString("board_type"));
                dto.setCategory(rs.getString("category"));
                dto.setTitle(rs.getString("title"));
                dto.setWriter(rs.getString("writer"));
                dto.setReg_date(rs.getTimestamp("reg_date"));
                dto.setView_count(rs.getInt("view_count"));
                dto.setLike_count(rs.getInt("like_count"));
                dto.setDislike_count(rs.getInt("dislike_count"));
                dto.setReport_count(rs.getInt("report_count"));
                dto.setStatus(rs.getString("status")); 
                dto.setCommentCount(rs.getInt("commentCount"));
                dto.setFile_name(rs.getString("file_name")); 
                
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return list;
    }

    // 💡 호환성용 메서드
    public List<BoardDTO> getPostList(int startRow, String boardType, String category, String sort, String searchType, String searchKeyword) {
        return getPostList(startRow, boardType, category, sort, searchType, searchKeyword, "");
    }
    
    // ==========================================
    // [13. 통합 관리자용 목록 조회 (페이징 포함)]
    // ==========================================
    public List<BoardDTO> getBoardList(String boardType, int startRow, int pageSize) {
        List<BoardDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        String sql = "SELECT * FROM (" +
                     "    SELECT rownum rnum, A.* FROM (" +
                     "        SELECT * FROM board WHERE board_type = ? ORDER BY ref DESC, re_step ASC" +
                     "    ) A" +
                     ") WHERE rnum >= ? AND rnum <= ?";
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, boardType);
            pstmt.setInt(2, startRow);
            pstmt.setInt(3, startRow + pageSize - 1);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                BoardDTO dto = new BoardDTO();
                dto.setPost_id(rs.getInt("post_id"));
                dto.setTitle(rs.getString("title"));
                dto.setWriter(rs.getString("writer"));
                dto.setReg_date(rs.getTimestamp("reg_date"));
                dto.setIs_blind(rs.getString("is_blind"));
                dto.setRe_level(rs.getInt("re_level"));
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return list;
    }
    
	public void updateBoardAdmin(int postId, String title, String content) {
	    // 관리자용 수정 쿼리: 제목과 내용을 업데이트합니다.
	    String sql = "UPDATE board SET title = ?, content = ? WHERE post_id = ?";
	    
	    try (Connection conn = getConn(); 
	         PreparedStatement pstmt = conn.prepareStatement(sql)) {
	        
	        pstmt.setString(1, title);
	        pstmt.setString(2, content);
	        pstmt.setInt(3, postId);
	        
	        pstmt.executeUpdate();
	        
	    } catch (Exception e) {
	        e.printStackTrace();
	    }
	}
    
    // 조회수 증가 메서드 (상세페이지 진입 시 호출하면 좋음)
    public void updateViewCount(int postId) {
        String sql = "UPDATE board SET view_count = view_count + 1 WHERE post_id = ?";
        try (Connection conn = getConn(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, postId);
            pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 회원 상태/권한 변경은 관리자 도메인의 책임이므로 AdminDAO.updateMember() 로 일원화
    // (기존에 이 클래스에 있던 동일 기능의 미사용 메서드는 중복 제거 목적으로 삭제)

    // ==========================================
    // [14. 블라인드 게시글 목록 조회 (신고 5회 이상 또는 수동 블라인드)]
    // ==========================================
    public List<BoardDTO> getBlindBoardList(int startRow, int pageSize) {
        List<BoardDTO> list = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        // 💡 핵심 로직: report_count가 5 이상이거나 관리자가 강제 블라인드(is_blind='Y') 처리한 글만 모아서 최근 글부터(post_id DESC) 가져옵니다.
        String sql = "SELECT * FROM (" +
                     "    SELECT rownum rnum, A.* FROM (" +
                     "        SELECT * FROM board WHERE report_count >= 5 OR is_blind = 'Y' ORDER BY post_id DESC" +
                     "    ) A" +
                     ") WHERE rnum >= ? AND rnum <= ?";
        
        try {
            conn = getConnection();
            pstmt = conn.prepareStatement(sql);
            
            // 기존 getBoardList 메서드처럼 페이징 처리를 위한 rownum 세팅
            pstmt.setInt(1, startRow);
            pstmt.setInt(2, startRow + pageSize - 1);
            rs = pstmt.executeQuery();
            
            // ResultSet으로 가져온 DB 데이터를 Java 객체(BoardDTO)로 매핑
            while(rs.next()) {
                BoardDTO dto = new BoardDTO();
                dto.setPost_id(rs.getInt("post_id"));
                dto.setTitle(rs.getString("title"));
                dto.setWriter(rs.getString("writer"));
                dto.setReg_date(rs.getTimestamp("reg_date"));
                dto.setIs_blind(rs.getString("is_blind"));
                
                // 신고 횟수와 게시판 타입도 화면에 필요할 수 있으므로 담아줍니다.
                dto.setReport_count(rs.getInt("report_count")); 
                dto.setBoard_type(rs.getString("board_type"));
                
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return list;
    }
    

}