USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_행사인력_장례_등록]    Script Date: 2024-05-17 오후 4:03:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조하영
-- Create date: 2024.04.24
-- Description:	장례 행사인력
-- SELECT * FROM 행사인력 WHERE 행사코드 = 'F20171000201'
-- EXEC P_행사인력_장례_등록 'I','6185','1000000','장례','','기본','20090006','김석주','','20240119','','20240119','','','1','','500000','3000000','20000','60000','10000000','30000','900000','0','본사','130001'
-- =============================================
ALTER PROCEDURE [dbo].[P_행사인력_장례_등록]
　@MOD				AS VARCHAR(2)		= ''		 
, @행사코드			AS VARCHAR(15)		= ''
, @SEQ				AS BIGINT			= 0
, @행사구분			AS VARCHAR(20)		= '' -- 장례/웨딩/여행/어학
, @참여구분			AS VARCHAR(20)		= ''
, @구분				AS VARCHAR(20)		= '' -- 등록 / 정산 / 엔딩플래너
, @영업자격코드		AS VARCHAR(20)		= ''
, @사원코드			AS VARCHAR(15)		= ''
, @사원명			AS VARCHAR(100)		= ''
, @주민번호			AS VARCHAR(13)		= ''
--, @접수참석			AS VARCHAR(2)		= ''
--, @입관참석			AS VARCHAR(2)		= ''
--, @발인참석			AS VARCHAR(2)		= ''
--, @장지참석			AS VARCHAR(2)		= ''
--, @복장상태			AS VARCHAR(5)		= ''
, @시작일자			AS VARCHAR(10)		= ''
, @시작시간			AS VARCHAR(5)		= ''
, @종료일자			AS VARCHAR(10)		= ''
, @종료시간			AS VARCHAR(5)		= ''
, @도착시간			AS VARCHAR(5)		= ''
, @근무시간			AS INT				= 0
, @초과근무시간		AS INT				= 0
, @단가				AS NUMERIC(18, 0)	= 0
, @작업금액			AS NUMERIC(18, 0)	= 0
, @추가금액			AS NUMERIC(18, 0)	= 0
, @추가수당			AS NUMERIC(18, 0)	= 0
, @총액				AS NUMERIC(18, 0)	= 0
, @원천세			AS NUMERIC(18, 2)	= 0
, @실지급액			AS NUMERIC(18, 2)	= 0
--, @전문상례사여부	AS VARCHAR(1)		= ''
, @세금정산여부		AS VARCHAR(1)		= ''
, @지급방법			AS VARCHAR(20)		= ''
, @등록자			AS VARCHAR(15)		= ''

AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @nMSG VARCHAR(2000), @회원명 VARCHAR(100), @중복계약코드 VARCHAR(15), @영업자격명 VARCHAR(100),@c종료시간 VARCHAR(4);
/*
	CREATE TABLE #행사인력중복(
		사원명		VARCHAR(100)
		,회원명		VARCHAR(50)
		,계약코드	VARCHAR(15)
		,행사코드	VARCHAR(15)
		,영업자격명	VARCHAR(100)
		,시작일자	VARCHAR(10)
		,시작시간	VARCHAR(5)
		,종료일자	VARCHAR(10)
		,종료시간	VARCHAR(5)
	)
*/
	IF @MOD = 'I'
	BEGIN
	/*
		-- 상례사,전문상례사,엔딩플래너
		IF @영업자격코드 IN ('00004','00005','00010','00011','00012') 
		BEGIN
			IF ISNULL(@종료시간,'') = ''
				SET @c종료시간 = '2400';
			ELSE 
				SET @c종료시간 = @종료시간;

			INSERT INTO #행사인력중복 (
					사원명,회원명,계약코드,행사코드,영업자격명,시작일자,시작시간,종료일자,종료시간 )
			SELECT	TOP 1 
					A.사원명,B.회원명,B.계약코드,A.행사코드
					,(SELECT 자격명 FROM 영업자격 WHERE 자격코드 = A.영업자격코드 ) AS 영업자격명
					,A.시작일자,A.시작시간,A.종료일자,A.종료시간
			FROM	행사인력  A (NOLOCK)
			INNER JOIN
					장례행사마스터V B (NOLOCK)
			ON		A.행사코드 = B.행사코드
			WHERE	A.행사구분 = '장례'
			AND		A.행사코드 <> @행사코드
			AND		A.사원코드 LIKE @사원코드 +'%'
			AND		A.주민번호 LIKE @주민번호 +'%'
			AND		A.영업자격코드 NOT IN ('00001','00003','00006','00007','00008') -- 외주지도사,사원입관보조,외부입관보조,지도사입관보조 제외
			AND		((@시작일자+@시작시간 BETWEEN ISNULL(A.시작일자,'')+ISNULL(A.시작시간,'') AND ISNULL(A.종료일자,'')+ISNULL(A.종료시간,'')) OR
					 (@종료일자+@c종료시간 BETWEEN ISNULL(A.시작일자,'')+ISNULL(A.시작시간,'') AND ISNULL(A.종료일자,'')+ISNULL(A.종료시간,''))
					)
		END
		/*
		-- 2017.11.02 김보라사원 요청
			:다른행사의 도우미로 나갔을경우가있으므로 시간대가 겹치지않는이상 등록 가능하게 요청

		-- 사원도우미,외부도우미
		IF @영업자격코드 IN ('00010','00011') 
		BEGIN
			INSERT INTO #행사인력중복 (
					사원명,회원명,계약코드,행사코드,영업자격명,시작일자,시작시간,종료일자,종료시간 )
			SELECT	A.사원명,B.회원명,B.계약코드,A.행사코드
					,(SELECT 자격명 FROM 영업자격 WHERE 자격코드 = A.영업자격코드 ) AS 영업자격명
					,A.시작일자,A.시작시간,A.종료일자,A.종료시간
			FROM	행사인력  A (NOLOCK)
			INNER JOIN
					장례행사마스터V B (NOLOCK)
			ON		A.행사코드 = B.행사코드
			WHERE	A.행사구분 = '장례'
			AND		A.행사코드 <> @행사코드
			AND		A.사원코드 LIKE @사원코드 +'%'
			AND		A.주민번호 LIKE @주민번호 +'%'
			AND		A.영업자격코드 NOT IN ('00001','00003','00006','00007','00008') -- 외주지도사,사원입관보조,외부입관보조,지도사입관보조 제외
			AND		((@시작일자 BETWEEN A.시작일자 AND A.종료일자) OR
					 (@종료일자 BETWEEN A.시작일자 AND A.종료일자)
					)
		END
		*/

		IF EXISTS (	SELECT 'X' 
					FROM #행사인력중복)
		BEGIN
			SELECT	@회원명 = 회원명
					,@중복계약코드 = 계약코드
					,@영업자격명 = 영업자격명
			FROM	#행사인력중복  A (NOLOCK)
			
			SET @nMSG = '"'+@사원명+'"은(는) 이미 계약코드:'+@중복계약코드+'/회원명: '+@회원명+' 행사기간에 '+@영업자격명+'(으)로 등록된 인력입니다. 날짜 또는 해당 행사 인력 정보가 맞는지 확인 후 다시 입력하세요.'
			Raiserror(@nMSG,16, 1, '', '', '');
			RETURN;
		END
	*/
		IF EXISTS (	SELECT 'X' 
					FROM	행사인력 AS A (NOLOCK)
					WHERE	행사코드 = @행사코드
					AND		SEQ		 = @SEQ
					)
		BEGIN
			UPDATE   A 
			SET		  참여구분			= @참여구분
					, 구분				= @구분
					, 영업자격코드		= @영업자격코드
					, 사원코드			= @사원코드
					, 사원명			= @사원명
					, 주민번호			= @주민번호
				--	, 접수참석			= CASE WHEN @접수참석  = '1' OR @접수참석  = 'Y' THEN 'Y' ELSE 'N' END
				--	, 입관참석			= CASE WHEN @입관참석  = '1' OR @입관참석  = 'Y' THEN 'Y' ELSE 'N' END
				--	, 발인참석			= CASE WHEN @발인참석  = '1' OR @발인참석  = 'Y' THEN 'Y' ELSE 'N' END
				--	, 장지참석			= CASE WHEN @장지참석  = '1' OR @장지참석  = 'Y' THEN 'Y' ELSE 'N' END
				--	, 복장상태			= @복장상태
					, 시작일자			= @시작일자
					, 시작시간			= @시작시간
					, 종료일자			= @종료일자
					, 종료시간			= @종료시간
					, 도착시간			= @도착시간
					, 근무시간			= ISNULL(@근무시간		,0)
					, 초과근무시간		= ISNULL(@초과근무시간  ,0)
					, 단가				= ISNULL(@단가			,0)
					, 작업금액			= ISNULL(@작업금액		,0)
					, 추가금액			= ISNULL(@추가금액		,0)
					, 추가수당			= ISNULL(@추가수당		,0)
					, 총액				= ISNULL(@총액			,0)
					, 원천세			= ISNULL(@원천세		,0)
					, 실지급액			= ISNULL(@실지급액		,0)
					--, 전문상례사여부	= @전문상례사여부
					, 세금정산여부		= CASE WHEN @세금정산여부  = '1' OR @세금정산여부  = 'Y' THEN 'Y' ELSE 'N' END
					, 지급방법			= @지급방법
			FROM	행사인력 AS A (NOLOCK)
			WHERE	행사코드			= @행사코드
			AND		SEQ					= @SEQ
		END
		ELSE
		BEGIN
			INSERT INTO 행사인력 (
					행사코드, 행사구분, 참여구분, 구분, 영업자격코드, 사원코드, 사원명, 주민번호, 
					/*접수참석, 입관참석, 발인참석, 장지참석, 복장상태,*/ 시작일자, 시작시간, 종료일자, 종료시간, 도착시간, 
					근무시간, 초과근무시간, 단가, 작업금액, 추가금액, 추가수당, 총액, 원천세, 실지급액,/* 전문상례사여부,*/ 세금정산여부,지급방법, 등록자) 
			VALUES (
					@행사코드, @행사구분, @참여구분, @구분, @영업자격코드, @사원코드, @사원명, @주민번호
					--,CASE WHEN @접수참석  = '1' THEN 'Y' ELSE 'N' END
				--	,CASE WHEN @입관참석  = '1' THEN 'Y' ELSE 'N' END
					--,CASE WHEN @발인참석  = '1' THEN 'Y' ELSE 'N' END
					--,CASE WHEN @장지참석  = '1' THEN 'Y' ELSE 'N' END
					--,@복장상태
					, @시작일자, @시작시간, @종료일자, @종료시간, @도착시간
					,ISNULL(@근무시간,0)
					,0
					,ISNULL(@단가,0)
					,ISNULL(@작업금액,0)
					,ISNULL(@추가금액,0)
					,ISNULL(@추가수당,0)
					,ISNULL(@총액,0)
					,ISNULL(@원천세,0)
					,ISNULL(@실지급액,0)
					--,@전문상례사여부
					,CASE WHEN @세금정산여부  = '1' OR @세금정산여부  = 'Y' THEN 'Y' ELSE 'N' END
					,@지급방법
					,@등록자
					)
	
		END
	END --END OF IF


	IF @MOD = 'D'
	BEGIN
	  DELETE	A FROM 행사인력 AS A (NOLOCK)
	  WHERE		행사코드	= @행사코드
	  AND		SEQ			= @SEQ
	
	END

END
