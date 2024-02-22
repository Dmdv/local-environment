USE [development]
GO

/****** Object:  Schema [SignalR]  ******/
CREATE SCHEMA [SignalR]
GO

USE [development]
GO

/****** Object:  Sequence [dbo].[GME_OrderID] ******/
CREATE SEQUENCE [dbo].[GME_OrderID]
    AS [bigint]
    START WITH 20000000
    INCREMENT BY 1
    MINVALUE -9223372036854775808
    MAXVALUE 9223372036854775807
    CACHE
GO

/****** Object:  UserDefinedTableType [dbo].[CurrencyRateType]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE TYPE [dbo].[CurrencyRateType] AS TABLE(
                                                 [Currency] [nvarchar](50) NULL,
                                                 [Market] [nvarchar](50) NULL,
                                                 [Rate] [decimal](18, 8) NULL,
                                                 [Volume] [decimal](18, 8) NULL
                                             )
GO
/****** Object:  UserDefinedFunction [dbo].[getBalance]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[getBalance](@CurrName NVARCHAR(5), @CID BIGinT)

    RETURNS DECIMAL(18,8)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @ResultVar DECIMAL(18,8), @txnTypeMIn int
    select @txnTypeMIn=TransactionTypeMin from [tbl_CurrencyPrefrences] with(nolock) where CurrencyShortName=@CurrName

    -- Add the T-SQL statements to compute the return value here
    SELECT @ResultVar = isnull(sum(Credit)-sum(debit),0) from AccountMaster where memberid=@CID and TxnType BETWEEN @txnTypeMIn AND @txnTypeMIn+9

    -- Return the result of the function
    RETURN @ResultVar

END
GO
/****** Object:  UserDefinedFunction [dbo].[GetOpenCandle]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION [dbo].[GetOpenCandle]
(
    -- Add the parameters for the function here
    @MarketName NVARCHAR(5), @CurrencyName NVARCHAR(5), @dt DATETIME
)
    RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @ResultVar NVARCHAR(MAX), @volume decimal(18,8), @High decimal(18,8), @Low decimal(18,8)
    select @volume=Sum(Volume),@High=Max(Rate),@Low=Min(Rate) from tbl_MatchedOrder with (Nolock) where MarketType=@MarketName and CurrencyType=@CurrencyName and  OrderConfirmDate >= @DT
    SET @ResultVar = cast(@high as nvarchar(max)) + ',' + cast(@Low as nvarchar(max)) + ',' +  cast(@volume as nvarchar(max))


    RETURN @ResultVar
END
GO
/****** Object:  UserDefinedFunction [dbo].[MySponsor]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[MySponsor]
(
    -- Add the parameters for the function here
    @UserCode bigint
)
    RETURNS bigint
AS
BEGIN
    -- Declare the return variable here
    DECLARE @SPCode bigint
    SET @SPCode=250252
    SELECT @SPCode = ReferralId from tbl_Customer with (nolock) where CID = @UserCode
    --SELECT @SPCode = MemberID from tblTreeMaster where LeftChild=@UserCode or RightChild=@UserCode
    RETURN ISNULL(@SPCode,250252)
END;

GO
/****** Object:  Table [dbo].[a_good_bot_orders]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[a_good_bot_orders](
                                          [OrderID] [bigint] NOT NULL,
                                          [BotOrderID] [bigint] NOT NULL,
                                          [Side] [varchar](4) NOT NULL,
                                          [Volume] [decimal](18, 8) NOT NULL,
                                          [Rate] [decimal](18, 8) NOT NULL,
                                          [TotalAmount] [decimal](18, 8) NOT NULL,
                                          [CustomerID] [bigint] NOT NULL,
                                          [OrderConfirmDate] [datetime] NOT NULL,
                                          [MarketType] [nvarchar](10) NOT NULL,
                                          [CurrencyType] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[a_good_matched_orders]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[a_good_matched_orders](
                                              [OrderID] [bigint] NOT NULL,
                                              [BotOrderID] [bigint] NOT NULL,
                                              [Side] [varchar](4) NOT NULL,
                                              [Volume] [decimal](18, 8) NOT NULL,
                                              [Rate] [decimal](18, 8) NOT NULL,
                                              [TotalAmount] [decimal](18, 8) NOT NULL,
                                              [CustomerID] [bigint] NOT NULL,
                                              [OrderConfirmDate] [datetime] NOT NULL,
                                              [MarketType] [nvarchar](10) NOT NULL,
                                              [CurrencyType] [nvarchar](10) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccountMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccountMaster](
                                      [TxnID] [bigint] IDENTITY(1,1) NOT NULL,
                                      [TxnType] [bigint] NOT NULL,
                                      [MemberID] [bigint] NOT NULL,
                                      [DateofTransaction] [datetime] NOT NULL,
                                      [Particulars] [nvarchar](350) NOT NULL,
                                      [Credit] [decimal](18, 8) NOT NULL,
                                      [Debit] [decimal](18, 8) NOT NULL,
                                      [Status] [bit] NOT NULL,
                                      CONSTRAINT [AccountMaster_primaryKey] PRIMARY KEY NONCLUSTERED
                                          (
                                           [TxnID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AccountMaster_Archive]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AccountMaster_Archive](
                                              [TxnID] [bigint] IDENTITY(1,1) NOT NULL,
                                              [TxnType] [bigint] NOT NULL,
                                              [MemberID] [bigint] NOT NULL,
                                              [DateofTransaction] [datetime] NOT NULL,
                                              [Particulars] [nvarchar](350) NOT NULL,
                                              [Credit] [decimal](18, 8) NOT NULL,
                                              [Debit] [decimal](18, 8) NOT NULL,
                                              [Status] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AdminLogin]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdminLogin](
                                   [ID] [int] IDENTITY(100,1) NOT NULL,
                                   [LoginID] [nvarchar](max) NOT NULL,
                                   [Password] [nvarchar](max) NOT NULL,
                                   [Email] [nvarchar](max) NULL,
                                   [Status] [nvarchar](max) NULL,
                                   [LastBuyID] [bigint] NULL,
                                   [LastSellID] [bigint] NULL,
                                   [LastWithdrawalID] [bigint] NULL,
                                   [LastDepositID] [bigint] NULL,
                                   [LastMatchedID] [bigint] NULL,
                                   [Themes] [nvarchar](max) NULL,
                                   [Configs] [nvarchar](max) NOT NULL,
                                   [KycProvider] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Contents]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Contents](
                                 [id] [int] NOT NULL,
                                 [PageName] [nvarchar](50) NULL,
                                 [PageContents] [nvarchar](max) NULL,
                                 [Active] [bit] NULL,
                                 CONSTRAINT [PK_Contents] PRIMARY KEY CLUSTERED
                                     (
                                      [id] ASC
                                         )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EmailNotifications]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EmailNotifications](
                                           [ID] [int] IDENTITY(1,1) NOT NULL,
                                           [Template] [nvarchar](50) NULL,
                                           [SendTo] [nvarchar](50) NULL,
                                           [Parameters] [nvarchar](max) NULL,
                                           [AddedOn] [datetime] NOT NULL,
                                           [Status] [nvarchar](10) NULL,
                                           [ProcessedOn] [datetime] NULL,
                                           [Message] [nvarchar](max) NULL,
                                           PRIMARY KEY CLUSTERED
                                               (
                                                [ID] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FireblocksWallets]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FireblocksWallets](
                                          [ID] [int] IDENTITY(1,1) NOT NULL,
                                          [CID] [bigint] NOT NULL,
                                          [Address] [varchar](250) NULL,
                                          [Currency] [varchar](10) NOT NULL,
                                          [VaultID] [varchar](50) NULL,
                                          [CreatedOn] [datetime] NOT NULL,
                                          PRIMARY KEY CLUSTERED
                                              (
                                               [ID] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KYC_FilterFields]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KYC_FilterFields](
                                         [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                         [FieldName] [nvarchar](50) NOT NULL,
                                         [AddedOn] [datetime] NOT NULL,
                                         [IsDeleted] [bit] NOT NULL,
                                         [DeletedOn] [datetime] NULL,
                                         CONSTRAINT [PK_KYC_FilterFields] PRIMARY KEY CLUSTERED
                                             (
                                              [Id] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KYC_FilterFieldsValues]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KYC_FilterFieldsValues](
                                               [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                               [CID] [bigint] NULL,
                                               [FieldId] [bigint] NULL,
                                               [FieldValue] [nvarchar](200) NULL,
                                               [AddedOn] [datetime] NULL,
                                               CONSTRAINT [PK_KYC_FilterFieldsValues] PRIMARY KEY CLUSTERED
                                                   (
                                                    [Id] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[KYC_New]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KYC_New](
                                [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                [CustomerID] [bigint] NOT NULL,
                                [SubmitDate] [datetime] NOT NULL,
                                [ApprovalRequestDate] [datetime] NULL,
                                [ApprovalReceivedDate] [datetime] NULL,
                                [CallbackURL] [varchar](100) NULL,
                                [ApprovedBy] [nvarchar](50) NULL,
                                [Blob_GUID] [nvarchar](50) NOT NULL,
                                [Comment] [nvarchar](max) NULL,
                                [Status] [varchar](20) NULL,
                                [Data] [varchar](max) NULL,
                                [RawResponse] [nvarchar](max) NULL,
                                [ProfileOnS3] [bit] NOT NULL,
                                CONSTRAINT [PK_KYC_New] PRIMARY KEY CLUSTERED
                                    (
                                     [ID] ASC
                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SumAndSubstanceApplicationTracker]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SumAndSubstanceApplicationTracker](
                                                          [Id] [int] IDENTITY(1,1) NOT NULL,
                                                          [CID] [bigint] NOT NULL,
                                                          [ApplicationId] [nvarchar](50) NULL,
                                                          [EntryOn] [datetime] NOT NULL,
                                                          [Status] [nvarchar](20) NULL,
                                                          [Comment] [nvarchar](max) NULL,
                                                          [LastUpdatedOn] [datetime] NULL,
                                                          PRIMARY KEY CLUSTERED
                                                              (
                                                               [Id] ASC
                                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AccessViolation]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AccessViolation](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [RuleType] [int] NOT NULL,
                                            [RuleCategory] [int] NOT NULL,
                                            [RuleFor] [int] NOT NULL,
                                            [CID] [bigint] NOT NULL,
                                            [Country] [nvarchar](2) NULL,
                                            [Asset] [varchar](10) NULL,
                                            [Product] [nvarchar](11) NULL,
                                            PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AddressBook]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AddressBook](
                                        [ID] [int] IDENTITY(1,1) NOT NULL,
                                        [CID] [bigint] NULL,
                                        [Currency] [nvarchar](10) NOT NULL,
                                        [Label] [nvarchar](50) NOT NULL,
                                        [Address] [nvarchar](250) NULL,
                                        [AddedOn] [datetime] NOT NULL,
                                        [IsDeleted] [bit] NOT NULL,
                                        [DT_Memo] [nvarchar](50) NOT NULL,
                                        CONSTRAINT [PK_tbl_AddressBook] PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AddressMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AddressMaster](
                                          [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                          [CID] [bigint] NOT NULL,
                                          [CurrencyShortName] [nvarchar](10) NOT NULL,
                                          [WalletAddress] [nvarchar](250) NOT NULL,
                                          [GenerationDate] [datetime] NOT NULL,
                                          CONSTRAINT [PK_tbl_AddressMaster] PRIMARY KEY CLUSTERED
                                              (
                                               [CID] ASC,
                                               [CurrencyShortName] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                          CONSTRAINT [Unique_Curr_Address] UNIQUE NONCLUSTERED
                                              (
                                               [WalletAddress] ASC,
                                               [CurrencyShortName] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AddressRequestsBitGoETH]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AddressRequestsBitGoETH](
                                                    [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                    [WalletID] [nvarchar](max) NULL,
                                                    [AddressID] [nvarchar](max) NULL,
                                                    [IssuedAddress] [nvarchar](max) NULL,
                                                    [IssuedStatus] [bit] NULL,
                                                    [RequestedDate] [datetime] NULL,
                                                    [IssuedDate] [datetime] NULL,
                                                    [CoinName] [varchar](10) NULL,
                                                    CONSTRAINT [PK_tbl_AddressRequestsBitGoETH] PRIMARY KEY CLUSTERED
                                                        (
                                                         [ID] ASC
                                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AddressStorage]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AddressStorage](
                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                           [CurrencyShortName] [nvarchar](10) NOT NULL,
                                           [Address] [nvarchar](250) NOT NULL,
                                           [GeneratedOn] [datetime] NOT NULL,
                                           [IndexNo] [int] NOT NULL,
                                           [IsUsed] [bit] NOT NULL,
                                           [UsedOn] [datetime] NULL,
                                           CONSTRAINT [UniqueAddress] UNIQUE NONCLUSTERED
                                               (
                                                [Address] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Admin_pages]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Admin_pages](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [Page] [nvarchar](50) NOT NULL,
                                        [GroupName] [nvarchar](50) NULL,
                                        CONSTRAINT [PK_tbl_roles_1] PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                        CONSTRAINT [IX_tbl_roles] UNIQUE NONCLUSTERED
                                            (
                                             [Page] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Admin_userPageMapping]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Admin_userPageMapping](
                                                  [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                  [CID] [bigint] NOT NULL,
                                                  [PageID] [bigint] NOT NULL,
                                                  [Access] [nvarchar](10) NULL,
                                                  PRIMARY KEY CLUSTERED
                                                      (
                                                       [ID] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AdminLogs]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AdminLogs](
                                      [ID] [int] IDENTITY(1,1) NOT NULL,
                                      [Email] [nvarchar](50) NOT NULL,
                                      [IPAddress] [nvarchar](max) NOT NULL,
                                      [Browser] [nvarchar](50) NOT NULL,
                                      [OperatingSystem] [nvarchar](50) NOT NULL,
                                      [PageTitle] [nvarchar](max) NOT NULL,
                                      [PageURL] [nvarchar](max) NOT NULL,
                                      [TimeStamp] [datetime] NOT NULL,
                                      [ActionType] [nvarchar](max) NOT NULL,
                                      [CustomObject] [nvarchar](max) NULL,
                                      PRIMARY KEY CLUSTERED
                                          (
                                           [ID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_AMM_HammerPatternData]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_AMM_HammerPatternData](
                                                  [Pair] [varchar](50) NOT NULL,
                                                  [TS] [bigint] NOT NULL,
                                                  [Users] [varchar](999) NULL,
                                                  CONSTRAINT [PK_tbl_AMM_HammerPatternData] PRIMARY KEY CLUSTERED
                                                      (
                                                       [Pair] ASC,
                                                       [TS] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ApikeyManager]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_ApikeyManager](
                                          [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                          [CID] [bigint] NOT NULL,
                                          [Key] [nvarchar](50) NOT NULL,
                                          [Secret] [nvarchar](50) NOT NULL,
                                          [Type] [nvarchar](10) NOT NULL,
                                          [GeneratedOn] [datetime] NOT NULL,
                                          [IsActive] [bit] NOT NULL,
                                          [DeactivatedOn] [datetime] NULL,
                                          [HitCount] [bigint] NOT NULL,
                                          [LastHit] [datetime] NULL,
                                          [TrustedIPs] [nvarchar](50) NOT NULL,
                                          CONSTRAINT [PK_tbl_ApikeyManager] PRIMARY KEY CLUSTERED
                                              (
                                               [ID] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_BlockSyncTransactions]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_BlockSyncTransactions](
                                                  [ID] [bigint] NOT NULL,
                                                  [CID] [bigint] NOT NULL,
                                                  [WithdrawalAmount] [decimal](18, 8) NOT NULL,
                                                  [WithdrawalType] [nvarchar](10) NOT NULL,
                                                  [WithdrawalAddress] [nvarchar](250) NOT NULL,
                                                  [Particulars] [nvarchar](250) NULL,
                                                  [WithdrawalReqDate] [datetime] NOT NULL,
                                                  [WithdrawalConfirmDate] [datetime] NULL,
                                                  [WithdrawalStatus] [nvarchar](10) NOT NULL,
                                                  [TXNHash] [nvarchar](250) NULL,
                                                  [EquivalentUsdAmt] [decimal](18, 8) NOT NULL,
                                                  [IsConfirmedByUser] [bit] NOT NULL,
                                                  [UserConfirmationID] [nvarchar](50) NOT NULL,
                                                  [Withdrawal_Fee] [decimal](18, 8) NULL,
                                                  [StartedOn] [datetime] NOT NULL,
                                                  [FinishedOn] [datetime] NOT NULL,
                                                  PRIMARY KEY CLUSTERED
                                                      (
                                                       [ID] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Bots]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Bots](
                                 [ID] [int] IDENTITY(1,1) NOT NULL,
                                 [CID] [bigint] NULL,
                                 [PublicKey] [nvarchar](max) NULL,
                                 [PrivateKey] [nvarchar](max) NULL,
                                 [IPAddress] [nvarchar](max) NULL,
                                 [IsDeleted] [bit] NULL,
                                 PRIMARY KEY CLUSTERED
                                     (
                                      [ID] ASC
                                         )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Burn_Addresses]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Burn_Addresses](
                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                           [Currency] [varchar](50) NULL,
                                           [Address] [varchar](100) NULL,
                                           [TotalBurned] [decimal](30, 20) NULL,
                                           CONSTRAINT [PK_tbl_Burn_Addresses] PRIMARY KEY CLUSTERED
                                               (
                                                [ID] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_BuyOrder]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_BuyOrder](
                                     [OrderID] [bigint] NOT NULL,
                                     [BuyerID] [bigint] NOT NULL,
                                     [CurrencyType] [nvarchar](10) NOT NULL,
                                     [Volume] [decimal](18, 8) NOT NULL,
                                     [Rate] [decimal](18, 8) NOT NULL,
                                     [Amount] [decimal](18, 8) NOT NULL,
                                     [Brokerage] [decimal](18, 8) NOT NULL,
                                     [SGST] [decimal](18, 8) NOT NULL,
                                     [CGST] [decimal](18, 8) NOT NULL,
                                     [IGST] [decimal](18, 8) NOT NULL,
                                     [TotalAmount] [decimal](18, 8) NOT NULL,
                                     [OrderStatus] [bit] NOT NULL,
                                     [OrderPlacementDate] [datetime] NOT NULL,
                                     [OrderConfirmDate] [datetime] NULL,
                                     [isSameStateTax] [bit] NOT NULL,
                                     [PendingVolume] [decimal](18, 8) NOT NULL,
                                     [MarketType] [nvarchar](10) NOT NULL,
                                     [ServiceChargePerc] [decimal](18, 8) NOT NULL,
                                     [TimeInForce] [nvarchar](50) NOT NULL,
                                     [Stop] [decimal](18, 8) NOT NULL,
                                     [OrderCategory] [nvarchar](50) NOT NULL,
                                     [ClientOrderId] [nvarchar](50) NOT NULL,
                                     [isMarginOrder] [bit] NOT NULL,
                                     [LiquidatedPositionID] [bigint] NOT NULL,
                                     [Client] [nvarchar](50) NULL,
                                     [ClientIP] [nvarchar](50) NULL,
                                     [StatusCode] [int] NOT NULL,
                                     [StatusMessage] [nvarchar](100) NULL,
                                     [ExtraData] [nvarchar](max) NULL,
                                     CONSTRAINT [tbl_BuyOrder_primaryKey] PRIMARY KEY NONCLUSTERED
                                         (
                                          [OrderID] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_BuyOrder_Archive]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_BuyOrder_Archive](
                                             [OrderID] [bigint] NOT NULL,
                                             [BuyerID] [bigint] NOT NULL,
                                             [CurrencyType] [nvarchar](10) NOT NULL,
                                             [Volume] [decimal](18, 8) NOT NULL,
                                             [Rate] [decimal](18, 8) NOT NULL,
                                             [Amount] [decimal](18, 8) NOT NULL,
                                             [Brokerage] [decimal](18, 8) NOT NULL,
                                             [SGST] [decimal](18, 8) NOT NULL,
                                             [CGST] [decimal](18, 8) NOT NULL,
                                             [IGST] [decimal](18, 8) NOT NULL,
                                             [TotalAmount] [decimal](18, 8) NOT NULL,
                                             [OrderStatus] [bit] NOT NULL,
                                             [OrderPlacementDate] [datetime] NOT NULL,
                                             [OrderConfirmDate] [datetime] NULL,
                                             [isSameStateTax] [bit] NOT NULL,
                                             [PendingVolume] [decimal](18, 8) NOT NULL,
                                             [MarketType] [nvarchar](10) NOT NULL,
                                             [ServiceChargePerc] [decimal](18, 8) NOT NULL,
                                             [TimeInForce] [nvarchar](50) NOT NULL,
                                             [Stop] [decimal](18, 8) NOT NULL,
                                             [OrderCategory] [nvarchar](50) NOT NULL,
                                             [ClientOrderId] [nvarchar](50) NOT NULL,
                                             [isMarginOrder] [bit] NOT NULL,
                                             [LiquidatedPositionID] [bigint] NOT NULL,
                                             [Client] [nvarchar](50) NULL,
                                             [ClientIP] [nvarchar](50) NULL,
                                             [StatusCode] [int] NOT NULL,
                                             [StatusMessage] [nvarchar](100) NULL,
                                             [ExtraData] [nvarchar](200) NULL,
                                             CONSTRAINT [tbl_BuyOrder_Archive_primaryKey] PRIMARY KEY NONCLUSTERED
                                                 (
                                                  [OrderID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_1_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_1_min](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [Currency] [nvarchar](50) NOT NULL,
                                        [Market] [nvarchar](50) NOT NULL,
                                        [Open] [decimal](30, 8) NOT NULL,
                                        [Close] [decimal](30, 8) NOT NULL,
                                        [High] [decimal](30, 8) NOT NULL,
                                        [Low] [decimal](30, 8) NOT NULL,
                                        [Time] [datetime] NOT NULL,
                                        [Volume] [decimal](30, 8) NOT NULL,
                                        [FromTime] [datetime] NULL,
                                        CONSTRAINT [PK__tbl_Char__3214EC2728F226A2] PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_10080_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_10080_min](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [Currency] [nvarchar](50) NOT NULL,
                                            [Market] [nvarchar](50) NOT NULL,
                                            [Open] [decimal](30, 8) NOT NULL,
                                            [Close] [decimal](30, 8) NOT NULL,
                                            [High] [decimal](30, 8) NOT NULL,
                                            [Low] [decimal](30, 8) NOT NULL,
                                            [Time] [datetime] NOT NULL,
                                            [Volume] [decimal](30, 8) NOT NULL,
                                            [FromTime] [datetime] NULL,
                                            CONSTRAINT [PK__tbl_Char__3214EC279FD47705] PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_1440_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_1440_min](
                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                           [Currency] [nvarchar](50) NOT NULL,
                                           [Market] [nvarchar](50) NOT NULL,
                                           [Open] [decimal](30, 8) NOT NULL,
                                           [Close] [decimal](30, 8) NOT NULL,
                                           [High] [decimal](30, 8) NOT NULL,
                                           [Low] [decimal](30, 8) NOT NULL,
                                           [Time] [datetime] NOT NULL,
                                           [Volume] [decimal](30, 8) NOT NULL,
                                           [FromTime] [datetime] NULL,
                                           CONSTRAINT [PK__tbl_Char__3214EC271109C47B] PRIMARY KEY CLUSTERED
                                               (
                                                [ID] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_15_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_15_min](
                                         [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                         [Currency] [nvarchar](50) NOT NULL,
                                         [Market] [nvarchar](50) NOT NULL,
                                         [Open] [decimal](30, 8) NOT NULL,
                                         [Close] [decimal](30, 8) NOT NULL,
                                         [High] [decimal](30, 8) NOT NULL,
                                         [Low] [decimal](30, 8) NOT NULL,
                                         [Time] [datetime] NOT NULL,
                                         [Volume] [decimal](30, 8) NOT NULL,
                                         [FromTime] [datetime] NULL,
                                         CONSTRAINT [PK__tbl_Char__3214EC27FEBE35ED] PRIMARY KEY CLUSTERED
                                             (
                                              [ID] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_240_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_240_min](
                                          [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                          [Currency] [nvarchar](50) NOT NULL,
                                          [Market] [nvarchar](50) NOT NULL,
                                          [Open] [decimal](30, 8) NOT NULL,
                                          [Close] [decimal](30, 8) NOT NULL,
                                          [High] [decimal](30, 8) NOT NULL,
                                          [Low] [decimal](30, 8) NOT NULL,
                                          [Time] [datetime] NOT NULL,
                                          [Volume] [decimal](30, 8) NOT NULL,
                                          [FromTime] [datetime] NULL,
                                          CONSTRAINT [PK__tbl_Char__3214EC27AC67DACA] PRIMARY KEY CLUSTERED
                                              (
                                               [ID] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_43200_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_43200_min](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [Currency] [nvarchar](50) NOT NULL,
                                            [Market] [nvarchar](50) NOT NULL,
                                            [Open] [decimal](30, 8) NOT NULL,
                                            [Close] [decimal](30, 8) NOT NULL,
                                            [High] [decimal](30, 8) NOT NULL,
                                            [Low] [decimal](30, 8) NOT NULL,
                                            [Time] [datetime] NOT NULL,
                                            [Volume] [decimal](30, 8) NOT NULL,
                                            [FromTime] [datetime] NULL,
                                            CONSTRAINT [PK__tbl_Char__3214EC27B3D1C354] PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_5_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_5_min](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [Currency] [nvarchar](50) NOT NULL,
                                        [Market] [nvarchar](50) NOT NULL,
                                        [Open] [decimal](30, 8) NOT NULL,
                                        [Close] [decimal](30, 8) NOT NULL,
                                        [High] [decimal](30, 8) NOT NULL,
                                        [Low] [decimal](30, 8) NOT NULL,
                                        [Time] [datetime] NOT NULL,
                                        [Volume] [decimal](30, 8) NOT NULL,
                                        [FromTime] [datetime] NULL,
                                        CONSTRAINT [PK__tbl_Char__3214EC2707C28FBE] PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Chart_60_min]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Chart_60_min](
                                         [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                         [Currency] [nvarchar](50) NOT NULL,
                                         [Market] [nvarchar](50) NOT NULL,
                                         [Open] [decimal](30, 8) NOT NULL,
                                         [Close] [decimal](30, 8) NOT NULL,
                                         [High] [decimal](30, 8) NOT NULL,
                                         [Low] [decimal](30, 8) NOT NULL,
                                         [Time] [datetime] NOT NULL,
                                         [Volume] [decimal](30, 8) NOT NULL,
                                         [FromTime] [datetime] NULL,
                                         CONSTRAINT [PK__tbl_Char__3214EC27226EB3D1] PRIMARY KEY CLUSTERED
                                             (
                                              [ID] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Checkbook_UserAccounts]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Checkbook_UserAccounts](
                                                   [CID] [bigint] NOT NULL,
                                                   [CheckbookID] [nvarchar](50) NULL,
                                                   [CheckbookKey] [nvarchar](50) NULL,
                                                   [CheckbookSecret] [nvarchar](50) NULL,
                                                   [CreatedOn] [datetime] NOT NULL,
                                                   PRIMARY KEY CLUSTERED
                                                       (
                                                        [CID] ASC
                                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Checkbook_UserBanks]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Checkbook_UserBanks](
                                                [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                [CID] [bigint] NOT NULL,
                                                [BankName] [nvarchar](100) NULL,
                                                [AccountNumber] [nvarchar](50) NULL,
                                                [AccountID] [nvarchar](50) NULL,
                                                [PlaidData] [nvarchar](max) NULL,
                                                [AccountData] [nvarchar](max) NULL,
                                                [CreatedOn] [datetime] NOT NULL,
                                                [IsVerified] [bit] NOT NULL,
                                                PRIMARY KEY CLUSTERED
                                                    (
                                                     [ID] ASC
                                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_checkout_cards]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_checkout_cards](
                                           [id] [bigint] IDENTITY(1,1) NOT NULL,
                                           [cid] [bigint] NOT NULL,
                                           [currency] [nvarchar](10) NULL,
                                           [source_id] [nvarchar](255) NULL,
                                           [last4] [nvarchar](4) NULL,
                                           [card_type] [nvarchar](80) NULL,
                                           [product_type] [nvarchar](255) NULL,
                                           [expiry_month] [int] NOT NULL,
                                           [expiry_year] [int] NOT NULL,
                                           [issuer] [nvarchar](255) NULL,
                                           [issuer_country] [nvarchar](3) NULL,
                                           [payouts] [bit] NOT NULL,
                                           [fast_funds] [nvarchar](2) NULL,
                                           [response_code] [nvarchar](10) NULL,
                                           [added_on] [datetime] NOT NULL,
                                           [is_deleted] [bit] NOT NULL,
                                           [deleted_on] [datetime] NULL,
                                           PRIMARY KEY CLUSTERED
                                               (
                                                [id] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_checkout_giftcard_types]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_checkout_giftcard_types](
                                                    [id] [int] IDENTITY(1,1) NOT NULL,
                                                    [type] [varchar](10) NOT NULL,
                                                    [image] [nvarchar](200) NULL,
                                                    PRIMARY KEY CLUSTERED
                                                        (
                                                         [id] ASC
                                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                                    UNIQUE NONCLUSTERED
                                                        (
                                                         [type] ASC
                                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_checkout_giftcards]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_checkout_giftcards](
                                               [id] [bigint] IDENTITY(1,1) NOT NULL,
                                               [cid] [bigint] NOT NULL,
                                               [amount] [decimal](18, 0) NOT NULL,
                                               [currency] [varchar](10) NULL,
                                               [gift_card_code] [varchar](20) NULL,
                                               [type] [varchar](10) NULL,
                                               [method] [varchar](10) NULL,
                                               [recipient_email] [varchar](50) NULL,
                                               [created_on] [datetime] NOT NULL,
                                               [description] [varchar](max) NULL,
                                               [is_paid] [bit] NOT NULL,
                                               [is_used] [bit] NOT NULL,
                                               [used_by] [varchar](50) NULL,
                                               [used_on] [datetime] NULL,
                                               [recipient_name] [nvarchar](100) NULL,
                                               PRIMARY KEY CLUSTERED
                                                   (
                                                    [id] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                               CONSTRAINT [ux_tbl_checkout_giftcards_gift_card_code] UNIQUE NONCLUSTERED
                                                   (
                                                    [gift_card_code] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_CoinAddRequest]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CoinAddRequest](
                                           [id] [bigint] IDENTITY(1,1) NOT NULL,
                                           [CoinFullName] [nvarchar](50) NOT NULL,
                                           [CoinShortName] [nvarchar](50) NOT NULL,
                                           [BitcoinTalkUrl] [nvarchar](250) NOT NULL,
                                           [OfficialWebsiteUrl] [nvarchar](250) NOT NULL,
                                           [ExplorerUrl] [nvarchar](250) NOT NULL,
                                           [TotalSupply] [bigint] NOT NULL,
                                           [TotalPremine] [bigint] NOT NULL,
                                           [BlockTime] [bigint] NOT NULL,
                                           [Algorithm] [nvarchar](50) NOT NULL,
                                           [CoinType] [nvarchar](50) NOT NULL,
                                           [TwitterHandleUrl] [nvarchar](250) NOT NULL,
                                           [DeveloperEmail] [nvarchar](250) NOT NULL,
                                           [FounderEmail] [nvarchar](250) NOT NULL,
                                           [GithubUrl] [nvarchar](250) NOT NULL,
                                           [Description] [nvarchar](500) NOT NULL,
                                           [RequestDate] [datetime] NULL,
                                           [ConfirmDate] [datetime] NULL,
                                           [Status] [nvarchar](50) NOT NULL,
                                           [ApprovedBy] [nvarchar](50) NULL,
                                           PRIMARY KEY CLUSTERED
                                               (
                                                [id] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_CoinStats]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CoinStats](
                                      [ExchangeTicker] [varchar](10) NOT NULL,
                                      [DataSource] [nvarchar](50) NULL,
                                      [CoinName] [nvarchar](100) NULL,
                                      [symbol] [nvarchar](max) NULL,
                                      [slug] [nvarchar](max) NULL,
                                      [image] [nvarchar](max) NULL,
                                      [rank] [smallint] NULL,
                                      [price] [nvarchar](100) NULL,
                                      [volume24h] [nvarchar](100) NULL,
                                      [marketCap] [nvarchar](100) NULL,
                                      [priceChangePercent24hr] [nvarchar](100) NULL,
                                      [circulatingSupply] [nvarchar](max) NULL,
                                      [sparkline] [nvarchar](max) NULL,
                                      [maxSupply] [nvarchar](max) NULL,
                                      [priceChangePercent1h] [nvarchar](100) NULL,
                                      [priceChangePercent7d] [nvarchar](100) NULL,
                                      [priceChangePercent30] [nvarchar](100) NULL,
                                      [issueDate] [datetime] NULL,
                                      [lastUpdated] [datetime] NULL,
                                      [tags] [nvarchar](max) NULL,
                                      [description] [nvarchar](max) NULL,
                                      [links_website] [nvarchar](max) NULL,
                                      [links_reddit] [nvarchar](max) NULL,
                                      [links_forum] [nvarchar](max) NULL,
                                      [links_explorer] [nvarchar](max) NULL,
                                      [links_sourceCode] [nvarchar](max) NULL,
                                      [links_technicalDoc] [nvarchar](max) NULL,
                                      [last_updatedon] [datetime] NULL,
                                      CONSTRAINT [PK_tbl_CoinStats] PRIMARY KEY CLUSTERED
                                          (
                                           [ExchangeTicker] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ColdWalletAddresses]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_ColdWalletAddresses](
                                                [Currency] [varchar](10) NOT NULL,
                                                [Addresss] [nvarchar](100) NULL,
                                                [MinBalance] [decimal](18, 8) NOT NULL,
                                                [LastChecked] [datetime] NOT NULL,
                                                [IsActive] [bit] NOT NULL,
                                                CONSTRAINT [PK__tbl_Cold_Wallet_Addresses] PRIMARY KEY CLUSTERED
                                                    (
                                                     [Currency] ASC
                                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ColdWalletTransactions]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_ColdWalletTransactions](
                                                   [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                   [Currency] [varchar](10) NULL,
                                                   [Address] [nvarchar](100) NULL,
                                                   [Amount] [decimal](18, 8) NOT NULL,
                                                   [TxnDate] [datetime] NOT NULL,
                                                   [TxnHash] [nvarchar](200) NULL,
                                                   PRIMARY KEY CLUSTERED
                                                       (
                                                        [ID] ASC
                                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_CopyTrade_Followers]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CopyTrade_Followers](
                                                [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                [ProTraderCID] [bigint] NOT NULL,
                                                [FollowerCID] [bigint] NOT NULL,
                                                [FollowedOn] [datetime] NOT NULL,
                                                [UnFollowedOn] [datetime] NULL,
                                                [FollowRatio] [decimal](18, 8) NOT NULL,
                                                CONSTRAINT [tbl_CopyTrade_Followers_ID] PRIMARY KEY NONCLUSTERED
                                                    (
                                                     [ID] ASC
                                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_CopyTrade_Orders]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CopyTrade_Orders](
                                             [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                             [ProTraderOrderID] [bigint] NOT NULL,
                                             [FollowerOrderID] [bigint] NOT NULL,
                                             [CopiedOn] [datetime] NOT NULL,
                                             [ProTraderCID] [bigint] NOT NULL,
                                             [FollowerCID] [bigint] NOT NULL,
                                             [Side] [nvarchar](5) NOT NULL,
                                             PRIMARY KEY CLUSTERED
                                                 (
                                                  [ID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Country]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Country](
                                    [Country ] [nvarchar](max) NOT NULL,
                                    [Countrycode] [nvarchar](255) NULL,
                                    [Internationaldialing] [nvarchar](255) NULL,
                                    [id] [int] IDENTITY(1,1) NOT NULL,
                                    [CountryCode3] [nvarchar](3) NULL,
                                    PRIMARY KEY CLUSTERED
                                        (
                                         [id] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                    UNIQUE NONCLUSTERED
                                        (
                                         [Countrycode] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_CurrencyPrefrences]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CurrencyPrefrences](
                                               [CurrencyID] [int] IDENTITY(1,1) NOT NULL,
                                               [CurrencyFullName] [nvarchar](50) NOT NULL,
                                               [CurrencyShortName] [nvarchar](10) NOT NULL,
                                               [CurrencyIcon] [nvarchar](50) NOT NULL,
                                               [TransactionTypeMin] [int] NOT NULL,
                                               [DaemonUrl] [nvarchar](100) NULL,
                                               [RpcUsername] [nvarchar](100) NULL,
                                               [RpcPassword] [nvarchar](100) NULL,
                                               [WalletPassword] [nvarchar](500) NULL,
                                               [AdditionDate] [datetime] NOT NULL,
                                               [Status] [bit] NOT NULL,
                                               [ServiceCharge_Withdrawal] [decimal](18, 8) NOT NULL,
                                               [ServiceCharge_Buy] [decimal](18, 8) NOT NULL,
                                               [ServiceCharge_Sell] [decimal](18, 8) NOT NULL,
                                               [Rank] [int] NOT NULL,
                                               [ConfCount] [int] NOT NULL,
                                               [ContractAddress] [nvarchar](100) NULL,
                                               [MinWithdrawalLimit] [decimal](18, 8) NOT NULL,
                                               [MaxWithdrawalLimit] [decimal](18, 8) NOT NULL,
                                               [CoinWalletType] [nvarchar](50) NOT NULL,
                                               [ExplorerUrl] [nvarchar](100) NULL,
                                               [DecimalPrecision] [int] NOT NULL,
                                               [ServiceCharge_Withdrawal_InBTC] [decimal](18, 8) NOT NULL,
                                               [EnableDeposit] [bit] NOT NULL,
                                               [EnableTrade] [bit] NOT NULL,
                                               [EnableWithdrawal] [bit] NOT NULL,
                                               [IsMarket] [bit] NOT NULL,
                                               [IsWithdrawFeeFixedFee] [bit] NULL,
                                               [EnableTrade_Buy] [bit] NOT NULL,
                                               [EnableTrade_Sell] [bit] NOT NULL,
                                               [InterestRate] [decimal](18, 8) NOT NULL,
                                               [isColdStorage] [bit] NOT NULL,
                                               [ServiceCharge_Buy1] [decimal](18, 8) NOT NULL,
                                               [ServiceCharge_Sell1] [decimal](18, 8) NOT NULL,
                                               [ISIN] [nvarchar](50) NULL,
                                               [CFI_Code] [nvarchar](50) NULL,
                                               [Bloomberg_Ticker] [nvarchar](50) NULL,
                                               [IsWalletPasswordEncrypted] [bit] NOT NULL,
                                               [DTMemo] [bit] NOT NULL,
                                               [DTMemoTitle] [nvarchar](20) NULL,
                                               [MinDeposit] [decimal](18, 8) NOT NULL,
                                               [MinDepositForAlerts] [decimal](18, 8) NOT NULL,
                                               [NetworkName] [nvarchar](50) NULL,
                                               [AddressRegex] [nvarchar](50) NULL,
                                               CONSTRAINT [tbl_CurrencyPrefrences_primaryKey] PRIMARY KEY NONCLUSTERED
                                                   (
                                                    [CurrencyShortName] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                               UNIQUE NONCLUSTERED
                                                   (
                                                    [TransactionTypeMin] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer](
                                     [CID] [bigint] NOT NULL,
                                     [FirstName] [nvarchar](50) NULL,
                                     [MiddleName] [nvarchar](50) NULL,
                                     [LastName] [nvarchar](50) NULL,
                                     [Name] [nvarchar](50) NOT NULL,
                                     [LoginName] [nvarchar](10) NOT NULL,
                                     [LoginPassword] [nvarchar](250) NOT NULL,
                                     [Gender] [nvarchar](10) NULL,
                                     [DOB] [date] NULL,
                                     [MaritalStatus] [nvarchar](10) NULL,
                                     [FatherName] [nvarchar](50) NULL,
                                     [City] [nvarchar](50) NULL,
                                     [District] [nvarchar](50) NULL,
                                     [State] [nvarchar](50) NULL,
                                     [Country] [nvarchar](50) NULL,
                                     [Address] [nvarchar](100) NULL,
                                     [PostalCode] [nvarchar](6) NULL,
                                     [Mobile] [varchar](15) NOT NULL,
                                     [Email] [varchar](50) NOT NULL,
                                     [PassportNo] [nvarchar](50) NULL,
                                     [DOJ] [datetime] NOT NULL,
                                     [Status] [nvarchar](10) NOT NULL,
                                     [Nationality] [nvarchar](50) NULL,
                                     [NationalityStatus] [bit] NOT NULL,
                                     [isProfileApproved] [bit] NOT NULL,
                                     [isAddressApproved] [bit] NOT NULL,
                                     [isPassportApproved] [bit] NOT NULL,
                                     [isSignatureApproved] [bit] NOT NULL,
                                     [ApprovedBy] [nvarchar](50) NULL,
                                     [GoogleAuthKey] [nvarchar](50) NOT NULL,
                                     [IsAuthenticationRequired] [bit] NOT NULL,
                                     [IsUserBlocked] [bit] NOT NULL,
                                     [TelegramID] [nvarchar](50) NULL,
                                     [WebHookUrl] [nvarchar](50) NULL,
                                     [WebHookKey] [nvarchar](50) NULL,
                                     [KycDetailStatus] [nvarchar](20) NULL,
                                     [KycDetailRemark] [nvarchar](250) NULL,
                                     [ProfileIMG] [nvarchar](50) NULL,
                                     [KycProfileImageStatus] [nvarchar](max) NULL,
                                     [KycProfileImageRemark] [nvarchar](250) NULL,
                                     [AddressProofIMG] [nvarchar](50) NULL,
                                     [KycAddressImageStatus] [nvarchar](10) NULL,
                                     [KycAddressImageRemark] [nvarchar](250) NULL,
                                     [PassportIMG] [nvarchar](50) NULL,
                                     [KycPassportImageStatus] [nvarchar](10) NULL,
                                     [KycPassportImageRemark] [nvarchar](250) NULL,
                                     [ReferralId] [bigint] NULL,
                                     [TeamReferral] [bigint] NOT NULL,
                                     [EnableCopyTrading] [bit] NOT NULL,
                                     [EnableMarginTrading] [bit] NOT NULL,
                                     [CustomerType] [nvarchar](20) NULL,
                                     [ParentCID] [bigint] NULL,
                                     [SubAccountID] [nvarchar](100) NULL,
                                     [SubAccountTitle] [nvarchar](200) NULL,
                                     [IsMobileVerified] [bit] NOT NULL,
                                     [PriceChangeAlert] [bit] NOT NULL,
                                     [CustomerCategoryID] [int] NOT NULL,
                                     CONSTRAINT [PKCID] PRIMARY KEY CLUSTERED
                                         (
                                          [CID] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                     CONSTRAINT [UniqueAuthKey] UNIQUE NONCLUSTERED
                                         (
                                          [GoogleAuthKey] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                     CONSTRAINT [UniqueEmail] UNIQUE NONCLUSTERED
                                         (
                                          [Email] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                     CONSTRAINT [UniqueLoginName] UNIQUE NONCLUSTERED
                                         (
                                          [LoginName] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_Autosell]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_Autosell](
                                              [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                              [CID] [bigint] NOT NULL,
                                              [Market] [varchar](10) NOT NULL,
                                              [Currency] [varchar](10) NOT NULL,
                                              [AddedOn] [datetime] NOT NULL,
                                              CONSTRAINT [PK_tbl_Customer_Autosell] PRIMARY KEY CLUSTERED
                                                  (
                                                   [ID] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_Autosell_Deleted]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_Autosell_Deleted](
                                                      [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                      [CID] [bigint] NOT NULL,
                                                      [Market] [varchar](50) NULL,
                                                      [Addedon] [datetime] NULL,
                                                      [Deletedon] [datetime] NULL,
                                                      [CurrencyName] [varchar](10) NULL,
                                                      CONSTRAINT [PK_tbl_Customer_Autosell_Deleted] PRIMARY KEY CLUSTERED
                                                          (
                                                           [ID] ASC
                                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_favCoins]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_favCoins](
                                              [id] [bigint] IDENTITY(1,1) NOT NULL,
                                              [cid] [bigint] NULL,
                                              [coin] [nvarchar](50) NULL,
                                              CONSTRAINT [PK_tbl_Customer_favCoins] PRIMARY KEY CLUSTERED
                                                  (
                                                   [id] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_favPairs]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_favPairs](
                                              [id] [bigint] IDENTITY(1,1) NOT NULL,
                                              [cid] [bigint] NULL,
                                              [pair] [nvarchar](50) NULL,
                                              CONSTRAINT [PK_tbl_Customer_favPairs] PRIMARY KEY CLUSTERED
                                                  (
                                                   [id] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_fido2]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_fido2](
                                           [cid] [bigint] NOT NULL,
                                           [stored_credentials] [nvarchar](max) NULL,
                                           [identifier] [nvarchar](1000) NULL,
                                           [userHandle] [nvarchar](1000) NULL,
                                           CONSTRAINT [PK_tbl_Customer_fido2] PRIMARY KEY CLUSTERED
                                               (
                                                [cid] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_FieldsMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_FieldsMaster](
                                                  [id] [int] IDENTITY(1,1) NOT NULL,
                                                  [FieldLabel] [nvarchar](50) NULL,
                                                  [FieldType] [nvarchar](50) NULL,
                                                  [DefaultValues] [nvarchar](max) NULL,
                                                  [RequiredValidation] [bit] NULL,
                                                  [ValidationRegEx] [nvarchar](max) NULL,
                                                  [isDeleted] [bit] NULL,
                                                  [isActive] [bit] NULL,
                                                  [Placeholder] [nvarchar](100) NULL,
                                                  [Country] [nvarchar](3) NOT NULL,
                                                  [IsUnique] [bit] NOT NULL,
                                                  CONSTRAINT [PK_tbl_Customer_FieldsMaster] PRIMARY KEY CLUSTERED
                                                      (
                                                       [id] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_IP_Whitelist]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_IP_Whitelist](
                                                  [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                  [CID] [bigint] NOT NULL,
                                                  [CIDR] [nvarchar](50) NULL,
                                                  [Type] [nvarchar](20) NULL,
                                                  [AddedOn] [datetime] NOT NULL,
                                                  [IsDeleted] [bit] NOT NULL,
                                                  [DeletedOn] [datetime] NULL,
                                                  PRIMARY KEY CLUSTERED
                                                      (
                                                       [ID] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customer_Updates]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customer_Updates](
                                             [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                             [CID] [bigint] NOT NULL,
                                             [Old_detail] [nvarchar](max) NOT NULL,
                                             [New_detail] [nvarchar](max) NOT NULL,
                                             [UpdatedAt] [datetime] NULL,
                                             [UpdatedBy] [nvarchar](50) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_CustomerCategory]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_CustomerCategory](
                                             [ID] [int] IDENTITY(1,1) NOT NULL,
                                             [CategoryName] [varchar](20) NOT NULL,
                                             [VerificationFlow] [varchar](20) NOT NULL,
                                             [Description] [varchar](50) NOT NULL,
                                             PRIMARY KEY CLUSTERED
                                                 (
                                                  [ID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Customers_FieldValues]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Customers_FieldValues](
                                                  [id] [bigint] IDENTITY(1,1) NOT NULL,
                                                  [cid] [bigint] NOT NULL,
                                                  [fieldid] [int] NOT NULL,
                                                  [fieldValue] [nvarchar](max) NOT NULL,
                                                  [addedOn] [datetime] NOT NULL,
                                                  CONSTRAINT [PK_tbl_Customers_FieldValues] PRIMARY KEY CLUSTERED
                                                      (
                                                       [id] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Deposit]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Deposit](
                                    [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                    [CID] [bigint] NOT NULL,
                                    [DepositAmount] [decimal](18, 8) NOT NULL,
                                    [EquivalentUsdAmt] [decimal](30, 2) NOT NULL,
                                    [EquivalentBTC] [decimal](18, 8) NOT NULL,
                                    [DepositType] [nvarchar](10) NOT NULL,
                                    [DepositAddress] [nvarchar](250) NOT NULL,
                                    [Particulars] [nvarchar](250) NOT NULL,
                                    [DepositReqDate] [datetime] NOT NULL,
                                    [DepositConfirmDate] [datetime] NULL,
                                    [DepositStatus] [bit] NOT NULL,
                                    [TXNHash] [nvarchar](250) NOT NULL,
                                    [CurrentTxnCount] [int] NOT NULL,
                                    [RequiredTxnCount] [int] NOT NULL,
                                    [IsTokenDeposit] [bit] NOT NULL,
                                    [IsPassedTravelRule] [bit] NOT NULL,
                                    CONSTRAINT [PK__tbl_Depo__3214EC277D77383A] PRIMARY KEY CLUSTERED
                                        (
                                         [ID] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                    CONSTRAINT [TxnHashCID] UNIQUE NONCLUSTERED
                                        (
                                         [TXNHash] ASC,
                                         [CID] ASC,
                                         [DepositType] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_deposit_limits]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_deposit_limits](
                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                           [Currency] [nchar](10) NOT NULL,
                                           [Limit] [decimal](18, 8) NOT NULL,
                                           [LimitLevel] [int] NOT NULL,
                                           [RollingLimit] [int] NOT NULL,
                                           [LimitType] [nvarchar](20) NULL,
                                           [AutoDepositLimit] [decimal](18, 8) NULL,
                                           [MinDepositLimit] [decimal](18, 8) NOT NULL,
                                           [MaxDepositLimit] [decimal](18, 8) NOT NULL,
                                           CONSTRAINT [PK_tbl_customer_deposit_limits] PRIMARY KEY CLUSTERED
                                               (
                                                [ID] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_DepositBonus]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_DepositBonus](
                                         [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                         [DepositCurrency] [varchar](10) NOT NULL,
                                         [BonusCurrency] [varchar](10) NOT NULL,
                                         [DepositorKYCLevel] [int] NOT NULL,
                                         [ReferrerKYCLevel] [int] NOT NULL,
                                         [MinDeposit] [decimal](18, 8) NOT NULL,
                                         [SelfBonus] [decimal](18, 8) NOT NULL,
                                         [ReferrerBonus] [decimal](18, 8) NOT NULL,
                                         [StartDate] [date] NULL,
                                         [DeletedOn] [datetime] NULL,
                                         [IsDeleted] [bit] NULL,
                                         [AddedOn] [datetime] NULL,
                                         [SelfBonusType] [char](1) NULL,
                                         [ReferrerBonusType] [char](1) NULL,
                                         PRIMARY KEY CLUSTERED
                                             (
                                              [ID] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Devices]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Devices](
                                    [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                    [CID] [bigint] NOT NULL,
                                    [DeviceID] [nvarchar](50) NULL,
                                    [Browser] [nvarchar](50) NULL,
                                    [OS] [nvarchar](50) NULL,
                                    [Device] [nvarchar](50) NULL,
                                    [IP] [nvarchar](50) NULL,
                                    [AddedOn] [datetime] NOT NULL,
                                    [IsVerified] [bit] NOT NULL,
                                    PRIMARY KEY CLUSTERED
                                        (
                                         [ID] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                    CONSTRAINT [UC_tbl_Devices_CID_DeviceID] UNIQUE NONCLUSTERED
                                        (
                                         [CID] ASC,
                                         [DeviceID] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ExceptionLog]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_ExceptionLog](
                                         [id] [bigint] IDENTITY(1,1) NOT NULL,
                                         [ProcName] [nvarchar](100) NULL,
                                         [Message] [nvarchar](3500) NULL,
                                         [OccuredOn] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Favourite_Wallets]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Favourite_Wallets](
                                              [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                              [CID] [bigint] NOT NULL,
                                              [Currency] [nvarchar](10) NOT NULL,
                                              [Pairs] [varchar](max) NULL,
                                              CONSTRAINT [PK_tbl_Favourite_Wallets] PRIMARY KEY CLUSTERED
                                                  (
                                                   [ID] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_FeeDiscount_VolumeBased]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_FeeDiscount_VolumeBased](
                                                    [id] [bigint] IDENTITY(1,1) NOT NULL,
                                                    [currency] [nvarchar](10) NOT NULL,
                                                    [limit] [decimal](18, 4) NOT NULL,
                                                    [discount] [decimal](18, 4) NOT NULL,
                                                    [IsDeleted] [bit] NOT NULL,
                                                    [AddedOn] [datetime] NOT NULL,
                                                    [DeletedOn] [datetime] NULL,
                                                    CONSTRAINT [PK_tbl_FeeDiscount_VolumeBased] PRIMARY KEY CLUSTERED
                                                        (
                                                         [id] ASC
                                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_FeeDiscount_VolumeBased_VolumeBasedV2]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_FeeDiscount_VolumeBased_VolumeBasedV2](
                                                                  [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                                                  [TargetVolume] [decimal](18, 2) NULL,
                                                                  [Discount] [decimal](18, 2) NULL,
                                                                  [BonusTokens] [decimal](18, 2) NULL,
                                                                  [Collateral] [decimal](18, 2) NULL,
                                                                  [TimePeriod_Days] [int] NULL,
                                                                  [GroupName] [nvarchar](15) NULL,
                                                                  [TargetVolumeType] [nvarchar](10) NOT NULL,
                                                                  PRIMARY KEY CLUSTERED
                                                                      (
                                                                       [Id] ASC
                                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_FeeDiscountEligibility]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_FeeDiscountEligibility](
                                                   [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                   [Cid] [bigint] NULL,
                                                   [EntryDate] [datetime] NULL,
                                                   [V2ID] [bigint] NULL,
                                                   PRIMARY KEY CLUSTERED
                                                       (
                                                        [ID] ASC
                                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_FeeSweepAddresses]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_FeeSweepAddresses](
                                              [ID] [int] IDENTITY(1,1) NOT NULL,
                                              [CoinType] [varchar](10) NOT NULL,
                                              [FeeWalletAddress] [nvarchar](max) NOT NULL,
                                              PRIMARY KEY CLUSTERED
                                                  (
                                                   [ID] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_FeeUserGroups]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_FeeUserGroups](
                                          [id] [bigint] IDENTITY(1,1) NOT NULL,
                                          [GroupTitle] [nvarchar](50) NOT NULL,
                                          [CID] [bigint] NOT NULL,
                                          [FeePerc] [float] NOT NULL,
                                          [isDeleted] [bit] NOT NULL,
                                          [AddedOn] [datetime] NULL,
                                          [DeletedOn] [datetime] NULL,
                                          CONSTRAINT [PK_tbl_FeeUserGroups] PRIMARY KEY NONCLUSTERED
                                              (
                                               [id] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Fiat_BanksList]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Fiat_BanksList](
                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                           [BankName] [nvarchar](50) NULL,
                                           [BranchName] [nvarchar](50) NULL,
                                           [BranchCity] [nvarchar](50) NULL,
                                           [BranchProvince] [nvarchar](50) NULL,
                                           [BranchCountry] [nvarchar](50) NULL,
                                           [AccountCurrency] [varchar](10) NULL,
                                           [BeneficiaryName] [nvarchar](50) NULL,
                                           [AccountNumber] [nvarchar](50) NULL,
                                           [BankRoutingCode] [nvarchar](50) NULL,
                                           [BranchRoutingCode] [nvarchar](50) NULL,
                                           [SwiftCode] [nvarchar](50) NULL,
                                           [IsActive] [bit] NULL,
                                           CONSTRAINT [PK_Fiat_BanksList] PRIMARY KEY CLUSTERED
                                               (
                                                [ID] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Fiat_CustomersAccounts]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Fiat_CustomersAccounts](
                                                   [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                   [CID] [bigint] NOT NULL,
                                                   [BankName] [nvarchar](50) NULL,
                                                   [AccountCurrency] [varchar](10) NULL,
                                                   [AccountType] [nvarchar](50) NULL,
                                                   [AccountNumber] [nvarchar](50) NULL,
                                                   [BankRoutingCode] [nvarchar](50) NULL,
                                                   [SwiftCode] [nvarchar](50) NULL,
                                                   [ForModule] [nvarchar](50) NULL,
                                                   [IsDeleted] [bit] NULL,
                                                   [isVerified] [bit] NOT NULL,
                                                   [accountid] [nvarchar](50) NULL,
                                                   [comments] [nvarchar](500) NULL,
                                                   CONSTRAINT [PK_Fiat_CustomersAccounts] PRIMARY KEY CLUSTERED
                                                       (
                                                        [ID] ASC
                                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Fiat_Manual_Deposit_Requests]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Fiat_Manual_Deposit_Requests](
                                                         [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                         [CID] [bigint] NULL,
                                                         [RequestDate] [datetime] NULL,
                                                         [RequestAmount] [money] NULL,
                                                         [TransactionID] [nvarchar](200) NULL,
                                                         [Comments] [nvarchar](50) NULL,
                                                         [Status] [nvarchar](10) NULL,
                                                         [ApprovedBy] [nvarchar](50) NULL,
                                                         [BankID] [bigint] NULL,
                                                         [DepositID] [bigint] NULL,
                                                         [ApprovedDate] [datetime] NULL,
                                                         [TransactionID_Admin] [nvarchar](1000) NULL,
                                                         [Email] [nvarchar](max) NULL,
                                                         CONSTRAINT [PK_Fiat_Manual_Deposit_Requests] PRIMARY KEY CLUSTERED
                                                             (
                                                              [ID] ASC
                                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Fiat_Manual_Withdrawal_Requests]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests](
                                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                            [CID] [bigint] NOT NULL,
                                                            [WithdrawalID] [nvarchar](50) NOT NULL,
                                                            [RequestDate] [datetime] NOT NULL,
                                                            [RequestAmount] [decimal](12, 2) NOT NULL,
                                                            [Status] [nvarchar](10) NOT NULL,
                                                            [CurrencyName] [nvarchar](10) NOT NULL,
                                                            [BankName] [nvarchar](250) NOT NULL,
                                                            [BeneficiaryName] [nvarchar](250) NOT NULL,
                                                            [AccountNumber] [nvarchar](50) NOT NULL,
                                                            [BankRoutingCode] [nvarchar](50) NOT NULL,
                                                            [SwiftCode] [nvarchar](50) NOT NULL,
                                                            [ApprovedDate] [datetime] NULL,
                                                            [TransactionID_Admin] [nvarchar](50) NULL,
                                                            [Comments] [nvarchar](50) NULL,
                                                            [ApprovedBy] [nvarchar](50) NULL,
                                                            [WithdrawalFee] [decimal](12, 2) NOT NULL,
                                                            [UserConfirmationID] [nvarchar](50) NOT NULL,
                                                            [IsConfirmedByUser] [bit] NOT NULL,
                                                            [Memo] [nvarchar](200) NULL,
                                                            CONSTRAINT [PK__tbl_Fiat__3214EC2781864D91] PRIMARY KEY CLUSTERED
                                                                (
                                                                 [ID] ASC
                                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Fiat_Payment_Gateways]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Fiat_Payment_Gateways](
                                                  [ID] [smallint] IDENTITY(1,1) NOT NULL,
                                                  [PG_Name] [varchar](50) NOT NULL,
                                                  [PG_Currency] [varchar](10) NOT NULL,
                                                  [Json_Settings] [nvarchar](max) NULL,
                                                  [IPN_Url] [varchar](100) NULL,
                                                  [Entry_On] [datetime] NOT NULL,
                                                  [LastUpdatedOn] [datetime] NOT NULL,
                                                  [Fee_In_Percent] [decimal](18, 8) NOT NULL,
                                                  [PG_URL] [varchar](100) NULL,
                                                  [IsActive] [bit] NOT NULL,
                                                  [MinTxnAmount] [decimal](18, 8) NOT NULL,
                                                  [MaxTxnAmount] [decimal](18, 8) NOT NULL,
                                                  [FixedFee] [decimal](18, 8) NOT NULL,
                                                  [MinFee] [decimal](18, 8) NOT NULL,
                                                  [MaxFee] [decimal](18, 8) NOT NULL,
                                                  [PG_Mode] [nvarchar](1) NULL,
                                                  [EnableAutoWithdrawals] [bit] NOT NULL,
                                                  CONSTRAINT [PK__tbl_Fiat__3214EC2781317BA8] PRIMARY KEY CLUSTERED
                                                      (
                                                       [ID] ASC
                                                          )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Fiat_PG_Payments]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Fiat_PG_Payments](
                                             [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                             [Txn_GUID] [varchar](36) NOT NULL,
                                             [CID] [bigint] NOT NULL,
                                             [PG_ID] [smallint] NOT NULL,
                                             [Redirect_Url] [varchar](150) NULL,
                                             [Response_Url] [varchar](100) NULL,
                                             [Amount] [decimal](18, 8) NOT NULL,
                                             [Fee] [decimal](18, 8) NOT NULL,
                                             [Total] [decimal](18, 8) NOT NULL,
                                             [Request_Date] [datetime] NOT NULL,
                                             [Response_Date] [datetime] NULL,
                                             [Status] [varchar](10) NOT NULL,
                                             [Comment] [varchar](max) NULL,
                                             [PG_Txn_ID] [varchar](50) NULL,
                                             PRIMARY KEY CLUSTERED
                                                 (
                                                  [ID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                             UNIQUE NONCLUSTERED
                                                 (
                                                  [Txn_GUID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_GeoFencing]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_GeoFencing](
                                       [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                       [Country] [nvarchar](2) NOT NULL,
                                       [Region ] [nvarchar](500) NOT NULL,
                                       PRIMARY KEY CLUSTERED
                                           (
                                            [ID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_InstaPair_Reserve]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_InstaPair_Reserve](
                                              [ID] [int] IDENTITY(1,1) NOT NULL,
                                              [Currency] [varchar](10) NOT NULL,
                                              [Reserve] [decimal](18, 8) NOT NULL,
                                              PRIMARY KEY CLUSTERED
                                                  (
                                                   [ID] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_InstaPairs]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_InstaPairs](
                                       [id] [int] IDENTITY(1,1) NOT NULL,
                                       [base_curr] [varchar](10) NULL,
                                       [quote_curr] [varchar](10) NULL,
                                       [min_limit] [decimal](18, 8) NOT NULL,
                                       [max_limit] [decimal](18, 8) NOT NULL,
                                       [margin] [float] NOT NULL,
                                       [miner_fee] [decimal](18, 8) NOT NULL,
                                       [commission] [decimal](18, 8) NULL,
                                       [isActive] [bit] NOT NULL,
                                       [Reserve] [decimal](18, 8) NOT NULL,
                                       [rate] [decimal](18, 8) NOT NULL,
                                       [AutoPriceUpdate] [bit] NULL,
                                       CONSTRAINT [PK_tbl_InstaPairs] PRIMARY KEY CLUSTERED
                                           (
                                            [id] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_InstaTrade]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_InstaTrade](
                                       [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                       [OrderID] [varchar](100) NOT NULL,
                                       [CID] [bigint] NOT NULL,
                                       [BaseCurrency] [varchar](13) NOT NULL,
                                       [QuoteCurrency] [varchar](10) NOT NULL,
                                       [Rate] [decimal](18, 8) NOT NULL,
                                       [Commission] [decimal](18, 8) NOT NULL,
                                       [BaseAmount] [decimal](18, 8) NOT NULL,
                                       [QuoteAmount] [decimal](18, 8) NOT NULL,
                                       [RequestedOn] [datetime] NOT NULL,
                                       [Status] [bit] NOT NULL,
                                       [PaymentID] [nvarchar](36) NULL,
                                       [AC] [bit] NOT NULL,
                                       [AC_Status] [bit] NOT NULL,
                                       [AC_OrderID] [varchar](50) NULL,
                                       [AC_Comment] [nvarchar](max) NULL,
                                       [AC_Currency] [varchar](10) NULL,
                                       [Side] [nvarchar](10) NULL,
                                       PRIMARY KEY CLUSTERED
                                           (
                                            [ID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Invoice]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Invoice](
                                    [ID] [bigint] IDENTITY(1000,1) NOT NULL,
                                    [CID] [bigint] NOT NULL,
                                    [Name] [varchar](50) NULL,
                                    [Email] [varchar](50) NULL,
                                    [PhoneNo] [varchar](15) NULL,
                                    [NationalID] [varchar](50) NULL,
                                    [InvoiceDate] [datetime] NOT NULL,
                                    [InvoiceType] [varchar](20) NULL,
                                    [Currency] [varchar](10) NULL,
                                    [BeforeTaxAmount] [decimal](18, 8) NOT NULL,
                                    [TaxPercentage] [decimal](4, 2) NOT NULL,
                                    [TaxAmount] [decimal](18, 8) NOT NULL,
                                    [AfterTaxAmount] [decimal](18, 8) NOT NULL,
                                    [ReferenceID] [bigint] NOT NULL,
                                    PRIMARY KEY CLUSTERED
                                        (
                                         [ID] ASC
                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_KYC_Corporate]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_KYC_Corporate](
                                          [CID] [bigint] NOT NULL,
                                          [ID] [int] NOT NULL,
                                          [FirstName] [nvarchar](100) NULL,
                                          [LastName] [nvarchar](100) NULL,
                                          [CompanyName] [nvarchar](100) NULL,
                                          [Type] [nvarchar](20) NULL,
                                          [Ownership] [decimal](5, 2) NOT NULL,
                                          [Data] [nvarchar](max) NULL,
                                          [Status] [nvarchar](20) NULL,
                                          [Provider] [nvarchar](20) NULL,
                                          [Info] [nvarchar](max) NULL,
                                          [RejectReason] [nvarchar](max) NULL,
                                          [RawResponse] [nvarchar](max) NULL,
                                          [StartedOn] [datetime] NOT NULL,
                                          [SubmittedOn] [datetime] NULL,
                                          [UpdatedOn] [datetime] NULL,
                                          [ProfileOnS3] [bit] NOT NULL,
                                          CONSTRAINT [PK_tbl_KYC_Corporate] PRIMARY KEY CLUSTERED
                                              (
                                               [CID] ASC,
                                               [ID] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Language]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Language](
                                     [ID] [int] IDENTITY(1,1) NOT NULL,
                                     [Code] [varchar](10) NOT NULL,
                                     [Language] [nvarchar](max) NULL,
                                     PRIMARY KEY CLUSTERED
                                         (
                                          [ID] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                     UNIQUE NONCLUSTERED
                                         (
                                          [Code] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_LoginManager]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_LoginManager](
                                         [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                         [UniqueID] [nvarchar](50) NOT NULL,
                                         [CID] [bigint] NULL,
                                         [LoginStatus] [bit] NOT NULL,
                                         [IsUIDVerified] [bit] NOT NULL,
                                         [IP] [nvarchar](100) NOT NULL,
                                         [LastTrade] [nvarchar](10) NOT NULL,
                                         [LastMarket] [nvarchar](10) NOT NULL,
                                         [FirstUsed] [datetime] NOT NULL,
                                         [LastUsed] [datetime] NOT NULL,
                                         [ValidTill] [datetime] NOT NULL,
                                         [OTP] [nvarchar](10) NULL,
                                         [OTPType] [nvarchar](10) NULL,
                                         [OTPValidTillUTC] [datetime] NULL,
                                         CONSTRAINT [PK__tbl_Logi__A2A2BAAAF6BD002E] PRIMARY KEY CLUSTERED
                                             (
                                              [UniqueID] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Market]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Market](
                                   [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                   [CoinName] [nvarchar](10) NOT NULL,
                                   [CurrentTradingPrice] [decimal](38, 8) NOT NULL,
                                   [TotalVolume] [decimal](38, 8) NOT NULL,
                                   [ChangeInPrice] [decimal](38, 8) NOT NULL,
                                   [PreviousTradingPrice] [decimal](38, 8) NOT NULL,
                                   [MarketName] [nvarchar](10) NOT NULL,
                                   [Status] [bit] NOT NULL,
                                   [GMEURL] [nvarchar](50) NOT NULL,
                                   [TotalVolumeBaseCurrency] [decimal](38, 8) NOT NULL,
                                   [Last24HrsLow] [decimal](38, 8) NOT NULL,
                                   [Last24HrsHigh] [decimal](38, 8) NOT NULL,
                                   [MinTradeAmount] [decimal](18, 8) NOT NULL,
                                   [MinTickSize] [decimal](18, 8) NOT NULL,
                                   [MinOrderValue] [decimal](18, 8) NOT NULL,
                                   [EnableMarginTrading] [bit] NOT NULL,
                                   [MakerFee] [decimal](18, 8) NOT NULL,
                                   [TakerFee] [decimal](18, 8) NOT NULL,
                                   [MakerFeePro] [decimal](18, 8) NOT NULL,
                                   [TakerFeePro] [decimal](18, 8) NOT NULL,
                                   [MaxSize] [decimal](18, 8) NOT NULL,
                                   [MaxOrderAmount] [decimal](18, 8) NOT NULL,
                                   [MaxMarketOrderSize] [decimal](18, 8) NOT NULL,
                                   [IsFixedFee] [bit] NOT NULL,
                                   CONSTRAINT [tbl_Market_primaryKey] PRIMARY KEY NONCLUSTERED
                                       (
                                        [CoinName] ASC,
                                        [MarketName] ASC
                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_MarketGroups]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_MarketGroups](
                                         [id] [int] IDENTITY(1,1) NOT NULL,
                                         [GroupName] [nvarchar](50) NULL,
                                         [MarketName] [nvarchar](10) NULL,
                                         CONSTRAINT [PK_tbl_MarketGroups] PRIMARY KEY CLUSTERED
                                             (
                                              [id] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_MatchedOrder]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_MatchedOrder](
                                         [OrderID] [bigint] IDENTITY(1,1) NOT NULL,
                                         [SellOrderID] [bigint] NOT NULL,
                                         [BuyOrderID] [bigint] NOT NULL,
                                         [Volume] [decimal](18, 8) NOT NULL,
                                         [Rate] [decimal](18, 8) NOT NULL,
                                         [CurrencyType] [nvarchar](10) NOT NULL,
                                         [Amount] [decimal](18, 8) NOT NULL,
                                         [Buyer_Brokerage] [decimal](18, 8) NOT NULL,
                                         [Buyer_SGST] [decimal](18, 8) NOT NULL,
                                         [Buyer_CGST] [decimal](18, 8) NOT NULL,
                                         [Buyer_IGST] [decimal](18, 8) NOT NULL,
                                         [Buyer_TotalAmount] [decimal](18, 8) NOT NULL,
                                         [Seller_Brokerage] [decimal](18, 8) NOT NULL,
                                         [Seller_SGST] [decimal](18, 8) NOT NULL,
                                         [Seller_CGST] [decimal](18, 8) NOT NULL,
                                         [Seller_IGST] [decimal](18, 8) NOT NULL,
                                         [Seller_TotalAmount] [decimal](18, 8) NOT NULL,
                                         [OrderConfirmDate] [datetime] NOT NULL,
                                         [OrderStatus] [bit] NOT NULL,
                                         [ExecutionType] [nvarchar](10) NOT NULL,
                                         [MarketType] [nvarchar](10) NOT NULL,
                                         [SellerID] [bigint] NOT NULL,
                                         [BuyerID] [bigint] NOT NULL,
                                         CONSTRAINT [tbl_MatchedOrder_primaryKey] PRIMARY KEY NONCLUSTERED
                                             (
                                              [OrderID] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                         CONSTRAINT [UniqueMatches] UNIQUE NONCLUSTERED
                                             (
                                              [SellOrderID] ASC,
                                              [BuyOrderID] ASC
                                                 )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_MatchedOrder_Archive]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_MatchedOrder_Archive](
                                                 [OrderID] [bigint] NOT NULL,
                                                 [SellOrderID] [bigint] NOT NULL,
                                                 [BuyOrderID] [bigint] NOT NULL,
                                                 [Volume] [decimal](18, 8) NOT NULL,
                                                 [Rate] [decimal](18, 8) NOT NULL,
                                                 [CurrencyType] [nvarchar](10) NOT NULL,
                                                 [Amount] [decimal](18, 8) NOT NULL,
                                                 [Buyer_Brokerage] [decimal](18, 8) NOT NULL,
                                                 [Buyer_SGST] [decimal](18, 8) NOT NULL,
                                                 [Buyer_CGST] [decimal](18, 8) NOT NULL,
                                                 [Buyer_IGST] [decimal](18, 8) NOT NULL,
                                                 [Buyer_TotalAmount] [decimal](18, 8) NOT NULL,
                                                 [Seller_Brokerage] [decimal](18, 8) NOT NULL,
                                                 [Seller_SGST] [decimal](18, 8) NOT NULL,
                                                 [Seller_CGST] [decimal](18, 8) NOT NULL,
                                                 [Seller_IGST] [decimal](18, 8) NOT NULL,
                                                 [Seller_TotalAmount] [decimal](18, 8) NOT NULL,
                                                 [OrderConfirmDate] [datetime] NOT NULL,
                                                 [OrderStatus] [bit] NOT NULL,
                                                 [ExecutionType] [nvarchar](10) NOT NULL,
                                                 [MarketType] [nvarchar](10) NOT NULL,
                                                 [SellerID] [bigint] NOT NULL,
                                                 [BuyerID] [bigint] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_MetaTags]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_MetaTags](
                                     [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                     [TagName] [nvarchar](50) NOT NULL,
                                     [TagContent] [nvarchar](max) NOT NULL,
                                     CONSTRAINT [PK_tbl_MetaTags] PRIMARY KEY CLUSTERED
                                         (
                                          [ID] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Migrations]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Migrations](
                                       [ID] [bigint] NOT NULL,
                                       [Description] [nvarchar](100) NOT NULL,
                                       PRIMARY KEY CLUSTERED
                                           (
                                            [ID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Notifications]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Notifications](
                                          [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                          [CID] [bigint] NOT NULL,
                                          [MessageTitle] [nvarchar](100) NOT NULL,
                                          [MessageBody] [nvarchar](500) NOT NULL,
                                          [IsRead] [bit] NULL,
                                          [IsDeleted] [bit] NOT NULL,
                                          [AddedOn] [datetime] NOT NULL,
                                          [DeletedOn] [datetime] NULL,
                                          CONSTRAINT [PK_tbl_Notifications] PRIMARY KEY CLUSTERED
                                              (
                                               [Id] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_Assets]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_Assets](
                                       [AssetName] [nvarchar](10) NOT NULL,
                                       [IsFiat] [bit] NOT NULL,
                                       [MinLimit] [decimal](18, 8) NOT NULL,
                                       [MaxLimit] [decimal](18, 8) NOT NULL,
                                       [IsActive] [bit] NOT NULL,
                                       [IsDeleted] [bit] NOT NULL,
                                       CONSTRAINT [PK_tbl_P2P_Assets] PRIMARY KEY CLUSTERED
                                           (
                                            [AssetName] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_Offers]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_Offers](
                                       [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                       [Cid] [bigint] NOT NULL,
                                       [OrderDate] [datetime] NOT NULL,
                                       [Side] [nvarchar](10) NOT NULL,
                                       [Size] [decimal](18, 8) NOT NULL,
                                       [Price] [decimal](18, 8) NOT NULL,
                                       [StartPrice] [decimal](18, 8) NOT NULL,
                                       [FloatingPrice] [bit] NOT NULL,
                                       [FloatingPremium] [decimal](5, 2) NOT NULL,
                                       [FilledSize] [decimal](18, 8) NOT NULL,
                                       [BaseCurrency] [nvarchar](10) NOT NULL,
                                       [QuoteCurrency] [nvarchar](10) NOT NULL,
                                       [OrderLimit_LB] [decimal](18, 8) NOT NULL,
                                       [OrderLimit_UB] [decimal](18, 8) NOT NULL,
                                       [Fee] [decimal](18, 8) NOT NULL,
                                       [IsActive] [bit] NOT NULL,
                                       [Status] [bit] NOT NULL,
                                       [StatusText] [nvarchar](50) NULL,
                                       [CancelDate] [datetime] NULL,
                                       [FilledSizeInProcess] [decimal](18, 8) NOT NULL,
                                       [PaymentTimeLimit] [int] NOT NULL,
                                       [Remarks] [nvarchar](500) NULL,
                                       [AutoReply] [nvarchar](500) NULL,
                                       [CounterPartyKYC] [bit] NOT NULL,
                                       [RegisteredXDaysAgo] [int] NOT NULL,
                                       [LastUpdate] [datetime] NOT NULL,
                                       CONSTRAINT [PK_tbl_P2P_Orders] PRIMARY KEY CLUSTERED
                                           (
                                            [Id] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_Offers_PaymentMethods]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_Offers_PaymentMethods](
                                                      [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                                      [OfferId] [bigint] NULL,
                                                      [UserPaymentId] [bigint] NULL,
                                                      CONSTRAINT [PK_tbl_P2P_Offers_PaymentMethods] PRIMARY KEY CLUSTERED
                                                          (
                                                           [Id] ASC
                                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_Order_Chats]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_Order_Chats](
                                            [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                            [OrderId] [bigint] NOT NULL,
                                            [Timestamp] [datetime] NOT NULL,
                                            [Sender] [bigint] NOT NULL,
                                            [Receiver] [bigint] NOT NULL,
                                            [Message] [nvarchar](500) NOT NULL,
                                            [Attachment] [nvarchar](50) NULL,
                                            [AdminMessage] [bit] NOT NULL,
                                            CONSTRAINT [PK_tbl_P2P_Order_Chats] PRIMARY KEY CLUSTERED
                                                (
                                                 [Id] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_Orders]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_Orders](
                                       [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                       [OfferId] [bigint] NOT NULL,
                                       [TakerCid] [bigint] NOT NULL,
                                       [Size] [decimal](18, 8) NOT NULL,
                                       [StartDate] [datetime] NOT NULL,
                                       [ExpiryDate] [datetime] NOT NULL,
                                       [PaymentDate] [datetime] NULL,
                                       [ConfirmDate] [datetime] NULL,
                                       [HasTakerCancelled] [bit] NULL,
                                       [TakerCancelDate] [datetime] NULL,
                                       [TakerSide] [varchar](5) NULL,
                                       [OrderGuid] [varchar](36) NULL,
                                       [Price] [decimal](18, 8) NULL,
                                       [MakerPaymentMethodId] [bigint] NULL,
                                       [UserCancelComments] [nvarchar](200) NULL,
                                       [AppealDate] [datetime] NULL,
                                       [OrderStatus] [bit] NOT NULL,
                                       [BuyerFeedback] [bigint] NOT NULL,
                                       [SellerFeedback] [bigint] NOT NULL,
                                       [BuyerFeedbackText] [nvarchar](250) NULL,
                                       [SellerFeedbackText] [nvarchar](250) NULL,
                                       CONSTRAINT [PK_tbl_P2P_Orders_1] PRIMARY KEY CLUSTERED
                                           (
                                            [Id] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_Orders_Disputes]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_Orders_Disputes](
                                                [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                                [OrderId] [bigint] NOT NULL,
                                                [Appeal_Date] [datetime] NOT NULL,
                                                [Primary_Reason] [nvarchar](200) NOT NULL,
                                                [Description] [nvarchar](1000) NOT NULL,
                                                [AVProof] [nvarchar](100) NOT NULL,
                                                [MobileNo] [nvarchar](50) NOT NULL,
                                                [Status] [bit] NOT NULL,
                                                [ResolutionDate] [datetime] NULL,
                                                [ResolvedComments] [nvarchar](500) NULL,
                                                [ResolutionFavoring] [nvarchar](20) NULL,
                                                [Side] [nchar](10) NULL,
                                                [Appeal_By] [bigint] NOT NULL,
                                                [UserCancel_Date] [datetime] NULL,
                                                CONSTRAINT [PK_tbl_P2P_Disputes] PRIMARY KEY CLUSTERED
                                                    (
                                                     [Id] ASC
                                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_PaymentMethods]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_PaymentMethods](
                                               [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                               [Currency] [nvarchar](10) NULL,
                                               [MethodName] [nvarchar](50) NULL,
                                               [FieldsJSON] [nvarchar](500) NULL,
                                               [IsActive] [bit] NULL,
                                               [IsDeleted] [bit] NULL,
                                               CONSTRAINT [PK_tbl_P2P_PaymentMethods] PRIMARY KEY CLUSTERED
                                                   (
                                                    [Id] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_TradingPairs]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_TradingPairs](
                                             [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                             [BaseCurrency] [nvarchar](10) NOT NULL,
                                             [QuoteCurrency] [nvarchar](10) NOT NULL,
                                             [FullName] [nvarchar](50) NOT NULL,
                                             [Maker] [decimal](18, 8) NOT NULL,
                                             [Taker] [decimal](18, 8) NOT NULL,
                                             CONSTRAINT [PK_tbl_P2P_TradingPairs] PRIMARY KEY CLUSTERED
                                                 (
                                                  [Id] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_UserPaymentMethods]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_UserPaymentMethods](
                                                   [Id] [bigint] IDENTITY(1000,1) NOT NULL,
                                                   [PaymentId] [bigint] NULL,
                                                   [Cid] [bigint] NULL,
                                                   [PaymentJSON] [nvarchar](max) NULL,
                                                   [IsDeleted] [bit] NULL,
                                                   [Title] [nvarchar](50) NULL,
                                                   CONSTRAINT [PK_tbl_P2P_UserPaymentMethods] PRIMARY KEY CLUSTERED
                                                       (
                                                        [Id] ASC
                                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_P2P_UserProfiles]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_P2P_UserProfiles](
                                             [CID] [bigint] NOT NULL,
                                             [DisplayName] [nvarchar](50) NOT NULL,
                                             [OrderCompleteCount] [bigint] NULL,
                                             [Rating] [int] NULL,
                                             [ID] [int] IDENTITY(1,1) NOT NULL,
                                             [Trades] [bigint] NOT NULL,
                                             [CompletionRate] [decimal](18, 8) NOT NULL,
                                             [AvgReleaseTime] [decimal](18, 8) NOT NULL,
                                             [AvgPayTime] [decimal](18, 8) NOT NULL,
                                             [PositiveFeedback] [decimal](18, 8) NOT NULL,
                                             [Positive] [bigint] NOT NULL,
                                             [Negative] [bigint] NOT NULL,
                                             [Registered] [bigint] NOT NULL,
                                             [FirstTrade] [bigint] NOT NULL,
                                             [AllTrade] [bigint] NOT NULL,
                                             CONSTRAINT [PK_tbl_P2P_UserProfiles_1] PRIMARY KEY CLUSTERED
                                                 (
                                                  [ID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_PasswordResetTracker]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_PasswordResetTracker](
                                                 [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                 [CID] [bigint] NOT NULL,
                                                 [ChangedOn] [datetime] NOT NULL,
                                                 PRIMARY KEY CLUSTERED
                                                     (
                                                      [ID] ASC
                                                         )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Portfolio]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Portfolio](
                                      [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                      [CID] [bigint] NULL,
                                      [prevValue] [decimal](20, 10) NOT NULL,
                                      [currValue] [decimal](20, 10) NOT NULL,
                                      [timeStamp] [datetime] NULL,
                                      [percentChange] [decimal](5, 2) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_PriceAlerts]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_PriceAlerts](
                                        [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                        [Asset] [nvarchar](10) NOT NULL,
                                        [AlertPrice] [decimal](18, 8) NOT NULL,
                                        [RefPrice] [decimal](18, 8) NOT NULL,
                                        [AlertType] [nvarchar](20) NOT NULL,
                                        [AddedOn] [datetime] NOT NULL,
                                        PRIMARY KEY CLUSTERED
                                            (
                                             [Id] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_recurringPurchases]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_recurringPurchases](
                                               [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                               [CID] [bigint] NOT NULL,
                                               [CardID] [bigint] NOT NULL,
                                               [Period] [int] NOT NULL,
                                               [Currency] [varchar](10) NULL,
                                               [Amount] [decimal](18, 8) NOT NULL,
                                               [SubscribedOn] [datetime] NOT NULL,
                                               [LastPaymentID] [varchar](50) NULL,
                                               [LastPaymentDate] [datetime] NOT NULL,
                                               PRIMARY KEY CLUSTERED
                                                   (
                                                    [ID] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ReferralComissions]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_ReferralComissions](
                                               [id] [bigint] IDENTITY(1,1) NOT NULL,
                                               [Coin] [varchar](10) NULL,
                                               [Market] [varchar](10) NULL,
                                               [TradeID] [bigint] NULL,
                                               [FromCID] [bigint] NULL,
                                               [ToCID] [bigint] NULL,
                                               [ExecType] [nvarchar](4) NULL,
                                               [ExecDate] [datetime] NULL,
                                               [FromCID_Paid_Curr] [varchar](10) NULL,
                                               [Amount] [decimal](18, 8) NULL,
                                               [Tier] [int] NULL,
                                               [BTC_Value] [decimal](18, 8) NULL,
                                               [USD_Value] [decimal](18, 8) NULL,
                                               CONSTRAINT [PK_tbl_ReferralComissions] PRIMARY KEY CLUSTERED
                                                   (
                                                    [id] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_ResetLink]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_ResetLink](
                                      [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                      [CID] [bigint] NOT NULL,
                                      [UniqueCode] [nvarchar](50) NOT NULL,
                                      [LinkType] [nvarchar](50) NOT NULL,
                                      [RequestTime] [datetime] NOT NULL,
                                      [IsUsed] [bit] NOT NULL,
                                      CONSTRAINT [PK__tbl_Rese__3214EC270B44A812] PRIMARY KEY CLUSTERED
                                          (
                                           [ID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_RiskDetection]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_RiskDetection](
                                          [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                          [UserID] [bigint] NOT NULL,
                                          [OrderID] [bigint] NOT NULL,
                                          [CurrencyPair] [varchar](20) NULL,
                                          [RiskType] [nvarchar](50) NULL,
                                          [DetectionType] [nvarchar](10) NULL,
                                          [DetectedOn] [datetime] NULL,
                                          [BlockedOn] [datetime] NULL,
                                          PRIMARY KEY CLUSTERED
                                              (
                                               [Id] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_RiskTrigger]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_RiskTrigger](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [UserID] [bigint] NOT NULL,
                                        [Currency] [nvarchar](10) NOT NULL,
                                        [Address] [nvarchar](100) NOT NULL,
                                        [EventType] [nvarchar](10) NOT NULL,
                                        [Message] [nvarchar](500) NOT NULL,
                                        [RiskScore] [nvarchar](10) NOT NULL,
                                        [AlertDateUTC] [datetime] NOT NULL,
                                        [isProcessed] [bit] NOT NULL,
                                        [isPassed] [bit] NOT NULL,
                                        PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SellOrder]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SellOrder](
                                      [OrderID] [bigint] NOT NULL,
                                      [SellerID] [bigint] NOT NULL,
                                      [CurrencyType] [nvarchar](10) NOT NULL,
                                      [Volume] [decimal](18, 8) NOT NULL,
                                      [Rate] [decimal](18, 8) NOT NULL,
                                      [Amount] [decimal](18, 8) NOT NULL,
                                      [Brokerage] [decimal](18, 8) NOT NULL,
                                      [SGST] [decimal](18, 8) NOT NULL,
                                      [CGST] [decimal](18, 8) NOT NULL,
                                      [IGST] [decimal](18, 8) NOT NULL,
                                      [TotalAmount] [decimal](18, 8) NOT NULL,
                                      [OrderStatus] [bit] NOT NULL,
                                      [OrderPlacementDate] [datetime] NOT NULL,
                                      [OrderConfirmDate] [datetime] NULL,
                                      [isSameStateTax] [bit] NOT NULL,
                                      [PendingVolume] [decimal](18, 8) NOT NULL,
                                      [MarketType] [nvarchar](10) NOT NULL,
                                      [ServiceChargePerc] [decimal](18, 8) NOT NULL,
                                      [TimeInForce] [nvarchar](50) NOT NULL,
                                      [Stop] [decimal](18, 8) NOT NULL,
                                      [OrderCategory] [nvarchar](50) NOT NULL,
                                      [ClientOrderId] [nvarchar](50) NOT NULL,
                                      [isMarginOrder] [bit] NOT NULL,
                                      [LiquidatedPositionID] [bigint] NOT NULL,
                                      [Client] [nvarchar](50) NULL,
                                      [ClientIP] [nvarchar](50) NULL,
                                      [StatusCode] [int] NOT NULL,
                                      [StatusMessage] [nvarchar](100) NULL,
                                      [ExtraData] [nvarchar](max) NULL,
                                      CONSTRAINT [tbl_SellOrder_primaryKey] PRIMARY KEY NONCLUSTERED
                                          (
                                           [OrderID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SellOrder_Archive]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SellOrder_Archive](
                                              [OrderID] [bigint] NOT NULL,
                                              [SellerID] [bigint] NOT NULL,
                                              [CurrencyType] [nvarchar](10) NOT NULL,
                                              [Volume] [decimal](18, 8) NOT NULL,
                                              [Rate] [decimal](18, 8) NOT NULL,
                                              [Amount] [decimal](18, 8) NOT NULL,
                                              [Brokerage] [decimal](18, 8) NOT NULL,
                                              [SGST] [decimal](18, 8) NOT NULL,
                                              [CGST] [decimal](18, 8) NOT NULL,
                                              [IGST] [decimal](18, 8) NOT NULL,
                                              [TotalAmount] [decimal](18, 8) NOT NULL,
                                              [OrderStatus] [bit] NOT NULL,
                                              [OrderPlacementDate] [datetime] NOT NULL,
                                              [OrderConfirmDate] [datetime] NULL,
                                              [isSameStateTax] [bit] NOT NULL,
                                              [PendingVolume] [decimal](18, 8) NOT NULL,
                                              [MarketType] [nvarchar](10) NOT NULL,
                                              [ServiceChargePerc] [decimal](18, 8) NOT NULL,
                                              [TimeInForce] [nvarchar](50) NOT NULL,
                                              [Stop] [decimal](18, 8) NOT NULL,
                                              [OrderCategory] [nvarchar](50) NOT NULL,
                                              [ClientOrderId] [nvarchar](50) NOT NULL,
                                              [isMarginOrder] [bit] NOT NULL,
                                              [LiquidatedPositionID] [bigint] NOT NULL,
                                              [Client] [nvarchar](50) NULL,
                                              [ClientIP] [nvarchar](50) NULL,
                                              [StatusCode] [int] NOT NULL,
                                              [StatusMessage] [nvarchar](100) NULL,
                                              [ExtraData] [nvarchar](200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SessionLog]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SessionLog](
                                       [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                       [CID] [bigint] NOT NULL,
                                       [StartedOn] [datetime] NOT NULL,
                                       [IP] [nvarchar](200) NULL,
                                       [OS] [nvarchar](200) NULL,
                                       [Browser] [nvarchar](200) NULL,
                                       [Location] [nvarchar](200) NULL,
                                       CONSTRAINT [PK_tbl_SessionLog] PRIMARY KEY CLUSTERED
                                           (
                                            [ID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Settings]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Settings](
                                     [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                     [SettingName] [nvarchar](200) NULL,
                                     [SettingValue] [nvarchar](200) NULL,
                                     [IsHidden] [bit] NOT NULL,
                                     [Description] [nvarchar](max) NULL,
                                     [AliasName] [nvarchar](200) NULL,
                                     CONSTRAINT [tbl_Settings_primaryKey] PRIMARY KEY NONCLUSTERED
                                         (
                                          [ID] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                     UNIQUE NONCLUSTERED
                                         (
                                          [SettingName] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Sharepool_Rules]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Sharepool_Rules](
                                            [period] [int] NOT NULL,
                                            [payout_perc] [decimal](18, 2) NULL,
                                            [burn_perc] [decimal](18, 2) NULL,
                                            CONSTRAINT [PK_tbl_Sharepool_Rules] PRIMARY KEY CLUSTERED
                                                (
                                                 [period] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Sharepool_Stats]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Sharepool_Stats](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [Date] [date] NULL,
                                            [TermLength] [int] NULL,
                                            [InitialStake] [decimal](18, 0) NULL,
                                            [Burned] [decimal](18, 8) NULL,
                                            [PaidOut] [decimal](18, 8) NULL,
                                            [ROI] [decimal](18, 8) NULL,
                                            CONSTRAINT [PK_tbl_Sharepool_Stats] PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Sharepool_Subscriptions]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Sharepool_Subscriptions](
                                                    [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                    [CID] [bigint] NOT NULL,
                                                    [Days] [int] NULL,
                                                    [StartDate] [date] NULL,
                                                    [EndDate] [date] NULL,
                                                    [Amount] [decimal](18, 8) NULL,
                                                    [TotalPayout] [decimal](30, 20) NULL,
                                                    [AddedOn] [datetime] NULL,
                                                    CONSTRAINT [PK_tbl_Sharepool_Subscriptions] PRIMARY KEY CLUSTERED
                                                        (
                                                         [ID] ASC
                                                            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SMSTemplate]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SMSTemplate](
                                        [Name] [nvarchar](50) NOT NULL,
                                        [Content] [nvarchar](max) NULL,
                                        [UpdatedOn] [bigint] NULL,
                                        [Country] [nvarchar](3) NOT NULL,
                                        [Enabled] [bit] NOT NULL,
                                        PRIMARY KEY CLUSTERED
                                            (
                                             [Name] ASC,
                                             [Country] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SubAccounts_Managers]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SubAccounts_Managers](
                                                 [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                 [SubAccount_CID] [bigint] NOT NULL,
                                                 [Manager_CID] [bigint] NOT NULL,
                                                 [Manager_Email] [nvarchar](max) NULL,
                                                 [InvitedOn] [datetime] NOT NULL,
                                                 [AcceptedOn] [datetime] NULL,
                                                 [Status] [nvarchar](20) NULL,
                                                 PRIMARY KEY CLUSTERED
                                                     (
                                                      [ID] ASC
                                                         )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                                 UNIQUE NONCLUSTERED
                                                     (
                                                      [SubAccount_CID] ASC
                                                         )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SubAccounts_Managers_Delinked]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SubAccounts_Managers_Delinked](
                                                          [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                          [SubAccount_CID] [bigint] NOT NULL,
                                                          [Manager_CID] [bigint] NOT NULL,
                                                          [Manager_Email] [nvarchar](max) NULL,
                                                          [InvitedOn] [datetime] NOT NULL,
                                                          [AcceptedOn] [datetime] NOT NULL,
                                                          [RevokedOn] [datetime] NOT NULL,
                                                          [Status] [nvarchar](20) NULL,
                                                          PRIMARY KEY CLUSTERED
                                                              (
                                                               [ID] ASC
                                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SubAccountTransfers]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SubAccountTransfers](
                                                [ID] [bigint] IDENTITY(1000000,1) NOT NULL,
                                                [FromCID] [bigint] NOT NULL,
                                                [ToCID] [bigint] NOT NULL,
                                                [Asset] [varchar](10) NULL,
                                                [Amount] [decimal](18, 8) NOT NULL,
                                                [TransferredOn] [datetime] NOT NULL,
                                                PRIMARY KEY CLUSTERED
                                                    (
                                                     [ID] ASC
                                                        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_SyncTracker]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_SyncTracker](
                                        [blockchain] [nvarchar](20) NOT NULL,
                                        [height] [bigint] NULL,
                                        [lastsync] [datetime] NULL,
                                        [syncduration] [smallint] NULL,
                                        CONSTRAINT [PK_tbl_SyncTracker] PRIMARY KEY CLUSTERED
                                            (
                                             [blockchain] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TDM_Disenrollments]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TDM_Disenrollments](
                                               [id] [bigint] IDENTITY(1,1) NOT NULL,
                                               [Cid] [bigint] NULL,
                                               [EnrolledOn] [datetime] NULL,
                                               [DeletedOn] [datetime] NULL,
                                               CONSTRAINT [PK_tbl_TDM_Disenrollments] PRIMARY KEY CLUSTERED
                                                   (
                                                    [id] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TDM_Tiers]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TDM_Tiers](
                                      [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                      [Holding] [bigint] NOT NULL,
                                      [Discount] [decimal](18, 8) NOT NULL,
                                      [Tier] [nvarchar](50) NOT NULL,
                                      CONSTRAINT [PK_tbl_TDM_Tiers] PRIMARY KEY NONCLUSTERED
                                          (
                                           [ID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TDMEnrollments]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TDMEnrollments](
                                           [id] [bigint] IDENTITY(1,1) NOT NULL,
                                           [Cid] [bigint] NOT NULL,
                                           [EnrolledOn] [datetime] NOT NULL,
                                           CONSTRAINT [PK_tbl_TDMEnrollments] PRIMARY KEY NONCLUSTERED
                                               (
                                                [id] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Template]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Template](
                                     [Name] [nvarchar](200) NOT NULL,
                                     [PlaceHolderCSV] [nvarchar](max) NULL,
                                     [Subject] [nvarchar](1000) NULL,
                                     [Body] [nvarchar](max) NULL,
                                     [UpdatedOn] [bigint] NULL,
                                     [Country] [nvarchar](3) NOT NULL,
                                     [Enabled] [bit] NOT NULL,
                                     CONSTRAINT [PK_Composite] PRIMARY KEY CLUSTERED
                                         (
                                          [Name] ASC,
                                          [Country] ASC
                                             )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TokenCollection]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TokenCollection](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [CID] [bigint] NOT NULL,
                                            [Amount] [decimal](18, 8) NOT NULL,
                                            [Address] [nvarchar](250) NOT NULL,
                                            [TokenType] [nvarchar](10) NOT NULL,
                                            [ArrivalTime] [datetime] NOT NULL,
                                            [CollectionTime] [datetime] NULL,
                                            [isCollected] [bit] NOT NULL,
                                            [TxnHash] [nvarchar](250) NULL,
                                            [IsVerified] [bit] NOT NULL,
                                            [CollectionTime1] [datetime] NULL,
                                            [IsCollected1] [bit] NOT NULL,
                                            [TxnHash1] [nvarchar](250) NULL,
                                            [IsVerified1] [bit] NOT NULL,
                                            CONSTRAINT [PK__tbl_Toke__3214EC27861C89C6] PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Trade_ProfitLoss]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Trade_ProfitLoss](
                                             [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                             [CID] [bigint] NOT NULL,
                                             [Market] [nvarchar](10) NOT NULL,
                                             [Currency] [nvarchar](10) NOT NULL,
                                             [PLPerc] [decimal](18, 8) NOT NULL,
                                             [UpdatedOn] [datetime] NOT NULL,
                                             CONSTRAINT [tbl_Trade_ProfitLoss_primaryKey] PRIMARY KEY NONCLUSTERED
                                                 (
                                                  [ID] ASC
                                                     )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Trade_Volume_Stats]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Trade_Volume_Stats](
                                               [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                               [CID] [bigint] NOT NULL,
                                               [Currency] [varchar](10) NOT NULL,
                                               [RuleLimit] [decimal](38, 8) NOT NULL,
                                               [RuleLimitUSD] [decimal](38, 8) NOT NULL,
                                               [RuleDiscount] [decimal](5, 2) NOT NULL,
                                               [UserVolumeUSD] [decimal](38, 8) NOT NULL,
                                               [TradedVolume] [decimal](38, 8) NOT NULL,
                                               CONSTRAINT [PK__tbl_Trade_Volume_Stats] PRIMARY KEY CLUSTERED
                                                   (
                                                    [CID] ASC,
                                                    [Currency] ASC
                                                       )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TradeLimits]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TradeLimits](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [Currency] [varchar](10) NOT NULL,
                                        [Limit] [decimal](18, 8) NOT NULL,
                                        [KYCLevel] [int] NOT NULL,
                                        [RollingLimit] [int] NOT NULL,
                                        PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TradeSize]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TradeSize](
                                      [ID] [int] IDENTITY(1,1) NOT NULL,
                                      [CurrencyName] [nvarchar](10) NULL,
                                      [TradeSize] [decimal](18, 8) NOT NULL,
                                      PRIMARY KEY CLUSTERED
                                          (
                                           [ID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                      UNIQUE NONCLUSTERED
                                          (
                                           [CurrencyName] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TradingHours_Blacklist]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TradingHours_Blacklist](
                                                   [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                   [Pair] [nvarchar](20) NULL,
                                                   [Day] [date] NOT NULL,
                                                   [FromTime] [time](7) NOT NULL,
                                                   [ToTime] [time](7) NOT NULL,
                                                   PRIMARY KEY CLUSTERED
                                                       (
                                                        [ID] ASC
                                                           )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TrailOrder]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TrailOrder](
                                       [OrderID] [bigint] NOT NULL,
                                       [UserID] [bigint] NOT NULL,
                                       [CurrencyType] [nvarchar](10) NOT NULL,
                                       [MarketType] [nvarchar](10) NOT NULL,
                                       [Volume] [decimal](18, 8) NOT NULL,
                                       [TrailAmt] [decimal](18, 8) NOT NULL,
                                       [Stop] [decimal](18, 8) NOT NULL,
                                       [OrderPlacementDate] [datetime] NOT NULL,
                                       [IsTrailInPercentage] [bit] NOT NULL,
                                       [Side] [nvarchar](5) NOT NULL,
                                       [Limit] [decimal](18, 8) NOT NULL,
                                       CONSTRAINT [tbl_TrailOrder_primaryKey] PRIMARY KEY NONCLUSTERED
                                           (
                                            [OrderID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Translation]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Translation](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [LanguageID] [int] NOT NULL,
                                        [Type] [nvarchar](200) NULL,
                                        [Key] [nvarchar](200) NULL,
                                        [Value] [nvarchar](max) NOT NULL,
                                        CONSTRAINT [PK__tbl_Tran__3214EC2767B8E594] PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                        CONSTRAINT [UK_tbl_Translation] UNIQUE NONCLUSTERED
                                            (
                                             [LanguageID] ASC,
                                             [Key] ASC,
                                             [Type] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TravelRule]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TravelRule](
                                       [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                       [Timestamp] [datetime] NOT NULL,
                                       [OriginatorName] [nvarchar](100) NULL,
                                       [OriginatorNationalIdentification] [nvarchar](200) NULL,
                                       [OriginatorAccountNumber] [nvarchar](100) NULL,
                                       [OriginatorGeographicAddress] [nvarchar](1000) NULL,
                                       [OriginatorDateAndPlaceOfBirth] [nvarchar](1000) NULL,
                                       [BeneficiaryName] [nvarchar](100) NULL,
                                       [BeneficiaryAccountNumber] [nvarchar](100) NULL,
                                       [BeneficiaryGeographicAddress] [nvarchar](1000) NULL,
                                       [TravelRuleJson] [nvarchar](max) NOT NULL,
                                       [CID] [bigint] NOT NULL,
                                       [WithdrawalID] [bigint] NULL,
                                       [InfoSource] [nvarchar](100) NULL,
                                       CONSTRAINT [PK_tbl_TravelRule] PRIMARY KEY CLUSTERED
                                           (
                                            [ID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_TravelRuleDeposit]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_TravelRuleDeposit](
                                              [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                              [Timestamp] [datetime] NOT NULL,
                                              [OriginatorName] [nvarchar](100) NULL,
                                              [OriginatorNationalIdentification] [nvarchar](200) NULL,
                                              [OriginatorAccountNumber] [nvarchar](100) NULL,
                                              [OriginatorGeographicAddress] [nvarchar](1000) NULL,
                                              [OriginatorDateAndPlaceOfBirth] [nvarchar](1000) NULL,
                                              [BeneficiaryName] [nvarchar](100) NULL,
                                              [BeneficiaryAccountNumber] [nvarchar](100) NULL,
                                              [BeneficiaryGeographicAddress] [nvarchar](1000) NULL,
                                              [TravelRuleJson] [nvarchar](max) NOT NULL,
                                              [DepositID] [bigint] NOT NULL,
                                              [InfoSource] [nvarchar](100) NULL,
                                              [CID] [bigint] NOT NULL,
                                              [Amount] [decimal](18, 8) NOT NULL,
                                              CONSTRAINT [PK_tbl_TravelRuleDeposit] PRIMARY KEY CLUSTERED
                                                  (
                                                   [ID] ASC
                                                      )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_UnsafePasswords]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_UnsafePasswords](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [Password] [nvarchar](50) NOT NULL,
                                            [AddedOn] [datetime] NOT NULL,
                                            [IsDeleted] [bit] NOT NULL,
                                            [DeletedOn] [datetime] NULL,
                                            PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_USDPriceMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_USDPriceMaster](
                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                           [Currency] [nvarchar](10) NOT NULL,
                                           [Rate] [decimal](18, 8) NULL,
                                           [UpdationTime] [datetime] NOT NULL,
                                           [IterationCount] [bigint] NOT NULL,
                                           PRIMARY KEY CLUSTERED
                                               (
                                                [ID] ASC
                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_USDPrices]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_USDPrices](
                                      [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                      [Currency] [nvarchar](max) NOT NULL,
                                      [TS] [datetime] NOT NULL,
                                      [Price] [decimal](18, 8) NULL,
                                      PRIMARY KEY CLUSTERED
                                          (
                                           [ID] ASC
                                              )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_WebApiRateLimit]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_WebApiRateLimit](
                                            [Id] [bigint] IDENTITY(1,1) NOT NULL,
                                            [Rule] [nvarchar](100) NOT NULL,
                                            [Type] [nvarchar](50) NOT NULL,
                                            [PerSecond] [bigint] NOT NULL,
                                            [PerMinute] [bigint] NOT NULL,
                                            [PerHour] [bigint] NOT NULL,
                                            [PerDay] [bigint] NOT NULL,
                                            [PerWeek] [bigint] NOT NULL,
                                            [AddedOn] [datetime] NOT NULL,
                                            PRIMARY KEY CLUSTERED
                                                (
                                                 [Id] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
                                            CONSTRAINT [UC_WebApiRateLimit_Rule_Type] UNIQUE NONCLUSTERED
                                                (
                                                 [Rule] ASC,
                                                 [Type] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_withdraw_limits]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_withdraw_limits](
                                            [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                            [Currency] [nchar](10) NOT NULL,
                                            [Limit] [decimal](18, 8) NOT NULL,
                                            [LimitLevel] [int] NOT NULL,
                                            [RollingLimit] [int] NOT NULL,
                                            [LimitType] [nvarchar](20) NULL,
                                            [AutoWithdrawalLimit] [decimal](18, 8) NULL,
                                            [MinWithdrawalLimit] [decimal](18, 8) NOT NULL,
                                            [MaxWithdrawalLimit] [decimal](18, 8) NOT NULL,
                                            CONSTRAINT [PK_tbl_customer_withdraw_limits] PRIMARY KEY CLUSTERED
                                                (
                                                 [ID] ASC
                                                    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Withdrawal]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Withdrawal](
                                       [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                       [CID] [bigint] NOT NULL,
                                       [WithdrawalAmount] [decimal](18, 8) NOT NULL,
                                       [WithdrawalType] [nvarchar](10) NOT NULL,
                                       [WithdrawalAddress] [nvarchar](250) NOT NULL,
                                       [Particulars] [nvarchar](250) NULL,
                                       [WithdrawalReqDate] [datetime] NOT NULL,
                                       [WithdrawalConfirmDate] [datetime] NULL,
                                       [WithdrawalStatus] [nvarchar](10) NOT NULL,
                                       [TXNHash] [nvarchar](250) NULL,
                                       [EquivalentUsdAmt] [decimal](30, 2) NOT NULL,
                                       [IsConfirmedByUser] [bit] NOT NULL,
                                       [UserConfirmationID] [nvarchar](50) NOT NULL,
                                       [Withdrawal_Fee] [decimal](18, 8) NULL,
                                       [Memo] [nvarchar](200) NULL,
                                       [NotabeneTransactionId] [nvarchar](100) NULL,
                                       [WithdrawalDraftDate] [datetime] NULL,
                                       CONSTRAINT [PK_tbl_Withdrawal] PRIMARY KEY CLUSTERED
                                           (
                                            [ID] ASC
                                               )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Withdrawal_Address_Whitelisting_Disenrollments]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Withdrawal_Address_Whitelisting_Disenrollments](
                                                                           [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                                           [CID] [bigint] NOT NULL,
                                                                           [EnrolledOn] [datetime] NOT NULL,
                                                                           [DisenrolledOn] [datetime] NOT NULL,
                                                                           PRIMARY KEY CLUSTERED
                                                                               (
                                                                                [ID] ASC
                                                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[tbl_Withdrawal_Address_Whitelisting_Enrollments]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbl_Withdrawal_Address_Whitelisting_Enrollments](
                                                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                                                        [CID] [bigint] NOT NULL,
                                                                        [EnrolledOn] [datetime] NOT NULL,
                                                                        PRIMARY KEY CLUSTERED
                                                                            (
                                                                             [ID] ASC
                                                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TblMatrixMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TblMatrixMaster](
                                        [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                        [SponserID] [bigint] NOT NULL,
                                        [MemberID] [bigint] NOT NULL,
                                        [Level] [bigint] NOT NULL,
                                        PRIMARY KEY CLUSTERED
                                            (
                                             [ID] ASC
                                                )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Temp_Fiat_PG_Payments_Notification]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Temp_Fiat_PG_Payments_Notification](
                                                           [ID] [int] IDENTITY(1,1) NOT NULL,
                                                           [EntryOn] [datetime] NOT NULL,
                                                           [Response] [nvarchar](max) NULL,
                                                           PRIMARY KEY CLUSTERED
                                                               (
                                                                [ID] ASC
                                                                   )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TransactionStatus]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TransactionStatus](
                                          [ID] [bigint] IDENTITY(1,1) NOT NULL,
                                          [CID] [bigint] NULL,
                                          [Withdrawal_Status] [bit] NULL,
                                          [Deposit_Status] [bit] NULL,
                                          [Trade_Status] [bit] NULL,
                                          CONSTRAINT [PK__Transact__3214EC2712FB47A6] PRIMARY KEY CLUSTERED
                                              (
                                               [ID] ASC
                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tbl_BuyOrder_BuyerID_CurrencyType_MarketType_OrderStatus]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_BuyOrder_BuyerID_CurrencyType_MarketType_OrderStatus] ON [dbo].[tbl_BuyOrder]
    (
     [BuyerID] ASC,
     [CurrencyType] ASC,
     [MarketType] ASC,
     [OrderStatus] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tbl_BuyOrder_Archive_BuyerID_CurrencyType_MarketType_OrderStatus]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_BuyOrder_Archive_BuyerID_CurrencyType_MarketType_OrderStatus] ON [dbo].[tbl_BuyOrder_Archive]
    (
     [BuyerID] ASC,
     [CurrencyType] ASC,
     [MarketType] ASC,
     [OrderStatus] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [tbl_BuyOrder_Archive_orderid_buyerid]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [tbl_BuyOrder_Archive_orderid_buyerid] ON [dbo].[tbl_BuyOrder_Archive]
    (
     [OrderStatus] ASC
        )
    INCLUDE([OrderID],[BuyerID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_1_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_1_min_High] ON [dbo].[tbl_Chart_1_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_1_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_1_min_Low] ON [dbo].[tbl_Chart_1_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_10080_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_10080_min_High] ON [dbo].[tbl_Chart_10080_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_10080_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_10080_min_Low] ON [dbo].[tbl_Chart_10080_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_1440_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_1440_min_High] ON [dbo].[tbl_Chart_1440_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_1440_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_1440_min_Low] ON [dbo].[tbl_Chart_1440_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_15_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_15_min_High] ON [dbo].[tbl_Chart_15_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_15_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_15_min_Low] ON [dbo].[tbl_Chart_15_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_240_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_240_min_High] ON [dbo].[tbl_Chart_240_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_240_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_240_min_Low] ON [dbo].[tbl_Chart_240_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_43200_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_43200_min_High] ON [dbo].[tbl_Chart_43200_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_43200_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_43200_min_Low] ON [dbo].[tbl_Chart_43200_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_5_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_5_min_High] ON [dbo].[tbl_Chart_5_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_5_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_5_min_Low] ON [dbo].[tbl_Chart_5_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_60_min_High]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_60_min_High] ON [dbo].[tbl_Chart_60_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_tbl_Chart_60_min_Low]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_Chart_60_min_Low] ON [dbo].[tbl_Chart_60_min]
    (
     [Low] ASC
        )
    INCLUDE([Open],[Close]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_tbl_SellOrder_SellerID_CurrencyType_MarketType_OrderStatus]    Script Date: 1/10/2024 5:05:17 AM ******/
CREATE NONCLUSTERED INDEX [IX_tbl_SellOrder_SellerID_CurrencyType_MarketType_OrderStatus] ON [dbo].[tbl_SellOrder]
    (
     [SellerID] ASC,
     [CurrencyType] ASC,
     [MarketType] ASC,
     [OrderStatus] ASC
        )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AccountMaster] ADD  CONSTRAINT [DF__AccountMa__Statu__22401542]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[AdminLogin] ADD  DEFAULT ('{}') FOR [Configs]
GO
ALTER TABLE [dbo].[Contents] ADD  DEFAULT ((0)) FOR [Active]
GO
ALTER TABLE [dbo].[KYC_New] ADD  CONSTRAINT [DF_KYC_New_Blob_GUID]  DEFAULT (newid()) FOR [Blob_GUID]
GO
ALTER TABLE [dbo].[KYC_New] ADD  DEFAULT ((0)) FOR [ProfileOnS3]
GO
ALTER TABLE [dbo].[tbl_AddressMaster] ADD  CONSTRAINT [DF__tbl_Addre__Gener__66B53B20]  DEFAULT (getutcdate()) FOR [GenerationDate]
GO
ALTER TABLE [dbo].[tbl_AddressStorage] ADD  CONSTRAINT [DF_tbl_AddressStorage_GeneratedOn]  DEFAULT (getutcdate()) FOR [GeneratedOn]
GO
ALTER TABLE [dbo].[tbl_AddressStorage] ADD  CONSTRAINT [DF_tbl_AddressStorage_IsUsed]  DEFAULT ((0)) FOR [IsUsed]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_Key]  DEFAULT (lower(newid())) FOR [Key]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_Secret]  DEFAULT (lower(newid())) FOR [Secret]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_Type]  DEFAULT (N'ReadOnly') FOR [Type]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_GeneratedOn]  DEFAULT (getutcdate()) FOR [GeneratedOn]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_HitCount]  DEFAULT ((0)) FOR [HitCount]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] ADD  CONSTRAINT [DF_tbl_ApikeyManager_TrustedIPs]  DEFAULT (N'*') FOR [TrustedIPs]
GO
ALTER TABLE [dbo].[tbl_Bots] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[tbl_Burn_Addresses] ADD  CONSTRAINT [DF_tbl_Burn_Addresses_TotalBurned]  DEFAULT ((0)) FOR [TotalBurned]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF__tbl_BuyOr__Order__17C286CF]  DEFAULT ((0)) FOR [OrderStatus]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF__tbl_BuyOr__Order__18B6AB08]  DEFAULT (getutcdate()) FOR [OrderPlacementDate]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF_tbl_BuyOrder_isSameStateTax]  DEFAULT ((0)) FOR [isSameStateTax]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF__tbl_BuyOr__Pendi__603D47BB]  DEFAULT ((0)) FOR [PendingVolume]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF__tbl_BuyOr__Servi__72507171]  DEFAULT ((0)) FOR [ServiceChargePerc]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF_tbl_BuyOrder_IsNormalOrder]  DEFAULT (N'GTC') FOR [TimeInForce]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF_tbl_BuyOrder_Stop]  DEFAULT ((0)) FOR [Stop]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF_tbl_BuyOrder_OrderType]  DEFAULT (N'LIMIT') FOR [OrderCategory]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  CONSTRAINT [DF_tbl_BuyOrder_ClientOrderId]  DEFAULT (newid()) FOR [ClientOrderId]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  DEFAULT ((0)) FOR [isMarginOrder]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  DEFAULT ((-1)) FOR [LiquidatedPositionID]
GO
ALTER TABLE [dbo].[tbl_BuyOrder] ADD  DEFAULT ((0)) FOR [StatusCode]
GO
ALTER TABLE [dbo].[tbl_BuyOrder_Archive] ADD  DEFAULT ((0)) FOR [StatusCode]
GO
ALTER TABLE [dbo].[tbl_Chart_1_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_1_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_1_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_1_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_1_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__588280EB]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_1_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_10080_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_10080_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_10080_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_10080_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_10080_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__4FED3AEA]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_10080_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_1440_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_1440_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_1440_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_1440_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_1440_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__4663D0B0]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_1440_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_15_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_15_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_15_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_15_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_15_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__3BE6423D]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_15_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_240_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_240_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_240_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_240_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_240_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__3350FC3C]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_240_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_43200_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_43200_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_43200_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_43200_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_43200_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__2BAFDA74]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_43200_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_5_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_5_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_5_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_5_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_5_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__231A9473]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_5_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_Chart_60_min] ADD  DEFAULT ((0)) FOR [Open]
GO
ALTER TABLE [dbo].[tbl_Chart_60_min] ADD  DEFAULT ((0)) FOR [Close]
GO
ALTER TABLE [dbo].[tbl_Chart_60_min] ADD  DEFAULT ((0)) FOR [High]
GO
ALTER TABLE [dbo].[tbl_Chart_60_min] ADD  DEFAULT ((0)) FOR [Low]
GO
ALTER TABLE [dbo].[tbl_Chart_60_min] ADD  CONSTRAINT [DF__tbl_Chart___Time__1A854E72]  DEFAULT (getutcdate()) FOR [Time]
GO
ALTER TABLE [dbo].[tbl_Chart_60_min] ADD  DEFAULT ((0)) FOR [Volume]
GO
ALTER TABLE [dbo].[tbl_CoinAddRequest] ADD  DEFAULT (getdate()) FOR [RequestDate]
GO
ALTER TABLE [dbo].[tbl_CoinAddRequest] ADD  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[tbl_CopyTrade_Followers] ADD  CONSTRAINT [DF_tbl_CopyTrade_Followers_CalculatedOn]  DEFAULT (getutcdate()) FOR [FollowedOn]
GO
ALTER TABLE [dbo].[tbl_CopyTrade_Followers] ADD  DEFAULT ((10)) FOR [FollowRatio]
GO
ALTER TABLE [dbo].[tbl_CopyTrade_Orders] ADD  DEFAULT (getutcdate()) FOR [CopiedOn]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF__tbl_Curre__Addit__740F363E]  DEFAULT (getutcdate()) FOR [AdditionDate]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF__tbl_Curre__Statu__75035A77]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_ServiceCharge]  DEFAULT ((0)) FOR [ServiceCharge_Withdrawal]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_ServiceCharge_Buy]  DEFAULT ((0)) FOR [ServiceCharge_Buy]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_ServiceCharge_Sell]  DEFAULT ((0)) FOR [ServiceCharge_Sell]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF__tbl_Curre__ConfC__2DB429F3]  DEFAULT ((1)) FOR [ConfCount]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF__tbl_Curre__Contr__2F3D7CD3]  DEFAULT ('') FOR [ContractAddress]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_MinWithdrawalLimit]  DEFAULT ((0)) FOR [MinWithdrawalLimit]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_MaxWithdrawalLimit]  DEFAULT ((0)) FOR [MaxWithdrawalLimit]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_WalletType]  DEFAULT (N'BITCOIN') FOR [CoinWalletType]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_DecimalPrecision]  DEFAULT ((8)) FOR [DecimalPrecision]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_ServiceCharge_Withdrawal_InBTC]  DEFAULT ((0)) FOR [ServiceCharge_Withdrawal_InBTC]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_EnableDeposit]  DEFAULT ((0)) FOR [EnableDeposit]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_EnableTrade]  DEFAULT ((0)) FOR [EnableTrade]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_EnableWithdrawal]  DEFAULT ((0)) FOR [EnableWithdrawal]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_isMarket]  DEFAULT ((0)) FOR [IsMarket]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  CONSTRAINT [DF_tbl_CurrencyPrefrences_IsWithdrawFeeFixedFee]  DEFAULT ((0)) FOR [IsWithdrawFeeFixedFee]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((1)) FOR [EnableTrade_Buy]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((1)) FOR [EnableTrade_Sell]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((0)) FOR [InterestRate]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((0)) FOR [isColdStorage]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((0)) FOR [IsWalletPasswordEncrypted]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((0)) FOR [DTMemo]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((0)) FOR [MinDeposit]
GO
ALTER TABLE [dbo].[tbl_CurrencyPrefrences] ADD  DEFAULT ((0)) FOR [MinDepositForAlerts]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF_tbl_Customer_FirstName]  DEFAULT ('') FOR [FirstName]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Customer_DOB]  DEFAULT ('1947-08-15') FOR [DOB]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Customer_DOJ]  DEFAULT (getutcdate()) FOR [DOJ]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Custo__Status]  DEFAULT ('InActive') FOR [Status]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF_tbl_Customer_NationalityStatus]  DEFAULT ((0)) FOR [NationalityStatus]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Custo__isPro__7FEAFD3E]  DEFAULT ((0)) FOR [isProfileApproved]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF_tbl_Customer_isAddressApproved]  DEFAULT ((0)) FOR [isAddressApproved]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Custo__isPan__01D345B0]  DEFAULT ((0)) FOR [isPassportApproved]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Custo__isSig__7E02B4CC]  DEFAULT ((0)) FOR [isSignatureApproved]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF_tbl_Customer_GoogleAuthKey]  DEFAULT (newid()) FOR [GoogleAuthKey]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Custo__IsAut__36D11DD4]  DEFAULT ((0)) FOR [IsAuthenticationRequired]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  CONSTRAINT [DF__tbl_Custo__IsUse__1427CB6C]  DEFAULT ((0)) FOR [IsUserBlocked]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  DEFAULT ((0)) FOR [EnableCopyTrading]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  DEFAULT ((0)) FOR [EnableMarginTrading]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  DEFAULT ((0)) FOR [IsMobileVerified]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  DEFAULT ((1)) FOR [PriceChangeAlert]
GO
ALTER TABLE [dbo].[tbl_Customer] ADD  DEFAULT ((1)) FOR [CustomerCategoryID]
GO
ALTER TABLE [dbo].[tbl_Customer_FieldsMaster] ADD  CONSTRAINT [DF_SomeName]  DEFAULT ((1)) FOR [RequiredValidation]
GO
ALTER TABLE [dbo].[tbl_Customer_FieldsMaster] ADD  DEFAULT ('All') FOR [Country]
GO
ALTER TABLE [dbo].[tbl_Customer_FieldsMaster] ADD  DEFAULT ((0)) FOR [IsUnique]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF_tbl_Deposit_DepositAmount]  DEFAULT ((0)) FOR [DepositAmount]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF_tbl_Deposit_EquivalentUsdAmt]  DEFAULT ((0)) FOR [EquivalentUsdAmt]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF_tbl_Deposit_EquivalentBTC]  DEFAULT ((0)) FOR [EquivalentBTC]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF__tbl_Depos__Depos__77368703]  DEFAULT (getutcdate()) FOR [DepositReqDate]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF__tbl_Depos__Depos__782AAB3C]  DEFAULT ((0)) FOR [DepositStatus]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF__tbl_Depos__Curre__30E2A0C7]  DEFAULT ((0)) FOR [CurrentTxnCount]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  CONSTRAINT [DF_tbl_Deposit_isTokenDeposit]  DEFAULT ((0)) FOR [IsTokenDeposit]
GO
ALTER TABLE [dbo].[tbl_Deposit] ADD  DEFAULT ((1)) FOR [IsPassedTravelRule]
GO
ALTER TABLE [dbo].[tbl_deposit_limits] ADD  DEFAULT ((0.0)) FOR [MinDepositLimit]
GO
ALTER TABLE [dbo].[tbl_deposit_limits] ADD  DEFAULT ((0.0)) FOR [MaxDepositLimit]
GO
ALTER TABLE [dbo].[tbl_ExceptionLog] ADD  CONSTRAINT [DF__tbl_Excep__Occur__6DAA5301]  DEFAULT (getutcdate()) FOR [OccuredOn]
GO
ALTER TABLE [dbo].[tbl_FeeDiscount_VolumeBased] ADD  CONSTRAINT [DF_tbl_FeeDiscount_VolumeBased_limit]  DEFAULT ((0)) FOR [limit]
GO
ALTER TABLE [dbo].[tbl_FeeDiscount_VolumeBased] ADD  CONSTRAINT [DF_tbl_FeeDiscount_VolumeBased_discount]  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[tbl_FeeDiscount_VolumeBased] ADD  CONSTRAINT [DF_tbl_FeeDiscount_VolumeBased_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[tbl_FeeDiscount_VolumeBased] ADD  CONSTRAINT [DF_tbl_FeeDiscount_VolumeBased_AddedOn]  DEFAULT (getutcdate()) FOR [AddedOn]
GO
ALTER TABLE [dbo].[tbl_FeeDiscount_VolumeBased_VolumeBasedV2] ADD  DEFAULT ('BTC') FOR [TargetVolumeType]
GO
ALTER TABLE [dbo].[tbl_Fiat_CustomersAccounts] ADD  DEFAULT ((0)) FOR [isVerified]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests] ADD  CONSTRAINT [DF__tbl_Fiat___Withd__6672A7D1]  DEFAULT (newid()) FOR [WithdrawalID]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests] ADD  CONSTRAINT [DF__tbl_Fiat___Reque__6766CC0A]  DEFAULT (getutcdate()) FOR [RequestDate]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests] ADD  CONSTRAINT [DF__tbl_Fiat___Statu__694F147C]  DEFAULT ('Pending') FOR [Status]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests] ADD  CONSTRAINT [DF__tbl_Fiat___Withd__6E02B3B3]  DEFAULT ((0)) FOR [WithdrawalFee]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests] ADD  CONSTRAINT [DF__tbl_Fiat___IsCon__2885265A]  DEFAULT ((0)) FOR [IsConfirmedByUser]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  CONSTRAINT [DF__tbl_Fiat___Fee_I__430D36EC]  DEFAULT ((0)) FOR [Fee_In_Percent]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((1)) FOR [MinTxnAmount]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((100000)) FOR [MaxTxnAmount]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((0)) FOR [FixedFee]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((1)) FOR [MinFee]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((100000)) FOR [MaxFee]
GO
ALTER TABLE [dbo].[tbl_Fiat_Payment_Gateways] ADD  DEFAULT ((0)) FOR [EnableAutoWithdrawals]
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments] ADD  DEFAULT (newid()) FOR [Txn_GUID]
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments] ADD  DEFAULT ((0)) FOR [Amount]
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments] ADD  DEFAULT ((0)) FOR [Fee]
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments] ADD  DEFAULT ((0)) FOR [Total]
GO
ALTER TABLE [dbo].[tbl_InstaPair_Reserve] ADD  DEFAULT ((0)) FOR [Reserve]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [min_limit]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [max_limit]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [margin]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [miner_fee]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [commission]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [isActive]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [Reserve]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((0)) FOR [rate]
GO
ALTER TABLE [dbo].[tbl_InstaPairs] ADD  DEFAULT ((1)) FOR [AutoPriceUpdate]
GO
ALTER TABLE [dbo].[tbl_InstaTrade] ADD  DEFAULT ((0)) FOR [Commission]
GO
ALTER TABLE [dbo].[tbl_InstaTrade] ADD  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[tbl_InstaTrade] ADD  DEFAULT ((0)) FOR [AC]
GO
ALTER TABLE [dbo].[tbl_InstaTrade] ADD  DEFAULT ((0)) FOR [AC_Status]
GO
ALTER TABLE [dbo].[tbl_Invoice] ADD  DEFAULT ((0)) FOR [BeforeTaxAmount]
GO
ALTER TABLE [dbo].[tbl_Invoice] ADD  DEFAULT ((0)) FOR [TaxPercentage]
GO
ALTER TABLE [dbo].[tbl_Invoice] ADD  DEFAULT ((0)) FOR [TaxAmount]
GO
ALTER TABLE [dbo].[tbl_Invoice] ADD  DEFAULT ((0)) FOR [AfterTaxAmount]
GO
ALTER TABLE [dbo].[tbl_KYC_Corporate] ADD  DEFAULT ((0)) FOR [ProfileOnS3]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__Uniqu__63904C60]  DEFAULT (newid()) FOR [UniqueID]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__Login__657894D2]  DEFAULT ((0)) FOR [LoginStatus]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__IsUID__666CB90B]  DEFAULT ((0)) FOR [IsUIDVerified]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__LastT__6760DD44]  DEFAULT ('ETH') FOR [LastTrade]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__LastM__6855017D]  DEFAULT ('BTC') FOR [LastMarket]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__First__694925B6]  DEFAULT (getutcdate()) FOR [FirstUsed]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__LastU__6A3D49EF]  DEFAULT (getutcdate()) FOR [LastUsed]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__Valid__6B316E28]  DEFAULT (dateadd(month,(1),getdate())) FOR [ValidTill]
GO
ALTER TABLE [dbo].[tbl_LoginManager] ADD  CONSTRAINT [DF__tbl_Login__OTPVa__1F47D783]  DEFAULT (getutcdate()) FOR [OTPValidTillUTC]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF_tbl_Market_CurrentTradingPrice]  DEFAULT ((0)) FOR [CurrentTradingPrice]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF_tbl_Market_TotalVolume]  DEFAULT ((0)) FOR [TotalVolume]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF_tbl_Market_ChangeInPrice]  DEFAULT ((0)) FOR [ChangeInPrice]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF_tbl_Market_PreviousTradingPrice]  DEFAULT ((0)) FOR [PreviousTradingPrice]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF__tbl_Marke__Marke__7AC7EC1C]  DEFAULT ('BTC') FOR [MarketName]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF__tbl_Marke__Statu__2BCBE181]  DEFAULT ((0)) FOR [Status]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF_tbl_Market_TotalVolumeBaseCurrency]  DEFAULT ((0)) FOR [TotalVolumeBaseCurrency]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF__tbl_Marke__Last2__22754D07]  DEFAULT ((0)) FOR [Last24HrsLow]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  CONSTRAINT [DF__tbl_Marke__Last2__23697140]  DEFAULT ((0)) FOR [Last24HrsHigh]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [MinTradeAmount]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [MinTickSize]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [MinOrderValue]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [EnableMarginTrading]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [MaxSize]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [MaxOrderAmount]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [MaxMarketOrderSize]
GO
ALTER TABLE [dbo].[tbl_Market] ADD  DEFAULT ((0)) FOR [IsFixedFee]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] ADD  CONSTRAINT [DF__tbl_Match__Order__66EA454A]  DEFAULT (getutcdate()) FOR [OrderConfirmDate]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] ADD  CONSTRAINT [DF__tbl_Match__Order__67DE6983]  DEFAULT ((1)) FOR [OrderStatus]
GO
ALTER TABLE [dbo].[tbl_Notifications] ADD  CONSTRAINT [DF_tbl_Notifications_IsRead]  DEFAULT ((0)) FOR [IsRead]
GO
ALTER TABLE [dbo].[tbl_Notifications] ADD  CONSTRAINT [DF_tbl_Notifications_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[tbl_P2P_Assets] ADD  CONSTRAINT [DF_tbl_P2P_Assets_IsFiat]  DEFAULT ((0)) FOR [IsFiat]
GO
ALTER TABLE [dbo].[tbl_P2P_Assets] ADD  CONSTRAINT [DF_tbl_P2P_Assets_MinLimit]  DEFAULT ((0)) FOR [MinLimit]
GO
ALTER TABLE [dbo].[tbl_P2P_Assets] ADD  CONSTRAINT [DF_tbl_P2P_Assets_MaxLimit]  DEFAULT ((0)) FOR [MaxLimit]
GO
ALTER TABLE [dbo].[tbl_P2P_Assets] ADD  CONSTRAINT [DF_tbl_P2P_Assets_IsActive]  DEFAULT ((0)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tbl_P2P_Assets] ADD  CONSTRAINT [DF_tbl_P2P_Assets_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_OrderDate]  DEFAULT (getutcdate()) FOR [OrderDate]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_CustomerPrice]  DEFAULT ((0)) FOR [StartPrice]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_FixedPrice]  DEFAULT ((0)) FOR [FloatingPrice]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_FloatingPremium]  DEFAULT ((0)) FOR [FloatingPremium]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_IsActive]  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_FilledSizeInProcess]  DEFAULT ((0)) FOR [FilledSizeInProcess]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_PaymentTimeLimit]  DEFAULT ((15)) FOR [PaymentTimeLimit]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_CounterPartyKYC]  DEFAULT ((1)) FOR [CounterPartyKYC]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_RegisteredXDaysAgo]  DEFAULT ((0)) FOR [RegisteredXDaysAgo]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] ADD  CONSTRAINT [DF_tbl_P2P_Offers_LastIUpdateDate]  DEFAULT (getutcdate()) FOR [LastUpdate]
GO
ALTER TABLE [dbo].[tbl_P2P_Order_Chats] ADD  CONSTRAINT [DF_tbl_P2P_Order_Chats_isAdmin]  DEFAULT ((0)) FOR [AdminMessage]
GO
ALTER TABLE [dbo].[tbl_P2P_Orders] ADD  CONSTRAINT [DF_tbl_P2P_Orders_OrderStatus]  DEFAULT ((0)) FOR [OrderStatus]
GO
ALTER TABLE [dbo].[tbl_P2P_Orders] ADD  DEFAULT ((0)) FOR [BuyerFeedback]
GO
ALTER TABLE [dbo].[tbl_P2P_Orders] ADD  DEFAULT ((0)) FOR [SellerFeedback]
GO
ALTER TABLE [dbo].[tbl_P2P_Orders_Disputes] ADD  CONSTRAINT [DF_tbl_P2P_Orders_Disputes_Appeal_By]  DEFAULT ((0)) FOR [Appeal_By]
GO
ALTER TABLE [dbo].[tbl_P2P_UserPaymentMethods] ADD  CONSTRAINT [DF_tbl_P2P_UserPaymentMethods_IsDeleted]  DEFAULT ((0)) FOR [IsDeleted]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [Trades]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [CompletionRate]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [AvgReleaseTime]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [AvgPayTime]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [PositiveFeedback]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [Positive]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [Negative]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [Registered]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [FirstTrade]
GO
ALTER TABLE [dbo].[tbl_P2P_UserProfiles] ADD  DEFAULT ((0)) FOR [AllTrade]
GO
ALTER TABLE [dbo].[tbl_PasswordResetTracker] ADD  DEFAULT (getutcdate()) FOR [ChangedOn]
GO
ALTER TABLE [dbo].[tbl_ReferralComissions] ADD  DEFAULT ((1)) FOR [Tier]
GO
ALTER TABLE [dbo].[tbl_ReferralComissions] ADD  DEFAULT ((0.0)) FOR [BTC_Value]
GO
ALTER TABLE [dbo].[tbl_ReferralComissions] ADD  DEFAULT ((0.0)) FOR [USD_Value]
GO
ALTER TABLE [dbo].[tbl_ResetLink] ADD  CONSTRAINT [DF_tbl_ResetLink_UniqueCode]  DEFAULT (newid()) FOR [UniqueCode]
GO
ALTER TABLE [dbo].[tbl_ResetLink] ADD  CONSTRAINT [DF__tbl_Reset__Reque__733BD8ED]  DEFAULT (getutcdate()) FOR [RequestTime]
GO
ALTER TABLE [dbo].[tbl_ResetLink] ADD  CONSTRAINT [DF__tbl_Reset__IsUse__742FFD26]  DEFAULT ((0)) FOR [IsUsed]
GO
ALTER TABLE [dbo].[tbl_RiskDetection] ADD  DEFAULT (getutcdate()) FOR [DetectedOn]
GO
ALTER TABLE [dbo].[tbl_RiskDetection] ADD  DEFAULT (getutcdate()) FOR [BlockedOn]
GO
ALTER TABLE [dbo].[tbl_RiskTrigger] ADD  DEFAULT (getutcdate()) FOR [AlertDateUTC]
GO
ALTER TABLE [dbo].[tbl_RiskTrigger] ADD  DEFAULT ((0)) FOR [isProcessed]
GO
ALTER TABLE [dbo].[tbl_RiskTrigger] ADD  DEFAULT ((0)) FOR [isPassed]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF__tbl_SellO__Order__0F2D40CE]  DEFAULT ((0)) FOR [OrderStatus]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF__tbl_SellO__Order__10216507]  DEFAULT (getutcdate()) FOR [OrderPlacementDate]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF_tbl_SellOrder_isSameStateTax]  DEFAULT ((0)) FOR [isSameStateTax]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF__tbl_SellO__Pendi__61316BF4]  DEFAULT ((0)) FOR [PendingVolume]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF__tbl_SellO__Servi__734495AA]  DEFAULT ((0)) FOR [ServiceChargePerc]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF_tbl_SellOrder_TimeInForce]  DEFAULT (N'GTC') FOR [TimeInForce]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF_tbl_SellOrder_Stop]  DEFAULT ((0)) FOR [Stop]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF_tbl_SellOrder_OrderType]  DEFAULT (N'LIMIT') FOR [OrderCategory]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  CONSTRAINT [DF_tbl_SellOrder_ClientOrderId]  DEFAULT (newid()) FOR [ClientOrderId]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  DEFAULT ((0)) FOR [isMarginOrder]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  DEFAULT ((-1)) FOR [LiquidatedPositionID]
GO
ALTER TABLE [dbo].[tbl_SellOrder] ADD  DEFAULT ((0)) FOR [StatusCode]
GO
ALTER TABLE [dbo].[tbl_SellOrder_Archive] ADD  DEFAULT ((0)) FOR [StatusCode]
GO
ALTER TABLE [dbo].[tbl_SessionLog] ADD  CONSTRAINT [DF_tbl_SessionLog_StartedOn]  DEFAULT (getutcdate()) FOR [StartedOn]
GO
ALTER TABLE [dbo].[tbl_SessionLog] ADD  CONSTRAINT [DF_tbl_SessionLog_IP]  DEFAULT (N'n/a') FOR [IP]
GO
ALTER TABLE [dbo].[tbl_SessionLog] ADD  CONSTRAINT [DF_tbl_SessionLog_OS]  DEFAULT (N'n/a') FOR [OS]
GO
ALTER TABLE [dbo].[tbl_SessionLog] ADD  CONSTRAINT [DF_tbl_SessionLog_Browser]  DEFAULT (N'n/a') FOR [Browser]
GO
ALTER TABLE [dbo].[tbl_SessionLog] ADD  CONSTRAINT [DF_tbl_SessionLog_Location]  DEFAULT (N'n/a') FOR [Location]
GO
ALTER TABLE [dbo].[tbl_Settings] ADD  CONSTRAINT [DF_tbl_Settings_IsHidden]  DEFAULT ((0)) FOR [IsHidden]
GO
ALTER TABLE [dbo].[tbl_Sharepool_Subscriptions] ADD  CONSTRAINT [DF_tbl_Sharepool_Subscriptions_TotalPayout]  DEFAULT ((0)) FOR [TotalPayout]
GO
ALTER TABLE [dbo].[tbl_SMSTemplate] ADD  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[tbl_Template] ADD  DEFAULT ((1)) FOR [Enabled]
GO
ALTER TABLE [dbo].[tbl_TokenCollection] ADD  CONSTRAINT [DF__tbl_Token__Arriv__48D067DC]  DEFAULT (getutcdate()) FOR [ArrivalTime]
GO
ALTER TABLE [dbo].[tbl_TokenCollection] ADD  CONSTRAINT [DF__tbl_Token__isCol__49C48C15]  DEFAULT ((0)) FOR [isCollected]
GO
ALTER TABLE [dbo].[tbl_TokenCollection] ADD  DEFAULT ((0)) FOR [IsVerified]
GO
ALTER TABLE [dbo].[tbl_TokenCollection] ADD  DEFAULT ((0)) FOR [IsCollected1]
GO
ALTER TABLE [dbo].[tbl_TokenCollection] ADD  DEFAULT ((0)) FOR [IsVerified1]
GO
ALTER TABLE [dbo].[tbl_Trade_ProfitLoss] ADD  CONSTRAINT [DF_tbl_Trade_ProfitLoss_ISClosed]  DEFAULT (getutcdate()) FOR [UpdatedOn]
GO
ALTER TABLE [dbo].[tbl_Trade_Volume_Stats] ADD  DEFAULT ((0)) FOR [RuleLimit]
GO
ALTER TABLE [dbo].[tbl_Trade_Volume_Stats] ADD  DEFAULT ((0)) FOR [RuleLimitUSD]
GO
ALTER TABLE [dbo].[tbl_Trade_Volume_Stats] ADD  DEFAULT ((0)) FOR [RuleDiscount]
GO
ALTER TABLE [dbo].[tbl_Trade_Volume_Stats] ADD  DEFAULT ((0)) FOR [UserVolumeUSD]
GO
ALTER TABLE [dbo].[tbl_Trade_Volume_Stats] ADD  DEFAULT ((0)) FOR [TradedVolume]
GO
ALTER TABLE [dbo].[tbl_TrailOrder] ADD  DEFAULT ((0)) FOR [Stop]
GO
ALTER TABLE [dbo].[tbl_TrailOrder] ADD  DEFAULT (getutcdate()) FOR [OrderPlacementDate]
GO
ALTER TABLE [dbo].[tbl_TrailOrder] ADD  DEFAULT ((0)) FOR [IsTrailInPercentage]
GO
ALTER TABLE [dbo].[tbl_TravelRule] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_TravelRule] ADD  DEFAULT ((0)) FOR [CID]
GO
ALTER TABLE [dbo].[tbl_TravelRuleDeposit] ADD  DEFAULT (getdate()) FOR [Timestamp]
GO
ALTER TABLE [dbo].[tbl_TravelRuleDeposit] ADD  DEFAULT ((0)) FOR [CID]
GO
ALTER TABLE [dbo].[tbl_TravelRuleDeposit] ADD  DEFAULT ((0.0)) FOR [Amount]
GO
ALTER TABLE [dbo].[tbl_USDPriceMaster] ADD  DEFAULT ((0)) FOR [Rate]
GO
ALTER TABLE [dbo].[tbl_USDPriceMaster] ADD  DEFAULT (getutcdate()) FOR [UpdationTime]
GO
ALTER TABLE [dbo].[tbl_USDPriceMaster] ADD  DEFAULT ((0)) FOR [IterationCount]
GO
ALTER TABLE [dbo].[tbl_withdraw_limits] ADD  DEFAULT ((0.0)) FOR [MinWithdrawalLimit]
GO
ALTER TABLE [dbo].[tbl_withdraw_limits] ADD  DEFAULT ((0.0)) FOR [MaxWithdrawalLimit]
GO
ALTER TABLE [dbo].[tbl_Withdrawal] ADD  CONSTRAINT [DF__tbl_Withd__Withd__32767D0B]  DEFAULT (getutcdate()) FOR [WithdrawalReqDate]
GO
ALTER TABLE [dbo].[tbl_Withdrawal] ADD  CONSTRAINT [DF__tbl_Withd__Withd__50FB042B]  DEFAULT ('Pending') FOR [WithdrawalStatus]
GO
ALTER TABLE [dbo].[tbl_Withdrawal] ADD  CONSTRAINT [DF_tbl_Withdrawal_EquivalentUsdAmt]  DEFAULT ((0)) FOR [EquivalentUsdAmt]
GO
ALTER TABLE [dbo].[tbl_Withdrawal] ADD  CONSTRAINT [DF_tbl_Withdrawal_IsConfirmedByUser]  DEFAULT ((0)) FOR [IsConfirmedByUser]
GO
ALTER TABLE [dbo].[tbl_Withdrawal] ADD  CONSTRAINT [DF_tbl_Withdrawal_UserConfirmationID]  DEFAULT (N'NA') FOR [UserConfirmationID]
GO
ALTER TABLE [dbo].[tbl_Withdrawal] ADD  DEFAULT ((0)) FOR [Withdrawal_Fee]
GO
ALTER TABLE [dbo].[KYC_FilterFieldsValues]  WITH CHECK ADD  CONSTRAINT [FK_KYC_FilterFieldsValues_KYC_FilterFields] FOREIGN KEY([FieldId])
    REFERENCES [dbo].[KYC_FilterFields] ([Id])
GO
ALTER TABLE [dbo].[KYC_FilterFieldsValues] CHECK CONSTRAINT [FK_KYC_FilterFieldsValues_KYC_FilterFields]
GO
ALTER TABLE [dbo].[tbl_AddressMaster]  WITH CHECK ADD  CONSTRAINT [FK_tbl_AddressMaster_tbl_Customer] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_AddressMaster] CHECK CONSTRAINT [FK_tbl_AddressMaster_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Admin_userPageMapping]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Admin_userPageMapping_CID] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_Admin_userPageMapping] CHECK CONSTRAINT [FK_tbl_Admin_userPageMapping_CID]
GO
ALTER TABLE [dbo].[tbl_Admin_userPageMapping]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Admin_userPageMapping_PageID] FOREIGN KEY([PageID])
    REFERENCES [dbo].[tbl_Admin_pages] ([ID])
GO
ALTER TABLE [dbo].[tbl_Admin_userPageMapping] CHECK CONSTRAINT [FK_tbl_Admin_userPageMapping_PageID]
GO
ALTER TABLE [dbo].[tbl_ApikeyManager]  WITH CHECK ADD  CONSTRAINT [FK_tbl_ApikeyManager_tbl_Customer] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_ApikeyManager] CHECK CONSTRAINT [FK_tbl_ApikeyManager_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Customer]  WITH CHECK ADD  CONSTRAINT [FK_CustomerCategoryID] FOREIGN KEY([CustomerCategoryID])
    REFERENCES [dbo].[tbl_CustomerCategory] ([ID])
    ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[tbl_Customer] CHECK CONSTRAINT [FK_CustomerCategoryID]
GO
ALTER TABLE [dbo].[tbl_Customers_FieldValues]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Customers_FieldValues_tbl_Customer] FOREIGN KEY([cid])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_Customers_FieldValues] CHECK CONSTRAINT [FK_tbl_Customers_FieldValues_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Customers_FieldValues]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Customers_FieldValues_tbl_Customer_FieldsMaster] FOREIGN KEY([fieldid])
    REFERENCES [dbo].[tbl_Customer_FieldsMaster] ([id])
GO
ALTER TABLE [dbo].[tbl_Customers_FieldValues] CHECK CONSTRAINT [FK_tbl_Customers_FieldValues_tbl_Customer_FieldsMaster]
GO
ALTER TABLE [dbo].[tbl_Devices]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Devices_CID] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_Devices] CHECK CONSTRAINT [FK_tbl_Devices_CID]
GO
ALTER TABLE [dbo].[tbl_Fiat_CustomersAccounts]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Fiat_CustomersAccounts_tbl_Customer] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_Fiat_CustomersAccounts] CHECK CONSTRAINT [FK_tbl_Fiat_CustomersAccounts_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Deposit_Requests]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Fiat_Manual_Deposit_Requests_tbl_Customer] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Deposit_Requests] CHECK CONSTRAINT [FK_tbl_Fiat_Manual_Deposit_Requests_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Deposit_Requests]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Fiat_Manual_Deposit_Requests_tbl_Fiat_BanksList] FOREIGN KEY([BankID])
    REFERENCES [dbo].[tbl_Fiat_BanksList] ([ID])
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Deposit_Requests] CHECK CONSTRAINT [FK_tbl_Fiat_Manual_Deposit_Requests_tbl_Fiat_BanksList]
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments]  WITH CHECK ADD  CONSTRAINT [FK__tbl_Fiat___PG_ID__48C61042] FOREIGN KEY([PG_ID])
    REFERENCES [dbo].[tbl_Fiat_Payment_Gateways] ([ID])
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments] CHECK CONSTRAINT [FK__tbl_Fiat___PG_ID__48C61042]
GO
ALTER TABLE [dbo].[tbl_Fiat_PG_Payments]  WITH CHECK ADD FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_InstaTrade]  WITH CHECK ADD FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_Invoice]  WITH CHECK ADD FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_KYC_Corporate]  WITH CHECK ADD  CONSTRAINT [FK_tbl_KYC_corporate_CID] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_KYC_Corporate] CHECK CONSTRAINT [FK_tbl_KYC_corporate_CID]
GO
ALTER TABLE [dbo].[tbl_Market]  WITH NOCHECK ADD  CONSTRAINT [FK_tbl_Market_tbl_CurrencyPrefrences] FOREIGN KEY([CoinName])
    REFERENCES [dbo].[tbl_CurrencyPrefrences] ([CurrencyShortName])
GO
ALTER TABLE [dbo].[tbl_Market] CHECK CONSTRAINT [FK_tbl_Market_tbl_CurrencyPrefrences]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder]  WITH CHECK ADD  CONSTRAINT [FK_tbl_MatchedOrder_tbl_BuyOrder] FOREIGN KEY([BuyOrderID])
    REFERENCES [dbo].[tbl_BuyOrder] ([OrderID])
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] CHECK CONSTRAINT [FK_tbl_MatchedOrder_tbl_BuyOrder]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder]  WITH CHECK ADD  CONSTRAINT [FK_tbl_MatchedOrder_tbl_SellOrder] FOREIGN KEY([SellOrderID])
    REFERENCES [dbo].[tbl_SellOrder] ([OrderID])
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] CHECK CONSTRAINT [FK_tbl_MatchedOrder_tbl_SellOrder]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers]  WITH CHECK ADD  CONSTRAINT [FK_tbl_P2P_Offers_tbl_Customer] FOREIGN KEY([Cid])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] CHECK CONSTRAINT [FK_tbl_P2P_Offers_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers]  WITH CHECK ADD  CONSTRAINT [FK_tbl_P2P_Offers_tbl_P2P_Assets_BaseCurrency] FOREIGN KEY([BaseCurrency])
    REFERENCES [dbo].[tbl_P2P_Assets] ([AssetName])
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] CHECK CONSTRAINT [FK_tbl_P2P_Offers_tbl_P2P_Assets_BaseCurrency]
GO
ALTER TABLE [dbo].[tbl_P2P_Offers]  WITH CHECK ADD  CONSTRAINT [FK_tbl_P2P_Offers_tbl_P2P_Assets_QuoteCurrency] FOREIGN KEY([QuoteCurrency])
    REFERENCES [dbo].[tbl_P2P_Assets] ([AssetName])
GO
ALTER TABLE [dbo].[tbl_P2P_Offers] CHECK CONSTRAINT [FK_tbl_P2P_Offers_tbl_P2P_Assets_QuoteCurrency]
GO
ALTER TABLE [dbo].[tbl_PasswordResetTracker]  WITH CHECK ADD FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_PriceAlerts]  WITH CHECK ADD  CONSTRAINT [FK_tbl_PriceAlerts_Ticker] FOREIGN KEY([Asset])
    REFERENCES [dbo].[tbl_CurrencyPrefrences] ([CurrencyShortName])
GO
ALTER TABLE [dbo].[tbl_PriceAlerts] CHECK CONSTRAINT [FK_tbl_PriceAlerts_Ticker]
GO
ALTER TABLE [dbo].[tbl_ResetLink]  WITH CHECK ADD  CONSTRAINT [FK_tbl_ResetLink_tbl_Customer] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_ResetLink] CHECK CONSTRAINT [FK_tbl_ResetLink_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Sharepool_Subscriptions]  WITH CHECK ADD  CONSTRAINT [FK_tbl_Sharepool_Subscriptions_tbl_Sharepool_Rules] FOREIGN KEY([Days])
    REFERENCES [dbo].[tbl_Sharepool_Rules] ([period])
GO
ALTER TABLE [dbo].[tbl_Sharepool_Subscriptions] CHECK CONSTRAINT [FK_tbl_Sharepool_Subscriptions_tbl_Sharepool_Rules]
GO
ALTER TABLE [dbo].[tbl_TokenCollection]  WITH CHECK ADD  CONSTRAINT [FK_tbl_TokenCollection_tbl_Customer] FOREIGN KEY([CID])
    REFERENCES [dbo].[tbl_Customer] ([CID])
GO
ALTER TABLE [dbo].[tbl_TokenCollection] CHECK CONSTRAINT [FK_tbl_TokenCollection_tbl_Customer]
GO
ALTER TABLE [dbo].[tbl_Translation]  WITH CHECK ADD  CONSTRAINT [FK__tbl_Trans__Langu__33E52993] FOREIGN KEY([LanguageID])
    REFERENCES [dbo].[tbl_Language] ([ID])
GO
ALTER TABLE [dbo].[tbl_Translation] CHECK CONSTRAINT [FK__tbl_Trans__Langu__33E52993]
GO
ALTER TABLE [dbo].[AccountMaster]  WITH CHECK ADD  CONSTRAINT [CheckForNegativeOrZero] CHECK  (([Credit]>=(0) AND [Debit]>=(0)))
GO
ALTER TABLE [dbo].[AccountMaster] CHECK CONSTRAINT [CheckForNegativeOrZero]
GO
ALTER TABLE [dbo].[tbl_BuyOrder]  WITH CHECK ADD  CONSTRAINT [CheckGreaterThanZeroTotalBuyAndPending] CHECK  (([Totalamount]>(0) AND [pendingvolume]>=(0)))
GO
ALTER TABLE [dbo].[tbl_BuyOrder] CHECK CONSTRAINT [CheckGreaterThanZeroTotalBuyAndPending]
GO
ALTER TABLE [dbo].[tbl_BuyOrder]  WITH CHECK ADD  CONSTRAINT [CheckNegativeZeroBuyRate] CHECK  (([Rate]>(0)))
GO
ALTER TABLE [dbo].[tbl_BuyOrder] CHECK CONSTRAINT [CheckNegativeZeroBuyRate]
GO
ALTER TABLE [dbo].[tbl_BuyOrder]  WITH CHECK ADD  CONSTRAINT [CheckNegativeZeroBuyVolume] CHECK  (([Volume]>(0)))
GO
ALTER TABLE [dbo].[tbl_BuyOrder] CHECK CONSTRAINT [CheckNegativeZeroBuyVolume]
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests]  WITH CHECK ADD  CONSTRAINT [CK__tbl_Fiat___Reque__685AF043] CHECK  (([RequestAmount]>(0)))
GO
ALTER TABLE [dbo].[tbl_Fiat_Manual_Withdrawal_Requests] CHECK CONSTRAINT [CK__tbl_Fiat___Reque__685AF043]
GO
ALTER TABLE [dbo].[tbl_Market]  WITH CHECK ADD  CONSTRAINT [CheckNegativeCurrentTradingPrice] CHECK  (([CurrentTradingPrice]>=(0)))
GO
ALTER TABLE [dbo].[tbl_Market] CHECK CONSTRAINT [CheckNegativeCurrentTradingPrice]
GO
ALTER TABLE [dbo].[tbl_Market]  WITH CHECK ADD  CONSTRAINT [CheckNegativePreviousTradingPrice] CHECK  (([PreviousTradingPrice]>=(0)))
GO
ALTER TABLE [dbo].[tbl_Market] CHECK CONSTRAINT [CheckNegativePreviousTradingPrice]
GO
ALTER TABLE [dbo].[tbl_Market]  WITH CHECK ADD  CONSTRAINT [CheckNegativeTotalVolume] CHECK  (([TotalVolume]>=(0)))
GO
ALTER TABLE [dbo].[tbl_Market] CHECK CONSTRAINT [CheckNegativeTotalVolume]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder]  WITH CHECK ADD  CONSTRAINT [CheckNegativeZeroAmount] CHECK  (([Buyer_TotalAmount]>(0) AND [Seller_TotalAmount]>(0)))
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] CHECK CONSTRAINT [CheckNegativeZeroAmount]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder]  WITH CHECK ADD  CONSTRAINT [CheckRate] CHECK  (([Rate]>(0)))
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] CHECK CONSTRAINT [CheckRate]
GO
ALTER TABLE [dbo].[tbl_MatchedOrder]  WITH CHECK ADD  CONSTRAINT [CheckVolume] CHECK  (([Volume]>(0)))
GO
ALTER TABLE [dbo].[tbl_MatchedOrder] CHECK CONSTRAINT [CheckVolume]
GO
ALTER TABLE [dbo].[tbl_SellOrder]  WITH CHECK ADD  CONSTRAINT [CheckGreaterThanZeroTotalSellAndPending] CHECK  (([Totalamount]>(0) AND [pendingvolume]>=(0)))
GO
ALTER TABLE [dbo].[tbl_SellOrder] CHECK CONSTRAINT [CheckGreaterThanZeroTotalSellAndPending]
GO
ALTER TABLE [dbo].[tbl_SellOrder]  WITH CHECK ADD  CONSTRAINT [CheckNegativeSellVolume] CHECK  (([Volume]>(0)))
GO
ALTER TABLE [dbo].[tbl_SellOrder] CHECK CONSTRAINT [CheckNegativeSellVolume]
GO
ALTER TABLE [dbo].[tbl_SellOrder]  WITH CHECK ADD  CONSTRAINT [CheckZeroNegativeSellRate] CHECK  (([Rate]>(0)))
GO
ALTER TABLE [dbo].[tbl_SellOrder] CHECK CONSTRAINT [CheckZeroNegativeSellRate]
GO
/****** Object:  StoredProcedure [dbo].[ChangeSponsor]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[ChangeSponsor]
    @UserCode bigint,
    @OldSponsorId bigint,
    @NewSponsorId bigint
AS
BEGIN
    update tbl_Customer set ReferralId = @NewSponsorId where CID = @UserCode
    delete from tblmatrixmaster where MemberID = @UserCode
    update tbl_Customer set teamreferral = teamreferral - 1 where cid in (select sponserid from tblmatrixmaster with (nolock) where memberid = @UserCode)
    exec [dbo].[CreateMatrix] @UserCode, @NewSponsorId
    select 'success'
END
GO
/****** Object:  StoredProcedure [dbo].[Clean_M3BOT_Data]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================

CREATE   PROCEDURE [dbo].[Clean_M3BOT_Data]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    IF OBJECT_ID('dbo.a_good_bot_orders', 'U') IS NOT NULL
        DROP TABLE dbo.a_good_bot_orders;

    select *  into a_good_bot_orders from (
                                              select OrderID,BuyOrderID BotOrderID, 'Buy' Side,Volume,Rate,Buyer_TotalAmount TotalAmount,BuyerID CustomerID,OrderConfirmDate,MarketType,CurrencyType from tbl_MatchedOrder where BuyerID  in (Select cid from tbl_Bots) and SellerID not in (Select cid from tbl_Bots)
                                              UNION
                                              select OrderID,SellOrderID BotOrderID, 'Sell' Side,Volume,Rate,Seller_TotalAmount TotalAmount,SellerID CustomerID,OrderConfirmDate,MarketType,CurrencyType  from tbl_MatchedOrder where BuyerID  not in (Select cid from tbl_Bots) and SellerID  in (Select cid from tbl_Bots)
                                          ) tAbA

    delete from tbl_MatchedOrder where BuyerID in (select cid from tbl_Bots) and orderid not in (select orderid from a_good_bot_orders)
    delete from tbl_MatchedOrder where SellerID in (select cid from tbl_Bots) and orderid not in (select orderid from a_good_bot_orders)
    delete from tbl_BuyOrder where BuyerID in (select cid from tbl_Bots) and orderid not in (select BotOrderID from a_good_bot_orders) and OrderStatus=1
    delete from tbl_SellOrder where SellerID in (select cid from tbl_Bots) and orderid not in (select BotOrderID from a_good_bot_orders) and OrderStatus=1

    delete from AccountMaster where MemberID in (Select cid from tbl_Bots)


END
GO
/****** Object:  StoredProcedure [dbo].[CleanDB]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE   proc [dbo].[CleanDB]
AS
BEGIN
    delete from tbl_matchedorder
    truncate table tbl_MatchedOrder_Archive
    truncate table tbl_buyorder_archive
    truncate table tbl_sellorder_archive
    truncate table tblMatrixMaster
    delete from tbl_CancelledOrders
    delete from tbl_ReferralComissions
    delete from Temp_Fiat_PG_Payments_Notification
    delete from tbl_Bots

    exec dbo.CleanRoleBasedAuthentications

    DoAgainBuyOrder:
    delete top(1000) from  tbl_buyorder
    IF @@ROWCOUNT > 0
        GOTO DoAgainBuyOrder;


    DoAgainSellOrder:
    delete top(1000) from  tbl_sellorder
    IF @@ROWCOUNT > 0
        GOTO DoAgainSellOrder;


    DoAgainaccountmaster:
    delete top(1000) from  accountmaster
    IF @@ROWCOUNT > 0
        GOTO DoAgainAccountmaster;



    DoAgainaccountmaster_Archive:
    delete top(1000) from  accountmaster_Archive
    IF @@ROWCOUNT > 0
        GOTO DoAgainaccountmaster_Archive;
    delete from tbl_TDM_Tiers
    delete from tbl_TradeSize
    delete from tbl_withdraw_limits
    delete from tbl_InstaTrade
    delete from tbl_FeeDiscount_VolumeBased
    delete from SumAndSubstanceApplicationTracker
    delete from tbl_Fiat_Manual_Deposit_Requests
    delete from tbl_Fiat_Manual_Withdrawal_Requests
    delete from tbl_Fiat_PG_Payments
    delete from tbl_USDPriceMaster
    delete from tbl_InstaPair_Reserve
    delete from tbl_InstaPairs
    delete from tbl_AddressMaster_Merchant
    delete from tbl_AddressMaster
    delete from tbl_AddressStorage
    delete from tbl_FeeUserGroups
    delete from tbl_Withdrawal
    delete from tbl_deposit
    delete from tbl_Fiat_Manual_Deposit_Requests
    delete from tbl_Fiat_Manual_Withdrawal_Requests
    delete from tbl_Fiat_PG_Payments
    delete from tbl_Fiat_BanksList
    delete from tbl_SessionLog
    delete from tbl_NotificationMaster
    delete from tbl_LoginManager
    delete from tbl_ExceptionLog
    delete from tbl_ResetLink
    delete from tbl_RiskTrigger
    delete from tbl_TDMEnrollments
    delete from tbl_TDM_Disenrollments
    delete from tbl_ApikeyManager
    delete from tbl_TokenCollection
    delete from tbl_USDPriceMaster
    delete from KYC_New




    truncate table [dbo].[TransactionStatus]
    truncate table [dbo].[tbl_Chart_1_min]
    truncate table [dbo].[tbl_Chart_5_min]
    truncate table [dbo].[tbl_Chart_15_min]
    truncate table [dbo].[tbl_Chart_60_min]
    truncate table [dbo].[tbl_Chart_240_min]
    truncate table [dbo].[tbl_Chart_1440_min]
    truncate table [dbo].[tbl_Chart_10080_min]
    truncate table [dbo].[tbl_Chart_43200_min]
    truncate table [dbo].[AccountMaster_Archive]
    truncate table [dbo].[tbl_BuyOrder_Archive]
    truncate table [dbo].[tbl_SellOrder_Archive]
    truncate table [dbo].[tbl_AddressRequestsBitGoETH]
    truncate table [dbo].[tbl_AddressMaster]
    truncate table [dbo].[KYC_New]
    truncate table [dbo].[Temp_Fiat_PG_Payments_Notification]

    truncate table [dbo].[tbl_CopyTrade_Orders]
    truncate table [dbo].[tbl_CopyTrade_Followers]

    delete from tbl_Customer where CID not in (250252, 332424)
    delete from tbl_Market where CoinName !='ETH' and MarketName!='BTC'
    update tbl_Market set CurrentTradingPrice = 0, Last24HrsHigh=0, TotalVolume=0, TotalVolumeBaseCurrency=0, Last24HrsLow=0, ChangeInPrice=0, PreviousTradingPrice=0
END
GO
/****** Object:  StoredProcedure [dbo].[CreateMatrix]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[CreateMatrix]
    -- Add the parameters for the stored procedure here
    @UserCode bigint,
    @SPID bigint
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @ParentCode bigint
    DECLARE @Level BIGINT
    SET @Level = 1
    INSERT INTO tblmatrixmaster(SponserID,MemberID,Level) VALUES (@SPID ,@UserCode,@Level)
    SELECT @ParentCode = DBO.MySponsor(@SPID)
    WHILE @ParentCode != @SPID and  @Level<=3
        BEGIN
            SET @Level = @Level + 1
            INSERT INTO tblmatrixmaster(SponserID,MemberID,Level) VALUES (@ParentCode ,@UserCode,@Level)
            SET @SPID =  @ParentCode
            SELECT @ParentCode = DBO.MySponsor(@SPID)
        END

    update tbl_Customer set teamreferral = teamreferral + 1 where cid in (select sponserid from tblmatrixmaster with (nolock) where memberid = @UserCode)
END
GO
/****** Object:  StoredProcedure [dbo].[Delete_Customer]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [dbo].[Delete_Customer]
@CID BIGINT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    --SET NOCOUNT ON;
    declare @email nvarchar(50)
    select @email=replace(newid(),'-','')+'@xyz.com'
    UPDATE       tbl_Customer
    SET                FirstName = 'DELETED', MiddleName = 'DELETED', LastName = 'DELETED', [Name] = 'DELETED', LoginPassword = 'DELETED', Gender = 'DELETED', DOB ='1940-01-01', MaritalStatus = 'DELETED', FatherName = 'DELETED', City = 'DELETED', District = 'DELETED', [State] = 'DELETED', Country = 'DELETED', [Address] = 'DELETED', PostalCode = '000000', Mobile = (Select LEFT(SUBSTRING (RTRIM(RAND()) + SUBSTRING(RTRIM(RAND()),3,11), 3,11),10))
            , Email = @email, PassportNo = 'DELETED', [Status] = 'InActive',
                       Nationality =  'DELETED', NationalityStatus = 0, GoogleAuthKey = replace(newid(),'-',''), TelegramID = 'DELETED', WebHookUrl = 'DELETED', WebHookKey = 'DELETED', ProfileIMG = 'DELETED', AddressProofIMG = 'DELETED', PassportIMG = 'DELETED', KycDetailStatus = null, ApprovedBy = null, IsUserBlocked = 1 where CID = @CID


    if exists (select 1 from TransactionStatus where CID = @CID)
        update TransactionStatus set Withdrawal_Status = 1, Deposit_Status = 1, Trade_Status = 1 where CID = @CID
    else
        insert into TransactionStatus (CID, Withdrawal_Status, Deposit_Status, Trade_Status) values (@CID, 1, 1, 1)

    delete from KYC_New where CustomerID = @CID

END
GO
/****** Object:  StoredProcedure [dbo].[Exchange_Insert_Referral]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Exchange_Insert_Referral]
    -- Add the parameters for the stored procedure here
    @Order_ServiceFee_buy decimal(18,8),
    @Order_ServiceFee_sell decimal(18,8),
    @Buy_BuyerID BIGINT,
    @Sell_SellerID BIGINT,
    @ExecDate DATETIME,
    @MinTxnNoTradeCurrency int,
    @MinTxnNoBaseCurrency int,
    @Match_Order_ID bigint,
    @Curr NVARCHAR(5),
    @Market nVARCHAR(5),
    @exec_type nvarchar(4),
    @Has_Buyer_paid_in_Exchage_token bit,
    @Has_seller_paid_in_Exchage_token bit,
    @Order_ServiceFee_buy_in_exch_token decimal(18,8),
    @Order_ServiceFee_sell_in_exch_token decimal(18,8),
    @MinTxnNoExchCurrency int,
    @exchange_token nvarchar(5),
    @quotecurr_exchangetoken_market_price decimal(18,8),
    @quote_curr_Fee_model nvarchar(5)

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    declare @level_count int,@perc float, @t_Buy_BuyerID bigint, @t_Sell_SellerID bigint, @Seller_SPID bigint, @Buyer_SPID bigint,@Order_ServiceFee_buy_admin decimal(18,8), @Order_ServiceFee_sell_admin decimal(18,8)
        , @Disable_RM nvarchar(5)='True'

    select @Disable_RM=SettingValue from tbl_settings where SettingName='Disable_RM'

    IF @quote_curr_Fee_model = 'True'
        SET @MinTxnNoBaseCurrency = @MinTxnNoTradeCurrency

    SET @Order_ServiceFee_buy_admin = @Order_ServiceFee_buy
    SeT @Order_ServiceFee_sell_admin = @Order_ServiceFee_sell

    SET @t_Buy_BuyerID = @Buy_BuyerID
    SET @t_Sell_SellerID = @Sell_SellerID

    set @level_count = 1
    WHILE @level_count <=3 and @Disable_RM='False'
        BEGIN

            select @Buyer_SPID = dbo.MySponsor(@t_Buy_BuyerID)
            select @Seller_SPID = dbo.MySponsor(@t_Sell_SellerID)

            set @perc = 0
            IF @level_count = 1
                select @perc = cast(SettingValue as float)/100 from tbl_Settings with (nolock) where SettingName = 'Level-1-Referral-%'
            ELSE IF @level_count = 2
                select @perc = cast(SettingValue as float)/100 from tbl_Settings with (nolock)  where SettingName = 'Level-2-Referral-%'
            ELSE IF @level_count = 3
                select @perc = cast(SettingValue as float)/100 from tbl_Settings with (nolock)  where SettingName = 'Level-3-Referral-%'
            ELSE
                BREAK;

            print '@Buyer_SPID' + cast(isnull(@Buyer_SPID, -1) as nvarchar)
            print '@perc' + cast(isnull(@perc, 'NULL') as nvarchar)
            print '@Order_ServiceFee_buy' + cast(isnull(@Order_ServiceFee_buy, 'NULL') as nvarchar)

            IF @Buyer_SPID IS NOT NULL AND @perc > 0 AND @Buyer_SPID != 250252 AND @Buyer_SPID!= -1 AND @Order_ServiceFee_buy*@perc>0
                BEGIN
                    -- buyer pays in base currency
                    INSERT INTO AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoBaseCurrency+6),@Buyer_SPID,@ExecDate,'Referral Commision from Trade#'+ CAST(@Match_Order_ID AS NVARCHAR),@Order_ServiceFee_buy*@perc,0,1)

                    INSERT INTO [dbo].[tbl_ReferralComissions]([Coin],[Market],[TradeID],[FromCID],[ToCID],[ExecType], [ExecDate],[FromCID_Paid_Curr], Amount)
                    VALUES(@Curr, @Market, @Match_Order_ID, @Buy_BuyerID, @Buyer_SPID, @exec_type, @ExecDate, @Curr, @Order_ServiceFee_buy*@perc)

                    SET @Order_ServiceFee_buy_admin = @Order_ServiceFee_buy_admin - (@Order_ServiceFee_buy*@perc)

                END

            print '@Seller_SPID' + cast(isnull(@Seller_SPID, -1) as nvarchar)
            print '@perc' + cast(isnull(@perc, 'NULL') as nvarchar)
            print '@Order_ServiceFee_sell' + cast(isnull(@Order_ServiceFee_sell, 'NULL') as nvarchar)
            IF @Seller_SPID IS NOT NULL AND @perc > 0 AND @Seller_SPID != 250252 AND @Seller_SPID != -1 AND @Order_ServiceFee_sell*@perc>0
                BEGIN
                    -- seller pays in quote currency
                    INSERT INTO AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoTradeCurrency+6),@Seller_SPID,@ExecDate,'Referral Commision from Trade#'+ CAST(@Match_Order_ID AS NVARCHAR),@Order_ServiceFee_sell*@perc,0,1)

                    INSERT INTO [dbo].[tbl_ReferralComissions]([Coin],[Market],[TradeID],[FromCID],[ToCID],[ExecType], [ExecDate], [FromCID_Paid_Curr], Amount)
                    VALUES(@Curr, @Market, @Match_Order_ID, @Sell_SellerID, @Seller_SPID, @exec_type, @ExecDate, @Market,@Order_ServiceFee_sell*@perc)

                    SET @Order_ServiceFee_sell_admin = @Order_ServiceFee_sell_admin - (@Order_ServiceFee_sell*@perc)

                END
            SET @t_Buy_BuyerID = @Buyer_SPID
            SET @t_Sell_SellerID = @Seller_SPID
            SET @level_count = @level_count + 1
        END

    print 'insert referral 1'

    --Changed on 29th march== Issue Was : ===== In case of exch_token FeeCollection entries were being inserted twice.
    IF @Order_ServiceFee_buy_in_exch_token > 0
        INSERT INTO AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status])
        values((@MinTxnNoExchCurrency+7),250252,@ExecDate,'Fee Collected from Buy Side Trade#'+ CAST(@Match_Order_ID AS NVARCHAR),@Order_ServiceFee_buy_in_exch_token,0,1)
    Else IF @Order_ServiceFee_buy_admin > 0
        INSERT INTO AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status])
        values((@MinTxnNoBaseCurrency+7),250252,@ExecDate,'Fee Collected from Buy Side Trade#'+ CAST(@Match_Order_ID AS NVARCHAR),@Order_ServiceFee_buy_admin,0,1)

    IF @Order_ServiceFee_sell_in_exch_token > 0
        INSERT INTO AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status])
        values((@MinTxnNoExchCurrency+7),250252,@ExecDate,'Fee Collected from Sell Side Trade#'+CAST(@Match_Order_ID AS NVARCHAR) ,@Order_ServiceFee_sell_in_exch_token,0,1)
    ELSE IF @Order_ServiceFee_sell_admin > 0
        INSERT INTO AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status])
        values((@MinTxnNoTradeCurrency+7),250252,@ExecDate,'Fee Collected from Sell Side Trade#'+CAST(@Match_Order_ID AS NVARCHAR) ,@Order_ServiceFee_sell_admin,0,1)


    print 'insert referral'

    declare @vol decimal(18,8)
    IF @Has_Buyer_paid_in_Exchage_token = 0 AND @Order_ServiceFee_buy_admin > 0 and @quotecurr_exchangetoken_market_price > 0
        BEGIN

            set @vol = (@Order_ServiceFee_buy_admin * 0.25) / @quotecurr_exchangetoken_market_price
            print @vol


        END
    IF @Has_Seller_paid_in_Exchage_token = 0  AND @Order_ServiceFee_sell_admin > 0 and @quotecurr_exchangetoken_market_price > 0
        BEGIN
            set @vol = (@Order_ServiceFee_sell_admin * 0.25) / @quotecurr_exchangetoken_market_price


        END

    -- Upto this point we have distributed fee in base/quote currencies. 

    IF @Has_Buyer_paid_in_Exchage_token =1
        BEGIN
            SET @Order_ServiceFee_buy = @Order_ServiceFee_buy_in_exch_token
            SET @MinTxnNoBaseCurrency = @MinTxnNoExchCurrency
        END
    IF @Has_Seller_paid_in_Exchage_token =1
        BEGIN
            SeT @Order_ServiceFee_sell = @Order_ServiceFee_sell_in_exch_token
            SET @MinTxnNoTradeCurrency = @MinTxnNoExchCurrency
        END


END
GO
/****** Object:  StoredProcedure [dbo].[Exchange_InsertMatch_Deprecated]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------------------------------------------------------------------

create   PROCEDURE [dbo].[Exchange_InsertMatch_Deprecated]
(@Sell_OrderID bigint,
 @Buy_OrderID bigint,
 @MatchedVolume decimal(20,10),
 @ExecRate decimal(20,10),
 @Curr_Name nvarchar(5),
 @Market_Name nvarchar(5),
 @Buy_BuyerID bigint,
 @Sell_SellerID bigint,

 @ServiceCharge_Buy decimal(20,10)=0,
 @ServiceCharge_Sell decimal(20,10)=0,

 @MakerId bigint,
 @TakerId bigint,

 @Buy_PendingVolume decimal(20,10)=0,
 @Sell_PendingVolume decimal(20,10)=0,

 @execSide nvarchar(4),
 @Buyer_OrderCategory NVARCHAR(20),
 @Seller_OrderCategory NVARCHAR(20),

 @UpdateOrderDetails bit=1,--when SQL_ME @UpdateOrderDetails==1  else  @UpdateOrderDetails==0

 @result nvarchar(Max) OUTPUT)


AS BEGIN
    --print 'Insert Match Execution Started'
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    --Describe Fee Model:
    --Buy XRP/BTC-- pays in XRP
    -- no fee on order-submission, 10 XRP @ 0.5 BTC - > 5 BTC deducted
    -- assume maker fee: 0.5% and taker fee : 1 %
    -- if buyer is a maker, 0.05 XRP payable
    -- if buyer is a taker,   0.10 XRP payable



    -- Sell XRP/BTC-- pays in BTC
    -- no fee on order-submission, 10 XRP @ 0.5 BTC - > 10 XRP deducted
    -- assume maker fee: 0.5% and taker fee : 1 %
    -- if seller is a maker, 0.025 BTC payable, Seller gets 0.5*10-0.025 = 4.975 BTC
    -- if seller is a taker, 0.500 BTC payable, Seller gets 0.5*10-0.050 = 4.950 BTC

    declare @Order_ServiceFee_buy decimal(20,10), @Order_TotalAmount_buy decimal(20,10), @Order_ServiceFee_sell decimal(20,10), @Order_TotalAmount_sell decimal(20,10), @Order_Amount  decimal(20,10), @MinTxnNoBaseCurrency int=-1, @MinTxnNoTradeCurrency int=-2,  @Msg nvarchar(350), @buyer_Credit decimal(20,10), @Seller_Credit decimal(20,10), @Exchange_Token nvarchar(maX), @MinTxnNoExchCurrency int,@Order_ServiceFee_sell_admin decimal(20,10), @Order_ServiceFee_buy_admin decimal(20,10)
    DECLARE @Buyer_Pays_ET INT, @Seller_Pays_ET INT, @Buyer_Token_Balance decimal(20,10), @Seller_Token_Balance decimal(20,10), @Buyer_Discount  decimal(10,7), @Seller_Discount  decimal(10,7), @Exchange_Token_MarketPrice decimal(20,10), @ExecDate DATETIME, @isBuyProOrder bit=0, @isSellProOrder bit=0, @ServiceCharge_Buy_pro decimal(20,10), @ServiceCharge_sell_pro decimal(20,10)

    DECLARE @Order_ServiceFee_buy_nett decimal(20,10), @Order_ServiceFee_sell_nett decimal(20,10)

    declare @Match_Order_ID bigint

    DECLARE @err_msg AS NVARCHAR(250);

    declare @Has_Buyer_paid_in_Exchage_token BIT, @Has_Seller_paid_in_Exchage_token BIT
    DECLARE @Order_ServiceFee_buy_in_exch_token decimal(20,10), @Order_ServiceFee_sell_in_exch_token decimal(20,10)

    declare @quote_curr_Fee_model nvarchar(20)
    SET @result = 'Error'
    --SET NOCOUNT ON;
--BEGIN TRY
--BEGIN TRANSACTION TMMBO  
    declare @buyrate decimal(20,10)=0, @pdiff decimal(20,10)=0, @refund_inQuoteCurr decimal(20,10)=0, @service_chargeinQuoteCurr decimal(20,10)=0
    select @buyrate = [Rate],@service_chargeinQuoteCurr=ServiceChargePerc, @isBuyProOrder = IsMarginOrder from dbo.tbl_buyOrder  where OrderID = @Buy_OrderID
    select @isSellProOrder = IsMarginOrder from dbo.tbl_SellOrder  where OrderID = @Sell_OrderID

    select @MinTxnNoBaseCurrency=TransactionTypeMin from dbo.[tbl_CurrencyPrefrences]  where CurrencyShortName=@Market_Name
    select @MinTxnNoTradeCurrency=TransactionTypeMin from dbo.[tbl_CurrencyPrefrences]  where CurrencyShortName=@Curr_Name

    select @ServiceCharge_Buy = MakerFee, @ServiceCharge_Sell = TakerFee, @ServiceCharge_Buy_pro = MakerFeePro, @ServiceCharge_Sell_pro = TakerFeePro from dbo.tbl_Market  where CoinName=@Curr_Name and MarketName = @Market_Name


    if @MinTxnNoBaseCurrency<0 or @MinTxnNoTradeCurrency<0
        return

    select @quote_curr_Fee_model =  settingValue from dbo.tbl_Settings  where SettingName='Fee_In_Quote_Currency'
    SET @execDate = getutcdate()
    select @Exchange_Token = SettingValue from dbo.tbl_Settings  where SettingName = 'Exchange_Token'

    SET @MinTxnNoExchCurrency = -10
    select @MinTxnNoExchCurrency=TransactionTypeMin from dbo.[tbl_CurrencyPrefrences]  where CurrencyShortName=@Exchange_Token
    declare  @service_fee_buy_Refund decimal(20,10) = 0, @TDM_ETPay_Share  decimal(20,10)=100
    select @TDM_ETPay_Share =  settingValue from dbo.tbl_Settings  where SettingName='TDM_ETPay_Share'
    SET @TDM_ETPay_Share = round((@TDM_ETPay_Share *cast(0.01 as decimal(20,10))),8,1)

    select @Buyer_Token_Balance = dbo.getBalance_MO(@Exchange_Token,@Buy_BuyerID)
    select @Seller_Token_Balance = dbo.getBalance_MO(@Exchange_Token,@Sell_SellerID)

    select top(1) @Buyer_Discount = Discount from [dbo].[tbl_TDM_Tiers]  where Holding <= @Buyer_Token_Balance order by Holding DESC
    select top(1) @Seller_Discount = Discount from [dbo].[tbl_TDM_Tiers]  where Holding <= @Seller_Token_Balance order by Holding DESC

    SET @Buyer_Discount = round(ISNULL(@Buyer_Discount/100,0),8,1)
    SET @Seller_Discount = round(ISNULL(@Seller_Discount/100,0),8,1)

    set @Order_Amount=round(@MatchedVolume*@ExecRate,8,1)



    -- Checking Custom fee user groups:
    declare @Buyer_fee_group_discount  decimal(20,10), @seller_fee_group_discount  decimal(20,10)
    select top(1) @Buyer_fee_group_discount = FeePerc from dbo.tbl_FeeUserGroups  where CID = @Buy_BuyerID AND IsDeleted=0 order by FeePerc DESC
    select top(1) @seller_fee_group_discount = FeePerc from dbo.tbl_FeeUserGroups  where CID = @Sell_SellerID AND IsDeleted=0 order by FeePerc DESC
    set @Buyer_fee_group_discount = round(ISNULL(@Buyer_fee_group_discount*cast(0.01 as decimal(20,10)),0),8,1)
    SET @seller_fee_group_discount = round(ISNULL(@seller_fee_group_discount*cast(0.01 as decimal(20,10)),0),8,1)

    IF @Buyer_fee_group_discount > 0
        SET @Buyer_Discount = @Buyer_fee_group_discount
    IF @seller_fee_group_discount > 0
        SET @Seller_Discount = @seller_fee_group_discount
    -- End of Checking Custom fee user groups


    -- Sanity Check : discount > 100%
    IF @Buyer_Discount > 100
        set @Buyer_Discount = 100
    IF @Seller_Discount > 100
        set @Seller_Discount = 100

    IF @quote_curr_Fee_model != 'True'
        BEGIN
            --  when buyers pays in base currency i.e. -- usual fee model
            IF @Buy_BuyerID = @MakerId AND @isBuyProOrder = 0
                set @Order_ServiceFee_buy= round( ((@MatchedVolume* (@ServiceCharge_Buy- (@ServiceCharge_Buy*@Buyer_Discount)))/100) ,8,1)
            ELSE IF @Buy_BuyerID = @MakerId AND @isBuyProOrder = 1
                set @Order_ServiceFee_buy= round( ((@MatchedVolume* (@ServiceCharge_Buy_pro- (@ServiceCharge_Buy_pro*@Buyer_Discount)))/100) ,8,1)
            ELSE IF @Buy_BuyerID = @TakerId AND @isBuyProOrder = 0
                set @Order_ServiceFee_buy = round((@MatchedVolume*(@ServiceCharge_Sell-(@ServiceCharge_Sell*@Buyer_Discount))/100),8,1)
            ELSE IF @Buy_BuyerID = @TakerId AND @isBuyProOrder = 1
                set @Order_ServiceFee_buy = round((@MatchedVolume*(@ServiceCharge_Sell_pro-(@ServiceCharge_Sell_pro*@Buyer_Discount))/100),8,1)
        END
    ELSE
        BEGIN
            --  when Quote Currency Fee Model is True. only buyer's have to pay fee in quote currency instead of base currency as buyers usually pay in base currency
            IF @Buy_BuyerID = @MakerId AND @isBuyProOrder = 0 --Maker's fee in base curr
                set @Order_ServiceFee_buy=round((@Order_Amount*(@ServiceCharge_Buy- (@ServiceCharge_Buy*@Buyer_Discount))/100),8,1)    -- 
            ELSE IF @Buy_BuyerID = @MakerId AND @isBuyProOrder = 1 --Maker's pro fee in base curr
                set @Order_ServiceFee_buy=round((@Order_Amount*(@ServiceCharge_Buy_pro- (@ServiceCharge_Buy_pro*@Buyer_Discount))/100),8,1)    -- 
            ELSE IF @Buy_BuyerID = @TakerId  AND @isBuyProOrder = 0  -- Taker's fee in base 
                set @Order_ServiceFee_buy= round((@Order_Amount*(@ServiceCharge_Sell-(@ServiceCharge_Sell*@Buyer_Discount))/100),8,1) -- 
            ELSE IF @Buy_BuyerID = @TakerId  AND @isBuyProOrder = 1  -- Taker's pro fee in base 
                set @Order_ServiceFee_buy= round((@Order_Amount*(@ServiceCharge_Sell_pro-(@ServiceCharge_Sell_pro*@Buyer_Discount))/100),8,1) -- 
        END

    IF @Sell_SellerID = @TakerId AND @isSellProOrder = 0 --Taker's fee in quote curr
        set @Order_ServiceFee_sell=  round(( @Order_Amount*(@ServiceCharge_Sell-(@ServiceCharge_Sell*@Seller_Discount)) /100),8,1) -- 
    ELSE IF @Sell_SellerID = @TakerId AND @isSellProOrder = 1 --Taker's pro fee in quote curr
        set @Order_ServiceFee_sell=  round(( @Order_Amount*(@ServiceCharge_Sell_pro-(@ServiceCharge_Sell_pro*@Seller_Discount)) /100),8,1) -- 
    ELSE IF @Sell_SellerID = @MakerId AND @isSellProOrder = 0 -- maker's fee in quote curr
        set @Order_ServiceFee_sell= round((@Order_Amount*(@ServiceCharge_Buy-(@ServiceCharge_Buy*@Seller_Discount))/100),8,1) -- Maker's 
    ELSE IF @Sell_SellerID = @MakerId AND @isSellProOrder = 1 -- maker's pro fee in quote curr
        set @Order_ServiceFee_sell= round((@Order_Amount*(@ServiceCharge_Buy_pro-(@ServiceCharge_Buy_pro*@Seller_Discount))/100),8,1) -- Maker's 


    --SET @Order_ServiceFee_sell = round((@Order_ServiceFee_sell*cast(0.01 as decimal(20,10))),8,1)
    --SET @Order_ServiceFee_buy = round((@Order_ServiceFee_buy *cast(0.01 as decimal(20,10))),8,1)


    IF @Order_ServiceFee_buy <=0
        set @Order_ServiceFee_buy = 0
    IF @Order_ServiceFee_sell <=0
        set @Order_ServiceFee_sell = 0

    IF @quote_curr_Fee_model = 'True'
        BEGIN
            IF @Buy_BuyerID = @MakerId
                BEGIN
                    --SET NUMERIC_ROUNDABORT OFF
                    set @service_fee_buy_Refund=round(@Order_Amount*@ServiceCharge_Sell,8,1)
                    set @service_fee_buy_Refund=round((@service_fee_buy_Refund / 100),8,1)
                    set @service_fee_buy_Refund = round(@service_fee_buy_Refund - @Order_ServiceFee_buy,8,1)
                END
            IF @Buy_BuyerID = @TakerId and @Order_ServiceFee_buy !=round((@Order_Amount*@ServiceCharge_Sell/100),8,1)
                BEGIN
                    --SET NUMERIC_ROUNDABORT OFF
                    set @service_fee_buy_Refund=round((@Order_Amount*@ServiceCharge_Sell/100 - @Order_ServiceFee_buy),8,1)
                END
        END
    if @service_fee_buy_Refund < 0
        set @service_fee_buy_Refund = 0
    declare @t_curr nvarchar(5), @t_curr_price decimal(20,10)
    --checking if fee is to be paid in exchange-tokens 

    set @Order_ServiceFee_buy_in_exch_token= 0
    SET @Order_ServiceFee_sell_in_exch_token = 0
    select @Buyer_Pays_ET = ISNULL(COUNT(*),0) from dbo.tbl_TDMEnrollments  WHERE CID = @Buy_BuyerID
    select @Seller_Pays_ET = ISNULL(COUNT(*),0) from dbo.tbl_TDMEnrollments  WHERE CID = @Sell_SellerID
    SET @Buyer_Pays_ET = ISNULL(@Buyer_Pays_ET,0)
    SET @Seller_Pays_ET = ISNULL(@Seller_Pays_ET,0)
    IF @Buyer_Pays_ET = 1 AND @Order_ServiceFee_buy > 0
        BEGIN

            IF @quote_curr_Fee_model = 'True'
                select @t_curr_price = CurrentTradingPrice from dbo.tbl_Market   where CoinName = @Market_Name AND MarketName = @Exchange_Token
            ELSE
                select @t_curr_price = CurrentTradingPrice from dbo.tbl_Market   where CoinName = @Curr_Name AND MarketName = @Exchange_Token

            SET @t_curr_price = ISNULL(@t_curr_price,0)
            IF @t_curr_price > 0  -- BTC/MDX price
                SET @Order_ServiceFee_buy_in_exch_token = round((@Order_ServiceFee_buy * (1 / @t_curr_price) * @TDM_ETPay_Share),8,1)
            ELSE
                SET @Order_ServiceFee_buy_in_exch_token = 0
            IF @Order_ServiceFee_buy_in_exch_token >0 AND @Buyer_Token_Balance < @Order_ServiceFee_buy_in_exch_token
                SET @Order_ServiceFee_buy_in_exch_token = 0

        END
    IF @Seller_Pays_ET = 1  AND @Order_ServiceFee_sell > 0
        BEGIN
            --IF @Sell_SellerID = @MakerId SET @t_curr = @Curr_Name ELSE IF @Sell_SellerID = @TakerID SET @t_curr = @Market_Name
            set @t_curr_price = 0
            select @t_curr_price = CurrentTradingPrice from dbo.tbl_Market   where CoinName = @Market_Name AND MarketName = @Exchange_Token
            SET @t_curr_price = ISNULL(@t_curr_price,0)
            IF @t_curr_price > 0  -- BTC/MDX price
                SET @Order_ServiceFee_sell_in_exch_token = round((@Order_ServiceFee_sell * (@t_curr_price) * @TDM_ETPay_Share),8,1)
            ELSE
                SET @Order_ServiceFee_sell_in_exch_token = 0
            IF @Order_ServiceFee_sell_in_exch_token >0 AND @Seller_Token_Balance < @Order_ServiceFee_sell_in_exch_token
                SET @Order_ServiceFee_sell_in_exch_token = 0
        END
    ---- end of checking exchange-token fee model


    IF @quote_curr_Fee_model = 'True'
        BEGIN
            IF @Order_ServiceFee_buy_in_exch_token = 0
                BEGIN
                    SET @Order_TotalAmount_buy=@MatchedVolume
                    SET @Order_ServiceFee_buy_nett = @Order_ServiceFee_buy
                END
            ELSE IF @Order_ServiceFee_buy_in_exch_token > 0
                BEGIN
                    SET @Order_TotalAmount_buy=@MatchedVolume
                    SET @Order_ServiceFee_buy_nett = round(@Order_ServiceFee_buy-(@Order_ServiceFee_buy*@TDM_ETPay_Share),8,1)
                END

        END
    ELSE
        BEGIN
            IF @Order_ServiceFee_buy_in_exch_token = 0
                BEGIN
                    set @Order_TotalAmount_buy=@MatchedVolume-@Order_ServiceFee_buy
                    SET @Order_ServiceFee_buy_nett = @Order_ServiceFee_buy
                END
            ELSE IF @Order_ServiceFee_buy_in_exch_token > 0
                BEGIN
                    SET @Order_TotalAmount_buy=round(@MatchedVolume-@Order_ServiceFee_buy-(@Order_ServiceFee_buy*@TDM_ETPay_Share),8,1)
                    SET @Order_ServiceFee_buy_nett = round(@Order_ServiceFee_buy-(@Order_ServiceFee_buy*@TDM_ETPay_Share),8,1)
                END
        END

    IF @Order_ServiceFee_sell_in_exch_token = 0
        BEGIN
            set @Order_TotalAmount_sell=round(@Order_Amount-(@Order_ServiceFee_sell),8,1)
            SET @Order_ServiceFee_sell_nett = @Order_ServiceFee_sell
        END
    ELSE IF @Order_ServiceFee_sell_in_exch_token > 0
        BEGIN
            SET @Order_TotalAmount_sell=round(@Order_Amount-@Order_ServiceFee_sell-(@Order_ServiceFee_sell*@TDM_ETPay_Share),8,1)
            SET @Order_ServiceFee_sell_nett = round(@Order_ServiceFee_sell-(@Order_ServiceFee_sell*@TDM_ETPay_Share),8,1)
        END


    SET @Has_Buyer_paid_in_Exchage_token = 0
    SET @Has_Seller_paid_in_Exchage_token = 0

    IF @Order_ServiceFee_buy_in_exch_token > 0
        SET @Has_Buyer_paid_in_Exchage_token =1
    IF @Order_ServiceFee_sell_in_exch_token > 0
        SET @Has_Seller_paid_in_Exchage_token = 1

    Begin Try
        insert into dbo.tbl_matchedOrder(SellOrderId,BuyOrderId,Volume,Rate,CurrencyType,Amount,Buyer_Brokerage,Buyer_SGST,Buyer_CGST,Buyer_IGST,Buyer_TotalAmount,Seller_Brokerage,Seller_SGST,Seller_CGST,Seller_IGST,Seller_TotalAmount,OrderConfirmDate,OrderStatus,ExecutionType,BuyerID,SellerID,MarketType)
        values(@Sell_OrderID,@Buy_OrderID,@MatchedVolume,@ExecRate,@Curr_Name,@Order_Amount,@Order_ServiceFee_buy,@Has_Buyer_paid_in_Exchage_token,@Order_ServiceFee_buy_in_exch_token,@Order_ServiceFee_buy_nett,@Order_TotalAmount_buy,@Order_ServiceFee_sell,@Has_Seller_paid_in_Exchage_token,@Order_ServiceFee_sell_in_exch_token,@Order_ServiceFee_sell_nett,@Order_TotalAmount_sell,@ExecDate,1,@execSide,@Buy_BuyerID,@Sell_SellerID,@Market_Name)
        set @Match_Order_ID = SCOPE_IDENTITY()
    End Try
    BEgin Catch
        --set @result=ERROR_MESSAGE()
        return
    End Catch

    set @result='Match #' + cast(@Match_Order_ID as nvarchar)


    IF @TakerId = @Buy_BuyerID and @ExecRate < @buyrate -- when buyer paid $3250 and order matched as $3200
        BEGIN
            set @pdiff = @buyrate - @ExecRate
            if @pdiff > 0
                BEGIN
                    set @refund_inQuoteCurr=round(@MatchedVolume*@pdiff,8,1);
                    IF @quote_curr_Fee_model = 'True'
                        set @refund_inQuoteCurr=round(@refund_inQuoteCurr+(@refund_inQuoteCurr *@service_chargeinQuoteCurr*.01),8,1)
                    INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoBaseCurrency+4),@Buy_BuyerID,@ExecDate,'Refund to Buyer(Taker) for Match Order#'+ + cast(@Match_Order_ID as nvarchar),round(@refund_inQuoteCurr,8,1),0,1)
                END
        END

    SET @Msg = cast(@MatchedVolume as nvarchar)+@Curr_Name+' @ '+cast(@ExecRate as nvarchar)+@Market_Name+' Matched Order#'+ cast(@Match_Order_ID as nvarchar)

    IF @Buyer_Pays_ET = 1 AND @Order_ServiceFee_buy_in_exch_token > 0
        BEGIN
            IF @quote_curr_Fee_model != 'True'
                SET @buyer_Credit = round(@MatchedVolume - (@Order_ServiceFee_buy - (@Order_ServiceFee_buy * @TDM_ETPay_Share)),8,1)
            IF @quote_curr_Fee_model = 'True'
                SET @buyer_Credit = @MatchedVolume

            INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoTradeCurrency+4),@Buy_BuyerID,@ExecDate,'Currency Swap for '+ @Curr_Name + '_'+ @Market_Name +' Buy Match Order#'+ + cast(@Match_Order_ID as nvarchar),round(@buyer_Credit,8,1),0,1)
            INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoExchCurrency+7),@Buy_BuyerID,@ExecDate,'Fee deducted in Exchange Token for Buy Match Order#'+ cast(@Match_Order_ID as nvarchar),0,round(@Order_ServiceFee_buy_in_exch_token,8,1),1)
        END
    ELSE
        BEGIN
            IF @quote_curr_Fee_model != 'True'
                SET @buyer_Credit = round(@MatchedVolume - @Order_ServiceFee_buy,8,1)
            ELSE
                SET @buyer_Credit = @MatchedVolume
            INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoTradeCurrency+4),@Buy_BuyerID,@ExecDate,'Currency Swap for '+ @Curr_Name + '_'+ @Market_Name +' Buy Match Order#'+ + cast(@Match_Order_ID as nvarchar),round(@buyer_Credit,8,1),0,1)
        END
    If @service_fee_buy_Refund > 0
        INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoBaseCurrency+4),@Buy_BuyerID,@ExecDate,'Fee Refund for Buy Match Order#'+ cast(@Match_Order_ID as nvarchar),round(@service_fee_buy_Refund,8,1),0,1)


    IF @Seller_Pays_ET = 1 AND @Order_ServiceFee_sell_in_exch_token > 0
        BEGIN
            -- seller pays in base currency and get less than what he saw at the time of order placement.. BTC= ex_BTC- fee-in-btc
            SET @Seller_Credit = round(@Order_Amount - (@Order_ServiceFee_sell - (@Order_ServiceFee_sell * @TDM_ETPay_Share)),8,1)
            INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoBaseCurrency+4),@Sell_SellerID,@ExecDate,'Currency Swap for '+ @Curr_Name + '_'+ @Market_Name +' Sell Match Order#'+ + cast(@Match_Order_ID as nvarchar),round(@Seller_Credit,8,1),0,1)
            INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoExchCurrency+7),@Sell_SellerID,@ExecDate,'Fee deducted in Exchange Token for Sell Match Order#'+ cast(@Match_Order_ID as nvarchar),0,round(@Order_ServiceFee_sell_in_exch_token,8,1),1)

        END
    ELSE
        BEGIN
            SET @Seller_Credit = round(@Order_Amount - @Order_ServiceFee_sell,8,1)
            INSERT INTO dbo.AccountMaster (TxnType,MemberID,DateOfTransaction,Particulars,Credit,Debit,[Status]) values((@MinTxnNoBaseCurrency+4),@Sell_SellerID,@ExecDate,'Currency Swap for '+ @Curr_Name + '_'+ @Market_Name +' Sell Match Order#'+ + cast(@Match_Order_ID as nvarchar),round(@Seller_Credit,8,1),0,1)
        END


    SET @result = 'Success'
    BEGIN TRY

        declare @PreviousTradingPrice decimal(20,10)=0, @ChangeInPrice decimal(20,10)=0, @Last24HrsLow decimal(20,10), @Last24HrsHigh decimal(20,10)
        select @PreviousTradingPrice = PreviousTradingPrice, @Last24HrsLow= Last24HrsLow, @Last24HrsHigh = Last24HrsHigh from dbo.tbl_Market where CoinName=@curr_name and MarketName=@Market_Name
        IF @PreviousTradingPrice IS NULL or @PreviousTradingPrice = 0
            set @ChangeInPrice = 100
        ELSE
            set @ChangeInPrice =round((((@ExecRate - isNull(@PreviousTradingPrice,0)) / (@PreviousTradingPrice))*100),8,1)

        IF @Last24HrsLow > @ExecRate
            set @Last24HrsLow = @ExecRate

        IF @Last24HrsHigh < @ExecRate
            set @Last24HrsHigh = @ExecRate

        update dbo.tbl_Market set ChangeInPrice=@ChangeInPrice, CurrentTradingPrice=@ExecRate,TotalVolume=(TotalVolume+@MatchedVolume),TotalVolumeBaseCurrency=round((TotalVolumeBaseCurrency+(@MatchedVolume*@ExecRate)),8,1) , Last24HrsLow= @Last24HrsLow, Last24HrsHigh=@Last24HrsHigh where CoinName=@curr_name and MarketName=@Market_Name

    END TRY
    Begin Catch
        SET @err_msg = ERROR_MESSAGE()+' In Line :'+ cast( ERROR_Line() as nvarchar)+'=='+@result;
        --print @err_msg
        --exec sp_LogException 'sp_MatchMyBuyOrder', @err_msg
    END Catch

END
GO
/****** Object:  StoredProcedure [dbo].[FixUpMatrixMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[FixUpMatrixMaster]
    -- Add the parameters for the stored procedure here

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    DECLARE @UserCode bigint, @SPID bigint
    update tbl_Customer set teamreferral = 0
    truncate table tblMatrixMaster
    DECLARE curMain CURSOR
        FOR SELECT CID from tbl_Customer with (nolock) order by DOJ
    OPEN curMain
    FETCH NEXT FROM curMain INTO @UserCode
    WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SPID = dbo.MySponsor(@UserCode)
            EXEC [dbo].[CreateMatrix] @UserCode, @SPID

            FETCH NEXT FROM curMain INTO @UserCode
        END
    CLOSE curMain;
    DEALLOCATE curMain;
END
GO
/****** Object:  StoredProcedure [dbo].[FixUpReferralCommission_Fee]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FixUpReferralCommission_Fee]
@redo bit = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE  @Order_ServiceFee_buy decimal(18,8),@Order_ServiceFee_sell decimal(18,8),@Buy_BuyerID BIGINT, @Sell_SellerID BIGINT, @ExecDate DATETIME, @MinTxnNoBaseCurrency int, @MinTxnNoTradeCurrency int, @Match_Order_ID bigint, @CurrencyType nvarchar(5),@MarketType nvarchar(5),@ExecutionType nvarchar(5), @Has_Buyer_paid_in_Exchage_token BIT,@Has_Seller_paid_in_Exchage_token BIT, @Exchange_Token nvarchar(5),@MinTxnNoExchCurrency int,
        @service_fee_buy_ex_token decimal(18,8),@service_fee_sell_ex_token decimal(18,8),
        @QuoteCurr_Fee_Model nvarchar(5), @QuoteCurr_ex_token_MarketPrice decimal(18,8)=0, @lastOrderID bigint



    IF @redo = 1
        BEGIN
            delete from AccountMaster where TxnType % 10 = 8 and Debit = 0
            delete from AccountMaster where TxnType % 10 = 7 and Debit = 0
            delete from tbl_ReferralComissions

            update AdminLogin set LastMatchedID = 0
        END

    select @lastOrderID = LastMatchedID from AdminLogin

    select @Exchange_Token = SettingValue from tbl_Settings with (nolock) where SettingName = 'Exchange_Token'
    select @QuoteCurr_Fee_Model = SettingValue from tbl_Settings with (nolock) where SettingName = 'Fee_In_Quote_Currency'

    SET @MinTxnNoExchCurrency = -10
    select @MinTxnNoExchCurrency=TransactionTypeMin from [tbl_CurrencyPrefrences] with(nolock) where CurrencyShortName=@Exchange_Token



    DECLARE product_cursor CURSOR FOR
        select Buyer_Brokerage,Seller_Brokerage,BuyerID,SellerID,OrderConfirmDate,
               (select TransactionTypeMin from tbl_CurrencyPrefrences where CurrencyShortName = CurrencyType),
               (select TransactionTypeMin from tbl_CurrencyPrefrences where CurrencyShortName = MarketType),OrderID,CurrencyType,MarketType,ExecutionType,
               Buyer_SGST, -- @Has_Buyer_paid_in_Exchage_token
               Seller_SGST, -- @Has_seller_paid_in_Exchage_token
               Buyer_CGST, --@Order_ServiceFee_buy_in_exch_token
               Seller_CGST --@Order_ServiceFee_sell_in_exch_token

        from tbl_MatchedOrder where OrderID > @lastOrderID order by OrderID
    --UNION
    --select Buyer_Brokerage,Seller_Brokerage,BuyerID,SellerID,OrderConfirmDate,(select TransactionTypeMin from tbl_CurrencyPrefrences where CurrencyShortName = CurrencyType),(select TransactionTypeMin from tbl_CurrencyPrefrences where CurrencyShortName = MarketType),OrderID,CurrencyType,MarketType,ExecutionType, case when Buyer_TotalAmount = Volume then 1 else 0 end, case when Seller_TotalAmount = Amount then 1 else 0 end from tbl_MatchedOrder_Archive order by OrderID


    OPEN product_cursor
    FETCH NEXT FROM product_cursor INTO  @Order_ServiceFee_buy,@Order_ServiceFee_sell,@Buy_BuyerID, @Sell_SellerID, @ExecDate,@MinTxnNoTradeCurrency, @MinTxnNoBaseCurrency , @Match_Order_ID,
        @CurrencyType,@MarketType,@ExecutionType, @Has_Buyer_paid_in_Exchage_token, @Has_Seller_paid_in_Exchage_token,@service_fee_buy_ex_token, @service_fee_sell_ex_token

    WHILE @@FETCH_STATUS = 0
        BEGIN



            EXEC dbo.[Exchange_Insert_Referral] @Order_ServiceFee_buy,@Order_ServiceFee_sell,@Buy_BuyerID, @Sell_SellerID, @ExecDate, @MinTxnNoBaseCurrency, @MinTxnNoTradeCurrency,
                 @Match_Order_ID  , @CurrencyType,@MarketType,@ExecutionType, @Has_Buyer_paid_in_Exchage_token, @Has_Seller_paid_in_Exchage_token,@service_fee_buy_ex_token,@service_fee_sell_ex_token,@MinTxnNoExchCurrency,@Exchange_Token,0,@QuoteCurr_Fee_Model
            set @lastOrderID = @Match_Order_ID
            FETCH NEXT FROM product_cursor INTO  @Order_ServiceFee_buy,@Order_ServiceFee_sell,@Buy_BuyerID, @Sell_SellerID, @ExecDate,@MinTxnNoTradeCurrency, @MinTxnNoBaseCurrency ,
                @Match_Order_ID  , @CurrencyType,@MarketType,@ExecutionType , @Has_Buyer_paid_in_Exchage_token, @Has_Seller_paid_in_Exchage_token, @service_fee_buy_ex_token, @service_fee_sell_ex_token

        END

    CLOSE product_cursor
    DEALLOCATE product_cursor

    update AdminLogin set LastMatchedID = @lastOrderID


END
GO
/****** Object:  StoredProcedure [dbo].[GoPro__DataArchive]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc  [dbo].[GoPro__DataArchive]

as begin

    drop table iF exists a_good_matched_orders

    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tbl_BuyOrder_Archive')
        BEGIN
            select top(1) * into tbl_BuyOrder_Archive from tbl_BuyOrder
            delete from tbl_BuyOrder_Archive
        END
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tbl_SellOrder_Archive')
        BEGIN
            select top(1) * into tbl_SellOrder_Archive from tbl_SellOrder
            delete from tbl_SellOrder_Archive
        END


    select *  into a_good_matched_orders from (
                                                  select OrderID,BuyOrderID BotOrderID, 'Buy' Side,Volume,Rate,Buyer_TotalAmount TotalAmount,BuyerID CustomerID,OrderConfirmDate,MarketType,CurrencyType from tbl_MatchedOrder
                                                  UNION
                                                  select OrderID,SellOrderID BotOrderID, 'Sell' Side,Volume,Rate,Seller_TotalAmount TotalAmount,SellerID CustomerID,OrderConfirmDate,MarketType,CurrencyType  from tbl_MatchedOrder
                                              ) tAbA

    insert into tbl_BuyOrder_Archive
    select * from tbl_BuyOrder where orderid not in (select BotOrderID from a_good_matched_orders) and OrderStatus=1

    insert into tbl_SellOrder_Archive
    select * from tbl_SellOrder where orderid not in (select BotOrderID from a_good_matched_orders) and OrderStatus=1

    delete from tbl_BuyOrder where orderid not in (select BotOrderID from a_good_matched_orders) and OrderStatus=1
    delete from tbl_SellOrder where orderid not in (select BotOrderID from a_good_matched_orders) and OrderStatus=1

    delete from tbl_CancelledOrders where OrderID not in (Select orderid from tbl_BuyOrder)
    delete from tbl_CancelledOrders where OrderID not in (Select orderid from tbl_SellOrder)





    print '[tbl_NotificationMaster]'
    truncate table tbl_NotificationMaster

    print '[tbl_ResetLink]'
    delete from  [dbo].[tbl_ResetLink] where isused=1 or RequestTime< dateadd(MINUTE,-10,getutcdate())
--Commit Tran DataArchive 
    select 'Success' as Result

end
GO
/****** Object:  StoredProcedure [dbo].[GoPro_Archive_AccountMaster]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE        proc [dbo].[GoPro_Archive_AccountMaster]
As
BEGIN
    --Begin Try
    --    Begin Tran sp_Archive_AccountMaster
    set Nocount on
    IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'AccountMaster_Archive')
        BEGIN
            CREATE TABLE [dbo].[AccountMaster_Archive](
                                                          [TxnID] [bigint] NOT NULL,
                                                          [TxnType] [bigint] NOT NULL,
                                                          [MemberID] [bigint] NOT NULL,
                                                          [DateofTransaction] [datetime] NOT NULL,
                                                          [Particulars] [nvarchar](350) NOT NULL,
                                                          [Credit] [decimal](18, 8) NOT NULL,
                                                          [Debit] [decimal](18, 8) NOT NULL,
                                                          [Status] [bit] NOT NULL,
                                                          CONSTRAINT [PK_AccountMaster_Archive] PRIMARY KEY CLUSTERED
                                                              (
                                                               [TxnID] ASC
                                                                  )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]

        END
    Declare @CurrentTime datetime= getutcdate()


    Select txnid,TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status] into #to_archive from [AccountMaster] where Particulars not like '%Carry Forwarded%'
                                                                                                                              and (TxnType % 10 = 2  or TxnType % 10 = 5) order by txnid

    insert into [AccountMaster_Archive] (TxnID,TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status])
    select TxnID,TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status] from #to_archive

    drop table if exists Temp_AccountMaster
    Select  MemberID,TxnType, Sum(isNull(Credit,0)) as Credit ,Sum(isNull(DEBIT,0)) as Debit  into Temp_AccountMaster from AccountMaster_Archive
    where (TxnType % 10 = 2  or TxnType % 10 = 5) group by MemberID,TxnType order by  MemberID,TxnType


    delete from  [AccountMaster] where txnid in (select txnid from #to_Archive)
    delete from AccountMaster where Particulars  like '%Carry Forwarded%'

    DECLARE   @MemberID bigint, @TxnType bigint,@Credit decimal(38,8),@Debit decimal(38,8)


    DECLARE cur CURSOR
        FOR
        SELECT * from Temp_AccountMaster order by Credit, Debit
    OPEN cur
    FETCH NEXT FROM cur INTO @MemberID,@TxnType,@Credit,@Debit
    WHILE @@FETCH_STATUS = 0
        BEGIN
            print cast(@memberid as nvarchar) + ' ' + cast(@txntype as nvarchar)+ ' cr:'+ cast(@credit as nvarchar)  + ' dr:' + cast(@debit as nvarchar)

            if @Credit>1000000000
                BEGIN
                    print 'credit big'
                    declare @bal decimal(18,8)
                    set @bal = @credit - @debit
                    if @bal > 0
                        insert into [AccountMaster] (TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status]) values (@TxnType,@MemberID,@CurrentTime,'Carry Forwarded Credit On : '+cast(@CurrentTime as nvarchar),@bal,0,1)
                END
            else IF @Credit>0
                insert into [AccountMaster] (TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status]) values (@TxnType,@MemberID,@CurrentTime,'Carry Forwarded Credit On : '+cast(@CurrentTime as nvarchar),@Credit,0,1)


            if @Debit>1000000000
                BEGIN

                    print 'debit big'
                    declare @baldr decimal(18,8)
                    set @baldr = @debit - @Credit
                    if @baldr > 0
                        insert into [AccountMaster] (TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status]) values (@TxnType,@MemberID,@CurrentTime,'Carry Forwarded Credit On : '+cast(@CurrentTime as nvarchar),0,@baldr,1)
                END
            else if @Debit>0
                insert into [AccountMaster] (TxnType,MemberID,DateofTransaction,Particulars,Credit,Debit,[Status]) values (@TxnType,@MemberID,@CurrentTime,'Carry Forwarded Debit On : '+cast(@CurrentTime as nvarchar),0,@Debit,1)

            FETCH NEXT FROM cur INTO @MemberID,@TxnType,@Credit,@Debit
        END
    CLOSE cur;
    DEALLOCATE cur;
    select 'Success' as Result


END

GO
/****** Object:  StoredProcedure [dbo].[GoPro_FindAllProcHavingKeyWord]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create Proc [dbo].[GoPro_FindAllProcHavingKeyWord]
@Name nvarchar(max)
as
Begin

    SELECT DISTINCT
        o.name AS Object_Name,
        o.type_desc
    FROM sys.sql_modules m
             INNER JOIN
         sys.objects o
         ON m.object_id = o.object_id
    WHERE m.definition Like '%'+@Name+'%';

End
GO

/****** Object:  StoredProcedure [dbo].[sp_CalcTradeDiscount]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE   proc [dbo].[sp_CalcTradeDiscount]

AS
--     Begin
--
-- 	set Nocount on
-- 	DECLARE   @GroupName nvarchar(10)='TD'
-- 	DECLARE   @CurrentTime date=getUTCDATE()
-- 	DECLARE   @Time_30DaysEarlier date= dateadd(dd,-30,@CurrentTime)
-- 	DECLARE   @CP bigint
-- 	DECLARE   @tbl_Response Table(CP bigint,Currency nvarchar(5),TradeAmount  decimal(18,8),DiscountPC   decimal(5,3))
--
-- 	truncate table tbl_Trade_Volume_Stats
-- 	delete from tbl_FeeUserGroups where GroupTitle=@GroupName
-- 	select * into #Temp_Market from tbl_Market
--
-- 	DECLARE cur CURSOR
-- 	FOR
-- 	select * from (select distinct SellerID as CP from tbl_MatchedOrder where OrderConfirmDate>@Time_30DaysEarlier union select distinct BuyerID as CP from tbl_MatchedOrder  where OrderConfirmDate>@Time_30DaysEarlier ) tt  --where tt.CP not in (select CID from tbl_Bots)
-- 	OPEN cur
-- 	FETCH NEXT FROM cur INTO @CP
-- 	WHILE @@FETCH_STATUS = 0
-- 	BEGIN
-- 	print '@CP : ' +cast(@CP as nvarchar)
--
-- 			DECLARE   @CurrencyForDiscount nvarchar(5)
-- 			DECLARE cur_btw CURSOR
-- 			FOR
-- 			 select distinct Currency  from tbl_FeeDiscount_VolumeBased where IsDeleted=0
-- 			OPEN cur_btw
-- 			FETCH NEXT FROM cur_btw INTO @CurrencyForDiscount
-- 			WHILE @@FETCH_STATUS = 0
-- 			BEGIN
-- 				print '@CurrencyForDiscount : ' +cast(@CurrencyForDiscount as nvarchar)
-- 				DECLARE   @TotalTrade decimal(18,8) =0
--
-- 						DECLARE   @TradeAmount decimal(18,8) =0
-- 						DECLARE   @Market nvarchar(5)
-- 						DECLARE cur_inner CURSOR
-- 						FOR
-- 						select  sum(Amount),MarketType from tbl_MatchedOrder  where (BuyerID=@CP or SellerID=@CP) and OrderConfirmDate>@Time_30DaysEarlier  group by MarketType   HAVING cast((Sum(Amount)) as decimal(18,8))>0
-- 						OPEN cur_inner
-- 						FETCH NEXT FROM cur_inner INTO @TradeAmount,@Market
-- 						WHILE @@FETCH_STATUS = 0
-- 						BEGIN
-- 							DECLARE   @CurrentPrice decimal(18,8) =0
-- 							if(@Market=@CurrencyForDiscount)
-- 								set @CurrentPrice=1
-- 							else
-- 								select @CurrentPrice=CurrentTradingPrice from  #Temp_Market where MarketName=@CurrencyForDiscount  and CoinName=@Market
--
-- 							if(@CurrentPrice=0)
-- 									select @CurrentPrice=(1/CurrentTradingPrice)  from  #Temp_Market where MarketName=@Market   and CoinName=@CurrencyForDiscount and CurrentTradingPrice>0
--
-- 							 set  @TotalTrade=@TotalTrade+(@TradeAmount*@CurrentPrice)
--
-- 							FETCH NEXT FROM cur_inner INTO @TradeAmount,@Market
-- 						END
-- 						CLOSE cur_inner;
-- 						DEALLOCATE cur_inner;
--
--
-- 				print '@TotalTrade : ' +cast(@TotalTrade as nvarchar)+' '+cast(@CurrencyForDiscount as nvarchar)
--
-- 				DECLARE @Discount decimal(5,2) =0
-- 				DECLARE @Limit decimal(18,8) =0
--
-- 				select top 1 @Discount=discount,@Limit=limit from tbl_FeeDiscount_VolumeBased where  currency=@CurrencyForDiscount and IsDeleted=0 and limit<=@TotalTrade order by limit desc ,discount
-- 				if(@Discount>0)
-- 				BEGIN
-- 					--insert into @tbl_Response select @CP,@CurrencyForDiscount,@TotalTrade,@Discount
-- 					insert into tbl_FeeUserGroups(GroupTitle,CID,FeePerc,isDeleted,AddedOn) values(@GroupName,@CP,@Discount,0,@CurrentTime)
--
-- 					insert into tbl_Trade_Volume_Stats (CID,Currency,TradedVolume,TradedVolumeLimit,Discount) values(@CP,@CurrencyForDiscount,@TotalTrade,@Limit,@Discount)
-- 				END
--
-- 			FETCH NEXT FROM cur_btw INTO @CurrencyForDiscount
-- 			END
-- 			CLOSE cur_btw;
-- 			DEALLOCATE cur_btw;
--
--
-- 	FETCH NEXT FROM cur INTO @CP
-- 	END
-- 	CLOSE cur;
-- 	DEALLOCATE cur;
-- 	select 'Success'
--select * from @tbl_Response order by CP 
-- End
GO

/****** Object:  StoredProcedure [dbo].[sp_CalcTradeDiscountV2]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [dbo].[sp_CalcTradeDiscountV2]

AS
-- BEGIN
-- set nocount on
-- DECLARE @DOJ datetime, @SpecificDate datetime,@Exist int,@ExchangeToken nvarchar(10),@Timeperiod int,@TotalAmount decimal(18,8)=0;
-- DECLARE @TargetVolType nvarchar(10), @GroupName nvarchar(20),@BonusToken decimal(18,2),@MinTXNType int,@TokenExist int=0;
-- DECLARE @StartingDate datetime
-- set @StartingDate=DATEADD(SECOND,-1,CAST(CAST(GETUTCDATE() as DATE)as DATETIME))
-- print @startingdate
--
-- select @ExchangeToken=SettingValue from [dbo].[tbl_Settings] with (nolock) where SettingName='Exchange_Token';
-- select @TokenExist=Count(*) from tbl_CurrencyPrefrences with (nolock) where CurrencyShortName=@ExchangeToken;
-- IF @TokenExist<1
-- return;
--
-- select @MinTXNType=TransactionTypeMin from tbl_CurrencyPrefrences with (nolock) where CurrencyShortName=@ExchangeToken;
--
--
-- Select @TokenExist=Count(*) FROM [dbo].[tbl_FeeDiscount_VolumeBased_VolumeBasedV2] with (nolock)
-- IF @TokenExist<1
-- return;
--
-- select top 1 @TargetVolType=TargetVolumeType from [dbo].[tbl_FeeDiscount_VolumeBased_VolumeBasedV2] with (nolock)
--
-- drop table if exists #V2Currency_prices
-- declare @Currency nvarchar(5), @CurrentPrice decimal(20,10);
-- create table #V2Currency_prices (curr nvarchar(5), btc_price decimal(20,10))
-- DECLARE cur_btw CURSOR FOR select   CurrencyShortName  from tbl_CurrencyPrefrences with (nolock)
-- OPEN cur_btw
-- FETCH NEXT FROM cur_btw INTO @Currency
-- WHILE @@FETCH_STATUS = 0
-- BEGIN
-- 	SET @CurrentPrice = 0
-- 	if(@Currency=@TargetVolType)
-- 		set @CurrentPrice=1
-- 	else
-- 		select @CurrentPrice=CurrentTradingPrice from tbl_market where MarketName=@TargetVolType  and CoinName=@Currency
--
-- 	if(@CurrentPrice=0)
-- 		select @CurrentPrice=(1/CurrentTradingPrice)  from  tbl_market where MarketName=@Currency and CoinName=@TargetVolType and CurrentTradingPrice>0
-- 	insert into #V2Currency_prices VALUES (@Currency, @CurrentPrice)
-- 	FETCH NEXT FROM cur_btw INTO @Currency
-- END
-- CLOSE cur_btw
-- DEALLOCATE cur_btw
--
--
-- DECLARE @TargetVol decimal(18,2),@V2id bigint
-- DECLARE contact_cursor CURSOR FOR
-- SELECT TimePeriod_Days,TargetVolume,Id,BonusTokens,GroupName FROM [dbo].[tbl_FeeDiscount_VolumeBased_VolumeBasedV2] with (nolock)
--
-- OPEN contact_cursor;
--
-- -- Perform the first fetch.
-- FETCH NEXT FROM contact_cursor
-- INTO @Timeperiod,@TargetVol,@V2id,@BonusToken,@GroupName;
--
-- WHILE @@FETCH_STATUS = 0
-- BEGIN
-- 	declare @fmt datetime
--
-- 	if @Timeperiod >= 99999
-- 		set @fmt = '2019-01-01'
-- 	else
-- 		set @fmt = DateADD(dd,-@Timeperiod,@StartingDate)
--
-- 	DECLARE @UserID bigint
-- 	DECLARE cur_cid CURSOR FOR SELECT distinct CID,DOJ from tbl_Customer with (nolock) where DOJ>=@fmt and cid in (select cid from tbl_Customers_FieldValues where fieldid=6 and fieldValue = @GroupName)
-- 	OPEN cur_cid
-- 	FETCH NEXT FROM cur_cid INTO @UserID ,@DOJ
-- 	WHILE @@FETCH_STATUS = 0
-- 	BEGIN
-- 		set @TotalAmount=0
-- 		set @Exist = 0
--
-- 		select @Exist=count(*) from [dbo].[tbl_FeeDiscountEligibility]  where Cid=@UserID and V2ID=@V2id
-- 		if @userid = 231378
-- 			print cast( @userid as nvarchar) + ' --> ' + cast(@v2id as nvarchar) + ' --> ' + cast(@exist as nvarchar)
-- 		IF @Exist>0
-- 		BEGIN
-- 			print 'Continue'
-- 			FETCH NEXT FROM cur_cid INTO @UserID ,@DOJ;
-- 		END
-- 		IF @Timeperiod >=99999
-- 			SET @SpecificDate = '2019-01-01'
-- 		ELSE
-- 			SET @SpecificDate=DateADD(dd,-@Timeperiod,@StartingDate)
--
-- 		IF @SpecificDate<@StartingDate
-- 		BEGIN
-- 			DECLARE @MarketType nvarchar(5),@Amount DECIMAL(18,8),@PriceInBTC DECIMAL(18,8)
-- 			DECLARE contact_cursor2 CURSOR FOR
-- 			SELECT MarketType,SUM(Amount) Amount FROM tbl_MatchedOrder with (nolock) WHERE (SellerID=@UserID or BuyerID=@UserID) and OrderConfirmDate>=@SpecificDate and OrderConfirmDate<=@StartingDate GROUP BY MarketType
-- 			OPEN contact_cursor2;
--
-- 				FETCH NEXT FROM contact_cursor2
-- 				INTO @MarketType,@Amount;
-- 				WHILE @@FETCH_STATUS = 0
-- 				BEGIN
-- 					select @PriceInBTC=btc_price from #V2Currency_prices where curr=@MarketType
-- 					set @TotalAmount+=(@PriceInBTC*@Amount);
-- 					FETCH NEXT FROM contact_cursor2
-- 					INTO @MarketType,@Amount;
-- 				END
--
-- 				CLOSE contact_cursor2;
-- 				DEALLOCATE contact_cursor2;
-- 			END
--
-- 		IF @TotalAmount > 0
-- 		BEGIN
-- 			delete from tbl_Trade_Volume_Stats where cid  = @UserID
-- 			insert into tbl_Trade_Volume_Stats (CID,Currency,TradedVolume,TradedVolumeLimit,Discount) values(@UserID,'BTC',@TotalAmount,0,0)
-- 		END
-- 		IF @TargetVol<=ROUND(@TotalAmount,2)
-- 		BEGIN
-- 			INSERT INTO [dbo].[tbl_FeeDiscountEligibility](Cid,EntryDate,V2ID) Values(@UserID,GETUTCDATE(),@V2id);
-- 			Insert Into [dbo].[AccountMaster](TxnType,MemberID,DateofTransaction,[Status],Credit,Debit,Particulars) Values(@MinTXNType+9,@UserID,GETUTCDATE(),1,@BonusToken,0,CONCAT(@GroupName,' ',@TargetVol,'BTC Target Achieved'));
-- 		END
--
-- 	FETCH NEXT FROM cur_cid INTO @UserID ,@DOJ
-- 	END
-- CLOSE cur_cid
-- DEALLOCATE cur_cid
--
-- 	FETCH NEXT FROM contact_cursor
-- INTO @Timeperiod,@TargetVol,@V2id,@BonusToken,@GroupName;
-- END
--
-- CLOSE contact_cursor;
-- DEALLOCATE contact_cursor;
--
-- return;
--
-- END
GO


/****** Object:  StoredProcedure [dbo].[Sp_Delete_Currency_ByName]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[Sp_Delete_Currency_ByName] --'USD'
@CurrName nvarchar(5)
as
begin


    Begin Try
        --select top 1 * from  [dbo].[tbl_CurrencyPrefrences]


        Declare @MinTxnType int=-1;

        select @MinTxnType=TransactionTypeMin from  [dbo].[tbl_CurrencyPrefrences]  where CurrencyShortName=@CurrName
        if(@MinTxnType<0)
            BEGIN
                select 'Currency Not Found'
                return
            END


        SET TRANSACTION ISOLATION LEVEL Read Committed
        BEGIN TRANSACTION

            print 'Deleting from tbl_matchedorder'
            delete from tbl_matchedorder where CurrencyType=@CurrName or MarketType=@CurrName
            print 'Deleting from tbl_sellorder'
            delete from tbl_sellorder where CurrencyType=@CurrName or MarketType=@CurrName
            print 'Deleting from tbl_buyorder'
            delete from tbl_buyorder where CurrencyType=@CurrName or MarketType=@CurrName
            print 'Deleting from [NotificationMaster]'
            delete from [tbl_NotificationMaster] where mSG like '%'+@CurrName+'%'

            print 'Deleting from [tbl_AddressMaster]'
            delete from [dbo].[tbl_AddressMaster] where CurrencyShortName=@CurrName


            print 'Deleting from [AccountMaster]'
            delete from [dbo].[AccountMaster] where  TxnType between @MinTxnType and @MinTxnType+9


            print 'Deleting from [tbl_Deposit]'
            delete from [tbl_Deposit] where DepositType=@CurrName
            print 'Deleting from [tbl_LoginManager]'
            delete from [tbl_LoginManager] where LastTrade=@CurrName or LastMarket=@CurrName

            print 'Deleting from [tbl_Withdrawal]'
            delete from [tbl_Withdrawal] where WithdrawalType=@CurrName
            print 'Deleting from [tbl_Market]'
            delete from [dbo].[tbl_Market] where CoinNAme=@CurrName or MarketName=@CurrName
            print 'Deleting from [tbl_CurrencyPrefrences]'
            delete from [dbo].[tbl_CurrencyPrefrences] where CurrencyShortNAme=@CurrName
        COMMIT TRANSACTION
        select 'Success' as Result
    END TRY
    Begin CATCH
        if @@TRANCOUNT>0
            ROLLBACK TRANSACTION
        DECLARE @err_msg AS NVARCHAR(250);
        SET @err_msg = ERROR_MESSAGE();
        select @err_msg as Result
    End CATCH

end
GO
/****** Object:  StoredProcedure [dbo].[sp_GetAllUsersBalance]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE     proc [dbo].[sp_GetAllUsersBalance]  --332424,'ALL'
    @CID bigint=0,
    @CurrencyShortName nvarchar(5)='BTC'
as
Begin
    set Nocount on
    DECLARE  @CurrMinTxn bigint, @CoinWalletType  nvarchar(50)



    select TxnType,Memberid,Sum(cast(Credit as decimal(25,10))) as Credit,Sum(cast(Debit as decimal(25,10))) as Debit into #AccountMaster_Grouped from AccountMaster where (MemberID=@CID or @CID=0)   group by TxnType,Memberid

    select * into #tbl_SellOrder from tbl_SellOrder where OrderStatus=0
    select * into #tbl_BuyOrder from tbl_BuyOrder where OrderStatus=0
    SELECT distinct MemberID into #memberList from #AccountMaster_Grouped

    if not exists ( select 1 from  #memberList where MemberID=@CID) and @CID!=0
        insert into #memberList select @CID

    Declare @Output_Table table(CID bigint,CurrencyName nvarchar(10),TotalDeposits decimal(25,10), TotalWithdrawals decimal(25,10),Balance decimal(25,10),BalanceInTrade decimal(25,10))
    --create nonclustered index TxnType on #AccountMaster_Grouped (TxnType)

    DECLARE cur_outer CURSOR
        FOR
        SELECT TransactionTypeMin,CurrencyShortName,CoinWalletType from tbl_CurrencyPrefrences where (CurrencyShortName = @CurrencyShortName OR @CurrencyShortName = 'ALL')
    OPEN cur_outer
    FETCH NEXT FROM cur_outer INTO @CurrMinTxn,@CurrencyShortName,@CoinWalletType
    WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE cur_inner CURSOR
                FOR
                select memberId from #memberList
            OPEN cur_inner
            FETCH NEXT FROM cur_inner INTO @CID
            WHILE @@FETCH_STATUS = 0
                BEGIN

                    Declare @Bal  decimal(25,10)=0 , @BalInTrade  decimal(25,10)=0 , @BalInTrade_Buy  decimal(25,10)=0 , @BalInTrade_Sell  decimal(25,10)=0 , @deposits  decimal(25,10)=0 , @withdrawals  decimal(25,10)=0

                    select @Bal=isNull(Sum(Credit),0) -isNull(Sum(Debit),0) from #AccountMaster_Grouped where MemberID=@CID and TxnType between @CurrMinTxn and @CurrMinTxn+9

                    select @deposits=isNull(Sum(Credit),0) -isNull(Sum(Debit),0) from #AccountMaster_Grouped where MemberID=@CID and TxnType = @CurrMinTxn
                    select @withdrawals=abs(isNull(Sum(debit),0) -isNull(Sum(Credit),0)) from #AccountMaster_Grouped where MemberID=@CID and TxnType = @CurrMinTxn+3


                    select @BalInTrade_Sell=SUM(cast(PendingVolume as decimal(25,10))) from #tbl_SellOrder where CurrencyType=@CurrencyShortName and  SellerID=@CID

                    select @BalInTrade_Buy=SUM(cast(PendingVolume as decimal(25,10)) * cast(Rate as decimal(25,10))) from #tbl_BuyOrder where  MarketType=@CurrencyShortName and BuyerID=@CID
                    set @BalInTrade_Sell = ISNULL(@BalInTrade_Sell,0)
                    set @BalInTrade_Buy = ISNULL(@BalInTrade_Buy,0)


                    IF(@CoinWalletType like 'Fiat-%')
                        BEGIN
                            set @Bal=round(@Bal, 2, 1)
                            set @BalInTrade_Buy=round(@BalInTrade_Buy, 2, 1)
                            set @BalInTrade_Sell=round(@BalInTrade_Sell, 2, 1)
                            set @deposits=round(@deposits, 2, 1)
                            set @withdrawals=round(@withdrawals, 2, 1)
                            set @BalInTrade=round(@BalInTrade_Buy+@BalInTrade_Sell, 2, 1)
                        END
                    ELSE
                        BEGIN
                            set @Bal=round(@Bal, 8, 1)
                            set @BalInTrade_Buy=round(@BalInTrade_Buy, 8, 1)
                            set @BalInTrade_Sell=round(@BalInTrade_Sell, 8, 1)
                            set @deposits=round(@deposits, 8, 1)
                            set @withdrawals=round(@withdrawals, 8, 1)
                            set @BalInTrade=round(@BalInTrade_Buy+@BalInTrade_Sell, 8, 1)
                        END
                    insert into @Output_Table(CID,CurrencyName,TotalDeposits,TotalWithdrawals,Balance,BalanceInTrade) values (@CID,@CurrencyShortName,@deposits,@withdrawals,@Bal,@BalInTrade)

                    FETCH NEXT FROM cur_inner INTO @CID
                END
            CLOSE cur_inner;
            DEALLOCATE cur_inner;

            FETCH NEXT FROM cur_outer INTO @CurrMinTxn,@CurrencyShortName,@CoinWalletType
        END
    CLOSE cur_outer;
    DEALLOCATE cur_outer;
    --drop table  #AccountMaster_Grouped

    select OTPT.CID,Email,FirstName,LastName,Country,CurrencyName,TotalDeposits,TotalWithdrawals,Balance,BalanceInTrade from  @Output_Table OTPT inner join tbl_Customer TC WITH (NOLOCK) On OTPT.CID=TC.CID order by Balance DESC,BalanceInTrade DESC, OTPT.CID ASC

End

--select * from tbl_CurrencyPrefrences
-- [dbo].[sp_GetAllUsersBalance]    332424,'ALL'

GO
/****** Object:  StoredProcedure [dbo].[sp_LogException]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create proc [dbo].[sp_LogException]

    @ProcName nvarchar(100),
    @Message nvarchar(250)
as begin
    set nocount on
    insert into tbl_ExceptionLog (ProcName,[Message]) values (@ProcName,@Message)

end
GO
/****** Object:  StoredProcedure [dbo].[Sp_UserTradingInfo]    Script Date: 1/10/2024 5:05:17 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[Sp_UserTradingInfo]
    @From  date,
    @To date

AS
BEGIN


    SET NOCOUNT ON

    BEGIN-- calculating ET Balance for all users
        drop table if exists #ET_Balances
        declare @ExchangeToken nvarchar(5)
        select @ExchangeToken=SettingValue from tbl_Settings with(nolock)  where SettingName='Exchange_Token'

        create table #ET_Balances(CID bigint, Email nvarchar(50), FirstName nvarchar(50), LastName nvarchar(50), country nvarchar(2), currencyName nvarchar(5), TotalDeposit decimal(20,10), totalwithdrawal decimal(20,10), Balance decimal(20,10), BalanceInTrade decimal(20,10))
        insert into #ET_Balances
            exec dbo.sp_GetAllUsersBalance 0,'BTSM'
--select * from #ET_Balances
    END

    BEGIN-- calculating BTC equivalent
        drop table if exists #BTC_prices
        declare @Currency nvarchar(5), @CurrentPrice decimal(20,10);
        create table #BTC_prices (curr nvarchar(5), btc_price decimal(20,10))
        DECLARE cur_btw CURSOR FOR select   CurrencyShortName  from tbl_CurrencyPrefrences
        OPEN cur_btw
        FETCH NEXT FROM cur_btw INTO @Currency
        WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @CurrentPrice = 0
                if(@Currency='BTC')
                    set @CurrentPrice=1
                else
                    select @CurrentPrice=CurrentTradingPrice from tbl_market where MarketName='BTC'  and CoinName=@Currency

                if(@CurrentPrice=0)
                    select @CurrentPrice=(1/CurrentTradingPrice)  from  tbl_market where MarketName=@Currency and CoinName='BTC' and CurrentTradingPrice>0
                insert into #BTC_prices VALUES (@Currency, @CurrentPrice)
                FETCH NEXT FROM cur_btw INTO @Currency
            END
        CLOSE cur_btw
        DEALLOCATE cur_btw
--select * from #BTC_prices
    END

    BEGIN-- calculating volume & order counts

        drop table if exists #BuyOrderCounts
        drop table if exists #SellOrderCounts
        create table #BuyOrderCounts(CID bigint, TotalBuyOrder bigint, totalBuyVolumeinBTC decimal(20,10))
        create table #SellOrderCounts(CID bigint, TotalSellOrder bigint, totalSellVolumeinBTC decimal(20,10))

        INSERT INTO #BuyOrderCounts(CID,TotalBuyOrder,totalBuyVolumeinBTC)
        select BuyerID AS CID, SUM(TotOrders) TotalBuyOrder, SUM(btc_vol) totalBuyVolumeinBTC  from (
                                                                                                        select BuyerID,count(1) TotOrders, SUM(Amount) * (select btc_price from #BTC_prices where curr = MarketType) btc_vol from tbl_MatchedOrder where OrderConfirmDate BETWEEN @From and @To group by BuyerID,MarketType) TAbA group by BuyerID

        INSERT INTO #SellOrderCounts(CID,TotalSellOrder,totalSellVolumeinBTC)
        select SellerID AS CID, SUM(TotOrders) TotalSellOrder, SUM(btc_vol) totalSellVolumeinBTC  from (
                                                                                                           select SellerID,count(1) TotOrders, SUM(Amount) * (select btc_price from #BTC_prices where curr = MarketType) btc_vol from tbl_MatchedOrder where OrderConfirmDate BETWEEN @From and @To group by SellerID,MarketType) TAbA group by SellerID

        --select * from #BuyOrderCounts;
--select * from #SellOrderCounts;
    END

    BEGIN-- caculating deposits & withdrwals
        drop table if exists #crypto_deposits
        create table #crypto_deposits (cid bigint, TotalCryptoDepositInBTC decimal(20,10))
        drop table if exists #crypto_withdrawals
        create table #crypto_withdrawals (cid bigint, TotalCryptoDepositInBTC decimal(20,10))
        drop table if exists #fiat_deposits
        create table #fiat_deposits (cid bigint, TotalCryptoDepositInBTC decimal(20,10))
        drop table if exists #fiat_withdrawals
        create table #fiat_withdrawals (cid bigint, TotalCryptoDepositInBTC decimal(20,10))

        insert into #crypto_deposits
        select CID, SUM(totalBTC) TotalCryptoDepositInBTC from (
                                                                   select sum(DepositAmount) TotalDeposit,DepositType,CID, sum(DepositAmount) * (select btc_price from #BTC_prices where curr = DepositType) totalBTC
                                                                   from tbl_Deposit where DepositStatus=1 and DepositConfirmDate BETWEEN @From and @To
                                                                   group by DepositType,CID ) TabA group by CID


        insert into #crypto_withdrawals
        select CID, SUM(totalBTC) TotalCryptoWithdrawalInBTC from (
                                                                      SELECT sum(WithdrawalAmount) TotalWithdraw,WithdrawalType,CID,  sum(WithdrawalAmount) * (select btc_price from #BTC_prices where curr = WithdrawalType) totalBTC
                                                                      from tbl_Withdrawal where WithdrawalStatus='Processed' and WithdrawalConfirmDate BETWEEN @From and @To
                                                                      group by  WithdrawalType,CID) TabA group by CID


        insert into #fiat_deposits
        select CID, SUM(totalBTC) TotalFiatDepositlInBTC from (
                                                                  select sum(tbl_Deposit.RequestAmount) totalfiatdeposit,tb.AccountCurrency, tbl_Deposit.CID,sum(tbl_Deposit.RequestAmount) * (select btc_price from #BTC_prices where curr = tb.AccountCurrency) totalBTC
                                                                  from  [dbo].[tbl_Fiat_BanksList] tb  inner join tbl_Fiat_Manual_Deposit_Requests tbl_Deposit on tbl_Deposit.BankID= tb.ID
                                                                  where  tbl_Deposit.[Status]='Approved' and tbl_Deposit.ApprovedDate BETWEEN @From and @To
                                                                  group by tb.AccountCurrency, tbl_Deposit.CID) TabA group by CID


        insert into #fiat_withdrawals
        select CID, SUM(totalBTC) TotalFiatDepositlInBTC from (
                                                                  select ISNULL(sum(RequestAmount),0) FiatWithdrawals,CurrencyName,CID,ISNULL(sum(RequestAmount),0) * (select btc_price from #BTC_prices where curr = CurrencyName)totalBTC
                                                                  from tbl_Fiat_Manual_Withdrawal_Requests
                                                                  where [Status]='Approved' and ApprovedDate BETWEEN @From and @To
                                                                  group by CurrencyName,CID) TabA group by CID
    END

    BEGIN-- calculating balances
        create table #userBalance(Cid bigint, Balance decimal(20,10), Curr nvarchar(5), BTC_Balance decimal(20,10))
        create table #AccMaster(Balance decimal(20,10),Cid bigint, txntype int)
        insert into #AccMaster
        select SUM(Credit)-SUM(Debit) Balance,memberid, txntype from accountmaster group by memberid, txntype
        declare @CurrencyShortName nvarchar(5), @CurrMinTxn int
        DECLARE cur_outer CURSOR FOR
            SELECT TransactionTypeMin,CurrencyShortName from tbl_CurrencyPrefrences
        OPEN cur_outer
        FETCH NEXT FROM cur_outer INTO @CurrMinTxn,@CurrencyShortName
        WHILE @@FETCH_STATUS = 0
            BEGIN

                insert into #userBalance
                select Cid,isNull(Sum(Balance),0),@CurrencyShortName, isNull(Sum(Balance),0) * (select btc_price from #BTC_prices where curr = @CurrencyShortName) from #AccMaster where TxnType between @CurrMinTxn and @CurrMinTxn+9 group by Cid

                FETCH NEXT FROM cur_outer INTO @CurrMinTxn,@CurrencyShortName
            END
        CLOSE cur_outer;
        DEALLOCATE cur_outer;
        drop table #AccMaster
        --select * from #userBalance
--drop table #userBalance
    END

    BEGIN--final-merge
        DECLARE   @tbl_Response Table(CID bigint,Email nvarchar(50),TotalTradeVol decimal(18,8),NoOfBuyOrders int,NoOfSellOrders int,NoOfAllOrders int,
                                      ExchangeTokenBalance decimal(18,8),TotalPortfolioBalance decimal(18,8),TotalCryptoDeposits decimal(18,8),TotalFiatDeposits decimal(18,8),
                                      TotalCryptoWithdrawals decimal(18,8),TotalFiatWithdrawals decimal(18,8))

        declare @cid bigint, @Email nvarchar(max)
        DECLARE cur CURSOR FAST_FORWARD FOR select CID,Email from  tbl_customer
        OPEN cur
        FETCH NEXT FROM cur INTO @CID, @Email
        WHILE @@FETCH_STATUS = 0
            BEGIN
                DECLARE   @NoOfBuyOrders  int=0, @totalBuyVolumeinBTC decimal(18,8)=0
                DECLARE   @NoOfSellOrders  int=0, @totalSellVolumeinBTC decimal(18,8)=0
                DECLARE   @TotalTradeVol decimal(18,8)=0
                DECLARE   @ExchangeTokenBalance decimal(18,8)=0
                DECLARE   @TotalPortfolioBalance decimal(18,8)=0
                DECLARE   @TotalCryptoDeposits decimal(18,8)=0
                DECLARE   @TotalFiatDeposits decimal(18,8)=0
                DECLARE   @TotalCryptoWithdrawals decimal(18,8)=0
                DECLARE   @TotalFiatWithdrawals decimal(18,8)=0

                select @ExchangeTokenBalance = ISNULL(Balance,0) from #ET_Balances where CID = @Cid
                select @NoOfBuyOrders = TotalBuyOrder, @totalBuyVolumeinBTC = ISNULL(totalBuyVolumeinBTC,0) from #BuyOrderCounts where CID = @Cid
                select @NoOfSellOrders = TotalSellOrder, @totalSellVolumeinBTC = ISNULL(totalSellVolumeinBTC,0) from #SellOrderCounts where CID = @Cid
                set @TotalTradeVol = @totalBuyVolumeinBTC + @totalSellVolumeinBTC

                select @TotalCryptoDeposits = ISNULL(TotalCryptoDepositInBTC,0) from #crypto_deposits where CID = @Cid
                select @TotalFiatDeposits = ISNULL(TotalCryptoDepositInBTC,0) from #fiat_deposits where CID = @Cid
                select @TotalCryptoWithdrawals = ISNULL(TotalCryptoDepositInBTC,0) from #crypto_withdrawals where CID = @Cid
                select @TotalFiatWithdrawals = ISNULL(TotalCryptoDepositInBTC,0) from #fiat_withdrawals where CID = @Cid

                SET @TotalPortfolioBalance = 0 -- not implemented
                select @TotalPortfolioBalance = ISNULL(SUM(BTC_Balance),0) from #userBalance where CID = @Cid

                insert into @tbl_Response(CID,Email,TotalTradeVol,NoOfBuyOrders ,NoOfSellOrders,NoOfAllOrders,ExchangeTokenBalance,TotalPortfolioBalance,TotalCryptoDeposits,TotalFiatDeposits,TotalCryptoWithdrawals,TotalFiatWithdrawals)
                values
                    (@CID,@Email,@TotalTradeVol,@NoOfBuyOrders,@NoOfSellOrders,@NoOfSellOrders+@NoOfBuyOrders,@ExchangeTokenBalance,@TotalPortfolioBalance,@TotalCryptoDeposits,@TotalFiatDeposits,@TotalCryptoWithdrawals,@TotalFiatWithdrawals)

                FETCH NEXT FROM cur INTO @CID,@Email
            END
        CLOSE cur;
        DEALLOCATE cur;
    END

    select * from @tbl_Response where TotalTradeVol!=0 or NoOfBuyOrders !=0 or NoOfSellOrders!=0 or NoOfAllOrders!=0 or ExchangeTokenBalance!=0 or TotalPortfolioBalance!=0 or TotalCryptoDeposits!=0 or TotalFiatDeposits!=0 or TotalCryptoWithdrawals!=0 or TotalFiatWithdrawals!=0

END
GO
USE [master]
GO
ALTER DATABASE [development] SET  READ_WRITE
GO

