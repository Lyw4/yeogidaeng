package web.bean.board;

import java.sql.Timestamp;

public class ReplyDTO {
    private int replyId;			// board 테이블과 똑같이 자동 증가 적용
    private int postId;				// 어떤 게시글에 달린 댓글인지 구분
    private String content;			// 댓글 내용
    private String writer;			// 댓글 작성자
    private Timestamp regDate;		// 댓글 작성일
    private String fileName; 		// 파일명
    private int parentReplyId;		// 부모 댓글 ID
    private int depth;				// 댓글 깊이
    private int replyGroup;			// 같은 그룹끼리 묶을 번호 
    
    // 마이페이지 목록에서 원본 글의 카테고리를 보여주기 위한 변수
    private String category;
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    // Getter / Setter
    public int getReplyId() { return replyId; }
    public void setReplyId(int replyId) { this.replyId = replyId; }

    public int getPostId() { return postId; }
    public void setPostId(int postId) { this.postId = postId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }

    public Timestamp getRegDate() { return regDate; }
    public void setRegDate(Timestamp regDate) { this.regDate = regDate; }
    
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    
    public int getParentReplyId() { return parentReplyId; }
    public void setParentReplyId(int parentReplyId) { this.parentReplyId = parentReplyId; }
    
    public int getDepth() { return depth; }
    public void setDepth(int depth) { this.depth = depth; }
    
    public int getReplyGroup() { return replyGroup; }
    public void setReplyGroup(int replyGroup) { this.replyGroup = replyGroup; }
}