USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_장례조회]    Script Date: 2024-08-08 오전 10:35:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		손혜진
-- Create date: 2017.10.12
-- Description:	장례조회
-- EXEC P_장례조회 '리스트조회','장례접수일자','20200601','20200629','','','','','','','','','','','130001','','F'
-- EXEC P_장례조회 '리스트조회','입관일자', '20210101','20240326','','','','',''
-- =============================================
ALTER PROCEDURE [dbo].[P_장례조회]
	 @구분				AS VARCHAR(20) = '' -- 리스트조회/상세조회
	,@조회구분			AS VARCHAR(20) = ''
	,@시작일자			AS VARCHAR(10) = ''
	,@종료일자			AS VARCHAR(10) = ''
	,@회원명			AS VARCHAR(100) = ''
	,@상주명			AS VARCHAR(100) = ''
	,@고인성명			AS VARCHAR(100) = ''
	,@계약코드			AS VARCHAR(15) = ''
	,@행사코드			AS VARCHAR(15) = ''
	,@본부코드			AS VARCHAR(10) = ''
	,@지사코드			AS VARCHAR(10) = ''
	,@지점코드			AS VARCHAR(10) = ''
	,@팀코드			AS VARCHAR(10) = ''
	,@사원코드			AS VARCHAR(15) = ''
	,@로그인사원코드	AS VARCHAR(15) = ''
	,@의전팀장			AS VARCHAR(15) = ''
	,@오등록포함		AS VARCHAR(1) = ''

AS
BEGIN
	
	SET NOCOUNT ON;

		-- ★ 로그인사원 업무관리-영업조직 
		CREATE TABLE #영업조직(
			본부코드	VARCHAR(10)
			,지사코드	VARCHAR(10)
			,지점코드	VARCHAR(10)
			,팀코드		VARCHAR(10)
			,사원코드	VARCHAR(15)
		)
			CREATE TABLE #장례리스트( -- DROP TABLE #장례리스트
			 행사시작일자	VARCHAR(10)
			,접수일자		VARCHAR(10)
			,행사상태		VARCHAR(20)
			,회원코드		VARCHAR(15)
			,회원명			VARCHAR(100)
			,계약코드		VARCHAR(15)
			,상주명			VARCHAR(50)
			,고인명			VARCHAR(50)
			,즉발행사구분	VARCHAR(20)
			,행사코드		VARCHAR(15)
			,의전팀장코드	VARCHAR(15)
			,의전팀장		VARCHAR(100)
			,의전팀장소속	VARCHAR(200)
			,의전팀장지역	VARCHAR(200)
			,취소구분		VARCHAR(20)
			,상품코드		VARCHAR(10)
			,계약상품명		VARCHAR(50)
			,상품총액		BIGINT
			,장례식장명		VARCHAR(200)
			,시스템일자		DATETIME
		)

	IF @구분 = '리스트조회'
	BEGIN

		-- ★ 로그인사원 업무관리-영업조직 
		INSERT INTO #영업조직
		SELECT DISTINCT 본부코드,지사코드,지점코드,팀코드,사원코드 FROM DBO.f_사원관리조직M(@로그인사원코드);

		IF ISNULL(@행사코드,'') <> '' OR ISNULL(@계약코드,'') <> ''
		BEGIN
			INSERT INTO #장례리스트
			SELECT	 A.행사시작일자
					,A.접수일자
					,A.행사상태
					,B.회원코드
					,B.회원명
					,A.계약코드
					,A.상주 AS 상주명
					,A.고인성명 AS 고인명
					,A.즉발행사구분
					,A.행사코드
					,CONVERT(VARCHAR,'') AS 의전팀장코드
					,CONVERT(VARCHAR,'') AS 의전팀장
					,CONVERT(VARCHAR,'') AS 의전팀장소속
					,CONVERT(VARCHAR,'') AS 의전팀장지역
					,A.취소구분
					,A.상품코드	
					,B.계약상품명	
					,B.상품총액	
					,(SELECT 장례식장명 FROM 장례식장 (NOLOCK) WHERE 장례식장코드 = A.장례식장코드) AS 장례식장명
					,A.시스템일자
			FROM	행사마스터 AS A　(NOLOCK)
			INNER JOIN
					계약마스터4V AS B (NOLOCK)
			ON		A.계약상세코드 = B.계약상세코드
			INNER JOIN
					조직변경이력 AS F (NOLOCK)
			ON		B.수금사원코드 = F.사원코드 
			AND		CONVERT(VARCHAR(8),GETDATE(),112) BETWEEN F.시작일자 AND F.종료일자
			INNER JOIN
					#영업조직 AS C (NOLOCK)
			ON		F.사원코드 = C.사원코드
			WHERE	(CASE WHEN ISNULL(@행사코드,'') = '' THEN ISNULL(@행사코드,'') ELSE A.행사코드 END = ISNULL(@행사코드,''))
			AND		(CASE WHEN ISNULL(@계약코드,'') = '' THEN ISNULL(@계약코드,'') ELSE A.계약코드 END = ISNULL(@계약코드,''))
		END --END OF IF : @행사코드 <> '' OR 계약코드 <> ''

		ELSE 
		BEGIN
			INSERT INTO #장례리스트 (
				 행사시작일자 ,접수일자 ,행사상태 ,회원코드 ,회원명 ,계약코드 ,상주명 ,고인명
				,즉발행사구분 ,행사코드 ,의전팀장코드 ,의전팀장 ,의전팀장소속 ,의전팀장지역
				,취소구분, 상품코드, 계약상품명, 상품총액 ,장례식장명 ,시스템일자
			)
			SELECT	 A.행사시작일자
					,A.접수일자
					,A.행사상태
					,B.회원코드
					,B.회원명
					,A.계약코드
					,A.상주 AS 상주명
					,A.고인성명 AS 고인명
					,A.즉발행사구분
					,A.행사코드
					,CONVERT(VARCHAR,'') AS 의전팀장코드
					,CONVERT(VARCHAR,'') AS 의전팀장
					,CONVERT(VARCHAR,'') AS 의전팀장소속
					,CONVERT(VARCHAR,'') AS 의전팀장지역
					,A.취소구분
					,A.상품코드
					,B.계약상품명
					,B.상품총액
					,(SELECT 장례식장명 FROM 장례식장 WHERE 장례식장코드 = A.장례식장코드) AS 장례식장명
					,A.시스템일자
			FROM	행사마스터 AS A (NOLOCK)
			INNER JOIN
					계약마스터4V AS B (NOLOCK)
			ON		A.계약상세코드 = B.계약상세코드
			INNER JOIN
					조직변경이력 AS F (NOLOCK)
			ON		B.수금사원코드 = F.사원코드 
			AND		CONVERT(VARCHAR(8),GETDATE(),112) BETWEEN F.시작일자 AND F.종료일자
			INNER JOIN
					#영업조직 AS C (NOLOCK)
			ON		F.사원코드 = C.사원코드
			WHERE	(CASE WHEN @조회구분 = '입관일자' THEN A.입관일자
						 WHEN @조회구분 = '행사접수일자' THEN CONVERT(VARCHAR(10),A.접수일자,112)
						 ELSE A.발인일자 END) BETWEEN @시작일자 AND @종료일자
			AND		(CASE WHEN @사원코드 = '' THEN ISNULL(@사원코드,'') ELSE B.수금사원코드 END = ISNULL(@사원코드,''))
			AND		(CASE WHEN @본부코드 = '' THEN ISNULL(@본부코드,'') ELSE F.본부코드 END = ISNULL(@본부코드,''))
			AND		(CASE WHEN @지사코드 = '' THEN ISNULL(@지사코드,'') ELSE F.지사코드 END = ISNULL(@지사코드,''))
			AND		(CASE WHEN @지점코드 = '' THEN ISNULL(@지점코드,'') ELSE F.지점코드 END = ISNULL(@지점코드,''))
			AND		(CASE WHEN @팀코드   = '' THEN ISNULL(@팀코드,'')   ELSE F.팀코드   END = ISNULL(@팀코드,''))
			AND		ISNULL(A.상주,'') 		LIKE '%'+ ISNULL(@상주명,'')+'%'
			AND		ISNULL(A.고인성명,'')	LIKE '%'+ ISNULL(@고인성명,'') +'%'
			AND		ISNULL(B.회원명,'')	LIKE '%'+ ISNULL(@회원명,'') +'%'
		END --END OF ELSE : @행사코드 <> '' OR 계약코드 <> ''


		IF ISNULL(@오등록포함,'N') = 'N' DELETE #장례리스트 WHERE 취소구분 = '00006'

		UPDATE	 A
		SET		 A.의전팀장코드 = B.사원코드
				,A.의전팀장 = C.사원명
				,A.의전팀장소속 = C.소속조직명
		FROM	#장례리스트 AS A
		INNER JOIN
				행사인력 AS B (NOLOCK)
		ON		A.행사코드 = B.행사코드
		AND		B.참여구분 = '의전팀장'
		INNER JOIN
				사원마스터V AS C (NOLOCK)
		ON		B.사원코드 = C.사원코드
		
		UPDATE	A
		SET		의전팀장지역 = B.권역명
		FROM	#장례리스트 AS A
		INNER JOIN
				(SELECT 사원코드,권역명
				 FROM	영업자격관리 A (NOLOCK)
				 INNER JOIN
						권역마스터 B (NOLOCK)
				 ON		B.업무구분 = '의전팀장'
				 AND	A.관리지역코드 = B.권역코드
				 WHERE 	A.자격상태 = '정상'
				)B
		ON		A.의전팀장코드 = B.사원코드 
		WHERE	ISNULL(의전팀장코드,'') <> ''

		IF ISNULL(@의전팀장,'') != ''
		BEGIN
			DELETE #장례리스트 WHERE 의전팀장코드 <> ISNULL(@의전팀장,'')
		END --END OF IF

		--결과
		SELECT	 행사시작일자
				,접수일자
				,행사상태	
				,회원코드	
				,회원명		
				,계약코드	
				,상주명		
				,고인명		
				,즉발행사구분
				,행사코드	
				,의전팀장코드
				,의전팀장	
				,의전팀장소속 
				,의전팀장지역
				,취소구분	
				,상품코드
				,계약상품명
				,상품총액
				,장례식장명	
				,시스템일자	
		FROM	#장례리스트 (NOLOCK)
		ORDER BY 시스템일자 DESC
	END --END OF IF : @구분 = '리스트조회'



	IF @구분 = '상세조회'
	BEGIN
		SELECT B.라인번호, B.행사코드, B.SEQ, B.구분, B.사원코드, E.사원명, B.영업자격코드,B.행사구분,B.참여구분,B.전문상례사여부
				,(SELECT 휴대폰 FROM 사원마스터 (NOLOCK) WHERE 사원코드 = B.사원코드) AS 휴대폰
		INTO	#행사인력
		FROM	행사인력 AS B (NOLOCK)
		INNER JOIN
				사원마스터 AS E (NOLOCK)
		ON		B.사원코드 = E.사원코드				
		WHERE	B.행사코드 = @행사코드
		AND		B.참여구분 = '의전팀장'

		SELECT	 F.라인번호, A.회원코드 ,A.회원명 ,A.회원구분, A.회원상세구분, dbo.f_전화번호포맷(A.휴대폰) AS 휴대폰, A.주민번호,A.성별
				,A.계약코드, A.계약상세코드, A.계약일자, A.계약상태, A.계약회차, A.납입방법
				,A.납입회차 AS 납입회차, A.납입금액 AS 납입금액
				,A.잔여회차

				--,A.잔여금액 -- (상품금액 - 납입금액) :: 적용된 금액
				,A.상품총액 - (A.납입금액 + A.할인금액) AS 잔여금액 

				,A.상품총액, A.상품매출, A.할인정책,A.할인회차, A.할인금액, A.행사특별할인, A.상품코드,A.계약상품명, A.접수일자 , A.소속부서
				,A.모집사원코드, A.모집사원명, dbo.f_전화번호포맷(A.모집사원휴대폰) AS 모집사원휴대폰
				,(CASE  WHEN ISNULL(A.모집사원팀명,'') <> ''   THEN A.모집사원본부명 +'>'+A.모집사원지사명 +'>'+A.모집사원지점명 +'>'+A.모집사원팀명 
					 WHEN ISNULL(A.모집사원지점명,'') <> '' THEN A.모집사원본부명 +'>'+A.모집사원지사명 +'>'+A.모집사원지점명 
					 WHEN ISNULL(A.모집사원지사명,'') <> '' THEN A.모집사원본부명 +'>'+A.모집사원지사명 
					 WHEN ISNULL(A.모집사원본부명,'') <> '' THEN A.모집사원본부명 
				 END)	AS 모집사원조직
				,A.수금사원코드, A.수금사원명, dbo.f_전화번호포맷(A.수금사원휴대폰) AS 수금사원휴대폰
				,(CASE  WHEN ISNULL(A.수금사원팀명,'') <> ''   THEN A.수금사원본부명 +'>'+A.수금사원지사명 +'>'+A.수금사원지점명 +'>'+A.수금사원팀명 
					 WHEN ISNULL(A.수금사원지점명,'') <> '' THEN A.수금사원본부명 +'>'+A.수금사원지사명 +'>'+A.수금사원지점명 
					 WHEN ISNULL(A.수금사원지사명,'') <> '' THEN A.수금사원본부명 +'>'+A.수금사원지사명 
					 WHEN ISNULL(A.수금사원본부명,'') <> '' THEN A.수금사원본부명 
				 END)	AS 수금사원조직
				,A.행사코드 ,A.행사상태 ,A.외주구분 ,A.지역,A.지역명
				, A.창고지역
				,(SELECT 창고명 FROM 창고코드 (NOLOCK) WHERE 창고코드 = A.창고지역) AS 창고지역명
				,A.창고지역상세
				,(SELECT 창고상세명 FROM 창고상세코드 (NOLOCK) WHERE 창고코드 = A.창고지역 AND 창고상세코드 = A.창고지역상세) AS 창고지역상세명
				,A.행사시작일자 ,A.행사시작시간 ,A.행사종료일자 ,A.행사종료시간
				,A.입관일자 ,A.입관시간 ,A.발인일자 ,A.발인시간 ,A.고인성명 AS 고인명 ,A.상주	AS 상주명 ,dbo.f_전화번호포맷(replace(A.상주휴대폰,'-','')) AS 상주연락처
				,A.장례식장코드 ,A.장례식장, A.장례식장주소, A.운구여부 ,A.장례형태 AS 장법 ,A.장지1차 ,A.장지2차
				,A.비고+' '+ISNULL(CONVERT(VARCHAR,A.행사특이사항),'') AS 비고
				,A.즉발행사구분 ,A.행사상품코드	
				,A.장례상품명 AS 행사상품명, A.종교					
				,F.SEQ		  AS 지도사SEQ
				--,F.사원코드	  AS 지도사코드
				--,F.사원명	  AS 지도사명
				,A.의전팀장코드	  AS 지도사코드
				,A.의전팀장명	  AS 지도사명
				,(CASE  WHEN ISNULL(A.의전팀장팀명,'') <> ''   THEN A.의전팀장본부명 +'>'+A.의전팀장지사명 +'>'+A.의전팀장지점명 +'>'+A.의전팀장팀명 
					 WHEN ISNULL(A.의전팀장지점명,'') <> '' THEN A.의전팀장본부명 +'>'+A.의전팀장지사명 +'>'+A.의전팀장지점명 
					 WHEN ISNULL(A.의전팀장지사명,'') <> '' THEN A.의전팀장본부명 +'>'+A.의전팀장지사명 
					 WHEN ISNULL(A.의전팀장본부명,'') <> '' THEN A.의전팀장본부명 
				 END)	AS 의전팀장조직
				,A.계약자명, A.계약자휴대폰
				,dbo.f_전화번호포맷(F.휴대폰)		  AS 지도사휴대폰
				,(SELECT 소속조직명 FROM 사원마스터V (NOLOCK) H WHERE H.사원코드 = F.사원코드)  AS 지도사조직
				,F.영업자격코드	AS 지도사자격코드
				,F.참여구분		AS 지도사상세분류
				,A.발생장소,A.관계,A.상주목록,A.접수인
				,dbo.f_전화번호포맷(replace(A.접수인연락처,'-','')) AS 접수인연락처
				,A.감독관코드
				,A.감독관명
				,A.정산완료일 
				,A.고인성별
				,A.연령
				,A.부고사유
				,A.빈소
				,A.앰뷸런스
				,A.협력업체_차량
				,(SELECT 거래처명 FROM 거래처마스터 (NOLOCK) WHERE 거래처코드 = a.협력업체_차량) AS 협력업체_차량명
				,A.협력업체_화환
				,(SELECT 거래처명 FROM 거래처마스터  (NOLOCK) WHERE 거래처코드 = a.협력업체_화환) AS 협력업체_화환명
				,A.협력업체_상복
				,(SELECT 거래처명 FROM 거래처마스터 (NOLOCK) WHERE 거래처코드 = a.협력업체_상복) AS 협력업체_상복명
				,A.협력업체_도우미
				,(SELECT 지역명 FROM 지역마스터 (NOLOCK) WHERE 지역코드 = a.협력업체_도우미) AS 협력업체_도우미명
				,A.협력업체_장지
				,(SELECT 거래처명 FROM 거래처마스터(NOLOCK)  WHERE 거래처코드 = a.협력업체_장지) AS 협력업체_장지명
				,A.협력업체_유골함
				,(SELECT 거래처명 FROM 거래처마스터 (NOLOCK) WHERE 거래처코드 = a.협력업체_유골함) AS 협력업체_유골함명
				,A.상황부여
				,A.도착시간
				,A.출동시간
				,A.완료시간
				,A.수의구분
				,A.기타구분
				,A.장지구분
				,A.상품이미지경로
				,A.취소일자 
				,A.취소시간
				,A.취소구분 ,A.취소상세 ,A.취소사유 AS 취소내용 
		FROM	장례행사마스터V AS A (NOLOCK)
		LEFT OUTER JOIN 
				#행사인력 AS F (NOLOCK)
		ON		F.행사코드	= A.행사코드 
		WHERE   A.행사코드 = @행사코드

		DROP TABLE #행사인력;
	END --END OF IF : @구분 = '상세조회'

	--TMP TABLE DROP-------
	DROP TABLE #장례리스트
	DROP TABLE #영업조직
	
END

