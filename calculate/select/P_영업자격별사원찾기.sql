USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_영업자격별사원찾기]    Script Date: 2024-05-17 오후 4:11:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		손혜진
-- Create date: 2018.05.28
-- Description:	영업자격별 사원 찾기 조회

-- EXEC P_영업자격별사원찾기 '장례'
-- EXEC P_영업자격별사원찾기 '웨딩'
-- =============================================
ALTER PROCEDURE [dbo].[P_영업자격별사원찾기]
 @대분류	VARCHAR(20)	= ''
,@상세분류	VARCHAR(20) = ''
,@본부코드	VARCHAR(10)	= ''
,@지사코드	VARCHAR(10)	= ''
,@지점코드	VARCHAR(10)	= ''
,@팀코드	VARCHAR(10)	= ''
,@사원명	VARCHAR(50)	= ''
,@사원코드	VARCHAR(15)	= ''
,@관리지역	VARCHAR(10) = ''
,@재직구분	VARCHAR(20) = ''
,@자격코드	VARCHAR(20) = ''


AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	CREATE TABLE #영업자격별사원(
		사원코드		VARCHAR(15)
		,사원명			VARCHAR(50)
		,자격코드		VARCHAR(15)
		,자격명			VARCHAR(50)
		,대분류			VARCHAR(50)
		,상세분류		VARCHAR(50)
		,관리지역코드	VARCHAR(10)
		,관리지역명		VARCHAR(100)
		,창고지역		VARCHAR(10)
		,창고지역명		VARCHAR(100)
		,창고지역상세	VARCHAR(10)
		,창고지역상세명	VARCHAR(100)
		,휴대폰			VARCHAR(15)
		,주민번호		VARCHAR(15)
		,본부코드		VARCHAR(10)
		,본부명			VARCHAR(50)
		,지사코드		VARCHAR(10)
		,지사명			VARCHAR(50)
		,지점코드		VARCHAR(10)
		,지점명			VARCHAR(50)
		,팀코드			VARCHAR(10)
		,팀명			VARCHAR(50)
		,재직구분		VARCHAR(20)
	)

	IF @대분류 = '장례' AND ISNULL(@상세분류,'') IN ('', '의전팀장')
	BEGIN
		INSERT INTO #영업자격별사원(
				사원코드,사원명,본부코드,본부명,지사코드,지사명,지점코드,지점명,팀코드,팀명
				,자격코드,자격명,대분류,상세분류,관리지역코드,관리지역명,창고지역,창고지역명,창고지역상세,창고지역상세명
				,휴대폰,주민번호,재직구분	
		)
		SELECT	A.사원코드, B.사원명, B.본부코드, B.본부명, B.지사코드, B.지사명, B.지점코드, B.지점명, B.팀코드, B.팀명
				, A.자격코드
				, C.자격명
				, C.대분류
				, C.상세분류
				, A.관리지역코드 AS 관리지역코드
				, (SELECT 권역명 FROM 권역마스터 WHERE 업무구분 = '의전팀장' AND 권역코드 = A.관리지역코드) AS 관리지역명
				, A.창고지역
				, (SELECT 창고명 FROM 창고코드 WHERE 창고코드 = A.창고지역) AS 창고지역명
				, A.창고지역상세
				, (SELECT 창고상세명 FROM 창고상세코드 WHERE 창고코드 = A.창고지역 AND 창고상세코드 = A.창고지역상세) AS 창고지역상세명
				, DBO.F_전화번호포맷(B.휴대폰) AS 휴대폰
				, B.주민번호
				, B.재직구분
		FROM	영업자격관리 A (NOLOCK)
		INNER JOIN
				사원마스터V B (NOLOCK)
		ON		A.사원코드 = B.사원코드
		INNER JOIN
				영업자격 C (NOLOCK)
		ON		A.자격코드 = C.자격코드
		WHERE	A.자격상태 = '정상'
		AND		C.상세분류 = '의전팀장'
		AND		B.재직구분 LIKE ISNULL(@재직구분,'') + '%'
		AND		A.자격코드 LIKE ISNULL(@자격코드,'') + '%'
		AND		ISNULL(A.관리지역코드,'') LIKE ISNULL(@관리지역,'') +'%'
		
		IF ISNULL(@본부코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 본부코드 != ISNULL(@본부코드,'')

		IF ISNULL(@지사코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 지사코드 != ISNULL(@지사코드,'')

		IF ISNULL(@지점코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 지점코드 != ISNULL(@지점코드,'')

		IF ISNULL(@팀코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 팀코드 != ISNULL(@팀코드,'')

	END


	IF @대분류 = '장례' AND ISNULL(@상세분류,'') != '의전팀장'
	BEGIN
		INSERT INTO #영업자격별사원(
				사원코드,사원명
				,자격코드,자격명,대분류,상세분류,본부코드,본부명,지사코드,지사명
				,휴대폰,주민번호
		)
		SELECT	A.사원코드,A.사원명
				,A.사원구분
				,B.자격명
				,B.대분류
				,B.상세분류
				,A.지역코드
				,(SELECT 권역명 FROM 권역마스터  WHERE 업무구분 = '복지사' AND 권역코드 = A.지역코드)
				,A.팀코드
				,(SELECT 지역명 FROM 지역마스터  WHERE 업무구분 = '복지사' AND 지역코드 = A.팀코드)
				,DBO.F_전화번호포맷(A.휴대폰) AS 휴대폰
				,A.주민번호
				
		FROM	행사사원마스터  AS A (NOLOCK)
		INNER JOIN
				영업자격 AS B (NOLOCK)
		ON		A.사원구분 = B.자격코드

	END

	IF @대분류 = '웨딩' AND ISNULL(@상세분류,'') IN ('', '임직원')
	BEGIN
		INSERT INTO #영업자격별사원(
				사원코드,사원명,본부코드,본부명,지사코드,지사명,지점코드,지점명,팀코드,팀명
				,자격코드,자격명,대분류,상세분류,관리지역코드,관리지역명,창고지역,창고지역명,창고지역상세,창고지역상세명
				,휴대폰,주민번호,재직구분	
		)
		SELECT	A.사원코드, B.사원명, B.본부코드, B.본부명, B.지사코드, B.지사명, B.지점코드, B.지점명, B.팀코드, B.팀명
				, A.자격코드
				, C.자격명
				, C.대분류
				, C.상세분류
				, A.관리지역코드 AS 관리지역코드
				, (SELECT 권역명 FROM 권역마스터 WHERE 권역코드 = A.관리지역코드) AS 관리지역명
				, A.창고지역
				, (SELECT 권역명 FROM 권역마스터 WHERE 권역코드 = A.창고지역) AS 창고지역명
				, A.창고지역상세
				, (SELECT 지역명 FROM 지역마스터 WHERE 지역코드 = A.창고지역상세) AS 창고지역상세명
				, DBO.F_전화번호포맷(B.휴대폰) AS 휴대폰
				, B.주민번호
				, B.재직구분
		FROM	영업자격관리 AS A (NOLOCK)
		INNER JOIN
				사원마스터V AS B (NOLOCK) 
		ON		A.사원코드 = B.사원코드
		INNER JOIN
				영업자격 AS C (NOLOCK)
		ON		A.자격코드 = C.자격코드
		WHERE	A.자격상태 = '정상'
		AND		C.상세분류 = '임직원'
		AND		B.재직구분 LIKE ISNULL(@재직구분,'') + '%'
		AND		A.자격코드 LIKE ISNULL(@자격코드,'') + '%'
		AND		ISNULL(A.관리지역코드,'') LIKE ISNULL(@관리지역,'') +'%'

		IF ISNULL(@본부코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 본부코드 != ISNULL(@본부코드,'')

		IF ISNULL(@지사코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 지사코드 != ISNULL(@지사코드,'')

		IF ISNULL(@지점코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 지점코드 != ISNULL(@지점코드,'')

		IF ISNULL(@팀코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 팀코드 != ISNULL(@팀코드,'')

	END

	IF ISNULL(@상세분류,'') != ''
			DELETE FROM #영업자격별사원 WHERE 상세분류 != ISNULL(@상세분류,'') 

	IF ISNULL(@사원코드,'') != ''
			DELETE FROM #영업자격별사원 WHERE 사원코드 != ISNULL(@사원코드,'') 
	

	SELECT	* 
	FROM	#영업자격별사원
	WHERE	사원명 LIKE '%'+ ISNULL(@사원명,'') +'%'
	ORDER BY 사원코드

END
