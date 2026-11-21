CREATE SCHEMA Membership;   
GO
CREATE SCHEMA Logistics;    
GO
CREATE SCHEMA Catalog;     
GO
CREATE SCHEMA Sales;        
GO

--City


CREATE TABLE Membership.City
(
    CityId      INT IDENTITY(1,1) NOT NULL,
    Name        NVARCHAR(60)      NOT NULL,
    CountryCode CHAR(2)           NOT NULL,

    CONSTRAINT PK_City PRIMARY KEY (CityId),
    CONSTRAINT CK_City_CountryCode CHECK (CountryCode IN ('EG', 'SA', 'AE')),
    CONSTRAINT UQ_City_CountryCode_Name UNIQUE (CountryCode, Name)
);

--Wallet

CREATE TABLE Membership.Wallet
(
    MemberId   UNIQUEIDENTIFIER NOT NULL,
    Balance    DECIMAL(12,2)    NOT NULL
        CONSTRAINT DF_Wallet_Balance DEFAULT 0,
    HeldAmount DECIMAL(12,2)    NOT NULL
        CONSTRAINT DF_Wallet_HeldAmount DEFAULT 0,
    Currency   CHAR(3)          NOT NULL
        CONSTRAINT DF_Wallet_Currency DEFAULT 'EGP',
    UpdatedAt  DATETIME2(3)     NOT NULL
        CONSTRAINT DF_Wallet_UpdatedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_Wallet PRIMARY KEY (MemberId),
    CONSTRAINT CK_Wallet_Balance CHECK (Balance >= 0),
    CONSTRAINT CK_Wallet_HeldAmount CHECK (HeldAmount >= 0),
    CONSTRAINT CK_Wallet_Held_Within_Balance CHECK (HeldAmount <= Balance)
);


--Member
CREATE TABLE Membership.Member
(
    MemberId          UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT DF_Member_MemberId DEFAULT NEWID(),
    FullName          NVARCHAR(100)    NOT NULL,
    Email             VARCHAR(254)     NOT NULL,
    Mobile            VARCHAR(16)      NOT NULL,
    NationalId        VARCHAR(20)      NOT NULL,
    BirthDate         DATE             NOT NULL,
    IsVerified        BIT              NOT NULL
        CONSTRAINT DF_Member_IsVerified DEFAULT 0,
    RegisteredAt      DATETIME2(3)     NOT NULL
        CONSTRAINT DF_Member_RegisteredAt DEFAULT SYSUTCDATETIME(),
    CityId            INT              NOT NULL,
    InvitedByMemberId UNIQUEIDENTIFIER NULL,

    CONSTRAINT PK_Member PRIMARY KEY (MemberId),
    CONSTRAINT UQ_Member_Email UNIQUE (Email),
    CONSTRAINT UQ_Member_NationalId UNIQUE (NationalId),
    CONSTRAINT CK_Member_NationalId
        CHECK (NationalId NOT LIKE '%[^A-Za-z0-9]%'),
    CONSTRAINT CK_Member_Mobile
        CHECK (Mobile LIKE '+%' AND Mobile NOT LIKE '%[^0-9+]%'),
    CONSTRAINT CK_Member_BirthDate_18Plus
        CHECK (BirthDate <= DATEADD(YEAR, -18, CAST(SYSDATETIME() AS DATE))),
    CONSTRAINT CK_Member_NotInvitedBySelf
        CHECK (InvitedByMemberId IS NULL OR InvitedByMemberId <> MemberId)
);


--Warehouse
CREATE TABLE Logistics.Warehouse
(
    WarehouseId  INT IDENTITY(1,1) NOT NULL,
    Name         NVARCHAR(80)      NOT NULL,
    Capacity     INT               NOT NULL,
    CityId       INT               NOT NULL,
    Latitude     FLOAT             NOT NULL,
    Longitude    FLOAT             NOT NULL,
    ManagerId    UNIQUEIDENTIFIER  NULL,
    ManagerSince DATE              NULL,

    CONSTRAINT PK_Warehouse PRIMARY KEY (WarehouseId),
    CONSTRAINT UQ_Warehouse_Name UNIQUE (Name),
    CONSTRAINT UQ_Warehouse_ManagerId UNIQUE (ManagerId),
    CONSTRAINT CK_Warehouse_Capacity CHECK (Capacity > 0),
    CONSTRAINT CK_Warehouse_Latitude CHECK (Latitude BETWEEN -90 AND 90),
    CONSTRAINT CK_Warehouse_Longitude CHECK (Longitude BETWEEN -180 AND 180),
    CONSTRAINT CK_Warehouse_Manager_And_Date
        CHECK ((ManagerId IS NULL AND ManagerSince IS NULL)
            OR (ManagerId IS NOT NULL AND ManagerSince IS NOT NULL))
);

--Employee
CREATE TABLE Logistics.Employee
(
    MemberId    UNIQUEIDENTIFIER NOT NULL,
    WarehouseId INT              NOT NULL,

    CONSTRAINT PK_Employee PRIMARY KEY (MemberId)
);

--Category
CREATE TABLE Catalog.Category
(
    CategoryId       INT           NOT NULL,
    NameEn           VARCHAR(50)   NOT NULL,
    NameAr           NVARCHAR(50)  NOT NULL,
    CommissionPct    DECIMAL(4,2)  NOT NULL,
    ParentCategoryId INT           NULL,

    CONSTRAINT PK_Category PRIMARY KEY (CategoryId),
    CONSTRAINT UQ_Category_NameEn UNIQUE (NameEn),
    CONSTRAINT CK_Category_CommissionPct CHECK (CommissionPct BETWEEN 0 AND 30),
    CONSTRAINT CK_Category_NotItsOwnParent
        CHECK (ParentCategoryId IS NULL OR ParentCategoryId <> CategoryId)
);

--Item
CREATE TABLE Catalog.Item
(
    ItemId         INT IDENTITY(1,1) NOT NULL,
    Title          NVARCHAR(150)     NOT NULL,
    Description    NVARCHAR(MAX)     NULL,
    ConditionScore TINYINT           NOT NULL,
    Specs          NVARCHAR(MAX)     NOT NULL,
    ListedAt       DATETIME2(3)      NOT NULL
        CONSTRAINT DF_Item_ListedAt DEFAULT SYSUTCDATETIME(),
    SellerId       UNIQUEIDENTIFIER  NOT NULL,
    InspectorId    UNIQUEIDENTIFIER  NULL,
    CategoryId     INT               NOT NULL,
    WarehouseId    INT               NULL,

    CONSTRAINT PK_Item PRIMARY KEY (ItemId),
    CONSTRAINT CK_Item_ConditionScore CHECK (ConditionScore BETWEEN 1 AND 10),
    CONSTRAINT CK_Item_Specs CHECK (ISJSON(Specs) = 1),
    CONSTRAINT CK_Item_SellerIsNotInspector
        CHECK (InspectorId IS NULL OR InspectorId <> SellerId)
);


--Photo
CREATE TABLE Catalog.Photo
(
    ItemId  INT          NOT NULL,
    PhotoNo TINYINT      NOT NULL,
    Url     VARCHAR(500) NOT NULL,
    IsMain  BIT          NOT NULL
        CONSTRAINT DF_ItemPhoto_IsMain DEFAULT 0,

    CONSTRAINT PK_ItemPhoto PRIMARY KEY (ItemId, PhotoNo),
    CONSTRAINT CK_ItemPhoto_PhotoNo CHECK (PhotoNo BETWEEN 1 AND 20)
);

--Auction
CREATE TABLE Sales.Auction
(
    AuctionId    INT IDENTITY(1,1) NOT NULL,
    ItemId       INT               NOT NULL,
    StartPrice   DECIMAL(12,2)     NOT NULL,
    ReservePrice DECIMAL(12,2)     NULL,
    BidIncrement DECIMAL(12,2)     NOT NULL
        CONSTRAINT DF_Auction_BidIncrement DEFAULT 50.00,
    StartsAt     DATETIMEOFFSET    NOT NULL,
    EndsAt       DATETIMEOFFSET    NOT NULL,
    Status       VARCHAR(15)       NOT NULL
        CONSTRAINT DF_Auction_Status DEFAULT 'Draft',

    CONSTRAINT PK_Auction PRIMARY KEY (AuctionId),
    CONSTRAINT CK_Auction_StartPrice CHECK (StartPrice > 0),
    CONSTRAINT CK_Auction_BidIncrement CHECK (BidIncrement > 0),
    CONSTRAINT CK_Auction_Status
        CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled')),
    CONSTRAINT CK_Auction_Reserve_Not_Below_Start
        CHECK (ReservePrice IS NULL OR ReservePrice >= StartPrice),
    CONSTRAINT CK_Auction_End_After_Start CHECK (EndsAt > StartsAt)
);

--Bid
CREATE TABLE Sales.Bid
(
    BidId     BIGINT IDENTITY(1,1) NOT NULL,
    AuctionId INT                  NOT NULL,
    MemberId  UNIQUEIDENTIFIER     NOT NULL,
    Amount    DECIMAL(12,2)        NOT NULL,
    PlacedAt  DATETIME2(3)         NOT NULL
        CONSTRAINT DF_Bid_PlacedAt DEFAULT SYSUTCDATETIME(),
    IpAddress VARCHAR(45)          NOT NULL,

    CONSTRAINT PK_Bid PRIMARY KEY (BidId),
    CONSTRAINT CK_Bid_Amount CHECK (Amount > 0),
    CONSTRAINT UQ_Bid_AuctionId_Amount UNIQUE (AuctionId, Amount)
);

--AuctionFollower
CREATE TABLE Sales.AuctionFollower
(
    MemberId   UNIQUEIDENTIFIER NOT NULL,
    AuctionId  INT              NOT NULL,
    FollowedAt DATETIME2(3)     NOT NULL
        CONSTRAINT DF_AuctionFollower_FollowedAt DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_AuctionFollower PRIMARY KEY (MemberId, AuctionId)
);