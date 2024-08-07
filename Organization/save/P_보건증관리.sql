USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_보건증관리]    Script Date: 2024-07-29 오후 1:53:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		정경윤
-- Create date: 2018.07.16
-- Description:	보건증관리
-- =============================================
ALTER PROCEDURE [dbo].[P_보건증관리](
	 @구분				VARCHAR(1)	= 'S'
	,@사원코드  		VARCHAR(15)	= ''
	,@보건증번호		VARCHAR(50) = ''
	,@검진일자			VARCHAR(10) = ''
	,@접수일자			VARCHAR(10) = ''
	,@등록자			VARCHAR(15) = ''
	
)
	
AS
BEGIN	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	IF @구분 IN ('I')
	BEGIN    	
  		INSERT 보건증관리 (
				사원코드 ,보건증번호 ,검진일자 ,접수일자 ,등록자
		) VALUES ( 
				@사원코드 ,@보건증번호 ,@검진일자 ,@접수일자 ,@등록자
		)	
	END

	IF @구분 IN ('U')
	BEGIN    	
  		UPDATE	A 
		SET		A.검진일자 = @검진일자 
				,A.접수일자 = @접수일자
		FROM	보건증관리 AS A 
		WHERE	A.사원코드 = @사원코드
		AND		A.보건증번호 = @보건증번호
	END

END




