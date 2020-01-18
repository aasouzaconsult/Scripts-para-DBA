SELECT * FROM sys.resource_governor_configuration
SELECT * FROM sys.resource_governor_resource_pools
SELECT * FROM sys.resource_governor_workload_groups

USE master
GO
-- Criando um Pool de Recurso
CREATE RESOURCE POOL [Relatórios] WITH(min_cpu_percent=0, 
		max_cpu_percent=100, 
		min_memory_percent=0, 
		max_memory_percent=100)
GO
-- Criando um Grupo de Carga de Trabalho
CREATE WORKLOAD GROUP [GrupoRelatorios] WITH(group_max_requests=0, 
		importance=Medium, 
		request_max_cpu_time_sec=0, 
		request_max_memory_grant_percent=25, 
		request_memory_grant_timeout_sec=0, 
		max_dop=0) USING [Relatórios]
GO

USE master
go
CREATE FUNCTION dbo.fn_ResourceGovernorClassifier()
RETURNS sysname
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @group  sysname
    --Workload group name is case sensitive, 
    --    regardless of server setting
    IF SUSER_SNAME() = 'Executivos'
        SET @group = 'GrupoExecutivos'
    ELSE IF SUSER_SNAME() = 'NaoExecutivos'
        SET @group = 'GrupoNaoExecutivos'
    ELSE IF SUSER_SNAME() = 'Relatórios'
        SET @group = 'GrupoRelatorios'
    ELSE
        SET @group = 'default'    

    RETURN @group        
END
GO

--Associate classifier function to resource governor
ALTER RESOURCE GOVERNOR WITH (CLASSIFIER_FUNCTION = dbo.fn_ResourceGovernorClassifier)
GO

--Make new classifier function active
ALTER RESOURCE GOVERNOR RECONFIGURE
GO

-- TESTANDO...
CREATE LOGIN Executive WITH PASSWORD = '123456'
GO
CREATE LOGIN Customer WITH PASSWORD = '123456'
GO
CREATE LOGIN AdHocReport WITH PASSWORD = '123456'
GO

SELECT b.name WorkloadGroup, a.login_name, a.session_id
FROM sys.dm_exec_sessions a INNER JOIN sys.dm_resource_governor_workload_groups b
    ON a.group_id = b.group_id
WHERE b.name != 'internal'

