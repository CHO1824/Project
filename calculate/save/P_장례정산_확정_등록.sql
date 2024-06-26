USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_장례정산_확정_등록]    Script Date: 2024-05-17 오후 4:09:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:
-- Create date:
-- Description:	장례정산 확정

/*
행사정산화면 :: 저장버튼 기능 
FSP :: EVENT_N_60100300_MASTER_U
UPDATE	A
SET		특별할인 = #행사특별할인#
		,의전팀장입금일	  = #의전팀장입금일#
		,의전팀장실입금액 = #의전팀장실입금액#
		,현금납입부금 = #현금납입부금#
		,카드납입부금 = #카드납입부금#
		,수정자   = #gds_userInfo.사원코드# 
		,수정일자 = getdate()	
		,행사상태 = '완료'
FROM	행사마스터 A WITH(NOLOCK)
WHERE	행사코드 = #행사코드#

select * from 수납마스터 where 계약상세코드 = '17047357D01'
select * from 행사마스터 where 계약상세코드 = '17047357D01'
select * from 계약업무이력 where 계약상세코드 = '17047357D01'

exec P_장례정산_확정 @행사코드,@계약상세코드,@회원코드,@행사상태,@정산완료일,@등록자

exec P_장례정산_확정 '10001181','17047357D01','SJ17042153','완료','20200625','130001'

6/25 ,7/8
*/
-- =============================================
ALTER PROCEDURE [dbo].[P_장례정산_확정_등록]
	 @행사코드			AS VARCHAR(15) = ''
	,@계약상세코드		AS VARCHAR(15) = ''
	,@회원코드			AS VARCHAR(15) = ''
	,@행사상태			AS VARCHAR(20) = ''
	,@정산완료일		AS VARCHAR(10) = ''
	,@등록자			AS VARCHAR(15) = ''
AS
BEGIN
	
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE  @현재일자			VARCHAR(10)	= CONVERT(VARCHAR(10),GETDATE(),112)
			,@행사시작일자		VARCHAR(10) = ''
			,@이전_정산완료일	VARCHAR(10) = ''
			,@납입회차			INT = 0
			,@납입예정금액		NUMERIC(18,0) = 0
			,@납부자번호		VARCHAR(20) = ''
			,@결제방법			VARCHAR(20) = ''
			,@부금상태			VARCHAR(20) = ''
			,@접수시납입금액	NUMERIC(18,0)	= 0
			,@정산시납입금액	NUMERIC(18,0)	= 0
			,@계좌번호			VARCHAR(50) = ''
			,@회계정산완료일	VARCHAR(10) = ''
			,@실계약회차		INT = 0
			,@errMsg			varchar(500) = ''
			;

	IF ISNULL(@계약상세코드,'') = ''
	BEGIN
		RAISERROR('계약상세코드가 없습니다. 확정불가..!',16, 1, '', '', '')
		RETURN
	END

	SELECT	 @행사시작일자		= X.행사시작일자
			,@이전_정산완료일	= ISNULL(X.정산완료일,'')
			,@접수시납입금액	= ISNULL(X.카드납입부금,0)+ISNULL(X.현금납입부금,0)
			,@회계정산완료일	= ISNULL(X.회계정산완료일,'')
			,@실계약회차		= Y.계약회차-ISNULL(Y.면제회차,0)
	FROM	행사마스터 AS X
	LEFT OUTER JOIN
			계약마스터 AS Y
	ON		X.계약상세코드 = Y.계약상세코드
	WHERE	행사코드 = @행사코드

	SELECT	@납입예정금액 = SUM(납입예정금액) 
			,@납입회차	  = MIN(회차)
	FROM	수납일정표 
	WHERE	계약상세코드 = @계약상세코드
	AND		납입예정금액 <> 입금액;

	SELECT @errMsg = DBO.f_업무별월마감확인(@행사시작일자,'행사정산')

	IF LEFT(@errMsg,2) <> '00'
	BEGIN
		RAISERROR(@errMsg,16, 1, '', '', '');
		RETURN
	END

	IF ISNULL(@회계정산완료일,'') <> ''
	BEGIN
		RAISERROR('회계정산완료되었습니다. 수정불가..!',16, 1, '', '', '')
		RETURN
	END

-- 행사후 출금 데이터 환불 처리 체크 로직 :: CMS출금 중 일때는 정산안됨--------------------------------------------------------------------------
	SELECT	 @납부자번호 = CMS납부자번호
			,@결제방법 = 결제방법
			,@부금상태 = 상태
			,@계좌번호 = 계좌번호
	FROM	부금결제개별
	WHERE	계약상세코드 = @계약상세코드

	IF EXISTS(SELECT 'X' FROM CMS출금 WHERE CMS납부자번호 = @납부자번호 AND 상태 = '신청')
	BEGIN
		RAISERROR('출금중입니다. 확정불가..!', 16, 1, '', '', '')
		RETURN;
	END;

-- 행사상태 변경 ----------------------------------------------------------------------------------------------------------------------------------
	UPDATE	A
	SET		 정산완료일 = @정산완료일
			,수정자		= @등록자
			,수정일자	= GETDATE()
			,행사상태	= @행사상태
	FROM	행사마스터 A
	WHERE	행사코드 = @행사코드

	IF ISNULL(@정산완료일,'') = ''
	BEGIN
		DELETE FROM 수납마스터 WHERE 계약상세코드 = @계약상세코드 AND 입금방법 = '행사완납'
		-- 업무이력
		INSERT INTO 계약업무이력(
			업무일자,계약코드,계약상세코드,회원코드,업무구분,업무내용,등록자
		)	SELECT	@현재일자,계약코드,계약상세코드,회원코드,'행사완료'
					,'장례정산 확정취소로 행사상태 진행으로 변경 및 행사완납 수납삭제'
					,@등록자
			FROM	행사마스터 
			WHERE	행사코드 = @행사코드 
	END; -- end of if

	IF ISNULL(@이전_정산완료일,'') = ISNULL(@정산완료일,'') OR ISNULL(@정산완료일,'') = '' RETURN;
	

	IF @결제방법 <> 'CMS' AND @부금상태 <> '해지'
	BEGIN
		EXEC P_부금상태변경 @계약상세코드,'장례정산확정','해지',@등록자
	END;

	-- 2020.11.13 손혜진 추가: 행사 확정시 가상계좌 할당 취소
		update	x
		set		cmf_nm		= null	--예금주명 
				,acct_st	= ''	--계좌상태
				,reg_il		= ''	--등록일자
				,open_il	= null	--할당일자
				,close_il	= null	--해지일자
				,fst_il		= null	--최초거래일자
				,lst_il		= null	--최종거래일자
				,tr_amt		= 0
				,tramt_cond	= 0
				,trbegin_il	= null	--입금가능시작일
				,trend_il	= null	--입금가능만료일
				,trbegin_si	= null	--입금가능시작시간
				,trend_si	= null	--입금가능만료시간
				,seq_no		= null	--기간내수납횟수
				,cms_cd		= null	--계약코드
				,계약상세코드	= null
				,수정자			= null
		from	vacs_vact as x with(nolock)
		where	계약상세코드 = @계약상세코드
	
-- 행사수납 처리 ------------------------------------------------------------------------------------------------------------------------

	IF ISNULL(@납입예정금액,0) <> 0
	BEGIN

		INSERT INTO 수납마스터(
			수납일자,계약코드,계약상세코드,회원코드,사원코드,납입회차,수납구분,수납상세구분
			,입금액,입금방법,할인금액,등록자,예금주,비고,실입금일자
		) SELECT	@행사시작일자
					,계약코드
					,계약상세코드
					,회원코드
					,수당사원코드
					,ISNULL(@납입회차,1)
					,'월부금'
					,'행사완납'
					,@납입예정금액
					,'행사완납'
					,0
					,@등록자
					,''
					,''
					,@행사시작일자
			FROM	계약마스터
			WHERE	계약상세코드 = @계약상세코드
	END; -- end of if

	-- 업무이력
	INSERT INTO 계약업무이력(
		업무일자,계약코드,계약상세코드,회원코드,업무구분,업무내용,등록자
	)	SELECT	@현재일자,계약코드,계약상세코드,회원코드,'행사정산완료'
				,'행사종류: '+'장의'
				+',접수자: '+ISNULL(접수인,'')
				+',상주명: '+ISNULL(상주,'')
				+',고인명: '+ISNULL(고인성명,'')
				+',행사장소: '+ISNULL(장례식장,'')
				+' 행사정산확정'
				,@등록자
		FROM	행사마스터 
		WHERE	행사코드 = @행사코드 
	
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
END
