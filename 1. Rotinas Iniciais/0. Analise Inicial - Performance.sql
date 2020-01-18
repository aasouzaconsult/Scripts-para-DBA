-- Analise inicial do ambiente / performance

-- Informações do SQL Server e SO
SELECT SERVERPROPERTY ('MachineName') AS [Server Name]
     , @@VERSION AS [SQL Server and OS Version Info]
     , SERVERPROPERTY('Edition') AS [Edition]
     , SERVERPROPERTY('ProductLevel') AS [ProductLevel]
     , SERVERPROPERTY('ProductVersion') AS [ProductVersion]
     , SERVERPROPERTY('ProcessID') AS [ProcessID]
     , create_date AS [SQL Server Install Date]
FROM sys.server_principals WITH (NOLOCK)
WHERE name = N'NT AUTHORITY\SYSTEM'
   OR name = N'NT AUTHORITY\NETWORK SERVICE' OPTION (RECOMPILE);

-- Máquina
EXEC xp_readerrorlog 0, 1, N'Manufacturer'
-- Processador
EXEC xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', N'ProcessorNameString';
-- Parte Física (Servidor)
SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)], 
sqlserver_start_time, affinity_type_desc
FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);  

-- Dados 
SELECT [>] = 'DADOS';
SELECT DISTINCT vs.volume_mount_point, vs.file_system_type, 
vs.logical_volume_name, CONVERT(DECIMAL(18,2),vs.total_bytes/1073741824.0) AS [Total Size (GB)],
CONVERT(DECIMAL(18,2),vs.available_bytes/1073741824.0) AS [Available Size (GB)],  
CAST(CAST(vs.available_bytes AS FLOAT)/ CAST(vs.total_bytes AS FLOAT) AS DECIMAL(18,2)) * 100 AS [Space Free %] 
FROM sys.master_files AS f WITH (NOLOCK)
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.[file_id]) AS vs OPTION (RECOMPILE);

-- CPU
SELECT [>] = 'CPU';

-- Get CPU utilization by database (Query 24) (CPU Usage by Database)
WITH DB_CPU_Stats
AS
(SELECT DatabaseID, DB_Name(DatabaseID) AS [Database Name], SUM(total_worker_time) AS [CPU_Time_Ms]
 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY (SELECT CONVERT(int, value) AS [DatabaseID] 
              FROM sys.dm_exec_plan_attributes(qs.plan_handle)
              WHERE attribute = N'dbid') AS F_DB
 GROUP BY DatabaseID)
SELECT ROW_NUMBER() OVER(ORDER BY [CPU_Time_Ms] DESC) AS [CPU Rank],
       [Database Name], [CPU_Time_Ms] AS [CPU Time (ms)], 
       CAST([CPU_Time_Ms] * 1.0 / SUM([CPU_Time_Ms]) OVER() * 100.0 AS DECIMAL(5, 2)) AS [CPU Percent]
FROM DB_CPU_Stats
WHERE DatabaseID <> 32767 -- ResourceDB
ORDER BY [CPU Rank] OPTION (RECOMPILE);

-- Get CPU Utilization History for last 256 minutes (in one minute intervals)  (Query 32) (CPU Utilization History)
-- This version works with SQL Server 2008 R2
DECLARE @ts_now bigint = (SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info WITH (NOLOCK)); 

SELECT TOP(100) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers WITH (NOLOCK)
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE N'%<SystemHealth>%') AS x 
	  ) AS y 
ORDER BY record_id DESC OPTION (RECOMPILE);

-- IO
SELECT [>] = 'IO';
-- Get I/O utilization by database (Query 25) (IO Usage By Database)
WITH Aggregate_IO_Statistics
AS
(SELECT DB_NAME(database_id) AS [Database Name],
CAST(SUM(num_of_bytes_read + num_of_bytes_written)/1048576 AS DECIMAL(12, 2)) AS io_in_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS [DM_IO_STATS]
GROUP BY database_id)
SELECT ROW_NUMBER() OVER(ORDER BY io_in_mb DESC) AS [I/O Rank], [Database Name], io_in_mb AS [Total I/O (MB)],
       CAST(io_in_mb/ SUM(io_in_mb) OVER() * 100.0 AS DECIMAL(5,2)) AS [I/O Percent]
FROM Aggregate_IO_Statistics
ORDER BY [I/O Rank] OPTION (RECOMPILE);

-- MAX WORKER THREADS
SELECT [>] = 'MAX WORKER THREADS';
/* -------------------------------------------------------------------------
   Opção max worker threads
   http://msdn.microsoft.com/pt-br/library/ms187024%28v=sql.105%29.aspx

-------------------------------------------------------------------------
Configurar a opção max worker threads de configuração de servidor
http://msdn.microsoft.com/pt-br/library/ms190219.aspx

-------------------------------------------------------------------------
sys.dm_os_sys_info (Transact-SQL)
http://msdn.microsoft.com/pt-br/library/ms175048.aspx

select max_workers_count, * From sys.dm_os_sys_info
-------------------------------------------------------------------------
sys.dm_os_threads (Transact-SQL)
http://technet.microsoft.com/pt-br/library/ms187818%28v=sql.105%29.aspx

select count(*) from sys.dm_os_threads
select * from sys.dm_os_threads
-------------------------------------------------------------------------
Funções e exibições de gerenciamento dinâmico relacionadas ao sistema operacional do SQL Server (Transact-SQL)
http://technet.microsoft.com/pt-br/library/ms176083%28v=sql.105%29.aspx
------------------------------------------------------------------------- */
Select max_workers_count, * From sys.dm_os_sys_info
Select ATUAL = count(*) From sys.dm_os_threads --(857, 855, 856, 854, 865, 586, 644, 599, 569, 882)


-- Memória
SELECT [>] = 'MEMÓRIA';
-- Good basic information about OS memory amounts and state  (Query 34) (System Memory)
SELECT total_physical_memory_kb/1024 AS [Physical Memory (MB)], 
       available_physical_memory_kb/1024 AS [Available Memory (MB)], 
       total_page_file_kb/1024 AS [Total Page File (MB)], 
	   available_page_file_kb/1024 AS [Available Page File (MB)], 
	   system_cache_kb/1024 AS [System Cache (MB)],
       system_memory_state_desc AS [System Memory State]
FROM sys.dm_os_sys_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- SQL Server Process Address space info  (Query 35) (Process Memory) 
-- (shows whether locked pages is enabled, among other things)
SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
       large_page_allocations_kb, locked_page_allocations_kb, page_fault_count, 
	   memory_utilization_percentage, available_commit_limit_kb, 
	   process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- Memory Clerk Usage for instance  (Query 38) (Memory Clerk Usage)
-- Look for high value for CACHESTORE_SQLCP (Ad-hoc query plans)
SELECT TOP(10) [type] AS [Memory Clerk Type], SUM(single_pages_kb)/1024 AS [SPA Memory Usage (MB)] 
FROM sys.dm_os_memory_clerks WITH (NOLOCK)
GROUP BY [type]  
ORDER BY SUM(single_pages_kb) DESC OPTION (RECOMPILE);

-- CACHESTORE_SQLCP  SQL Plans         
-- These are cached SQL statements or batches that aren't in stored procedures, functions and triggers
-- Watch out for high values for CACHESTORE_SQLCP

-- CACHESTORE_OBJCP  Object Plans      
-- These are compiled plans for stored procedures, functions and triggers

-- Backups
SELECT [>] = 'BACKUPs'
-- Look at recent Full backups for the current database (Query 65) (Recent Full Backups)
SELECT TOP (30) bs.machine_name, bs.server_name, bs.database_name AS [Database Name], bs.recovery_model,
CONVERT (BIGINT, bs.backup_size / 1048576 ) AS [Uncompressed Backup Size (MB)],
CONVERT (BIGINT, bs.compressed_backup_size / 1048576 ) AS [Compressed Backup Size (MB)],
CONVERT (NUMERIC (20,2), (CONVERT (FLOAT, bs.backup_size) /
CONVERT (FLOAT, bs.compressed_backup_size))) AS [Compression Ratio], 
DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) AS [Backup Elapsed Time (sec)],
bs.backup_finish_date AS [Backup Finish Date]
FROM msdb.dbo.backupset AS bs WITH (NOLOCK)
WHERE DATEDIFF (SECOND, bs.backup_start_date, bs.backup_finish_date) > 0 
AND bs.backup_size > 0
AND bs.type = 'D' -- Change to L if you want Log backups
--AND database_name = DB_NAME(DB_ID())
ORDER BY bs.backup_finish_date DESC OPTION (RECOMPILE);


-- SEGURANÇA
SELECT [>] = 'SEGURANÇA'
--  Get logins that are connected and how many sessions they have (Query 29) (Connection Counts)
SELECT login_name, [program_name], COUNT(session_id) AS [session_count] 
FROM sys.dm_exec_sessions WITH (NOLOCK)
GROUP BY login_name, [program_name]
ORDER BY COUNT(session_id) DESC OPTION (RECOMPILE);

-- Get a count of SQL connections by IP address (Query 30) (Connection Counts by IP Address)
SELECT ec.client_net_address, es.[program_name], es.[host_name], es.login_name, 
COUNT(ec.session_id) AS [connection count] 
FROM sys.dm_exec_sessions AS es WITH (NOLOCK) 
INNER JOIN sys.dm_exec_connections AS ec WITH (NOLOCK) 
ON es.session_id = ec.session_id 
GROUP BY ec.client_net_address, es.[program_name], es.[host_name], es.login_name  
ORDER BY ec.client_net_address, es.[program_name] OPTION (RECOMPILE);

--Listar quais permissões cada usuário tem
--dentro do database
SELECT dp.NAME AS principal_name,
	   dp.type_desc AS principal_type_desc,
	   o.NAME AS [object_name],
	   p.permission_name,
	   p.state_desc AS permission_state_desc
 FROM      sys.database_permissions p
 LEFT JOIN sys.all_objects          o ON p.major_id             = o.[OBJECT_ID]
INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id

--Qual a database role?
SELECT USR.name AS [User_Name], 
	   USR1.name AS Database_Role
  FROM       SYS.database_role_members DR
  INNER JOIN sys.sysusers USR  ON DR.member_principal_id = USR.uid
  INNER JOIN sys.sysusers USR1 ON USR1.uid               = DR.role_principal_id


-- ESPAÇO
SELECT [>] = 'ESPAÇO';

-- Quanto de espaço cada tabela utiliza no database? (Por database)
BEGIN try  
DECLARE @table_name VARCHAR(500) ;  
DECLARE @schema_name VARCHAR(500) ;  
DECLARE @tab1 TABLE( 
        tablename VARCHAR (500) collate database_default 
,       schemaname VARCHAR(500) collate database_default 
);  
DECLARE  @temp_table TABLE (     
        tablename sysname 
,       row_count INT 
,       reserved VARCHAR(50) collate database_default 
,       data VARCHAR(50) collate database_default 
,       index_size VARCHAR(50) collate database_default 
,       unused VARCHAR(50) collate database_default  
);  
INSERT INTO @tab1 SELECT t1.name, t2.name FROM sys.tables t1  
INNER JOIN sys.schemas t2 ON ( t1.schema_id = t2.schema_id );    
DECLARE c1 CURSOR FOR  
SELECT t2.name + '.' + t1.name FROM sys.tables t1  
INNER JOIN sys.schemas t2 ON ( t1.schema_id = t2.schema_id );    
OPEN c1;  
FETCH NEXT FROM c1 INTO @table_name; 
WHILE @@FETCH_STATUS = 0  
BEGIN   
        SET @table_name = REPLACE(@table_name, '[','');  
        SET @table_name = REPLACE(@table_name, ']','');  
        -- make sure the object exists before calling sp_spacedused 
        IF EXISTS(SELECT OBJECT_ID FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(@table_name)) 
        BEGIN 
                INSERT INTO @temp_table EXEC sp_spaceused @table_name, false ; 
        END 
         
        FETCH NEXT FROM c1 INTO @table_name;  
END;  
CLOSE c1;  
DEALLOCATE c1;  
SELECT t1.*, t2.schemaname FROM @temp_table t1  
INNER JOIN @tab1 t2 ON (t1.tablename = t2.tablename ) 
ORDER BY  schemaname,tablename; 
END try  
BEGIN catch  
SELECT -100 AS l1 
,       ERROR_NUMBER() AS tablename 
,       ERROR_SEVERITY() AS row_count 
,       ERROR_STATE() AS reserved 
,       ERROR_MESSAGE() AS data 
,       1 AS index_size, 1 AS unused, 1 AS schemaname  
END catch