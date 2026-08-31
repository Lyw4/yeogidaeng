package web.bean.admin;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import web.bean.board.BoardDTO; // 통합된 DTO 사용
import web.bean.member.MemberDTO;

public class AdminDAO extends DBConnection {
   
   // ========  공지사항 수정 실행 (Update) ========
   public int updateNotice(BoardDTO dto) {
      int result = 0;
      // 쿼리 확인: 테이블 이름이 'board'인지, 컬럼명이 맞는지 꼭 확인하세요!
      String sql = "UPDATE board SET title = ?, content = ?, category = ? WHERE post_id = ?";
      
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         
         pstmt.setString(1, dto.getTitle());
         pstmt.setString(2, dto.getContent());
         pstmt.setString(3, dto.getCategory());
         pstmt.setInt(4, dto.getPost_id()); // WHERE 조건의 post_id
         
         result = pstmt.executeUpdate(); // 쿼리 실행
      } catch (Exception e) {
         System.out.println("DAO update 에러: " + e.getMessage());
         e.printStackTrace(); 
      }
      return result;
   }
   
   // 건의사항 관리 (미답변 건수 카운트 - 댓글 방식)
      public int getPendingQnaCount() {
         // SUGGESTION 게시판 글 중에서, board_reply(댓글)에 자기 번호가 없는 글만 셉니다!
         String sql = "SELECT count(*) FROM board b " +
                      "WHERE b.board_type = 'SUGGESTION' " +
                      "AND NOT EXISTS (SELECT 1 FROM board_reply r WHERE r.post_id = b.post_id)";
         
         try (Connection conn = getConn(); 
              PreparedStatement pstmt = conn.prepareStatement(sql);
              ResultSet rs = pstmt.executeQuery()) {
            
            if (rs.next()) {
               return rs.getInt(1);
            }
         } catch (Exception e) { e.printStackTrace(); }
         return 0;
      }
   
   // 멤버 상태에 따른 권한 제한
   public int getMemberStatus(String id) {
      String sql = "SELECT status FROM member WHERE id = ?";
      
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         
         pstmt.setString(1, id);
         
         try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
               return rs.getInt("status");
            }
         }
      } catch (Exception e) {
         e.printStackTrace();
      }
      return 0; // 정보가 없거나 에러 발생 시 기본값 0(탈퇴) 반환
   }

   // ===== 1. 유저 관리 ======
   public List<MemberDTO> getAllMember() {
        List<MemberDTO> list = new ArrayList<>();
        // 서브쿼리로 해당 유저의 블라인드 글 개수를 카운트하여 blindCount 별칭으로 가져옴
        String sql = "SELECT m.*, (SELECT COUNT(*) FROM board b WHERE b.writer = m.id AND b.is_blind = 'Y') as blindCount " +
                     "FROM member m ORDER BY reg DESC";
        
        try (Connection conn = getConn(); 
             PreparedStatement pstmt = conn.prepareStatement(sql); 
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                MemberDTO dto = new MemberDTO();
                dto.setEmail(rs.getString("email"));
                dto.setReg(rs.getTimestamp("reg"));
                dto.setId(rs.getString("id"));
                dto.setName(rs.getString("name"));
                dto.setStatus(rs.getInt("status"));
                dto.setRole(rs.getString("role"));
                dto.setBlindCount(rs.getInt("blindCount")); // 💡 추가된 데이터 매핑
                list.add(dto);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

   // [통합] 회원 수정 기능 (상태와 권한을 한 번에 업데이트)
   public int updateMember(String id, int status, String role) {
      String sql = "UPDATE member SET status = ?, role = ? WHERE id = ?";
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         pstmt.setInt(1, status);
         pstmt.setString(2, role);
         pstmt.setString(3, id);
         return pstmt.executeUpdate();
      } catch (Exception e) { e.printStackTrace(); }
      return 0;
   }

   // ====== 🔥 [수정 완료] 괄호가 깨졌던 공지사항 등록 ======
   public int insertNotice(BoardDTO dto) {
      int result = 0;
      // writer를 추가하여 데이터베이스에 완벽하게 삽입합니다.
      String sql = "INSERT INTO board (post_id, board_type, title, content, category, writer, reg_date) "
                 + "VALUES (board_seq.nextval, 'NOTICE', ?, ?, ?, ?, sysdate)";
                 
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         
         pstmt.setString(1, dto.getTitle());
         pstmt.setString(2, dto.getContent());
         pstmt.setString(3, dto.getCategory());
         pstmt.setString(4, dto.getWriter()); // 💡 작성자 연결 완료!
         
         result = pstmt.executeUpdate();
      } catch (Exception e) { e.printStackTrace(); }
      
      return result;
   }

   public int deleteNotice(int boardNo) {
      String sql = "DELETE FROM board WHERE post_id = ? AND board_type='NOTICE'";
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         pstmt.setInt(1, boardNo);
         return pstmt.executeUpdate();
      } catch (Exception e) { e.printStackTrace(); }
      return 0;
   }

   // ====== 3. 건의(문의)관리 기능 ======
   public List<BoardDTO> getPendingQnaList() {
      List<BoardDTO> list = new ArrayList<>();
      String sql = "SELECT * FROM board WHERE board_type = 'QNA' AND status != 'COMPLETED' ORDER BY reg_date ASC";
      
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql);
           ResultSet rs = pstmt.executeQuery()) {
         
         while (rs.next()) {
            BoardDTO qna = new BoardDTO();
            qna.setPost_id(rs.getInt("post_id"));
            qna.setTitle(rs.getString("title"));
            qna.setWriter(rs.getString("writer"));
            qna.setReg_date(rs.getTimestamp("reg_date"));
            list.add(qna);
         }
      } catch (Exception e) { e.printStackTrace(); }
      return list;
   }

   // [수정] 기존 QnaReplyDTO 대신 BoardDTO(또는 별도 reply 테이블 DTO) 활용 권장
   public int insertQnaReply(BoardDTO reply) {
      String sql = "INSERT INTO board_reply(post_id, content, writer) VALUES(?, ?, ?)";
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         pstmt.setInt(1, reply.getPost_id());
         pstmt.setString(2, reply.getContent());
         pstmt.setString(3, reply.getWriter());
         return pstmt.executeUpdate();
      } catch (Exception e) { e.printStackTrace(); }
      return 0;
   }

   // ====== 4. 공지사항 관련 로직 통합 (수정/조회) ======
   public BoardDTO getNoticeDetail(int postId) {
      String sql = "SELECT * FROM board WHERE post_id = ? AND board_type='NOTICE'";
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql)) {
         pstmt.setInt(1, postId);
         try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
               BoardDTO notice = new BoardDTO();
               notice.setPost_id(rs.getInt("post_id"));
               notice.setTitle(rs.getString("title"));
               notice.setContent(rs.getString("content"));
               notice.setCategory(rs.getString("category"));
               
               // 💡 DB에서 작성자를 꺼내와 DTO에 담아주는 코드 추가!
               notice.setWriter(rs.getString("writer")); 
               return notice;
            }
         }
      } catch (Exception e) { e.printStackTrace(); }
      return null;
   }

   public List<BoardDTO> getAllNotices() {
      String sql = "SELECT * FROM board WHERE board_type = 'NOTICE' " +
                   "ORDER BY CASE WHEN category = 'PIN' THEN 1 ELSE 2 END, reg_date DESC";
      List<BoardDTO> list = new ArrayList<>();
      try (Connection conn = getConn(); 
           PreparedStatement pstmt = conn.prepareStatement(sql);
           ResultSet rs = pstmt.executeQuery()) {
         while (rs.next()) {
            BoardDTO b = new BoardDTO();
            b.setPost_id(rs.getInt("post_id"));
            b.setTitle(rs.getString("title"));
            b.setCategory(rs.getString("category"));
            b.setReg_date(rs.getTimestamp("reg_date"));
            
            // 💡 DB에서 작성자를 꺼내와 리스트에 담아주는 코드 추가!
            b.setWriter(rs.getString("writer")); 
            list.add(b);
         }
      } catch (Exception e) { e.printStackTrace(); }
      return list;
   }
   
   // ====== 특정 회원의 블라인드 처리된 게시글 개수 정확히 조회 ======
      public int getBlindedPostCount(String id) {
         int count = 0;
         // 💡 수정된 부분: status 컬럼 대신 is_blind = 'Y' 조건을 사용합니다.
         String sql = "SELECT count(*) FROM board WHERE writer = ? AND is_blind = 'Y'";
         
         try (Connection conn = getConn(); 
              PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, id); // 회원의 아이디를 ? 에 세팅
            
            try (ResultSet rs = pstmt.executeQuery()) {
               if (rs.next()) {
                  count = rs.getInt(1); // 카운트된 숫자를 가져옴
               }
            }
         } catch (Exception e) { 
            System.out.println("블라인드 카운트 에러: " + e.getMessage());
            e.printStackTrace(); 
         }
         
         return count;
      }
}