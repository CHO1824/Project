USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_가족정보관리]    Script Date: 2024-07-29 오후 1:49:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		정경윤
-- Create date: 2018.07.07
-- Description:	가족정보관리
-- =============================================
ALTER PROCEDURE [dbo].[P_가족정보관리](
	 @구분				VARCHAR(1)		= 'S'
	,@사원코드  		VARCHAR(15)		= ''
	,@주민번호			VARCHAR(13)		= ''
	,@일련번호			INT				= 0
	,@성명				VARCHAR(30)		= ''
	,@생년월일			VARCHAR(10)		= ''
	,@생일구분			VARCHAR(2)		= ''
	,@성별				VARCHAR(2)		= ''
	,@관계				VARCHAR(20)		= ''
	,@직업				VARCHAR(30)		= ''
	,@학력				VARCHAR(20)		= ''
	,@동거구분			VARCHAR(10)		= ''
	,@등록자			VARCHAR(9)		= ''
	,@비고				VARCHAR(100)	= ''
)
	
AS
BEGIN	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @구분 IN ('I','U')
	BEGIN
		 UPDATE A
		 SET 	--주민번호		= @주민번호,	
				성명			= @성명,
				생년월일		= @생년월일,
				생일구분		= @생일구분,
				성별			= @성별,
				관계			= @관계,		
				직업			= @직업,	
				학력			= @학력,	
				동거구분		= @동거구분,	
				등록자			= @등록자,	
				비고			= @비고	
		 FROM	사원가족정보 AS A 
		 WHERE	사원코드		= @사원코드
		 AND	일련번호	    = @일련번호
       
		IF @@ROWCOUNT = 0
		BEGIN	
  			INSERT 사원가족정보 
				  ( 사원코드,주민번호,	성명, 생년월일, 생일구분, 성별, 관계, 직업,학력,동거구분,등록자,비고)
			VALUES
				  ( @사원코드,@주민번호,	@성명, @생년월일, @생일구분, @성별, @관계,@직업,@학력,@동거구분,@등록자,@비고 )	
		END	
	END

	IF @구분 = 'D'	
	BEGIN		
		DELETE	A
		FROM	사원가족정보 AS A 
		WHERE	사원코드	= @사원코드
		AND		일련번호	    = @일련번호
	END
END



