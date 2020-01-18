sp_configure 'show advanced options', 1
reconfigure with override 
GO
sp_configure 'xp_cmdshell', 1
reconfigure with override 
SELECT * FROM sys.configurations
ORDER BY name ;
sp_configure 'show advanced options', 1
RECONFIGURE
sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE WITH OVERRIDE 
