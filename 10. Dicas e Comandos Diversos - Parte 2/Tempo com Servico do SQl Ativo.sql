--
-- Quanto tempo se passou desde que o serviço do SQL Server 
-- foi inicializado?
--
--
USE master;
DECLARE @starttime datetime
SET @starttime = (SELECT crdate FROM sysdatabases WHERE name = 'tempdb' )

DECLARE @currenttime datetime
SET @currenttime = GETDATE()

DECLARE @difference_dd int
DECLARE @difference_hh int
DECLARE @difference_mi int

SET @difference_mi = (SELECT DATEDIFF(mi, @starttime, @currenttime))
SET @difference_dd = (@difference_mi/60/24)
SET @difference_mi = @difference_mi - (@difference_dd*60)*24
SET @difference_hh = (@difference_mi/60)
SET @difference_mi = @difference_mi - (@difference_hh*60)

PRINT 'O serviço do SQL Server foi iniciado: ' 
+ CONVERT(varchar, @difference_dd) + ' dias ' 
+ CONVERT(varchar, @difference_hh) + ' horas ' 
+ CONVERT(varchar, @difference_mi) + ' minutos.'  

