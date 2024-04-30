<%@ page import="org.apache.commons.logging.*" %>
<%@ page import="com.tobesoft.xplatform.data.*" %>
<%@ page import="com.tobesoft.xplatform.tx.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*" %>

<%@ page contentType="text/html; charset=euc-kr" pageEncoding="euc-kr"%> 

<!-- DB 연결String -->
<%@include file="../Include/dbConn.jsp" %> 

<%! 
/*********** 공통함수 *************/
// DataSet 값 가져오기, 단, "null"을 ""로
public String  dsGet(DataSet ds, int rowno, String colid) throws Exception
{
	String value;
	value = ds.getString(rowno,colid);
	if( value == null )
		return "";
	else
		return value;
} 
%>

<%
/****** Service API 초기화 ******/
PlatformData o_xpData = new PlatformData();
	
int nErrorCode = 0; // MP변경 : 변수처리 이렇게 해야 함
String strErrorMsg = "START"; // MP변경 : 변수처리 이렇게 해야 함

// HttpServletRequest설정
HttpPlatformRequest pReq = new HttpPlatformRequest(request);
	
/** Web Server에서 XML수신 및 Parsing **/
pReq.receiveData();
PlatformData i_xpData = pReq.getData();

// 변수List가져오기
VariableList in_vl = i_xpData.getVariableList();

String EmpCode = request.getParameter("EmpCode");

String in_var2 = in_vl.getString("in_var2");

DataSet ds = i_xpData.getDataSet("input");

try {	
	/******* JDBC Connection *******/
	Connection conn = null;
	Statement  stmt = null;
	ResultSet  rs   = null;
	
	try {

		Class.forName(DBDriver);
		conn = DriverManager.getConnection(DBString);	
		stmt = conn.createStatement();
	
		String SQL = "";
		int	i;
		
//		System.out.println(">>> SQL : " + ds.getRowCount());
		/******** Dataset을 INSERT, UPDATE처리 ********/
		
		for(i=0;i<ds.getRowCount();i++)
		{
				SQL = "exec P_고객_연락금지_NFP_등록 'I',"+
							"'" + dsGet(ds,i,"일련번호"		) + "'," +
							"'" + dsGet(ds,i,"담당설계사코드"		) + "'," +
							"'" + dsGet(ds,i,"고객명"			) + "'," +
							"'" + dsGet(ds,i,"고객사연락처"		) + "'," +
							"'" + dsGet(ds,i,"콜접수일자"		) + "'," +
							"'" + dsGet(ds,i,"연락금지요청일자"	) + "'," +
							"'" + dsGet(ds,i,"접수자"			) + "'," +
							"'" + dsGet(ds,i,"설계사전달일자"		) + "'," +
							"'" + dsGet(ds,i,"설계사확인유무일자"	) + "'," +
							"'" + EmpCode					  + "'";
//			}
			stmt.executeUpdate(SQL);
		}
		
		
		/****** Dataset을 DELETE처리 ****/
		for( i = 0 ; i< ds.getRemovedRowCount() ; i++ )
		{
			String Param01 = ds.getRemovedData(i,"일련번호").toString();
			SQL = "exec P_고객_연락금지_NFP_등록 'D',"+"'"+Param01+"'";
			stmt.executeUpdate(SQL);
		} 

		conn.commit();

	} catch (SQLException e) {
		nErrorCode = -1;
		strErrorMsg = e.getMessage();
	}	
	
	/******** JDBC Close ********/
	if ( stmt != null ) try { stmt.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
	if ( conn != null ) try { conn.close(); } catch (Exception e) {nErrorCode = -1; strErrorMsg = e.getMessage();}
	
	nErrorCode = 0;
	strErrorMsg = "SUCC";
			
} catch (Throwable th) {
	nErrorCode = -1;
	strErrorMsg = th.getMessage();
}

VariableList varList = o_xpData.getVariableList();
		
// VariableList에 직접넣을 수 없고 변수 만들어 넣어야 됨
varList.add("ErrorCode", nErrorCode);
varList.add("ErrorMsg", strErrorMsg);
String out_var = in_var2;
varList.add("out_var", out_var);  

HttpPlatformResponse pRes = new HttpPlatformResponse(response, PlatformType.CONTENT_TYPE_XML, "UTF-8");
pRes.setData(o_xpData);

// XML보내기
pRes.sendData();
%>
