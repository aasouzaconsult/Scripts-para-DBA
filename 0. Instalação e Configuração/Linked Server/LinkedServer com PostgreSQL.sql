--USE [master]
--GO
--EXEC master.dbo.sp_addlinkedserver @server = N'POSTGRES', @srvproduct=N'PostgreSQL', @provider=N'MSDASQL', @datasrc=N'PostgreSQL30'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'collation compatible', @optvalue=N'false'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'data access', @optvalue=N'true'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'rpc', @optvalue=N'false'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'rpc out', @optvalue=N'false'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'connect timeout', @optvalue=N'0'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'collation name', @optvalue=null
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'query timeout', @optvalue=N'0'
--GO
--EXEC master.dbo.sp_serveroption @server=N'POSTGRES', @optname=N'use remote collation', @optvalue=N'true'
--GO
--USE [master]
--GO
--EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'POSTGRES', @locallogin = NULL , @useself = N'False'
--GO


SELECT * FROM OPENQUERY(POSTGRES, 'SELECT * FROM INFORMATION_SCHEMA.TABLES');

SELECT * FROM OPENQUERY(POSTGRES, 'SELECT * FROM public.contrato_conclusao');
SELECT * FROM OPENQUERY(POSTGRES, 'SELECT * FROM public.delegacia');

SELECT * FROM OPENQUERY(POSTGRES, 'SELECT * FROM public.pasta');