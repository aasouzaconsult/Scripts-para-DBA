BACKUP LOG [AdventureWorks] TO  DISK = N'D:\Alex\SQL Server\Backups\bkp_AdventureWorks_10032010_LOG.trn' 
WITH NO_TRUNCATE

USE AdventureWorks
GO

CREATE SCHEMA test AUTHORIZATION dbo
GO

CREATE TABLE test.Customer
(CustomerID     INT         IDENTITY(1,1),
LastName        VARCHAR(50) NOT NULL,
FirstName       VARCHAR(50) NOT NULL,
CreditLine      MONEY       SPARSE NULL,
CreationDate    DATE        NOT NULL)
GO

CREATE TABLE test.OrderHeader
(OrderID        INT         IDENTITY(1,1),
CustomerID      INT         NOT NULL,
OrderDate       DATE        NOT NULL,
OrderTime       TIME        NOT NULL,
SubTotal        MONEY       NOT NULL,
ShippingAmt     MONEY       NOT NULL,
OrderTotal      AS (SubTotal + ShippingAmt))
WITH (DATA_COMPRESSION = ROW)
GO

ALTER TABLE test.Customer
    ADD CONSTRAINT pk_customer PRIMARY KEY CLUSTERED (CustomerID)
GO    

ALTER TABLE test.OrderHeader
    ADD CONSTRAINT pk_orderheader PRIMARY KEY CLUSTERED (OrderID)
GO

ALTER TABLE test.OrderHeader
    ADD CONSTRAINT fk_orderheadertocustomer FOREIGN KEY (CustomerID)
        REFERENCES test.Customer (CustomerID)
GO        
        
ALTER TABLE test.Customer
    ADD CONSTRAINT df_creationdate DEFAULT (GETDATE()) FOR CreationDate
GO

ALTER TABLE test.OrderHeader
    ADD CONSTRAINT df_orderdate DEFAULT (GETDATE()) FOR OrderDate
GO
    
ALTER TABLE test.OrderHeader
    ADD CONSTRAINT ck_subtotal CHECK (SubTotal > 0)
GO