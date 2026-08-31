package web.bean.board;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

// 🔥 에러 해결 1: BoardDAO처럼 통합 DBConnection을 가져오기 위한 패키지 임포트!
import web.bean.admin.DBConnection;

// 🔥 에러 해결 2: DBConnection을 상속(extends)받아서 내 것처럼 씁니다.
public class ReplyDAO extends DBConnection {
    
    // 🔥 에러 해결 3: 기존의 잘못된 아이디/비밀번호를 싹 지우고, 통합 관리자의 getConn()을 불러옵니다!
    private Connection getConnection() throws Exception {
        return getConn(); 
    }

    // 1. [핵심] 댓글/대댓글 저장 (계층형 로직 포함)
    public int insertReply(ReplyDTO dto) {
        // 일반 댓글이면 새로운 그룹번호 생성, 대댓글이면 부모의 그룹번호를 조회해서 사용
        String sql = "INSERT INTO BOARD_REPLY (post_id, content, writer, parent_reply_id, depth, reply_group) " +
                     "VALUES (?, ?, ?, ?, ?, " +
                     "CASE WHEN ? = 0 THEN (SELECT NVL(MAX(reply_group), 0) + 1 FROM BOARD_REPLY) " +
                     "ELSE (SELECT reply_group FROM BOARD_REPLY WHERE reply_id = ?) END)";
        
        int result = 0;
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, dto.getPostId());
            pstmt.setString(2, dto.getContent());
            pstmt.setString(3, dto.getWriter());
            pstmt.setInt(4, dto.getParentReplyId());
            pstmt.setInt(5, dto.getDepth());
            pstmt.setInt(6, dto.getParentReplyId()); // CASE 조건
            pstmt.setInt(7, dto.getParentReplyId()); // 서브쿼리 조건
            
            result = pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    // 2. [핵심] 댓글 목록 조회 (계층형 정렬)
    public List<ReplyDTO> getReplyList(int postId) {
        List<ReplyDTO> list = new ArrayList<>();
        // 같은 그룹(reply_group) 내에서 부모 댓글이 항상 위에 오도록 정렬
        String sql = "SELECT * FROM BOARD_REPLY WHERE post_id = ? " +
                     "ORDER BY reply_group ASC, depth ASC, reg_date ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, postId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ReplyDTO dto = new ReplyDTO();
                    dto.setReplyId(rs.getInt("reply_id"));
                    dto.setPostId(rs.getInt("post_id"));
                    dto.setContent(rs.getString("content"));
                    dto.setWriter(rs.getString("writer"));
                    dto.setRegDate(rs.getTimestamp("reg_date"));
                    dto.setParentReplyId(rs.getInt("parent_reply_id"));
                    dto.setDepth(rs.getInt("depth"));
                    dto.setReplyGroup(rs.getInt("reply_group"));
                    list.add(dto);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    // ==========================================
    // [추가 기능] 내가 쓴 댓글 수정 기능
    // ==========================================
    public void updateReply(int replyId, String content) {
        String sql = "UPDATE BOARD_REPLY SET content = ? WHERE reply_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, content);
            pstmt.setInt(2, replyId);
            pstmt.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // ==========================================
    // [추가 기능] 내가 쓴 댓글 삭제 기능
    // ==========================================
    public void deleteReply(int replyId) {
        String sql = "DELETE FROM BOARD_REPLY WHERE reply_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, replyId);
            pstmt.executeUpdate();
            
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 🔥 건의사항 및 게시글의 댓글(답변) 목록을 가져오는 메서드 추가!
    public List<ReplyDTO> getReplies(int postId) {
        List<ReplyDTO> list = new ArrayList<>();
        
        // 1. ORDER BY 수정: 그룹별로 묶고, 깊이 순서대로 정렬하여 계층 구조 유지
        String sql = "SELECT * FROM board_reply WHERE post_id = ? ORDER BY reply_group ASC, depth ASC, reg_date ASC";
        
        try (Connection conn = getConn(); 
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, postId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    ReplyDTO reply = new ReplyDTO();
                    // 2. 모든 필수 필드 매핑 (DTO의 모든 값을 가져와야 함)
                    reply.setReplyId(rs.getInt("reply_id"));
                    reply.setPostId(rs.getInt("post_id"));
                    reply.setWriter(rs.getString("writer"));
                    reply.setContent(rs.getString("content"));
                    reply.setRegDate(rs.getTimestamp("reg_date"));
                    
                    // [중요] 대댓글 계층 정보 매핑
                    reply.setParentReplyId(rs.getInt("parent_reply_id"));
                    reply.setDepth(rs.getInt("depth"));
                    reply.setReplyGroup(rs.getInt("reply_group"));
                    
                    list.add(reply);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}