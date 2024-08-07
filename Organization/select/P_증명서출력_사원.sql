USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_증명서출력_사원]    Script Date: 2024-07-29 오후 1:40:26 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		김정기
-- Create date: 2018.10.10
-- Description:	P_증명서출력_사원

-- exec P_증명서출력_사원 '1701859','130001'
-- exec P_증명서출력_사원 '20090012','20090041'

-- =============================================
ALTER PROCEDURE [dbo].[P_증명서출력_사원]
	@사원코드			VARCHAR(10) = ''
	,@로그인사원코드	VARCHAR(10) = ''
AS
BEGIN
	
	SET NOCOUNT ON;

	DECLARE 
		@출력일자 VARCHAR(30) = ''
		,@신청일자 VARCHAR(30) = ''
		,@대표코드	VARCHAR(5)	= ''
		,@상세코드	VARCHAR(20)	= ''
		,@그룹코드	VARCHAR(5)	= ''

	SET @출력일자 = CONVERT(VARCHAR(20),GETDATE(),112);
	SET @신청일자 = CONVERT(VARCHAR(20),GETDATE(),112);
	SET @출력일자 = '  '+LEFT(@출력일자,4)+' 년 '+SUBSTRING(@출력일자,5,2)+' 월 '+RIGHT(@출력일자,2)+' 일 '
	--증명서 담당자 셋팅
	SET @대표코드 = '00081'
	SET	@상세코드 = '334475'
	SET	@그룹코드 = '00001'

	SELECT	A.사원코드
			,A.사원명
			,(SELECT 사원명 FROM 사원마스터V AS Z (NOLOCK) WHERE @로그인사원코드 = Z.사원코드) AS 신청인
			,(SELECT 소속조직명 FROM 사원마스터V AS Z (NOLOCK) WHERE @로그인사원코드 = Z.사원코드) AS 신청인소속
			,A.사원등록일자
			,A.소속조직명 AS 소속
			,A.본부명
			,A.지사명
			,A.지점명
			,A.팀명
			,dbo.f_주민번호포맷(A.주민번호) AS 주민번호
			,A.생년월일
			,A.자택우편번호
			,CASE WHEN ISNULL(A.자택도로명주소,'') <> ''
				  THEN A.자택도로명주소+ ' ' + A.자택상세주소
				  ELSE A.자택우편주소
				  END AS 자택주소
			,A.직장우편번호	  
			,A.직장우편주소+ ' ' + A.직장상세주소 AS 직장주소
			,dbo.f_전화번호포맷(A.집전화) AS 집전화
			,dbo.f_전화번호포맷(A.휴대폰) AS 휴대폰
			,A.예금주
			,A.은행명
			,A.계좌번호
			,@출력일자 AS 출력일자
			,@신청일자 AS 신청일자
			,CONVERT(VARCHAR(100) , '') AS 회사법인명
			,CONVERT(VARCHAR(10) , '') AS 회사우편번호
			,CONVERT(VARCHAR(100), '') AS 회사도로명주소
			,CONVERT(VARCHAR(100), '') AS 회사상세주소
			,CONVERT(VARCHAR(50), '') AS 출력자부서
			,CONVERT(VARCHAR(15), '') AS 출력자TEL -- 나중에 프로그램 오픈후 고객이 요청한 번호로 진행 (휴대폰,집전화,직장전화)
			,CONVERT(VARCHAR(15), '') AS 출력자FAX
			,@로그인사원코드 AS 로그인사원코드
	INTO	#TMP_임시기초데이터 -- DROP TABLE #TMP_임시기초데이터
	FROM	사원마스터V AS A (NOLOCK)
	WHERE	사원코드 = @사원코드

	UPDATE	T1
	SET		 T1.회사법인명		= (SELECT 법인명 FROM 회사정보마스터 AS Z (NOLOCK))
			,T1.회사우편번호	= (SELECT 우편번호 FROM 회사정보마스터 AS Z (NOLOCK))
			,T1.회사도로명주소	= (SELECT 도로명주소 FROM 회사정보마스터 AS Z (NOLOCK))
			,T1.회사상세주소	= (SELECT 상세주소 FROM 회사정보마스터 AS Z (NOLOCK))
	FROM	#TMP_임시기초데이터 AS T1

	UPDATE	T1
	SET		 T1.출력자부서 = T2.부서명
			,T1.출력자TEL = T2.휴대폰
			,T1.출력자FAX = T2.직장팩스
	FROM	#TMP_임시기초데이터 AS T1
	INNER JOIN
			사원마스터V AS T2
	ON		T1.로그인사원코드 = T2.사원코드

	SELECT	*
	FROM	#TMP_임시기초데이터
	
END
