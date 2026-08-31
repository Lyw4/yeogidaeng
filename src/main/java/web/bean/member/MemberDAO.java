package web.bean.member;

/*
 	DB와 직접 소통하는 객체
 	DBConnection 클래스로 연결 / 끊기
*/

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import web.bean.admin.DBConnection;

public class MemberDAO extends DBConnection {	// 상속
	
	
	// 1. 핵심: 기존에 20개 JSP가 쓰던 "new MemberDAO()"를 허용해 줍니다. (private으로 막지 않음)
    // 대신, new를 호출해도 내부적으로는 늘 "동일한 공유 자원"을 바라보게 static으로 통제합니다.
    private static MemberDAO instance = new MemberDAO();
    
    // 유일한 인스턴스 반환하는 메서드
    public static MemberDAO getInstance() {
        return instance;
    }

    // private 생성자
    public MemberDAO() {}
    
    private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	private String sql;
	
/* 	
  	========================================
	회원가입 (INSERT) 
	========================================
*/
	public void insertMember( MemberDTO dto ) {
		 try {
			conn = getConn();
			// status 컬럼 기본값 규칙 통일 반영 (정상 회원 : 1, 탈퇴 회원 : 0, 정지 회원 : -1)
			sql = "insert into member values(?,?,?,TO_DATE(?,'YYYY-MM-DD'),?,?,?,sysdate,1,'USER')";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, dto.getId());
			pstmt.setString(2, dto.getPw());
			pstmt.setString(3, dto.getName());
			pstmt.setString(4, dto.getBirth());
			pstmt.setString(5, dto.getPhone());
			pstmt.setString(6, dto.getGender());
			pstmt.setString(7, dto.getEmail());
			
			pstmt.executeUpdate();

		 } catch (Exception e) {
			e.printStackTrace();
		 } finally {
			 close(conn, pstmt, rs);
		 }
	}
	
/* 	
  	========================================
	아이디 중복 확인 유효성 검사 (SELECT)
	========================================
*/
	public boolean checkId( String id ) {
		boolean isExist = false;
		
		try {
			conn = getConn();
			sql = "select * from member where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
			
			if( rs.next() ) {	
				isExist = true;	
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, rs);
		}
		
		return isExist;
	}
	
/* 	
  	========================================
	로그인 (SELECT) 
	========================================
*/ 	
	public String loginCheck(MemberDTO dto){
		String result = "FAIL";		
			
		try {
			conn = getConn();
			// 🔥 1. select 문에 role 컬럼 추가!
			sql = "select pw, status, role from member where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, dto.getId());
			rs = pstmt.executeQuery();
			
			if( rs.next() ) {
				String dbPw = rs.getString("pw");
				int dbStatus = rs.getInt("status");
				String dbRole = rs.getString("role"); // 🔥 2. 권한 정보 꺼내기!
				
				if(dbStatus == 0) {
					result = "WITHDRAWN";	
				} else if(dbStatus == -1) {
					result = "SUSPENDED"; 
				} else if( dbPw.equals(dto.getPw())) {
					result = "SUCCESS";	 
					
					// 🔥 3. 로그인 성공 시 DTO에 권한 정보 담아주기!
					dto.setRole(dbRole); 
					
				} else {
					result = "WRONG_PW"; 
				}
			} else {
				result = "NOT_FOUND";	
			}
		} catch (Exception e) {
			e.printStackTrace();
			result = "ERROR";
		} finally {
			close(conn, pstmt, rs);
		}
			
		return result;
	}
	
/* 	
  	========================================
	아이디 찾기 (SELECT) - name, email
	========================================
*/
	public String findId( String name, String email ) {		
		String foundId = null;	
			
		try {
			conn = getConn();
			sql = "select id from member where name = ? and email = ? and status = 1";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, name);
			pstmt.setString(2, email);
			rs = pstmt.executeQuery();
				
			if( rs.next() ) {
				foundId = rs.getString("id");
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, rs);
		}
			
		return foundId;		
	}
		
/* 	
  	========================================
	비밀번호 재설정(SELECT) - id, name, email 
	========================================
*/
	public boolean checkMemberForPw( String id, String name, String email ) {	
		boolean isExist = false;
			
		try {
			conn = getConn();
			sql = "select id from member where id = ? and name = ? and email = ? and status = 1";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			pstmt.setString(2, name);
			pstmt.setString(3, email);
			rs = pstmt.executeQuery();
				
			if( rs.next() ) {
				isExist = true;		
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, rs);
		}
		return isExist;
	}
		
/* 	
  	========================================
 	비밀번호 -> 임시 비밀번호 변경 (UPDATE)
	========================================
*/
	public int updatePw( String id, String newPw ) {	
		int result = 0;
			
		try {
			conn = getConn();
			sql = "update member set pw = ? where id = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, newPw);
			pstmt.setString(2, id);
			result = pstmt.executeUpdate();		
				
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, null);
		}
			
		return result;
	}
		
/* 	
  	========================================
	내 정보 조회 (SELECT) 
	========================================
*/
	public MemberDTO idInfo(String id) {
		MemberDTO dto = new MemberDTO();
			
		try {
			conn = getConn();
			sql = "select * from member where id = ? and status = 1";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, id);
			rs = pstmt.executeQuery();
				
			if( rs.next() ) {
				dto.setId(rs.getString("id"));
				dto.setPw(rs.getString("pw"));
				dto.setName(rs.getString("name"));
				dto.setBirth(rs.getString("birth"));
				dto.setPhone(rs.getString("phone"));
				dto.setGender(rs.getString("gender"));
				dto.setEmail(rs.getString("email"));
				dto.setReg(rs.getTimestamp("reg"));
				dto.setRole(rs.getString("role"));
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, rs);
		}
			
		return dto;
	}
		
/* 	
  	========================================
	회원 탈퇴 (UPDATE) - status = 0 (탈퇴 회원)
	========================================
*/
	public int deleteMember(String id) {
		int result = 0;

		try {
			conn = getConn(); 
		    sql = "update member set status = 0 where id = ?";
		    pstmt = conn.prepareStatement(sql);
		    pstmt.setString(1, id);
		        
		    result = pstmt.executeUpdate(); 
		        
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, rs); 
		}
		    
		return result;
	}
	
/* 	
  	========================================
	회원 정보 수정 (UPDATE) 
	========================================
*/
	public void updateMember( MemberDTO dto ) {
		try {
			conn = getConn();
			sql = "update member set pw=?, name=?, birth=?, email=?, phone=? where id=?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, dto.getPw());
			pstmt.setString(2, dto.getName());
			pstmt.setString(3, dto.getBirth());
			pstmt.setString(4, dto.getEmail());
			pstmt.setString(5, dto.getPhone());
			pstmt.setString(6, dto.getId());
			pstmt.executeUpdate();
			
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			close(conn, pstmt, rs);
		}
	}
}