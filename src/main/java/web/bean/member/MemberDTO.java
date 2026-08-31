package web.bean.member;

import java.sql.Timestamp;

/*
-- 회원 테이블 생성
create table member(
id		varchar2(20)	primary key,				// 아이디
pw		varchar2(100)	not null,					// 비번
name	varchar2(20)	not null,					// 이름
birth	date			not null,					// 생년월일
phone	varchar2(20)	not null,					// 전화번호
gender	varchar2(20)	not null,					// 성별
email	varchar2(30)	not null,					// 이메일
reg		date			default sysdate,			// 가입일
status	number			default 1	not null,		// 상태 - 정상 : 1, 탈퇴 : 0, 정지 : -1
role	varchar2(20)	not null	default 'USER'	// 권한 - 일반 : USER, 관리자 : ADMIN
); 
commit;
*/

public class MemberDTO {		// 회원
	
	private String id;			// 아이디
	private String pw;			// 비밀번호
	private String name;		// 이름
	private String birth;		// 생년월일
	private String phone;		// 전화번호
	private String gender;		// 성별
	private String email;		// 이메일
	private Timestamp reg;		// 가입일
	private int status;			// 회원 상태 - 정상 : 1, 탈퇴 : 0, 정지 : -1
	private String role;		// 권한
	
	// 자동 로그인, DB에 없음
	private String auto;
	
	private int blindCount;
	
	
	// 자동 로그인 setter() / getter() 
	public void setAuto( String auto ) {
		this.auto = auto;
	}
	public String getAuto() {
		return auto;
	}
	
	// member setter()
	public void setId( String id ) {
		this.id = id;
	}
	public void setPw( String pw ) {
		this.pw = pw;
	}
	public void setName( String name ) {
		this.name = name;
	}
	public void setBirth( String birth ) {
		this.birth = birth;
	}
	public void setPhone( String phone ) {
		this.phone = phone;
	}
	public void setGender( String gender ) {
		this.gender = gender;
	}
	public void setEmail( String email ) {
		this.email = email;
	}
	public void setReg( Timestamp reg ) {
		this.reg = reg;
	}
	public void setStatus( int status ) {
		this.status = status;
	}
	public void setRole( String role ) {
		this.role = role;
	}
	
	public void setBlindCount(int blindCount) { 
		this.blindCount = blindCount; 
	}
	
	// member getter()
	public String getId() {
		return id;
	}
	public String getPw() {
		return pw;
	}
	public String getName() {
		return name;
	}
	public String getBirth() {
		return birth;
	}
	public String getPhone() {
		return phone;
	}
	public String getGender() {
		return gender;
	}
	public String getEmail() {
		return email;
	}
	public Timestamp getReg() {
		return reg;
	}
	public int getStatus() {
		return status;
	}
	public String getRole() {
		return role;
	}
	public int getBlindCount() { 
		return blindCount; 
	}
	
}
