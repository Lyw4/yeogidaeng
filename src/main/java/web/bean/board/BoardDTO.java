package web.bean.board;

import java.sql.Timestamp;

public class BoardDTO {
    // === 기존 게시판 컬럼 변수들 (우리의 뱀 표기법 규격 유지) ===
    private int post_id;
    private String board_type;
    private String category;
    private String title;
    private String content;
    private String writer;
    private Timestamp reg_date; 
    private int view_count;
    private int like_count;
    private int dislike_count;
    private int report_count;
    private int is_reported;
    private String file_name;
    private int CommentCount;
    // 2. QnA(건의사항) 및 답글 전용 변수
    private int ref;
    private int re_step;
    private int re_level;
    private String image_file; 
    private String is_blind;   
    
    // 문의 사항 답변 상태
    private String status;			

    // ======== Getter & Setter ========
    public int getPost_id() { return post_id; }
    public void setPost_id(int post_id) { this.post_id = post_id; }
    
    public String getBoard_type() { return board_type; }
    public void setBoard_type(String board_type) { this.board_type = board_type; }
    
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
   
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    
    public String getWriter() { return writer; }
    public void setWriter(String writer) { this.writer = writer; }
    
    public Timestamp getReg_date() { return reg_date; }
    public void setReg_date(Timestamp reg_date) { this.reg_date = reg_date; }
    
    public int getView_count() { return view_count; }
    public void setView_count(int view_count) { this.view_count = view_count; }
    
    public int getLike_count() { return like_count; }
    public void setLike_count(int like_count) { this.like_count = like_count; }
    
    public int getDislike_count() { return dislike_count; }
    public void setDislike_count(int dislike_count) { this.dislike_count = dislike_count; }
    
    public int getReport_count() { return report_count; }
    public void setReport_count(int report_count) { this.report_count = report_count; }
    
    public int getIs_reported() { return is_reported; }
    public void setIs_reported(int is_reported) { this.is_reported = is_reported; }

    public String getFile_name() { return file_name; }
    public void setFile_name(String file_name) { this.file_name = file_name; }

    public String getImage_file() { return image_file; }
    public void setImage_file(String image_file) { this.image_file = image_file; }
    
    public String getIs_blind() { return is_blind; }
    public void setIs_blind(String is_blind) { this.is_blind = is_blind; }
    
    public int getRef() { return ref; }
    public void setRef(int ref) { this.ref = ref; }
    
    public int getRe_step() { return re_step; }
    public void setRe_step(int re_step) { this.re_step = re_step; }
    
    public int getRe_level() { return re_level; }
    public void setRe_level(int re_level) { this.re_level = re_level; }

    // 🌟 [팀원 추가분 Getter/Setter]
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public int getCommentCount() { return CommentCount; }
    public void setCommentCount(int commentCount) { this.CommentCount = commentCount; }
}