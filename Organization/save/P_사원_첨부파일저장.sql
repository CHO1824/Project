USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_사원_첨부파일저장]    Script Date: 2024-07-29 오후 2:02:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		오원준
-- Create date: 2020.05.18
-- Description:	사원정보등록 서류페이지 첨부파일저장
-- EXEC P_사원_첨부파일저장 '1','1707533' ,'1' , '', '00002.jpg','' , 'C:\Users\soo\Desktop\00002.jpg' , '80206' , '80206001' ,'20200518','test' ,'Y' ,'130001' 
-- SELECT * FROM 사원_첨부파일
-- =============================================
ALTER PROCEDURE [dbo].[P_사원_첨부파일저장]
	 @MOD				NVARCHAR(2)		= 'i'
	,@사원코드			NVARCHAR(10)	= ''
	,@일련번호			BIGINT			= 0
	,@첨부서류명		NVARCHAR(100)	= ''
	,@파일명			NVARCHAR(100)	= ''
	,@파일사이즈		BIGINT			= 0
	,@파일경로			NVARCHAR(200)	= ''
	,@서류분류			VARCHAR(10)		= ''
	,@서류상세			VARCHAR(10)		= ''
	,@시행일자			VARCHAR(8)		= ''
	,@비고				VARCHAR(1000)	= ''
	,@업로드성공여부	VARCHAR(10)		= ''
	,@등록사원코드		NVARCHAR(10)	= ''

AS
BEGIN
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @n일련번호 AS BIGINT = 0;
	
	IF @MOD = 'i' AND @업로드성공여부 = 'Y'
	BEGIN
		UPDATE  X
		SET		X.첨부서류명 = @첨부서류명
				,X.파일명 = @파일명
				,X.파일경로 = @파일경로
				,X.서류분류 = @서류분류
				,X.서류상세 = @서류상세
				,X.시행일자 = @시행일자
				,X.비고 = @비고
				,X.수정사원코드 = @등록사원코드
				,X.수정일자 = GETDATE()
		FROM    사원_첨부파일 AS X
		WHERE	X.사원코드 = @사원코드
		AND		X.일련번호 = @일련번호

		IF @@ROWCOUNT =0
		BEGIN
			SET @n일련번호 = (SELECT ISNULL(MAX(일련번호),0)+1 FROM 사원_첨부파일 WHERE 사원코드 = @사원코드)

			INSERT INTO 사원_첨부파일(
					사원코드, 일련번호 ,첨부서류명, 파일명, 파일사이즈, 파일경로, 서류분류, 서류상세, 시행일자, 비고
					, 등록사원코드
			)VALUES(
					@사원코드, @n일련번호 ,@첨부서류명, @파일명, @파일사이즈, @파일경로, @서류분류, @서류상세, @시행일자, @비고
					, @등록사원코드
			)
		END;
	END; -- end of if 구분 : i

	IF @MOD = '1'
	BEGIN
		SELECT	'0' AS 체크
				,사원코드
				,일련번호
				,파일명
				,파일경로
				,서류분류
				,서류상세
				,시행일자
				,비고
				,'Y' AS 업로드성공여부
				,첨부서류명
				,파일사이즈
		FROM	 사원_첨부파일 (NOLOCK)
		WHERE	 사원코드 = @사원코드
		ORDER BY 시행일자 DESC
	END -- end of if 구분 : s

	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END