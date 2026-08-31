package web.bean.board;

import java.sql.Timestamp;

public class QnaReplyDTO {		// 건의사항 답글용
	private int replyNo;		// 답글 번호
	private int post_id;		// 문의글 번호 (어떤 건의글에 대한 답인지)
	private String content;		// 답글 내용
	private String writer;		// 관리자 id
	private Timestamp regDate;	// 답글 작성일
	
	public void setReplyNo(int replyNo) {this.replyNo = replyNo;}
	public int getReplyNo() {return replyNo;}
	
	public void setPost_id(int post_id) {this.post_id = post_id;}
	public int getPost_id() {return post_id;}
	
	public void setContent(String content) {this.content = content;}
	public String getContent() {return content;}
	
	public void setWriter(String writer) {this.writer = writer;}
	public String getWriter() {return writer;}
	
	public void setRegDate(Timestamp regDate) {this.regDate = regDate;}
	public Timestamp getRegDate() {return regDate;}

}
