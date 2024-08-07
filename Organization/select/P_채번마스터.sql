USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_채번마스터]    Script Date: 2024-07-29 오후 1:38:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************************
                          채번마스터

1.작성일자/작성자 : 2023.03.29 / 백성흠
2.작성일자/작성자 : 

-- select * from 채번마스터 where 업무구분 = '사원코드'

-- exec P_채번마스터 '계약코드',''
-- exec P_채번마스터 '사원코드',''
**********************************************************************/
ALTER PROCEDURE [dbo].[P_채번마스터]
	 @업무구분	AS VARCHAR(50) = ''
	,@시작문자	AS VARCHAR(20) = ''
AS
BEGIN
/* ※ 코드 정의
		1) 조직코드 5자리 : SEQ(시작문자 : 본부 =>1,지사=>2,지점=>3,팀=>4)     -- 2024.03.29 백성흠 로직 반영 OK
		2) 사원코드 최대 8자리 : SEQ [규칙 : 년도(4자리) + SEQ(4자리)]         -- 2024.03.29 백성흠 로직 반영 OK
		3) 조직코드 5자리
		4) 행사번호 8자리   : '1'+SEQ                                                           -- 2024.03.29 백성흠 로직 반영 OK
		5) 회원코드 10자리  : 기존ERP 번호 이어서 발생 (SEQ) [규칙 : 년도(4자리) + SEQ(6자리)]  -- 2024.03.29 백성흠 로직 반영 OK
		6) 계약코드 10자리  : 기존ERP 번호 이어서 발생 (SEQ) [규칙 : 년도(4자리) + SEQ(6자리)]  -- 2024.03.29 백성흠 로직 반영 OK
		7) 계약상세코드 10자리 : 계약코드                                                       -- 2024.03.29 백성흠 로직 반영 OK
		14) 행사사원코드(6자리) : B + SEQ(5)                                                    -- 2024.03.29 백성흠 로직 반영 OK		
		26) 행사장(장례식장코드) : SEQ
		29) 거래처코드 : SEQ(5)

		31) 여행코드 10자리  : [규칙 : 'T' + 년도(4자리) + SEQ(5자리)]  -- 2024.04.05 백성흠 로직 반영 OK
		32) 어학코드 10자리  : [규칙 : 'L' + 년도(4자리) + SEQ(5자리)]  -- 2024.04.05 백성흠 로직 반영 OK
		33) 웨딩코드 10자리  : [규칙 : 'W' + 년도(4자리) + SEQ(5자리)]  -- 2024.04.05 백성흠 로직 반영 OK




		-- 아래쪽은 확인하면서 반영해야 함 (2024.03.29 백성흠) -- 

		8) 여행상품코드 8자리 : 년도 + 구분자('C'/'T') + SEQ(3) 
		
		11) 입출고 INT: SEQ	(시작문자 : 년월일)
		12) 상담번호 INT: SEQ (시작문자 : 년월일)
		13) 입사신청서 QR코드 16: 공용코드(상세코드)(6)+SEQ(10) 
				
		15) 해약번호(INT) : SEQ
		16) 업무요청번호 : SEQ ( 시작문자 : 년월일)
		17) 출력번호 : SEQ (8)
		18) 회원정보변경 : SEQ
		19) 법인카드 : SEQ (5) = 법인카드사용내역 
		20) 즉시출금 : SEQ
		21) G사원코드 10자리 : G+지사코드뒤5자리+SEQ(4)
		22) 기안상품코드 : 년도 4자리 + SEQ(3)
		23) 프로모션 : 년도 4자리 + SEQ(3)
		24) 양도양수 : SEQ(5)
		25) 계좌변경 : SEQ(5)
		
		27) 부금결제개별변경번호 : SEQ(5)
		28) 문자코드 : SEQ(5)
		

        -- 채번마스터 사용하지 않는 코드 (4/26 백성흠)
		군코드
		 9) 중분류코드 4자리: 대분류(2)+SEQ(2)            --> P_군중분류등록 에서 처리
		10) 소분류코드 7자리: 대분류(2)+중분류(4)+SEQ(3)  --> P_군소분류등록 에서 처리
*/

	SET NOCOUNT ON;
	
	DECLARE @채번 INT;


	-- SP 호출시 : 사원코드 AND 기존 시작문자('17')로 했을 경우 변경해야 함(2024.03.29 백성흠 추가)
	-- ---------------------------------------------------------------------//시작
	IF (@업무구분 IN ('사원코드','회원코드','계약코드'))
	BEGIN
	     SET @시작문자 = LEFT(CONVERT(VARCHAR(10),GETDATE(),112),4)
	END;
	-- ---------------------------------------------------------------------//끝

	-- Start Transaction  **********************************************************************************************
	BEGIN TRY
		BEGIN TRANSACTION;

		-- 현재 MAX번호 
		IF EXISTS(SELECT 'X' FROM 채번마스터 (NOLOCK) WHERE 업무구분 = @업무구분 AND 시작문자 = @시작문자)
		BEGIN	
		     --1.MAX(번호) + 1
			 SELECT  @채번 = 번호+1 FROM 채번마스터 (NOLOCK) WHERE 업무구분 = @업무구분 AND 시작문자 = @시작문자;

			 --2.채번 UPDATE
			 UPDATE 채번마스터
			    SET 번호 = @채번
			  WHERE 업무구분 = @업무구분
			    AND 시작문자 = @시작문자;
		END
		ELSE
		BEGIN
		      IF (@업무구분 IN ('사원코드','조직코드'))
	          BEGIN

			       IF (@업무구분 = '사원코드')
				   BEGIN
				        -- 사원번호 마지막 4자리(SEQ값)+1
				        SELECT @채번 = MAX(RIGHT(사원코드,4))+1 
					      FROM 사원마스터 (NOLOCK)
						 WHERE 사원코드 LIKE @시작문자+'%';

                        IF ISNULL(@채번,0) = 0 SET @채번 = 1;
				   END;
			       
			       IF (@업무구분 = '조직코드')
				   BEGIN
				        -- 조직코드 5자리(SEQ값)+1
				        SELECT @채번 = MAX(RIGHT(코드,4))+1  FROM 조직코드V (NOLOCK);

                        IF ISNULL(@채번,0) = 0 SET @채번 = 1;
				   END;
				   
				   UPDATE 채번마스터
	                  SET 시작문자 = @시작문자
		                 ,번호     = @채번
	                WHERE 업무구분 = @업무구분;

	               IF (@@ROWCOUNT = 0)
				   BEGIN
	                    INSERT INTO 채번마스터(업무구분, 시작문자, 번호) VALUES(@업무구분, @시작문자, @채번)
                   END
              END
			  ELSE  -- 나머지는 새롭게 저장
	          BEGIN
			      INSERT INTO 채번마스터(업무구분,시작문자,번호) VALUES(@업무구분 ,@시작문자 ,1)
              END
		END; -- END OF IF ELSE

	    COMMIT TRAN;
	END TRY
	BEGIN CATCH

		IF XACT_STATE() <> 0 ROLLBACK TRAN;
		RAISERROR('계약등록 중 오류가 발생하였습니다.',16, 1, '', '', '');

	END CATCH; --end of try~catch	
	-- End Transaction  ************************************************************************************************

	-- 	RETURN TO CODE
	IF @업무구분 IN ('여행확정순위','입출고','상담번호','해약번호','업무요청번호','회원정보','즉시출금')
	BEGIN
		SELECT 번호 FROM 채번마스터 (NOLOCK) WHERE 업무구분 = @업무구분 AND 시작문자 = @시작문자
	END
	ELSE BEGIN
		SELECT	(CASE WHEN @업무구분 = '조직코드'	   THEN RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)              -- 3/29 OK
					  WHEN @업무구분 = '사원코드'	   THEN @시작문자+RIGHT('0000'+CONVERT(VARCHAR(4),번호),4)     -- 3/29 OK
					  WHEN @업무구분 = '회원코드'	   THEN @시작문자+RIGHT('000000'+CONVERT(VARCHAR(6),번호),6)   -- 3/29 OK
					  WHEN @업무구분 = '계약코드'	   THEN @시작문자+RIGHT('000000'+CONVERT(VARCHAR(6),번호),6)   -- 3/29 OK
					  WHEN @업무구분 = '계약상세코드'  THEN @시작문자+RIGHT('000000'+CONVERT(VARCHAR(6),번호),6)   -- 3/29 OK
					  WHEN @업무구분 = '행사번호'      THEN @시작문자+RIGHT('0000000'+CONVERT(VARCHAR(7),번호),7) -- 3/29 OK
					  WHEN @업무구분 = '행사사원'	   THEN 'B'+RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)          -- 3/29 OK
					  
					  WHEN @업무구분 = '여행코드'	   THEN 'T'+@시작문자+RIGHT('00000'+CONVERT(VARCHAR(5),번호),5) -- 4/5 OK 
					  WHEN @업무구분 = '어학코드'	   THEN 'L'+@시작문자+RIGHT('00000'+CONVERT(VARCHAR(5),번호),5) -- 4/5 OK
					  WHEN @업무구분 = '웨딩코드'	   THEN 'W'+@시작문자+RIGHT('00000'+CONVERT(VARCHAR(5),번호),5) -- 4/5 OK

					  WHEN @업무구분 = '행사장'        THEN CONVERT(VARCHAR(5),번호)     -- 5/20 OK (SEQ 값)
					  WHEN @업무구분 = '거래처코드'    THEN CONVERT(VARCHAR(5),번호)     -- 7/15 OK (SEQ 값)

					  -- 아래쪽은 확인하면서 반영해야 함 (2024.03.29 백성흠) --

					  WHEN @업무구분 = '여행상품코드'  THEN @시작문자+RIGHT('000'+CONVERT(VARCHAR(3),번호),3)	
					  WHEN @업무구분 = '신용카드승인'  THEN @시작문자+RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)	
					  WHEN @업무구분 = '입사신청서QR'  THEN @시작문자+RIGHT('0000000000'+CONVERT(VARCHAR(10),번호),10)
					  					  

					  WHEN @업무구분 = '출력번호'	   THEN RIGHT('00000000'+CONVERT(VARCHAR(8),번호),8)
					  WHEN @업무구분 = '상담대분류'	   THEN (CASE WHEN @시작문자 = 'IN' 
																  THEN '1'+RIGHT('00'+CONVERT(VARCHAR(3),번호),2)
																  ELSE '5'+RIGHT('00'+CONVERT(VARCHAR(3),번호),2)
															 END)
					  WHEN @업무구분 = '법인카드'	   THEN RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)
					  WHEN @업무구분 = 'G사원코드'	   THEN @시작문자+RIGHT('0000'+CONVERT(VARCHAR(4),번호),4)
					  WHEN @업무구분 = '기안상품코드'  THEN @시작문자+RIGHT('000'+CONVERT(VARCHAR(3),번호),3)
					  WHEN @업무구분 = '프로모션'	   THEN @시작문자+RIGHT('000'+CONVERT(VARCHAR(3),번호),3)
					  WHEN @업무구분 = 'VOC접수코드'   THEN @시작문자+RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)
					  WHEN @업무구분 = '양도양수'      THEN RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)
					  WHEN @업무구분 = '계좌변경'      THEN RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)
					  
					  WHEN @업무구분 = '부금결제'      THEN RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)
					  WHEN @업무구분 = '문자코드'      THEN RIGHT('00000'+CONVERT(VARCHAR(5),번호),5)
					  



					  -- 채번마스터 사용하지 않는 코드 (4/26 백성흠)
					  -- ------------------------------------------------------------------------------------------//시작
					  -- WHEN @업무구분 = '중분류군코드'  THEN @시작문자+RIGHT('00'+CONVERT(VARCHAR(2),번호),2)	   --> P_군중분류등록 에서 처리
					  -- WHEN @업무구분 = '소분류군코드'  THEN @시작문자+RIGHT('000'+CONVERT(VARCHAR(3),번호),3)   --> P_군소분류등록 에서 처리
					  -- ------------------------------------------------------------------------------------------//끝
				 END)		AS 번호		
		FROM	채번마스터 (NOLOCK)
		WHERE	업무구분 = @업무구분
		AND		시작문자 = @시작문자
	END; -- end of if~else
	 
END;
