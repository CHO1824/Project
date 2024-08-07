USE [KwooErp]
GO
/****** Object:  UserDefinedFunction [dbo].[f_장례마감확인]    Script Date: 2024-08-08 오전 10:31:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: 김종진
-- Create date: 2018.05.30
-- Description:	장례마감확인
-- exec f_장례마감확인 '', '6189'
-- =============================================
ALTER FUNCTION [dbo].[f_장례마감확인]
(
	@업무일자	VARCHAR(10) -- 정산완료일자
	,@행사코드	VARCHAR(15)
)
RETURNS VARCHAR(500)
AS
BEGIN

	DECLARE 
		 @회계마감일자	VARCHAR(10)
		,@장례마감		VARCHAR(10)
		,@정산완료일	VARCHAR(10)
		,@월마감일자	VARCHAR(10)		
		,@RESULTVAR		VARCHAR(500);

	SET @RESULTVAR = '00 정상';

	-- 회계마감 체크
	-- 2019.01.22 손혜진 : 일마감 대신 행사마스터의 회계정산완료일로 체크
	--SELECT	@마감일자 = ISNULL(마감일자,'')
	--		,@장례마감 = ISNULL(장례마감,'진행')
	--FROM	일마감 (NOLOCK)
	--WHERE	영업일자 = @업무일자

	SELECT	@회계마감일자 = ISNULL(회계정산완료일,'')
	FROM	행사마스터 (NOLOCK)
	WHERE	행사코드 = @행사코드 

	
	IF ISNULL(@회계마감일자,'') <> ''
	BEGIN
		SET @RESULTVAR = '02 회계마감이 되어 수정작업이 불가 합니다.!';
	END;
	
	SELECT	@정산완료일 = ISNULL(정산완료일,'')
	FROM	행사마스터 (NOLOCK)
	WHERE	행사코드 = @행사코드

	IF ISNULL(@정산완료일,'') <> '' and @업무일자 <> ''
	BEGIN
		SET @RESULTVAR = '03 장례정산이 확정되어 수정작업이 불가 합니다.!';
	END

	RETURN @RESULTVAR;

END
