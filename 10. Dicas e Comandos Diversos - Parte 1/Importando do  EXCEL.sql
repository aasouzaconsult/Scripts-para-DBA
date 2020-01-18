--
-- Realizando a leitura dos dados...
-- 
exec
sp_configure 'show advanced options', 1 
RECONFIGURE
exec
sp_configure 'Ad Hoc Distributed Queries', 1 
RECONFIGURE
GO
--
--
select
[Login], [Nome], [Sobrenome] 
FROM OPENDATASOURCE('Microsoft.Jet.OLEDB.4.0', 
'Data Source=C:\backup\empregados.xls;Extended Properties=Excel 8.0')...[Sheet1$] 
order
by [Login] asc