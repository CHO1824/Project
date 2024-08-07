USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_이행보증이력관리]    Script Date: 2024-07-29 오후 1:53:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		정경윤
-- Create date: 2018.07.08
-- Description:	이행보증이력관리
-- =============================================
ALTER PROCEDURE [dbo].[P_이행보증이력관리](
	 @구분				varchar(1)	= 'S'
	,@사원코드  		varchar(15)	= ''
	,@보증보험구분		varchar(20) = ''
	,@시작일자			varchar(10)
	,@종료일자			varchar(10) = ''
	,@가입일자			varchar(10) = ''
	,@증권번호			varchar(30) = ''
	,@가입금액			int = 0
	,@연대보증인		varchar(100) = ''
	,@비고				varchar(200) = ''
	,@등록자			varchar(15) = ''	
)
	
AS
BEGIN	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @구분 IN('I','U')
	BEGIN
		 UPDATE A
		   SET 	가입일자		= @가입일자,
				증권번호		= @증권번호,
				가입금액		= @가입금액,
				연대보증인		= @연대보증인,		
				비고			= @비고,	
				등록자			= @등록자
		 FROM	이행보증이력 AS A 
		 WHERE	사원코드		= @사원코드
		 AND	보증보험구분	= @보증보험구분
		 AND	시작일자	    = @시작일자
		 AND	종료일자	    = @종료일자 

		IF @@ROWCOUNT = 0
		BEGIN	
  			INSERT 이행보증이력 
				  ( 사원코드, 보증보험구분,	시작일자, 종료일자, 가입일자, 증권번호, 가입금액, 연대보증인, 비고, 등록자)
			 VALUES
				  ( @사원코드, @보증보험구분, @시작일자, @종료일자, @가입일자, @증권번호, @가입금액, @연대보증인, @비고, @등록자)	
		END	
	END

	IF @구분 = 'D'
	BEGIN		
		DELETE	A
		FROM	이행보증이력 AS A
		WHERE	사원코드		= @사원코드
		AND		보증보험구분	= @보증보험구분
		AND		시작일자	    = @시작일자
		AND		종료일자	    = @종료일자
	END
END




