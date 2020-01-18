-- consulta outro SQL Server sem linked server
SELECT Adv.*
FROM OPENROWSET('SQLOLEDB','server';'Externo';'123',
'select top 10 * from AdventureWorks.HumanResources.Employee')
AS Adv

--SQLClient
SELECT Adv.*
FROM OPENROWSET('SQLNCLI', 'server';'Externo';'123',
     'SELECT GroupName, Name, DepartmentID
      FROM AdventureWorks.HumanResources.Department
      ORDER BY GroupName, Name') AS Adv;