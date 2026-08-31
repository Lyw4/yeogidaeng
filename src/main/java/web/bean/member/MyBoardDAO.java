package web.bean.member;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import web.bean.admin.DBConnection;
import web.bean.board.BoardDTO;
import web.bean.board.ReplyDTO;

/*
	마이페이지 전용 조회 DAO
	
	[중요] 이 클래스는 싱글톤으로 공유되므로 어떤 상태도 필드로 갖지 않는다.
	Connection / PreparedStatement / ResultSet 을 필드로 두면 여러 사용자의
	요청 스레드가 같은 객체를 덮어써서 엉뚱한 데이터가 조회되거나 예외가 발생한다.
	모든 자원은 메서드 안에서 만들고 try-with-resources 로 닫는다.
*/
public class MyBoardDAO extends DBConnection {	// 상속
		
		// 유일한 인스턴스 저장할 static 변수
		private static final MyBoardDAO instance = new MyBoardDAO();
		
		// 유일한 인스턴스 반환하는 메서드
		public static MyBoardDAO getInstance() {
			return instance; 
		}
		
		// 기존 JSP 들이 new MyBoardDAO() 로도 쓸 수 있게 생성자는 열어둔다
		public MyBoardDAO() {}
		
/* 	
	  	========================================
		내 글 수 (SELECT) 
		========================================
*/
		public int boardMyCount( String id ) {
		    int result = 0;
		    String sql = "select count(*) from board where writer=? and board_type NOT IN ('SUGGESTION', 'QNA')";
		    
		    try ( Connection conn = getConn();
		          PreparedStatement pstmt = conn.prepareStatement(sql) ) {
		        
		        pstmt.setString(1, id);
		        
		        try ( ResultSet rs = pstmt.executeQuery() ) {
		            if(rs.next()) { result = rs.getInt(1); }
		        }
		    } catch (Exception e) { e.printStackTrace(); }
		    
		    return result;
		}
		
/* 	
	  	========================================
		내 글 목록 (SELECT) 
		========================================
*/
		public ArrayList<BoardDTO> boardMyList(String id, int startRow, int endRow){
		    ArrayList<BoardDTO> list = new ArrayList<>();
		    String sql = " select * from ( "
		               + "    select rownum rnum, a.* from ( "
		               + "        select * from board where writer=? and board_type NOT IN ('SUGGESTION', 'QNA') order by post_id desc "
		               + "    ) a "
		               + " ) where rnum >= ? and rnum <= ? ";
		    
		    try ( Connection conn = getConn();
		          PreparedStatement pstmt = conn.prepareStatement(sql) ) {
		        
		        pstmt.setString(1, id);
		        pstmt.setInt(2, startRow);
		        pstmt.setInt(3, endRow);
		        
		        try ( ResultSet rs = pstmt.executeQuery() ) {
		            while( rs.next() ) {
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
		                list.add(dto);
		            }
		        }
		    } catch (Exception e) { e.printStackTrace(); }
		    
		    return list;
		}
		
/* 	
	  	========================================
		내 댓글 목록 (SELECT) 
		========================================
*/
		public List<ReplyDTO> commentMyList( String id ){
			List<ReplyDTO> list = new ArrayList<>();
			
			// board_reply와 board를 post_id 기준으로 조인하여 카테고리를 함께 긁어옴
			String sql = " SELECT r.*, b.board_type as b_type, b.category as boardCategory "
	                   + " FROM board_reply r "
	                   + " INNER JOIN board b ON r.post_id = b.post_id "
	                   + " WHERE r.writer = ? "
	                   + " ORDER BY r.reply_id DESC ";
			
			try ( Connection conn = getConn();
			      PreparedStatement pstmt = conn.prepareStatement(sql) ) {
				
				pstmt.setString(1, id);
				
				try ( ResultSet rs = pstmt.executeQuery() ) {
					while (rs.next()) {
		                ReplyDTO reply = new ReplyDTO();			 	// ReplyDTO로 객체 생성
		                reply.setReplyId(rs.getInt("reply_id"));
		                reply.setPostId(rs.getInt("post_id"));
		                reply.setCategory(rs.getString("b_type"));		// 조인해온 게시판 구분 저장
		                reply.setContent(rs.getString("content"));
		                reply.setWriter(rs.getString("writer"));
		                reply.setRegDate(rs.getTimestamp("reg_date"));
		                
		                list.add(reply);
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			return list;
		}
		
/* 	
	  	========================================
		내 문의 목록 (SELECT) 
		========================================
*/
		public List<BoardDTO> boardMyQnaList(String id, int startRow, int endRow) {
		    List<BoardDTO> list = new ArrayList<>();
		    String sql = " SELECT * FROM ( "
		               + "    SELECT rownum rnum, a.* FROM ( "
		               + "        SELECT post_id, category, title, reg_date, status " 
		               + "        FROM board "
		               + "        WHERE writer = ? AND board_type IN ('SUGGESTION', 'QNA') "
		               + "        ORDER BY post_id DESC "
		               + "    ) a "
		               + " ) WHERE rnum >= ? AND rnum <= ? ";
		    
		    try ( Connection conn = getConn();
		          PreparedStatement pstmt = conn.prepareStatement(sql) ) {
		        
		        pstmt.setString(1, id);
		        pstmt.setInt(2, startRow);
		        pstmt.setInt(3, endRow);
		        
		        try ( ResultSet rs = pstmt.executeQuery() ) {
		            while( rs.next() ) {
		                BoardDTO dto = new BoardDTO();
		                dto.setPost_id(rs.getInt("post_id"));
		                dto.setCategory(rs.getString("category"));
		                dto.setTitle(rs.getString("title"));
		                dto.setReg_date(rs.getTimestamp("reg_date"));
		                
		                //  JSP 화면에 '답변완료'를 띄워주기 위해 DTO에 담아줍니다!
		                dto.setStatus(rs.getString("status")); 
		                
		                list.add(dto);
		            }
		        }
		    } catch (Exception e) { e.printStackTrace(); }
		    
		    return list;
		}
		
/* 	
	  	========================================
		내 문의 수 (SELECT) 
		========================================
*/
		public int boardMyQnaCount(String id) {
		    int result = 0;
		    String sql = "SELECT COUNT(*) FROM board WHERE writer = ? AND board_type IN ('SUGGESTION', 'QNA')";
		    
		    try ( Connection conn = getConn();
		          PreparedStatement pstmt = conn.prepareStatement(sql) ) {
		        
		        pstmt.setString(1, id);
		        
		        try ( ResultSet rs = pstmt.executeQuery() ) {
		            if (rs.next()) { result = rs.getInt(1); }
		        }
		    } catch (Exception e) { e.printStackTrace(); }
		    
		    return result;
		}
		
}
