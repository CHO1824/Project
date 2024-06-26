USE [NationalFP]
GO
/****** Object:  StoredProcedure [dbo].[P_고객_연락금지_NFP_등록]    Script Date: 2024-04-30 오후 1:13:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조하영
-- Create date: 2023.11.16
-- Description:	P_고객_연락금지_NFP_등록
-- exec P_고객_연락금지_NFP_등록 'I', '1','10004', '홍길동', '01088889999', '20231117','20231117','홍길동','20231117','20231117',''

-- exec P_고객_연락금지_NFP_등록 'I','','10216','','','20231117','','','','','130001'
-- =============================================
ALTER PROCEDURE [dbo].[P_고객_연락금지_NFP_등록]
		 @구분					AS VARCHAR(1)	= ''
		, @일련번호				AS INT			= 0
		, @담당설계사코드		AS VARCHAR(20)	= ''
		, @고객명				AS VARCHAR(100)	= ''
		, @고객사연락처			AS VARCHAR(20)	= ''
		, @콜접수일자			AS VARCHAR(10)	= ''
		, @연락금지요청일자		AS VARCHAR(10)	= ''
		, @접수자				AS VARCHAR(10)	= ''
		, @설계사전달일자		AS VARCHAR(10)	= ''
		, @설계사확인유무일자	AS VARCHAR(10)	= ''
		, @등록자				AS VARCHAR(20)	= ''

AS
BEGIN

	SET NOCOUNT ON;

	IF @구분 = 'I'
	BEGIN
        UPDATE A
		SET     담당설계사코드			= @담당설계사코드
                , 고객명				= @고객명
                , 고객사연락처			= @고객사연락처
                , 콜접수일자			= @콜접수일자
                , 연락금지요청일자		= @연락금지요청일자
                , 접수자				= @접수자
                , 설계사전달일자		= @설계사전달일자
                , 설계사확인유무일자	= @설계사확인유무일자
                , 수정자				= @등록자
                , 수정일자				= GETDATE()
        FROM    고객_연락금지_NFP AS A
        WHERE   A.일련번호 = @일련번호

        IF @@ROWCOUNT <= 0
        BEGIN
            INSERT INTO 고객_연락금지_NFP(
				담당설계사코드, 고객명, 고객사연락처, 콜접수일자, 연락금지요청일자, 접수자, 설계사전달일자, 설계사확인유무일자, 등록자, 등록일자
            )VALUES(
                @담당설계사코드, @고객명, @고객사연락처, @콜접수일자, @연락금지요청일자, @접수자, @설계사전달일자, @설계사확인유무일자, @등록자, GETDATE()
            )
        END -- END OF IF
	END -- END OF IF

	IF @구분 = 'D'
	BEGIN
		DELETE A
		FROM 고객_연락금지_NFP AS A
		WHERE A.일련번호 = @일련번호
	END

END