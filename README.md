# 여기댕 - 우리 동네 댕댕이 커뮤니티

반려동물 보호자를 위한 지역 기반 커뮤니티 웹 서비스입니다.
병원 / 미용 / 호텔 / 놀거리 4개 주제 게시판과 공지사항, 건의사항을 운영하며,
회원 권한 분리와 신고 및 블라인드 누적에 따른 자율 정화 기능을 갖추고 있습니다.

- 개발 기간 : 2026.06.16 ~ 2026.06.24 (약 2주, 팀 프로젝트)
- 규모 : JSP 63본, Java 클래스 10본, 약 10,700줄

## 기술 스택

| 구분 | 사용 기술 |
|---|---|
| Language | Java 21 |
| Backend | JSP / Servlet (Model 1), JDBC, DAO · DTO 패턴 |
| Database | Oracle |
| Frontend | HTML5, CSS3, Vanilla JavaScript (Fetch API) |
| Library | ojdbc17 (JDBC 드라이버), cos.jar (파일 업로드) |
| Server / Tool | Apache Tomcat 9.0, Eclipse, SQL Developer, Git |

## 주요 기능

### 회원
- 회원가입 : 정규표현식 유효성 검사 + Fetch API 기반 아이디 중복 확인
- 로그인 : 세션 기반 인증, 쿠키 기반 자동 로그인(유효기간 7일)
- 아이디 / 비밀번호 찾기, 회원정보 수정
- 회원 탈퇴 : 물리 삭제 대신 상태값 변경(Soft Delete)으로 작성 이력 보존
- 상태값 : 정상 `1` / 탈퇴 `0` / 정지 `-1`, 권한 : `USER` / `ADMIN`

### 게시판
- 게시글 CRUD 및 이미지 첨부 (용량 제한, 중복 파일명 자동 리네임)
- 검색(제목 · 내용 · 작성자), 정렬(최신순 · 조회순 · 추천순), 카테고리 필터
- Oracle `rownum` 중첩 서브쿼리 기반 페이징 (10건 단위, 5개 단위 페이지 블록)
- 계층형 댓글 : `reply_group` · `depth` · `parent_reply_id` 조합으로 무한 깊이 대댓글
- 조회수 · 추천 · 비추천 · 신고 중복 방지 : 이력 테이블 + 트랜잭션 처리

### 관리자
- 회원 목록 조회 및 상태 · 권한 일괄 변경
- 공지사항 CRUD, 상단 고정(PIN) 우선 정렬
- 건의사항 답변 관리 및 미답변 건수 집계
- 신고 누적 / 블라인드 게시글 관리
- 신고 5회 누적 → 자동 블라인드 → 블라인드 5건 누적 → 작성자 자동 정지

### 메인
- JSON 응답 엔드포인트와 Fetch API 연동으로 목록 · 검색 · 정렬 비동기 처리
- 조회수 상위 8건 인기글 캐러셀

## 프로젝트 구조

```
mini
├── src/main/java
│   ├── db.properties            # DB 접속 정보 (git 제외 대상)
│   ├── db.properties.example    # 접속 정보 템플릿
│   └── web/bean
│       ├── admin                # DBConnection, AdminDAO
│       ├── board                # BoardDAO, BoardDTO, ReplyDAO, ReplyDTO, QnaReplyDTO
│       └── member               # MemberDAO, MemberDTO, MyBoardDAO
└── src/main/webapp
    ├── WEB-INF                  # web.xml, lib (git 제외 대상)
    └── views
        ├── admin                # 관리자 페이지
        ├── board                # 게시판
        ├── components           # 공통 header / footer
        ├── css, js              # 정적 자원
        ├── main                 # 메인 페이지, JSON 엔드포인트
        ├── member               # 회원 기능
        └── upload               # 업로드 파일 저장소 (git 제외 대상)
```

## 실행 방법

### 1. 라이브러리 준비

라이선스와 용량 문제로 JAR 파일은 저장소에 포함하지 않았습니다.
아래 두 파일을 `src/main/webapp/WEB-INF/lib` 에 넣어주세요.

| 파일 | 용도 | 다운로드 |
|---|---|---|
| `ojdbc17.jar` | Oracle JDBC 드라이버 | [Oracle JDBC 다운로드](https://www.oracle.com/database/technologies/appdev/jdbc-downloads.html) |
| `cos.jar` | 파일 업로드 (MultipartRequest) | [O'Reilly COS](http://www.servlets.com/cos/) |

### 2. DB 접속 정보 설정

`src/main/java/db.properties.example` 을 같은 위치에 `db.properties` 로 복사한 뒤 값을 채웁니다.

```properties
db.driver=oracle.jdbc.driver.OracleDriver
db.url=jdbc:oracle:thin:@localhost:1521:orcl
db.user=계정명
db.password=비밀번호
```

`db.properties` 는 `.gitignore` 에 등록되어 있어 커밋되지 않습니다.
접속 정보를 소스에 직접 적지 않도록 주의해 주세요.

### 3. 테이블 생성

Oracle 계정에 아래 테이블과 시퀀스가 필요합니다.

| 테이블 | 용도 | 주요 컬럼 |
|---|---|---|
| `member` | 회원 | `id`, `pw`, `name`, `birth`, `phone`, `gender`, `email`, `reg`, `status`, `role` |
| `board` | 게시글 · 공지 · 건의사항 | `post_id`, `board_type`, `category`, `title`, `content`, `writer`, `reg_date`, `view_count`, `like_count`, `dislike_count`, `report_count`, `is_reported`, `is_blind`, `file_name`, `image_file`, `status`, `ref`, `re_step`, `re_level` |
| `board_reply` | 계층형 댓글 | `reply_id`, `post_id`, `content`, `writer`, `reg_date`, `parent_reply_id`, `depth`, `reply_group` |
| `board_history` | 조회 · 추천 · 신고 이력 | `post_id`, `user_id`, `action_type`, `reg_date` |
| `board_seq` | 게시글 번호 시퀀스 | - |

`member` 테이블 생성 스크립트는 `MemberDTO.java` 상단 주석에 있습니다.

### 4. 서버 실행

Eclipse 에서 Apache Tomcat 9.0 서버에 프로젝트를 추가하고 실행합니다.

```
http://localhost:8080/mini/views/main/mainPage.jsp
```

컨텍스트 경로는 `/mini` 기준입니다. 다르게 배포하는 경우
`src/main/webapp/views/js/main.js` 의 `ctx` 값을 함께 수정해야 합니다.
