USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_행사진행물품_등록]    Script Date: 2024-05-17 오후 4:02:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조하영
-- Create date: 2024.04.24
-- Description:	행사정산 - 행사품목 조회

-- DROP PROC P_장례행사진행물품
-- EXEC P_행사진행물품  
-- =============================================
ALTER PROCEDURE [dbo].[P_행사진행물품_등록]	
	@MOD				AS VARCHAR(2)		= ''		
	, @행사코드			AS VARCHAR(15)		= ''	
	, @SEQ				AS BIGINT			= 0		
	, @구성품코드		AS VARCHAR(5)		= ''	
	, @행사상품코드		AS VARCHAR(15)		= ''	
	, @행사구분			AS VARCHAR(10)		= ''	
	, @구분				AS VARCHAR(10)		= ''	
	, @재고구분			AS VARCHAR(10)		= ''	
	, @수량				AS INT				= 0		
	--, @단위			AS VARCHAR(50)		= ''	
	--, @단가			AS NUMERIC(18, 0)	= 0		
	, @금액				AS NUMERIC(18, 0)	= 0		
	--, @판매금액		AS NUMERIC(18, 0)	= 0		
	--, @판매차액		AS NUMERIC(18, 0)	= 0		
	--, @할인금액		AS NUMERIC(18, 0)	= 0		
	, @결제방법			AS VARCHAR(10)		= ''	
	, @거래처코드		AS VARCHAR(10)		= ''	
	, @증빙구분			AS VARCHAR(10)		= ''	
	--, @수입수수료		AS NUMERIC(18, 0)	= 0		
	--, @추가수당회사	AS NUMERIC(18, 0)	= 0		
	--, @추가수당담당자	AS NUMERIC(18, 0)	= 0		
	--, @추가수당플래너	AS NUMERIC(18, 0)	= 0		
	--, @추가수당지도사	AS NUMERIC(18, 0)	= 0		
	--, @추가수당상례사	AS NUMERIC(18, 0)	= 0		
	--, @혼수입금일자	AS VARCHAR(10)		= ''	
	--, @혼수입금자명	AS VARCHAR(100)		= ''	
	, @비고				AS VARCHAR(200)		= ''	
	, @등록자			AS VARCHAR(15)		= ''	
	--, @혼수회사수당	AS NUMERIC(18, 0)	= 0
	--, @혼수담당자수당	AS NUMERIC(18, 0)	= 0
	--, @혼수플래너코드	AS VARCHAR(15)		= ''
	--, @혼수플래너수당	AS NUMERIC(18, 0)	= 0
	--, @화면구분		AS VARCHAR(15)		= ''
	--, @부가세			AS NUMERIC(18,0)	= 0
	, @업체추가지급액	AS NUMERIC(18,2)	= 0
	--, @창고지역		AS VARCHAR(10)		= 0
	--, @창고지역상세	AS VARCHAR(10)		= 0
	, @분류번호			AS VARCHAR(1)		= ''
	, @발행일자			AS VARCHAR(10)		= ''
	--, @승인번호		AS VARCHAR(50)		= ''

AS
BEGIN

	SET NOCOUNT ON;

    IF @MOD = 'IU'
	BEGIN
		/*
		IF @화면구분 <> '정산'
		BEGIN
			IF EXISTS (SELECT 'X' FROM 웨딩발주관리 WHERE 행사코드 = @행사코드 AND 행사품목코드 = @구성품코드 AND 결제방법 = '지급') 
			BEGIN
				RAISERROR('이미 거래처 정산이 완료되어 수정할 수 없습니다.!',16, 1, '', '', '');
				RETURN;
			END -- end of if
		END
		*/
		IF ISNULL(@구성품코드,'') = ''
		BEGIN
			RAISERROR('구성품코드가 없습니다.',16, 1, '', '', '')
			RETURN
		END

		UPDATE	A
		SET		구성품코드		= @구성품코드
				,재고구분		= @재고구분
				,수량			= ISNULL(@수량,0)
			--	,단위			= @단위
			--	,단가			= ISNULL(@단가	,0)
				,금액			= ISNULL(@금액	,0)
			--	,판매금액		= ISNULL(@판매금액,0)
			--	,판매차액		= ISNULL(@판매차액,0)
			--	,할인금액		= ISNULL(@할인금액,0)
				,결제방법		= @결제방법
				,거래처코드		= @거래처코드
				,증빙구분		= @증빙구분
			--	,수입수수료		= ISNULL(@수입수수료	,0)
			--	,추가수당회사	= ISNULL(@추가수당회사  ,0)
			--	,추가수당담당자 = ISNULL(@추가수당담당자,0)
			--	,추가수당플래너 = ISNULL(@추가수당플래너,0)
			--	,추가수당지도사 = ISNULL(@추가수당지도사,0)
			--	,추가수당상례사 = ISNULL(@추가수당상례사,0)
			--	,혼수입금일자	= @혼수입금일자
			--	,혼수입금자명	= @혼수입금자명
				,비고			= @비고
			--	,혼수회사수당	= ISNULL(@혼수회사수당  ,0)
			--	,혼수담당자수당 = ISNULL(@혼수담당자수당,0)
			--	,혼수플래너코드 = ISNULL(@혼수플래너코드,0)
			--	,혼수플래너수당 = ISNULL(@혼수플래너수당,0)
			--	,부가세			= ISNULL(@부가세,0)
				,구분			= @구분 --여행팀요청사항(10/30)
				,업체추가지급액 = ISNULL(@업체추가지급액,0)
			--	,창고지역		= @창고지역
			--	,창고지역상세	= @창고지역상세
				,분류번호		= @분류번호
				,발행일자		= @발행일자
			--	,승인번호		= @승인번호
		FROM	행사진행물품	AS A (NOLOCK)
		WHERE	행사코드 = @행사코드
		AND		SEQ = @SEQ
		
		IF @@ROWCOUNT <=0
		BEGIN 
			
			INSERT INTO 행사진행물품 (
				행사코드
				, 구성품코드
				, 행사상품코드
				, 행사구분
				, 구분
				, 재고구분
				, 수량
			--	, 단위
				--, 단가
				, 금액
				--, 판매금액
				--, 판매차액
			--	, 할인금액
				, 결제방법
				, 거래처코드
				, 증빙구분
				--, 수입수수료
				--, 추가수당회사
				--, 추가수당담당자
			--	, 추가수당플래너
				--, 추가수당지도사
				--, 추가수당상례사
				--, 혼수입금일자
				--, 혼수입금자명
				, 비고, 등록자
				--, 혼수회사수당
				--, 혼수담당자수당
				--, 혼수플래너코드
				--, 혼수플래너수당
				--, 부가세
				, 업체추가지급액
				--, 창고지역
				--, 창고지역상세
				, 분류번호
				, 발행일자
				--, 승인번호
			)
			VALUES (
				@행사코드
				, @구성품코드
				, @행사상품코드
				, @행사구분
				, @구분
				, @재고구분
				, ISNULL(@수량,0)
				--, @단위
				--, ISNULL(@단가	,0)
				, ISNULL(@금액	,0)
				--, ISNULL(@판매금액,0)
			--	, ISNULL(@판매차액,0)
				--, ISNULL(@할인금액,0)
				, @결제방법
				, @거래처코드
				, @증빙구분
			--	, ISNULL(@수입수수료	,0)
			--	, ISNULL(@추가수당회사  ,0)
				--, ISNULL(@추가수당담당자,0)
				--, ISNULL(@추가수당플래너,0)
				--, ISNULL(@추가수당지도사,0)
				--, ISNULL(@추가수당상례사,0)
			--	, @혼수입금일자
			--	, @혼수입금자명
				, @비고, @등록자
				--, ISNULL(@혼수회사수당  ,0)
				--, ISNULL(@혼수담당자수당,0)
				--, ISNULL(@혼수플래너코드,0)
			--	, ISNULL(@혼수플래너수당,0)
				--, ISNULL(@부가세,0)
				, ISNULL(@업체추가지급액,0)
				--, @창고지역
				--, @창고지역상세
				, @분류번호
				, @발행일자
			--	, @승인번호
			)	
		END 
		/*
		IF @행사구분 = '웨딩'
		BEGIN
			EXEC P_웨딩발주관리 'I',@행사코드,@거래처코드,@구성품코드,'N','','N','','N','','N','',0,'',@등록자
		END
		*/
	END -- end of if

	IF @MOD = 'D'
	BEGIN
		DELETE FROM 행사진행물품 WHERE 행사코드 = @행사코드 AND SEQ = @SEQ	
	END -- end of if
	
END