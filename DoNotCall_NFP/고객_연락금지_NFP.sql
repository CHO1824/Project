USE [NationalFP]
GO

/****** Object:  Table [dbo].[��_��������_NFP]    Script Date: 2024-04-30 ���� 1:14:08 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[��_��������_NFP](
	[�Ϸù�ȣ] [int] IDENTITY(1,1) NOT NULL,
	[��缳����ڵ�] [varchar](20) NULL,
	[����] [varchar](100) NULL,
	[���翬��ó] [varchar](20) NULL,
	[����������] [varchar](10) NULL,
	[����������û����] [varchar](10) NULL,
	[������] [varchar](10) NULL,
	[�������������] [varchar](10) NULL,
	[�����Ȯ����������] [varchar](10) NULL,
	[�����] [varchar](20) NULL,
	[�������] [datetime] NULL,
	[������] [varchar](20) NULL,
	[��������] [datetime] NULL,
 CONSTRAINT [PK__��_��������___4BE534AB54AEC6DA] PRIMARY KEY CLUSTERED 
(
	[�Ϸù�ȣ] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[��_��������_NFP] ADD  CONSTRAINT [DF__��_��������_NF__�������__56970F4C]  DEFAULT (getdate()) FOR [�������]
GO


