USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_사원정보조회]    Script Date: 2024-07-29 오후 1:25:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		정경윤
-- Create date: 2018.07.16
-- Description:	사원조회
-- EXEC P_사원정보조회 '20160034','130001'
-- =============================================
ALTER PROCEDURE [dbo].[P_사원정보조회]
@사원코드			AS VARCHAR(15) = ''
,@로그인사원코드	AS VARCHAR(15) = ''
AS
BEGIN
    SET NOCOUNT ON;

	-- ★ 로그인사원 업무관리-영업조직 
	CREATE TABLE #영업조직(
	  본부코드	 VARCHAR(7)
	 ,지사코드	 VARCHAR(7)
	 ,지점코드	 VARCHAR(7)
	 ,팀코드     VARCHAR(7)
	 ,사원코드	 VARCHAR(15)
	)

	-- ★ 로그인사원 업무관리-영업조직 
	INSERT INTO #영업조직(본부코드,지사코드,지점코드,팀코드,사원코드)
	SELECT DISTINCT 본부코드,지사코드,지점코드,팀코드,사원코드 
	FROM DBO.F_사원관리조직M(@로그인사원코드)

    SELECT   A.사원코드 
			,A.사원명
			,A.재직구분
			,A.주민번호
			,(CASE WHEN SUBSTRING(주민번호,7,1) IN('1','3') THEN '남'
				  WHEN SUBSTRING(주민번호,7,1) IN('2','4') THEN '여'
				  ELSE ''
			 END)					AS 성별
			,A.사원등록일자 		AS 입사일자 
			,A.퇴사일자 
			,A.지원서접수일
			,A.유치자코드 			AS 증원사원코드
			,A.증원사원명
			,A.사원구분
			,A.사원등급
			,A.대표사원코드
			,A.ERP사용구분 		AS ERP사용여부
			,dbo.f_전화번호포맷(A.휴대폰) AS 휴대폰
			,dbo.f_전화번호포맷(A.집전화) AS 집전화
			,A.자택우편번호
			,A.자택우편주소
			,A.자택도로명주소
			,A.자택상세주소
			,A.직장우편번호
			,A.직장우편주소
			,A.직장상세주소
			,A.은행코드
			,A.은행명
			,A.계좌번호
			,A.예금주
			,A.예금주주민번호
			,A.예금주관계
			,A.지급방법
			,A.EMail계정
			,A.EMail호스트
			,A.EMail호스트2
			,A.비밀번호
			,A.본부코드
			,A.본부명
			,A.지사코드
			,A.지사명
			,A.지점코드
			,A.지점명
			,A.팀코드
			,A.팀명
			,A.직급코드 
			,A.직급명 
			,A.비고
			,A.직급시작일자
			,A.직급종료일자
			,A.조직시작일자
			,A.조직종료일자
			,A.이미지경로
			,A.직책시작일자
			,A.직책종료일자
			,A.관리지역코드
			,A.관리지역명
			,A.CTI_ID
			,A.CTI_PWD
			,A.CTI_EXT
			,A.QR코드
			,A.세금구분
			,A.실거주지도로명주소
			,A.실거주지상세주소
			,A.실거주지우편번호
			,A.실거주지우편주소
			,A.신규승인
            ,A.입사신청서
			,A.SMS수신
			,A.세금성명
			,A.세금주민번호
			,A.세금사업자번호
			,A.생일
			,A.생일구분
			,A.결혼기념일
			,A.수당지급여부
			,dbo.f_전화번호포맷(A.직장전화) AS 직장전화
			,dbo.f_전화번호포맷(A.직장팩스) AS 직장팩스
			,A.실적본부코드
			,A.실적본부명
			,A.실적지사코드
			,A.실적지사명
			,A.실적지점코드
			,A.실적지점명
			,A.실적팀코드
			,A.실적팀명
	FROM	사원마스터V AS A (NOLOCK)
	INNER JOIN
			#영업조직 C (NOLOCK)
	ON		A.사원코드 = C.사원코드
	WHERE   A.사원코드 LIKE + ISNULL(@사원코드,'') + '%'
	
	
END