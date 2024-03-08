CREATE DATABASE Customer
GO

USE Customer
Go

CREATE TABLE [dbo].[CustomerDetail](
	[Id] int IDENTITY(1,1) NOT NULL,
	[Name] varchar(MAX) NOT NULL,
	[PhoneNumber] varchar(12) NULL,
	[Email] varchar(40) NULL,
	[Address] varchar (MAX) NULL,
	[CreateDate] DateTime,
	[IsActive] BIT 
) ON [PRIMARY]
GO