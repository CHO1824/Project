USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_사원트리]    Script Date: 2024-07-29 오후 1:22:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		정경윤
-- Create date: 
-- Description:	사원트리

-- EXEC P_사원트리 '','','','','','','','130001','',''

-- select * from 조직마스터
-- select * from 사원마스터v
-- select * from 사원마스터
-- =============================================
ALTER PROCEDURE [dbo].[P_사원트리](
	 @본부코드	 VARCHAR(10)   = ''
	,@지사코드	 VARCHAR(10)   = ''
	,@지점코드	 VARCHAR(10)   = ''
	,@팀코드	 VARCHAR(10)   = ''
	,@폐쇄포함	 VARCHAR(1)   = '' -- 폐쇄조직 포함여부
	,@퇴직포함	 VARCHAR(1)   = '' -- 퇴직자 포함여부
	,@사원코드   VARCHAR(15)  = '' -- 조회사원
	,@로그인사번 VARCHAR(15)  = '' -- 로그인사번
	,@휴대폰	 VARCHAR(20) = ''
	,@생년월일	 VARCHAR(20) = ''
)
AS
BEGIN
	 
	SET NOCOUNT ON;
	

	SET @휴대폰 = REPLACE(@휴대폰,'-','');
	SET @생년월일 = REPLACE(@생년월일,'-','');
	/***************************************************************************************************************************************
	 0.임시테이블
	***************************************************************************************************************************************/
	CREATE TABLE #TMP_조직(
		 조직코드		VARCHAR(10)
		,조직명			VARCHAR(100)
		,사원코드		VARCHAR(15)
		,사원명			VARCHAR(50)
		,본부코드		VARCHAR(10)
		,본부명			VARCHAR(100)
		,지사코드		VARCHAR(10)
		,지사명			VARCHAR(100)
		,지점코드		VARCHAR(10)
		,지점명			VARCHAR(100)
		,팀코드			VARCHAR(10)
		,팀명			VARCHAR(100)
		,레벨			INT		
		,재직구분		VARCHAR(10)	
	)

	-- ★ 로그인사원 업무관리-영업조직 
	CREATE TABLE #영업조직(
		본부코드	VARCHAR(7)
		,지사코드	VARCHAR(7)
		,지점코드	VARCHAR(7)
		,팀코드		VARCHAR(7)
		,사원코드	VARCHAR(15)
	)

	INSERT INTO #영업조직(본부코드,지사코드,지점코드,팀코드,사원코드)
	SELECT	본부코드,지사코드,지점코드,팀코드,사원코드
	FROM	KwooErp.dbo.f_영업사원조직L(@로그인사번)

	/***************************************************************************************************************************************
	 1.조직생성
	***************************************************************************************************************************************/
	
	SELECT	조직코드,조직명,본부코드,본부명,지사코드,지사명,지점코드,지점명,팀코드,팀명,레벨,폐쇄여부
	INTO	#TEMP_조직마스터
	FROM	DBO.F_사원관리조직(@로그인사번)
	
	IF @팀코드 <> ''	
		DELETE A FROM #TEMP_조직마스터 A WHERE 팀코드 <> @팀코드

	IF @지점코드 <> ''
		DELETE A FROM #TEMP_조직마스터 A WHERE A.지점코드 <> @지점코드 AND 지점코드 <> ''
	
	IF @지사코드 <> ''
		DELETE A FROM #TEMP_조직마스터 A WHERE A.지사코드 <> @지사코드 AND 지사코드 <> ''

	IF @본부코드 <> ''
		DELETE A FROM #TEMP_조직마스터 A WHERE 본부코드 <> @본부코드
		  
	IF @폐쇄포함 = 'F'
		DELETE A FROM #TEMP_조직마스터 A WHERE 폐쇄여부 <> 'F'
	
	--1.기본 조직도 저장
	INSERT INTO #TMP_조직(
		조직코드,조직명,사원코드,사원명,본부코드,본부명,지사코드,지사명,지점코드,지점명,팀코드,팀명,레벨,재직구분
	)	SELECT	조직코드,조직명,'','',본부코드,본부명,지사코드,지사명,지점코드,지점명,팀코드,팀명,레벨,폐쇄여부
		FROM	#TEMP_조직마스터

	/***************************************************************************************************************************************
	 2.사원생성
	***************************************************************************************************************************************/
			
	INSERT INTO #TMP_조직(
		조직코드 ,조직명 ,사원코드 ,사원명 ,본부코드 ,본부명 ,지사코드 ,지사명 ,지점코드 ,지점명 ,팀코드 ,팀명 ,레벨 ,재직구분
	)
	SELECT	(CASE	WHEN A.본부코드 <> '' AND A.지사코드 = ''  AND A.지점코드 = ''  AND A.팀코드 =''  THEN A.본부코드 
					WHEN A.본부코드 <> '' AND A.지사코드 <> '' AND A.지점코드 = ''  AND A.팀코드 =''  THEN A.지사코드
					WHEN A.본부코드 <> '' AND A.지사코드 <> '' AND A.지점코드 <> '' AND A.팀코드 =''  THEN A.지점코드
					WHEN A.본부코드 <> '' AND A.지사코드 <> '' AND A.지점코드 <> '' AND A.팀코드 <>'' THEN A.팀코드 
			 END) AS 조직코드
			,A.사원코드+' '+G.사원명+ ' ('+(CASE WHEN G.신규승인 = 'N' THEN '미승인자' ELSE G.재직구분 END)+')' AS 조직명
			,A.사원코드
			,G.사원명
			,A.본부코드
			,ISNULL((SELECT 본부명 FROM 본부 (NOLOCK) WHERE 본부코드 = A.본부코드),'') AS 본부명
			,A.지사코드
			,ISNULL((SELECT 지사명 FROM 지사 (NOLOCK) WHERE 지사코드 = A.지사코드),'') AS 지사명
			,A.지점코드
			,ISNULL((SELECT 지점명 FROM 지점 (NOLOCK) WHERE 지점코드 = A.지점코드),'') AS 지점명
			,A.팀코드
			,ISNULL((SELECT 팀명 FROM 팀 (NOLOCK) WHERE 팀코드 = A.팀코드),'') AS 팀명
			,(CASE	WHEN A.본부코드 <> '' AND A.지사코드 = '' AND A.지점코드 = ''  AND A.팀코드 =''  THEN 2
					WHEN A.본부코드 <> '' AND A.지사코드 <> '' AND A.지점코드 = '' AND A.팀코드 =''  THEN 3
					WHEN A.본부코드 <> '' AND A.지사코드 <> '' AND A.지점코드 <> ''AND A.팀코드 =''  THEN 4
					WHEN A.본부코드 <> '' AND A.지사코드 <> '' AND A.지점코드 <> ''AND A.팀코드 <>'' THEN 5
			 END) AS 레벨
			,G.재직구분
	FROM	(
				SELECT  X.사원코드,X.본부코드,X.지사코드,X.지점코드,X.팀코드,X.시작일자,X.종료일자 
				FROM	조직변경이력 AS X (NOLOCK)
				INNER JOIN
						#TEMP_조직마스터 AS B
				ON		X.본부코드 = B.본부코드
				AND		X.지사코드 = B.지사코드 
				AND		X.지점코드 = B.지점코드 
				AND		X.팀코드 = B.팀코드 
				
				WHERE	CONVERT(VARCHAR(8),GETDATE(),112) BETWEEN X.시작일자 AND X.종료일자
			) AS A 	
	INNER JOIN
			사원마스터 AS G (NOLOCK)
	ON		A.사원코드 = G.사원코드
	WHERE	G.신규승인 <> 'C'
	AND     (CASE WHEN @사원코드 = '' THEN @사원코드 ELSE G.사원코드 END = ISNULL(@사원코드,''))
	AND		(CASE WHEN @휴대폰 = '' THEN @휴대폰 ELSE G.휴대폰 END LIKE '%'+ ISNULL(@휴대폰,'') +'%')
	AND		(CASE WHEN @생년월일 = '' THEN @생년월일 ELSE G.주민번호 END LIKE '%'+ ISNULL(@생년월일,'') +'%')


	IF @퇴직포함 = 'F'
		DELETE A FROM #TMP_조직 A WHERE 재직구분 NOT IN ('재직' ,'위촉' ,'F', 'T') 

	/***************************************************************************************************************************************
	 9.최종결과
	***************************************************************************************************************************************/
	DELETE A FROM #TMP_조직 AS A WHERE 사원코드 = '130001' --관리자삭제

	SELECT		조직코드,조직명,사원코드,사원명,레벨,본부코드,본부명,지사코드,지사명,지점코드,지점명,팀코드,팀명,재직구분
	FROM		#TMP_조직
	ORDER BY	본부코드, 지사코드 ,지점코드,팀코드,사원코드

	DROP TABLE	#TEMP_조직마스터
	DROP TABLE	#TMP_조직
	DROP TABLE	#영업조직

END