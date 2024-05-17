USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_행사마스터_행사특이사항_등록]    Script Date: 2024-05-17 오후 4:08:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조하영
-- Create date: 2024.05.02
-- Description:	P_행사마스터_행사특이사항_등록
-- =============================================
ALTER PROCEDURE [dbo].[P_행사마스터_행사특이사항_등록]
	 @행사코드		AS VARCHAR(15)	= ''
	,@행사특이사항	AS TEXT			= ''
AS
BEGIN
	SET NOCOUNT ON;
		
		UPDATE	A
		SET		행사특이사항 = @행사특이사항
		FROM	행사마스터 AS A
		WHERE	행사코드 = @행사코드
END

