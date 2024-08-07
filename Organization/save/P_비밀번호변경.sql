USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_비밀번호변경]    Script Date: 2024-07-29 오후 1:45:18 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		손혜진
-- Create date: 2020.07.01
-- Description:	비밀번호 변경
-- =============================================
ALTER PROCEDURE [dbo].[P_비밀번호변경](
	 @사원코드		VARCHAR(15) = ''
	,@비밀번호		VARCHAR(152) = ''
	,@이전비밀번호	VARCHAR(152) = ''
)
	
AS
BEGIN	
	SET NOCOUNT ON;

	DECLARE @N변경일자 VARCHAR(8)

	SET @N변경일자 = CONVERT(VARCHAR(8),GETDATE(),112);
	SET @비밀번호 = @비밀번호;

	UPDATE	A
	SET		A.비밀번호 = @비밀번호
	FROM	사원마스터 AS A with (NOLOCK)
	WHERE	사원코드 = @사원코드
	
	UPDATE	 A
	SET		 NO_PASSWORD   = @비밀번호
			,NO_BFPASSWORD = @이전비밀번호
			,LOGINCNT      = 0 
			,DT_PASSWORD   = @N변경일자
	FROM	 SY_SYSUSER AS A  with (NOLOCK)
	WHERE	 NO_EMP = @사원코드
	
	-- 비밃전호변경이력 등록
	IF @@ROWCOUNT > 0
	BEGIN
		-- 이전 비밀번호이력 종료일자 설정
		UPDATE	A
		SET     A.종료일자 = CONVERT(VARCHAR(8),DATEADD(DD,-1,@N변경일자),112)
		FROM	SY_비밀번호이력 AS A with (NOLOCK)
		WHERE	사원코드 = @사원코드
		AND		종료일자 = (
								SELECT	MAX(종료일자) AS 종료일자
								FROM	SY_비밀번호이력 with (NOLOCK)
								WHERE	사원코드 = @사원코드
								GROUP BY 사원코드
							)

		INSERT INTO SY_비밀번호이력 (
			 사원코드,생성일자,종료일자,비밀번호
		) VALUES (
			@사원코드,@N변경일자,CONVERT(VARCHAR(8),DATEADD(MM,6,@N변경일자),112),@비밀번호  --유효기간 6개월
		)
	END
END

