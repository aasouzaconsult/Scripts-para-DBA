
Create database webcast
go
use WebCast 
go
CREATE TABLE [Employee](
	[EmployeeID] [int] IDENTITY(1,1) NOT NULL,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[ContactID] [int] NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[ManagerID] [int] NULL,
	[Title] [nvarchar](50) NOT NULL,
	[BirthDate] [datetime] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[HireDate] [datetime] NOT NULL,
	[SalariedFlag] char(10) NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[CurrentFlag] Char(10) NOT NULL,
	[rowguid] [uniqueidentifier] ROWGUIDCOL  NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	)