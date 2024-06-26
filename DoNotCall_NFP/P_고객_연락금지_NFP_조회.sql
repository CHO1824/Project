USE [NationalFP]
GO
/****** Object:  StoredProcedure [dbo].[P_고객_연락금지_NFP_조회]    Script Date: 2024-04-30 오후 1:12:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조하영
-- Create date: 2023.11.15
-- Description:	P_고객_연락금지_NFP_조회

-- exec P_고객_연락금지_NFP_조회 '','20000101','99991231',''
-- =============================================
ALTER PROCEDURE [dbo].[P_고객_연락금지_NFP_조회]
    @구분			AS VARCHAR(5) =''
	,@본부코드		AS VARCHAR(7) = ''
    ,@시작일자		AS VARCHAR(10) = ''
    ,@종료일자		AS VARCHAR(10) = ''
    ,@고객명		AS VARCHAR(100) = ''
AS
BEGIN
    SET NOCOUNT ON;

    SET @고객명 = ISNULL(@고객명,'')
    SET @본부코드 = ISNULL(@본부코드,'')

	IF @구분 = 'S'
	BEGIN
		SELECT	 A.일련번호
				,A.담당설계사코드
				,B.사원명			AS 담당설계사명
				,B.본부명			AS 사업단
				,A.고객명
				,A.고객사연락처
				,A.콜접수일자
				,A.연락금지요청일자
				,A.접수자
				,A.설계사전달일자
				,A.설계사확인유무일자
				,A.등록자
				,A.등록일자
				,A.수정자
				,A.수정일자
		FROM    고객_연락금지_NFP AS A (NOLOCK)
		INNER JOIN
		         사원마스터V AS B (NOLOCK)
		ON      A.담당설계사코드 = B.사원코드
		WHERE   A.콜접수일자 BETWEEN @시작일자 AND @종료일자
		AND		B.본부코드 LIKE @본부코드+'%'
		AND     A.고객명	   LIKE '%' + @고객명 + '%'
	END

	IF @구분 = 'S1'
	BEGIN
		SELECT DISTINCT 본부코드 AS 코드
				, 본부명 AS 명칭
		FROM 조직마스터V (NOLOCK) 
		WHERE ISNULL(본부코드,'') <> ''
		UNION
		SELECT '00000','전체'
		ORDER BY 1
	END
END