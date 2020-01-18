CREATE DATABASE AdventureWorksTest
USE AdventureWorksTest
GO

CREATE SCHEMA Person AUTHORIZATION dbo
GO

SELECT *
INTO	AdventureWorksTest.Person.Address 
FROM	AdventureWorks.Person.Address

SELECT *
FROM	AdventureWorksTest.Person.Address

SELECT AddressLine1, AddressLine2, City, PostalCode
FROM Person.Address
WHERE City = 'Dallas'
GO
SELECT AddressLine1, AddressLine2, City, PostalCode
FROM Person.Address
WHERE City LIKE 'S%'
GO
SELECT AddressLine1, AddressLine2, City, PostalCode
FROM Person.Address
WHERE PostalCode = '75201'
GO