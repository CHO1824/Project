USE [NationalFP]
GO

/****** Object:  Table [dbo].[고객_연락금지_NFP]    Script Date: 2024-04-30 오후 1:14:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[고객_연락금지_NFP](
	[일련번호] [int] IDENTITY(1,1) NOT NULL,
	[담당설계사코드] [varchar](20) NULL,
	[고객명] [varchar](100) NULL,
	[고객사연락처] [varchar](20) NULL,
	[콜접수일자] [varchar](10) NULL,
	[연락금지요청일자] [varchar](10) NULL,
	[접수자] [varchar](10) NULL,
	[설계사전달일자] [varchar](10) NULL,
	[설계사확인유무일자] [varchar](10) NULL,
	[등록자] [varchar](20) NULL,
	[등록일자] [datetime] NULL,
	[수정자] [varchar](20) NULL,
	[수정일자] [datetime] NULL,
 CONSTRAINT [PK__고객_연락금지___4BE534AB54AEC6DA] PRIMARY KEY CLUSTERED 
(
	[일련번호] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[고객_연락금지_NFP] ADD  CONSTRAINT [DF__고객_연락금지_NF__등록일자__56970F4C]  DEFAULT (getdate()) FOR [등록일자]
GO


