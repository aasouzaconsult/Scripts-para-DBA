USE AdventureWorks

GO

WITH Aleatorio AS

(SELECT * FROM Person.Contact TABLESAMPLE(1 PERCENT))

SELECT TOP(3) * FROM Aleatorio


SELECT FirstName, LastName
FROM Person.Contact 
TABLESAMPLE (10 percent) 

SELECT FirstName, LastName
FROM Person.Contact 
TABLESAMPLE (100 rows)

SELECT FirstName, LastName
FROM Person.Contact 
TABLESAMPLE (10 percent)
 repeatable(10)