/*	O SQL Server 2005, apresenta várias inovações em relação ao SQL Server 2000, dentro as quais 
destacamos a claúsula TableSample.
	Através desta claúsula é possível retornar os dados especificados no select, de forma aleatória
sem ter a necessidade de utilizar a função NewID().
 
Veja abaixo o código de exemplo: */
 
USE AdventureWorks
GO
WITH Aleatorio AS
(SELECT * FROM Person.Contact TABLESAMPLE(1 PERCENT))
SELECT TOP(3) * FROM Aleatorio

SELECT FirstName, LastName FROM Person.Contact
TABLESAMPLE (10 percent)
 
SELECT FirstName, LastName  FROM Person.Contact
TABLESAMPLE (100 rows)
 
SELECT FirstName, LastName FROM Person.Contact
 TABLESAMPLE (10 percent)
 repeatable(10)