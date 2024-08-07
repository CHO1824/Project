USE [KwooErp]
GO
/****** Object:  StoredProcedure [dbo].[P_문자전송_기본]    Script Date: 2024-08-08 오전 10:23:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/***********************************************************************
   생성일자 : 2020.05.25
   생 성 자 : 김종진
   프로그램 : 
   특이사항 :
   수정일자/수정자 : 
     2024-01-25 유니온엠씨문자모듈 변경으로 인해 신규 모듈로 적용조치

   exec P_문자전송_기본 '','경우라이프문자테스트경우라이프문자테스트경우라이프문자테스트경우라이프문자','','','','','01053141178','SMS','','','18003535',''
   exec P_문자전송_기본 '멤버쉽','박지영','','','','','01071184263','3','[멤버쉽카드재발급]','17043503','18003535','멤버쉽'
*************************************************************************/
ALTER PROCEDURE [dbo].[P_문자전송_기본]
	 @문자코드		varchar(50) = '직접'
	,@Param1		varchar(4000) = ''
	,@Param2		varchar(200) = ''
	,@Param3		varchar(200) = ''
	,@Param4		varchar(200) = ''
	,@Param5		varchar(200) = ''
	,@착신번호		varchar(20) = ''
	,@문자형태		varchar(20) = 'SMS'
	,@문자제목		varchar(120) = ''
	,@계약상세코드	varchar(15) = ''
	,@회신번호		varchar(20) = ''
	,@전송구분		varchar(20) = '' -- 회원 / 계약 
	,@템플릿코드	varchar(100) = '' -- 기본은 문자마스터의 템플릿코드를 사용, 템플릿코드 직접 넣어 사용가능, '수기'로 넣으면 메세지를 그대로 사용하여 알림톡발송함(문자마스터에는 정의된것만 가능)
	,@발신프로필키  varchar(100) = ''
	,@등록사원코드	varchar(100) = ''
AS
BEGIN
	SET NOCOUNT ON;

	declare
		@문자내용 varchar(4000) = '';

	IF @문자코드 = '' BEGIN SET @문자코드 = '직접' END 
	IF @회신번호 = '' BEGIN SET @회신번호 = '18003535' END 

	CREATE TABLE #문자마스터(
		 문자코드	VARCHAR(15)
		,업무구분	VARCHAR(30)
		,착신구분	VARCHAR(30)
		,문자형태	VARCHAR(20) -- SMS1 LMS3 MMS 알림톡 친구톡 
		,문자제목	VARCHAR(120)
		,발송내용1	VARCHAR(4000)
		,발송내용2	VARCHAR(4000)
		,발송내용3	VARCHAR(4000)
		,발송내용4	VARCHAR(4000)
		,발송내용5	VARCHAR(4000)
		,발송내용6	VARCHAR(4000)
		,발송시점	VARCHAR(200)
		,템플릿코드 VARCHAR(100)
		,회신번호	VARCHAR(20)
		,개행문자	VARCHAR(1)
		,착신번호	VARCHAR(20)
	);

	if @문자코드 = '전자청약' ---------------------------------------------------------------------------------------------------------------
	begin
			/*
			--------------------------------------------------
								부고알림장
			--------------------------------------------------
			@문자코드		:    공백 
			@Param1			:   고객명
			@Param2			:   상품명
			@Param3			:     URL
			@Param4			:    공백
			@Param5			:    공백
			@착신번호		:   고객연락처
			@문자형태		:      3
			@문자제목		:  [경우라이프]
			@계약상세코드	:     공백
			@회신번호		:   18003535
			@전송구분		:     계약
			--------------------------------------------------
			*/

		set @문자내용 = @Param1+' 님의 ' -- 고객명
					   +@Param2+' 상품가입을 위한 전자서명을 진행해주시기바랍니다.' --상품명
					   +char(13)+char(10)+'전자서명하기 : '
					   +@Param3;

        /*
		insert into MSG_QUEUE(
			MSG_TYPE,DSTADDR,CALLBACK,SUBJECT,REQUEST_TIME,TEXT,EXT_COL1,EXT_COL2,EXT_COL3
		)	values(	'3' --MSG_TYPE 
					,@착신번호 --DSTADDR
					,@회신번호 --CALLBACK
					,'[경우라이프]' --SUBJECT
					,dateadd(mi,-1,getdate()) --REQUEST_TIME -- 현재시간보다 1분 늦게 입력 처리 하여 즉시전송 처리 형태로 함.
					,@문자내용
					,'계약'			--EXT_COL1
					,@계약상세코드	--EXT_COL2
					,@문자코드		--EXT_COL3
		);
        */
        -- 2024-01-25 변경
		/*

		-- 2024-04-02 테이블이 없어 주석처리 조하영
        insert into mms_msg(
            phone,callback,org_callback,subject,reqdate,msg,etc1,etc2,etc3
		)	values(
					@착신번호 --phone
					,@회신번호 --callback
                    ,@회신번호 --org_callback
					,'[경우라이프]' --subject
					,dateadd(mi,-1,getdate()) --reqdate -- 현재시간보다 1분 늦게 입력 처리 하여 즉시전송 처리 형태로 함.
					,@문자내용 -- msg
					,'계약'			--etc1
					,@계약상세코드	--etc2
					,@문자코드		--etc3
		);
		*/
		return;

	end; --end of if @문자코드 = 전자청약

	if @문자코드 in('부고','납입내역') ---------------------------------------------------------------------------------------------------------
	begin
		/*
			----------------------------------------------------------------------
								부고알림장		납입내역서			멤버십카드발급
			----------------------------------------------------------------------
			@문자코드		:    부고          	납입내역			멤버쉽			
			@Param1			:   상주명         	회원명 				고객명			
			@Param2			:    공백          	공백			     공백				
			@Param3			:    공백          	공백			     공백				
			@Param4			:    공백          	공백			     공백				
			@Param5			:    공백          	공백			     공백				
			@착신번호		:   상주연락처     	회원핸드폰			 회원핸드폰			
			@문자형태		:      3           	3			          3				
			@문자제목		:  [부고알림]		[납입내역서]		[멤버쉽카드재발급]
			@계약상세코드	:   행사코드       	계약상세코드		계약상세코드			
			@회신번호		:   18003535       	18003535			18003535			
			@전송구분		:   행사           	계약			     계약				
			------------------------------------------------------------------------

			부고알림장URL::https://erp.sjsangjo.com:8443/bugo/행사코드
			납입내역서URL::https://erp.sjsangjo.com:8443/mpay/계약상세코드
			멤버십카드발급::http://www.sjsangjo.com:9091/member/card/계약코드	(계약원장에서 바로 전송)

		*/

		set @문자내용 = case @전송구분
						     when '부고알림' then '[부고알림URL]'
											     +char(13)+char(10)
											     +convert(varchar(100),'https://erp.sjsangjo.com:8443/bugo/')+@계약상세코드
                             when '납입내역' then '[경우라이프]안녕하세요 '+@Param1+' 회원님 현재까지 납입하신 납입내역서 URL 입니다'
											     +char(13)+char(10)+char(13)+char(10)
											     +convert(varchar(100),'https://erp.sjsangjo.com:8443/mpay/')+@계약상세코드
											     +char(13)+char(10)+char(13)+char(10)
                                                 +'감사합니다. *경우라이프  고객상담센터 : 1800-3535 (평일 오전9시~오후6시/주말 및 공휴일 휴무) *장례접수 : 1800-4119 (연중무휴 24시간)'
					    end;

        -- 2023-08-24 추가, 알림톡발송
        if @문자코드 = '납입내역'
        begin
            INSERT INTO UnionMSG(
                msggroupid
                ,SendType
                ,sender
                ,receiver
                ,Subject
                ,msg
                ,MsgType
                ,FailOver
                ,ReplaceMsg
                ,KakaoMethod
                ,SenderKey
                ,TemplateCode
                ,FilePath
                ,Etc1
                ,Etc2
                ,Etc3
            )
            select  (isnull((select max(MsgID) from UnionMSG (nolock)),0)+1)+'01' as msggroupid
                    ,'KMS' as SendType
                    ,@회신번호 as sender
                    ,@착신번호 as receiver
                    ,@문자제목 as Subject
                    ,@문자내용 as msg
                    ,'AT' as MsgType
                    ,'2' as FailOver
                    ,@문자내용 as ReplaceMsg
                    ,'p' as KakaoMethod
                    ,'664bd7b8d9600b847bc4d412343478dd3226a5ba' as SenderKey
                    ,'SJKAKAO-081' as TemplateCode
                    ,'' as FilePath
                    ,'계약' as Etc1
                    ,@계약상세코드 as Etc2
                    ,@문자코드 as Etc3

            return
        end

        /*
		insert into MSG_QUEUE(
			MSG_TYPE,DSTADDR,CALLBACK,SUBJECT,REQUEST_TIME,TEXT,EXT_COL1,EXT_COL2,EXT_COL3
		)	values(	 @문자형태 --MSG_TYPE 
					,@착신번호 --DSTADDR
					,@회신번호 --CALLBACK
					,@문자제목 --SUBJECT
					,dateadd(mi,-1,getdate()) --REQUEST_TIME -- 현재시간보다 1분 늦게 입력 처리 하여 즉시전송 처리 형태로 함.

					,@문자내용 --TEXT

					,case when @전송구분 = '부고알림' then '행사' else '계약' end --EXT_COL1
					,@계약상세코드	--EXT_COL2
					,@문자코드		--EXT_COL3
		);
        */

		/*
        -- 2024-01-25 변경

		-- 2024-04-02 테이블이 없어 주석처리 조하영
        insert into mms_msg(
            phone,callback,org_callback,subject,reqdate,msg,etc1,etc2,etc3
		)	values(
					@착신번호 --phone
					,@회신번호 --callback
                    ,@회신번호 --org_callback
					,@문자제목 --subject
					,dateadd(mi,-1,getdate()) --reqdate -- 현재시간보다 1분 늦게 입력 처리 하여 즉시전송 처리 형태로 함.
					,@문자내용 -- msg
                    ,case when @전송구분 = '부고알림' then '행사' else '계약' end --etc1
					,@계약상세코드	--etc2
					,@문자코드		--etc3
		);

		*/
		return;

	end; --end of if @문자코드 = 멤버쉽,부고,납입내역


	if @문자코드 in('직접','대량') -------------------------------------------------------------------------------------------------------
	begin
		insert into #문자마스터(
			문자코드,업무구분,착신구분,문자형태,문자제목,발송내용1,발송내용2,발송내용3,발송내용4,발송내용5,발송내용6
			,발송시점,템플릿코드,회신번호,개행문자,착신번호
		) values(
			'','','',@문자형태,@문자제목,@Param1,'','','','','','',@템플릿코드,@회신번호,'N',@착신번호
		);

		goto MsgIns;

	end; --end of if @문자코드 = 직접,대량,멤버쉽,부고

-- 문자포맷 조회 --------------------------------------------------------------------------------------------------------------------------
	insert into #문자마스터(
		문자코드,업무구분,착신구분,문자형태,문자제목,발송내용1,발송내용2,발송내용3,발송내용4,발송내용5,발송내용6
		,발송시점,템플릿코드,개행문자,착신번호
	)	select	 q.문자코드
				,q.업무구분
				,q.착신구분
				,q.문자형태 -- SMS1 LMS3 MMS 알림톡 친구톡 
				,q.문자제목
				,isnull(q.발송내용1,'') as 발송내용1
				,isnull(q.발송내용2,'') as 발송내용2
				,isnull(q.발송내용3,'') as 발송내용3
				,isnull(q.발송내용4,'') as 발송내용4
				,isnull(q.발송내용5,'') as 발송내용5
				,isnull(q.발송내용6,'') as 발송내용6
				,q.발송시점
				,q.템플릿코드
				,q.개행문자
				,case when isnull(p.착신연락처,'') = '' then @착신번호 else p.착신연락처 end
		from	문자마스터 as q with (nolock)
		left outer join
				문자착신상세 as p with (nolock)
		on		q.문자코드 = p.문자코드
		where	q.문자코드 = @문자코드

-- 문자열생성 & 문자전송 내용 저장 --------------------------------------------------------------------------------------------------------
MsgIns:

    -- 알림톡발송 - 문자형태 7 = LMS알림톡
    if exists(select 'X' from 문자마스터 with (nolock) where 문자코드 = @문자코드 and 문자형태 = '7' and isnull(템플릿코드,'') <> '')
    and @문자코드 in(
        '00041','00042','00043','00044','00045','00046'
        ,'00001','00003','00008','00009'
        ,'00069','00070'
        ,'00073','00074','00075','00076'
        ,'00033','00034'
        ,'00002','00010','00012','00052','00072'
        ,'00057','00058','00050'
        ,'00087'
    )
    begin
        DECLARE
            @S_알림톡메세지  VARCHAR(8000)
            ,@S_알림톡템플릿 VARCHAR(20)
        
        SET @S_알림톡템플릿 = (SELECT TOP 1 템플릿코드 FROM #문자마스터)

        -- 메세지를 미리 만들어 보내는 경우
        if isnull(@템플릿코드,'') = '수기'
        begin
            set @S_알림톡메세지 = (
                                    select  top 1
                                            (case when 개행문자 = 'N' 
                                                then isnull(발송내용1,'')
                                                        +space(1)+@Param1+space(1)+isnull(발송내용2,'')
                                                        +space(1)+@Param2+space(1)+isnull(발송내용3,'')
                                                        +space(1)+@Param3+space(1)+isnull(발송내용4,'')
                                                        +space(1)+@Param4+space(1)+isnull(발송내용5,'')
                                                        +space(1)+@Param5+space(1)+isnull(발송내용6,'')
                                                else isnull(발송내용1,'')
                                                        +char(13)+char(10)+@Param1+space(1)+isnull(발송내용2,'')
                                                        +char(13)+char(10)+@Param2+space(1)+isnull(발송내용3,'')
                                                        +char(13)+char(10)+@Param3+space(1)+isnull(발송내용4,'')
                                                        +char(13)+char(10)+@Param4+space(1)+isnull(발송내용5,'')
                                                        +char(13)+char(10)+@Param5+space(1)+isnull(발송내용6,'')
                                            end) as 메세지
                                    from #문자마스터
                                  )
        end
        else
        begin
            EXEC dbo.P_문자발송_알림톡메세지 @S_알림톡메세지 OUTPUT,@S_알림톡템플릿,@Param1,@Param2,@Param3,@Param4,@Param5
        end

        IF ISNULL(@S_알림톡메세지,'') = '' RETURN

        INSERT INTO UnionMSG(
            msggroupid
            ,SendType
            ,sender
            ,receiver
            ,Subject
            ,msg
            ,MsgType
            ,FailOver
            ,ReplaceMsg
            ,KakaoMethod
            ,SenderKey
            ,TemplateCode
            ,FilePath
            ,Etc1
            ,Etc2
            ,Etc3
        )
        select  (isnull((select max(MsgID) from UnionMSG (nolock)),0)+1)+'01' as msggroupid
                ,'KMS' as SendType
                ,@회신번호 as sender
                ,착신번호 as receiver
                ,문자제목 as Subject
                ,@S_알림톡메세지 as msg
                ,'AT' as MsgType
                ,'2' as FailOver
                ,@S_알림톡메세지 as ReplaceMsg
                ,'p' as KakaoMethod
                ,'664bd7b8d9600b847bc4d412343478dd3226a5ba' as SenderKey
                ,템플릿코드 as TemplateCode
                ,'' as FilePath
                ,@전송구분 as Etc1
                ,@계약상세코드 as Etc2
                ,@문자코드 as Etc3
        from    #문자마스터
    end
    else if @문자코드 in('직접','대량') and isnull(@템플릿코드,'') <> '' -- 알림톡이지만 직접 메세지 처리한 경우
    begin
        INSERT INTO UnionMSG(
            msggroupid
            ,SendType
            ,sender
            ,receiver
            ,Subject
            ,msg
            ,MsgType
            ,FailOver
            ,ReplaceMsg
            ,KakaoMethod
            ,SenderKey
            ,TemplateCode
            ,FilePath
            ,Etc1
            ,Etc2
            ,Etc3
        )
        select  (isnull((select max(MsgID) from UnionMSG (nolock)),0)+1)+'01' as msggroupid
                ,'KMS' as SendType
                ,@회신번호 as sender
                ,착신번호 as receiver
                ,문자제목 as Subject
                ,발송내용1 as msg
                ,'AT' as MsgType
                ,'2' as FailOver
                ,발송내용1 as ReplaceMsg
                ,'p' as KakaoMethod
                ,'664bd7b8d9600b847bc4d412343478dd3226a5ba' as SenderKey
                ,템플릿코드 as TemplateCode
                ,'' as FilePath
                ,@전송구분 as Etc1
                ,@계약상세코드 as Etc2
                ,@문자코드 as Etc3
        from    #문자마스터
    end
	/*
    else -- 일반문자발송(기존)
    begin
        /*
	    insert into MSG_QUEUE(
		    MSG_TYPE,DSTADDR,CALLBACK,SUBJECT,REQUEST_TIME,TEXT,EXT_COL1,EXT_COL2,EXT_COL3,TEMPLATE_CODE,SENDER_KEY
	    )	select	case when 문자형태 in('SMS','1') then '1'
					     when 문자형태 in('LMS','3') then '3'
					     when 문자형태 in('LMS알림톡','7') then '7'
					     else '1'
				    end as  MSG_TYPE 
				    ,착신번호 as DSTADDR
				    ,@회신번호 as CALLBACK
				    ,문자제목 as SUBJECT
				    ,dateadd(mi,-1,getdate()) as REQUEST_TIME -- 현재시간보다 1분 늦게 입력 처리 하여 즉시전송 처리 형태로 함.

				    ,case when @문자코드 in('직접','대량') 
					      then @Param1
					      else (
								    case when 개행문자 = 'N' 
									     then isnull(발송내용1,'')
										      +space(1)+@Param1+space(1)+isnull(발송내용2,'')
										      +space(1)+@Param2+space(1)+isnull(발송내용3,'')
										      +space(1)+@Param3+space(1)+isnull(발송내용4,'')
										      +space(1)+@Param4+space(1)+isnull(발송내용5,'')
										      +space(1)+@Param5+space(1)+isnull(발송내용6,'')
									     else isnull(발송내용1,'')
										      +char(13)+char(10)+@Param1+space(1)+isnull(발송내용2,'')
										      +char(13)+char(10)+@Param2+space(1)+isnull(발송내용3,'')
										      +char(13)+char(10)+@Param3+space(1)+isnull(발송내용4,'')
										      +char(13)+char(10)+@Param4+space(1)+isnull(발송내용5,'')
										      +char(13)+char(10)+@Param5+space(1)+isnull(발송내용6,'')
								    end
					      )
				     end as TEXT

				    ,@전송구분		as EXT_COL1
				    ,@계약상세코드	as EXT_COL2
				    ,@문자코드		as EXT_COL3
				    ,@템플릿코드	as TEMPLATE_CODE
				    ,@발신프로필키  as SENDER_KEY
		    from	#문자마스터;
            */

		-- 2024-04-02 테이블이 없어 주석처리 조하영
        -- 2024-01-25 변경
        insert into mms_msg(
            phone,callback,org_callback,subject,reqdate,msg,etc1,etc2,etc3
		)
        select	착신번호 as phone
				,@회신번호 as callback
                ,@회신번호 as org_callback
				,문자제목 as subject
				,dateadd(mi,-1,getdate()) as reqdate -- 현재시간보다 1분 늦게 입력 처리 하여 즉시전송 처리 형태로 함.

				,case when @문자코드 in('직접','대량') 
					    then @Param1
					    else (
								case when 개행문자 = 'N' 
									    then isnull(발송내용1,'')
										    +space(1)+@Param1+space(1)+isnull(발송내용2,'')
										    +space(1)+@Param2+space(1)+isnull(발송내용3,'')
										    +space(1)+@Param3+space(1)+isnull(발송내용4,'')
										    +space(1)+@Param4+space(1)+isnull(발송내용5,'')
										    +space(1)+@Param5+space(1)+isnull(발송내용6,'')
									    else isnull(발송내용1,'')
										    +char(13)+char(10)+@Param1+space(1)+isnull(발송내용2,'')
										    +char(13)+char(10)+@Param2+space(1)+isnull(발송내용3,'')
										    +char(13)+char(10)+@Param3+space(1)+isnull(발송내용4,'')
										    +char(13)+char(10)+@Param4+space(1)+isnull(발송내용5,'')
										    +char(13)+char(10)+@Param5+space(1)+isnull(발송내용6,'')
								end
					    )
				    end as msg

				,@전송구분		as etc1
				,@계약상세코드	as etc2
				,@문자코드		as etc3
		from	#문자마스터;
    end

	drop table #문자마스터;
	*/
END;
