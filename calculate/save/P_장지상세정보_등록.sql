USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_장지상세정보_등록]    Script Date: 2024-05-17 오후 4:04:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		조하영
-- Create date: 2024.04.24
-- Description:	장지상세정보
-- =============================================
ALTER PROCEDURE [dbo].[P_장지상세정보_등록]
	@구분			AS VARCHAR(2)		= ''
	, @행사코드		AS VARCHAR(15)		= ''
	, @거래처코드	AS VARCHAR(10)		= ''
	, @거래처명		AS VARCHAR(50)		= ''
	, @상담사		AS VARCHAR(15)		= ''
	, @상담일시		AS VARCHAR(10)		= ''
	--, @연락처		AS VARCHAR(15)		= ''
	--, @화장장		AS VARCHAR(100)		= ''
	, @장지			AS VARCHAR(100)		= ''
	--, @안치단		AS VARCHAR(100)		= ''
	, @장묘방식		AS VARCHAR(10)		= ''
	, @기계약		AS VARCHAR(2)		= ''
	, @기계약일자	AS VARCHAR(10)		= ''
	--, @계약금액		AS NUMERIC(18, 0)	= 0
	, @수수료		AS NUMERIC(18, 0)	= 0
	, @수수료율		AS NUMERIC(5, 2)	= 0
	, @할인금액		AS NUMERIC(18, 0)	= 0
	, @할인율		AS NUMERIC(5, 2)	= 0
	, @고객확인서	AS VARCHAR(2)		= 0
	--, @부가세		AS NUMERIC(18, 0)	= 0
	--, @세금			AS NUMERIC(18, 0)	= 0
	--, @기타금액		AS NUMERIC(18, 0)	= 0
	--, @순익			AS NUMERIC(18, 0)	= 0
	--, @영업비		AS NUMERIC(18, 0)	= 0
	--, @입금액		AS NUMERIC(18, 0)	= 0
	--, @세후금액		AS NUMERIC(18, 0)	= 0
	--, @의전팀장수당 AS NUMERIC(18, 0)	= 0
	--, @회사수당		AS NUMERIC(18, 0)	= 0
	, @비고			AS VARCHAR(200)		= ''
	, @등록자		AS VARCHAR(15)		= ''
AS
BEGIN

	SET NOCOUNT ON;

    IF @구분 = 'IU'
	BEGIN
		UPDATE	A
		SET 	  거래처코드	= @거래처코드
				, 거래처명		= @거래처명
				, 상담사		= @상담사
				, 상담일시		= @상담일시
				--, 연락처		= @연락처
				--, 화장장		= @화장장
				, 장지			= @장지
				, 장묘방식		= @장묘방식
				, 기계약		= @기계약
				, 기계약일자	= @기계약일자
				--, 안치단		= @안치단
				--, 계약금액	= @계약금액
				, 수수료		= @수수료
				, 수수료율		= @수수료율
				, 할인금액		= @할인금액
				, 할인율		= @할인율
				, 고객확인서	= @고객확인서
				--, 부가세		= @부가세
				--, 세금			= @세금
				--, 기타금액		= @기타금액
				--, 순익			= @순익
				--, 영업비		= @영업비
				--, 입금액		= @입금액
				--, 세후금액		= @세후금액
				--, 의전팀장수당	= @의전팀장수당
				--, 회사수당		= @회사수당
				, 비고			= @비고
		FROM	장지상세 AS A
		WHERE	행사코드		= @행사코드

		IF @@ROWCOUNT <=0
		BEGIN 
	
			INSERT INTO 장지상세 (
				행사코드, 거래처코드, 거래처명, 상담사, 상담일시, 장지, 장묘방식, 기계약, 기계약일자, 수수료, 수수료율, 할인금액, 할인율
				, 고객확인서, 비고, 등록자
			)
			VALUES (
				@행사코드, @거래처코드, @거래처명, @상담사, @상담일시, @장지, @장묘방식, @기계약, @기계약일자, @수수료, @수수료율, @할인금액, @할인율
				,@고객확인서, @비고, @등록자
			)
		END 
	END

	ELSE IF @구분 = 'D'
	BEGIN
		DELETE A FROM 장지상세 AS A (NOLOCK)
		WHERE	행사코드 = @행사코드

	END
END


