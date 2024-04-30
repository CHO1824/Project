<%@ page import="org.apache.commons.logging.*" %>
 
<%@ page import="com.tobesoft.xplatform.data.*" %>
<%@ page import="com.tobesoft.xplatform.tx.*" %>
<%@ page import="com.tobesoft.xplatform.data.datatype.*" %>  

<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>
<%@ page contentType="text/xml; charset=euc-kr" %>

<!-- DB 연결String -->
<%@ include file="../Include/dbConn.jsp" %> 

<%  
	PlatformData o_xpData = new PlatformData();
	int nErrorCode = 0;
	String strErrorMsg = "START";

	Connection conn = null;
	Statement  stmt = null;
	ResultSet  rs   = null;
	 
	Class.forName(DBDriver);
	conn = DriverManager.getConnection(DBString);	
	stmt = conn.createStatement();

	HttpPlatformRequest pReq = new HttpPlatformRequest(request);
	pReq.receiveData();
	PlatformData i_xpData = pReq.getData();
	VariableList in_vl = i_xpData.getVariableList();
	
	String gbn  = request.getParameter("gbn");				// 구분
	String bonbu = request.getParameter("bonbu"); 			// 본부코드
	String customer = request.getParameter("customer"); 	// 고객명
	String sDate = request.getParameter("sDate"); 			// 시작일자
	String eDate = request.getParameter("eDate"); 			// 종료일자
	
	String SQL = "";

	/******* SQL ************/
	/*
	if (Gbn.equals("01")) {
		String SQL="select distinct 본부코드 as 코드, 본부명 as 명칭 from 조직마스터V (nolock) where isnull(본부코드,'') <> '' "+
			       "union "+
			       "select '00000','전체'"+
			       "order by 1";
		//rs = stmt.executeQuery(SQL);
	}
	*/
	
	SQL = " exec P_고객_연락금지_NFP_조회 '"+gbn+"','"+bonbu+"','"+sDate+"','"+eDate+"','"+customer+"' ";
	
	rs = stmt.executeQuery(SQL);
	

	/********* Dataset **********/
	DataSet ds = new DataSet("ds_output");

	/* 공통모듈... 데이터셋...연계 필드명으로 레코드셋...가져오기 */
	int i, j;

	// 컬럼갯수 가져오기
 	ResultSetMetaData rsMetaData = rs.getMetaData();
    int numberOfColumns = rsMetaData.getColumnCount();

    // 컬럼명가져오기.
    String[] columnNames = new String[numberOfColumns];

    for(i = 0; i < numberOfColumns; i++) {
         columnNames[i] = rsMetaData.getColumnName(i + 1);
    }

    if(numberOfColumns > 0 ) {
		for(j = 0; j < numberOfColumns; j++) {
		   ds.addColumn(columnNames[j], DataTypes.STRING, (short)400); 
        }

        while(rs.next()) {
			int row = ds.newRow();
			
			for(int k = 0; k < numberOfColumns; k++) {
				 ds.set(row, columnNames[k], rs.getString(columnNames[k]));
			}	
		}
    }
	 
	o_xpData.addDataSet(ds);
	nErrorCode = 0;
	strErrorMsg = "SUCC";

	/******** JDBC Close ********/
	if ( stmt != null ) try { stmt.close(); } catch (Exception e) { nErrorCode = -1; strErrorMsg = e.getMessage(); }
	if ( conn != null ) try { conn.close(); } catch (Exception e) { nErrorCode = -1; strErrorMsg = e.getMessage(); }

	// VariableList
	VariableList varList = o_xpData.getVariableList();
			
	// Variable --> VariableList
	varList.add("ErrorCode", nErrorCode);
	varList.add("ErrorMsg", strErrorMsg);

	// HttpPlatformResponse 
	HttpPlatformResponse pRes = new HttpPlatformResponse(response, PlatformType.CONTENT_TYPE_XML, "UTF-8");
	pRes.setData(o_xpData);

	// Send data
	pRes.sendData();
%>