USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_장례행사내용]    Script Date: 2024-05-17 오후 4:05:43 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조하영
-- Create date: 2017.04.05
-- Description:	장례행사내용 저장
-- =============================================
ALTER PROCEDURE [dbo].[P_장례행사내용]
@구분				AS VARCHAR(2)	= 'S'
, @행사코드			AS VARCHAR(15)	= ''
, @리무진업체		AS VARCHAR(10)	= ''
, @리무진복장상태	AS VARCHAR(10)	= ''
, @리무진청결상태	AS VARCHAR(10)	= ''
, @리무진친절상태	AS VARCHAR(10)	= ''
, @리무진특이사항	AS VARCHAR(200)	= ''
, @제단업체			AS VARCHAR(10)	= ''
, @제단상태			AS VARCHAR(10)	= ''
, @제단도착시간		AS VARCHAR(10)	= ''
, @제단특이사항		AS VARCHAR(200)	= ''
, @버스업체			AS VARCHAR(10)	= ''
, @버스복장상태		AS VARCHAR(10)	= ''
, @버스청결상태		AS VARCHAR(10)	= ''
, @버스친절상태		AS VARCHAR(10)	= ''
, @버스특이사항		AS VARCHAR(200)	= ''
, @양복업체			AS VARCHAR(10)	= ''
, @양복상태			AS VARCHAR(10)	= ''
, @양복도착시간		AS VARCHAR(5)	= ''
, @한복업체			AS VARCHAR(10)	= ''
, @한복상태			AS VARCHAR(10)	= ''
, @한복도착시간		AS VARCHAR(5)	= ''
, @셔츠업체			AS VARCHAR(10)	= ''
, @셔츠상태			AS VARCHAR(10)	= ''
, @셔츠도착시간		AS VARCHAR(5)	= ''
, @상복특이사항		AS VARCHAR(200)	= ''
, @장례1일차		AS VARCHAR(400)	= ''
, @장례2일차		AS VARCHAR(200)	= ''
, @장례3일차		AS VARCHAR(200)	= ''
, @장례4일차		AS VARCHAR(200)	= ''
, @장례5일차		AS VARCHAR(200)	= ''

, @등록자			AS VARCHAR(15)	= ''

AS
BEGIN

	SET NOCOUNT ON;

	IF @구분 = 'IU'
	BEGIN
		UPDATE A
		SET 	  리무진업체 = @리무진업체
				, 리무진복장상태 = @리무진복장상태
				, 리무진청결상태 = @리무진청결상태
				, 리무진친절상태 = @리무진친절상태
				, 리무진특이사항 = @리무진특이사항
				, 제단업체 = @제단업체
				, 제단상태 = @제단상태
				, 제단도착시간 = @제단도착시간
				, 제단특이사항 = @제단특이사항
				, 버스업체 = @버스업체
				, 버스복장상태 = @버스복장상태
				, 버스청결상태 = @버스청결상태
				, 버스친절상태 = @버스친절상태
				, 버스특이사항 = @버스특이사항
				, 양복업체 = @양복업체
				, 양복상태 = @양복상태
				, 양복도착시간 = @양복도착시간
				, 한복업체 = @한복업체
				, 한복상태 = @한복상태
				, 한복도착시간 = @한복도착시간
				, 셔츠업체 = @셔츠업체
				, 셔츠상태 = @셔츠상태
				, 셔츠도착시간 = @셔츠도착시간
				, 상복특이사항 = @상복특이사항
				, 장례1일차 = @장례1일차
				, 장례2일차 = @장례2일차
				, 장례3일차 = @장례3일차
				, 장례4일차 = @장례4일차
				, 장례5일차 = @장례5일차
		FROM	장례행사내용	AS A (NOLOCK)
		WHERE	행사코드 = @행사코드
		
		IF @@ROWCOUNT <=0
		BEGIN 
	
			INSERT INTO 장례행사내용 (
					행사코드, 리무진업체, 리무진복장상태, 리무진청결상태, 리무진친절상태, 리무진특이사항
					, 제단업체, 제단상태, 제단도착시간, 제단특이사항
					, 버스업체, 버스복장상태, 버스청결상태, 버스친절상태, 버스특이사항
					, 양복업체, 양복상태, 양복도착시간, 한복업체, 한복상태, 한복도착시간, 셔츠업체, 셔츠상태, 셔츠도착시간, 상복특이사항
					, 장례1일차, 장례2일차, 장례3일차, 장례4일차, 장례5일차, 등록자
			)
			VALUES (
					@행사코드, @리무진업체, @리무진복장상태, @리무진청결상태, @리무진친절상태, @리무진특이사항
					, @제단업체, @제단상태, @제단도착시간, @제단특이사항
					, @버스업체, @버스복장상태, @버스청결상태, @버스친절상태, @버스특이사항
					, @양복업체, @양복상태, @양복도착시간, @한복업체, @한복상태, @한복도착시간, @셔츠업체, @셔츠상태, @셔츠도착시간, @상복특이사항
					, @장례1일차, @장례2일차, @장례3일차, @장례4일차, @장례5일차, @등록자
			)
		END 
	END

	ELSE IF @구분 = 'D'
	BEGIN
		DELETE A FROM 장례행사내용 AS A(NOLOCK)
		WHERE	행사코드 = @행사코드
	END

   
END


