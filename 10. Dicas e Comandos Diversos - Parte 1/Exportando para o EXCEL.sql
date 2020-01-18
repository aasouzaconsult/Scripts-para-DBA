--Exportando dados do SQL Server para o Excel
--
--
exec
sp_configure 'show advanced options', 1 
RECONFIGURE
exec
sp_configure 'Ad Hoc Distributed Queries', 1 
RECONFIGURE
GO
 
--
-- Realizando a carga dos dados do SQL Server para o Excel...
-- 
USE ADVENTUREWORKS2008
GO
INSERT INTO OPENROWSET('Microsoft.Jet.OLEDB.4.0',  'Excel 8.0;Database=C:\backup\empregados_advworks.xls;', 
'SELECT LoginID, JobTitle FROM [Sheet1$]') 
SELECT LoginID, JobTitle FROM HumanResources.Employee
GO
