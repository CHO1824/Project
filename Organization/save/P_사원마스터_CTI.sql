USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_사원마스터_CTI]    Script Date: 2024-07-29 오후 1:56:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		정경윤
-- Create date: 2017.09.14
-- Description:	사원마스터_CTI할당 업데이트 
-- =============================================
ALTER PROCEDURE [dbo].[P_사원마스터_CTI] (
	 @CTI_ID	AS VARCHAR(20) 
	,@CTI_PWD	AS VARCHAR(20)
	,@CTI_EXT	AS VARCHAR(20)
	,@사원코드	AS VARCHAR(15)
	,@등록자	AS VARCHAR(15)
)
	
AS
BEGIN
	SET NOCOUNT ON;

	  UPDATE  A
		 SET  A.CTI_ID  = @CTI_ID	
		 	 ,A.CTI_PWD = @CTI_PWD
		 	 ,A.CTI_EXT = @CTI_EXT
		 	 ,A.수정자  = @등록자
			 ,A.수정일자= GETDATE()
		FROM 사원마스터 AS A (NOLOCK)
	   WHERE 사원코드 = @사원코드

END

