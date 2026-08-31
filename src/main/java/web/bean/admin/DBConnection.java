package web.bean.admin;

// import
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;

/*
	DB 연결 공통 클래스 (각 DAO 가 상속해서 사용)
	
	접속 정보는 소스에 직접 적지 않고 클래스패스의 db.properties 에서 읽어온다.
	- 개발 환경마다 접속 주소/계정이 다른데 소스를 고치지 않아도 되고
	- 계정과 비밀번호가 저장소(GitHub)에 올라가지 않는다.
	
	파일 위치 : src/main/java/db.properties
	           -> 빌드 후 build/classes/db.properties
	           -> 배포 후 WEB-INF/classes/db.properties
	
	최초 설정 : db.properties.example 을 복사해서 db.properties 로 이름을 바꾸고 값을 채운다.
*/
public class DBConnection {

	// 접속 설정 파일명 (클래스패스 최상단 기준)
	private static final String CONFIG_FILE = "db.properties";

	// 설정값 보관용 - 파일은 요청마다 읽지 않고 최초 1회만 읽어서 재사용
	private static Properties config = null;

	// 드라이버 중복 로딩 방지 플래그
	private static boolean driverLoaded = false;

	/*
		========================================
		설정 파일 읽기 (최초 호출 시 1회만 수행)
		========================================
	*/
	private static synchronized Properties getConfig() throws Exception {
		if (config != null) {
			return config;
		}

		Properties loaded = new Properties();

		// 클래스로더로 클래스패스에서 찾기 -> 톰캣 배포 후에도 경로가 깨지지 않는다
		try (InputStream in = DBConnection.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {

			if (in == null) {
				throw new IllegalStateException(
						CONFIG_FILE + " 파일을 클래스패스에서 찾을 수 없습니다. "
						+ "db.properties.example 을 복사해 src/main/java/db.properties 로 만들고 접속 정보를 채워주세요.");
			}

			loaded.load(in);

		} catch (IOException e) {
			throw new IllegalStateException(CONFIG_FILE + " 파일을 읽는 중 오류가 발생했습니다.", e);
		}

		config = loaded;
		return config;
	}

	/*
		========================================
		필수 설정값 조회
		- 값이 없으면 "No suitable driver" 같은 모호한 에러 대신
		  어떤 항목이 비었는지 바로 알 수 있게 예외를 던진다
		========================================
	*/
	private static String getRequired(Properties props, String key) {
		String value = props.getProperty(key);

		if (value == null || value.trim().isEmpty()) {
			throw new IllegalStateException(CONFIG_FILE + " 에 " + key + " 항목이 설정되지 않았습니다.");
		}

		return value.trim();
	}

	/*
		========================================
		DB 연결 메서드
		Connection getConn() -> (Connection 객체 반환)
		========================================
	*/
	public Connection getConn() throws Exception {
		Properties props = getConfig();

		// JDBC 드라이버 로딩 (최초 1회)
		if (!driverLoaded) {
			Class.forName(getRequired(props, "db.driver"));
			driverLoaded = true;
		}

		// DB 연결
		String url = getRequired(props, "db.url");
		String user = getRequired(props, "db.user");
		String pw = getRequired(props, "db.password");

		return DriverManager.getConnection(url, user, pw);
	}

	/*
		========================================
		연결 끊기 메서드
		- 자원은 생성 순서의 역순(ResultSet -> PreparedStatement -> Connection)으로 닫는다
		========================================
	*/
	public void close(Connection conn, PreparedStatement pstmt, ResultSet rs) {
		if (   rs != null ) { try {   rs.close();} 	catch(SQLException e) { e.printStackTrace();}}
		if(pstmt != null ) { try {pstmt.close();} 	catch(SQLException e) { e.printStackTrace();}}
		if( conn != null ) { try { conn.close();} 	catch(SQLException e) { e.printStackTrace();}}
	}
}
