USE [happy]
GO
/****** Object:  StoredProcedure [dbo].[P_INSA_인사_증명서발급_제증명서신청복지사_조회]    Script Date: 2024-02-26 오후 1:52:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		조하영
-- Create date: 2023.02.23
-- Description:	P_INSA_증명서신청발급_조회
-- SELECT * FROM 인사_증명서발급
-- SELECT * FROM 행사사원마스터V


-- EXEC P_INSA_인사_증명서발급_제증명서신청복지사_조회 '20010101', '99991231'

-- =============================================
ALTER PROCEDURE [dbo].[P_INSA_인사_증명서발급_제증명서신청복지사_조회]
		 @구분				AS VARCHAR(10) = ''
		,@신청일자_첫째날	AS VARCHAR(8) = ''
		,@신청일자_현재		AS VARCHAR(8) = ''
		,@진행상태			AS VARCHAR(2) = ''
		,@대상구분			AS VARCHAR(2) = ''
		,@증명서종류		AS VARCHAR(2) = ''
		,@대상사원코드		AS VARCHAR(10) = ''
AS
BEGIN
	
	SET NOCOUNT ON;

	IF @구분 = 'S'
	BEGIN

		SELECT	  A.일련번호
				, A.문서번호
				, A.신청일자
				, A.진행상태
				, D.NM_CODE			AS 진행상태명
				, A.대상구분
				, E.NM_CODE			AS 대상구분명
				, A.대상사원코드
				, B.퇴사일자
				, A.증명서종류
				, F.NM_CODE			AS 증명서명
				, A.출력여부
				, A.출력일자
				, A.발급용도
				, A.발급수량
				, A.수령방법
				, A.수령상세주소
				, A.비고
				, (CASE WHEN A.진행상태 = '01' THEN '0' ELSE '1' END)	AS 승인처리
				, (CASE WHEN ISNULL(A.승인일자,'') != '' THEN H.사원명 ELSE '' END)		AS 승인사원코드
				, (CASE WHEN A.진행상태 = '03' THEN A.승인일자 ELSE A.승인일자 END)		AS 승인일자
				, DATEDIFF(DAY, A.승인일자, GETDATE()) AS 일차이		-- 승인일자로부터 7일지난 증명서는 출력 안되게 해달라는 요청으로 일수 계산로직 추가 2024.01.24 조하영

				--리포트내용
				, B.사원명		AS 대상사원명
				, B.주민번호
				, '사업소득자(장례복지사)'		AS 소속
				, ISNULL(LEFT(B.퇴사일자,4),'') +'년 '+ISNULL(SUBSTRING(B.퇴사일자,5,2),'')+'월 '+ISNULL(RIGHT(B.퇴사일자,2),'')+'일'	AS 해촉일
				--, G.조직명
				, A.근무일자
				, FORMAT(GETDATE(),'yyyy년 MM월 dd일')		AS 현재일자
				, (SELECT 사업자번호 FROM 인사_법인정보 (NOLOCK) WHERE 법인코드 = '1000')	AS 사업자번호
				, (SELECT 법인명 FROM 인사_법인정보 (NOLOCK) WHERE 법인코드 = '1000')	 AS 회사명
				, (SELECT 주소 FROM 인사_법인정보 (NOLOCK) WHERE 법인코드 = '1000')		AS 회사주소
				, (SELECT '대표이사           '+대표자명 FROM 인사_법인정보 (NOLOCK) WHERE 법인코드 = '1000')		AS 대표자명
				, (SELECT 'https://fsp.soffice.co.kr/REPORT/UbiFile/happy/comImg/'+'happy_logo.jpg' FROM 인사_법인정보 WHERE 법인코드 = '1000')		AS 회사로고이미지
				, (SELECT 'https://fsp.soffice.co.kr/REPORT/UbiFile/happy/comImg/'+'corporateseal.jpg' FROM 인사_법인정보 WHERE 법인코드 = '1000')	AS 법인도장이미지
				, 'https://fsp.soffice.co.kr/REPORT/UbiFile/happy/comImg/'+ 'happy_logo.jpg'	AS 해피엔딩이미지
				, (SELECT 'Tel. '+전화번호 FROM 인사_법인정보 WHERE 법인코드 = '1000') + ' / ' + (SELECT 'FAX. '+ 팩스번호 FROM 인사_법인정보 WHERE 법인코드 = '1000')	AS 팩스전화

				, A.등록자
				, A.등록일자
				, A.수정자
				, A.수정일자
		FROM 인사_증명서발급 AS A (NOLOCK)
		INNER JOIN 행사사원마스터v AS B (NOLOCK) 
		ON		A.대상사원코드 = B.행사사원코드
		LEFT OUTER JOIN SY_HRCODE AS D (NOLOCK) 
		ON		D.CL_CODE = 'IS17' AND A.진행상태 = D.CD_CODE
		LEFT OUTER JOIN SY_HRCODE AS E (NOLOCK) 
		ON		E.CL_CODE = 'IS23' AND A.대상구분 = E.CD_CODE
		LEFT OUTER JOIN SY_HRCODE AS F (NOLOCK) 
		ON		F.CL_CODE = 'IS24' AND A.증명서종류 = F.CD_CODE
		INNER JOIN 조직마스터V AS G (NOLOCK) 
		ON		B.조직코드 = G.조직코드
		LEFT OUTER JOIN 사원마스터V AS H (NOLOCK)
		ON		A.승인사원코드 = H.사원코드
		WHERE A.대상구분 LIKE '%' + ISNULL(@대상구분, '') + '%'
		AND   A.신청일자 BETWEEN @신청일자_첫째날 AND @신청일자_현재
		AND   A.진행상태 LIKE '%' + ISNULL(@진행상태, '') + '%'
		AND   A.증명서종류 LIKE '%' + ISNULL(@증명서종류, '') + '%'
		AND	  A.대상사원코드 LIKE '%' + ISNULL(@대상사원코드, '') + '%'
		ORDER BY A.신청일자 DESC
	END

	IF @구분 = 'S1'
	BEGIN
		SELECT 행사사원코드, 사원명
		FROM 행사사원마스터v
		WHERE 행사사원코드 LIKE '%' + ISNULL(@대상사원코드, '') + '%'
	END

END