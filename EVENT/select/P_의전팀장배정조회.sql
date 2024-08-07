USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_의전팀장배정조회]    Script Date: 2024-08-08 오전 10:17:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		손혜진
-- Create date: 2018.10.26
-- Description:	의전팀장 배정 조회
-- EXEC P_의전팀장배정조회 '20200704','00011','Y',''
-- =============================================
ALTER PROCEDURE [dbo].[P_의전팀장배정조회]
	 @배정일자		VARCHAR(10) = ''
	,@의전지역		VARCHAR(10) = ''
	,@외주팀장만	VARCHAR(1) = '' -- Y,N
	,@의전팀장명	VARCHAR(50) = ''
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @현재시간 VARCHAR(4) = LEFT(REPLACE(CONVERT(VARCHAR(8),GETDATE(),8),':',''),4);

	CREATE TABLE #의전팀장배정(
		사원코드		VARCHAR(15)
		,사원명		 	VARCHAR(100)
		,사원구분		VARCHAR(50)
		,자격코드		VARCHAR(15)
		,휴대폰		 	VARCHAR(15)
		,휴대폰CTI		VARCHAR(15)
		,본부명		 	VARCHAR(100)
		,지사명		 	VARCHAR(100)
		,지점명		 	VARCHAR(100)
		,팀명		 	VARCHAR(100)
		,관리지역코드	VARCHAR(15)
		,관리지역명	   	VARCHAR(100)
		,창고지역		VARCHAR(15)
		,창고지역명	   	VARCHAR(100)
		,창고지역상세	VARCHAR(15)
		,창고지역상세명 VARCHAR(100)
		,배정일자		VARCHAR(15)
		,순번			INT
		,휴가여부		VARCHAR(1)
		,비고			VARCHAR(200)
		,외주구분		VARCHAR(20)
		,행사여부		VARCHAR(20)
		,행사계약코드	VARCHAR(15)
		,SORT			INT
	)
	INSERT INTO #의전팀장배정 (
		 사원코드,사원명,자격코드,휴대폰,휴대폰CTI,본부명,지사명,지점명		 	
		,팀명,관리지역코드,관리지역명,창고지역,창고지역명,창고지역상세	,창고지역상세명 
		,배정일자,순번,휴가여부,비고,외주구분,행사여부,행사계약코드,SORT	
	)
	SELECT	 B.사원코드
			,B.사원명
			,A.사원구분 --AS 자격코드
			,DBO.F_전화번호포맷(REPLACE(B.휴대폰,'-','')) AS 휴대폰
			,REPLACE(B.휴대폰,'-','') AS 휴대폰CTI
			,B.본부명
			,B.지사명
			,B.지점명
			,B.팀명 
			,ISNULL(A.지역코드,'') AS 관리지역코드
			,(SELECT 권역명 FROM 권역마스터 WHERE 권역코드 = C.관리지역코드) AS 관리지역명
			,ISNULL(C.창고지역,'')	AS 창고지역
			,ISNULL((SELECT 창고명 FROM 창고코드 WHERE 창고코드 = C.창고지역),'') AS 창고지역명
			,ISNULL(C.창고지역상세,'')	AS 창고지역상세
			,ISNULL((SELECT 창고상세명 FROM 창고상세코드 WHERE 창고코드 = C.창고지역 AND 창고상세코드 = C.창고지역상세),'') AS 창고지역상세명
			,@배정일자 AS 배정일자
			,99		AS 순번
			,'0'	AS 휴가여부
			,''		AS 비고
			,'외주' AS 외주구분
			,''		AS 행사여부
			,''		AS 행사계약코드
			,3		AS SORT
	FROM	행사사원마스터 AS A (NOLOCK)
	INNER JOIN	
			영업자격관리 AS C (NOLOCK)
	ON		A.실제사원코드 = C.사원코드  
	AND		A.사원구분 = C.자격코드 
	INNER JOIN
			사원마스터V AS B (NOLOCK)
	ON		A.실제사원코드 = B.사원코드
	AND		B.재직구분 IN ('재직','위촉')
	WHERE	B.사원명 LIKE '%' + ISNULL(@의전팀장명,'') +'%'
	AND		A.지역코드 = ISNULL(@의전지역,'')
	AND		A.사원구분 = (CASE WHEN @외주팀장만 = 'Y' THEN '00002' ELSE A.사원구분 END)
	AND		A.사원구분 IN('00001','00002')

	--UPDATE	 A
	--SET		 A.행사여부 = '진행중'
	--		,A.행사계약코드 = C.계약코드
	--		,A.SORT = CASE WHEN A.외주구분 = '직영' THEN 2 ELSE 4 END
	--FROM	#의전팀장배정 A
	--INNER JOIN
	--		행사인력 B
	--ON		A.사원코드 = B.사원코드
	--INNER JOIN
	--		행사마스터 C
	--ON		B.행사코드 = C.행사코드
	--WHERE	C.행사상태 <> '취소'
	--AND		A.배정일자 BETWEEN C.행사시작일자 AND CONVERT(VARCHAR(8),DATEADD(DD,-1,C.행사종료일자),112)

	SELECT	A.*,B.상세분류
			
			,CASE WHEN	A.휴가여부 = '1' 
						OR 행사여부 = '진행중'
				  THEN '1'
				  ELSE '0'
			END AS 배정불가여부
	FROM	#의전팀장배정 A
	INNER JOIN
			영업자격 B
	ON		A.자격코드 = B.자격코드
	ORDER BY SORT,순번,지점명

	DROP TABLE #의전팀장배정

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

END
