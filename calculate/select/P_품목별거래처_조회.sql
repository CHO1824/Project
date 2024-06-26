USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_품목별거래처_조회]    Script Date: 2024-05-17 오후 4:15:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		손혜진
-- Create date: 2019.01.18
-- Description:	품목별 거래처
-- EXEC P_품목별거래처_조회 '장례','00027','정상거래'
-- =============================================
ALTER PROCEDURE [dbo].[P_품목별거래처_조회]
 @행사구분	 AS VARCHAR(10) = ''
,@구성품코드 AS VARCHAR(10) = ''
,@거래상태	 AS VARCHAR(10) = ''

AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @재고여부 VARCHAR(1) = ''

	SELECT	@재고여부 = ISNULL(재고관리여부,'N')
	FROM	행사구성품
	WHERE	구성품코드 = ISNULL(@구성품코드,'')

    IF EXISTS (	SELECT 'X'
				FROM	거래처품목단가 (NOLOCK)
				WHERE	구성품코드 = ISNULL(@구성품코드,'')
				AND		CONVERT(VARCHAR(10),GETDATE(),112) BETWEEN 시작일자 AND 종료일자
	) OR @재고여부 = 'Y'
	BEGIN
		SELECT	A.거래처코드
		,A.거래처명
		,B.구성품코드
		,C.구성품명
		,B.매입단가
		,B.판매단가
		,B.추가단가
		,C.단위
		,C.수량
		,C.재고관리여부
		,A.사업자등록번호
		,A.사업자대표자
		,A.사업자우편주소+' '+사업자상세주소 AS 사업자주소
		FROM	거래처마스터 AS A (NOLOCK)
		INNER JOIN
				거래처품목단가 AS B (NOLOCK)
		ON		A.거래처코드 = B.거래처코드 AND CONVERT(VARCHAR(10),GETDATE(),112) BETWEEN B.시작일자 AND B.종료일자
		INNER JOIN
				행사구성품 AS C (NOLOCK)
		ON		C.구성품코드 =  ISNULL(@구성품코드,'') 
		AND		B.구성품코드 = C.구성품코드 	
		AND		C.사용구분 = 'Y'
		WHERE	A.거래상태 LIKE ISNULL(@거래상태,'') +'%'
		AND		A.거래처구분 = ISNULL(@행사구분,'')
	END
	ELSE
	BEGIN
		SELECT	A.거래처코드
		,A.거래처명
		,'' AS 구성품코드
		,''	AS 구성품명
		,0	AS 매입단가
		,0	AS 판매단가
		,0	AS 추가단가
		,'' 단위
		,0	AS 수량
		,'' AS 재고관리여부
		,A.사업자등록번호
		,A.사업자대표자
		,A.사업자우편주소+' '+사업자상세주소 AS 사업자주소
		FROM	거래처마스터 AS A (NOLOCK)
		WHERE	A.거래상태 LIKE ISNULL(@거래상태,'') +'%'
		AND		A.거래처구분 = ISNULL(@행사구분,'')
	END
END
